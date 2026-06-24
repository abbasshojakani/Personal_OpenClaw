FROM coollabsio/openclaw:2026.2.6

USER root

# Install Xvfb, Chromium, Python, jq, and common libraries
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium \
    fonts-liberation \
    libnss3 \
    libgbm1 \
    libasound2 \
    curl \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install common Python packages
RUN pip3 install --break-system-packages --no-cache-dir \
    requests beautifulsoup4 pandas numpy lxml pillow python-dotenv \
    || pip3 install --no-cache-dir \
    requests beautifulsoup4 pandas numpy lxml pillow python-dotenv

# Create the startup script
RUN cat > /start-headed.sh << 'EOF'
#!/bin/bash
set -e

echo "--- Starting Virtual Display (Xvfb) ---"
Xvfb :99 -screen 0 1920x1080x24 -ac -nolisten tcp &
export DISPLAY=:99
sleep 2

echo "--- Cleaning up stale Chromium locks ---"
# Kill any leftover Chromium processes and remove lock files from previous runs
pkill -9 -f chromium || true
rm -f /data/.openclaw/browser/openclaw/user-data/SingletonLock
rm -f /data/.openclaw/browser/openclaw/user-data/SingletonSocket
rm -f /data/.openclaw/browser/openclaw/user-data/SingletonCookie
sleep 1

echo "--- Starting Chromium with remote CDP ---"
mkdir -p /data/.openclaw/browser/openclaw/user-data
chromium --no-sandbox --disable-gpu --disable-dev-shm-usage \
  --remote-debugging-port=18800 \
  --remote-debugging-address=0.0.0.0 \
  --user-data-dir=/data/.openclaw/browser/openclaw/user-data \
  --no-first-run --no-default-browser-check \
  --window-size=1920,1080 \
  --disable-features=MediaRouter \
  --disable-component-extensions-with-background-pages \
  --disable-background-networking \
  about:blank &
sleep 3

echo "--- Configuring OpenClaw browser (attachOnly mode) ---"
CONFIG_FILE="/data/.openclaw/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
    jq '.browser.attachOnly = true | .browser.profiles.openclaw.cdpUrl = "http://127.0.0.1:18800" | .browser.profiles.openclaw.color = "#FF4500"' "$CONFIG_FILE" > /tmp/openclaw.json.tmp && mv /tmp/openclaw.json.tmp "$CONFIG_FILE"
else
    mkdir -p /data/.openclaw
    cat > "$CONFIG_FILE" << 'CONFEOF'
{
  "browser": {
    "attachOnly": true,
    "profiles": {
      "openclaw": {
        "cdpUrl": "http://127.0.0.1:18800",
        "color": "#FF4500"
      }
    }
  }
}
CONFEOF
fi

echo "--- Starting OpenClaw Gateway ---"
exec openclaw gateway --bind lan
EOF

RUN chmod +x /start-headed.sh

ENTRYPOINT ["/start-headed.sh"]