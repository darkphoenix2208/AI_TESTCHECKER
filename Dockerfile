# Use Python 3.11 slim base image
FROM python:3.11-slim

# Install system libraries required by OpenCV and MediaPipe.
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Hugging Face security requirement: Set up a non-root user
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app/backend

COPY --chown=user . $HOME/app

# Install all requirements.
# NOTE: ultralytics pulls in opencv-python and mediapipe pulls in opencv-contrib-python.
# Both provide the same cv2.so file; whichever installs last "wins" the slot on disk.
RUN pip install --no-cache-dir -r requirements.txt

# Diagnostic check (non-fatal): print cv2 and mediapipe status to build logs.
# The app handles missing cv2.face and mp.solutions gracefully at runtime,
# so we don't fail the build here - we just report what we have.
RUN python -c "\
import sys; print('Python:', sys.version); \
try: \
    import cv2; print('cv2 version:', cv2.__version__); \
    if hasattr(cv2, 'face'): print('cv2.face: AVAILABLE'); \
    else: print('cv2.face: MISSING (face recognition will be unavailable)'); \
except Exception as e: print('cv2 import error:', e); \
try: \
    import mediapipe as mp; print('mediapipe version:', mp.__version__); \
    if hasattr(mp, 'solutions'): print('mp.solutions: AVAILABLE'); \
    else: print('mp.solutions: ABSENT (Haar cascade fallback active)'); \
except Exception as e: print('mediapipe import error:', e); \
print('Diagnostic complete')"

# Pre-download YOLO model at build time so it is ready when the server starts.
RUN python -c "from ultralytics import YOLO; YOLO('yolov5nu.pt')" || true

EXPOSE 7860

ENV FLASK_ENV=production \
    HOST=0.0.0.0 \
    PORT=7860

CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "300"]
