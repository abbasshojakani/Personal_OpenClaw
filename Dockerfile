FROM coollabsio/openclaw:2026.2.6

USER root

# Install Xvfb, Chromium, and curl
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium \
    fonts-liberation \
    libnss3 \
    libgbm1 \
    libasound2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# The Fix: Add --host 0.0.0.0 to force external network binding
RUN echo '#!/bin/bash\n\
echo "--- Starting Virtual Display (Xvfb) ---"\n\
Xvfb :99 -screen 0 1920x1080x24 -ac -nolisten tcp &\n\
export DISPLAY=:99\n\
echo "--- Starting OpenClaw Gateway ---"\n\
exec openclaw gateway --host 0.0.0.0' > /start-headed.sh && chmod +x /start-headed.sh

ENTRYPOINT ["/start-headed.sh"]