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

bundle="output/swift-darwin-${linux_version}.artifactbundle"
rm -rf "$bundle"
cp -a layout "$bundle"

mkdir -p "$bundle/res"
cp -a "$dev_dir/Toolchains/XcodeDefault.xctoolchain/usr/lib/"{swift,swift_static,clang} "$bundle/res/"

mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux/releases/download/v${DARWIN_TOOLS_VERSION}/darwin-tools-${linux_version}.tar.gz" | tar xvzf - -C "$bundle/toolset" --strip-components=2

function add_ver {
    target="$1$2"
    mkdir -p "$bundle/targets/$target"
    sed 's/$TARGET/'$target'/g' templates/toolset-target.json > "$bundle/targets/$target/toolset.json"
    sed 's/$SDK/'$sdk_name'/g' "templates/swift-sdk.json" > "$bundle/targets/$target/swift-sdk.json"
    jq '. * $next' --argjson next "$(sed 's/$TARGET/'"$target"'/g' templates/info-base.json)" < "$bundle/info.json" > "$bundle/info.json.tmp"
    mv "$bundle/info.json"{.tmp,}
}

function add_plat {
    sdk_path="$dev_dir/Platforms/$2.platform/Developer/SDKs/$2.sdk"
    sdk_name="$(basename "$sdk_path")"
    sys="$(jq -r ".SupportedTargets.$1.LLVMTargetTripleSys" < "$sdk_path/SDKSettings.json")"
    mkdir -p "$bundle/sdks"
    cp -a "${sdk_path}" "$bundle/sdks/"
    versions=($(jq -r '.SupportedTargets.'"$1"'.ValidDeploymentTargets | join(" ")' < "$sdk_path/SDKSettings.json"))
    for version in "${versions[@]}"; do
        add_ver $sys $version
        if echo $version | grep -q '^[0-9]*\.0'; then
            major="$(echo $version | grep -o '^[0-9]*')"
            add_ver $sys $major
        fi
    done
}

add_plat iphoneos iPhoneOS
add_plat macosx MacOSX
