# scurl

**Intelligent curl wrapper with automatic typo detection and correction**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/yourusername/scurl/releases)
[![Shell Script](https://img.shields.io/badge/shell-bash-blue.svg)](https://www.gnu.org/software/bash/)

> Stop wasting time debugging curl typos. Let scurl fix them for you automatically.

## ⚡ Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/abheektripathy/scurl/main/install.sh | bash
```

## 🚀 Features

- ✅ **Fixes option typos** (`-x` → `-X`, `--Head` → `--header`)
- ✅ **Corrects HTTP methods** (`post` → `POST`, `get` → `GET`)
- ✅ **Adds missing JSON quotes** (`{name:john}` → `'{"name":"john"}'`)
- ✅ **Suggests HTTPS over HTTP** for security
- ✅ **Recommends missing headers** (Content-Type, etc.)
- ✅ **Interactive corrections** with confirmation prompts
- ✅ **Zero configuration** - works out of the box
- ✅ **Colored output** for easy scanning

## 📖 Usage

Use `scurl` exactly like `curl`, but with intelligent error correction:

```bash
# Instead of curl with typos:
scurl -x post -d {name:"john"} http://api.example.com

# scurl automatically suggests:
curl -X POST -d '{"name":"john"}' https://api.example.com
```

## 🎯 What It Fixes

### Option Typo Corrections
```bash
# Before → After
scurl -x POST api.com                    → curl -X POST api.com
scurl -h "Content-Type: json" api.com    → curl --header "Content-Type: json" api.com
scurl --Head "Auth: Bearer xyz" api.com  → curl --header "Auth: Bearer xyz" api.com
scurl -D '{"data": "test"}' api.com      → curl --data '{"data": "test"}' api.com
scurl -l api.com                         → curl --location api.com
```

### HTTP Method Capitalization
```bash
# Before → After
scurl -X get api.com                     → curl -X GET api.com
scurl -X post api.com                    → curl -X POST api.com
scurl -X delete api.com                  → curl -X DELETE api.com
scurl --request Put api.com              → curl --request PUT api.com
```

### JSON Data Corrections
```bash
# Before → After
scurl -d {name:john} api.com             → curl -d '{"name":"john"}' api.com
scurl -d {"name":"john","age":25} api.com → curl -d '{"name":"john","age":25}' api.com
```

### URL Format Suggestions
```bash
# Suggests HTTPS for security
scurl http://api.example.com             → Suggests: https://api.example.com

# Adds missing protocol
scurl api.example.com                    → Suggests: https://api.example.com
```

### Smart Suggestions
```bash
# Suggests Content-Type for POST/PUT/PATCH with data
scurl -X POST -d '{"name":"john"}' api.com
# → Suggests: -H "Content-Type: application/json"

# Always suggests redirect flag
scurl https://api.com                    → Suggests: Add -L flag to follow redirects
```

## 🛠️ Installation

### Quick Install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/scurl/main/install.sh | bash
```

### Manual Installation

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/yourusername/scurl/main/scurl
   ```

2. **Make it executable:**
   ```bash
   chmod +x scurl
   ```

3. **Move to your PATH:**
   ```bash
   # System-wide (requires sudo)
   sudo mv scurl /usr/local/bin/

   # User-only
   mkdir -p ~/.local/bin
   mv scurl ~/.local/bin/
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

### Verify Installation
```bash
scurl --help
```

## 💡 Examples

### API Testing
```bash
# Login with multiple corrections
scurl -x Post -d {email:user@test.com,password:123} -h "content-type: json" api.com/login

# Gets corrected to:
curl -X POST --data '{"email":"user@test.com","password":123}' --header "content-type: json" https://api.com/login
```

### GraphQL Queries
```bash
# GraphQL with typos
scurl -x post -h "content-type: application/json" -d {query:"{ users { id name } }"} graphql.api.com

# Gets corrected to:
curl -X POST --header "content-type: application/json" --data '{"query":"{ users { id name } }"}' https://graphql.api.com
```

### File Uploads
```bash
# File upload with corrections
scurl -x put -h "Auth: Bearer token" -D @file.json api.com/upload

# Gets corrected to:
curl -X PUT --header "Auth: Bearer token" --data @file.json https://api.com/upload
```

## ⚙️ Configuration

scurl works out of the box with zero configuration. However, you can customize behavior by modifying the script variables:

- **OPTION_CORRECTIONS**: Add custom option mappings
- **HTTP_METHODS**: Add custom HTTP method corrections
- **Color output**: Modify color codes in the script

## 🔧 Advanced Usage

### Bypass Corrections
If you want to use the original curl without any corrections:
```bash
command curl [your options]
# or
\curl [your options]
```

### Check What Would Be Fixed
```bash
scurl --help  # Shows help and examples
```

### Interactive Mode
scurl always shows corrections before executing and asks for confirmation:
```bash
$ scurl -x post -d {name:john} api.com

⚠️  Warning: Correcting '-x' to '-X'
⚠️  Warning: Correcting HTTP method 'post' to 'POST'
⚠️  Warning: JSON data should be quoted. Adding quotes around: {name:john}

✅ Success: Corrected command:
curl -X POST -d '{"name":"john"}' https://api.com

Execute corrected command? (y/N):
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Add your improvements**
4. **Test thoroughly**
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Ideas for Contributions
- Add more typo corrections
- Improve URL validation
- Add support for more HTTP methods
- Better JSON validation
- Add configuration file support
- Create fish/zsh shell completions

## 📋 Requirements

- **Bash 4.0+** (most systems have this)
- **curl** (obviously!)
- **Standard Unix tools** (grep, sed, awk - usually pre-installed)

### Compatibility
- ✅ Linux (all distributions)
- ✅ macOS
- ✅ Windows (WSL, Git Bash, Cygwin)
- ✅ BSD variants

## 🐛 Troubleshooting

### scurl command not found
```bash
# Check if it's in your PATH
which scurl

# If not, add ~/.local/bin to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Permission denied
```bash
# Make sure the script is executable
chmod +x ~/.local/bin/scurl
```

### Corrections not working
- Ensure you have bash 4.0+ with `bash --version`
- Check that curl is installed with `curl --version`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by common curl mistakes we all make
- Built for developers, by developers
- Thanks to the curl team for the amazing tool

## 📈 Changelog

### v1.0.0 (2025-06-08)
- Initial release
- Basic typo correction for curl options
- HTTP method capitalization
- JSON quote detection
- URL format suggestions
- Interactive correction prompts
- Colored output support

---

**Made with ❤️ for developers who are tired of curl typos**

If scurl helped you, please ⭐ star this repo and share it with other developers!