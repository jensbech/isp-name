# ISPOrgMenuBarApp

Simple macOS menu bar app to show the ISP organization name. Useful for quickly verifying if you are on a VPN connection or not.

## Features

- 🌐 Shows your current ISP organization in the menu bar
- 📍 Displays your IP address and location
- 🔄 Auto-refreshes every 60 seconds
- 🚀 Launch at login support
- 🎯 Spotlight searchable when installed in Applications
- 🖱️ No dock icon - lives purely in the menu bar
- ⌨️ Keyboard shortcut (R) to refresh manually

## Installation

### Download from Releases (Recommended)
1. Download the latest release from [GitHub Releases](https://github.com/jensbech/isp-name/releases)
2. Extract the `.app` bundle and move it to your Applications folder
3. The app will appear in your menu bar - look for the ISP indicator

### Build from Source
```bash
git clone https://github.com/jensbech/isp-name.git
cd isp-name
./scripts/build-app-bundle.sh
```

The built app will be available at `release/1.0.0/ISPOrgMenuBarApp.app`
