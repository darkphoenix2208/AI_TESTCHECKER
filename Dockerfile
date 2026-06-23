# Use a lightweight Python 3.11 base image (matches your render.yaml)
FROM python:3.11-slim

# Install system dependencies
# libgl1 and libglib2.0-0 are required by OpenCV and MediaPipe
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Hugging Face security requirement: Set up a non-root user
RUN useradd -m -u 1000 user
USER user

# Define environmental variables for the user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set the working directory to the backend directory
WORKDIR $HOME/app/backend

# Copy all project files into the container, ensuring the non-root user owns them
# We copy the entire root, but WORKDIR is set to backend
COPY --chown=user . $HOME/app

# Install Python dependencies from backend/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the specific port Hugging Face Spaces expects
EXPOSE 7860

# Environment variables for Flask
ENV FLASK_ENV=production
ENV HOST=0.0.0.0
ENV PORT=7860
# Note: You will need to set MONGODB_URI in the Hugging Face Space settings!

# Start the Flask app using Gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:7860", "--workers", "2", "--timeout", "120"]
