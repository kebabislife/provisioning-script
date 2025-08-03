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
TEXT_ENCODERS_DIR=${MODELS_DIR}/text_encoders


# Ensure directories exist
mkdir -p "$CHECKPOINTS_DIR" "$UPSCALE_MODELS_DIR" "$CLIP_VISION_DIR" \
         "$INPAINT_DIR" "$IPADAPTER_DIR" "$LORAS_DIR" "$VAE_DIR" "$EMBEDDINGS_DIR" "$TEXT_ENCODERS_DIR"

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
# clone_repo "https://github.com/Acly/comfyui-tooling-nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/rgthree/rgthree-comfy.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/EllangoK/ComfyUI-post-processing-nodes.git" "$CUSTOM_NODES_DIR"
clone_repo "https://github.com/cubiq/ComfyUI_essentials.git" "$CUSTOM_NODES_DIR"

echo "Downloading models..."
# Download LORA models
# fetch_file "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors" "$LORAS_DIR" "Hyper-SDXL-8steps-CFG-lora.safetensors"

# Download VAE
# fetch_file "https://civitai.com/api/download/models/1373880" "$VAE_DIR"
fetch_file "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors" "$VAE_DIR" "ae.safetensors"

# Download Text Encoders
fetch_file "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR" "t5xxl_fp8_e4m3fn_scaled.safetensors"

echo "Setup completed successfully!"
