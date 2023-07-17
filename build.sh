#!/bin/bash

set -e

linux_version=ubuntu22.04-aarch64

DARWIN_TOOLS_VERSION="2.2.1"
SUPPORTED_SDKS=(iphoneos macosx)

swift_version="$(swift --version 2>/dev/null | head -1 | cut -f4 -d" ")"
echo "Detected Swift version $swift_version"

rm -rf output
mkdir -p output

bundle="output/swift-${swift_version}-darwin.artifactbundle"
cp -a layout "$bundle"

mkdir -p "$bundle/res"
cp -a "$(dirname "$(xcrun -f swiftc)")/../lib/"{swift,swift_static,clang} "$bundle/res/"

mkdir -p "$bundle/toolset"
curl -#L "https://github.com/kabiroberai/darwin-tools-linux/releases/download/v${DARWIN_TOOLS_VERSION}/darwin-tools-${linux_version}.tar.gz" | tar xvzf - -C "$bundle/toolset" --strip-components=2

function add_ver() {
    target="$1$2"
    mkdir -p "$bundle/targets/$target"
    sed 's/$TARGET/'$target'/g' templates/toolset-target.json > "$bundle/targets/$target/toolset.json"
    sed 's/$SDK/'$sdk_name'/g' "templates/swift-sdk.json" > "$bundle/targets/$target/swift-sdk.json"
    jq '. * $next' --argjson next "$(sed 's/$TARGET/'"$target"'/g' templates/info-base.json)" < "$bundle/info.json" > "$bundle/info.json.tmp"
    mv "$bundle/info.json"{.tmp,}
}

function add_plat() {
    sdk_path="$(readlink -f $(xcrun --show-sdk-path -sdk $1))"
    sdk_name="$(basename "$sdk_path")"
    sys="$(jq -r ".SupportedTargets.$1.LLVMTargetTripleSys" < "$sdk_path/SDKSettings.json")"
    mkdir -p "$bundle/sdks"
    cp -a "${sdk_path}" "$bundle/sdks/"
    versions=($(jq -r '.SupportedTargets.'"$1"'.ValidDeploymentTargets | join(" ")' < "$sdk_path/SDKSettings.json"))
    for version in "${versions[@]}"; do
        add_ver $sys $version
        if echo $version | grep -q '^\d*.0'; then
            major="$(echo $version | grep -o '^\d*')"
            add_ver $sys $major
        fi
    done
}

for sdk in "${SUPPORTED_SDKS[@]}"; do
    add_plat $sdk
done
