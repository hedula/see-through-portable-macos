"""Pick inference device and dtype for CUDA / MPS / CPU."""

import torch


def get_inference_device() -> str:
    if torch.cuda.is_available():
        return "cuda"
    if hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
        return "mps"
    return "cpu"


def inference_dtype(device: str) -> torch.dtype:
    if device == "cuda":
        return torch.bfloat16
    if device == "mps":
        # MPS: float16 is widely supported for diffusion workloads; bf16 is uneven.
        return torch.float16
    return torch.float32


def empty_accelerator_cache() -> None:
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
        torch.mps.empty_cache()
