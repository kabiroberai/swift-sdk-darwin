#!/bin/bash

DARWIN_TOOLS_VERSION="1.0.1"

set -e

if [[ ($# -gt 2) || $1 == -h || $1 == --help ]]; then
    echo "Usage: $0 [/path/to/Xcode.app/Contents/Developer|auto] [x86_64|aarch64|auto]"
    exit 1
fi

dev_dir="${1:-auto}"
if [[ "${dev_dir}" == auto ]]; then
    if type -p xcode-select &>/dev/null; then
        dev_dir="$(xcode-select -p)"
    else
        echo "error: Path to Xcode.app was not supplied; can't infer since we aren't on macOS."
        exit 1
    fi
fi

target_arch="${2:-auto}"
if [[ "${target_arch}" == auto ]]; then
    target_arch="$(arch)"
fi
case "$target_arch" in
    x86_64) ;;
    aarch64) ;;
    arm64) target_arch=aarch64 ;;
    *)
        echo "error: Unrecognized architecture '${target_arch}'. Please specify x86_64 or aarch64."
        exit 1
        ;;
esac

echo "Building for ${target_arch} using Xcode at ${dev_dir}..."

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
grep -o '^    \"current\": \".*\"' versions.json | cut -d'"' -f4 > "$bundle/darwin-version.txt"

echo "Installing toolset..."
mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux-llvm/releases/download/v${DARWIN_TOOLS_VERSION}/toolset-${target_arch}.tar.gz" \
    | tar xzf - -C "$bundle/toolset"

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
mv -f "$root/staging/darwin.artifactbundle.zip.tmp" "$root/output/darwin-linux-${target_arch}.artifactbundle.zip"
rm -rf staging

echo "Done!"
