# Frozen-method predictions

Outputs of Ancestra at git tag **`freeze-v1`** of the research repository, exactly as scored in the project's
final evaluations. They are not re-generated for this repository. Every file is gzip-compressed (`gzip -n -9`) and
below 95 MB. The uncompressed md5 of each file equals the md5 recorded in the run's `manifest.json` (checked when this
repository was assembled).

| run | benchmark | preset | gene order | proteomes | guide tree |
|---|---|---|---|---|---|
| `orthobench/accurate` | Open OrthoBench | `accurate` (default) | yes | 12 OrthoBench proteomes (251,378 proteins) | `inputs/orthobench/guide_tree.nwk` (NCBI taxonomy) |
| `orthobench/fast` | Open OrthoBench | `fast` | yes | same | same |
| `qfo2022/accurate` | QfO 2022 | `accurate` (default) | yes | 78 QfO 2022_02 canonical proteomes (988,778 proteins) | `inputs/qfo2022/guide_tree.nwk` (NCBI taxonomy) |
| `qfo2022/fast` | QfO 2022 | `fast` | yes | same | same |

## Files

Each run directory contains:

- `hogs.orthoxml.gz`: the primary output (OrthoXML 0.5, XSD-valid, levels = guide-tree node names).
- `pairs.tsv.gz` (OrthoBench runs only): ortholog pairs (`#gene_a  gene_b  level`) derived from the HOGs by the QfO
  flattening rule. For QfO, the pair files (67–71 MB each) are left out to keep the repository small. Regenerate them
  with `python scripts/orthoxml_to_pairs.py hogs.orthoxml.gz pairs.tsv.gz`. The output is byte-identical to the
  original `pairs.tsv` (tested by checksum on all four runs). The table below
  gives the sha256 of the uncompressed QfO pair files, so a regenerated file can be checked.
- `orthobench_ogs.txt.gz` (OrthoBench runs only): root-level groups in the Open OrthoBench input format. It is the file
  that was scored. Not provided for QfO (it is not used by that benchmark).
- `manifest.json`: provenance written by the pipeline (tool versions, git commit, argv, full config, md5 of every input
  proteome, per-stage wall time and peak RSS, per-node merge statistics, output md5). Paths in `argv` are those of the
  research repository, where the data lived under `data/`.
- `verify_orthoxml.json`: result of `scripts/verify_orthoxml.py` on that run in the research repository. All eight checks
  passed (XSD, geneRef integrity, genes once, TaxRange = LCA, pairs count, flattening equals the QfO extractor, pyham
  loads, OrthoBench reader accepts). Two of them (`flattening_vs_qfo`, `orthobench_export`) need benchmark code that is
  not in this repository; see the main README.
- OrthoBench runs: `time.txt` (`/usr/bin/time -v`). QfO runs: `stage_accounting.json` (per-stage wall, CPU and RSS).

## Checksums

`SHA256SUMS` (this directory) covers the `.gz` files: `cd predictions && sha256sum -c SHA256SUMS`.

| file | gz size | sha256 (gz file) | sha256 (uncompressed) |
|---|---|---|---|
| `orthobench/accurate/hogs.orthoxml.gz` | 3.5 MB | `b3931b0359c73453b77716e27e240327fa10c2b65fb6f39bb08ddae47a389820` | `392d12fb8219efc33c45bf791384cc215d062b8eab734fd6d6a3c11e0965f287` |
| `orthobench/accurate/orthobench_ogs.txt.gz` | 1.1 MB | `f3ba84e7be4e96e987e9a6fb01e5468fa57105e3906c2470ac89deb0a80e7a94` | `df3746158c5e3eb880c4e81eadcf66a64e86d74beae2c5c5c52b52b5d74bd521` |
| `orthobench/accurate/pairs.tsv.gz` | 6.7 MB | `e7603f0b74f355fe0ce3d8ef21ae7f179522c02d2e4734a1c34eb4120aebcadb` | `223fc0c358b600e0e3e41e50c3b9ba2657e3e30381e1e9f2a6c3b9f6602abed8` |
| `orthobench/fast/hogs.orthoxml.gz` | 3.5 MB | `0bad66294c7474d3ba4d278f6bfa423083c41ec6d3aa6cc96ac7868abbc734d0` | `487aa2e38b2eb6ee5b98e1089d2bb6bbcc8c329563e435118084c7949d6dcfb3` |
| `orthobench/fast/orthobench_ogs.txt.gz` | 1.1 MB | `8edcf5befadd45478f770c046ca75124b12e4cbe405af3dd640c2dedc51b0563` | `b22fec446780d10c206cb9b0de39c3c912215d67b0bb0c2817b2ad41b42f238e` |
| `orthobench/fast/pairs.tsv.gz` | 6.7 MB | `5573f2ea74cbbbc0b7e728ec7b859666b500a7c74b36d9a56659296ff7673e08` | `5f4490d6668ab39c83878df7e1db037ad69d63762cd7388b6788ca70e075ec0d` |
| `qfo2022/accurate/hogs.orthoxml.gz` | 13.1 MB | `de46f16b53fa97e9ca5f8573e9d134a7ec0552732f1fbb97a5622521475b288f` | `7c98bdb92c186a1223ba42b3b732e44b03b3b083a100e731f84ca23f2ae33e65` |
| `qfo2022/accurate/pairs.tsv` (not included; regenerate) | – | – | `cbc448c2ed4ebb9fce1f877dfff6ff2434c47355967855ad7b7e49a16c760283` |
| `qfo2022/fast/hogs.orthoxml.gz` | 13.2 MB | `6dea475f43c31a5cae0e8308a4b0d47bb3befa465ea5a333ea0f8d49f7d19099` | `4b20beea8664803b3035a5160fb5ea31b1c79a09eb95c987c9576f9230530829` |
| `qfo2022/fast/pairs.tsv` (not included; regenerate) | – | – | `ada7b0158f4bf3936c3c2089796cced1ae1fb800b6d5955e4366e8b6c2dd2740` |

## Provenance and exact command lines

Code: `ancestra/` in this repository is a byte-identical copy of `ancestra/` at tag `freeze-v1` (`git archive freeze-v1
ancestra`; sha256 of every file in `results/freeze.json`). The run manifests record the sha256 of the code that ran; they
match `freeze.json`. The git commit ids inside the manifests differ from the tag commit, because the runs were made on
commits before and after the tag in which `ancestra/` did not change (`docs/DISCLOSURES.md`, item 16).

**OrthoBench** (`orthobench/accurate`, run on 10 threads, 31.5 min wall, 3.91 CPU-h, max RSS 14.0 GB on a shared node):

```bash
python -u -m ancestra run --proteomes <OrthoBench>/BENCHMARKS/Input \
    --tree inputs/orthobench/guide_tree.nwk --gene-order inputs/orthobench/gene_order \
    --out runs/ob_accurate --threads 10 --preset accurate
```

`orthobench/fast` is the same command with `--preset fast`, run on the S0 and S2 checkpoints of the `accurate` run (the
merge and output stages depend on the preset; S0 and S2 do not). Its merge-only wall time was 69 s.
The original command lines were: `--tree results/S1_speciestree/ob/ncbi.nwk --gene-order data/genomes/orthobench`.

**QfO 2022** (`qfo2022/accurate`, `qfo2022/fast`): run with `scripts/qfo_pipeline_driver.py` of the research repository
(a thin wrapper around `ancestra.pipeline.run_pipeline` that adds per-stage accounting and cache invalidation; it does
not change the method), on 12 threads:

```bash
python scripts/qfo_pipeline_driver.py --proteomes data/inputs/qfo2022/proteomes \
    --tree data/inputs/qfo2022/guide_tree_ncbi.nwk --gene-order data/inputs/qfo2022/gene_order \
    --out work/qfo2022_det/cand2_<preset> --threads 12 --preset <accurate|fast> \
    --reuse-stages-from work/qfo2022_det/det_nogo
```

The S0 (families) and S2 (scores) checkpoints were computed once in the deterministic run `det_nogo` (S0 25.6 min,
S2 64.8 min wall, 12 threads, peak RSS 29.5 GB) and hard-linked into both runs, so the accounting in these two
directories covers the merge and output stages only (`accurate` merge and output: 50.8 min wall, 7.0 CPU-h; `fast` merge: 6.3 min wall, 0.11 CPU-h). The
equivalent plain command is `ancestra run --proteomes <78 canonical QfO FASTA files> --tree inputs/qfo2022/guide_tree.nwk
--gene-order inputs/qfo2022/gene_order --preset <preset> --threads 12 --out <dir>`; a full QfO re-run from scratch with the
public CLI was not repeated for this repository.

The 78 input proteomes are the canonical `UPxxxxxxxxx_<taxid>.fasta` files of
`qfo_release-2022_02_with_updated_UP000000437` (see `docs/DATA.md` section 3; md5 of each in `inputs/qfo2022/inputs.json`
and in the manifests).

## Scores

The OrthoBench files score as reported in `results/orthobench_final/summary.md` when run through `bench/scripts/run_orthobench.sh`
(re-checked when this repository was assembled: test F 76.19 `accurate`, 74.79 `fast`). QfO scores come from the official QfO
benchmark code, run locally (`bench/scripts/run_qfo_local.sh`); the resulting tables are in `results/qfo_final/summary.md`.
