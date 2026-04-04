import os
import subprocess

base = "/workspace/ComfyUI/models"

downloads = [
    ("text_encoders", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/text_encoders/qwen.safetensors"),
    ("checkpoints", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/checkpoints/SDXLNSFW.safetensors"),
    ("vae", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/vae/variational_encoder_primary.safetensors"),
    ("diffusion_models", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/diffusion_models/zimage.safetensors"),
    ("ultralytics", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/bbox/lips_v1.pt"),
    ("ultralytics", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/bbox/nipple.pt"),
    ("ultralytics", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/bbox/pussyV2.pt"),
    ("upscale_models", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/upscale_models/4x-UltraSharpV2.pth"),
    ("upscale_models", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth"),
    ("upscale_models", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/upscale_models/x1_ITF_SkinDiffDetail_Lite_v1.pth"),
    ("loras", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/loras/DetailedNipples.safetensors"),
    ("loras", "https://huggingface.co/lehychh/Z-ImageTurbo-SDXL-NSFW/resolve/main/loras/dmd2_sdxl_4step_lora_fp16.safetensors"),
]

for folder, url in downloads:
    dest = os.path.join(base, folder)
    os.makedirs(dest, exist_ok=True)
    filename = url.split("/")[-1]
    filepath = os.path.join(dest, filename)
    if os.path.exists(filepath):
        print(f"Уже есть: {filename}")
        continue
    print(f"Скачиваю {filename} -> {folder}/")
    result = subprocess.run(
        ["wget", "-q", "--show-progress", "-O", filepath, url],
        capture_output=False
    )
    if result.returncode == 0:
        print(f"Готово: {filename}")
    else:
        print(f"Ошибка: {filename}")
