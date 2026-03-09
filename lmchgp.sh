#!/bin/bash
# lmchgp.sh — CLI wrapper for LMCHGP (Local Motif Clustering via (Hyper)Graph Partitioning)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$SCRIPT_DIR/LMCHGP/deploy/motif_clustering_graph"

usage() {
    cat <<'EOF'
Usage: lmchgp.sh --graph <file> --seed_node <n> [options]

Local Motif Clustering via (Hyper)Graph Partitioning (ALENEX 2023).
Finds a local community around a seed node by minimizing motif conductance
using graph partitioning with triangle-weighted edges.

Required:
  --graph <file>           Path to graph file (METIS format)
  --seed_node <n>          Seed node (1-indexed)

Options:
  --depths <d1:d2:...>     BFS depths to explore (default: 1:2:3)
  --beta <n>               Number of random imbalance trials per depth (default: 3)
  --triangle_count <n>     Total triangles in graph (for exact motif conductance)
  --timelimit <s>          Time limit in seconds (default: 3600)
  --label_prop             Enable label propagation local search
  --output <file>          Write community to file
  --seed <n>               Random seed
  --quiet                  Suppress output
  --help                   Print this help

Examples:
  # Basic clustering around node 5
  lmchgp.sh --graph network.graph --seed_node 5

  # With label propagation refinement and custom depths
  lmchgp.sh --graph network.graph --seed_node 5 --depths 2:3:4 --label_prop

  # Save community to file
  lmchgp.sh --graph network.graph --seed_node 5 --output community.txt
EOF
    exit 0
}

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    echo "Build first: cd LMCHGP && ./compile.sh"
    exit 1
fi

# Defaults
GRAPH=""
SEED_NODE=""
DEPTHS="1:2:3"
BETA=""
TRIANGLE_COUNT=""
TIMELIMIT=""
LABEL_PROP=""
OUTPUT=""
SEED=""
QUIET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --graph)       GRAPH="$2"; shift 2 ;;
        --seed_node)   SEED_NODE="$2"; shift 2 ;;
        --depths)      DEPTHS="$2"; shift 2 ;;
        --beta)        BETA="$2"; shift 2 ;;
        --triangle_count) TRIANGLE_COUNT="$2"; shift 2 ;;
        --timelimit)   TIMELIMIT="$2"; shift 2 ;;
        --label_prop)  LABEL_PROP=1; shift ;;
        --output)      OUTPUT="$2"; shift 2 ;;
        --seed)        SEED="$2"; shift 2 ;;
        --quiet)       QUIET=1; shift ;;
        --help|-h)     usage ;;
        *)             echo "Unknown option: $1"; usage ;;
    esac
done

if [ -z "$GRAPH" ] || [ -z "$SEED_NODE" ]; then
    echo "Error: --graph and --seed_node are required."
    echo ""
    usage
fi

ARGS=("$GRAPH")
ARGS+=(--seed_node "$SEED_NODE")
ARGS+=(--bfsdepth_parameter_string "$DEPTHS")

[ -n "$BETA" ]           && ARGS+=(--beta "$BETA")
[ -n "$TRIANGLE_COUNT" ] && ARGS+=(--triangle_count "$TRIANGLE_COUNT")
[ -n "$TIMELIMIT" ]      && ARGS+=(--repetition_timelimit "$TIMELIMIT")
[ -n "$LABEL_PROP" ]     && ARGS+=(--label_prop_ls)
[ -n "$SEED" ]           && ARGS+=(--seed "$SEED")
[ -n "$QUIET" ]          && ARGS+=(--suppress_output)

if [ -n "$OUTPUT" ]; then
    ARGS+=(--write_cluster --output_filename "$OUTPUT")
fi

exec "$BINARY" "${ARGS[@]}"
