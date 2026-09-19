#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
(cd services/api && vendor/bin/pint --test && vendor/bin/phpstan analyse --no-progress && vendor/bin/phpunit)
(cd apps/collector_app && dart format --output=none --set-exit-if-changed lib test integration_test && flutter analyze && flutter test && flutter build web --debug --dart-define=API_BASE_URL=http://localhost:8000/api/v1/)
