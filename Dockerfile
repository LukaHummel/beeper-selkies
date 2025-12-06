FROM ghcr.io/linuxserver/baseimage-selkies:debianbookworm

# Install minimal deps (no FUSE needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-3-0 libxss1 libasound2 libnss3 libgconf-2-4 \
    libappindicator3-1 libdbusmenu-glib4 libdbusmenu-gtk3-4 \
    libgbm1 libxshmfence1 libdrm2 libsecret-1-0 libatspi2.0-0 && \
    rm -rf /var/lib/apt/lists/*
# Environment Variables
ENV NO_GAMEPAD="True" \
    TITLE="Beeper" \
    RESTART_APP="True" \
    SELKIES_UI_TITLE="Beeper"
# Download Beeper AppImage
RUN curl -L -o /usr/local/bin/beeper.AppImage https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop && \
    chmod +x /usr/local/bin/beeper.AppImage

# Persist config
RUN mkdir -p /config/beeper/{config,share} && chown -R 1000:1000 /config

USER root
RUN mkdir -p ~/.config ~/.local/share && \
    ln -sf /config/beeper/config ~/.config/beeper && \
    ln -sf /config/beeper/share ~/.local/share/beeper
COPY /root /
