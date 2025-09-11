
# Monetization

Implemented: **One-time lifetime unlock**

## Products
- `premium_lifetime` (non-consumable). Configure in both stores.

## Flows
1. User taps "Go Premium".
2. We query products via `in_app_purchase`.
3. Purchase, then verify:
   - Locally mark `premium=true` after `purchaseStatus == purchased`.
   - Cache receipt in secure storage.
   - If backend exists, POST receipt for server verification.
4. Entitlements:
   - Unlimited pets, export, advanced reports, calendar export.

## Server-side validation (if/when backend exists)
- Apple: verify via App Store Server API, keep signed JWS, match bundle ID and product ID.
- Google: verify via Play Developer API Purchases.products.
- Persist entitlement with user identifier, handle restore.

## A/B testing
- Variant A: paywall after creating 3 items.
- Variant B: paywall after 7 days.
- Track: conversion rate, day-7 retention, LTV.

## Metrics to watch
- Paywall views -> purchase start -> purchase complete
- Churn after paywall
- Feature usage by premium vs free
