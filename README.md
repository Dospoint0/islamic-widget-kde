# Islamic Widget for KDE Plasma

A KDE Plasma widget that displays:
- Prayer times with countdown to the next prayer
- Daily Qur'anic verses with translations
- Daily Hadith from authentic sources

![Islamic Widget Preview](screenshot.png)

## Features

- **Prayer Times**: Shows all five daily prayers, sunrise, and midnight times
- **Dynamic Countdown**: Displays time remaining until the next prayer
- **Daily Qur'an Verse**: Random verse with English translation
- **Daily Hadith**: Random hadith from Sahih al-Bukhari
- **Location-based**: Configure your city and country for accurate prayer times
- **Customizable**: Control font size, theme, and which elements to display
- **Auto-updating**: Refreshes data daily and updates countdown timer in real-time

## Requirements

- KDE Plasma 6 (recommended) or Plasma 5
- Internet connection for API access

## Installation

### Method 1: Using the Installation Script (Recommended)

```bash
# Clone the repository
git clone https://github.com/Dospoint0/islamic-widget-kde

# Enter the repository directory
cd islamic-widget-kde

# Make the install script executable
chmod +x install.sh

# Run the installation script
./install.sh
```

The script will:
1. Detect your Plasma version
2. Create the necessary directories
3. Copy all required files
4. Offer to restart Plasma to activate the widget

### Method 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/Dospoint0/islamic-widget-kde

# Create the destination directory if it doesn't exist
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget/contents/{ui,config}

# Copy the widget files
cp islamic-widget-kde/metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget/
cp islamic-widget-kde/contents/ui/*.qml ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget/contents/ui/
cp islamic-widget-kde/contents/config/* ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget/contents/config/

# Restart Plasma
# For Plasma 6:
kquitapp6 plasmashell || killall plasmashell && kstart6 plasmashell
# For Plasma 5:
kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell
```

## Usage

### Adding the Widget

1. Right-click on your desktop or panel
2. Select "Add Widgets..."
3. Search for "Islamic Widget"
4. Click on the widget to add it to your desktop/panel

### Configuration

Right-click on the widget and select "Configure..." to access settings:

- **Location Settings**:
  - City: Your city name (e.g., "London")
  - Country: Your country name (e.g., "United Kingdom")
  - Timezone: Your timezone (e.g., "Europe/London")

- **Appearance Settings**:
  - Font Size: Adjust text size (8-24px)
  - Theme: Choose between light and dark
  - Show Arabic Text: Toggle Arabic verse display
  - Show Translation: Toggle English translation display
  - Show Hadith: Toggle hadith display
  - Show Prayer Times: Toggle prayer times display

### Refreshing Data

The widget automatically updates at midnight, but you can manually refresh the data by clicking the "Refresh" button at the bottom of the widget.

## Troubleshooting

### Widget Not Appearing After Installation

1. Make sure you've restarted Plasma
2. Check if the installation directory exists: `ls ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget`
3. Ensure all files are in the correct places

### Prayer Times Not Loading

1. Check your internet connection
2. Verify that your city and country names are correct in the widget settings
3. Try refreshing the widget using the button at the bottom

## API Information

This widget uses the following APIs:
- Prayer Times: Al Adhan API (https://aladhan.com/prayer-times-api)
- Qur'an Verses: Al Quran Cloud API (https://alquran.cloud/api)
- Hadith: Random Hadith Generator API (https://random-hadith-generator.vercel.app)

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.