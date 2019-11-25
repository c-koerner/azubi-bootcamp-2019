#!/bin/bash

# -----------------------------------------------------------------------------
# CHECK ADMIN PERMISSIONS
# -----------------------------------------------------------------------------

if [[ "$(uname -s)" == "Darwin" ]]; then

	echo 🛡 testing admin permissions

	if ! id -Gn | grep -q -w admin; then
		if [ -d /Applications/AS-Tools/Adminrechte.app/ ]; then #
			echo -e "\n${RED}ATTENTION: You need admin rights on your system before executing this script."
			open --wait-apps /Applications/AS-Tools/Adminrechte.app # wait for closing app
		else
			echo "❌ Please run Adminrechte tool to ensure admin permissions."
			exit 1
		fi
	fi

	echo 🐌 setting up XCode commandline tools

	# -----------------------------------------------------------------------------
	# Ensures XCode cmdline tools are installed, required for brew to run
	# -----------------------------------------------------------------------------
	if ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables >/dev/null 2>&1; then
		# XCode commandline tools are apparently not installed but needed for brew
		xcode-select --install
		# FIXME: find out if xcode-select can run in foreground until its done
		read -r -p "Press enter to continue when XCode cmdline is configured properly"
	fi

	# -----------------------------------------------------------------------------
	# INSTALLING HOMEBREW
	# -----------------------------------------------------------------------------

	echo 💾 installing brew - the MacOS package manager

	if [ ! -f /usr/local/bin/brew ]; then

		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	fi

	echo ☕️ updating brew package lists

	brew update >/dev/null

	# -----------------------------------------------------------------------------
	# install or update brew packages
	# -----------------------------------------------------------------------------

	echo 💾 installing mandatory brew packages

	export HOMEBREW_NO_INSTALL_CLEANUP=1
	export HOMEBREW_NO_AUTO_UPDATE=1
	brew bundle --file=../Brewfile

else
	sudo apt-get update
	sudo apt-get install -y awscli unzip bats wget
	TER_VER="0.12.14"
	wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
	unzip terraform_${TER_VER}_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
fi

# -----------------------------------------------------------------------------
# setting up awscli
# -----------------------------------------------------------------------------

echo ☁️ setting up awscli

mkdir -p "$HOME/.aws"
touch ${HOME}/.aws/config ${HOME}/.aws/credentials

aws configure set profile.as-aws-training.region eu-central-1

# -----------------------------------------------------------------------------
# performing final tests
# -----------------------------------------------------------------------------

echo Testing if everything works as expected ...
bats tests.bats