#!/bin/bash

#is brew installed? if not, install it
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }



# this is for tools required 
brew update
brew install ninja
brew install cmake

# crete the default root directory
mkdir $HOME/Aseprite
cd $HOME/Aseprite


# download skia m102
curl -O -L "https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-macOS-Release-arm64.zip"
unzip Skia-macOS-Release-arm64.zip -d skia-m102
rm Skia-macOS-Release-arm64.zip

# this is the project itselft
curl -O -L "https://github.com/aseprite/aseprite/releases/download/v1.3-beta21/Aseprite-v1.3-beta21-Source.zip"
unzip Aseprite-v1.3-beta21-Source.zip -d aseprite
rm Aseprite-v1.3-beta21-Source.zip

# compiling aseprite
cd aseprite
mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -DLAF_BACKEND=skia -DSKIA_DIR=$HOME/Aseprite/skia-m102 -DSKIA_LIBRARY_DIR=$HOME/Aseprite/skia-m102/out/Release-arm64 -DSKIA_LIBRARY=$HOME/Aseprite/skia-m102/out/Release-arm64/libskia.a -DPNG_ARM_NEON:STRING=on -G Ninja ..


ninja aseprite
cd ../..

# bundle app from trial
mkdir bundle
cd bundle
curl -O -J "https://www.aseprite.org/downloads/trial/Aseprite-v1.2.40-trial-macOS.dmg"
mkdir mount
yes qy | hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint mount Aseprite-v1.2.40-trial-macOS.dmg
cp -r mount/Aseprite.app .
hdiutil detach mount
rm -rf Aseprite.app/Contents/MacOS/aseprite
cp -r ../aseprite/build/bin/aseprite Aseprite.app/Contents/MacOS/aseprite
rm -rf Aseprite.app/Contents/Resources/data
cp -r ../aseprite/build/bin/data Aseprite.app/Contents/Resources/data
cd .. 

# Install on /Applications
sudo cp -R bundle/Aseprite.app /Applications/
cd $HOME
rm -rf Aseprite
echo "Please check your 'Applications' folder for Aseprite App"




