#!/bin/sh
# Copyright 2014 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# A convenient script to configure a local project for Flutter development.

# Required variables:
# FLUTTER_SDK_PATH
# PROJECT_DIR
# TRACKED_FILES_COUNT

set -e

# Verify that the git repository has the required files.
check_tracked_files() {
  if [ $TRACKED_FILES_COUNT -lt 1 ]; then
    echo "error: Missing git tracked files."
    exit 1
  fi
}

# Verify that git is available.
if ! hash git 2>/dev/null; then
  echo "error: Git is required but was not found."
  exit 1
fi

# Verify that the project directory is a git repository.
if ! git -C "$PROJECT_DIR" rev-parse HEAD >/dev/null 2>&1; then
  echo "error: Not a git repository."
  exit 1
fi

# Verify that the project has at least one tracked file.
cd "$PROJECT_DIR"
TRACKED_FILES_COUNT=$(git ls-files | wc -l)
check_tracked_files