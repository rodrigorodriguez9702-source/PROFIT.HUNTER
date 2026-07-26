# Profit Hunter PWA MVP

This is the mobile-friendly Flutter web/PWA version of Profit Hunter.

Included:
- Dashboard
- Saved Hunts
- Casual Hunter limit of 2 hunts
- Avid Hunter upgrade screen
- Deal Feed with sample listings
- Resale/profit estimates and Hunter Score
- Manual model/SKU fields
- Flip Tracker
- Settings
- PWA manifest + app icons for Add to Home Screen

## Run on Windows
1. Install Flutter.
2. Open a terminal in this folder.
3. Run:
   `flutter create . --platforms=web`
4. Run:
   `flutter pub get`
5. Run:
   `flutter run -d chrome`

## Build for hosting
Run:
`flutter build web`

Upload the contents of `build/web/` to a HTTPS web host.

## iPhone use
After deployment to HTTPS:
1. Open the site in Safari.
2. Tap Share.
3. Tap "Add to Home Screen".
4. Launch Profit Hunter from the new Home Screen icon.

Notes:
- Marketplace results are sample data in this MVP.
- Avid Hunter unlock is local-only in this prototype; real App Store/Stripe billing is not connected yet.
