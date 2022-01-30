# VOIP

VoIP services convert your voice into a digital signal that travels over the Internet. If you are calling a regular phone number, the signal is converted to a regular telephone signal before it reaches the destination. VoIP can allow you to make a call directly from a computer, a special VoIP phone, or a traditional phone connected to a special adapter.

## Mumble Server

If `Sandbox 1` was previously set in the Tor configuration file, it must be removed for Mumble functionality.

Install and configure murmur (mumble-server)
```sh
sudo ./setup.sh
```

TODO: To install uMurmur https://github.com/umurmur/umurmur/wiki/Building

## Mumble

From mumble manual page:

_Mumble is an open source, low-latency, high quality voice chat software primarily intended for use while gaming._

Read also [TPO TorifyHowTo](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Mumble) and [Whonix wiki](https://www.whonix.org/wiki/VoIP#Mumble_Client).

You can review mumble source code on its [git](https://github.com/mumble-voip/mumble) repository, but if you are installing from debian repositories, you can find the source code on [debian salsa](https://salsa.debian.org/pkg-voip-team/mumble).

### Security

[Whonix guide](https://www.whonix.org/wiki/VoIP#Mumble):
> Group chats pose a greater risk since there is no end-to-end encryption. This means if the server is compromised, all conversations are no longer private. However, if only two parties use Mumble for communications, then end-to-end encryption protects against this threat.
When one of the two communicating parties hosts a mumble server as a Tor onion service and the other party connects over Tor, encryption is already provided by Tor. This means Mumble's own encryption is not required and so long as a server password is set (see below), this configuration should be secure.

### Configure desktop client

Install mumble client:
```sh
sudo apt install -y mumble
```

Tor does not resolve UDP, so let's force TCP mode:
`Configure` -> `Settings` -> `Network` -> `Connection` -> `Force TCP mode`.

Connect to the onion mumble server, you must torify the client before it starts:
```sh
torsocks mumble
```

**Warning**: Do not use mumble proxy settings, it [does not work correctly](https://github.com/mumble-voip/mumble/issues/1812) as it tries to resolve the onion domain without the proxy leading to DNS leak. Leave `Direct conneciton` as the proxy type (default).

### Configure mobile client

For android, there is [Mumla](https://f-droid.org/packages/se.lublin.mumla/) ([git](https://gitlab.com/quite/mumla)), which the developer of this project has not audited, so use it at your own risk.

To connect to tor, use [Orbot](https://guardianproject.info/apps/org.torproject.android/) on VPN mode to tunnel Mula.

### Connect to server

If the server administrator runs the server on its local machine and also wants to connect to the server, then local (127.0.0.1) connections are recommended since it is faster than connecting to the onion service domain.

`Server` -> `Connect` -> `Add New`:
```sh
Address: domain.onion
Port: 64738
Username: anything
Label: anything
```
