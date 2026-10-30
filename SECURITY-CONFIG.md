# Client configuration

`assets/env/.env` is retained locally but is no longer tracked. Copy `.env.example` only if you need this optional local file; current app code does not read it.

The 32-character APP_KEY matches the Kakao native SDK key in `lib/main.dart`, the iOS key and Kakao callback scheme. These are public mobile SDK identifiers, not a Kakao client secret, REST admin key, database password or signing secret. The Naver Maps client ID is also a public app identifier. No secret-driven rotation is indicated by this code alone. Keep bundle/package IDs, signing fingerprints, API scopes and quota restrictions configured in provider consoles.

Do not put server secrets in Flutter assets or compile-time defines: distributed apps can expose them. Public SDK identifiers remain in their existing initialization/platform locations so login and callbacks stay consistent.
