# Contributing to AAB Converter Tool

Thank you for your interest in contributing to Wilson Goal's AAB Converter Tool! This document provides guidelines and instructions for contributing to this project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contribution Guidelines](#contribution-guidelines)
- [Submitting Changes](#submitting-changes)
- [Testing](#testing)
- [Style Guidelines](#style-guidelines)

## 🤝 Code of Conduct

This project follows a simple code of conduct:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- Git installed
- For Linux development: Bash 4.0+, Ubuntu/Debian system
- For Windows development: PowerShell 5.1+ or PowerShell Core 7+
- Java JDK 8 or higher
- A GitHub account

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/apk_builder.git
   cd apk_builder
   ```

3. Add the upstream repository:

   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/apk_builder.git
   ```

## 🛠️ Development Setup

### Linux Development

```bash
cd linux
chmod +x main.sh
./main.sh --help
```

### Windows Development

```powershell
cd windows
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\main.ps1 -Help
```

### Testing with PowerShell Core (Cross-platform)

```bash
# Install PowerShell Core if not already installed
# On Ubuntu/Debian:
sudo apt install -y powershell

# Test Windows scripts on Linux
cd windows
pwsh -File main.ps1 -Help
```

## 📁 Project Structure

```
apk_builder/
├── linux/                  # Linux bash implementation
│   ├── main.sh            # Main entry point
│   └── src/               # Modular bash scripts
│       ├── aab.sh         # AAB operations
│       ├── bundle_tool.sh # Bundletool management
│       ├── config.sh      # Configuration
│       ├── constant.sh    # Constants
│       ├── error.sh       # Error handling
│       ├── help.sh        # Help documentation
│       ├── keystore.sh    # Keystore operations
│       ├── logger.sh      # Logging
│       ├── theme.sh       # Color themes
│       ├── ui.sh          # UI elements
│       └── utils.sh       # Utilities
│
├── windows/               # Windows PowerShell implementation
│   ├── main.ps1          # Main entry point
│   └── src/              # Modular PowerShell scripts
│       ├── AAB.ps1       # AAB operations
│       ├── BundleTool.ps1 # Bundletool management
│       ├── Config.ps1    # Configuration
│       ├── Constants.ps1 # Constants
│       ├── Error.ps1     # Error handling
│       ├── Help.ps1      # Help documentation
│       ├── Keystore.ps1  # Keystore operations
│       ├── Logger.ps1    # Logging
│       ├── Theme.ps1     # Color themes
│       ├── UI.ps1        # UI elements
│       └── Utils.ps1     # Utilities
│
├── README.md             # Main documentation
├── CONTRIBUTING.md       # This file
└── .gitignore           # Git ignore rules
```

## 📝 Contribution Guidelines

### What to Contribute

We welcome contributions in the following areas:

1. **Bug Fixes**
   - Fix existing bugs
   - Improve error handling
   - Enhance stability

2. **Features**
   - New conversion modes
   - Additional bundletool features
   - UI/UX improvements
   - Performance optimizations

3. **Documentation**
   - Improve README
   - Add usage examples
   - Fix typos
   - Translate documentation

4. **Platform Support**
   - macOS support
   - Additional Linux distributions
   - PowerShell Core enhancements

5. **Testing**
   - Add test cases
   - Improve test coverage
   - Test on different platforms

### What NOT to Contribute

- Breaking changes without discussion
- Features that don't align with project goals
- Code that doesn't follow style guidelines
- Untested code

## 🔄 Submitting Changes

### Branch Naming

Use descriptive branch names:

- `feature/add-macos-support`
- `bugfix/fix-keystore-validation`
- `docs/update-installation-guide`
- `refactor/improve-error-handling`

### Commit Messages

Follow conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(windows): add support for custom themes

fix(linux): resolve bundletool download timeout issue

docs(readme): update installation instructions for macOS
```

### Pull Request Process

1. **Update your fork:**

   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create a feature branch:**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**
   - Write clean, readable code
   - Follow existing code style
   - Add comments where necessary
   - Update documentation

4. **Test your changes:**
   - Test on the target platform
   - Ensure no regressions
   - Verify all commands work

5. **Commit your changes:**

   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

6. **Push to your fork:**

   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request:**
   - Go to GitHub and create a PR
   - Fill out the PR template
   - Link related issues
   - Request review

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (specify)

## Testing
- [ ] Tested on Linux
- [ ] Tested on Windows
- [ ] Tested on macOS (if applicable)
- [ ] All existing tests pass
- [ ] Added new tests (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit messages follow convention
```

## 🧪 Testing

### Manual Testing

#### Linux

```bash
cd linux

# Test help
./main.sh --help

# Test version
./main.sh --version

# Test conversion (with sample AAB)
./main.sh convert

# Test validation
./main.sh validate

# Test cleanup
./main.sh cleanup
```

#### Windows

```powershell
cd windows

# Test help
.\main.ps1 -Help

# Test version
.\main.ps1 -ShowVersion

# Test conversion (with sample AAB)
.\main.ps1 -Command convert

# Test validation
.\main.ps1 -Command validate

# Test cleanup
.\main.ps1 -Command cleanup
```

### Test Checklist

Before submitting a PR, verify:

- [ ] Script runs without errors
- [ ] Help text displays correctly
- [ ] Version information is accurate
- [ ] AAB files are detected properly
- [ ] Conversion works with sample AAB
- [ ] Error messages are clear and helpful
- [ ] Dependencies are checked correctly
- [ ] Keystore creation works
- [ ] Output files are generated correctly
- [ ] Cleanup removes generated files

## 🎨 Style Guidelines

### Bash (Linux)

```bash
# Use descriptive function names
function convert_aab() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    # Add comments for complex logic
    log_info "Converting AAB to APKS format..."
    
    # Use proper error handling
    if [[ ! -f "$aab_file" ]]; then
        log_error "File not found: $aab_file"
        return 1
    fi
}

# Use consistent indentation (4 spaces)
# Use lowercase with underscores for variables
# Use uppercase for constants
readonly VERSION="1.0.1"
```

### PowerShell (Windows)

```powershell
# Use PascalCase for function names
function Convert-AAB {
    param(
        [string]$AABFile,
        [string]$BundleToolPath
    )
    
    # Add comments for complex logic
    Log-Info "Converting AAB to APKS format..."
    
    # Use proper error handling
    if (-not (Test-Path $AABFile)) {
        Log-Error "File not found: $AABFile"
        return $false
    }
}

# Use PascalCase for parameters
# Use $script: for script-level variables
# Use approved verbs (Get, Set, New, Remove, etc.)
```

### Documentation

- Use clear, concise language
- Include code examples
- Keep line length under 100 characters
- Use proper markdown formatting
- Add emojis sparingly for visual appeal

## 🐛 Reporting Bugs

### Before Reporting

1. Check existing issues
2. Verify it's not a configuration issue
3. Test on latest version
4. Gather relevant information

### Bug Report Template

```markdown
**Description**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: [e.g., Windows 11, Ubuntu 22.04]
- PowerShell/Bash version:
- Java version:
- Script version:

**Screenshots/Logs**
If applicable, add screenshots or error logs

**Additional Context**
Any other relevant information
```

## 💡 Feature Requests

### Before Requesting

1. Check existing feature requests
2. Ensure it aligns with project goals
3. Consider if it benefits most users

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
Clear description of desired functionality

**Describe alternatives you've considered**
Other approaches you've thought about

**Additional context**
Any other relevant information
```

## 📞 Getting Help

- **Issues**: [GitHub Issues](https://github.com/yourusername/apk_builder/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/apk_builder/discussions)
- **Email**: <bugiriwilson651@gmail.com>

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to AAB Converter Tool! 🎉

---

**Created with ❤️ by Wilson Goal - 2025**
