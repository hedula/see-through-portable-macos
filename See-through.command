#!/bin/bash
# Double-click in Finder to open Terminal and start the app (macOS).
cd "$(dirname "$0")" || exit 1
chmod +x run.sh 2>/dev/null || true
exec ./run.sh
