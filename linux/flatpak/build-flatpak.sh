#!/bin/bash

# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x

projectName=TubeSync
projectId=io.github.khaled_0.TubeSync
executableName=tubesync

# Unzip Binary
mkdir $projectName
unzip tubesync_linux_release.zip -d $projectName

# Copy the portable app to the Flatpak-based location.
cp -r $projectName /app/
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon.
iconDir=/app/share/icons/hicolor/scalable/apps
mkdir -p $iconDir
ls $projectName/
cp -r $projectName/data/flutter_assets/assets/tubesync.png $iconDir/$projectId.png

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp -r ./$projectId.desktop $desktopFileDir/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp -r ./$projectId.metainfo.xml $metadataDir/
