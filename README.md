# SwiftSpriter

[![CI Status](http://img.shields.io/travis/Matthew Herz/SwiftSpriter.svg?style=flat)](https://travis-ci.org/Matthew Herz/SwiftSpriter)
[![Version](https://img.shields.io/cocoapods/v/SwiftSpriter.svg?style=flat)](http://cocoapods.org/pods/SwiftSpriter)
[![License](https://img.shields.io/cocoapods/l/SwiftSpriter.svg?style=flat)](http://cocoapods.org/pods/SwiftSpriter)
[![Platform](https://img.shields.io/cocoapods/p/SwiftSpriter.svg?style=flat)](http://cocoapods.org/pods/SwiftSpriter)

SwiftSpriter is a port of [INSpriterKit](https://github.com/indieSoftware/INSpriterKit) in Swift. This is an implementation of [Spriter](https://www.brashmonkey.com) in Apple's SpriteKit.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SwiftSpriter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftSpriter"
```

## Features

It only supports the scon extension. Currently it runs all basic tests except dealing with bone scaling. It's slightly different from INSpriterKit in that it uses SKAction for its keyframe animations (not sure if I want to keep this or not), so currently it only does linear interpolations. 

Texture atlases work. Create your *.atlasc file and make sure the scon file uses the atlas. 

## Author

Matthew Herz, matthewaherz@gmail.com

## License

SwiftSpriter is available under the MIT license. See the LICENSE file for more info.
