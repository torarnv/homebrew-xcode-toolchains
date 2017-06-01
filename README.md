# Homebrew Xcode toolchains

Extensions to common Homebrew formulas to provide matching Xcode toolchains

## Installation

```
brew install torarnv/xcode-toolchains/ccache
```

or

```
brew tap torarnv/xcode-toolchains
brew tap-pin torarnv/xcode-toolchains
brew install ccache
```

## Usage

Choose the `ccache` toolchain in Xcode's preferences:

![screenshot](/screenshot.png?raw=true)

or `export TOOLCHAINS=ccache` when building on the command line.