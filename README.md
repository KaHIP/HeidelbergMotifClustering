# Heidelberg Motif Clustering

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![C++20](https://img.shields.io/badge/C++-20-blue.svg?style=flat)
[![Linux](https://img.shields.io/badge/platform-Linux-blue)](https://github.com/LocalClustering/HeidelbergMotifClustering)
[![GitHub Stars](https://img.shields.io/github/stars/LocalClustering/HeidelbergMotifClustering)](https://github.com/LocalClustering/HeidelbergMotifClustering/stargazers)
[![ALENEX 2023](https://img.shields.io/badge/ALENEX-2023-green)](https://doi.org/10.1137/1.9781611977561.ch9)
[![ESA 2023](https://img.shields.io/badge/ESA-2023-green)](https://doi.org/10.4230/LIPIcs.ESA.2023.34)
[![Agent-Ready](https://img.shields.io/badge/agent--ready-yes-brightgreen)](https://github.com/LocalClustering/HeidelbergMotifClustering)

**Combinatorial algorithms for local motif clustering in graphs.** Given a seed node, find a well-characterized community by minimizing *motif conductance* — a measure based on the distribution of higher-order structures (triangles) rather than just edges.

## Algorithms

| Algorithm | Paper | Method | Binary |
|-----------|-------|--------|--------|
| **LMCHGP** | [ALENEX 2023](https://doi.org/10.1137/1.9781611977561.ch9) | Graph partitioning with triangle-weighted edges | `motif_clustering_graph` |
| **SOCIAL** | [ESA 2023](https://arxiv.org/pdf/2301.07145.pdf) | Clique expansion + max-flow quotient-cut improvement (MQI) | `social` |

**SOCIAL** is generally faster and produces higher-quality clusters by using flow-based improvements instead of graph partitioning.

## Quick Start

```console
# Clone with submodules
git clone --recursive https://github.com/LocalClustering/HeidelbergMotifClustering.git
cd HeidelbergMotifClustering

# Build both algorithms
cd SOCIAL && ./compile.sh && cd ..
cd LMCHGP && ./compile.sh && cd ..

# Run SOCIAL on a sample graph (find community around node 1)
./heidelberg_motif_clustering --algorithm social --graph examples/test_sample.graph --seed_node 1

# Run LMCHGP on the same graph
./heidelberg_motif_clustering --algorithm lmchgp --graph examples/test_sample.graph --seed_node 1
```

## Usage

```console
./heidelberg_motif_clustering --algorithm <social|lmchgp> --graph <file> --seed_node <n> [options]
```

| Option | Description | Default |
|--------|-------------|---------|
| `--algorithm <name>` | Algorithm: `social` (recommended) or `lmchgp` | *required* |
| `--graph <file>` | Path to graph file (METIS format) | *required* |
| `--seed_node <n>` | Seed node, 1-indexed | *required* |
| `--depths <d1:d2:...>` | BFS depths to explore | `1:2:3` |
| `--triangle_count <n>` | Total triangles in graph | auto-computed (social) |
| `--timelimit <s>` | Time limit in seconds | `3600` |
| `--output <file>` | Write community to file | stdout only |
| `--seed <n>` | Random seed | - |
| `--quiet` | Suppress verbose output | off |
| `--fix_seed` | Fix seed node during MQI (social only) | off |
| `--beta <n>` | Random imbalance trials per depth (lmchgp only) | `3` |
| `--label_prop` | Label propagation local search (lmchgp only) | off |

**Examples:**
```console
# SOCIAL — cluster around node 42 with custom BFS depths
./heidelberg_motif_clustering --algorithm social --graph network.graph --seed_node 42 --depths 2:3:4:5

# SOCIAL — save community to file
./heidelberg_motif_clustering --algorithm social --graph network.graph --seed_node 42 --output community.txt

# LMCHGP — with label propagation refinement
./heidelberg_motif_clustering --algorithm lmchgp --graph network.graph --seed_node 42 --label_prop
```

### Direct Binary Usage

You can also call the binaries directly for full control over all parameters:

```console
# SOCIAL
./SOCIAL/deploy/social network.graph --seed_node 5 --bfsdepth_parameter_string 1:2:3 \
  --triangle_count 50000 --write_cluster --output_filename community.txt

# LMCHGP
./LMCHGP/deploy/motif_clustering_graph network.graph --seed_node 5 \
  --bfsdepth_parameter_string 1:2:3 --beta 3 \
  --label_prop_ls --write_cluster --output_filename community.txt

# Count triangles (SOCIAL includes a triangle counter)
./SOCIAL/deploy/triangle_counter network.graph

# Evaluate a clustering result
./SOCIAL/deploy/evaluator network.graph --input_partition community.txt --triangle_count 50000
```

## Graph Format

Input graphs use the [METIS format](http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/manual.pdf):

```
<num_nodes> <num_edges>
<neighbors of node 1>
<neighbors of node 2>
...
```

Example (`test_sample.graph` — 7 nodes, 12 edges):
```
7 12
2 3 7
1 3 4 5
1 2 4 5
2 3 5 6 7
2 3 4
4 7
1 4 6
```

## Output

Both algorithms print:
- **Motif conductance** — quality score of the detected community (lower is better)
- **Community size** — number of nodes in the cluster
- **Timing** — total clustering and triangle enumeration time

With `--output`, the community is written as a list of node IDs (one per line).

## Requirements

- Linux (64-bit)
- C++20 compiler (GCC 7+ or Clang 11+)
- CMake >= 3.16
- Boost Program Options (`libboost-program-options-dev`)
- Intel TBB (`libtbb-dev`)
- hwloc (`libhwloc-dev`)
- OpenMPI (LMCHGP only)

Install on Ubuntu/Debian:
```console
sudo apt-get install libboost-program-options-dev libtbb-dev libhwloc-dev libnuma-dev numactl openmpi-bin
```

## Citation

If you use **LMCHGP**, please cite:
```bibtex
@inproceedings{DBLP:conf/alenex/ChhabraF023,
  author       = {Adil Chhabra and
                  Marcelo Fonseca Faraj and
                  Christian Schulz},
  title        = {Local Motif Clustering via (Hyper)Graph Partitioning},
  booktitle    = {Proceedings of the 25th Symposium on Algorithm Engineering and Experiments,
                  {ALENEX} 2023, Florence, Italy, January 22-23, 2023},
  pages        = {96--109},
  publisher    = {{SIAM}},
  year         = {2023},
  doi          = {10.1137/1.9781611977561.CH9}
}
```

If you use **SOCIAL**, please cite:
```bibtex
@inproceedings{DBLP:conf/esa/ChhabraF023,
  author       = {Adil Chhabra and
                  Marcelo Fonseca Faraj and
                  Christian Schulz},
  title        = {Faster Local Motif Clustering via Maximum Flows},
  booktitle    = {31st Annual European Symposium on Algorithms, {ESA} 2023, Amsterdam,
                  The Netherlands, September 4-6, 2023},
  series       = {LIPIcs},
  volume       = {274},
  pages        = {34:1--34:16},
  publisher    = {Schloss Dagstuhl - Leibniz-Zentrum f{\"{u}}r Informatik},
  year         = {2023},
  doi          = {10.4230/LIPIcs.ESA.2023.34}
}
```

## License

MIT License. See [LICENSE](LICENSE) for details.
