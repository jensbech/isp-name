# ISPOrgMenuBarApp

Simple macOS menu bar app to show the ISP organization name. Useful for quickly verifying if you are on a VPN connection or not.

## Installation

### Homebrew (Recommended)
```bash
# Install directly from this repository
brew install jensbech/isp-name/isp-org-menubar-app

# Or add as a tap first, then install
brew tap jensbech/isp-name
brew install isp-org-menubar-app
```

### Manual Installation
1. Download the latest release from [GitHub Releases](https://github.com/jensbech/isp-name/releases)
2. Extract and move to `/usr/local/bin/` or another directory in your PATH
3. Run: `ISPOrgMenuBarApp`

### Build from Source
```bash
git clone https://github.com/jensbech/isp-name.git
cd isp-name
swift build -c release
.build/arm64-apple-macosx/release/ISPOrgMenuBarApp
```
