# SnapVault - iOS Development Guide

## Executive Summary

SnapVault is a privacy-first, on-device AI screenshot manager for iOS that automatically categorizes, searches, and cleans screenshots. Targeting the US market of heavy screenshot users (shoppers, students, developers, creatives), SnapVault differentiates through 100% local processing (Vision + CoreML), 15-category smart classification, Tinder-style swipe cleaning, and a one-time $4.99 Pro purchase — no subscriptions, no cloud, no ads.

**Key Differentiators**:
- 100% on-device AI (Vision OCR + CoreML) — zero cloud dependency, zero API cost
- 15 smart categories vs. competitors' 5-6
- Temporary screenshot auto-detection (OTP/QR codes) with expiration reminders
- Tinder-style swipe-to-clean interaction with lock protection
- One-time $4.99 buyout vs. competitors' subscription models
- Spotlight system integration for searching screenshot content from home screen

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| SnapSort (4.8, 8928 ratings) | AI categorization, lifetime upgrade option, on-device processing, clean UI | Limited categories (6-7), no OCR search yet, no swipe cleaning, no temp detection | 15 categories, OCR full-text search, swipe clean, OTP/QR auto-detect |
| Captr | Cloud offload, AI descriptions, task reminders, auto-sync | Requires subscription ($129/yr or $1299 lifetime), cloud-dependent (privacy risk), no swipe clean, no temp detection | One-time $4.99, 100% local, swipe clean, temp screenshot management |
| MobileClean | Swipe cleaning, duplicate detection, secret space, compression | General photo cleaner (not screenshot-specific), no AI categorization, no OCR search, subscription required | Screenshot-specific AI, OCR search, 15 categories, one-time price |
| FlyScreen | Text recognition, tags, cross-platform | Limited iOS features, no auto-categorization, no temp detection | Full auto-classification, temp detection, native iOS experience |
| Screenshot Zero | Completely free, simple find-and-delete | No AI, no categorization, no search, very basic | Full AI suite, smart categories, OCR search, swipe clean |

## Apple Design Guidelines Compliance

- **HIG Navigation**: TabView with 3 tabs (Browse, Clean, Search) following iOS tab bar conventions
- **HIG Gestures**: DragGesture with 100pt threshold for swipe cleaning, consistent with system swipe patterns
- **HIG Privacy**: All processing on-device, no data collection, Photos permission with clear purpose explanation
- **HIG Visual Design**: SF Symbols for category icons, system fonts (SF Pro), native color palette
- **HIG Feedback**: Haptic feedback on swipe actions, progress indicators during scan, success confirmations
- **HIG Accessibility**: VoiceOver labels for all interactive elements, Dynamic Type support, high contrast colors
- **HIG Data Protection**: PHAsset-based deletion with user confirmation, no auto-delete without consent
- **App Store Review 5.1.1**: Photos access with clear purpose string, no background tracking
- **App Store Review 2.1**: All AI on-device, no server dependency

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), Photos Framework (PHAsset), Vision Framework (OCR/QR)
- **Data**: SwiftData with @Model macro, no CoreData
- **AI/ML**: Vision Framework (VNRecognizeTextRequest, VNDetectBarcodesRequest), CoreML (ScreenshotClassifier)
- **Search**: Local OCR index + Spotlight Core (CSSearchableIndex)
- **Notifications**: UserNotifications framework for expiration reminders
- **Background**: PHPhotoLibraryChangeObserver for real-time screenshot monitoring
- **Concurrency**: Swift Concurrency (Task, TaskGroup, Actor)

## Module Structure

```
SnapVault/
├── SnapVault/
│   ├── SnapVaultApp.swift
│   ├── Models/
│   │   ├── SnapItem.swift
│   │   ├── SnapCategory.swift
│   │   └── SearchEntry.swift
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift
│   │   ├── Browse/
│   │   │   ├── BrowseView.swift
│   │   │   ├── CategoryGridView.swift
│   │   │   └── ScreenshotDetailView.swift
│   │   ├── Clean/
│   │   │   ├── SwipeCleanView.swift
│   │   │   └── ScreenshotCard.swift
│   │   ├── Search/
│   │   │   └── SearchView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   └── ContactSupportView.swift
│   │   └── Components/
│   │       ├── CategoryBadge.swift
│   │       └── StorageStatCard.swift
│   ├── ViewModels/
│   │   ├── BrowseViewModel.swift
│   │   ├── CleanViewModel.swift
│   │   └── SearchViewModel.swift
│   ├── Services/
│   │   ├── ScreenshotScanner.swift
│   │   ├── ScreenshotMonitor.swift
│   │   ├── OCRService.swift
│   │   ├── ClassificationService.swift
│   │   ├── PhotoLibraryService.swift
│   │   └── NotificationService.swift
│   └── Purchase/
│       └── PurchaseManager.swift
├── Assets.xcassets/
└── Info.plist
```

## Implementation Flow

1. Create SwiftData models (SnapItem, SnapCategory, SearchEntry)
2. Implement PhotoLibraryService (PHAsset fetch, permission handling)
3. Build OnboardingView (welcome + permission request)
4. Implement ScreenshotScanner (Vision OCR + QR detection + CoreML classification)
5. Build BrowseView with category grid and screenshot detail
6. Build SwipeCleanView with Tinder-style card interaction
7. Build SearchView with OCR full-text search and filters
8. Implement ScreenshotMonitor (PHPhotoLibraryChangeObserver)
9. Implement NotificationService (expiration reminders)
10. Build SettingsView with policy links and contact support
11. Implement PurchaseManager (StoreKit 2, one-time purchase)
12. Build main TabView navigation
13. Integrate all modules in SnapVaultApp
14. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**: System blue (#007AFF) primary, orange (#FF9500) for temporary items, red (#FF3B30) for delete, green (#34C759) for keep
- **Typography**: SF Pro Display for headings (34/28/20pt), SF Pro Text for body (17/15/13pt)
- **Layout**: TabView with 3 tabs, card-based UI for clean view, grid layout for browse, max-width 720pt for iPad content
- **Animations**: Swipe delete 0.3s easeOut, card spring 0.4s damping 0.7, category fade+scale 0.25s, search stagger 0.05s per item
- **Dark Mode**: Full support with adaptive colors
- **iPad**: No sidebarAdaptable, content centered with maxWidth 720pt

## Code Generation Rules

- SwiftUI + SwiftData, minimum iOS 17.0
- All AI processing 100% on-device, zero cloud dependency
- Vision Framework for OCR and QR detection, no third-party OCR libraries
- CoreML + CreateML for screenshot classification, no cloud AI API
- Photos Framework for system screenshot album access, no copying images to app sandbox
- Deletion via PHAssetChangeRequest with user confirmation
- PHPhotoLibraryChangeObserver for background monitoring, no polling
- DragGesture with 100pt threshold for swipe actions
- Swift Concurrency (Task, TaskGroup) for batch classification
- @Observable macro, no Combine
- PHImageManager for thumbnail caching, no full-size image loading
- No comments in code, no debug logs, no redundant code

## Build & Deployment Checklist

- [ ] Xcode project configured with bundle ID com.zzoutuo.SnapVault
- [ ] Deployment target set to iOS 17.0
- [ ] Photos permission usage description added
- [ ] Notification permission usage description added
- [ ] App icon generated and added to Asset Catalog
- [ ] StoreKit configuration file for testing IAP
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] No API keys or secrets in source code
- [ ] Push to GitHub repository
- [ ] Policy pages deployed to GitHub Pages
- [ ] App Store Connect metadata prepared (keytext.md)
