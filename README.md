![Keelhaul Logo](https://raw.githubusercontent.com/thoughtbot/keelhaul-sdk/master/Header.png)

# [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub release](https://img.shields.io/github/release/thoughtbot/keelhaul-sdk.svg)](https://github.com/thoughtbot/keelhaul-sdk/releases) ![Swift 2.1.1](https://img.shields.io/badge/Swift-2.1.1-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X-lightgrey.svg)

An iOS/OSX SDK to communicate with Keelhaul—server-side App Store receipt validation API.

## Installation

### [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

Add the following to your Cartfile:

~~~
github "thoughtbot/Keelhaul"
~~~

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

## How It Works

The Keelhaul SDK communicates via HTTPS with the server, which in turn sends receipt validation requests to Apple and caches the response for future SDK requests. It also keeps track of which device was used to validate the receipt and makes sure that any receipt is used on exactly one device– a feature that Apple's validation erver does not provide.

## Quick Start

~~~swift
import Keelhaul

let keelhaul = Keelhaul.init(token: "YOUR_API_TOKEN")

keelhaul.validateReceipt { receipt, validationError in
  if let error = validationError {
    // Handle invalid receipt with error...
    return
  }

  if let receipt = receipt {
    // Handle valid receipt...
  }
}
~~~

There are several reasons the validation would fail, so handle each accordingly:

~~~swift
public enum KeelhaulError: Int {
  case MalformedRequestJSON
  case MalformedReceiptData
  case UnauthenticSignature
  case WrongSubscriptionPassword
  case AppleServerUnavailable
  case ExpiredSubscription
  case SanboxReceiptEnvMismatch
  case ProductionReceiptEnvMismatch
  case MalformedResponseJSON
  case InsufficientResponseJSON
  case MissingReceipt
  case MissingDeviceHash
  case InvalidHTTPResponse
  case MissingResponseData
  case InvalidResponse
  case InvalidDeveloperAPIKey
  case DeviceMismatch
  case UnknownSDKError
}
~~~

## License

Keelhaul is Copyright (c) 2016 thoughtbot, inc. It is free software, and may be
redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About

![thoughtbot](https://thoughtbot.com/logo.png)

Keelhaul is maintained and funded by thoughtbot, inc.

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software! See [our other projects][community] or look at
our product [case studies] and [hire us][hire] to help build your iOS app.

[community]: https://thoughtbot.com/community?utm_source=github
[case studies]: https://thoughtbot.com/ios?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
