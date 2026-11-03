# Shahed Merchant (شهد للتجار)

The partners portal (`bnpl-vender`) as a phone app, built in the customer app's design
(`forntendUser`). It uses the same backend and endpoints as the portal; the portal itself
is unchanged.

| Tab | Covers (portal page) |
| --- | --- |
| الرئيسية | Dashboard: KPIs, six-month sales chart, quick actions, settlement request |
| البيع | POS: product grid, cart, manual discount, send to customer phone (OTP) or QR, live approval |
| المنتجات | Products: list, add, edit, delete, image upload |
| المبيعات | Sales operations and transactions, with receipt sharing |
| حسابي | Final profits, store settings, API credentials, language, sign out |

Sign-in, sign-up and store setup work as on the portal. Arabic and English, RTL by default.

## Run

```bash
flutter pub get
flutter run
```

The app talks to `https://api.shahedapp.com/api/v1` by default. To point it at another
backend:

```bash
flutter run --dart-define=API_URL=http://localhost:3000/api/v1
```
