# See-through Portable

Upload a single anime character illustration to automatically decompose it into fully-inpainted semantic layers with depth ordering, exported as a layered PSD file.

A one-click portable launcher based on [See-through](https://github.com/shitagaki-lab/see-through) (Apache 2.0 License).

**This repository** ([hedula/see-through-portable-macos](https://github.com/hedula/see-through-portable-macos)) is a fork of [iamtie34/see-through-portable](https://github.com/iamtie34/see-through-portable) with a **macOS launcher** (`run.sh`), Metal (MPS) support on Apple Silicon, and cross-platform device handling in code. The upstream Windows flow still uses `run.bat`.

[繁體中文說明](README_ZH.md)

## Features

- Automatically decompose anime character images into up to 23 semantic layers:
  - **Hair**: front hair, back hair
  - **Head**: head, face, nose, mouth
  - **Eyes**: eyewhite, irides, eyelash, eyebrow
  - **Accessories**: headwear, eyewear, earwear, neckwear
  - **Body**: ears, neck
  - **Clothing**: topwear, bottomwear, legwear, footwear, handwear
  - **Other**: tail, wings, objects
- Every layer is fully inpainted, not simply cropped
- Automatic depth ordering for each layer
- Export as PSD file
- Gradio web interface with English / Chinese toggle

## System Requirements

### Windows (upstream-style)

- **OS**: Windows 10 / 11
- **Python**: 3.10 or above (check "Add Python to PATH" during installation)
- **GPU**: NVIDIA GPU with at least 8 GB VRAM
- **NVIDIA Driver**: Latest version recommended
- **Disk Space**: ~20 GB (including model downloads)

### macOS (this fork)

- **OS**: macOS 12.3 or later (Metal / MPS is used on Apple Silicon)
- **Python**: 3.10 or above (`python3` from [python.org](https://www.python.org/downloads/) or Homebrew)
- **Hardware**: Apple Silicon (M1/M2/M3…) strongly recommended — inference runs on **Metal (MPS)** with unified memory. Intel Macs have no MPS; CPU-only is not practical for this workload.
- **Disk Space**: ~20 GB (including model downloads)
- **Note**: **Group Offload** in the UI is only applied on **NVIDIA CUDA** (Windows/Linux). On macOS it is ignored so the diffusers offload path does not run on MPS.

## Usage

### Windows

1. Download zip from [Releases](../../releases) and extract, or clone this repository
2. Double-click `run.bat`
3. First run will automatically create a virtual environment and install all dependencies (~10-20 minutes)
4. Browser will automatically open the Gradio interface
5. Upload an image and click "Start Processing"

### macOS

If you do not yet have Python 3.10+ (the system `python3` is often 3.9 from Xcode), install via Homebrew once:

```bash
cd /path/to/see-through-portable-macos
brew bundle              # installs python@3.12 from Brewfile (needs Homebrew)
make run                 # or ./run.sh
```

Later, start from the project folder with `./run.sh` or `make run`.

**Easier options**

| Method | What it does |
|--------|----------------|
| **Double-click** `See-through.command` | Opens Terminal and runs `run.sh` (if blocked the first time: right-click → **Open**) |
| **`make run`** | Same as `./run.sh`; ensures scripts are executable |
| **Terminal** | `chmod +x run.sh` once, then `./run.sh` |

First run creates `venv/`, installs a Metal-capable PyTorch and dependencies (~10-20 minutes). The browser should open Gradio at `http://127.0.0.1:7860`; upload an image and click **Start Processing**.

If Apple Silicon memory is tight, lower **Resolution** and/or disable “Depth resolution same as layers” and use a smaller depth resolution (e.g. 720).

> [!WARNING]
> The first time you process an image, models will be downloaded automatically (~13 GB). They will not be re-downloaded afterward.

## Manual Model Download

If automatic download is too slow or your network is unstable, you can download models manually.

This project uses two HuggingFace models:

| Model | Size | Link |
|-------|------|------|
| LayerDiff (Layer Decomposition) | ~9.5 GB | [layerdifforg/seethroughv0.0.2_layerdiff3d](https://huggingface.co/layerdifforg/seethroughv0.0.2_layerdiff3d) |
| Marigold (Depth Estimation) | ~3.3 GB | [24yearsold/seethroughv0.0.1_marigold](https://huggingface.co/24yearsold/seethroughv0.0.1_marigold) |

### Using huggingface-cli

**Windows** — run `run.bat` once, then in Command Prompt:

```bat
cd your\path\see-through-portable
venv\Scripts\activate
huggingface-cli download layerdifforg/seethroughv0.0.2_layerdiff3d --cache-dir models/hub
huggingface-cli download 24yearsold/seethroughv0.0.1_marigold --cache-dir models/hub
```

**macOS** — after `./run.sh` has created the venv:

```bash
cd /path/to/see-through-portable-macos
source venv/bin/activate
huggingface-cli download layerdifforg/seethroughv0.0.2_layerdiff3d --cache-dir models/hub
huggingface-cli download 24yearsold/seethroughv0.0.1_marigold --cache-dir models/hub
```


## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Random Seed | 42 | Different seeds produce different decomposition results |
| Resolution | 1280 | Higher = better quality but slower and more VRAM. Image is center-padded to square |
| Inference Steps | 30 | Denoising steps. More = better quality but slower. Not recommended to change |
| Left/Right Split | OFF | Split gloves, eyes, ears, etc. into separate left/right layers |
| Cache Tag Embeddings | ON | Pre-compute text embeddings and unload text encoders, saves ~2 GB VRAM with zero speed penalty |
| Group Offload | OFF | Move model blocks on/off GPU as needed. Drastically reduces VRAM but 2-3x slower |
| Depth Resolution | -1 | -1 = same as layer resolution. Lower values (e.g. 720) save VRAM with slightly reduced depth accuracy |

## VRAM Optimization Guide

**12 GB+ VRAM (e.g. RTX 3060 12G, RTX 4070 and above):**
Default settings are fine. Cache Tag Embeddings is already enabled by default.

**8-12 GB VRAM (e.g. RTX 3060 8G, RTX 4060):**
Try the following in order, from least to most impact on speed:

1. **Cache Tag Embeddings = ON** (already enabled by default) — Saves ~2 GB with zero speed penalty
2. **Lower Depth Resolution** — Uncheck "Depth resolution same as layers", defaults to 720, adjustable. Saves VRAM with slightly reduced depth accuracy
3. **Lower Resolution** — e.g. 1024 instead of 1280, reduces both VRAM and computation time
4. **Group Offload = ON** — Last resort. Drastically reduces VRAM but 2-3x slower

## Output

Output files are located in the `workspace/layerdiff_output/` folder:

- `<image_name>.psd` — Multi-layer PSD file
- `<image_name>/` — Individual layer PNG files

## FAQ

**Q: run.bat closes immediately?**
A: Right-click run.bat > Edit, check that the file encoding is UTF-8 with BOM or ANSI. Or run `run.bat` directly in cmd to see error messages.

**Q: "No NVIDIA GPU with CUDA detected"?** (Windows)
A: Make sure you have the latest NVIDIA driver installed. AMD GPUs are not supported.

**Q: macOS / Apple Silicon — out of memory or very slow?**
A: Use a lower **Resolution**, lower **Depth Resolution**, and keep **Cache Tag Embeddings** on. Unified memory is shared; quit other heavy apps. **Group Offload** is not available on macOS (CUDA-only in this build).

**Q: C++ compiler error during dependency installation?**
A: Install [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/).

**Q: How long does it take to process one image?**
A: Processing time varies greatly depending on GPU performance and image resolution.

## Credits

This project is based on [See-through](https://github.com/shitagaki-lab/see-through) by [shitagaki-lab](https://github.com/shitagaki-lab), licensed under Apache 2.0.

## License

[Apache License 2.0](LICENSE)
