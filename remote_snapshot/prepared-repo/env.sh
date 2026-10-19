# 项目根目录
export AUTORESEARCH_ROOT=/data2/home/yingjie/autoresearch

# uv 下载缓存、专用 Python 和项目依赖环境
export UV_CACHE_DIR="$AUTORESEARCH_ROOT/cache/uv"
export UV_PYTHON_INSTALL_DIR="$AUTORESEARCH_ROOT/python"
export UV_PROJECT_ENVIRONMENT="$AUTORESEARCH_ROOT/repo/.venv"

# 常见工具的缓存目录
export XDG_CACHE_HOME="$AUTORESEARCH_ROOT/cache"
export HF_HOME="$AUTORESEARCH_ROOT/cache/huggingface"
export TORCH_HOME="$AUTORESEARCH_ROOT/cache/torch"
export TORCHINDUCTOR_CACHE_DIR="$AUTORESEARCH_ROOT/cache/torchinductor"
export TRITON_CACHE_DIR="$AUTORESEARCH_ROOT/cache/triton"
export CUDA_CACHE_PATH="$AUTORESEARCH_ROOT/cache/cuda"
export MPLCONFIGDIR="$AUTORESEARCH_ROOT/cache/matplotlib"

# 临时文件目录
export TMPDIR="$AUTORESEARCH_ROOT/tmp"