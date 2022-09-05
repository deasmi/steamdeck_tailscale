#!/usr/bin/env bash

# Based on https://tailscale.com/blog/steam-deck/

set -euo pipefail

cat <<EOF
We are going to setup tailscale on your steam deck
This can be used manually or set to run all the time
and restart on reboot

This will require your decl user password as this needs to be 
done as the root user.

We are not opening the read only seal, everything is kept in the
deck user home directory
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

tarball="$(curl 'https://pkgs.tailscale.com/stable/?mode=json' | jq -r .Tarballs.amd64)"
version="$(echo ${tarball} | cut -d_ -f2)"

curl "https://pkgs.tailscale.com/stable/${tarball}" -o tailscale.tgz

mkdir -p tailscale/usr/{bin,sbin,lib/{systemd/system,extension-release.d}}
tar xzf tailscale.tgz

mkdir -p ~/bin
mkdir -p ~/.config/default

cp -vrf "tailscale_${version}_amd64"/tailscale ~/bin/tailscale
sudo chown root:deck ~/bin/tailscale
sudo chmod 4750 ~/bin/tailscale
cp -vrf "tailscale_${version}_amd64"/tailscaled ~/bin/tailscaled
sudo chown root:deck ~/bin/tailscaled
sudo chmod 4750 ~/bin/tailscaled
cp -vrf "tailscale_${version}_amd64"/systemd/tailscaled.service ~/.config/systemd/user/tailscaled.service
cp -vrf ${source}/tailscaled.defaults ~/.config/default/tailscaled

sed -i 's/--port.*//g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/etc\/default/\~\/.config\/default\/tailscale/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/sbin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/bin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/multi-user.target/default.target/g' ~/.config/systemd/user/tailscaled.service

echo
echo -n "Calling systemctl --user daemon-reload...."
systemctl --user daemon-reload
echo "done"
echo

cat <<EOF
To start tailscale one issue the following command
systemctl --user start tailscaled

To make it start always the issue the following command
systemctl --user --now enable tailscaled

Then the following to connect the first time
~/bin/tailscale up --reset --accept-dns=false
--reset will make sure if you have run this before somehow you reset to defaults
--accpt-dns=false disables any dns managemnet from tailscale, I have had issue with cloud sync with this on
You will need to connect to the link provided in a web browser to login first time
EOF

popd
rm -rf "${dir}"
