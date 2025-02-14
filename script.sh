#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI/
CHECKPOINTS_DIR=${WORKSPACE}/ComfyUI/models/checkpoints
UPSCALE_MODELS_DIR=${WORKSPACE}/ComfyUI/models/upscale_models
CUSTOM_NODES_DIR=${WORKSPACE}/ComfyUI/custom_nodes
CLIP_VISION_DIR=${WORKSPACE}/ComfyUI/models/clip_vision
INPAINT_DIR=${WORKSPACE}/ComfyUI/models/inpaint
IPADAPTER_DIR=${WORKSPACE}/ComfyUI/models/ipadapter
LORAS_DIR=${WORKSPACE}/ComfyUI/models/loras

cd $COMFYUI_DIR

echo CIVITAI_TOKEN:
echo $CIVITAI_TOKEN

# Uninstall existing packages
pip uninstall -y torch torchvision torchaudio pyaudio

# Install nightly builds of torch, torchvision, and torchaudio with CUDA 12.8 support
pip install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu128
pip install opencv-python

cd $CHECKPOINTS_DIR
wget https://civitai.com/api/download/models/1411338?token=$CIVITAI_TOKEN --content-disposition # Illustrious XL Cyberfix
wget https://civitai.com/api/download/models/1413730?token=$CIVITAI_TOKEN --content-disposition # Animagine XL 4.0 opt-perp cyberfix v2
wget https://civitai.com/api/download/models/1410435?token=$CIVITAI_TOKEN --content-disposition # WAI-NSFW-illustrious-SDXL v11.0
wget https://civitai.com/api/download/models/1404800?token=$CIVITAI_TOKEN --content-disposition # Hesperides v1.0

cd $UPSCALE_MODELS_DIR
wget https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-YandereNeoXL_200k.pth --content-disposition

cd $CUSTOM_NODES_DIR
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git
cd comfyui_controlnet_aux
pip install -r requirements.txt

cd $CUSTOM_NODES_DIR
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git

cd $CLIP_VISION_DIR
wget https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors -O clip-vision_vit-h.safetensors --content-disposition

cd $UPSCALE_MODELS_DIR
wget https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth -O 4x_NMKD-Superscale-SP_178000_G.pth --content-disposition
wget https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors -O OmniSR_X2_DIV2K.safetensors --content-disposition
wget https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors -O OmniSR_X3_DIV2K.safetensors --content-disposition
wget https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors -O OmniSR_X4_DIV2K.safetensors --content-disposition

cd $IPADAPTER_DIR
wget https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors -O ip-adapter_sdxl_vit-h.safetensors --content-disposition

cd $LORAS_DIR
wget https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors -O Hyper-SDXL-8steps-CFG-lora.safetensors --content-disposition

cd $INPAINT_DIR
wget https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth -O fooocus_inpaint_head.pth --content-disposition
wget https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch -O inpaint_v26.fooocus.patch --content-disposition
wget https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors -O MAT_Places512_G_fp16.safetensors --content-disposition

cd $CUSTOM_NODES_DIR
git clone https://github.com/Acly/comfyui-tooling-nodes.git
git clone https://github.com/Acly/comfyui-inpaint-nodes.git

