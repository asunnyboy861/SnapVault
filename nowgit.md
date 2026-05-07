# SnapVault - NowGit

## Project Overview
- **App Name**: SnapVault
- **Bundle ID**: com.zzoutuo.SnapVault
- **Platform**: iOS 17.0+
- **Language**: Swift 5.9+ / SwiftUI
- **Repository**: https://github.com/asunnyboy861/SnapVault
- **GitHub Pages**: https://asunnyboy861.github.io/SnapVault

## Architecture
- **UI Framework**: SwiftUI with @Observable macro
- **Data Layer**: SwiftData with @Model macro
- **AI/ML**: Vision Framework (OCR + QR detection), rule-based classification
- **Photo Access**: Photos Framework (PHAsset)
- **IAP**: StoreKit 2 (one-time non-consumable)
- **Notifications**: UserNotifications (local only)
- **Search**: Core Spotlight (CSSearchableIndex)

## Project Structure
```
SnapVault/
├── SnapVault/
│   ├── SnapVaultApp.swift          # App entry point
│   ├── ContentView.swift           # Main TabView
│   ├── Models/
│   │   ├── SnapItem.swift          # SwiftData model
│   │   ├── SnapCategory.swift      # 15 categories enum
│   │   └── SearchEntry.swift       # Search index model
│   ├── Views/
│   │   ├── Onboarding/             # Welcome + permissions
│   │   ├── Browse/                 # Category grid + detail
│   │   ├── Clean/                  # Tinder-style swipe
│   │   ├── Search/                 # OCR full-text search
│   │   ├── Settings/               # Settings + contact
│   │   └── Components/             # Reusable components
│   ├── ViewModels/                 # View models
│   ├── Services/                   # Photo, OCR, classification, notifications
│   └── Purchase/                   # StoreKit 2 manager
├── Assets.xcassets/                # App icon + colors
└── Info.plist                      # Permissions
```

## Monetization
- **Model**: Free download + one-time $4.99 Pro IAP
- **Product ID**: com.zzoutuo.SnapVault.pro
- **Type**: Non-Consumable
- **Free Features**: Scan, categorize, OCR search, temp detection, browse
- **Pro Features**: Swipe clean, batch delete, lock, advanced search, Spotlight, share extension, export

## Policy Pages
- **Privacy Policy**: https://asunnyboy861.github.io/SnapVault/privacy
- **Support Page**: https://asunnyboy861.github.io/SnapVault/support

## Build Status
- ✅ Build succeeds on iOS Simulator (arm64)
- ✅ No compiler errors
- ✅ All SwiftData models configured
- ✅ StoreKit 2 IAP integrated
- ✅ Photos permission configured
- ✅ Notification permission configured

## Contact
- **Email**: iocompile67692@gmail.com
- **GitHub**: https://github.com/asunnyboy861

## Deployment Checklist
- [x] Xcode project builds successfully
- [x] App icon generated and configured
- [x] IAP product ID configured
- [x] Policy pages created
- [x] Contact support implemented
- [ ] Push to GitHub repository
- [ ] Deploy policy pages to GitHub Pages
- [ ] Create App Store Connect record
- [ ] Configure IAP in App Store Connect
- [ ] Submit for review
