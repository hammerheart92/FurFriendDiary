
# Security & Privacy

- Store secrets in platform keystore/keychain via flutter_secure_storage.
- Request permissions just-in-time (notifications, location, photos).
- Data retention: user controlled, export and delete from Settings.
- GDPR/CCPA:
  - Provide Privacy Policy link in store listings.
  - Let users opt-out of analytics and ads personalization.
  - Honor delete/export requests via in-app action (stub included).

Threats & mitigations:
- Lost device: encourage OS-level biometric lock, app stores minimal PII.
- Backups: Hive boxes are device-local; advise users before cloud backups.
- IAP fraud: validate receipts server-side when backend exists; instructions in docs/monetization.md.
