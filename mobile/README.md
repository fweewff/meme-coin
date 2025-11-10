# AI-Tuner Mobile Skeleton

Flutter-based client that orchestrates BLE connectivity to the vehicle, handles ECU binary transfers, and communicates with the AI-Tuner backend.

## Structure

- `lib/core`: shared configuration, services, and models (e.g., BLE manager, logging).
- `lib/features`: feature modules aligned with clean architecture layers (presentation/domain/data).
- `lib/routes`: centralized app routing using `go_router`.
- `lib/dependency_injection`: service locator bootstrap with `get_it`.

## Getting Started

```bash
cd mobile
flutter pub get
flutter run
```

Ensure platform-specific permissions for Bluetooth LE, file storage, and network access are configured in `android/` and `ios/` folders (not yet generated).

## Security TODOs

- Implement secure BLE pairing/bonding and encrypt ECU binary payloads.
- Integrate secure credential storage (e.g., Keychain/Keystore) for auth tokens.
- Perform checksum validation before flashing binaries to the ECU.
