#!/usr/bin/env bash
set -euo pipefail

_IX_ROOT="/data/sglang_bench/InferenceX"

export PREFILL_NODE="smci355-ccs-aus-g12-10.cs-aus.dcgpu"
export DECODE_NODE="smci355-ccs-aus-g12-14.cs-aus.dcgpu"

export PREFILL_IP="10.235.58.205"
export DECODE_IP="10.235.58.242"

export IBDEVICES="ionic_0,ionic_1,ionic_2,ionic_3"

export PREFILL_MODEL_HOST_DIR="/data/models"
export DECODE_MODEL_HOST_DIR="/data/models"
export MODEL_NAME="DeepSeek-R1-0528-MXFP4"

export BARRIER_SYNC_PORT="30025"
export SGLANG_PD_PORT="30026"
export ROUTER_PORT="30027"

# KV-cache transfer backend: "mori" or "mooncake"
export KVTRANSFER_BACKEND="mori"

export IMAGE="lmsysorg/sglang:v0.5.10rc0-rocm700-mi35x"

export ISL=128
export OSL=16
export CONC_LIST="1"

bash "${_IX_ROOT}/run_1p1d_sglang_mi300_mi325x.sh"
