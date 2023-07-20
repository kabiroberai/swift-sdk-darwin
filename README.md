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
2. Run `./build.sh <linux host> [developer dir]`.
    - **linux host**: You can pass any Linux host for which a darwin-tools-linux [release](https://github.com/kabiroberai/darwin-tools-linux/releases) exists. e.g. `ubuntu22.04-aarch64`.
    - **developer dir**: this should be the path to `Xcode.app/Contents/Developer`. On macOS, you can omit this argument to let the script infer it.

Find the output at `output/*.artifactbundle`.

## Installing

Prerequisites:
- Linux
- Swift 5.9 toolchain (<https://swift.org/download>)
- A built copy of `darwin.artifactbundle` (see **Building**)

```
swift experimental-sdk install path/to/darwin.artifactbundle
```

## Usage

```
swift build --experimental-swift-sdk ios
```

## TODO

- [ ] Make it easy to use CI (nb: we avoid distributing pre-packaged toolchains for legal reasons)
