#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Starting provisioning script..."

# Activate virtual environment
source /venv/main/bin/activate

# Define directories
COMFYUI_DIR=${WORKSPACE}/ComfyUI
DATA_DIR=/data/ComfyUI
MODELS_DIR=${DATA_DIR}/models
CUSTOM_NODES_DIR=${COMFYUI_DIR}/custom_nodes
EXTRA_MODEL_PATHS_FILENAME=extra_model_paths.yaml

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
DIFFUSION_MODELS_DIR=${MODELS_DIR}/diffusion_models


# Ensure directories exist
mkdir -p "$CHECKPOINTS_DIR" "$UPSCALE_MODELS_DIR" "$CLIP_VISION_DIR" \
         "$INPAINT_DIR" "$IPADAPTER_DIR" "$LORAS_DIR" "$VAE_DIR" "$EMBEDDINGS_DIR" "$TEXT_ENCODERS_DIR" "$DIFFUSION_MODELS_DIR"

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
clone_repo "https://github.com/city96/ComfyUI-GGUF.git" "$CUSTOM_NODES_DIR"
cd ComfyUI-GGUF
pip install --upgrade gguf
cd -
clone_repo "https://github.com/kijai/ComfyUI-KJNodes.git" "$CUSTOM_NODES_DIR"
cd ComfyUI-KJNodes
pip install -r requirements.txt
cd -

# echo "Downloading models..."
# # Download Diffusion Models
# # fetch_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" "$DIFFUSION_MODELS_DIR" "wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"
# # fetch_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" "$DIFFUSION_MODELS_DIR" "wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
# fetch_file "https://huggingface.co/city96/Qwen-Image-gguf/resolve/main/qwen-image-Q8_0.gguf" "$DIFFUSION_MODELS_DIR" "qwen-image-Q8_0.gguf"
# fetch_file "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf" "$DIFFUSION_MODELS_DIR" "Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"
fetch_file "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v0.8.safetensors" "$CHECKPOINTS_DIR" "Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v0.8"
fetch_file "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v0.8.safetensors" "$CHECKPOINTS_DIR" "Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v0.8"

# # Download LORA models
# # fetch_file "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors" "$LORAS_DIR" "Hyper-SDXL-8steps-CFG-lora.safetensors"
# echo "Downloading LORAs..."
# fetch_file "https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/FusionX_LoRa/Wan2.1_I2V_14B_FusionX_LoRA.safetensors" "$LORAS_DIR" "Wan2.1_I2V_14B_FusionX_LoRA.safetensors"
# fetch_file "https://huggingface.co/lightx2v/Wan2.1-I2V-14B-480P-StepDistill-CfgDistill-Lightx2v/resolve/main/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors" "$LORAS_DIR" "Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors"
# fetch_file "https://civitai.com/api/download/models/2086717" "$LORAS_DIR" "instagirl_wan_2.0.safetensors"

# # Download VAE
# echo "Downloading VAEs..."
# # fetch_file "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors" "$VAE_DIR" "ae.safetensors"
# fetch_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" "$VAE_DIR" "wan_2.1_vae.safetensors"
# fetch_file "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" "$VAE_DIR" "qwen_image_vae.safetensors"

# # Download Text Encoders
# echo "Downloading Text Encoders..."
# # fetch_file "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR" "t5xxl_fp8_e4m3fn_scaled.safetensors"
# # fetch_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" "$TEXT_ENCODERS_DIR" "umt5_xxl_fp16.safetensors"
# fetch_file "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" "$TEXT_ENCODERS_DIR" "qwen_2.5_vl_7b_fp8_scaled.safetensors"
# fetch_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR" "umt5_xxl_fp8_e4m3fn_scaled.safetensors"
fetch_file "https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_bf16.safetensors" "$TEXT_ENCODERS_DIR" "nsfw_wan_umt5-xxl_bf16.safetensors"

# echo "Downloading Upscale Models..."
# fetch_file "https://huggingface.co/Phips/4xRealWebPhoto_v4_dat2/resolve/main/4xRealWebPhoto_v4_dat2.safetensors" "$UPSCALE_MODELS_DIR" "4xRealWebPhoto_v4_dat2.safetensors"


sage_at() {
    echo "Compiling SageAttention..."
    cd ${WORKSPACE}
    git clone https://github.com/thu-ml/SageAttention.git
    cd SageAttention
    export EXT_PARALLEL=4
    export NVCC_APPEND_FLAGS="--threads 8"
    export MAX_JOBS=32
    python setup.py install
}

# sage_at

echo "Updating ComfyUI..."
cd $COMFYUI_DIR
git pull
pip install -r requirements.txt

echo "Creating Extra Model Paths YAML file..."

cd $COMFYUI_DIR
cat <<EOF > "$EXTRA_MODEL_PATHS_FILENAME"
comfyui:
  base_path: /data/ComfyUI
  is_default: true
  checkpoints: models/checkpoints/
  clip: models/clip/
  clip_vision: models/clip_vision/
  configs: models/configs/
  controlnet: models/controlnet/
  diffusion_models: |
    models/diffusion_models
    models/unet
  embeddings: models/embeddings/
  loras: models/loras/
  upscale_models: models/upscale_models/
  vae: models/vae/
  text_encoders: models/text_encoders/
EOF


echo "Setup completed successfully!"
