#!/usr/bin/env bash

# Set up odds and ends on a new Mac system


# Check for Homebrew to be present, install if it's missing
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# Update homebrew recipes
brew update

PACKAGES=(
    git
    gh
    zsh
	cmake
)
echo "Installing packages..."
brew install ${PACKAGES[@]}

echo "Installing cask..."
CASKS=(
    iterm2
    macvim
    adobe-acrobat-reader
    visual-studio-code
    evernote
    macdown
	todoist
	eqmac
	spotify
)
echo "Installing cask apps..."
brew install --cask ${CASKS[@]}

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Configuring OS..."
# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
