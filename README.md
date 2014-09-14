# xcassets-filler

This fills an xcassets bundle (Xcode Asset Catalog) with one image or one solid color.

## Prerequisites

brew install imagemagick

Have a Xcode project with iOS7+ SDK. Make sure there is an asset catalog (Images.xcassets) with image sets in it, and in the image set, all the required options are selected. And make sure that in the targe->general settings, the app icons and launch images are pointed to the right sources.

## Use cases

### App Icon

    prepare.rb <path of a big square icon file> <AppIcon.appiconset path>

e.g.

    prepare.rb ~/Downloads/icon1024x1024.png ~/project/path/Images.xcassets/AppIcon.appiconset

Note: the iTunesArtwork files that are going to be used by iTunesConnect/App Store will also be saved in the folder where Images.xcassets is located.

### Launch Screen Image

    prepare.rb \#<hex color code> <LaunchImage.launchimage path>

e.g.

    prepare.rb \#111111 ~/project/path/Images.xcassets/LaunchImage.launchimage

Note: unlike appiconset, this image set doesn't provide sizes. So we use a map to determine the sizes. So from time to time we may need to update launch_image_size_map
