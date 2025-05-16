FROM ubuntu:22.04

# Install Python and build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    python3-dev \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create and activate virtual environment
RUN python3 -m venv /app/venv

# Install dependencies with a specific spaCy version
RUN . /app/venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir wheel setuptools && \
    pip install --no-cache-dir flask gunicorn numpy pandas requests && \
    pip install --no-cache-dir "spacy<3.9.0,>=3.8.0"

# Download and verify spaCy models
RUN . /app/venv/bin/activate && \
    python -m spacy download xx_sent_ud_sm && \
    python -m spacy download de_core_news_sm && \
    python -c "import spacy; nlp_xx = spacy.load('xx_sent_ud_sm'); nlp_de = spacy.load('de_core_news_sm'); print('Models loaded successfully')"

# Copy application code
COPY . /app/

# Expose the port the app will run on
EXPOSE 8000

# Command to run the application using the venv Python
ENTRYPOINT ["/app/venv/bin/python3", "/app/app.py"]

