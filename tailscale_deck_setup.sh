#!/usr/bin/env bash

# Based on https://tailscale.com/blog/steam-deck/

set -euo pipefail

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
cp -vrf "tailscale_${version}_amd64"/systemd/tailscaled.defaults ~/.config/default/tailscale

sed -i 's/--port.*//g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/etc\/default/\~\/.config\/default\/tailscale/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/sbin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/\/usr\/bin/\/home\/deck\/bin/g' ~/.config/systemd/user/tailscaled.service
sed -i 's/multi-user.target/default.target/g' ~/.config/systemd/user/tailscaled.service

popd
rm -rf "${dir}"
