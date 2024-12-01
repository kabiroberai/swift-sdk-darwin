#!/bin/bash

DARWIN_TOOLS_VERSION="2.4.0"

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

if [[ "$(uname -s)" == Darwin ]]; then
    sed_inplace=(-i '')
else
    sed_inplace=(-i)
fi

cd "$(dirname "$0")"
root="$PWD"

rm -rf staging
mkdir -p staging output

echo "Making base..."
bundle="staging/darwin.artifactbundle"
rm -rf "$bundle"
cp -a layout "$bundle"

# we need to include the version numbers in the SDK names; ld uses these when emitting LC_BUILD_VERSION.
MacOSX_SDK="$(basename "$dev_dir"/Platforms/MacOSX.platform/Developer/SDKs/MacOSX*.*.sdk)"
iPhoneOS_SDK="$(basename "$dev_dir"/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS*.*.sdk)"
sed 's/$MacOSX_SDK/'"$MacOSX_SDK"'/g; s/$iPhoneOS_SDK/'"$iPhoneOS_SDK"'/g' templates/swift-sdk.json > "$bundle/swift-sdk.json"

echo "Installing toolset..."
mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux/releases/download/v${DARWIN_TOOLS_VERSION}/darwin-tools-${linux_version}.tar.gz" \
    | tar xzf - -C "$bundle/toolset" --strip-components=2 linux/iphone/bin/{dsymutil,libtool}

echo "Installing Developer directories..."
mkdir -p "$bundle/Developer"
rsync -aW --relative \
    "$dev_dir/./"Toolchains/XcodeDefault.xctoolchain/usr/lib/{swift,swift_static,clang} \
    "$dev_dir/./"Platforms/iPhoneOS.platform/Developer/SDKs \
    "$dev_dir/./"Platforms/MacOSX.platform/Developer/SDKs \
    --exclude "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/*/prebuilt-modules" \
    "$bundle/Developer/"

echo "Packaging..."
# We need to zip-then-move to avoid appending to an existing zip file.
(cd "$(dirname "$bundle")" && zip -yqr "$root/staging/darwin.artifactbundle.zip.tmp" "$(basename "$bundle")")
mv -f "$root/staging/darwin.artifactbundle.zip.tmp" "$root/output/darwin-${linux_version}.artifactbundle.zip"
rm -rf staging

echo "Done!"
