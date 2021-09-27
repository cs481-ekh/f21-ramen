#!/bin/bash
echo "Linux cannot compile the iOS version of the app, so this script will only
build the Android APK."

flutter build apk
if [ "$?" -ne "0" ]; then
	  echo "Error with flutter build!"
	  exit 1
fi
echo "Build finished without errors."
exit 0
