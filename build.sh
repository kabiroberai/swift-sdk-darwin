#!/bin/bash

DARWIN_TOOLS_VERSION="2.2.1"

set -e

if [[ ($# -ne 1 && $# -ne 2) || $1 == -h || $1 == --help ]]; then
    echo "Usage: $0 <linux version such as ubuntu22.04> [/path/to/Xcode.app/Contents/Developer]"
    exit 1
fi

linux_version=$1
if [[ $# == 2 ]]; then
    dev_dir="$2"
elif type -p xcode-select &>/dev/null; then
    dev_dir="$(xcode-select -p)"
else
    echo "error: Path to Xcode.app was not supplied; can't infer since we aren't on macOS."
    exit 1
fi

mkdir -p output

echo "Making base..."
bundle="output/darwin.artifactbundle"
rm -rf "$bundle"
cp -a layout "$bundle"

echo "Installing toolset..."
mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux/releases/download/v${DARWIN_TOOLS_VERSION}/darwin-tools-${linux_version}.tar.gz" \
    | tar xzf - -C "$bundle/toolset" --strip-components=2
echo '#!/bin/sh' > "$bundle/toolset/bin/dsymutil"

echo "Installing Developer directories..."
mkdir -p "$bundle/Developer"
rsync -aW --relative \
    "$dev_dir/./"Toolchains/XcodeDefault.xctoolchain/usr/lib/{swift,swift_static,clang} \
    "$dev_dir/./"Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    "$dev_dir/./"Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    "$bundle/Developer/"

echo "Done!"
