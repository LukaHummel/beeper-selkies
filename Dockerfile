FROM ghcr.io/linuxserver/baseimage-selkies:debianbookworm

# Install minimal deps (no FUSE needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal \
    libgtk-3-0 libxss1 libasound2 libnss3 libgconf-2-4 \
    libappindicator3-1 libdbusmenu-glib4 libdbusmenu-gtk3-4 \
    libgbm1 libxshmfence1 libdrm2 libsecret-1-0 libatspi2.0-0 && \
    rm -rf /var/lib/apt/lists/*
# Environment Variables
ENV NO_GAMEPAD="True" \
    TITLE="Beeper" \
    RESTART_APP="True" \
    SELKIES_UI_TITLE="Beeper" \
    SELKIES_UI_SHOW_LOGO="False" \
    SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE="False"
    
# Download Beeper AppImage
RUN curl -L -o /usr/local/bin/beeper.AppImage https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop && \
    chmod +x /usr/local/bin/beeper.AppImage

# Create Beeper config directories with correct permissions for abc user (UID 1000)
RUN mkdir -p /config/.config/BeeperTexts \
             /config/.config/beeper \
             /config/.local/share/beeper \
             /config/.pki/nssdb && \
    chown -R 1000:1000 /config/.config/BeeperTexts \
                       /config/.config/beeper \
                       /config/.local/share/beeper \
                       /config/.pki/nssdb
# Create launcher (SINGLE LINE - NO HEREDOC ISSUES)
RUN printf '%s\n' \
    '#!/bin/sh' \
    'export APPIMAGE_EXTRACT_AND_RUN=1' \
    'cd /usr/local/bin' \
    'exec ./beeper.AppImage --no-sandbox' \
    > /usr/local/bin/beeper-launch \
 && chmod +x /usr/local/bin/beeper-launch \
 && ln -sf /usr/local/bin/beeper-launch /usr/bin/beeper-launch

RUN printf '%s\n' 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/custom-path.sh

COPY root/ /
