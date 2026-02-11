# ROCm 7.2 + Ubuntu 24.04 + Python 3.12 + PyTorch 2.8.0 + ComfyUI

FROM rocm/dev-ubuntu-24.04:7.2

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# System dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-pip \
        git \
        ca-certificates \
        wget \
        libssl-dev \
        libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Ensure python3.12 is the default python / pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create and prepare virtual environment
RUN python -m venv /opt/comfyui-venv && \
    /opt/comfyui-venv/bin/pip install --upgrade pip

# Install specific ROCm 7.2 wheels for torch, torchaudio, triton, and torchvision
# Use --no-deps to avoid pip trying to resolve triton to a different version
RUN /opt/comfyui-venv/bin/pip install \
    https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2/torch-2.8.0%2Brocm7.2.0.lw.gitbf943426-cp312-cp312-linux_x86_64.whl \
    https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2/torchaudio-2.8.0%2Brocm7.2.0.git6e1c7fe9-cp312-cp312-linux_x86_64.whl \
    https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2/triton-3.5.1%2Brocm7.2.0.gita272dfa8-cp312-cp312-linux_x86_64.whl \
    https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2/torchvision-0.24.0%2Brocm7.2.0.gitb919bd0c-cp312-cp312-linux_x86_64.whl

# Install common Python-level dependencies that PyTorch and friends rely on
RUN /opt/comfyui-venv/bin/pip install \
    filelock \
    typing-extensions \
    sympy \
    networkx \
    jinja2 \
    fsspec



# Install ComfyUI
RUN git clone https://github.com/Comfy-Org/ComfyUI.git /opt/ComfyUI

WORKDIR /opt/ComfyUI

RUN /opt/comfyui-venv/bin/pip install --upgrade pip && \
    /opt/comfyui-venv/bin/pip install \
        comfyui-frontend-package==1.38.13 \
        comfyui-workflow-templates==0.8.38 \
        comfyui-embedded-docs==0.4.1 \
        torchsde \
        "numpy>=1.25.0" \
        einops \
        "transformers>=4.50.3" \
        "tokenizers>=0.13.3" \
        sentencepiece \
        "safetensors>=0.4.2" \
        "aiohttp>=3.11.8" \
        "yarl>=1.18.0" \
        pyyaml \
        Pillow \
        scipy \
        tqdm \
        psutil \
        alembic \
        SQLAlchemy \
        "av>=14.2.0" \
        "comfy-kitchen>=0.2.7" \
        "comfy-aimdo>=0.1.8" \
        requests \
        "kornia>=0.7.1" \
        spandrel \
        "pydantic~=2.0" \
        "pydantic-settings~=2.0"
        

EXPOSE 8188

ENV PATH="/opt/comfyui-venv/bin:${PATH}"

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
