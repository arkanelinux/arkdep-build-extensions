#
# This script is provided for reference and your convenience, but it is discouraged
# to actually use it for it will pollute your images with build dependencies.
#


# Set list of packages to install
# List is delimited with a +. first entry is package name, second is the git clone url
declare -r aur_packages=('paru-bin+https://aur.archlinux.org/paru-bin.git' 'yay-bin+https://aur.archlinux.org/yay-bin.git')

# Install build dependencies
printf '\e[1;32m-->\e[0m\e[1m Installing build dependencies\e[0m\n'
arch-chroot $workdir pacman -Sy --noconfirm --needed base-devel git

# Create temporary unpriviledged user, this is required for fakeroot
printf '\e[1;32m-->\e[0m\e[1m Creating temporary user\e[0m\n'
arch-chroot $workdir useradd aur -m -p '!'

for package in ${aur_packages[@]}; do

	readarray -d + -t pkginfo <<< "$package"

	pkginfo[0]=${pkginfo[0]//[$'\t\r\n']}
	pkginfo[1]=${pkginfo[1]//[$'\t\r\n']}

	# Build package
	printf "\e[1;32m-->\e[0m\e[1m Building ${pkginfo[0]}\e[0m\n"
	arch-chroot -u aur:aur $workdir bash -c "cd /home/aur && git clone '${pkginfo[1]}' && cd '${pkginfo[0]}' && makepkg -s --noconfirm"

	# Install package
	printf "\e[1;32m-->\e[0m\e[1m Installing ${pkginfo[0]}\e[0m\n"
	arch-chroot $workdir bash -c "pacman -U --noconfirm /home/aur/${pkginfo[0]}/*.pkg.tar.*"

done

# Cleanup
printf '\e[1;32m-->\e[0m\e[1m Performing cleanup\e[0m\n'
arch-chroot $workdir userdel -r aur
