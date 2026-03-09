#!/bin/bash
# social.sh — CLI wrapper for SOCIAL (Faster Local Motif Clustering via Maximum Flows)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$SCRIPT_DIR/SOCIAL/deploy/social"
TRIANGLE_COUNTER="$SCRIPT_DIR/SOCIAL/deploy/triangle_counter"

usage() {
    cat <<'EOF'
Usage: social.sh --graph <file> --seed_node <n> [options]

Faster Local Motif Clustering via Maximum Flows (ESA 2023).
Finds a local community around a seed node using clique expansion
and max-flow quotient-cut improvement (MQI).

Required:
  --graph <file>           Path to graph file (METIS format)
  --seed_node <n>          Seed node (1-indexed)

Options:
  --depths <d1:d2:...>     BFS depths to explore (default: 1:2:3)
  --triangle_count <n>     Total triangles in graph (auto-computed if omitted)
  --timelimit <s>          Time limit in seconds (default: 3600)
  --fix_seed               Fix seed node during MQI improvement
  --output <file>          Write community to file
  --seed <n>               Random seed
  --quiet                  Suppress output
  --help                   Print this help

Examples:
  # Basic clustering around node 5
  social.sh --graph network.graph --seed_node 5

  # With fixed seed node
  social.sh --graph network.graph --seed_node 5 --fix_seed

  # Save community and auto-count triangles
  social.sh --graph network.graph --seed_node 5 --output community.txt
EOF
    exit 0
}

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    echo "Build first: cd SOCIAL && ./compile.sh"
    exit 1
fi

# Defaults
GRAPH=""
SEED_NODE=""
DEPTHS="1:2:3"
TRIANGLE_COUNT=""
TIMELIMIT=""
FIX_SEED=""
OUTPUT=""
SEED=""
QUIET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --graph)       GRAPH="$2"; shift 2 ;;
        --seed_node)   SEED_NODE="$2"; shift 2 ;;
        --depths)      DEPTHS="$2"; shift 2 ;;
        --triangle_count) TRIANGLE_COUNT="$2"; shift 2 ;;
        --timelimit)   TIMELIMIT="$2"; shift 2 ;;
        --fix_seed)    FIX_SEED=1; shift ;;
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

# Auto-compute triangle count if not provided
if [ -z "$TRIANGLE_COUNT" ] && [ -f "$TRIANGLE_COUNTER" ]; then
    echo "Counting triangles..."
    TRIANGLE_COUNT=$("$TRIANGLE_COUNTER" "$GRAPH" 2>/dev/null | grep -oP 'triangles\s*[=:]\s*\K[0-9]+' || echo "")
fi

ARGS=("$GRAPH")
ARGS+=(--seed_node "$SEED_NODE")
ARGS+=(--bfsdepth_parameter_string "$DEPTHS")

[ -n "$TRIANGLE_COUNT" ] && ARGS+=(--triangle_count "$TRIANGLE_COUNT")
[ -n "$TIMELIMIT" ]      && ARGS+=(--repetition_timelimit "$TIMELIMIT")
[ -n "$FIX_SEED" ]       && ARGS+=(--fix_seed_node)
[ -n "$SEED" ]           && ARGS+=(--seed "$SEED")
[ -n "$QUIET" ]          && ARGS+=(--suppress_output)

if [ -n "$OUTPUT" ]; then
    ARGS+=(--write_cluster --output_filename "$OUTPUT")
fi

exec "$BINARY" "${ARGS[@]}"
