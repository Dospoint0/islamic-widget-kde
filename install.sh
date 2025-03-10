#!/bin/bash

# Islamic Widget for KDE Plasma Installation Script
# ------------------------------------------------

echo "Islamic Widget for KDE Plasma - Installation Script"
echo "=================================================="
echo

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


REPO_URL="https://github.com/Dospoint0/Islamic-Widget-KDE.git"
REPO_NAME="Islamic-Widget-KDE"
PLASMOID_NAME="org.kde.plasma.islamicwidget"
PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_NAME"

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
mkdir -p "$PLASMOID_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create plasmoid directory${NC}"
    exit 1
fi
echo -e "${GREEN}Installation directory created: $PLASMOID_DIR${NC}"

echo -e "${BLUE}Step 3: Copying widget files...${NC}"
# Copy metadata.desktop
cp metadata.json "$PLASMOID_DIR/" || { echo -e "${RED}Failed to copy metadata.json${NC}"; exit 1; }

# Copy contents directory
if [ -d "contents" ]; then
    cp -r contents "$PLASMOID_DIR/" || { echo -e "${RED}Failed to copy contents directory${NC}"; exit 1; }
else
    mkdir -p "$PLASMOID_DIR/contents/ui"
    
    # If the repo structure is different, try to locate the QML files
    if [ -f "main.qml" ]; then
        cp main.qml "$PLASMOID_DIR/contents/ui/" || { echo -e "${RED}Failed to copy main.qml${NC}"; exit 1; }
    fi
    
    if [ -f "configGeneral.qml" ]; then
        cp configGeneral.qml "$PLASMOID_DIR/contents/ui/" || { echo -e "${RED}Failed to copy configGeneral.qml${NC}"; exit 1; }
    fi
fi

echo -e "${GREEN}Widget files copied successfully!${NC}"

# Clean up
cd "$HOME"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}Temporary files cleaned up${NC}"

echo -e "${BLUE}Step 4: Installation completed!${NC}"
echo -e "${YELLOW}Do you want to restart the Plasma shell to apply changes? (y/n)${NC}"
read -r restart_choice

if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Restarting Plasma shell...${NC}"
    kquitapp5 plasmashell || killall plasmashell
    kstart5 plasmashell
    echo -e "${GREEN}Plasma shell restarted!${NC}"
    echo
    echo -e "${BLUE}How to add the widget:${NC}"
    echo "1. Right-click on your desktop"
    echo "2. Select 'Add Widgets'"
    echo "3. Find 'Islamic Widget' in the list"
    echo "4. Drag it to your desktop or panel"
else
    echo
    echo -e "${YELLOW}Please log out and log back in, or restart Plasma manually using:${NC}"
    echo "kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell"
    echo
    echo -e "${BLUE}After restarting, add the widget by:${NC}"
    echo "1. Right-click on your desktop"
    echo "2. Select 'Add Widgets'"
    echo "3. Find 'Islamic Widget' in the list"
    echo "4. Drag it to your desktop or panel"
fi

echo
echo -e "${GREEN}Installation complete! Enjoy your Islamic Widget!${NC}"