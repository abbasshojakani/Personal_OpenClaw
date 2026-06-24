FROM coollabsio/openclaw:2026.2.6
USER root
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium \
    fonts-liberation \
    libnss3 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*
ENV DISPLAY=:99
ENTRYPOINT ["xvfb-run", "-a", "--server-args=-screen 0 1920x1080x24", "openclaw", "gateway", "start"]