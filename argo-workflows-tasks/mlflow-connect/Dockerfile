FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Create non-root user 'app'
RUN useradd --create-home --shell /bin/bash app

# Switch to the non-root user for all subsequent steps
USER app
WORKDIR /home/app

# Ensure the user's local bin is on PATH (pip --user installs here)
ENV PATH="/home/app/.local/bin:${PATH}"

# Install mlflow into the user site-packages (no virtualenv)
RUN pip install --no-cache-dir --upgrade --user pip \
    && pip install --no-cache-dir --user mlflow

# Add the application code (owned by 'app')
COPY --chown=app:app list_experiments.py .

# Run the script when the container starts
ENTRYPOINT ["python", "list_experiments.py"]
