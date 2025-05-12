# swift-sdk-darwin

**DEPRECATED:** This repository has been superseded by [xtool](https://github.com/xtool-org/xtool).

## Building

Prerequisites:
- macOS
    - Xcode
    - [rsync](https://rsync.samba.org)
        - The system version of rsync will suffice on macOS < 15.4. However, 15.4 replaces rsync with openrsync which seems to not fully support `--relative`. If you're on macOS 15.4+, you may need to `brew install rsync`.
- Linux
    - [rsync](https://rsync.samba.org)
    - [unxip](https://github.com/saagarjha/unxip)

Steps:
1. Download and install/extract [Xcode](https://developer.apple.com/download/all/?q=Xcode) 16.0 or higher
    - Use `unxip` to extract Xcode if you're on Linux.
2. Run `./build.sh [developer dir]`.
    - **developer dir**: this should be the path to `Xcode.app/Contents/Developer`. On macOS, you can omit this argument (or pass `auto`) to let the script infer it.

Find the output at `output/darwin-linux-$(arch).artifactbundle`.

## Installing

Prerequisites:
- Swift 6.0 toolchain (<https://swift.org/download>)
- `darwin.artifactbundle` built for your host OS (see **Building**)

```
swift sdk install output/darwin-linux-$(arch).artifactbundle
```

## Usage

```
swift build --swift-sdk arm64-apple-ios
```
