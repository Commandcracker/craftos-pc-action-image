#!/bin/bash

# This needs to be done because github action will change your pwd
if [[ -n $LUAJIT ]]; then
    ln --symbolic /craftos2-luajit craftos2-luajit
fi

# Fix pulseaudio "Home directory not accessible: Permission denied"
HOME=/tmp/$USER

# Ensure that default values are set
if [[ -z $TIMEOUT_SIGNAL ]]; then
    TIMEOUT_SIGNAL="HUP"
fi

if [[ -z $ROOT ]]; then
    ROOT="./"
fi

# Set ROOT to absolute path
ROOT=$(realpath -s "$ROOT")

if [[ -z $TIMEOUT ]]; then
    TIMEOUT="60"
fi

# Setup variables
if [[ -z $LUAJIT ]]; then
    COMMAND="craftos"
else
    COMMAND="craftos-luajit"
fi

if [[ ! -z $ID ]]; then
    SET_ID="--id $ID"
else
    # Set ID to 0 if none is specified
    ID=0
fi

if [[ -z $DISABLE_TWEAKS ]]; then
    MOUNT_TWEAKS="--mount /rom/autorun=/opt/craftos-pc-action/craftos-pc-tweaks"
fi

if [[ -z $DISABLE_DEFAULT_SETTINGS ]]; then
    MOUNT_DEFAULT_SETTINGS="--mount /=/opt/craftos-pc-action/settings"
fi

# Prioritize $DIRECTORY over $ROOT and only link $ROOT if it is not disabled
if [[ ! -z $DIRECTORY ]]; then
    SET_DIRECTORY="--directory $DIRECTORY"
    # Set DIRECTORY to absolute path
    DIRECTORY=$(realpath -s "$DIRECTORY")
else
    DIRECTORY="/opt/craftos-pc-action/data_directory"
    # Create default data directory
    mkdir --parents "$DIRECTORY/computer"
    SET_DIRECTORY="--directory $DIRECTORY"
fi

# link root folder to computer dir
if [[ -z $DISABLE_ROOT ]]; then
    ln --symbolic "$ROOT" "$DIRECTORY/computer/$ID"
fi

if [[ -z $DISABLE_HEADLESS ]]; then
    HEADLESS="--headless"
fi

if [[ -z $DISABLE_SINGLE ]]; then
    SINGLE="--single"
fi

if [[ -z $DISABLE_TIMEOUT_VERBOSE ]]; then
    TIMEOUT_VERBOSE="--verbose"
fi

# Print CraftOS-PC Version
echo $($COMMAND --version | head -n 1)

# Run CraftOS-PC
timeout --signal=$TIMEOUT_SIGNAL $TIMEOUT_VERBOSE $TIMEOUT_ARGUMENTS $TIMEOUT $COMMAND \
    $HEADLESS $SINGLE \
    $MOUNT_DEFAULT_SETTINGS \
    $MOUNT_TWEAKS \
    $SET_ID $SET_DIRECTORY $OPTIONS

# Capture exit status
exit_status=$?

# Cleanup
if [[ -n $LUAJIT ]]; then
    rm craftos2-luajit > /dev/null 2>&1
fi

# Exit with captured exit status
exit $exit_status
