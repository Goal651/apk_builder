# ========== CONSTANTS ========== #
$script:VERSION = "1.0.1"
$script:BUNDLETOOL_VERSION = "1.18.2"
$script:BUNDLETOOL_URL = "https://github.com/google/bundletool/releases/download/$BUNDLETOOL_VERSION/bundletool-all-$BUNDLETOOL_VERSION.jar"
$script:DEFAULT_BUNDLETOOL = ".\bundletool-all-$BUNDLETOOL_VERSION.jar"

# ========== DEFAULT CONFIG ========== #
$script:VERBOSE = $true
$script:INTERACTIVE = $true
$script:OUTPUT_DIR = "."
$script:KEYSTORE_PATH = "my-release-key.keystore"
$script:KEYSTORE_ALIAS = "my-key-alias"
$script:KEYSTORE_PASS = "123456"
$script:BUILD_MODE = "universal"
$script:LOG_FILE = ""
$script:SECURE_INPUT = $false
$script:THEME = "msf"
