#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI
cd $COMFYUI_DIR

echo CIVITAI_TOKEN:
echo $CIVITAI_TOKEN

# Uninstall existing packages
pip uninstall -y torch torchvision torchaudio pyaudio

# Install nightly builds of torch, torchvision, and torchaudio with CUDA 12.8 support
pip install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu128

cd models/checkpoints
wget https://civitai.com/api/download/models/1411338?token=$CIVITAI_TOKEN --content-disposition # Illustrious XL Cyberfix
wget https://civitai.com/api/download/models/1413730?token=$CIVITAI_TOKEN --content-disposition # Animagine XL 4.0 opt-perp cyberfix v2
wget https://civitai.com/api/download/models/1410435?token=$CIVITAI_TOKEN --content-disposition # WAI-NSFW-illustrious-SDXL v11.0
wget https://civitai.com/api/download/models/1404800?token=$CIVITAI_TOKEN --content-disposition # Hesperides v1.0

cd $COMFYUI_DIR
cd models/upscale_models
wget https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-YandereNeoXL_200k.pth --content-disposition
