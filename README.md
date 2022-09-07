# Steam Deck Tailscale setup script

**IMPORTANT: This is alpha-level at the moment, it starts Tailscale and it survives reboots. However, there is no configuration/guide for how to use tailscale so YMMV**

[Tailscale](https://tailscale.com) is a zero-config VPN networking solution based on the Wireguard protocol.

This script will setup Tailscale on your Steam Deck to be persistent, ensuring that Tailscale starts properly on reboots (even after system updates).

## Installation

Clone this repo into a directory then run :

`./tailscale_deck_setup.sh`

- You will need to enter your `deck` user password as file ownership/suid changes need root
- It uses systemctl user mode

## Notes/FAQ

> **You are using root suid files, isn't that a bad idea?**  

Yes, if you are running enterprise linux that's probably not the best
idea, this is a Steam Deck.
The executables are only readable/executable by members of the deck group, of which
the deck user is the only member.

> **Shouldn't you be using ${HOME} in those sed commands?**  

Probably, but I couldn't be bothered to work out how to escape the shell expansion

