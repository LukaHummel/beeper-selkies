FROM ghcr.io/linuxserver/baseimage-selkies:debianbookworm

# Install minimal Electron deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-3-0 libxss1 libasound2 libnss3 libgconf-2-4 \
    libappindicator3-1 libdbusmenu-glib4 libdbusmenu-gtk3-4 \
    libgbm1 libxshmfence1 libdrm2 libsecret-1-0 libatspi2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Download + EXTRACT Beeper AppImage
RUN wget -O /tmp/beeper.AppImage https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop && \
    chmod +x /tmp/beeper.AppImage && \
    /tmp/beeper.AppImage --appimage-extract && \
    mv squashfs-root/* /usr/local/bin/beeper/ && \
    rm -rf /tmp/beeper.AppImage squashfs-root && \
    chmod +x /usr/local/bin/beeper/AppRun

# Persist config (symlink home dirs to /config)
RUN mkdir -p /config/beeper/config /config/beeper/share && \
    chown -R 1000:1000 /config

USER root
RUN mkdir -p ~/.config ~/.local/share && \
    ln -sf /config/beeper/config ~/.config/beeper && \
    ln -sf /config/beeper/share ~/.local/share/beeper
USER root

COPY root /
