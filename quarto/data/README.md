# Quarto prototype data

`data_ml_web.csv.gz` is a deterministic, browser-sized subset derived from
`material/data_ml.RData`.

It is included only to validate the executable-book prototype. Confirm the
upstream data redistribution terms before treating it as a separately licensed
dataset or publishing additional derivatives.

Regenerate it from the repository root:

```sh
uv run --with pyreadr --with pandas python scripts/build_quarto_web_data.py
```

The generated `data_ml_web.meta.json` records the source hash, selection rule,
shape, date range, columns, and missing-value counts.
