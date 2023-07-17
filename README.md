# swift-sdk-darwin

SDKs for cross-compiling Darwin code on Linux.

## Building

Prerequisites:
- macOS or Linux
- Xcode 15+
- [jq](https://github.com/jqlang/jq) (`brew install jq` or `apt-get install jq`)

Run `./build.sh <linux host> [developer dir]`.
- linux host: You can pass any Linux host for which a darwin-tools-linux [release](https://github.com/kabiroberai/darwin-tools-linux/releases) exists. e.g. `ubuntu22.04-aarch64`.
- developer dir: this should be a path to `Xcode.app/Contents/Developer`. If you're on macOS and you have Xcode installed, you can let the script infer this.

Find the output at `output/*.artifactbundle`.

## Installing

Prerequisites:
- Linux host
- Swift 5.9 toolchain (<https://swift.org/download>)

Steps:
1. Build a compatible toolchain
2. Run `toolchain.artifactbundle/install.sh` on your Linux machine

## Usage

```
swift build --experimental-swift-sdk ios16.0
```

## TODO

- [ ] Make it easy to use CI (nb: we avoid distributing pre-packaged toolchains bc copyright)
- [ ] Remove installation script once SwiftPM bugs are fixed
