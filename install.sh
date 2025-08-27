#!/bin/bash

# Script tự động cài đặt giao diện cho Arch Linux

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Lỗi: Script này phải được chạy với quyền root. Vui lòng sử dụng sudo."
   exit 1
fi

echo "
_____         _           _       _____           _     
|__  /_      _(_) ___  ___( )___  |_   _|__   ___ | |___ 
  / /\ \ /\ / / |/ _ \/ _ \// __|   | |/ _ \ / _ \| / __|
 / /_ \ V  V /| |  __/  __/ \__ \   | | (_) | (_) | \__ \
/____| \_/\_/ |_|\___|\___| |___/   |_|\___/ \___/|_|___/
"

echo "Chào mừng bạn đã đến với trình cài đặt "UI" dễ nhất do Zwiee tạo ra,"
echo "với một vài bộ dotfiles mình thấy là đẹp."
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

# Tạm thời gán quyền cho người dùng thường
NORMAL_USER_NAME=$(logname)

if [ "$choice" == "0" ]; then
    echo "Đã thoát khỏi script. Chúc bạn một ngày tốt lành!"
    exit 0
fi

case $choice in
    1)
        echo "Đang cài đặt xfce4..."
        pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    2)
        echo "Đang cài đặt kde-plasma-manjaro..."
        pacman -S --noconfirm plasma kde-applications sddm
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
                pacman -S --noconfirm gnome gnome-extra gdm
                systemctl enable gdm
                ;;
            2)
                echo "Đang cài đặt gnome-macos-looklike..."
                pacman -S --noconfirm gnome gnome-extra gdm git
                echo "Bạn cần cài đặt các theme GTK, Icon và Extensions thủ công sau khi cài đặt xong."
                echo "Vui lòng tham khảo file hướng dẫn đi kèm để biết thêm chi tiết."
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
                
                # Kiểm tra và cài đặt yay nếu chưa có
                if ! command -v yay &> /dev/null; then
                    echo "Cài đặt yay để cài các gói từ AUR..."
                    su - "$NORMAL_USER_NAME" -c "git clone https://aur.archlinux.org/yay.git"
                    su - "$NORMAL_USER_NAME" -c "cd yay && makepkg -si --noconfirm"
                    su - "$NORMAL_USER_NAME" -c "rm -rf yay"
                fi

                yay_packages="picom-git awesome-git acpid git mpd ncmpcpp wmctrl firefox lxappearance gucharmap thunar alacritty neovim polkit-gnome xdotool xclip scrot brightnessctl alsa-utils pulseaudio jq acpi rofi inotify-tools zsh mpdris2 bluez bluez-utils bluez-plugins acpi_call playerctl redshift cutefish-cursor-themes-git cutefish-icons upower"
                echo "Đang cài đặt các gói từ AUR và repo..."
                su - "$NORMAL_USER_NAME" -c "yay -S --noconfirm $yay_packages"

                # Kiểm tra thư mục dotfiles đã tồn tại
                if [ ! -d "dotfiles" ]; then
                    su - "$NORMAL_USER_NAME" -c "git clone --recurse-submodules https://github.com/saimoomedits/dotfiles.git"
                else
                    echo "Thư mục dotfiles đã tồn tại, bỏ qua bước git clone."
                fi
                
                # Cảnh báo và xác nhận trước khi sao chép
                echo ""
                echo "Cảnh báo: Việc này sẽ ghi đè các file cấu hình hiện có của bạn."
                read -p "Bạn có chắc chắn muốn tiếp tục không? (y/n): " confirm
                if [[ $confirm != "y" ]]; then
                    echo "Đã hủy quá trình cài đặt dotfiles."
                    exit 0
                fi
                echo ""

                echo "Đang sao chép các dotfiles..."
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/.config/* ~/.config/"
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/extras/mpd ~/.mpd"
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/extras/ncmpcpp ~/.ncmpcpp"
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/extras/fonts ~/.fonts"
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/extras/scripts ~/.scripts"
                su - "$NORMAL_USER_NAME" -c "cp -rf dotfiles/extras/oh-my-zsh ~/.oh-my-zsh"
                
                echo "Đang giải nén và di chuyển theme..."
                su - "$NORMAL_USER_NAME" -c "mkdir -p ~/.themes"
                su - "$NORMAL_USER_NAME" -c "tar -xf dotfiles/themes/Awesthetic.tar -C ~/.themes/"
                su - "$NORMAL_USER_NAME" -c "tar -xf dotfiles/themes/Cutefish-light-modified.tar -C ~/.themes/"
                
                echo "Đang kích hoạt các dịch vụ..."
                su - "$NORMAL_USER_NAME" -c "chmod -R +x ~/.config/awesome/misc/*"
                su - "$NORMAL_USER_NAME" -c "systemctl --user enable mpd"
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
