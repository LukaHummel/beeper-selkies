FROM ghcr.io/linuxserver/baseimage-selkies:debianbookworm

# Install dependencies (Electron/GTK libs for Beeper)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates wget libgtk-3-0 libnss3 libasound2 libxss1 libxtst6 \
        libappindicator3-1 libsecret-1-0 libgbm1 libxshmfence1 && \
    rm -rf /var/lib/apt/lists/*

# Download Beeper AppImage (replace with current URL from beeper.com/download)
RUN wget -O /usr/local/bin/beeper.AppImage https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop && \
    chmod +x /usr/local/bin/beeper.AppImage

# Create persistent dirs and symlinks (runs as PUID/PGID user)
RUN mkdir -p /config/beeper/config /config/beeper/share && \
    chown -R 1000:1000 /config  # Matches default PUID/PGID

# Symlink Beeper data to persistent storage
USER abc  # Default Selkies user
RUN mkdir -p ~/.config ~/.local/share && \
    mv ~/.config/beeper /config/beeper/config 2>/dev/null || true && \
    mv ~/.local/share/beeper /config/beeper/share 2>/dev/null || true && \
    ln -sf /config/beeper/config ~/.config/beeper && \
    ln -sf /config/beeper/share ~/.local/share/beeper
USER root

COPY root /
