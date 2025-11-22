# 🌟 Wilson Goal's AAB Converter Tool

A powerful, cross-platform command-line tool for converting Android App Bundle (.aab) files to APK format with automatic dependency management and user-friendly features. Available for both **Linux** and **Windows**.

## 🚀 Features

- **🔄 One-Click Conversion** - Convert multiple AAB files to APK format instantly
- **✅ Bundle Validation** - Verify AAB file integrity before conversion
- **📋 File Information** - Display detailed AAB bundle metadata
- **🔧 Auto Dependency Management** - Automatically detect and install missing dependencies
- **💻 Cross-Platform** - Works on Linux (Ubuntu/Debian) and Windows (10/11)
- **🎨 Colored Output** - Beautiful, informative terminal output with emojis
- **📝 Verbose Logging** - Detailed progress information and error reporting
- **🔐 Keystore Support** - Custom signing configuration for APK generation
- **📁 Flexible Output** - Custom output directory support

## 📋 Requirements

### System Requirements

#### Linux

- **OS**: Ubuntu/Debian-based Linux distribution
- **Architecture**: x86_64 or ARM64
- **Internet**: Required for bundletool download

#### Windows

- **OS**: Windows 10/11
- **PowerShell**: 5.1 or later (included in Windows 10/11)
- **Internet**: Required for bundletool download

### Automatic Dependencies

The tool will automatically detect and install:

- **Java Development Kit (JDK 8+)**
- **Bundletool** (Google's AAB conversion tool)
- **curl** (Linux) or **Invoke-WebRequest** (Windows PowerShell)

## 🛠️ Installation

### Linux - Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/apk_builder.git
cd apk_builder/linux

# Make the script executable
chmod +x main.sh

# Run the script (dependencies will be auto-installed)
./main.sh
```

### Windows - Quick Start

```powershell
# Clone the repository
git clone https://github.com/yourusername/apk_builder.git
cd apk_builder\windows

# Set execution policy (if needed, run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script (dependencies will be auto-installed)
.\main.ps1
```

### Manual Setup

#### Linux

```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/apk_builder/main/linux/main.sh

# Make executable
chmod +x main.sh

# Run
./main.sh
```

#### Windows

```powershell
# Download the repository as ZIP or clone with git
# Extract to a folder and navigate to windows directory

# Set execution policy (run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run
.\main.ps1
```

## 📖 Usage

### Linux - Basic Commands

```bash
# Interactive conversion (default)
cd linux
./main.sh

# Silent conversion (no verbose output)
./main.sh --quiet

# Batch conversion (non-interactive)
./main.sh --non-interactive

# Custom output directory
./main.sh --output ./apks --verbose

# Validate AAB files
./main.sh validate

# Show AAB file information
./main.sh info

# Show help
./main.sh --help

# Show version
./main.sh --version
```

### Windows - Basic Commands

```powershell
# Interactive conversion (default)
cd windows
.\main.ps1

# Silent conversion (no verbose output)
.\main.ps1 -Quiet

# Batch conversion (non-interactive)
.\main.ps1 -NonInteractive

# Custom output directory
.\main.ps1 -Output .\apks -Verbose

# Validate AAB files
.\main.ps1 -Command validate

# Show AAB file information
.\main.ps1 -Command info

# Show help
.\main.ps1 -Help

# Show version
.\main.ps1 -Version
```

### Advanced Options

#### Linux

```bash
# Custom keystore configuration
./main.sh --keystore my-key.keystore --alias my-alias --password mypassword

# Different build modes
./main.sh --mode universal    # Default: single APK for all devices
./main.sh --mode system       # System-signed APK
./main.sh --mode persistent   # Persistent APK

# Enable logging to file
./main.sh --log conversion.log
```

#### Windows

```powershell
# Custom keystore configuration
.\main.ps1 -Keystore my-key.keystore -Alias my-alias -Password mypassword

# Different build modes
.\main.ps1 -Mode universal    # Default: single APK for all devices
.\main.ps1 -Mode system       # System-signed APK
.\main.ps1 -Mode persistent   # Persistent APK

# Enable logging to file
.\main.ps1 -Log conversion.log
```

## 🎯 Command Reference

### Commands

| Command | Description |
|---------|-------------|
| `convert` | Convert AAB files to APKs (default) |
| `validate` | Validate AAB bundle integrity |
| `info` | Show detailed AAB file information |
| `help` | Display help message |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-h, --help` | Show help message | |
| `-v, --verbose` | Enable verbose output | ✅ Enabled |
| `--quiet` | Disable verbose output | |
| `-i, --interactive` | Interactive mode | ✅ Enabled |
| `-n, --non-interactive` | Non-interactive mode | |
| `-o, --output DIR` | Output directory | Current directory |
| `-k, --keystore PATH` | Keystore file path | `my-release-key.keystore` |
| `-a, --alias ALIAS` | Keystore alias | `my-key-alias` |
| `-p, --password PASS` | Keystore password | `123456` |
| `-m, --mode MODE` | Build mode | `universal` |
| `-l, --log FILE` | Log output to file | |
| `-V, --version` | Show version information | |

## 🔄 Workflow Examples

### 1. First Time Setup

```bash
# Initial run - will detect and install dependencies
./builder.sh

# Output:
# 🔍 Checking Dependencies...
#   • Java Runtime Environment... ✅ Found (11.0.16)
#   • curl... ✅ Found (7.81.0)
#   • find utility... ✅ Found
#   • disk utility (du)... ✅ Found
#   • Bundletool jar... ❌ Missing
# 
# ⚠️  Missing Dependencies Detected:
#   - Bundletool 1.18.2
# 
# 📋 Actions to be taken:
#   - Download Bundletool 1.18.2 from GitHub
# 
# 🤔 Would you like me to automatically install/download these missing dependencies? [y/N]: y
# 
# 🔧 Installing missing dependencies...
# 
# ➤ Processing: Bundletool 1.18.2
# 🌐 Downloading bundletool 1.18.2...
# 📡 URL: https://github.com/google/bundletool/releases/download/1.18.2/bundletool-all-1.18.2.jar
# 💾 Target: ./bundletool-all-1.18.2.jar
# ✅ Download completed (3.2M)
# 
# 🎉 All dependencies installed successfully!
```

### 2. Converting Multiple AAB Files

```bash
# Place your .aab files in the directory
ls *.aab
# app-release.aab  game-debug.aab  tools-prod.aab

# Convert all files
./builder.sh --output ./converted_apks

# Output:
# 🔍 Checking AAB files...
# 📁 Found 3 AAB file(s):
# -rw-r--r-- 1 user user 12M Oct 28 07:15 app-release.aab
# -rw-r--r-- 1 user user 8.5M Oct 28 07:15 game-debug.aab
# -rw-r--r-- 1 user user 15M Oct 28 07:15 tools-prod.aab
# 
# 📦 Processing: app-release.aab
# 🔄 Converting to ./converted_apks/app-release.apks...
# 🎉 Created: ./converted_apks/app-release.apks
# 
# 📦 Processing: game-debug.aab
# 🔄 Converting to ./converted_apks/game-debug.apks...
# 🎉 Created: ./converted_apks/game-debug.apks
# 
# 📦 Processing: tools-prod.aab
# 🔄 Converting to ./converted_apks/tools-prod.apks...
# 🎉 Created: ./converted_apks/tools-prod.apks
# 
# 🎊 All conversions completed successfully!
```

### 3. Validation Mode

```bash
./builder.sh validate

# Output:
# 🔍 Checking AAB files for validation...
# 📁 Found 2 AAB file(s):
# 
# 🔍 Validating: app-release.aab
# ✅ Valid AAB: app-release.aab
# Bundle validation successful
# 
# 🔍 Validating: corrupted-bundle.aab
# ❌ Validation failed for corrupted-bundle.aab
# ERROR: Invalid bundle file
# 
# ⚠️  Validation completed with 1 invalid file(s)
```

## 🐛 Troubleshooting

### Linux - Common Issues

#### 1. Permission Denied

```bash
chmod +x main.sh
```

#### 2. Java Not Found

```bash
# The tool will automatically offer to install Java
sudo apt update
sudo apt install -y openjdk-21-jre
```

#### 3. Bundletool Download Failed

```bash
# Check internet connection
curl -I https://github.com/google/bundletool/releases/latest

# Manual download if needed
wget https://github.com/google/bundletool/releases/download/1.18.2/bundletool-all-1.18.2.jar
```

#### 4. Keystore Issues

```bash
# Generate a new keystore
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
                                                                                    
# Use custom keystore
./main.sh --keystore my-release-key.keystore --alias my-key-alias --password yourpassword
```

### Windows - Common Issues

#### 1. Execution Policy Error

```powershell
# Run PowerShell as Administrator and execute:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for current session only:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

#### 2. Java Not Found

```powershell
# Download and install Java JDK from:
# https://adoptium.net/ (recommended)
# or https://www.oracle.com/java/technologies/downloads/

# Verify installation
java -version
```

#### 3. Bundletool Download Failed

```powershell
# Check internet connection
Test-NetConnection github.com -Port 443

# Manual download if needed
Invoke-WebRequest -Uri "https://github.com/google/bundletool/releases/download/1.18.2/bundletool-all-1.18.2.jar" -OutFile "bundletool-all-1.18.2.jar"
```

#### 4. Keystore Issues

```powershell
# Generate a new keystore
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

# Use custom keystore
.\main.ps1 -Keystore my-release-key.keystore -Alias my-key-alias -Password yourpassword
```

#### 5. Script Not Found or Path Issues

```powershell
# Make sure you're in the correct directory
cd path\to\apk_builder\windows

# Run with full path if needed
& "C:\path\to\apk_builder\windows\main.ps1"
```

### Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `🚫 No AAB files found` | No .aab files in directory | Place .aab files in current directory |
| `❌ Java is required` | Java not installed | Allow auto-install or install manually |
| `❌ Failed to download bundletool` | Network issues | Check internet connection or download manually |
| `💥 Conversion failed` | Invalid AAB file | Use `validate` command to check file integrity |
| `Execution Policy` (Windows) | PowerShell security policy | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

## 📁 File Structure

```bash
apk_builder/
├── builder.sh           # Main script
├── README.md           # This documentation
├── .gitignore          # Git ignore file
├── examples/           # Example AAB files (optional)
└── logs/              # Log files directory (auto-created)
```

### Generated Files

After conversion, you'll find:

- `*.apks` - APK bundle files (can be installed directly)
- `conversion.log` - Detailed conversion log (if logging enabled)

## 🔧 Configuration

### Environment Variables

```bash
# Set custom output directory
export APK_BUILDER_OUTPUT="./my_apks"

# Set custom keystore
export APK_BUILDER_KEYSTORE="./keys/release.keystore"
export APK_BUILDER_ALIAS="release"
export APK_BUILDER_PASSWORD="mypass123"
```

### Default Keystore

The tool includes a default keystore for testing:

- **File**: `my-release-key.keystore`
- **Alias**: `my-key-alias`
- **Password**: `123456`

⚠️ **Warning**: Use the default keystore only for testing. Generate your own keystore for production apps.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google** for the [Bundletool](https://github.com/google/bundletool) utility
- **Android** community for AAB format support
- **Ubuntu/Debian** for excellent package management

## 📞 Support

- 🐛 **Bug Reports**: [Create an Issue](https://github.com/yourusername/apk_builder/issues)
- 💡 **Feature Requests**: [Create an Issue](https://github.com/yourusername/apk_builder/issues)
- 📧 **Email**: <bugiriwilson651@gmail.com>

## 🔗 Related Links

- [Android App Bundle Documentation](https://developer.android.com/guide/app-bundle)
- [Bundletool GitHub Repository](https://github.com/google/bundletool)
- [Android Studio Releases](https://developer.android.com/studio/releases)

---

## **Created with ❤️ by Wilson Goal - 2025**

*If this tool helped you, consider giving it a ⭐ on GitHub!*
