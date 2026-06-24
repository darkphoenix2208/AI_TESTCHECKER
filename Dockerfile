FROM python:3.11-slim

# System libs needed by OpenCV (headless) and MediaPipe
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# FIXED: WORKDIR matches where gunicorn will look for app.py
WORKDIR $HOME/app

COPY --chown=user . $HOME/app

# FIXED: install in strict order to avoid opencv conflict
RUN pip install --no-cache-dir \
    # Step 1: install headless opencv FIRST and lock it
    opencv-python-headless==4.8.1.78 \
    # Step 2: install mediapipe — it will see opencv already satisfied and skip its own
    mediapipe==0.10.18 \
    # Step 3: install ultralytics — same, opencv already satisfied
    ultralytics==8.3.0 \
    # Step 4: pinned torch CPU-only (tiny vs full CUDA build — saves ~2GB)
    torch==2.3.1+cpu torchvision==0.18.1+cpu \
    --extra-index-url https://download.pytorch.org/whl/cpu

# Step 5: everything else
RUN pip install --no-cache-dir \
    Flask==3.1.1 \
    Flask-CORS==6.0.1 \
    numpy==1.26.4 \
    requests==2.31.0 \
    Pillow==10.4.0 \
    pymongo[srv]==4.6.1 \
    dnspython==2.4.2 \
    gunicorn==21.2.0 \
    python-dotenv==1.0.0 \
    certifi>=2024.1.1 \
    psutil \
    pytest==7.4.3 \
    pytest-flask==1.3.0 \
    pytest-cov==4.1.0

# Verify no opencv conflict — this WILL fail the build if broken (good)
RUN python -c "\
import cv2; print('cv2:', cv2.__version__); \
import mediapipe as mp; print('mediapipe:', mp.__version__); \
print('mp.solutions available:', hasattr(mp, 'solutions')); \
from ultralytics import YOLO; print('ultralytics: ok')"

# Pre-download YOLO weights at build time so startup is instant
RUN python -c "from ultralytics import YOLO; YOLO('yolov5nu.pt')" || true

EXPOSE 7860

ENV FLASK_ENV=production \
    HOST=0.0.0.0 \
    PORT=7860

# FIXED: cd into backend subdir if your app.py lives there
CMD ["gunicorn", "backend.app:app", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "300"]