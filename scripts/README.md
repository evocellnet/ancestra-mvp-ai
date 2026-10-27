# scripts

Copied from the research repository (`scripts/`), except where noted. They expect the raw data under `data/` (or `DATA_DIR`);
see `docs/DATA.md`.

| script | purpose |
|---|---|
| `verify_orthoxml.py RUN_DIR` | eight output checks: XSD, geneRef integrity, each gene once, TaxRange = LCA of members, pairs count, flattening equals the QfO extractor, pyham loads, OrthoBench export readable. **Changed for this repository:** the QfO extractor and OrthoBench `benchmark.py` are optional. If they are not found (set `QFO_BENCHMARK_DIR`, `ORTHOBENCH_DIR`, `QFO_MAPPING`, or `DATA_DIR`), those two checks are reported as SKIP instead of failing. |
| `orthoxml_to_pairs.py` | **new:** regenerate `pairs.tsv` from a `hogs.orthoxml[.gz]` with the pipeline's own writer (byte-identical; tested on the OrthoBench and QfO predictions) |
| `verify_ids.py` | input check for the QfO 2022 run (78 species, canonical files, accessions, tree leaves, gene-order tables); needs the QfO release and `mapping.json.gz` |
| `build_gene_order_orthobench.py` | gene-order tables for the 12 OrthoBench species from Ensembl 99 GFF3 |
| `build_gene_order.sh` | gene-order tables for the QfO 2022 proteomes (`ancestra.genomes_qfo`) |

Benchmark wrappers (OrthoBench scorer, local QfO runner, controls, published results) are in `../bench/`.
