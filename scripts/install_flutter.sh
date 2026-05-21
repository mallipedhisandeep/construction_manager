#!/bin/bash
set -e
git config --global --add safe.directory /vercel/path0
git config --global --add safe.directory /opt/flutter
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.44.0-stable.tar.xz | tar -xJ -C /opt
export PATH=$PATH:/opt/flutter/bin
flutter pub get
