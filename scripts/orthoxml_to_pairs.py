#!/usr/bin/env python3
"""Regenerate ``pairs.tsv`` (ortholog pairs, QfO flattening) from a ``hogs.orthoxml[.gz]``.

The pairs are a secondary export of the HOGs: two genes of different species form an ortholog pair
when their deepest common group is an orthologGroup (the rule of the QfO benchmark's
``map_relations.py``). This script calls the same streaming writer the pipeline uses
(``ancestra.pipeline.write_pairs_streaming``), so the output is byte-identical to the
``pairs.tsv`` written by ``ancestra run``.

    python scripts/orthoxml_to_pairs.py hogs.orthoxml.gz pairs.tsv[.gz]
    # or, for QfO-style submissions, stream to stdout:
    python scripts/orthoxml_to_pairs.py hogs.orthoxml.gz - | gzip > pairs.tsv.gz

Memory: the OrthoXML is parsed into memory (about 3 GB for the 989k-protein QfO run); pairs are
streamed to disk. Output columns: ``#gene_a  gene_b  level`` (level = TaxRange of the group).
"""
import argparse
import gzip
import os
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("orthoxml", help="hogs.orthoxml or hogs.orthoxml.gz")
    ap.add_argument("out", help="output path; ends in .gz to compress; '-' = stdout")
    a = ap.parse_args(argv)
    from ancestra.orthoxml import read_orthoxml
    from ancestra.pipeline import write_pairs_streaming

    src = a.orthoxml
    with tempfile.TemporaryDirectory() as td:
        if src.endswith(".gz"):
            plain = os.path.join(td, "hogs.orthoxml")
            with gzip.open(src, "rb") as fi, open(plain, "wb") as fo:
                shutil.copyfileobj(fi, fo)
            src = plain
        ox = read_orthoxml(src)
        tmp = os.path.join(td, "pairs.tsv")
        n = write_pairs_streaming(ox, tmp)
        if a.out == "-":
            with open(tmp, "rb") as fi:
                shutil.copyfileobj(fi, sys.stdout.buffer)
        elif a.out.endswith(".gz"):
            with open(tmp, "rb") as fi, gzip.GzipFile(a.out, "wb", mtime=0) as fo:
                shutil.copyfileobj(fi, fo)
        else:
            shutil.copyfile(tmp, a.out)
    print(f"[orthoxml_to_pairs] {n} ortholog pairs -> {a.out}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
