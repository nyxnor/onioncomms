# OnionComms

OnionComms is a repository for hosting sripts to configure a chat server to run as an onion service, therefore, onion communications.

The scripts are posix compliant but they were built for Debian and derived systems due to some configuration files dependency on operating system and service manager.

## Server configuration

Read the readme inside the folder of the program you want to use.

## Client configuration

### Desktop

In order for your client to work, you need to route through tor the client application. For this, configure a TCP socket SocksPort on your Tor configuration file. For example:
```sh
SocksPort 9050
```
And on the client application, normally on `Network` -> `Proxy`, setup `SOCKS5` proxy with `Address: 127.0.0.1` and `Port: 9050`.

If the application does not support configuring a proxy or even if it says it support but it is [broken as it happens with mumble](https://github.com/mumble-voip/mumble/issues/1812), torify the application (e.g.: mumble client):
```sh
torsocks mumble
```

### Mobile

On android, configure [Orbot](https://guardianproject.info/apps/org.torproject.android/) to proxy the client application with Tor.

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