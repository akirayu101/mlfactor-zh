# Quarto executable-book prototype

This directory contains the two-chapter executable-book prototype.

## Render

Install the Quarto Live extension once:

```sh
quarto add r-wasm/quarto-live
```

Then render from the repository root:

```sh
quarto render quarto
```

The output is written to `quarto-preview/`, which is intentionally ignored by
Git. On the quant server it is available below the existing Nginx mount at:

```text
http://192.168.1.6:8088/mlfactor/quarto-preview/
```
