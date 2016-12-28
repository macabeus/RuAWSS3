# RuAWSS3

[![CI Status](http://img.shields.io/travis/Macabeus/RuAWSS3.svg?style=flat)](https://travis-ci.org/Macabeus/RuAWSS3)
[![Version](https://img.shields.io/cocoapods/v/RuAWSS3.svg?style=flat)](http://cocoapods.org/pods/RuAWSS3)
[![License](https://img.shields.io/cocoapods/l/RuAWSS3.svg?style=flat)](http://cocoapods.org/pods/RuAWSS3)
[![Platform](https://img.shields.io/cocoapods/p/RuAWSS3.svg?style=flat)](http://cocoapods.org/pods/RuAWSS3)

Since AWS's official library is extremely complicated, I decided to make one to simplify the work.
All asynchrony is performed using [PromiseKit](https://github.com/mxcl/PromiseKit). You need to know the concept of promise; if you don't know, [see it](https://realm.io/news/altconf-michael-gray-futures-promises-gcd/).

![alt text](http://i.imgur.com/ubPEHUL.png)

## Run the example project

1. Clone the repo
2. Run `pod install` from the Example directory first
3. Open `AppDelegate.swift`
4. Update `application(_:didFinishLaunchingWithOptions)` with your Amazon's credentials

## Installation

RuAWSS3 is available through [CocoaPods](http://cocoapods.org). To install
it, add the following line to your Podfile:

```ruby
pod 'RuAWSS3', '~> 0.1.0-beta'
```

And, add in your `AppDelegate.swift`:

```swift
import RuAWSS3
...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

  AmazonS3.shared.performCredentials(
      regionType: ** YOUR REGION **,
      identityPoolId: ** YOUR POOL ID **
  )
  
  return true
}
```

## Usage

Firstly, you **need** import this modules:
```swift
import PromiseKit
import RuAWSS3
```

Upload image
```swift
firstly {
    AmazonS3.shared.uploadImage(
        bucket: "example",
        key: "image.jpg",
        image: UIImage(named: "example")!
    )
}.then {
    print("succes õ/")
}.catch { error in
    print("fail ;-;")
    print((error as NSError).localizedDescription)
}
```

Download image
```swift
firstly {
    AmazonS3.shared.download(
        bucket: "example",
        key: "image.jpg"
    )
}.then { filePath -> Void in
    print("succes õ/")
    self.imgView.image = UIImage(contentsOfFile: filePath)!
}.catch { error in
    print("fail ;-;")
    print((error as NSError).localizedDescription)
}
```

Delete file
```swift
firstly {
    AmazonS3.shared.delete(
        bucket: "example",
        key: "image.jpg"
    )
}.then {
    print("succes õ/")
}.catch { error in
    print("fail ;-;")
    print((error as NSError).localizedDescription)
}
```

You can see others amazing examples in [Example application](https://github.com/brunomacabeusbr/RuAWSS3/blob/master/Example/RuAWSS3/ViewController.swift).

## Author

Macabeus, bruno.macabeus@gmail.com

## License

RuAWSS3 is available under the MIT license. See the LICENSE file for more info.
