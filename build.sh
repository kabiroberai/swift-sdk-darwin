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

mkdir -p output

echo "Making base..."
bundle="output/darwin.artifactbundle"
rm -rf "$bundle"
cp -a layout "$bundle"

# we need to include the version numbers in the SDK names; ld uses these when emitting LC_BUILD_VERSION.
MacOSX_SDK="$(basename "$dev_dir"/Platforms/MacOSX.platform/Developer/SDKs/MacOSX*.*.sdk)"
iPhoneOS_SDK="$(basename "$dev_dir"/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS*.*.sdk)"
sed 's/$MacOSX_SDK/'"$MacOSX_SDK"'/g; s/$iPhoneOS_SDK/'"$iPhoneOS_SDK"'/g' templates/swift-sdk.json > "$bundle/swift-sdk.json"

echo "Installing toolset..."
mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux/releases/download/v${DARWIN_TOOLS_VERSION}/darwin-tools-${linux_version}.tar.gz" \
    | tar xzf - -C "$bundle/toolset" --strip-components=2

echo "Installing Developer directories..."
mkdir -p "$bundle/Developer"
rsync -aW --relative \
    "$dev_dir/./"Toolchains/XcodeDefault.xctoolchain/usr/lib/{swift,swift_static,clang} \
    "$dev_dir/./"Platforms/iPhoneOS.platform/Developer/SDKs \
    "$dev_dir/./"Platforms/MacOSX.platform/Developer/SDKs \
    --exclude "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/*/prebuilt-modules" \
    "$bundle/Developer/"

echo "Applying patches..."
# patches:
# - OSS toolchain doesn't seem to know about bridgeOS 9. _originallyDefinedIn doesn't like this, triggers this error:
#   https://github.com/swiftlang/swift/blob/7abd8890b5acb5ca111bf5466a1483d2bd3fa1d2/lib/Parse/ParseDecl.cpp#L3503
# - -target-variant appears to trip this assertion:
#   https://github.com/swiftlang/swift/blob/7abd8890b5acb5ca111bf5466a1483d2bd3fa1d2/lib/SILGen/SILGenDecl.cpp#L1774
find "$bundle"/Developer -type f -name '*.swiftinterface' -print0 | xargs -0 -n1 sed "${sed_inplace[@]}" \
    -e '/@_originallyDefinedIn.*bridgeOS/d' \
    -e 's/ -target-variant [a-z0-9.-]*//g'

echo "Done!"
