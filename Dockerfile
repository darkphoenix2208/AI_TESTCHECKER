# Use Python 3.11 slim base image
FROM python:3.11-slim

# Install all system dependencies needed by OpenCV and MediaPipe
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

# Step 1: Pin OpenCV headless FIRST before mediapipe/ultralytics pull in conflicting versions
RUN pip install --no-cache-dir opencv-contrib-python-headless==4.10.0.84

# Step 2: Install all other requirements
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Force reinstall headless OpenCV to undo any overrides by mediapipe/ultralytics
RUN pip uninstall -y opencv-python opencv-contrib-python 2>/dev/null || true \
    && pip install --no-cache-dir --force-reinstall opencv-contrib-python-headless==4.10.0.84

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
