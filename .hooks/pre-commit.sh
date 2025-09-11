
#!/usr/bin/env bash
set -e
dart format --set-exit-if-changed .
dart analyze
flutter test
