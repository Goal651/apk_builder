#!/usr/bin/env bash

# ========== CONSTANTS ========== #
readonly VERSION="1.0.1"
readonly BUNDLETOOL_VERSION="1.18.2"
readonly BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
readonly DEFAULT_BUNDLETOOL="./bundletool-all-${BUNDLETOOL_VERSION}.jar"

# ========== DEFAULT CONFIG ========== #
VERBOSE=true
INTERACTIVE=true
OUTPUT_DIR="."
KEYSTORE_PATH="my-release-key.keystore"
KEYSTORE_ALIAS="my-key-alias"
KEYSTORE_PASS="123456"
BUILD_MODE="universal"
LOG_FILE=""
SECURE_INPUT=false
THEME="msf"
