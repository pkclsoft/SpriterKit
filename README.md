# SpriterKit

This is an implementation of [Spriter](https://www.brashmonkey.com) using Apple's SpriteKit.

It is inspired (and helped a little) by some of [SwiftSpriter](https://github.com/lumenlunae/SwiftSpriter) and [SpriterHaxeEngine](https://github.com/loudoweb/SpriterHaxeEngine.git).

## Example

### Demo (non Events)
This is a simple-ish demo app fills the screen with 260 entities, all animating, showing both the performance and the ease with which the library can be used.

To run the example project, clone the repo, load up the SpriterKitDemo project and run it on the target of your choice.  The demo works on iOS, macOS and tvOS.

### Demo (Events)
This additional demo app shows the use of the events and point trigger mechanisms added (at some point) to the Spriter project specification.

This was built by reverse engineering a project file kindly shared by the people at BrashMonkeys in their forums at: (Small Example Spriter (scml) files for the metadata features](https://brashmonkey.com/forum/index.php?/topic/4087-small-example-spriter-scml-files-for-the-metadata-features/).

## Requirements
SpriteKit

The library itself has no specific OS version requirements at this time other than the need to support SpriteKit.

## Installation

SpriterKit is available as a Swift Package via SPM. To install, simply add the package reference to your project.

## Features

Unlike the projects SpriterKit was inspired by, SpriterKit supports both SCML and SCON Spriter project file formats.  It supports Bones and Objects and provides a way to visualise the bones should you need to (at a hefty performance cost).

All curve types are supported.

An additional script under the Scripts folder can be used to migrate all of the sprite assets from your Spriter project into an Xcode asset catalog.  SpriterKit assumes that the image assets are located and available this way.

## Author

Peter Easdown @ pkclsoft (i#n#f#o@p#k#c#l#s#o#f#t#.#c#o#m)

## License

Some parts of SpriterKit have been ported or migrated from SwiftSpriter and for those I refer to the license in that project.
 
SpriterKit is available under the GNU GENERAL PUBLIC LICENSE v3. See the LICENSE file for more info.
