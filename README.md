# xcassets-filler

This fills an empty xcassets (Xcode Asset Catalog) file with one image or one solid color.

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
