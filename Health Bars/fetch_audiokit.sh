#!/bin/sh
cd "${1}"
my_depSQL="SQLite.swift-0.12.2"
my_depAudio="AudioKit.framework"

if [ -d "${my_depAudio}" -o -L "${my_depAudio}"  ]; then
  echo "AudioKit already exists, skipping fetch"
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

if [ -d "${my_depSQL}" -o -L "${my_depSQL}"  ]; then
  echo "SQLite.swift already exists, skipping fetch"
else
  echo "Fetching SQLite.swift.Framework"
  curl -O -L https://github.com/stephencelis/SQLite.swift/archive/0.12.2.zip
  unzip 0.12.2.zip
  echo "Done fetching SQLite.framework, cleaning up downloaded files"
  rm -rf 0.12.2.zip
  echo "Done cleanup of downloaded files"
fi
