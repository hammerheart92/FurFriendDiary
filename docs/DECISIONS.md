
# DECISIONS.md

## State management
- Chosen: Riverpod. Reason: simpler dependency graph, testability, fewer boilerplate classes than Bloc, stronger guarantees than plain Provider.

## Storage
- Hive for speed and schema-lite models; secure storage for premium receipt and tokens.
- Consider sqflite if future relational queries needed.

## Notifications
- flutter_local_notifications + timezone to avoid DST bugs. Tested paths stubbed in integration_test.

## Routing
- go_router for declarative routes and deep link handling.

## Licenses
- Packages selected under MIT/BSD/Apache-compatible licenses only.

## Analytics
- Placeholder for analytics behind feature flag in settings. Recommending Firebase Analytics if allowed, else self-hosted Plausible proxy.

## Ads
- Not implemented in code to avoid SDK weight; strategy documented. Use Google Mobile Ads if chosen later, with paid ad-free toggle.
