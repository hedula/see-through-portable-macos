# See-through Portable

上傳一張動漫角色插圖，自動分解為完整修補的語義圖層並依深度排序，匯出為多圖層 PSD 檔案。

基於 [See-through](https://github.com/shitagaki-lab/see-through) 專案（Apache 2.0 授權），製作成一鍵啟動的懶人包。

**本儲存庫**（[hedula/see-through-portable-macos](https://github.com/hedula/see-through-portable-macos)）為 [iamtie34/see-through-portable](https://github.com/iamtie34/see-through-portable) 的分支，新增 **macOS 啟動腳本**（`run.sh`）、Apple Silicon 的 Metal（MPS）支援，以及程式內跨平台裝置選擇。上游 Windows 流程仍使用 `run.bat`。

[English](README.md)

## 功能

- 自動將動漫角色圖片分解為最多 23 個語義圖層：
  - **頭髮**：front hair、back hair
  - **頭部**：head、face、nose、mouth
  - **眼睛**：eyewhite、irides、eyelash、eyebrow
  - **配件**：headwear、eyewear、earwear、neckwear
  - **身體**：ears、neck
  - **服裝**：topwear、bottomwear、legwear、footwear、handwear
  - **其他**：tail、wings、objects
- 每個圖層皆為完整修補（fully-inpainted），不是簡單的裁切
- 自動估計各圖層的深度排序
- 匯出為 PSD 檔案
- Gradio 網頁介面，支援英文 / 中文切換

## 系統需求

### Windows（與上游相同）

- **作業系統**：Windows 10 / 11
- **Python**：3.10 以上（安裝時請勾選「Add Python to PATH」）
- **顯示卡**：NVIDIA GPU，至少 8 GB VRAM
- **NVIDIA 驅動**：建議安裝最新版本
- **硬碟空間**：約 20 GB（含模型下載）

### macOS（本分支）

- **作業系統**：macOS 12.3 以上（Apple Silicon 會使用 Metal / MPS）
- **Python**：3.10 以上（[python.org](https://www.python.org/downloads/) 或 Homebrew 的 `python3`）
- **硬體**：強烈建議 Apple Silicon（M1／M2／M3…）— 推論使用 **Metal（MPS）** 與統一記憶體。Intel Mac 無 MPS，僅 CPU 不適合此工作負載。
- **硬碟空間**：約 20 GB（含模型下載）
- **說明**：介面中的 **Group Offload** 僅在 **NVIDIA CUDA**（Windows／Linux）生效；在 macOS 上會略過，避免在 MPS 上走不支援的 offload 路徑。

## 使用方式

### Windows

1. 從 [Releases](../../releases) 下載 zip 並解壓縮，或 clone 此專案
2. 雙擊 `run.bat`
3. 首次執行會自動建立虛擬環境並安裝所有依賴（約 10-20 分鐘）
4. 瀏覽器會自動開啟 Gradio 介面
5. 上傳圖片，點擊「Start Processing」即可

### macOS

**若尚未安裝 Python 3.10+**（系統自帶的 `python3` 常為 3.9），建議用 Homebrew 一次裝好：

```bash
cd /path/to/see-through-portable-macos
brew bundle              # 依 Brewfile 安裝 python@3.12（需已安裝 Homebrew）
make run                 # 或 ./run.sh
```

之後若要啟動，在專案目錄執行 `./run.sh` 或 `make run` 即可。

**更省事的方式**

| 方式 | 說明 |
|------|------|
| **雙擊** `See-through.command` | 會開終端機並執行 `run.sh`（首次若被 macOS 擋下：右鍵 → **打開**） |
| **`make run`** | 等同 `./run.sh`，並確保腳本可執行 |
| **終端機** | `chmod +x run.sh`（僅第一次）後執行 `./run.sh` |

首次執行會建立 `venv/`、安裝支援 Metal 的 PyTorch 與依賴（約 10-20 分鐘）。瀏覽器應會開啟 Gradio（`http://127.0.0.1:7860`），上傳圖片後點「開始處理」。

若 Apple Silicon 記憶體吃緊，請降低 **解析度**，或取消「深度解析度與圖層相同」並使用較低的深度解析度（例如 720）。

> [!WARNING]
> 首次處理圖片時會自動下載模型（約 13 GB），之後不會重複下載。

## 手動下載模型

如果自動下載速度太慢或網路不穩定，可以手動下載模型檔案。

本專案使用兩個 HuggingFace 模型：

| 模型 | 大小 | 連結 |
|------|------|------|
| LayerDiff（圖層分解） | ~9.5 GB | [layerdifforg/seethroughv0.0.2_layerdiff3d](https://huggingface.co/layerdifforg/seethroughv0.0.2_layerdiff3d) |
| Marigold（深度估計） | ~3.3 GB | [24yearsold/seethroughv0.0.1_marigold](https://huggingface.co/24yearsold/seethroughv0.0.1_marigold) |

### 使用 huggingface-cli

**Windows** — 先執行一次 `run.bat` 建好虛擬環境，再在命令提示字元中：

```bat
cd 你的路徑\see-through-portable
venv\Scripts\activate
huggingface-cli download layerdifforg/seethroughv0.0.2_layerdiff3d --cache-dir models/hub
huggingface-cli download 24yearsold/seethroughv0.0.1_marigold --cache-dir models/hub
```

**macOS** — 在 `./run.sh` 已建立 venv 之後：

```bash
cd /path/to/see-through-portable-macos
source venv/bin/activate
huggingface-cli download layerdifforg/seethroughv0.0.2_layerdiff3d --cache-dir models/hub
huggingface-cli download 24yearsold/seethroughv0.0.1_marigold --cache-dir models/hub
```


## 參數說明

| 參數 | 預設 | 說明 |
|------|------|------|
| Random Seed | 42 | 不同的種子會產生不同的分解結果 |
| Resolution | 1280 | 越高品質越好，但越慢且需要更多 VRAM。圖片會自動填充為正方形 |
| Inference Steps | 30 | 去噪步數，越多品質越好但越慢，不建議更動 |
| Left/Right Split | OFF | 將手套、眼睛、耳朵等部位分成左右兩個圖層 |
| Cache Tag Embeddings | ON | 預先計算文字嵌入並卸載文字編碼器，省約 2 GB VRAM，零速度損失 |
| Group Offload | OFF | 按需移動模型區塊進出 GPU，大幅降低 VRAM 但慢 2-3 倍 |
| Depth Resolution | -1 | -1 同圖層解析度，設較低值如 720 可省 VRAM，品質損失極小 |

## VRAM 優化指南

**12 GB 以上 VRAM（如 RTX 3060 12G、RTX 4070 以上）：**
預設設定即可，Cache Tag Embeddings 已預設開啟。

**8-12 GB VRAM（如 RTX 3060 8G、RTX 4060）：**
依影響程度由小到大，依序嘗試：

1. **Cache Tag Embeddings = ON**（預設已開啟）— 省約 2 GB，零速度損失
2. **降低 Depth Resolution** — 取消勾選「深度解析度與圖層相同」，預設 720，可自行調整，省 VRAM 但深度精度會略降
3. **降低 Resolution** — 例如 1024 取代 1280，同時減少 VRAM 和計算時間
4. **Group Offload = ON** — 最後手段，大幅降低 VRAM 但慢 2-3 倍

## 輸出說明

處理完成後，輸出檔案位於 `workspace/layerdiff_output/` 資料夾：

- `<圖片名稱>.psd` — 多圖層 PSD 檔案
- `<圖片名稱>/` — 各圖層的 PNG 檔案

## 常見問題

**Q: run.bat 一開就關掉了？**
A: 對 run.bat 按右鍵 > 編輯，確認檔案編碼為 UTF-8 with BOM 或 ANSI。或直接在 cmd 中執行 `run.bat` 查看錯誤訊息。

**Q: 出現「No NVIDIA GPU with CUDA detected」？**（Windows）
A: 請確認已安裝最新的 NVIDIA 驅動程式。本工具不支援 AMD 顯卡。

**Q: macOS／Apple Silicon 記憶體不足或很慢？**
A: 請降低**解析度**、降低**深度解析度**，並保持 **Cache Tag Embeddings** 開啟。統一記憶體與系統共用，請關閉其他吃記憶體的程式。**Group Offload** 在 macOS 上無法使用（此建置僅支援 CUDA）。

**Q: 安裝依賴時出現 C++ 編譯器錯誤？**
A: 請安裝 [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)。

**Q: 處理一張圖片需要多久？**
A: 依顯卡效能和圖片解析度不同，處理時間會有很大差異。

## 致謝

本專案基於 [See-through](https://github.com/shitagaki-lab/see-through)，由 [shitagaki-lab](https://github.com/shitagaki-lab) 開發，採用 Apache 2.0 授權。

## 授權

[Apache License 2.0](LICENSE)
