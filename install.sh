#!/bin/bash

# Islamic Widget for KDE Plasma 6 - Installation Script
# ----------------------------------------------------

echo "Islamic Widget for KDE Plasma 6 - Installation Script"
echo "===================================================="
echo

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define repository URL - replace with your actual repository
REPO_URL="https://github.com/Dospoint0/Islamic-Widget-KDE.git"
REPO_NAME="Islamic-Widget-KDE"
PLASMOID_NAME="org.kde.plasma.islamicwidget"
PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_NAME"

# Detect Plasma version
PLASMA_VERSION=$(plasmashell --version 2>/dev/null | grep -o '^plasmashell [0-9]*' | awk '{print $2}' || echo "5")
echo -e "${BLUE}Detected Plasma version: $PLASMA_VERSION${NC}"

if [ "$PLASMA_VERSION" -lt "6" ]; then
    echo -e "${RED}This widget is designed for Plasma 6.${NC}"
    echo -e "${YELLOW}Do you want to continue anyway? (y/n)${NC}"
    read -r continue_choice
    if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || { echo -e "${RED}Failed to create temporary directory${NC}"; exit 1; }

echo -e "${BLUE}Step 1: Cloning repository...${NC}"
if git clone "$REPO_URL" "$REPO_NAME"; then
    echo -e "${GREEN}Repository cloned successfully!${NC}"
else
    echo -e "${RED}Failed to clone repository${NC}"
    echo "Please check if Git is installed and the repository URL is correct."
    echo "Repository URL: $REPO_URL"
    exit 1
fi

cd "$REPO_NAME" || { echo -e "${RED}Failed to enter repository directory${NC}"; exit 1; }

echo -e "${BLUE}Step 2: Creating installation directory...${NC}"
mkdir -p "$PLASMOID_DIR/contents/ui"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create plasmoid directory${NC}"
    exit 1
fi
echo -e "${GREEN}Installation directory created: $PLASMOID_DIR${NC}"

echo -e "${BLUE}Step 3: Copying widget files...${NC}"

# Copy metadata file based on Plasma version
if [ "$PLASMA_VERSION" -ge "6" ]; then
    # Use metadata.json for Plasma 6
    if [ -f "metadata.json" ]; then
        cp metadata.json "$PLASMOID_DIR/" || { echo -e "${RED}Failed to copy metadata.json${NC}"; exit 1; }
    else
        echo -e "${RED}metadata.json not found!${NC}"
        exit 1
    fi
else
    # Use metadata.desktop for Plasma 5
    if [ -f "metadata.desktop" ]; then
        cp metadata.desktop "$PLASMOID_DIR/" || { echo -e "${RED}Failed to copy metadata.desktop${NC}"; exit 1; }
    else
        echo -e "${RED}metadata.desktop not found!${NC}"
        exit 1
    fi
fi

# Copy QML files
cp contents/ui/main.qml "$PLASMOID_DIR/contents/ui/" || { echo -e "${RED}Failed to copy main.qml${NC}"; exit 1; }
cp contents/ui/configGeneral.qml "$PLASMOID_DIR/contents/ui/" || { echo -e "${RED}Failed to copy configGeneral.qml${NC}"; exit 1; }

# Copy config files
mkdir -p "$PLASMOID_DIR/contents/config" || { echo -e "${RED}Failed to create config directory${NC}"; exit 1; }
cp contents/config/config.qml "$PLASMOID_DIR/contents/config/" || { echo -e "${RED}Failed to copy config.qml${NC}"; exit 1; }
cp contents/config/main.xml "$PLASMOID_DIR/contents/config/" || { echo -e "${RED}Failed to copy main.xml${NC}"; exit 1; }

echo -e "${GREEN}Widget files copied successfully!${NC}"

# Clean up
cd "$HOME"
rm -rf "$TEMP_DIR"

echo -e "${BLUE}Step 4: Installation complete!${NC}"
echo -e "${GREEN}The Islamic Widget has been successfully installed.${NC}"

# Ask user if they want to restart Plasma
echo -e "${YELLOW}Would you like to restart Plasma now to activate the widget? (y/n)${NC}"
read -r restart_choice

if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Restarting Plasma...${NC}"
    if [ "$PLASMA_VERSION" -ge "6" ]; then
        # Plasma 6 restart
        kquitapp6 plasmashell || killall plasmashell
        kstart plasmashell
    else
        # Plasma 5 restart
        kquitapp5 plasmashell || killall plasmashell
        kstart5 plasmashell
    fi
    echo -e "${GREEN}Plasma has been restarted.${NC}"
else
    echo -e "${YELLOW}You may need to restart your Plasma session later to see the widget.${NC}"
fi

echo -e "${BLUE}To add the widget, right-click on your desktop or panel,"
echo -e "select 'Add Widgets' and search for 'Islamic Widget'${NC}"

exit 0