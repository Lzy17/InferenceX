#!/usr/bin/env bash
set -u

NODES=(
  amd@smci355-ccs-aus-g12-10.cs-aus.dcgpu
  amd@smci355-ccs-aus-g12-14.cs-aus.dcgpu
)

for node in "${NODES[@]}"; do
  echo "========================================"
  echo "Testing node: $node"
  echo "You may be prompted for a password."

  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$node" '
    echo "HOST: $(hostname)"
    echo "USER: $(whoami)"
    echo "REPO_EXISTS: $(test -d /data/sglang_bench/InferenceX && echo yes || echo no)"
    echo "INNER_EXISTS: $(test -f /data/sglang_bench/InferenceX/scripts/_disagg_ssh_remote_inner.sh && echo yes || echo no)"
    echo "ENTRY_EXISTS: $(test -f /data/sglang_bench/InferenceX/scripts/_disagg_container_entry.sh && echo yes || echo no)"
    echo "SERVER_EXISTS: $(test -f /data/sglang_bench/InferenceX/benchmarks/multi_node/amd_utils/server.sh && echo yes || echo no)"
    echo "DOCKER_EXISTS: $(command -v docker >/dev/null 2>&1 && echo yes || echo no)"
    echo "MODEL_EXISTS: $(test -d /dev/shm/DeepSeek-R1-0528 && echo yes || echo no)"
    echo "IBDEVICES: $(ibv_devinfo 2>/dev/null | awk '\''/hca_id:/ {print $2}'\'' | paste -sd,)"
    echo "DATA_IP: $(ip route get 1.1.1.1 2>/dev/null | awk '\''/src/ {print $7; exit}'\'')"
  '

  rc=$?
  echo "Exit code: $rc"
  echo
done
