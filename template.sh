#!/bin/bash
set -e
source /venv/main/bin/activate
WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"
echo "=== ComfyUI запуск ==="

APT_PACKAGES=(
    git-lfs
)

PIP_PACKAGES=()

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/lehych-sol/custom-nodes-2"
    "https://github.com/lehych-sol/custom-nodes"
    "https://github.com/thatboymentor/ofmtechclip"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/teskor-hub/comfyui-teskors-utils"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/jnxmx/ComfyUI_HuggingFace_Downloader"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/Smirnov75/ComfyUI-mxToolkit"
    "https://github.com/TheLustriVA/ComfyUI-Image-Size-Tools"
    "https://github.com/ZhiHui6/zhihui_nodes_comfyui"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/plugcrypt/CRT-Nodes"
    "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
)

# ─────────────── MODELS ───────────────

CLIP_MODELS=(
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"
)

CKPT_MODELS=(
    "https://huggingface.co/cyberdelia/CyberRealisticPony/resolve/main/CyberRealisticPony_V15.0_FP32.safetensors"
)

MODEL_PATCHES_MODELS=(
    "https://huggingface.co/arhiteector/zimage/resolve/main/Z-Image-Turbo-Fun-Controlnet-Union.safetensors"
)

TEXT_ENCODERS=(
    "https://huggingface.co/UmeAiRT/ComfyUI-Auto_installer/resolve/refs%2Fpr%2F5/models/clip/umt5-xxl-encoder-fp8-e4m3fn-scaled.safetensors"
)

UNET_MODELS=(
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"
)

DIFFUSION_MODELS=(
    "https://huggingface.co/T5B/Z-Image-Turbo-FP8/resolve/main/z-image-turbo-fp8-e4m3fn.safetensors"
)

BBOX_MODELS=(
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/face_yolov8s.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/femaleBodyDetection_yolo26.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/female_breast-v4.2.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/nipples_yolov8s.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/vagina-v4.2.pt"
    "https://huggingface.co/gazsuv/xmode/resolve/main/assdetailer.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/Eyeful_v2-Paired.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/Eyes.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/FacesV1.pt"
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/hand_yolov8s.pt"
    "https://huggingface.co/AunyMoons/loras-pack/resolve/main/foot-yolov8l.pt"
)

SAM_PTH=(
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/sams/sam_vit_b_01ec64.pth"
)

UPSCALER_MODELS=(
    "https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/4xUltrasharp_4xUltrasharpV10.pt"
)

# ─────────────── FUNCTIONS ───────────────
function provisioning_start() {
    provisioning_get_apt_packages
    provisioning_clone_comfyui
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_get_pip_packages
    provisioning_get_files "${COMFYUI_DIR}/models/model_patches" "${MODEL_PATCHES_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/clip" "${CLIP_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODERS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/unet" "${UNET_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/vae" "${VAE_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/checkpoints" "${CKPT_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/controlnet" "${FUN_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/diffusion_models" "${DIFFUSION_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox" "${BBOX_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/sams" "${SAM_PTH[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/upscale_models" "${UPSCALER_MODELS[@]}"

    # ───── Qwen3-VL Prompt Generator ─────
    provisioning_clone_hf_model \
        "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal" \
        "${COMFYUI_DIR}/models/prompt_generator/Qwen3-VL-4B-Instruct-heretic-7refusal"
}

function provisioning_clone_comfyui() {
    if [[ ! -d "${COMFYUI_DIR}" ]]; then
        git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
    fi
    cd "${COMFYUI_DIR}"
}

function provisioning_install_base_reqs() {
    if [[ -f requirements.txt ]]; then
        pip install --no-cache-dir -r requirements.txt
    fi
}

function provisioning_get_apt_packages() {
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        sudo apt-get update
        sudo apt-get install -y "${APT_PACKAGES[@]}"
    fi
}

function provisioning_get_pip_packages() {
    if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
        pip install --no-cache-dir "${PIP_PACKAGES[@]}"
    fi
}

function provisioning_get_nodes() {
    mkdir -p "${COMFYUI_DIR}/custom_nodes"
    cd "${COMFYUI_DIR}/custom_nodes"
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="./${dir}"
        if [[ -d "$path/.git" ]]; then
            (cd "$path" && git pull --ff-only)  echo "WARN: не удалось обновить ${dir}, пропускаю"
        else
            git clone "$repo" "$path" --recursive
        fi
        if [[ -f "$path/requirements.txt" ]]; then
            pip install --no-cache-dir -r "$path/requirements.txt"
        fi
    done
}

function provisioning_get_files() {
    local dir="$1"
    shift
    local files=("$@")
    mkdir -p "$dir"
    for url in "${files[@]}"; do
        local filename
        filename=$(basename "${url%%\?*}")
        if [[ ! -f "$dir/$filename" ]]; then
            wget --content-disposition -P "$dir" "$url"  echo "WARN: не удалось скачать ${url}"
        else
            echo "Файл уже существует: $dir/$filename, пропускаю"
        fi
    done
}

function provisioning_clone_hf_model() {
    local repo_url="$1"
    local target_dir="$2"
    mkdir -p "$(dirname "$target_dir")"
    git lfs install
    if [[ -d "$target_dir/.git" ]]; then
        (cd "$target_dir" && git pull) || echo "WARN: не удалось обновить ${target_dir}"
    else
        git clone "$repo_url" "$target_dir"
    fi
}

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

echo "=== Starting ComfyUI ==="
cd "${COMFYUI_DIR}"
python main.py --listen 0.0.0.0 --port 8188
