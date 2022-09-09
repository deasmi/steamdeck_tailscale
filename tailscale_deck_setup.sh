#!/usr/bin/env bash

# Based on https://tailscale.com/blog/steam-deck/

set -euo pipefail

cat <<EOF
We are going to setup Tailscale on your Steam Deck.

This can be used manually or set to run all the time
and restart on reboot.

This will require your deck user password as this needs to be 
done as the root user.

We are not opening the read-only seal, everything is kept in the
deck user home directory.
EOF

read -p "Do you want to continue? [Yy]" -n1 -r
if [[ ! $REPLY =~ [Yy]$ ]]; then
    exit
fi

source="$(pwd)"

dir="$(mktemp -d)"
pushd .
echo "${dir}"
cd "${dir}"

# Get the latest stable Tailscale tarball for amd64
tarball="$(curl 'https://pkgs.tailscale.com/stable/?mode=json' | jq -r .Tarballs.amd64)"
version="$(echo ${tarball} | cut -d_ -f2)"

echo
echo -n "Downloading the latest Tailscale binaries..."
# Download the latest Tailscale tarball for amd64
curl "https://pkgs.tailscale.com/stable/${tarball}" -o tailscale.tgz
echo

echo
echo -n "Extracting Tailscale binaries..."
# Extract the Tailscale tarball to tailscale/usr
mkdir -p tailscale/usr/{bin,sbin,lib/{systemd/system,extension-release.d}}
tar xzf tailscale.tgz
echo

echo
echo -n "Create necessary directories..."
# Create necessary binary and config directories
mkdir -p ~/bin
mkdir -p ~/.config/default
echo

echo
echo -n "Installing Tailscale binaries to ~/bin/..."
# Install Tailscale binaries to ~bin
cp -vrf "tailscale_${version}_amd64"/tailscale ~/bin/tailscale
sudo chown root:deck ~/bin/tailscale
sudo chmod 4750 ~/bin/tailscale
cp -vrf "tailscale_${version}_amd64"/tailscaled ~/bin/tailscaled
sudo chown root:deck ~/bin/tailscaled
sudo chmod 4750 ~/bin/tailscaled
# Create tailscaled systemd script from example script
cp -vrf "tailscale_${version}_amd64"/systemd/tailscaled.service ~/.config/systemd/user/tailscaled.service
cp -vrf ${source}/tailscaled.defaults ~/.config/default/tailscaled
echo

echo
echo -n "Configuring Tailscale systemd script..."
sed -i 's/--port.*//g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/etc\/default/\~\/.config\/default\/tailscale/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/sbin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/bin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/multi-user.target/default.target/g' ~/.config/systemd/user/tailscaled.service
echo

echo
echo -n "Calling systemctl --user daemon-reload...."
# Reload systemctl daemon to detect new tailscaled systemd script
systemctl --user daemon-reload
echo "Done"
echo

cat <<EOF
To start Tailscale, issue the following command:

systemctl --user start tailscaled

To make it start on boot, issue the following command:

systemctl --user --now enable tailscaled

Issue the following command to connect the first time:

~/bin/tailscale up --reset --accept-dns=false

--reset will make sure if you have run this before somehow you reset to defaults
--accpt-dns=false disables any dns management from Tailscale, I have had issue with cloud sync with this on

You will need to connect to the link provided in a web browser to login the first time.
EOF

popd
rm -rf "${dir}"
