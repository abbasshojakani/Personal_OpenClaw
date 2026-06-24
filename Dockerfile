FROM coollabsio/openclaw:2026.2.6

USER root

# Install Xvfb, Chromium, and required dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium \
    fonts-liberation \
    libnss3 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Set the virtual display environment variable
ENV DISPLAY=:99

# Instead of bypassing the app, wrap the official internal entrypoint script!
ENTRYPOINT ["xvfb-run", "-a", "--server-args=-screen 0 1920x1080x24", "/app/scripts/entrypoint.sh"]