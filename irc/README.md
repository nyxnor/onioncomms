# IRC

From [Wikipedia](https://en.wikipedia.org/wiki/Internet_Relay_Chat):

_Internet Relay Chat (IRC) is a text-based chat (instant messaging) system. IRC is designed for group communication in discussion forums, called channels, but also allows one-on-one communication via private messages as well as chat and data transfer, including file sharing. IRC is an open protocol that uses TCP and, optionally, TLS. An IRC server can connect to other IRC servers to expand the IRC network. Users access IRC networks by connecting a client to a server._

---
Table of contents
---
- [IRC](#irc)
  - [HexChat](#hexchat)
  - [Irssi](#irssi)
    - [Torsocks](#torsocks)
    - [MapAddress](#mapaddress)

---

## HexChat

From hexchat site page:

_HexChat is an IRC client based on XChat, but unlike XChat it’s completely free for both Windows and Unix-like systems. Since XChat is open source, it’s perfectly legal. For more info, please read the Shareware background._

Read also [TPO TorifyHowTO](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/HexChat) and [Whonix wiki](https://www.whonix.org/wiki/HexChat).

```sh
sudo apt install -y hexchat hexchat-otr
```

When the chat window opens, click the `Settings` drop-down menu on the toolbar and select `Preferences`, then select `Network Setup` from the leftside menu. Configure `Proxy server` with your SOCKS infromation.


## Irssi

From irssi manual page:

_Irssi  is  a  modular  Internet Relay Chat client; it is highly extensible and very secure. Being a fullscreen, termcap based client with many features, Irssi is easily extensible through scripts and modules._

Read also [TPO TorifyHowTO](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/irssi).

Install irssi:
```sh
sudo apt install -y irssi
```

### Torsocks

Torify irssi:
```
torsocks irssi
```

### MapAddress

Or without Torsocks, use MapAddress on your torrc. This will allow you to connect to the local 10.10.x address directly, and Tor will translate it to the desired address. Note: The map address is generic, though it must be one not in use on your local network.
```
MapAddress 10.10.10.10 examplesite.onion
```
Then start irssi as you normally would.

