#!/usr/bin/env bash
# End-to-end example on a toy simulation (6 species, 1,828 proteins, exact orthology truth).
# Runs the frozen method with both presets and gene order, validates the OrthoXML, and scores the
# result against the simulator truth. Expected wall time: ~2-3 min on 4 threads.
#
#   bash example/run_example.sh [THREADS=4]
#
# Needs: `pip install -e .` (or run from the repo root) and diamond, mmseqs2, famsa, FastTree on PATH
# (environment.yml). Outputs go to example/out/ (git-ignored).
set -euo pipefail
cd "$(dirname "$0")/.."
THREADS="${1:-4}"
export OMP_NUM_THREADS="$THREADS" NUMBA_NUM_THREADS="$THREADS"
D=example/data
O=example/out
rm -rf "$O"; mkdir -p "$O"
t0=$(date +%s)

# 0. (already committed; regenerate with)  python -m ancestra.simulate --out example/data --seed 11 --species 6 --genes 300
#    then `rm example/data/truth/gene_tree_*.nwk`. The simulation is seeded and byte-reproducible.

# 1. gene-order tables (synteny layer) from the simulator's GFF3 files
python - <<PY
import glob, os
from ancestra.genomes import build_ensembl_species, write_gene_order
os.makedirs("$O/gene_order", exist_ok=True)
for fa in sorted(glob.glob("$D/proteomes/*.fa")):
    sp = os.path.basename(fa)[:-3]
    df, cov = build_ensembl_species(fa, f"$D/gff/{sp}.gff3")
    write_gene_order(df, f"$O/gene_order/{sp}.parquet")
print("gene-order tables written for", len(glob.glob("$O/gene_order/*.parquet")), "species")
PY

# 2. run both presets (accurate = default; fast = NJ local trees), with gene order
for preset in accurate fast; do
  echo "== preset: $preset"
  python -m ancestra run --proteomes $D/proteomes --tree $D/species_tree.nwk \
      --gene-order $O/gene_order --preset $preset --threads "$THREADS" --out $O/$preset
  # 3. validate the OrthoXML (XSD, geneRef integrity, TaxRange == LCA, pairs, pyham)
  python scripts/verify_orthoxml.py $O/$preset --json $O/$preset/verify.json
  # 4. score against the simulator truth (ortholog-pair precision/recall)
  python -m ancestra eval --truth $D/truth/hogs.orthoxml --pred $O/$preset/hogs.orthoxml | tee $O/$preset/eval.txt | head -3
done

# 5. pairs can be regenerated from the OrthoXML alone, byte-identically
python scripts/orthoxml_to_pairs.py $O/accurate/hogs.orthoxml $O/pairs_regen.tsv
cmp $O/accurate/pairs.tsv $O/pairs_regen.tsv && echo "pairs regenerated from OrthoXML: identical"

echo "example finished OK in $(( $(date +%s) - t0 )) s"
