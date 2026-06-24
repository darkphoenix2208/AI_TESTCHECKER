# Use Python 3.11 slim base image
FROM python:3.11-slim

# Install all system dependencies needed by OpenCV (headless and non-headless) and MediaPipe.
# These libs make opencv-contrib-python (non-headless) work fine in this container.
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

# Define environmental variables for the user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set the working directory to the backend directory
WORKDIR $HOME/app/backend

# Copy all project files into the container
COPY --chown=user . $HOME/app

# Install all requirements.
# mediapipe pulls in opencv-contrib-python; ultralytics pulls in opencv-python.
# Both provide cv2.so and conflict with each other. We resolve this below.
RUN pip install --no-cache-dir -r requirements.txt

# Remove plain opencv-python (installed by ultralytics).
# opencv-contrib-python (installed by mediapipe) is a strict superset of opencv-python,
# so ultralytics, YOLO, and all other packages work perfectly with only contrib installed.
# Having BOTH causes a cv2.so file conflict that silently breaks mp.solutions.
RUN pip uninstall -y opencv-python 2>/dev/null || true

# Pin numpy back to 1.26.4 after install.
# opencv-contrib-python can upgrade numpy to 2.x during resolution,
# but ultralytics==8.3.0 requires numpy<2.0.0.
RUN pip install --no-cache-dir "numpy==1.26.4"

# Verify that cv2.face (LBPH recognizer) is available - this is REQUIRED.
# mp.solutions check is informational only: mediapipe 0.10.35 removed the legacy
# solutions attribute; the backend now falls back to Haar cascade automatically.
RUN python -c "\
import cv2; \
assert hasattr(cv2, 'face'), 'FATAL: cv2.face missing - opencv-contrib not installed correctly'; \
print('✓ cv2.face OK -', cv2.face.LBPHFaceRecognizer_create()); \
import mediapipe as mp; \
if hasattr(mp, 'solutions'): \
    print('✓ mp.solutions OK'); \
else: \
    print('⚠️ mp.solutions not available in mediapipe', mp.__version__, '- Haar cascade fallback will be used for face detection'); \
print('Build verification complete')"

# Pre-download YOLO model at build time so it's ready when the server starts
RUN python -c "from ultralytics import YOLO; YOLO('yolov5nu.pt')" || true

# Expose the specific port Hugging Face Spaces expects
EXPOSE 7860

# Environment variables for Flask
ENV FLASK_ENV=production
ENV HOST=0.0.0.0
ENV PORT=7860

# Start the Flask app using Gunicorn with a generous timeout for AI model loading
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "300"]
