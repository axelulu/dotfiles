#!/bin/bash

# Update and upgrade Homebrew
echo "Updating Homebrew..."
brew update
brew upgrade

# Install essential packages
echo "Installing essential packages..."
brew install git
brew install wget
brew install zsh
brew install vim
brew install lua
brew install switchaudio-osx
brew install nowplaying-cli
brew install node
brew install python

# Install cask applications
echo "Installing applications..."
brew install --cask google-chrome
brew install --cask visual-studio-code
brew install --cask iterm2
brew install --cask slack
brew install --cask sf-symbols
brew install --cask homebrew/cask-fonts/font-sf-mono
brew install --cask homebrew/cask-fonts/font-sf-pro

# Set up Zsh as the default shell
echo "Setting up Zsh as the default shell..."
chsh -s /bin/zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set up Git configuration
echo "Setting up Git configuration..."
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "vim"

# Install Starship prompt
echo "Installing Starship prompt..."
brew install starship

# Install additional tools
echo "Installing additional tools..."
brew tap FelixKratz/formulae
brew install sketchybar
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Clone configuration repository
echo "Cloning configuration repository..."
git clone https://github.com/yourusername/dotfiles.git $HOME/.config

# Apply configurations
echo "Applying configurations..."
cp $HOME/.config/starship.toml $HOME/.config/starship.toml
cp $HOME/.config/zshrc $HOME/.zshrc
cp $HOME/.config/sketchy_bottombar/sketchybarrc $HOME/.config/sketchy_bottombar/sketchybarrc

# Source .zshrc to apply changes
echo "Sourcing .zshrc..."
source $HOME/.zshrc

# Clean up
echo "Cleaning up..."
brew cleanup

echo "Configuration complete!"