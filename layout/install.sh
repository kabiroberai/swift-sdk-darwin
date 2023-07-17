#!/bin/bash

set -e

cd "$(dirname "$0")"

bundle_name="$(basename "$PWD")"
bundle_path=~/.swiftpm/swift-sdks/"$bundle_name"
sed 's:$BUNDLE:'"$bundle_path"':g' toolset-base.json > toolset.json

swift experimental-sdk remove "$bundle_name" 2>/dev/null || :
swift experimental-sdk install .
