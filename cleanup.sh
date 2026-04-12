#!/usr/bin/env bash
set -u

NODES=(
  amd@smci355-ccs-aus-g12-10.cs-aus.dcgpu
  amd@smci355-ccs-aus-g12-14.cs-aus.dcgpu
)

PORTS=(8998 30025 30026 30027)

for node in "${NODES[@]}"; do
  echo "=================================================="
  echo "Cleaning node: $node"
  echo "You may be prompted for SSH password and sudo password."
  echo "=================================================="

  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$node" '
    set +e

    echo "[HOST] $(hostname)"
    echo "[STEP] Show listeners before cleanup"
    for p in 8998 30025 30026 30027; do
      echo "--- port $p ---"
      sudo ss -ltnp "sport = :$p" || true
      sudo lsof -nP -iTCP:$p -sTCP:LISTEN || true
    done

    echo "[STEP] Kill listeners on target ports"
    for p in 8998 30025 30026 30027; do
      pids=$(sudo lsof -t -iTCP:$p -sTCP:LISTEN 2>/dev/null || true)
      if [[ -n "$pids" ]]; then
        echo "Killing PIDs on port $p: $pids"
        sudo kill $pids || true
        sleep 2
        pids2=$(sudo lsof -t -iTCP:$p -sTCP:LISTEN 2>/dev/null || true)
        if [[ -n "$pids2" ]]; then
          echo "Force killing remaining PIDs on port $p: $pids2"
          sudo kill -9 $pids2 || true
        fi
      else
        echo "No listeners on port $p"
      fi
    done

    echo "[STEP] Remove all docker containers"
    sudo docker ps -aq | xargs -r sudo docker rm -f

    echo "[STEP] Kill common leftover processes"
    pkill -f "sglang.launch_server" || true
    pkill -f "python3 -m sglang.launch_server" || true
    pkill -f "benchmarks/multi_node/amd_utils/server.sh" || true
    pkill -f "benchmarks/multi_node/amd_utils/sync.py" || true
    pkill -f "sglang_router.launch_router" || true

    echo "[STEP] Show listeners after cleanup"
    for p in 8998 30025 30026 30027; do
      echo "--- port $p ---"
      sudo ss -ltnp "sport = :$p" || true
    done

    echo "[DONE] $(hostname)"
  '

  rc=$?
  echo "[EXIT CODE] $node -> $rc"
  echo
done
