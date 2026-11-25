"""Generate synthetic banking data (no real people or accounts).

Output: data/raw/{customers,accounts,transactions,control_totals}.csv
Data-quality issues are injected on purpose so dbt tests have something to catch:
duplicate transactions, late-arriving records and missing channel values.
"""
import csv
import random
from collections import defaultdict
from datetime import date, datetime, timedelta
from decimal import Decimal
from pathlib import Path

SEED = 42
N_CUSTOMERS = 1_000
N_TRANSACTIONS = 50_000
START = datetime(2026, 1, 1)
DAYS = 180
OUT_DIR = Path(__file__).resolve().parents[1] / "data" / "raw"

FIRST_NAMES = ["Alex", "Sam", "Jordan", "Taylor", "Casey", "Robin", "Jamie", "Morgan"]
LAST_NAMES = ["Sample", "Example", "Testwell", "Mockley", "Demoson", "Fakerton"]
CITIES = ["Liverpool", "Manchester", "Leeds", "Bristol", "London", "Edinburgh"]
CHANNELS = ["card", "online", "mobile", "branch", "atm"]


def money(low: int, high: int) -> Decimal:
    """Random amount between low and high pence, returned in pounds."""
    return Decimal(random.randint(low, high)) / 100


def write_csv(name: str, rows: list) -> None:
    with open(OUT_DIR / f"{name}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{name}.csv: {len(rows):,} rows")


def make_customers() -> list:
    rows = []
    for i in range(1, N_CUSTOMERS + 1):
        first, last = random.choice(FIRST_NAMES), random.choice(LAST_NAMES)
        created = date(2020, 1, 1) + timedelta(days=random.randint(0, 2000))
        rows.append({
            "customer_id": f"C{i:06d}",
            "first_name": first,
            "last_name": last,
            "email": f"{first}.{last}{i}@example.com".lower(),
            "city": random.choice(CITIES),
            "postcode": f"ZZ{random.randint(1, 99)} {random.randint(1, 9)}ZZ",
            "created_date": created.isoformat(),
            "updated_at": f"{created.isoformat()} 00:00:00",
        })
    return rows


def make_accounts(customers: list) -> list:
    rows = []
    for customer in customers:
        for _ in range(random.choices([1, 2, 3], weights=[70, 25, 5])[0]):
            opened = date.fromisoformat(customer["created_date"]) + timedelta(days=random.randint(0, 30))
            rows.append({
                "account_id": f"A{len(rows) + 1:07d}",
                "customer_id": customer["customer_id"],
                "account_type": random.choice(["current", "savings", "credit_card"]),
                "currency": "GBP",
                "opened_date": opened.isoformat(),
                "status": random.choices(["active", "closed"], weights=[95, 5])[0],
            })
    return rows


def make_transactions(accounts: list) -> list:
    active = [a["account_id"] for a in accounts if a["status"] == "active"]
    rows = []
    for i in range(1, N_TRANSACTIONS + 1):
        ts = START + timedelta(seconds=random.randint(0, DAYS * 86_400 - 1))
        late = random.random() < 0.01
        delay = timedelta(days=random.randint(3, 7)) if late else timedelta(minutes=random.randint(1, 60))
        direction = random.choices(["debit", "credit"], weights=[80, 20])[0]
        rows.append({
            "transaction_id": f"T{i:09d}",
            "account_id": random.choice(active),
            "transaction_ts": ts.isoformat(sep=" "),
            "loaded_at": (ts + delay).isoformat(sep=" "),
            "direction": direction,
            "amount": money(100, 50_000) if direction == "debit" else money(1_000, 300_000),
            "currency": "GBP",
            "channel": "" if random.random() < 0.003 else random.choice(CHANNELS),
        })
    return rows


def control_totals(transactions: list) -> list:
    """Source-side daily counts and sums (before duplicates), used for reconciliation."""
    totals = defaultdict(lambda: [0, Decimal("0")])
    for t in transactions:
        day = totals[t["transaction_ts"][:10]]
        day[0] += 1
        day[1] += t["amount"]
    return [{"transaction_date": d, "row_count": c, "total_amount": s}
            for d, (c, s) in sorted(totals.items())]


def main() -> None:
    random.seed(SEED)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    customers = make_customers()
    accounts = make_accounts(customers)
    transactions = make_transactions(accounts)
    totals = control_totals(transactions)
    duplicates = random.sample(transactions, k=N_TRANSACTIONS // 200)
    feed = sorted(transactions + duplicates, key=lambda t: t["loaded_at"])
    write_csv("customers", customers)
    write_csv("accounts", accounts)
    write_csv("transactions", feed)
    write_csv("control_totals", totals)


if __name__ == "__main__":
    main()
