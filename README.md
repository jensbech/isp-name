# ISPOrgMenuBarApp

Simple macOS menu bar utility built with SwiftUI that periodically fetches current IP + organization (ISP) information from `ipinfo.io` and shows it in a menu bar popover.

## Features
- Native menu bar extra (macOS 13+)
- Auto-refresh every 60s (adjust in `NetworkMonitor.refreshInterval`)
- Manual refresh button (⌘R alternative: click "Refresh Now")
- Displays Org / IP / Location / Last Updated
- Quits cleanly from the menu
- Uses `LSUIElement` to stay as a menu bar only app (no dock icon)

## Requirements
- macOS 13+
- Swift 5.9 toolchain (Xcode 15 or recent Swift toolchain)

## Build & Run (SwiftPM CLI)
```bash
swift build -c release
open .build/release/ISPOrgMenuBarApp.app
```
(First build will produce an `.app` bundle inside `.build/release` because of resources + Info.plist.)

Alternatively for debug:
```bash
swift build
open .build/debug/ISPOrgMenuBarApp.app
```

## Change Refresh Interval
Edit `refreshInterval` inside `NetworkMonitor` in `main.swift`.

## Packaging
You can codesign ad-hoc:
```bash
codesign --force --sign - .build/release/ISPOrgMenuBarApp.app
```

## Notes
Unauthenticated `ipinfo.io` has a rate limit (typically 1k/day). Add a token by modifying the request URL if needed: `https://ipinfo.io/json?token=YOUR_TOKEN`.
