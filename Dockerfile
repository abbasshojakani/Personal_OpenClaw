FROM coollabsio/openclaw:2026.2.6

USER root

# Install Xvfb, Chromium, and curl (required for the healthcheck)
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium \
    fonts-liberation \
    libnss3 \
    libgbm1 \
    libasound2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a rock-solid startup script that guarantees logs and execution
RUN echo '#!/bin/bash\n\
echo "--- Starting Virtual Display (Xvfb) ---"\n\
Xvfb :99 -screen 0 1920x1080x24 -ac -nolisten tcp &\n\
export DISPLAY=:99\n\
echo "--- Starting OpenClaw Gateway ---"\n\
exec openclaw gateway start' > /start-headed.sh && chmod +x /start-headed.sh

# Set the custom script as the main process
ENTRYPOINT ["/start-headed.sh"]