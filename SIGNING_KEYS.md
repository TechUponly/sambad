# Private Samvad — Android Signing Key Reference

> ⚠️ **IMPORTANT:** Never regenerate the keystore file. If lost, you must request an upload key reset from Google Play Console (takes 24-48 hours).

---

## Current Upload Keystore

| Property | Value |
|----------|-------|
| **File** | `app_user/frontend/private-sambad-release.keystore` |
| **Alias** | `private-sambad` |
| **Store Password** | `sambad2025` |
| **Key Password** | `sambad2025` |
| **Created** | Mar 18, 2026 |
| **SHA-1** | `60:23:10:07:F2:3A:DB:A7:33:FC:70:C5:22:32:6F:C9:C9:E6:89:4B` |
| **SHA-256** | `B9:F4:5B:BA:B5:43:8D:CD:5B:0D:52:E5:27:48:C7:20:A6:A0:02:22:2E:AE:95:27:08:A3:83:42:3A:D7:0A:AA` |

## Google Play App Signing Key (Google-managed)

| Property | Value |
|----------|-------|
| **SHA-1** | `79:D9:5B:05:63:0B:14:6C:3E:B1:FF:F3:35:60:8B:66:60:4A:2F:39` |
| **MD5** | `A9:8F:19:E9:86:74:9D:36:F1:80:36:58:94:8A:A7:9A` |

## Upload Key History

| Date | Event | SHA-1 |
|------|-------|-------|
| Feb 2026 | Original upload to Play Store (key now lost) | `FC:AC:C6:AA:7C:2E:06:B4:E7:85:D6:86:38:74:3C:E0:B1:84:DA:65` |
| Mar 18, 2026 | New keystore generated (current) | `60:23:10:07:F2:3A:DB:A7:33:FC:70:C5:22:32:6F:C9:C9:E6:89:4B` |
| Apr 9, 2026 | Upload key reset requested via Play Console | PEM: `samvad-upload-key-2026-04-09.pem` |

## Key Configuration

### key.properties (android/key.properties)
```properties
storePassword=sambad2025
keyPassword=sambad2025
keyAlias=private-sambad
storeFile=../../private-sambad-release.keystore
```

### build.gradle.kts signing config
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]
        keyPassword = keystoreProperties["keyPassword"]
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"]
    }
}
```

## How to Verify Keystore

```bash
# Check keystore fingerprint
keytool -list -v -keystore app_user/frontend/private-sambad-release.keystore \
  -alias private-sambad -storepass sambad2025

# Check AAB signing
keytool -printcert -jarfile path/to/app-release.aab

# Export PEM for key reset
keytool -export -rfc \
  -keystore app_user/frontend/private-sambad-release.keystore \
  -alias private-sambad -storepass sambad2025 \
  -file upload_certificate.pem
```

## Play Console Location
- **App signing page:** Setup → App integrity → App signing
- **Upload key reset:** Same page → "Request upload key reset"
- **Application ID:** `com.shamrai.sambad` (do NOT change)

---

*Last updated: Apr 9, 2026*
