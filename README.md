# swift-sdk-darwin

SDKs for cross-compiling Darwin code on Linux.

## Building

Prerequisites:
- macOS
    - Xcode
- Linux
    - [rsync](https://rsync.samba.org)
    - [unxip](https://github.com/saagarjha/unxip)

Steps:
1. Download and install/extract [Xcode](https://developer.apple.com/download/all/?q=Xcode) 15.0 or higher
    - Use `unxip` to extract Xcode if you're on Linux.
2. Run `./build.sh [developer dir]`.
    - **developer dir**: this should be the path to `Xcode.app/Contents/Developer`. On macOS, you can omit this argument (or pass `auto`) to let the script infer it.

Find the output at `output/darwin-linux-$(arch).artifactbundle`.

## Installing

Prerequisites:
- Swift 5.9 toolchain (<https://swift.org/download>)
- `darwin.artifactbundle` built for your host OS (see **Building**)

```
swift experimental-sdk install output/darwin-linux-$(arch).artifactbundle
```

## Usage

```
swift build --experimental-swift-sdk arm64-apple-ios
```
