# OnionComms

OnionComms is a repository for scripts to configure a chat server to run as an onion service and guides to configure client side applications to route packets through Tor, therefore, onion communications.

The scripts are posix compliant but they were built for Debian and derived systems due to:
- configuration files not being host agnostic for some programs
- service manager to be used to signal the programs that need to be restarted and reloaded
- package name may differ on different systems as well as the package manager being used

Nonetheless, this should not discourage you from porting to any other *nix system.

## Server configuration

Read the README.md inside the folder of the program you want to use.

## Client configuration

Read [TORIFICATION.MD](https://github.com/nyxnor/onioncomms/blob/main/TORIFICATION.md).

## Applications

Some applications

### [tor](./tor)

Application|Client|Server
-|-|-
tor|yes|yes
torsocks|yes|no
Tor Browser|yes|no
Orbot|yes|no

### [Remote-Administration](./remote-administration)

Application|Client|Server
-|-|-
ssh|yes|no
sshd|no|yes
Remmina|yes|yes

TODO: Remmina guide is incomplete.

### [File-Sharing](./file-sharing)

Application|Client|Server
-|-|-
Magic-wormhole|yes|yes
OnionShare|no|yes

### [RSS](./rss)

Application|Client|Server
-|-|-
Newsboat|yes|no
QuiteRSS|yes|no

### [VOIP](./voip)

Application|Client|Server
-|-|-
Mumble|yes|no|
Mumble-server|no|yes|
Asterisk|yes|no|

TODO: Asterisk guide is incomplete.

## [XMPP](./voip)

Application|Client|Server
-|-|-
Prosody|no|yes|
Ejabberd|no|yes|
Pidgin|yes|no|
Dino IM|yes|no|

TODO: Every XMPP client guide is incomplete.

## [IRC](./irc)

Application|Client|Server
-|-|-
Hexchat|yes|no|
Irssi|yes|no|

## [Misc](misc)

Application|Client|Server
-|-|-
apt|yes|no|
wget|yes|no|
cURL|yes|no|
git|yes|no|
gpg|yes|no|
Ricochet-refresh|yes|yes|
TEG|yes|no|

TODO: TEG guide is incomplete.