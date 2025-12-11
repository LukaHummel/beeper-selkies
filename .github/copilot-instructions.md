# GitHub Copilot Instructions for beeper-selkies

## Project Overview

This repository packages the Beeper Desktop messaging application as a Docker container using the LinuxServer.io Selkies base image, which provides a web-accessible desktop environment.

## Architecture

- **Base Image**: `ghcr.io/linuxserver/baseimage-selkies:debianbookworm` - Provides Selkies web streaming infrastructure
- **Desktop Environment**: Openbox - Lightweight window manager optimized for Selkies
- **Application**: Beeper Desktop AppImage - Installed at `/usr/local/bin/beeper.AppImage`
- **Launch Script**: `/usr/local/bin/beeper-launch` - Wrapper script with required environment variables and flags

## Project Structure

```
.
├── Dockerfile                          # Main container build definition
├── .github/
│   └── workflows/
│       └── docker-publish.yml          # CI/CD workflow for building and publishing container
├── root/                               # Files copied to container root (/)
│   └── defaults/
│       ├── autostart                   # Primary application to launch
│       └── menu.xml                    # Openbox right-click menu definition
└── README.md                           # Documentation and configuration options
```

## Key Conventions and Requirements

### Dockerfile Conventions

1. **Base Image Selection**: Always use Debian-based Selkies images (`debianbookworm`) for this project, as Beeper requires specific dependencies not available on Alpine
2. **AppImage Execution**: Beeper AppImage requires:
   - `APPIMAGE_EXTRACT_AND_RUN=1` environment variable (for containerized environments)
   - `--no-sandbox` flag (required for Docker security restrictions)
3. **Configuration Persistence**: Use `/config/beeper/` for persistent data with proper symlinks to `~/.config/beeper` and `~/.local/share/beeper`
4. **File Copying**: Use `COPY root/ /` to copy configuration files from the `root/` directory into the container

### Desktop Environment

1. **Openbox Window Manager**: This project uses the default Openbox window manager that comes with the Selkies base image for optimal performance
2. **Autostart Mechanism**: 
   - Primary application defined in `root/defaults/autostart`
   - Selkies launches the application automatically via the `/defaults/autostart` mechanism
3. **Application Restart**: `RESTART_APP="True"` environment variable enables automatic application restart watchdog

### Selkies Configuration

1. **Environment Variables**: Configure Selkies features via environment variables in the Dockerfile:
   - `TITLE` and `SELKIES_UI_TITLE` - Set to "Beeper"
   - `NO_GAMEPAD="True"` - Disable gamepad support (not needed for messaging app)
   - `SELKIES_UI_SHOW_LOGO="False"` - Hide Selkies logo
   - `SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE="False"` - Hide gaming-specific UI elements
2. **Hardening Variables**: See README.md for `HARDEN_DESKTOP` and `HARDEN_OPENBOX` options for locked-down deployments

### File Locations

- **Application Binary**: `/usr/local/bin/beeper.AppImage`
- **Launch Script**: `/usr/local/bin/beeper-launch` (also symlinked to `/usr/bin/beeper-launch`)
- **Configuration**: `/config/beeper/config` (mounted volume)
- **Data**: `/config/beeper/share` (mounted volume)
- **Autostart File**: `/defaults/autostart` - Primary launch command

## Build and Test Process

### Building the Container

```bash
docker build -t beeper-selkies .
```

### Testing Locally

```bash
docker run --rm -it -p 3001:3001 beeper-selkies
```

Access the web interface at https://localhost:3001

### CI/CD

- **Workflow**: `.github/workflows/docker-publish.yml`
- **Registry**: GitHub Container Registry (ghcr.io)
- **Triggers**: Push to main branch, tags matching `v*.*.*`, and pull requests
- **Image Signing**: Uses cosign for container image signing

## Dependencies

### System Packages (Debian)

- GTK and graphics libraries for Beeper AppImage:
  - `libgtk-3-0`, `libxss1`, `libasound2`, `libnss3`, `libgconf-2-4`
  - `libappindicator3-1`, `libdbusmenu-glib4`, `libdbusmenu-gtk3-4`
  - `libgbm1`, `libxshmfence1`, `libdrm2`, `libsecret-1-0`, `libatspi2.0-0`

### External Resources

- Beeper AppImage downloaded from: `https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop`

## Common Tasks

### Adding New Environment Variables

Add environment variables in the Dockerfile's ENV instruction to configure Selkies or application behavior.

### Modifying Application Launch

Edit `root/defaults/autostart` to change the primary application launch command.

### Updating Desktop Menu

Modify `root/defaults/menu.xml` to add or change right-click menu items (XML format, Openbox syntax).

## Security Considerations

1. **No FUSE Required**: This container does not require FUSE or additional privileges for AppImage execution
2. **AppImage Security**: Uses `APPIMAGE_EXTRACT_AND_RUN=1` to extract and run instead of FUSE mounting
3. **Sandbox Disabled**: Beeper runs with `--no-sandbox` flag (required for Docker compatibility)
4. **Hardening Options**: See README.md for variables like `HARDEN_DESKTOP`, `DISABLE_SUDO`, `DISABLE_TERMINALS`

## Testing Guidelines

When making changes:

1. **Build Test**: Ensure the Docker image builds without errors
2. **Runtime Test**: Start the container and verify:
   - Web interface loads at port 3001
   - Beeper application starts automatically
   - Application is functional and responsive
   - Configuration persists across container restarts
3. **CI Test**: Ensure GitHub Actions workflow completes successfully

## Documentation Standards

- Update README.md when adding new configuration options or environment variables
- Follow existing documentation format and style
- Include examples for new features or configurations
- Document any breaking changes clearly

## Additional Resources

- [LinuxServer.io Selkies Base Images](https://github.com/linuxserver/docker-baseimage-selkies)
- [Selkies Documentation](https://selkies-project.github.io/selkies/)
- [Beeper Desktop](https://www.beeper.com/)
- [XFCE Desktop Environment](https://www.xfce.org/)
