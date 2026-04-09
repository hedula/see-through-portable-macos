#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$REPO_DIR/venv"
MARKER="$VENV_DIR/.installed"
PYTHON="$VENV_DIR/bin/python"
PIP="$VENV_DIR/bin/pip"

echo "========================================================================"
echo " See-through: Single-image Layer Decomposition for Anime Characters"
echo "========================================================================"
echo ""

echo "[1/4] Checking Python..."
SYS_PYTHON=""
for cand in python3.12 python3.11 python3.10 python3; do
  if command -v "$cand" >/dev/null 2>&1; then
    SYS_PYTHON="$(command -v "$cand")"
    break
  fi
done
if [[ -z "$SYS_PYTHON" ]]; then
  echo ""
  echo " ERROR: Python 3 not found."
  echo " Install Python 3.10+ from https://www.python.org/downloads/ or: brew install python@3.12"
  echo ""
  exit 1
fi

PY_VER="$("$SYS_PYTHON" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
MAJOR="${PY_VER%%.*}"
MINOR="${PY_VER#*.}"
if [[ "$MAJOR" -lt 3 ]] || { [[ "$MAJOR" -eq 3 ]] && [[ "${MINOR:-0}" -lt 10 ]]; }; then
  echo ""
  echo " ERROR: Python $PY_VER is too old. Please install Python 3.10 or newer."
  echo ""
  exit 1
fi
echo "        Found Python $PY_VER at $SYS_PYTHON"

echo "[2/4] Checking virtual environment..."
if [[ ! -x "$PYTHON" ]]; then
  echo "        Creating virtual environment..."
  "$SYS_PYTHON" -m venv "$VENV_DIR"
  echo "        Virtual environment created."
else
  echo "        Virtual environment found."
fi

echo "[3/4] Checking dependencies..."
if [[ -f "$MARKER" ]]; then
  echo "        Dependencies already installed."
else
  echo ""
  echo " First-time setup: installing dependencies..."
  echo " This may take 10-20 minutes depending on your internet speed."
  echo ""
  echo " Installing PyTorch (Apple Silicon uses Metal / MPS when available)..."
  "$PIP" install --upgrade pip
  "$PIP" install torch torchvision torchaudio
  echo ""
  echo " Installing project dependencies..."
  "$PIP" install -r "$REPO_DIR/requirements-portable.txt"
  echo "installed" > "$MARKER"
  echo ""
  echo " Setup complete!"
  echo ""
fi

echo "[4/4] Checking accelerator..."
export PYTHONPATH="$REPO_DIR/common"
cd "$REPO_DIR"
GPU_INFO="$("$PYTHON" -c "
import torch
from utils.device_utils import get_inference_device
d = get_inference_device()
if d == 'cuda' and torch.cuda.is_available():
    p = torch.cuda.get_device_properties(0)
    print('cuda:', torch.cuda.get_device_name(0), '(VRAM:', round(p.total_memory / 1024**3, 1), 'GB)')
elif d == 'mps':
    print('mps: Apple Metal (unified memory — use lower resolution if you hit memory limits)')
elif d == 'cpu':
    print('cpu: no GPU accelerator')
else:
    print(d)
" 2>/dev/null || echo "unknown")"
echo "        $GPU_INFO"

if echo "$GPU_INFO" | grep -q '^cpu:'; then
  echo ""
  echo " WARNING: No Metal (MPS) or CUDA GPU detected."
  echo " This workload is intended for GPU inference; CPU-only runs are usually impractical."
  read -r -p " Continue anyway? (y/N): " CONTINUE || true
  if [[ ! "${CONTINUE:-}" =~ ^[yY]$ ]]; then
    exit 1
  fi
fi

echo ""
echo "===================================================="
echo " Starting Gradio UI..."
echo " Loading models, please wait..."
echo " (This may take 10-30 seconds on first load)"
echo " Browser will open at http://127.0.0.1:7860"
echo " Press Ctrl+C in this terminal to stop the server."
echo "===================================================="
echo ""

cd "$REPO_DIR"
exec "$PYTHON" app.py
