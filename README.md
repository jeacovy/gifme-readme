![READme//GIFme](https://media.giphy.com/media/3o6wrhzdHGShspsARG/giphy.gif)

GIFme: Enhancing README Files with Animated GIFs

## Introduction

GIFme is a tool designed to help engineering teams add visual interest to their README files through the use of animated GIFs. The goal is to make README files more engaging, while providing teams with a simple and easy-to-use solution.

## Features

✨ **Enhanced for smooth monthly usage:**
- 🛡️ Robust error handling and dependency checking
- 🎨 Colorful, informative output with progress indicators
- 💾 Automatic backups with configurable retention
- 🔧 Configuration file support for easy setup
- 🧹 Automatic cleanup of temporary files and old backups
- 📋 Command-line options for help and configuration status
- 🔄 Perfect for automated monthly cron jobs

✨ **Original features:**
- 🎬 Add animated GIFs to your README files
- 🎯 Search by tags or get random GIFs
- 🛡️ Safe-for-work content (G-rated by default)
- 📄 Automatic README creation if it doesn't exist

## How to Use GIFme

GIFme v2.0 offers multiple ways to get started and is designed for smooth monthly usage:

### Quick Setup (Recommended)
1. Run the setup wizard: `./setup.sh`
2. Get your GIPHY API key from the [GIPHY website](https://developers.giphy.com/docs/api#quick-start-guide)
3. Edit `.gifme.conf` and add your API key
4. Run: `./readme-gifme.sh`

### Manual Setup
- Request a GIPHY API key from the [GIPHY website](https://support.giphy.com/hc/en-us/articles/360020283431-Request-A-GIPHY-API-Key)
- Set environment variables or create a `.gifme.conf` file:
  ```bash
  GIPHY_API_KEY_DEV=your_api_key_here
  GIPHY_TAG=programming
  ```
- Run the script: `./readme-gifme.sh`

### Monthly Automation
Set up a monthly cron job to automatically update your README:
```bash
# Edit your crontab
crontab -e

# Add this line (runs on the 1st of each month at 9 AM)
0 9 1 * * cd /path/to/gifme && ./readme-gifme.sh
```

### Configuration Options
Create a `.gifme.conf` file with any of these options:
- `GIPHY_API_KEY_DEV` - Your GIPHY API key (required)
- `GIPHY_TAG` - Search tag for GIFs (e.g., "programming", "cats")
- `GIPHY_RATING` - Content rating filter (g, pg, pg-13, r)
- `README_FILE` - Custom README file path
- `BACKUP_RETENTION_DAYS` - How long to keep backup files (default: 30)

## Use Cases

GIFme v2.0 is perfect for various scenarios:

- 📈 **Monthly README updates** - Set up automated monthly refreshes with new GIFs
- 🚀 **Pipeline builds** - Add dynamic content to release notes
- 📝 **Project documentation** - Make your documentation more engaging
- 🎉 **Release celebrations** - Add flair to version releases
- 👥 **Team morale** - Bring some fun to your project pages

With the enhanced monthly-usage features, you can easily automate GIF updates and maintain a fresh, engaging README without manual intervention.

## Notes

Please note that current support is only for adding a GIF at the top of the README files within the root of your codebase. Additionally, all GIFs provided by GIFme are rated G (i.e. safe for work).

## Contributions

Contributions to GIFme are welcome! If you think this tool can be improved in any way, please submit a pull request. We also encourage the use of GIF puns in PR titles and commits.

If you have any questions, suggestions, or just want to connect, you can find me on the following platforms:


