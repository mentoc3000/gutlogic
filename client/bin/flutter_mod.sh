#!/bin/bash

# Modify Flutter to accomodate issue related to screenshots
# https://github.com/flutter/flutter/issues/91668
# Replace script with https://github.com/flutter/flutter/issues/86985#issuecomment-1087941035

# Check that the file is from the expected version to correctly match line numbers
ver=$(flutter --version)
if [[ "$ver" != "Flutter 3.10.3"* ]]; then
    echo "Flutter version mismatch." 1>&2
    echo "Confirm file modification is still valid and necessary" 1>&2
    exit 1
fi

# Replace source file with modified file
src=$(dirname $(which flutter))/../packages/integration_test/ios/Classes/IntegrationTestPlugin.m
mod=flutter_mod_files/IntegrationTestPlugin.m
cp $mod $(dirname $src)