#!/bin/bash

# Enable NOPASSWD Sudo
su -c "echo \"$USER ALL=(ALL:ALL) NOPASSWD: ALL\" | EDITOR=\"tee -a\" visudo"

# Make screen brightness changeable
sudo chmod a+rw /sys/class/backlight/intel_backlight/brightness

# Remove original picom
sudo pacman -Rs --noconfirm picom

# Install packages
sudo pacman -S --noconfirm lightdm-webkit2-greeter light pulsemixer zsh flameshot kitty vim exa bat wmctrl ttf-joypixels

AUR_PKGS=(
	"nerd-fonts-jetbrains-mono" # JetBrains Mono Nerd Font
	"ttf-poppins" # Poppins font
	"picom-ibhagwan-git" # Picom compositor
	"brave-bin" # Brave Browser
)

for aurpkg in "${AUR_PKGS[@]}"; do
	git clone https://aur.archlinux.org/$aurpkg.git
	cd $aurpkg
	yes | makepkg -si
	cd ..
	rm -rf $aurpkg
done

# Install LightDM Aether theme
git clone https://github.com/NoiSek/Aether.git
sudo cp --recursive Aether /usr/share/lightdm-webkit/themes/
rm -rf Aether
sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
sudo ln -s /usr/share/lightdm-webkit/themes/Aether /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
sudo sed -i "s/greeter-session=lightdm-slick-greeter/greeter-session=lightdm-webkit2-greeter/g" /etc/lightdm/lightdm.conf
sudo cp /usr/share/lightdm-webkit/themes/Aether/src/img/default-user.png /var/lib/AccountsService/icons/$USER
sudo sed -i "s/Icon=\/home\/$USER\/.face/Icon=\/var\/lib\/AccountsService\/icons\/$USER/g" /var/lib/AccountsService/users/$USER

# Change default shell to ZSH
sudo chsh -s /bin/zsh $USER

# Configure BSPWM & SXHKD
rm -rf $HOME/.config/bspwm
rm -rf $HOME/.config/sxhkd
mv $HOME/eos-customizer/dotfiles/bspwm $HOME/.config/
mv $HOME/eos-customizer/dotfiles/sxhkd $HOME/.config/

mv $HOME/eos-customizer/dotfiles/wallpapers $HOME/.config/

sudo find $HOME/.config/bspwm -type f -exec chmod +x {} \;
sudo find $HOME/.config/sxhkd -type f -exec chmod +x {} \;

# Configure ZSH
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting
mv $HOME/eos-customizer/dotfiles/.zshrc $HOME/

# Configure Bash
mv $HOME/eos-customizer/dotfiles/.bashrc $HOME/

# Configure VIM
curl -fLso ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mv $HOME/eos-customizer/dotfiles/.vimrc $HOME/

# Configure Rofi
rm -rf $HOME/.config/rofi
mv $HOME/eos-customizer/dotfiles/rofi $HOME/.config/

# Configure Kitty
mv $HOME/eos-customizer/dotfiles/kitty $HOME/.config/

# Configure Picom 
mv $HOME/eos-customizer/dotfiles/picom.conf $HOME/.config/

# Configure Polybar
rm -rf $HOME/.config/polybar
mv $HOME/eos-customizer/dotfiles/polybar $HOME/.config/

for script in $HOME/.config/polybar/scripts/*; do
    sudo chmod +x $script
done

# Install Arabic font
unzip $HOME/eos-customizer/khebrat-musamim.zip
rm $HOME/eos-customizer/khebrat-musamim.zip
sudo mkdir -p /usr/share/fonts/TTF
sudo mv "$HOME/eos-customizer/18 Khebrat Musamim Regular.ttf" /usr/share/fonts/TTF/

sudo mv $HOME/eos-customizer/dotfiles/fonts.conf /etc/fonts/
sudo cp /etc/fonts/fonts.conf /etc/fonts/local.conf

# Install GRUB theme
sudo mkdir -p /boot/grub/themes
sudo mkdir /boot/grub/themes/endeavourOS
sudo mv endeavourOS.tar /boot/grub/themes/endeavourOS/
sudo tar xf /boot/grub/themes/endeavourOS/endeavourOS.tar -C /boot/grub/themes/endeavourOS/
sudo rm /boot/grub/themes/endeavourOS/endeavourOS.tar
sudo sed -i "s/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/g" /etc/default/grub
sudo sed -i "s/GRUB_THEME=\/boot\/grub\/themes\/EndeavourOS\/theme.txt/GRUB_THEME=\"\/boot\/grub\/themes\/endeavourOS\/theme.txt\"/g" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install cursor
tar -xf $HOME/eos-customizer/macOSBigSur.tar.gz
sudo mv $HOME/eos-customizer/macOSBigSur /usr/share/icons/
rm -rf $HOME/eos-customizer/macOSBigSur.tar.gz

sudo sed -i "s/Inherits=Adwaita/Inherits=macOSBigSur/g" /usr/share/icons/default/index.theme

# Remove script directory
rm -rf $HOME/eos-customizer
