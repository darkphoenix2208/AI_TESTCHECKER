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

# Force-reinstall opencv-contrib-python to guarantee cv2.face availability.
#
# Problem: after the install above, either opencv-python or opencv-contrib-python
# may own the cv2.so file on disk. If opencv-python "won", cv2.face won't exist.
#
# Solution: --force-reinstall overwrites whatever cv2.so is present with the
# opencv-contrib-python version (which includes all contrib modules like cv2.face).
# --no-deps avoids touching numpy or any other already-installed package.
# No uninstall step needed — we just overwrite the file directly.
RUN pip install --no-cache-dir --force-reinstall --no-deps "opencv-contrib-python==4.11.0.86"

# Verify cv2.face is accessible (strict - fails build if missing).
# mp.solutions check is informational: mediapipe 0.10.35 removed this attribute;
# the backend automatically uses Haar cascade as a fallback.
RUN python -c "\
import cv2; \
assert hasattr(cv2, 'face'), 'FATAL: cv2.face missing after contrib reinstall'; \
print('cv2 version:', cv2.__version__); \
print('✓ cv2.face OK'); \
import mediapipe as mp; \
print('mediapipe version:', mp.__version__); \
if hasattr(mp, 'solutions'): print('✓ mp.solutions OK'); \
else: print('NOTE: mp.solutions absent - Haar cascade fallback is active'); \
print('Build verification complete')"

# Pre-download YOLO model at build time so it is ready when the server starts.
RUN python -c "from ultralytics import YOLO; YOLO('yolov5nu.pt')" || true

EXPOSE 7860

ENV FLASK_ENV=production \
    HOST=0.0.0.0 \
    PORT=7860

CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "300"]
