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
# mediapipe will pull in opencv-contrib-python (non-headless), which is fine because
# the system libs above provide all the display dependencies it needs.
# ultralytics pulls in opencv-python but mediapipe's opencv-contrib-python is installed
# last and overwrites it (contrib is a superset, so cv2.face is available).
RUN pip install --no-cache-dir -r requirements.txt

# Pin numpy back to 1.26.4 after install.
# Some packages (e.g. opencv-contrib-python-headless) upgrade numpy to 2.x during
# dependency resolution, but ultralytics==8.3.0 requires numpy<2.0.0.
RUN pip install --no-cache-dir "numpy==1.26.4"

# Verify that cv2.face (LBPH face recognizer) AND mp.solutions are both available.
# This will FAIL the build loudly if either is broken, catching problems at build time.
RUN python -c "\
import cv2; \
assert hasattr(cv2, 'face'), 'cv2.face missing - opencv-contrib not installed correctly'; \
import mediapipe as mp; \
assert hasattr(mp, 'solutions'), 'mp.solutions missing - mediapipe broken by opencv conflict'; \
print('✓ cv2.face OK'); \
print('✓ mp.solutions OK'); \
print('All proctoring dependencies verified!')"

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
