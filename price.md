# Pricing Configuration

## Monetization Model: Free Download + One-Time IAP

- **Price**: Free download with core features
- **IAP**: One-time purchase for Pro features ($4.99)
- **Subscription**: None (deliberately no subscription)
- **Ads**: None

## Free Tier Features

| Feature | Included |
|---------|----------|
| Auto-scan all screenshots | ✅ |
| AI smart categorization (15 categories) | ✅ |
| OCR text search | ✅ |
| Temporary screenshot detection (OTP/QR) | ✅ |
| Temporary screenshot expiration reminders | ✅ |
| Screenshot browsing and preview | ✅ |
| Storage space statistics | ✅ |
| Dark mode | ✅ |

## Pro Tier — $4.99 One-Time Purchase

| Feature | Included |
|---------|----------|
| Tinder-style swipe cleaning | ✅ |
| Batch delete and space freeing | ✅ |
| Lock protection (prevent accidental deletion) | ✅ |
| Advanced search (amount/link/tag filters) | ✅ |
| Spotlight system integration | ✅ |
| Share Extension (save from any app) | ✅ |
| Custom classification rules | ✅ |
| Export screenshot data (CSV) | ✅ |
| Permanent free updates | ✅ |

## In-App Purchase Configuration

### Product Details
- **Reference Name**: SnapVault Pro
- **Product ID**: `com.zzoutuo.SnapVault.pro`
- **Type**: Non-Consumable (one-time purchase)
- **Price**: $4.99 (Tier 5)
- **Display Name**: SnapVault Pro (EN-US)
- **Description**: Unlock all Pro features forever (max 55 chars)

## App Store Connect Pricing
- **Price Tier**: Free (base app)
- **IAP Tier**: Tier 5 ($4.99)

## Policy Pages Required
- Support Page: ✅
- Privacy Policy: ✅
- Terms of Use: ❌ (Not needed for non-subscription apps with one-time IAP)

## Competitive Pricing Justification

| Competitor | Price Model | Price |
|------------|-------------|-------|
| SnapSort | Lifetime upgrade | $9.99 |
| Captr | Subscription | $129/yr or $1,299 lifetime |
| MobileClean | Subscription | Various |
| Screenshot Zero | Free | $0 (limited) |
| **SnapVault** | **One-time IAP** | **$4.99** |

**Why $4.99 one-time?**
1. Zero API cost (all AI on-device) = sustainable at one-time price
2. "$4.99 once, forever" is the strongest marketing message
3. 50% cheaper than SnapSort's $9.99 lifetime
4. No subscription fatigue for users
5. Screenshot management is a "sometimes important" tool — users prefer one-time over recurring

## Apple IAP Compliance Checklist
- [x] Non-consumable product type selected
- [x] Restore purchases functionality to be implemented
- [x] No dark patterns in paywall
- [x] Clear feature differentiation between free and pro
- [x] No auto-renewal terms needed (non-subscription)
