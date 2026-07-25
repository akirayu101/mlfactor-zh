"""Build the deterministic browser sample used by the Quarto prototype."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path

import pandas as pd
import pyreadr


DEFAULT_COLUMNS = [
    "stock_id",
    "date",
    "Mkt_Cap_12M_Usd",
    "Pb",
    "Vol1Y_Usd",
    "Mom_11M_Usd",
    "R1M_Usd",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=Path("material/data_ml.RData"),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("quarto/data/data_ml_web.csv.gz"),
    )
    parser.add_argument("--stocks", type=int, default=60)
    args = parser.parse_args()

    source = args.source.resolve()
    output = args.output.resolve()
    metadata_path = output.with_name("data_ml_web.meta.json")

    result = pyreadr.read_r(source)
    if "data_ml" not in result:
        raise KeyError("data_ml.RData does not contain an object named 'data_ml'")

    data = result["data_ml"].copy()
    data["date"] = pd.to_datetime(data["date"])

    history = (
        data.groupby("stock_id", sort=True)
        .size()
        .rename("observations")
        .reset_index()
        .sort_values(
            ["observations", "stock_id"],
            ascending=[False, True],
            kind="stable",
        )
    )
    selected_stocks = history.head(args.stocks)["stock_id"].tolist()

    sample = (
        data.loc[data["stock_id"].isin(selected_stocks), DEFAULT_COLUMNS]
        .sort_values(["date", "stock_id"], kind="stable")
        .reset_index(drop=True)
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(output, "wt", encoding="utf-8", newline="") as handle:
        sample.to_csv(handle, index=False, date_format="%Y-%m-%d")

    metadata = {
        "source": str(args.source).replace("\\", "/"),
        "source_sha256": sha256(source),
        "selection": (
            f"Top {args.stocks} stock_id values by observation count; "
            "ties ordered by stock_id ascending"
        ),
        "rows": len(sample),
        "stocks": int(sample["stock_id"].nunique()),
        "date_min": sample["date"].min().date().isoformat(),
        "date_max": sample["date"].max().date().isoformat(),
        "columns": DEFAULT_COLUMNS,
        "missing_values": {
            column: int(count)
            for column, count in sample.isna().sum().items()
        },
    }
    metadata_path.write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(
        f"Wrote {len(sample):,} rows, "
        f"{sample['stock_id'].nunique()} stocks to {output}"
    )


if __name__ == "__main__":
    main()
