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

## Protocols

Only Mumble (VoIP) and Prosody (XMPP) scripts are complete.

### VOIP

* Mumble
* Asterisk

### XMPP

* Prosody
* Ejabberd

### Ricochet

* Ricochet-refresh