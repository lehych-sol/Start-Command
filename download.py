import os
import subprocess

base = "/workspace/ComfyUI/models"

downloads = [
    ("clip", "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp16.safetensors"),
    ("clip_vision", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"),
    ("vae", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"),
    ("diffusion_models", "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors"),
    ("controlnet", "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_Uni3C_controlnet_fp16.safetensors"),
    ("detection", "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx"),
    ("detection", "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin"),
    ("detection", "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx"),
    ("upscale_models", "https://huggingface.co/arhiteector/loras/resolve/main/wanvideohelper/low.pt"),
    ("upscale_models", "https://huggingface.co/arhiteector/loras/resolve/main/wanvideohelper/005_colorDN_DFWB_s128w8_SwinIR-M_noise15.pth"),
    ("loras", "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"),
    ("loras", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"),
    ("loras", "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors"),
    ("loras", "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"),
    ("loras", "https://huggingface.co/lehychh/Video/resolve/main/BounceHighWan2_2.safetensors"),
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
