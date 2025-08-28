## [2.0.0] - Enhanced for Smooth Monthly Usage

### Added
- 🛡️ Robust error handling and dependency checking
- 🎨 Colorful, informative output with progress indicators
- 💾 Automatic backup system with configurable retention (30 days default)
- 🔧 Configuration file support (.gifme.conf) for easy setup
- 🧹 Automatic cleanup of temporary files and old backups
- 📋 Command-line options: --help, --config, --version, --dry-run
- 🚀 Setup wizard (setup.sh) for quick configuration
- 🔄 Perfect compatibility with automated monthly cron jobs

### Fixed
- Fixed bash syntax errors in string comparisons
- Improved network error handling for API calls
- Enhanced security with proper variable quoting
- Better file operations with atomic moves

### Changed
- Complete rewrite for better maintainability and user experience
- Safer temporary file handling with unique directories
- Improved README documentation with setup instructions
- Enhanced backup system to prevent data loss

## [1.0.0]

- Initial tool release.