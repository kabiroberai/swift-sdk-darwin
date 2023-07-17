# swift-sdk-darwin

SDKs for cross-compiling Darwin code on Linux.

## Building

Prerequisites:
- macOS or Linux
- [jq](https://github.com/jqlang/jq) (`brew install jq` or `apt install jq`)

Steps:
1. Download [Xcode](https://developer.apple.com/download/all/?q=Xcode) 15.0 or higher.
    - If you're on Linux, you can unpack Xcode.xip using [unxip](https://github.com/saagarjha/unxip).
2. Run `./build.sh <linux host> [developer dir]`.
    - **linux host**: You can pass any Linux host for which a darwin-tools-linux [release](https://github.com/kabiroberai/darwin-tools-linux/releases) exists. e.g. `ubuntu22.04-aarch64`.
    - **developer dir**: this should be the path to `Xcode.app/Contents/Developer`. On macOS, you can omit this argument to let the script infer it.

Find the output at `output/*.artifactbundle`.

## Installing

Prerequisites:
- Linux
- Swift 5.9 toolchain (<https://swift.org/download>)

Steps:
1. Build a toolchain as described above.
2. Run `output/*.artifactbundle/install.sh` on your Linux machine.

## Usage

```
swift build --experimental-swift-sdk ios16.0
```

## TODO

- [ ] Make it easy to use CI (nb: we avoid distributing pre-packaged toolchains for legal reasons)
- [ ] Remove installation script once SwiftPM bugs are fixed
