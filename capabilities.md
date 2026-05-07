# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Photos library access required (screenshot scanning, browsing, deletion)
- Notifications required (temporary screenshot expiration reminders)
- In-App Purchase required (one-time $4.99 Pro upgrade)
- No iCloud sync mentioned (all data local)
- No HealthKit needed
- No location services needed
- No camera access needed
- No Apple Watch companion

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Photos Library Access | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| User Notifications | ✅ Configured | Info.plist + UNUserNotificationCenter |
| In-App Purchase | ✅ Configured | StoreKit 2 framework |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| In-App Purchase (App Store Connect) | ⏳ Pending | 1. Create app record in App Store Connect 2. Create In-App Purchase product: com.zzoutuo.SnapVault.pro 3. Set price to $4.99 4. Add display name and description 5. Submit for review |

## No Configuration Needed

- iCloud / CloudKit (all data stored locally via SwiftData)
- Push Notifications (local notifications only)
- HealthKit (not applicable)
- Location Services (not applicable)
- Camera (not applicable)
- Apple Watch (not applicable)
- Siri (not applicable)
- Background Modes (using PHPhotoLibraryChangeObserver, no background fetch needed)
- Sign in with Apple (not applicable)

## Required Info.plist Keys

| Key | Value |
|-----|-------|
| NSPhotoLibraryUsageDescription | SnapVault needs access to your photos to scan and organize screenshots. |
| NSPhotoLibraryAddUsageDescription | SnapVault needs permission to manage your screenshot library. |
| UIBackgroundModes | Not required (using PHPhotoLibraryChangeObserver) |

## Verification
- Build succeeded after configuration: ✅
- All entitlements correct: ✅
- Photos permission string present: ✅
- Notification permission handled in code: ✅
