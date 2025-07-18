#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Starting provisioning script..."

# Activate virtual environment
source /venv/main/bin/activate

# Define directories
COMFYUI_DIR=${WORKSPACE}/ComfyUI
MODELS_DIR=${COMFYUI_DIR}/models
CUSTOM_NODES_DIR=${COMFYUI_DIR}/custom_nodes

# Define subdirectories
CHECKPOINTS_DIR=${MODELS_DIR}/checkpoints
UPSCALE_MODELS_DIR=${MODELS_DIR}/upscale_models
CLIP_VISION_DIR=${MODELS_DIR}/clip_vision
INPAINT_DIR=${MODELS_DIR}/inpaint
IPADAPTER_DIR=${MODELS_DIR}/ipadapter
LORAS_DIR=${MODELS_DIR}/loras
VAE_DIR=${MODELS_DIR}/vae
EMBEDDINGS_DIR=${MODELS_DIR}/embeddings

# Ensure directories exist
mkdir -p "$CHECKPOINTS_DIR" "$UPSCALE_MODELS_DIR" "$CLIP_VISION_DIR" \
         "$INPAINT_DIR" "$IPADAPTER_DIR" "$LORAS_DIR"

# Function to install packages
install_packages() {
    pip uninstall -y torch torchvision torchaudio
    pip install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu128
    pip install opencv-python
}

# Function to download files
fetch_file() {
    local url=$1
    local dest_dir=$2
    local filename=$3
    mkdir -p "$dest_dir"
    cd "$dest_dir"
    if [[ "$url" == *"civitai.com"* ]]; then
        if [[ -z "$filename" ]]; then
            wget "$url?token=$CIVITAI_TOKEN" --content-disposition
        else
            wget "$url?token=$CIVITAI_TOKEN" --content-disposition -O "$filename"
        fi
    else
        if [[ -z "$filename" ]]; then
            wget "$url" --content-disposition
        else
            wget "$url" --content-disposition -O "$filename"
        fi
    fi
}


# Function to clone Git repositories
clone_repo() {
    local repo_url=$1
    local dest_dir=$2
    mkdir -p "$dest_dir"
    cd "$dest_dir"
    git clone "$repo_url" || echo "Repository $repo_url already exists"
    echo "Cloned $repo_url"!
}

# Install necessary packages
# install_packages

# Download model checkpoints from environment variables
echo "Downloading model checkpoints..."
for var in $(printenv | grep '^CHECKPOINT_URL_' | awk -F= '{print $1}'); do
    url=${!var}
    index=$(echo "$var" | awk -F_ '{print $3}')
    filename_var="CHECKPOINT_FILENAME_$index"
    filename=${!filename_var:-$(basename "$url")}
    fetch_file "$url" "$CHECKPOINTS_DIR" "$filename"
    echo "Downloaded $filename"!
done

# Clone custom nodes repositories
echo "Cloning repos..."
clone_repo "https://github.com/Acly/comfyui-tooling-nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/Acly/comfyui-inpaint-nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/Fannovel16/comfyui_controlnet_aux.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/chengzeyi/Comfy-WaveSpeed.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/rgthree/rgthree-comfy.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/WASasquatch/was-node-suite-comfyui.git" "$CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR/was-node-suite-comfyui"
pip install -r requirements.txt
clone_repo "https://github.com/yolain/ComfyUI-Easy-Use.git" "$CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR/ComfyUI-Easy-Use"
pip install -r requirements.txt
clone_repo "https://github.com/jags111/efficiency-nodes-comfyui.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/sipherxyz/comfyui-art-venture.git" "$CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR/comfyui-art-venture"
pip install -r requirements.txt
clone_repo "https://github.com/EllangoK/ComfyUI-post-processing-nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/glifxyz/ComfyUI-GlifNodes.git" "$CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR/ComfyUI-GlifNodes"
pip install -r requirements.txt
clone_repo "https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/KoreTeknology/ComfyUI-Universal-Styler.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/glowcone/comfyui-string-converter.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/MythicalChu/ComfyUI-APG_ImYourCFGNow.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/Koishi-Star/Euler-Smea-Dyn-Sampler.git" "CUSTOM_NODES_DIR"

# Install requirements for controlnet_aux
cd "$CUSTOM_NODES_DIR/comfyui_controlnet_aux" && pip install -r requirements.txt

echo "Downloading models..."
# Download additional models
fetch_file "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors" "$CLIP_VISION_DIR" "clip-vision_vit-h.safetensors"

# Download upscaling models
fetch_file "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-YandereNeoXL_200k.pth" "$UPSCALE_MODELS_DIR" "4x_NMKD-YandereNeoXL_200k.pth"
fetch_file "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth" "$UPSCALE_MODELS_DIR" "4x_NMKD-Superscale-SP_178000_G.pth"
fetch_file "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors" "$UPSCALE_MODELS_DIR" "OmniSR_X2_DIV2K.safetensors"
fetch_file "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors" "$UPSCALE_MODELS_DIR" "OmniSR_X3_DIV2K.safetensors"
fetch_file "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors" "$UPSCALE_MODELS_DIR" "OmniSR_X4_DIV2K.safetensors"

# Download IPAdapter models
fetch_file "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors" "$IPADAPTER_DIR" "ip-adapter_sdxl_vit-h.safetensors"

# Download LORA models
fetch_file "https://civitai.com/api/download/models/1144036" "$LORAS_DIR"
fetch_file "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors" "$LORAS_DIR" "Hyper-SDXL-8steps-CFG-lora.safetensors"
fetch_file "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-lora.safetensors" "$LORAS_DIR" "Hyper-SDXL-8steps-lora.safetensors"

# Download Inpaint models
fetch_file "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth" "$INPAINT_DIR" "fooocus_inpaint_head.pth"
fetch_file "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch" "$INPAINT_DIR" "inpaint_v26.fooocus.patch"
fetch_file "https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors" "$INPAINT_DIR" "MAT_Places512_G_fp16.safetensors"

# Download VAE
fetch_file "https://civitai.com/api/download/models/1373880" "$VAE_DIR"

# Download Embeddings
fetch_file "https://civitai.com/api/download/models/1470451" "$EMBEDDINGS_DIR"
fetch_file "https://civitai.com/api/download/models/1591915" "$EMBEDDINGS_DIR"

cd $COMFYUI_DIR
git pull

echo "Setup completed successfully!"
