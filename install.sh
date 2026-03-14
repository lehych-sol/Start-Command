#!/bin/bash
set -e
 
# ===== STEP 1: Parse Command-Line Arguments =====
for arg in "$@"; do
    case $arg in
        --hf-token=*)
            export HF_TOKEN="${arg#*=}"
            shift
            ;;
        --civitai-token=*)
            export CIVITAI_TOKEN="${arg#*=}"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --hf-token=TOKEN        Set HuggingFace API token"
            echo "  --civitai-token=TOKEN   Set Civitai API token"
            echo "  --help                  Show this help message"
            echo ""
            echo "Example:"
            echo "  bash $0 --hf-token=hf_xxx --civitai-token=abc123"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done
 
if [[ -z "$HF_TOKEN" ]]; then
    echo "ERROR: HuggingFace token is required"
    echo "Please provide it using: --hf-token=YOUR_TOKEN"
    exit 1
fi
 
# ===== STEP 2: Configuration =====
WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR=${WORKSPACE}/ComfyUI
COMFYUI_VERSION="v0.13.0"
 
# ─── Custom Nodes ───
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/lehych-sol/Custom-Nodes-1.0"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/GACLove/ComfyUI-VFI"
    "https://github.com/lehych-sol/Demon-Custom-Nodes"
)
 
# ─── Models ───
LORA_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/7c2bf7cd56b55e483b78e02fd513ec8b774f7643/split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank64_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank128_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank256_bf16.safetensors"
    "https://huggingface.co/Kutches/UncensoredV2/resolve/c8e948623deb288db698255e94f00ef20c1c83ff/Wan2.2%20v3%20-%20T2V%20-%20Insta%20Girls%20-%20LOW%20-%2014B.safetensors"
    "https://huggingface.co/lightx2v/Wan2.2-Distill-Loras/resolve/main/wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step_1022.safetensors"
    "https://huggingface.co/lightx2v/Wan2.2-Distill-Loras/resolve/main/wan2.2_t2v_A14b_high_noise_lora_rank64_lightx2v_4step_1217.safetensors"
    "https://huggingface.co/m33nt0r/DASIWA/resolve/main/WAN-2.2-I2V-BreastPlay-HIGH-v2.safetensors"
    "https://huggingface.co/m33nt0r/DASIWA/resolve/main/wan22_i2v_shake_high_v2.safetensors"
    "https://huggingface.co/chococka/wanloras/resolve/main/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"
    "https://huggingface.co/m33nt0r/lorafan/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-MPS.safetensors"
    "https://huggingface.co/vpakarinen/wan22-vae-lora-clip/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"
)
 
VAE_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/346ea0b6848edd2aa7e34d0444b2b05ebc7bd97a/Wan2_1_VAE_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/a328a632b80d44062fda7df9b6b1a7b2c3a5cf2c/Wan2_1_VAE_bf16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
)
 
TEXT_ENCODERS_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
    "https://huggingface.co/OreX/Models/resolve/main/WAN/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors"
)
 
DIFFUSION_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_animate_14B_bf16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors"
    "https://huggingface.co/m33nt0r/DASIWA/resolve/main/DasiwaWAN22I2V14BLightspeed_synthseductionHighV9.safetensors"
    "https://huggingface.co/m33nt0r/DASIWA/resolve/main/DasiwaWAN22I2V14BLightspeed_synthseductionLowV9.safetensors"
    "https://huggingface.co/diego97martinez/video_baile_stady_dancer/resolve/main/WAN2-1-SteadyDancer-FP8.json"
    "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/SteadyDancer/Wan21_SteadyDancer_fp8_e4m3fn_scaled_KJ.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors"
)
 
CLIP_VISION_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)
 
UPSCALER_MODELS=(
    "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/a86fc6182b4650b4459cb1ddcb0a0d1ec86bf3b0/RealESRGAN_x2.pth"
    "https://raw.githubusercontent.com/gamefurius32-lgtm/upsclane1xskin/main/1xSkinContrast-SuperUltraCompact%20(3).pth"
)
 
DETECTION_MODELS=(
    "https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx"
    "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx"
    "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx"
    "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin"
)
 
# ===== STEP 3: Helper Functions =====
 
function print_header() {
    echo ""
    echo "=============================================="
    echo "  ComfyUI Installation & Model Setup"
    echo "=============================================="
    echo ""
}
 
function print_end() {
    echo ""
    echo "=============================================="
    echo "  Installation Complete!"
    echo "=============================================="
    echo ""
    echo "Starting ComfyUI from: $COMFYUI_DIR"
    echo ""
}
 
function setup_comfyui() {
    echo "Setting up ComfyUI..."
 
    if [[ -d "$COMFYUI_DIR" ]]; then
        echo "ComfyUI directory exists. Updating to $COMFYUI_VERSION..."
        cd "$COMFYUI_DIR"
        git config --global --add safe.directory "$COMFYUI_DIR"
        git fetch --all --tags || echo "Warning: Could not fetch updates"
        git checkout "$COMFYUI_VERSION" 2>/dev/null || echo "Warning: Could not checkout $COMFYUI_VERSION, using current version"
    else
        echo "Cloning ComfyUI..."
        git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
        cd "$COMFYUI_DIR"
        git checkout "$COMFYUI_VERSION" 2>/dev/null || true
    fi
 
    if [[ -f "requirements.txt" ]]; then
        echo "Installing ComfyUI requirements..."
        pip install --no-cache-dir -r requirements.txt
    fi
}
 
function install_custom_nodes() {
    if [[ ${#NODES[@]} -eq 0 ]]; then
        echo "No custom nodes to install."
        return
    fi
 
    echo "Installing ${#NODES[@]} custom node(s)..."
    mkdir -p custom_nodes
 
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="custom_nodes/${dir}"
 
        if [[ -d "$path" ]]; then
            echo "Updating node: $dir"
            (cd "$path" && git pull)
        else
            echo "Cloning node: $dir"
            git clone "$repo" "$path" --recursive
        fi
 
        if [[ -f "$path/requirements.txt" ]]; then
            pip install --no-cache-dir -r "$path/requirements.txt"
        fi
    done
}
 
function download_file() {
    local url_input="$1"
    local download_dir="$2"
    local custom_filename=""
    local download_url=""
 
    if [[ "$url_input" == *"|"* ]]; then
        download_url="${url_input%|*}"
        custom_filename="${url_input#*|}"
        custom_filename="$(echo "$custom_filename" | sed 's/\//_/g')"
    else
        download_url="$url_input"
    fi
 
    # Fix HuggingFace blob URLs
    if [[ $download_url =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co.*\/blob\/ ]]; then
        download_url=$(echo "$download_url" | sed 's|/blob/|/resolve/|')
    fi
 
    mkdir -p "$download_dir"
 
    if [[ -n $HF_TOKEN && $download_url =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co ]]; then
        if [[ -n "$custom_filename" ]]; then
            wget --header="Authorization: Bearer $HF_TOKEN" -nc --show-progress -O "$download_dir/$custom_filename" "$download_url"
        else
            wget --header="Authorization: Bearer $HF_TOKEN" -nc --content-disposition --show-progress -P "$download_dir" "$download_url"
        fi
    elif [[ -n $CIVITAI_TOKEN && $download_url =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com ]]; then
        local civitai_url="$download_url"
        if [[ "$civitai_url" == *"?"* ]]; then
            civitai_url="${civitai_url}&token=$CIVITAI_TOKEN"
        else
            civitai_url="${civitai_url}?token=$CIVITAI_TOKEN"
        fi
        if [[ -n "$custom_filename" ]]; then
            curl -fL -o "$download_dir/$custom_filename" "$civitai_url"
        else
            (cd "$download_dir" && curl -fL -J -O "$civitai_url")
        fi
    else
        if [[ -n "$custom_filename" ]]; then
            wget -nc --show-progress -O "$download_dir/$custom_filename" "$download_url"
        else
            wget -nc --content-disposition --show-progress -P "$download_dir" "$download_url"
        fi
    fi
}
 
function download_models() {
    local dir="$1"
    shift
    local arr=("$@")
 
    if [[ ${#arr[@]} -eq 0 ]]; then
        return
    fi
 
    echo "Downloading ${#arr[@]} model(s) to $dir..."
    for url in "${arr[@]}"; do
        echo "  -> $url"
        download_file "$url" "$dir"
    done
}
 
# ===== STEP 4: Main =====
 
print_header
 
# Activate venv if available
if [[ -f /venv/main/bin/activate ]]; then
    source /venv/main/bin/activate
fi
 
echo "Step 1/4: Setting up ComfyUI..."
setup_comfyui
 
echo ""
echo "Step 2/4: Installing custom nodes..."
install_custom_nodes
 
echo ""
echo "Step 3/4: Downloading models..."
download_models "${COMFYUI_DIR}/models/loras"             "${LORA_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/vae"               "${VAE_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/text_encoders"     "${TEXT_ENCODERS_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/diffusion_models"  "${DIFFUSION_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/clip_vision"       "${CLIP_VISION_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/upscale_models"    "${UPSCALER_MODELS[@]}"
download_models "${COMFYUI_DIR}/models/detection"         "${DETECTION_MODELS[@]}"
 
print_end
 
echo "Step 4/4: Installing Jupyter..."
pip install jupyter notebook

echo "Step 5/5: Launching ComfyUI + Jupyter..."
cd "$COMFYUI_DIR"

# Запускаем ComfyUI в фоне
python main.py --listen 0.0.0.0 --port 8188 &

# Запускаем Jupyter
jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/workspace

# Ждём чтобы контейнер не закрылся
wait
```

---

## Шаг 2 — В темплейте RunPod добавь порт

В поле **"Expose HTTP Ports"** укажи оба порта:
```
8188, 8888
