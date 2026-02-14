#!/usr/bin/env python3
"""
Populate the Items table from poe2db.tw (uniques + skill gems + support gems).
Uses the same DATA_DIR as the MCP so health_check sees the data.
Run from workspace with:
  python scripts\\populate_items.py
Optional env:
  LIMIT=N     cap unique items (default 0 = all). Gems are always full. E.g. LIMIT=100 for uniques-only quick run.
  UNIQUES_ONLY=1   skip skill/support gems (only scrape and insert uniques).
Verified counts (Perplexity): ~403 uniques, ~355 skill gems, ~527 support gems (~1,285 total).
"""
import asyncio
import os
import sys
from pathlib import Path

_candidates = [
    Path(r"C:\Users\admin\Python\Lib\site-packages"),
    Path(__file__).resolve().parent.parent.parent.parent / "Python" / "Lib" / "site-packages",
]
for _p in _candidates:
    if _p.exists() and (_p / "src" / "config.py").exists():
        sys.path.insert(0, str(_p))
        break


def main():
    async def run():
        from src.config import DATA_DIR
        from src.database.manager import DatabaseManager
        from src.database.models import Item
        from src.utils.scraper import PoE2DataScraper
        from src.api.rate_limiter import RateLimiter
        from sqlalchemy import select, func, delete

        limit_raw = os.environ.get("LIMIT", "0")
        limit = int(limit_raw) if limit_raw != "0" else None
        uniques_only = os.environ.get("UNIQUES_ONLY", "").strip().lower() in ("1", "true", "yes")

        print("DATA_DIR:", DATA_DIR)
        print("DB file:", DATA_DIR / "poe2_optimizer.db")
        print("Scraping uniques (limit=%s)..." % (limit or "all"))

        rate_limiter = RateLimiter(rate_limit=30)
        scraper = PoE2DataScraper(rate_limiter=rate_limiter)
        all_rows = []
        try:
            uniques = await scraper.scrape_unique_items(limit=limit)
            for d in uniques:
                all_rows.append(Item(
                    name=d.get("name", ""),
                    base_type=d.get("base_type", "Unique"),
                    item_class=d.get("item_class", "Other"),
                    rarity=d.get("rarity"),
                    required_level=int(d.get("level_requirement") or 0),
                ))
            print("  Uniques: %d" % len(uniques))

            if not uniques_only:
                print("Scraping skill gems...")
                skills = await scraper.scrape_skill_gems()
                for d in skills:
                    all_rows.append(Item(
                        name=d.get("name", ""),
                        base_type="Skill Gem",
                        item_class="Gem",
                        rarity=None,
                        required_level=0,
                    ))
                print("  Skill gems: %d" % len(skills))
                print("Scraping support gems...")
                supports = await scraper.scrape_support_gems()
                for d in supports:
                    all_rows.append(Item(
                        name=d.get("name", ""),
                        base_type="Support Gem",
                        item_class="Gem",
                        rarity=None,
                        required_level=0,
                    ))
                print("  Support gems: %d" % len(supports))
        finally:
            await scraper.close()

        if not all_rows:
            print("No items scraped. Exiting.")
            return False

        print("Inserting %d items into DB..." % len(all_rows))

        db = DatabaseManager()
        await db.initialize()
        try:
            async with db.async_session() as session:
                await session.execute(delete(Item))
                await session.commit()
            async with db.async_session() as session:
                for row in all_rows:
                    session.add(row)
                await session.commit()
            async with db.async_session() as session:
                r = await session.execute(select(func.count(Item.id)))
                count = r.scalar()
            print("Items table count: %d" % count)
        finally:
            await db.close()

        print("Done. Restart MCP and run health_check to confirm.")
        return True

    try:
        ok = asyncio.run(run())
        sys.exit(0 if ok else 1)
    except Exception as e:
        print("Populate failed:", e)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
