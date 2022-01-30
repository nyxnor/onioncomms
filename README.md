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

[TORIFICATION.MD](https://github.com/nyxnor/onioncomms/blob/main/TORIFICATION.md) is a must read on how to do properly torifications of applications. In short:
- application proxy settings may fail and leak DNS requests and IP address (per application)
- enforce proxy with a wrapper may also fail if not using the libc and leak DNS requests and IP address (torsocks, orbot)
- transparent proxy has huge security problems, it does not protect agains protocol leaks but the IP address will never be revealed (Tails)
- isolating proxy is the best solution as no leaks occur but it requires two host (virtual or physical) (Whonix)

The client guides are intended for plain Debian users, therefore application proxy settings and enforcing a proxy with a wrapper is the only solution, which isn't great but it is what is available.

Transparent proxy is hard to configure system wide and isolating proxy requires advanced configuration of creating a network between two hosts, these methods already route everything through Tor, so you don't need to configure the client to have onion routing, as all the traffic already does. What may change are simple configurations such as enforcing TCP mode or "hardening" by removing some "bad features" that leaks protocol information.

## Applications

Some applications

### [tor](tor)

Application|Client|Server
-|-|-
[tor](tor#tor)|yes|yes
[torsocks](tor#torsocks)|yes|no
[Tor Browser](tor#tor-browser)|yes|no
[Orbot](tor#orbot)|yes|no

### [Remote-Administration](remote-administration)

Application|Client|Server
-|-|-
[OpenSSH client](remote-administration#openssh-client)|yes|no
[OpenSSH server](remote-administration#openssh-server)|no|yes
[Remmina](remote-administration#remmina)|yes|yes

TODO: Remmina guide is incomplete.

### [File-Sharing](file-sharing)

Application|Client|Server
-|-|-
[Magic-wormhole](file-sharing#magic-wormhole)|yes|yes
[OnionShare](file-sharing#onionshare)|no|yes

### [RSS](rss)

Application|Client|Server
-|-|-
[Newsboat](rss#newsboat)|yes|no
[QuiteRSS](rss#quiterss)|yes|no

### [VOIP](voip)

Application|Client|Server
-|-|-
[Mumble](voip#mumble)|yes|no|
[Mumble-server](voip#mumble-server)|no|yes|

### [XMPP](xmpp)

Application|Client|Server
-|-|-
[Prosody](xmpp/prosody)|no|yes|
[Ejabberd](xmpp/ejabberd)|no|yes|
[Pidgin](xmpp#clients)|yes|no|
[Dino IM](xmpp#clients)|yes|no|

TODO: Every XMPP client guide is incomplete.

### [IRC](irc)

Application|Client|Server
-|-|-
[Hexchat](irc#hexchat)|yes|no|
[Irssi](irc#irssi)|yes|no|

### [Misc](misc)

Application|Client|Server
-|-|-
[apt](misc#apt)|yes|no|
[wget](misc#wget)|yes|no|
[cURL](misc#curl)|yes|no|
[git](misc#git)|yes|no|
[gpg](misc#gpg)|yes|no|
[Ricochet-refresh](misc#ricochet-refresh)|yes|yes|
[TEG](misc#teg)|yes|no|

TODO: TEG guide is incomplete.