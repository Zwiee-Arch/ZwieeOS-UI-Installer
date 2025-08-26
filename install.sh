#!/bin/bash

# Script tự động cài đặt giao diện cho Arch Linux

echo "
_____         _           _       _____           _     
|__  /_      _(_) ___  ___( )___  |_   _|__   ___ | |___ 
  / /\ \ /\ / / |/ _ \/ _ \// __|   | |/ _ \ / _ \| / __|
 / /_ \ V  V /| |  __/  __/ \__ \   | | (_) | (_) | \__ \
/____| \_/\_/ |_|\___|\___| |___/   |_|\___/ \___/|_|___/
"

echo "Chào mừng bạn đã đến với trình cài đặt "UI" dễ nhất do Zwiee tạo ra,"
echo "với 1 vài bộ dotfiles mình thấy là đẹp."
echo ""
echo "Mời bạn chọn "UI" mà bạn thích dùng:"
echo "-----------------------------------"
echo "1) xfce4"
echo "2) kde-plasma-manjaro"
echo "3) gnome"
echo "4) awesome-vm"
echo "0) Thoát"
echo "-----------------------------------"
read -p "Nhập lựa chọn của bạn (0-4): " choice

if [ "$choice" == "0" ]; then
    echo "Đã thoát khỏi script. Chúc bạn một ngày tốt lành!"
    exit 0
fi

case $choice in
    1)
        echo "Đang cài đặt xfce4..."
        pacman -S --noconfirm xfce4 xfce4-goodies
        pacman -S --noconfirm lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    2)
        echo "Đang cài đặt kde-plasma-manjaro..."
        pacman -S --noconfirm plasma kde-applications
        pacman -S --noconfirm sddm
        systemctl enable sddm
        ;;
    3)
        echo "Đang cài đặt gnome..."
        echo "Vui lòng chọn kiểu cài đặt gnome:"
        echo "-----------------------------------"
        echo "1: gnome-original"
        echo "2: gnome-macos-looklike"
        echo "-----------------------------------"
        read -p "Nhập lựa chọn của bạn (1-2): " gnome_choice

        case $gnome_choice in
            1)
                echo "Đang cài đặt gnome-original..."
                pacman -S --noconfirm gnome gnome-extra
                pacman -S --noconfirm gdm
                systemctl enable gdm
                ;;
            2)
                echo "Đang cài đặt gnome-macos-looklike..."
                pacman -S --noconfirm gnome gnome-extra git
                echo "Bạn cần cài đặt các theme GTK, Icon và Extensions thủ công sau khi cài đặt xong."
                echo "Xem file README (3).md để biết thêm chi tiết."
                pacman -S --noconfirm gdm
                systemctl enable gdm
                ;;
            *)
                echo "Lựa chọn không hợp lệ."
                exit 1
                ;;
        esac
        ;;
    4)
        echo "Đang cài đặt awesome-vm..."
        echo "Vui lòng chọn kiểu cài đặt awesome-vm:"
        echo "-----------------------------------"
        echo "1: awesomevm-original"
        echo "2: awesomevm-with-pre-dotfiles"
        echo "-----------------------------------"
        read -p "Nhập lựa chọn của bạn (1-2): " awesome_choice

        case $awesome_choice in
            1)
                echo "Đang cài đặt awesomevm-original..."
                pacman -S --noconfirm awesome xorg xorg-init lightdm lightdm-gtk-greeter
                systemctl enable lightdm
                ;;
            2)
                echo "Đang cài đặt awesomevm-with-pre-dotfiles..."
                pacman -S --noconfirm xorg xorg-init git tar
                if ! command -v yay &> /dev/null
                then
                    echo "Cài đặt yay để cài các gói từ AUR..."
                    git clone https://aur.archlinux.org/yay.git
                    cd yay
                    makepkg -si --noconfirm
                    cd ..
                    rm -rf yay
                fi

                yay -S --noconfirm picom-git awesome-git acpid git mpd ncmpcpp wmctrl firefox lxappearance gucharmap thunar alacritty neovim polkit-gnome xdotool xclip scrot brightnessctl alsa-utils pulseaudio jq acpi rofi inotify-tools zsh mpdris2 bluez bluez-utils bluez-plugins acpi acpi_call playerctl redshift cutefish-cursor-themes-git cutefish-icons upower xorg xorg-init tar

                git clone --recurse-submodules https://github.com/saimoomedits/dotfiles.git
                cd dotfiles
                cp -rf .config/* ~/.config/
                cp -rf extras/mpd ~/.mpd
                cp -rf extras/ncmpcpp ~/.ncmpcpp
                cp -rf extras/fonts ~/.fonts
                cp -rf extras/scripts ~/.scripts
                cp -rf extras/oh-my-zsh ~/.oh-my-zsh

                mkdir ~/.themes
                cp ./themes/* ~/.themes/
                cd ~/.themes
                tar -xf Awesthetic.tar
                tar -xf Cutefish-light-modified.tar
                rm Awesthetic.tar Cutefish-light-modified.tar
                cd ~

                sudo chmod -R +x ~/.config/awesome/misc/*
                systemctl --user enable mpd
                sudo systemctl enable bluetooth
                
                pacman -S --noconfirm lightdm lightdm-gtk-greeter
                systemctl enable lightdm
                ;;
            *)
                echo "Lựa chọn không hợp lệ."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Lựa chọn không hợp lệ. Vui lòng chạy lại script."
        exit 1
        ;;
esac

echo "Quá trình cài đặt đã hoàn tất! Vui lòng khởi động lại hệ thống."
