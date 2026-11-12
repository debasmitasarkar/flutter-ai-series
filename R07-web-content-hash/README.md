# Flutter 3.50: `--web-content-hash` and stale Flutter web deploys

Code for [Your Flutter Web Users Are Still Running Last Week's Build](https://medium.com/p/e97b7daea8f9).

Built and run on **Flutter 3.50.0 stable / Dart 3.14.0**.

- `hash_demo/` - a one-screen app ("Build 1 / the bug" in orange). Change the text and colour to make build 2.
- `deploy_demo/serve.py` - a 30-line static server with two cache policies: `naive` (everything but `index.html` cached for a day) and `hashed` (`index.html` and `flutter_bootstrap.js` revalidate, `*.<8 hex>.*` files immutable for a year).
- `deploy_demo/stage.html` + `deploy.js` - the split-screen recording from the article (Playwright).
- `firebase.json` - Firebase Hosting headers and rewrite, from the [Flutter web FAQ](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-configure-my-cache-headers).
- `repro_missing_index.sh` - the "plain build after a hashed build loses `index.html`" trap from the article.

## Build

```
cd hash_demo
flutter create . --platforms=web   # platform folders are not committed
flutter build web --web-content-hash
```

## Replay the deploy demo

```
mkdir -p work/dep/naive work/dep/hashed
# build hash_demo four times into work/dep/plain_v1, plain_v2 (plain build)
# and hash_v1, hash_v2 (--web-content-hash), changing the text between v1 and v2.
# Run `rm -rf build/web` before every build (see repro_missing_index.sh for why).
python3 deploy_demo/serve.py naive  8081 work/dep/naive  2> work/dep/naive.log &
python3 deploy_demo/serve.py hashed 8082 work/dep/hashed 2> work/dep/hashed.log &
cd deploy_demo && npm i playwright-core && node deploy.js ../work
```

What I saw: after "deploying" build 2 and reloading, the naive server received one request (`/`) and the page still showed build 1. The hashed server received `/`, `/flutter_bootstrap.js` and `/main.dart.276ca6e0.js`, and the page showed build 2.
