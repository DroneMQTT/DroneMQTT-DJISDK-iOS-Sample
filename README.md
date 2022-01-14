# DroneMQTT-DJISDK-iOS-Sample

DroneMQTT sample program for iOS (Swift) on DJI SDK

## Online docs

please visit **[https://docs.dronemqtt.com/](https://docs.dronemqtt.com/)**

## MQTT Account

DroneMQTT offers free and paid plans. 
please visit **[https://dronemqtt.com/](https://dronemqtt.com/)** to get a MQTTT instance

## DJI Developer Account

You need a DJI Developer account and APP Key to run this project.
please visit **[https://developer.dji.com/](https://developer.dji.com/)**

## Install

~~~
pod install
~~~

## How to use this project

1. Use your own Bundle Identifier
2. Use your own Provisioning Profile
3. Use your MQTT config in Swift code

### Swift code
you need to replace the values with your config data.
```swift:DefaultLayoutViewController.swift
  let host = "[assigned-domain].dronemqtt.com"
  let port: Int32 = 1883
  let username = "[mqtt username]"
  let password = "[mqtt password]"
```

## Library
this project uses these libraries
```
DJI-SDK
DJI-UXSDK-iOS
DJIWidget
Moscapsule
OpenSSL-Universal
```

## Support
Ask me on https://twitter.com/DroneMQTT
