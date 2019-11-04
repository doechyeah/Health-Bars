#!/bin/sh
cd "${1}"
my_deps="AudioKit.framework"
if [ -d "${my_deps}" -o -L "${my_deps}"  ]; then
  echo "AudioKit.framework already exists, skipping fetch"
else
  echo "Fetching AudioKit.framework"
  curl -O -L https://github.com/AudioKit/AudioKit/releases/download/v4.7.2/AudioKit-iOS-4.7.2.zip
  unzip AudioKit-iOS-4.7.2.zip
  cp -a AudioKit-iOS/AudioKit.framework .
  echo "Done fetching AudioKit.framework, cleaning up downloaded files"
  rm -rf AudioKit-iOS-4.7.2.zip
  rm -rf AudioKit-iOS
  echo "Done cleanup of downloaded files"
fi
