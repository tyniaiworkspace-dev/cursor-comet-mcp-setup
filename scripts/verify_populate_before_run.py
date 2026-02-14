#!/usr/bin/env python3
"""
Verify that we can run populate_database before doing the full run.
- Checks scraper can fetch at least 1 unique item from poe2db.tw
- Checks DatabaseManager can write to the same DB the MCP uses (site-packages/data)
Run from: the directory that contains the installed 'src' (e.g. site-packages).
  cd C:\\Users\\admin\\Python\\Lib\\site-packages
  python path\\to\\verify_populate_before_run.py
Or set PYTHONPATH to site-packages and run from repo.
"""
import asyncio
import sys
from pathlib import Path

# Ensure we use the installed poe2-mcp (site-packages) so DB goes to site-packages/data
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
        from sqlalchemy import select, func

        print("1. DATA_DIR (DB will be written here):", DATA_DIR)
        print("   DB file:", DATA_DIR / "poe2_optimizer.db")

        print("\n2. Testing scraper (fetch 1 unique item from poe2db.tw)...")
        rate_limiter = RateLimiter(rate_limit=30)
        scraper = PoE2DataScraper(rate_limiter=rate_limiter)
        scraper_ok = False
        try:
            items = await scraper.scrape_unique_items(limit=1)
            if not items:
                print("   SKIP: No items returned (site may be down or URL changed). We will still test DB write.")
            else:
                print("   OK: Got", len(items), "item(s). Example:", items[0].get("name", "?"))
                scraper_ok = True
        finally:
            await scraper.close()

        print("\n3. Testing DB write (insert one row, then count)...")
        db = DatabaseManager()
        await db.initialize()
        try:
            async with db.async_session() as session:
                one = Item(
                    name="VerifyTestItem",
                    base_type="Test",
                    item_class="Other",
                    required_level=0,
                )
                session.add(one)
                await session.commit()
            async with db.async_session() as session:
                r = await session.execute(select(func.count(Item.id)))
                count = r.scalar()
            print("   OK: Items table count after insert:", count)
            # Remove test row so we don't pollute
            async with db.async_session() as session:
                from sqlalchemy import delete
                await session.execute(delete(Item).where(Item.name == "VerifyTestItem"))
                await session.commit()
        finally:
            await db.close()

        if scraper_ok:
            print("\nVerification passed. Safe to run full populate_database.py with same DATA_DIR.")
        else:
            print("\nDB write passed. Scraper failed (poe2db.tw 404 or changed). Full populate may fail until upstream fixes scraper URL.")
        return True

    try:
        ok = asyncio.run(run())
        sys.exit(0 if ok else 1)
    except Exception as e:
        print("Verification failed:", e)
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
