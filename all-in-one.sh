#!/bin/bash
#set -e
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
    "https://github.com/lehych-sol/Zen-Face-Detail"
    "https://github.com/lehych-sol/Camera-Forensic-Realism"
    "https://github.com/lehych-sol/Spectral-latent-enchance-"
    "https://github.com/lehych-sol/advanced-denoiser"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/lehych-sol/geek-nodes"
    "https://github.com/lehych-sol/custom-nodes"
    "https://github.com/PGCRT/CRT-Nodes"
    "https://github.com/Jasonzzt/ComfyUI-CacheDiT"
    "https://github.com/thatboymentor/ofmtechclip"
    "https://github.com/scraed/LanPaint"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/facok/comfyui-meancache-z"
    "https://github.com/teskor-hub/comfyui-teskors-utils"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/ClownsharkBatwing/RES4LYF"
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
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/GACLove/ComfyUI-VFI"
)
 
# ─────────────── FUNCTIONS ───────────────
function provisioning_start() {
    provisioning_get_apt_packages
    provisioning_clone_comfyui
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_get_pip_packages
}
 
function provisioning_clone_comfyui() {
    if [[ ! -d "${COMFYUI_DIR}" ]]; then
        git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
    fi
    cd "${COMFYUI_DIR}"
    git pull
    pip install --no-cache-dir -r requirements.txt
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
            (cd "$path" && git pull --ff-only) || echo "WARN: не удалось обновить ${dir}, пропускаю"
        else
            git clone "$repo" "$path" --recursive
        fi
        if [[ -f "$path/requirements.txt" ]]; then
            pip install --no-cache-dir -r "$path/requirements.txt"
        fi
    done
}
 
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

# ─────────────── СЕРВИСЫ ───────────────
echo "=== Устанавливаем зависимости сервисов ==="
pip install --no-cache-dir fastapi uvicorn requests huggingface_hub aiofiles python-multipart

echo "=== Клонируем сервисы ==="
if [[ ! -d "${WORKSPACE}/services" ]]; then
    git clone https://github.com/lehych-sol/comfy-services.git /tmp/comfy-services
    cp -r /tmp/comfy-services/services "${WORKSPACE}/services"
else
    echo "Сервисы уже установлены, обновляем..."
    git -C /tmp/comfy-services pull --ff-only 2>/dev/null || git clone https://github.com/lehych-sol/comfy-services.git /tmp/comfy-services
    cp -r /tmp/comfy-services/services "${WORKSPACE}/services"
fi

echo "=== Запускаем загрузчик пресетов (порт 8081) ==="
cd "${WORKSPACE}"
uvicorn services.preset_downloader:app --host 0.0.0.0 --port 8081 &

echo "=== Starting ComfyUI ==="
cd "${COMFYUI_DIR}"
python main.py --listen 0.0.0.0 --port 8188
