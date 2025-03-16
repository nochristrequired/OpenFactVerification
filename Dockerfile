FROM python:3.9-slim

# Install required system packages inside the container
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libmagic-dev \
    tesseract-ocr \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip before installing your Python dependencies
RUN pip install --no-cache-dir --upgrade pip

# Create a working directory in the container
WORKDIR /app

# Copy your entire repo into the container
COPY . /app

# Optionally pull the latest commits if a remote is configured
# (Will only work if /app/.git exists and there's a valid remote.)
# RUN git pull || echo "No Git remote or repository present—skipping pull."

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install the package itself so "python -m factcheck" works
# RUN pip install --no-cache-dir .

# Copy the entrypoint from the repo into a standard location inside the container
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use the custom entrypoint to automatically append --client and --model
ENTRYPOINT ["docker-entrypoint.sh"]
