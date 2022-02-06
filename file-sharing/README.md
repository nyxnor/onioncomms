# File sharing

Programs that faciliate file sharing over Tor.

---
Table of contents
---
- [File sharing](#file-sharing)
  - [Magic-Wormhole](#magic-wormhole)
    - [Usage Magic-Wormhole](#usage-magic-wormhole)
  - [OnionShare](#onionshare)
    - [Usage OnionShare](#usage-onionshare)
  - [Extras todo](#extras-todo)

---

## Magic-Wormhole

This package provides a library and a command-line tool named wormhole, which makes it possible to get arbitrary-sized files and directories (or short pieces of text) from one computer to another. The two endpoints are identified by using identical “wormhole codes”: in general, the sending machine generates and displays the code, which must then be typed into the receiving machine.

The codes are short and human-pronounceable, using a phonetically-distinct wordlist. The receiving side offers tab-completion on the codewords, so usually only a few characters must be typed. Wormhole codes are single-use and do not need to be memorized.

Install magic-wormhole:
```sh
sudo apt install -y magic-wormhole
```

### Usage Magic-Wormhole

From [wormhole tor docs](https://github.com/magic-wormhole/magic-wormhole/blob/master/docs/tor.md):
_You should use `--tor` rather than running wormhole under tsocks or torsocks because the magic-wormhole "Transit" protocol normally sends the IP addresses of each computer to its peer, to attempt a direct connection between the two (somewhat like the FTP protocol would do). External tor-ifying programs don't know about this, so they can't strip these addresses out. Using `--tor` puts magic-wormhole into a mode where it does not share any IP addresses._

_If wormhole is unable to establish a control-port connection to any of those locations, it will assume there is a SOCKS daemon listening on `tcp:localhost:9050`, and hope for the best (if no SOCKS daemon is available on that port, the initial Rendezvous connection will fail, and the program will exit with an error before doing anything else)._

Send file:
```
wormhole send --tor myfile.jpg
```

Receive files:
```
wormhole receive --tor
```

If tor is installed, but you cannot use the control-port or SOCKS-port for some reason, then you can use --launch-tor to ask wormhole to start a new Tor daemon for the duration of the transfer (and then shut it down afterwards). This will add 30-40 seconds to program startup.
```sh
wormhole send --tor --launch-tor myfile.jpg
```

Alternatively, if you know of a pre-existing Tor daemon with a non-standard control-port, you can specify that control port with the `--tor-control-port=` argument:
```sh
wormhole send --tor --tor-control-port=tcp:127.0.0.1:9251 myfile.jpg
```

Unfortunately, it [does not support onion services](https://github.com/magic-wormhole/magic-wormhole/blob/master/docs/tor.md#onion-servers) yet:

_In the future, wormhole with --tor will listen on an ephemeral "onion service" when file transfers are requested. If both sides are Tor-capable, this will allow transfers to take place "directly" (via the Tor network) from sender to receiver, bypassing the Transit Relay server. This will require access to a Tor control-port (to ask Tor to create a new ephemeral onion service). SOCKS-port access will not be sufficient._

_However the current version of wormhole does not use onion services. For now, if both sides use --tor, any file transfers must use the transit relay, since neither side will advertise any listening IP addresses._

## OnionShare

From [onionshare website](https://onionshare.org/)
_OnionShare is an open source tool that lets you securely and anonymously share files, host websites, and chat with friends using the Tor network._

By default, it creates ephemeral onion services that are never written to disk. To achieve this functionality, it uses the tor control protocol via the sepa library, fork of stem, to send commands to the controller and create the temporary service, that optionally can be marked as persistent. Every server can use ClientAuthorization to improve security with an extra key to be able to connect to the service.

OnionShare provide 4 categories of service:
- share files
- receiving files and optionally messages
- chat server
- hosting a static webpage

Instalation:
```sh
sudo apt install -y onionshare
```

### Usage OnionShare

Read more about its [features](https://docs.onionshare.org/2.5/en/features.html) and [advanced usage](https://docs.onionshare.org/2.5/en/advanced.html) on OnionShare website.



## Extras todo

https://github.com/hbons/SparkleShare

https://docs.securedrop.org/en/stable/install.html

https://github.com/freedomofpress/securedrop

https://github.com/glamrock/Stormy
