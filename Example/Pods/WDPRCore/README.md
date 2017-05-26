# WDPRCore

[![Build Status](http://mobile-ci.wdpro.disney.com/buildStatus/icon?job=iOS/WDPRCore_master)](http://mobile-ci.wdpro.disney.com/job/iOS/view/PODs/job/WDPRCore_master/)

##Table of Contents

* [About](#About)
* [Usage](#Usage)
* [Requirements](#Requirements)
* [Installation](#Installation)
* [Subspecs](#Subspecs)
* [Code Contribution](#Code-Contribution)
* [Updating/Modifiying](#Updating/Modifiying)
* [Wiki](#Wiki)
* [Who We Are](#Who-We-Are)

## About

WDPRCore is designed to be the bottom layer of a WDPR application.

It contains:

* WDPRFoundation - NSFoundation Categories
* WDPRUIKit - UIKit Categories
* NSFoundation Helper classes - Classes that only rely on NSFoundation that are useful for any application.
    * WDPRQueueManager
    * and others...
* UIKit Helper classes - Classes that only rely on UIKit that are useful for most application.
    * WDPRTableDataDelegate (formerly MdxTableDataDelegate)
    * WDPRTableController
    * WDPRWebViewController
    * and many others...
* WDPRLogging - Logging facade for CocoaLumberjack.

WDPRCore depends on:
* CocoaLumberjack 2.0.0
* SDWebImage 3.7.x

## Requirements

* XCode 7.x

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

WDPRCore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WDPRCore"
```

### Subspecs

To use just WDPRFoundation, it is available as a subspec. This does not include the WDPRUIKit items.
```ruby
pod "WDPRCore/WDPRFoundation"
```

To use just WDPRLogging, it is available as a subspec. This does not include the WDPRUIKit or WDPRLogging items.
```ruby
pod "WDPRCore/WDPRLogging"
```

To use just WDPRLocalization, it is available as a subspec. This does not include the WDPRUIKit or WDPRLogging items.
```ruby
pod "WDPRCore/WDPRLocalization"
```

## Code Contribution

For working on this repo and with this project, please check these Wikis

* [How To Contribute to the Code](https://wiki.wdpro.wdig.com/display/PROJ/How+to+contribute+code)
* [How To Submit a Pull Request](https://wiki.wdpro.wdig.com/display/PROJ/How+To+Submit+a+Pull+Request)
* [How To Code Review a Pull Request](https://wiki.wdpro.wdig.com/display/PROJ/How+To+Code+Review+a+Pull+Request)

## Updating/Modifiying

When updating/modifying this pod, several prerequisites should be done before submitting a PR.

1. Run `pod lib lint --allow-warnings --sources='https://github.disney.com/wdpro-mobile/pro-specs.git,https://github.com/CocoaPods/Specs'`. This will find various issues that might cause issues when using as a pod.
1. Update the Example app.
  * Add/Update the added/changed functionality in the Example to demonstrate it
  * Add Unit Tests where applicable
1. Run the Example app's Unit Tests

## Wiki

https://wiki.wdpro.wdig.com/display/PROJ/WDPRCore

## Who We Are

The Park Platform team maintains a Wiki with information on our team, how to reach us, file issues, and lots of other helpful items. It is located [here](https://wiki.wdpro.wdig.com/display/PROJ/Disney+Mobile+Park+Platform).
