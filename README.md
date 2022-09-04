Steam Deck tailscale setup script
=================================

This script will setup tailscale on your steam deck to be persistent, that is
it will start on ever boot.

Clone this repo into a directory then run  
`./tailscale_deck_setup.sh`

You will need to enter you password as file ownership/suid changes need root

It uses systemctl user mode

Notes/FAQ

**You are using root suid files, isn't that a bad idea?**  
Yes, if you are running enterprise linux that's probably not the best
idea, this is a Steam Deck.
The executables are only readable/exectuable by members of the deck group, of which
the deck user is the only members.

**Shouldn't you be using ${HOME} in those sed commands?**  
Probably, but I couldn't be bothered to work out how to escape the shell expansion

