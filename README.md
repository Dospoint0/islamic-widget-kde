# islamic-widget-kde
KDE plasma widget that shows upcoming prayer times, daily Qur'anic verses and ahadith.

## Installation

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/Dospoint0/islamic-widget-kde

# Create the destination directory if it doesn't exist
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget

# Copy the widget files
cp -r islamic-widget-kde/* ~/.local/share/plasma/plasmoids/org.kde.plasma.islamicwidget/

# Restart Plasma (or log out and log back in)
kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell
