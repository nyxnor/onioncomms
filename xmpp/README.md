# XMPP

Definition from [xmpp.org](https://xmpp.org/about/):

_Extensible Messaging and Presence Protocol (XMPP) is an open XML technology for real-time communication, which powers a wide range of applications including instant messaging, presence and collaboration._

---
Table of contents
---
- [XMPP](#xmpp)
  - [Servers](#servers)
  - [Clients](#clients)
    - [Profanity](#profanity)
    - [Psi-plus](#psi-plus)
    - [Dino-im](#dino-im)
    - [Gajim](#gajim)
    - [Pidgin](#pidgin)
    - [Conversations](#conversations)
    - [Extra](#extra)
    - [Encryption](#encryption)

---

## Servers

Two servers are available, [Prosody](prosody) and [Ejabberd](ejabberd).

## Clients

Full list of clients can be found  https://xmpp.org/software/clients/

Client|Platform|Omemo|OTR|OpenPGP
-|-|-|-|-
Profanity|Linux, FreeBSD, OpenBSD, OSX, Windows and Android (Termux)|yes|yes|yes
Gajim|Linux / Windows|yes|no|yes
Dino IM|Linux|yes|no
Psi+|Linux / macOS / Other / Windows|yes|yes|yes
Pidgin|Linux / macOS / Other / Windows|no|yes
Adium|macOS|no|yes|no
Conversations|Android|yes|no

### Profanity

[Profanity](https://profanity-im.github.io/guide/latest/install.html) - [git](https://profanity-im.github.io/)

Profanity is a terminal client, for advanced users.

Install profanity:
```sh
sudo apt install -y profanity
```

Torsocksify profanity:
```sh
torsocks profanity
```

To connect to an onion server with authentication required and the certificated is self signed, need to default to trust the certificate:
```sh
/connect user@hostname.onion tls trust
```

Generate OMEMO crytographic materials for current account
```sh
/omemo gen
```

Start an OMEMO session with contact, or current recipient if omitted:
```sh
/omemo start [<contact>]
```

The same commands are valid for `/otr` and `/pgp`.

### Psi-plus

[Psi+](https://psi-plus.com/) - [git](https://github.com/psi-plus)

The best client on this projects point of view. Compatible with various operating systems, when the encryption plugins are installed, they are enabled by default

Install psi-plus and plugins to have encryption methods available (OMEMO, OpenPGP, OTR):
```sh
sudo apt install -y psi-plus psi-plus-plugins
```


### Dino-im

[Dino IM](https://dino.im/) - [git](https://github.com/dino/dino)

[Fixed accepting self-signed certificated](https://github.com/dino/dino/issues/958) on versions 0.2.1+.

Install dino-im:
```sh
sudo apt install -y dino-im
```

To configure the client, toggle Advanced settings during login and select Tor proxy.

### Gajim

[Gajim](https://gajim.org/) - [git](http://dev.gajim.org/gajim/gajim)

Problems:
- modules compatibility with other clients, such as conversations.
- privacy settings are opt-out, not opt-in, and per account, this might leak your operating system, local time, away since what time

Install gajim:
```sh
sudo apt install -y gajim gajim-omemo
```

### Pidgin

One of the oldest clients, written in C. Many exploits. Only present for compability with Tails before they migrate to a better client.

Install pidgin and its OTR plugin:
```sh
sudo apt install -y pidgin pidgin-otr
```

### Conversations

[Conversations](https://conversations.im/) - [git](https://github.com/inputmice/Conversations)

### Extra

Read [this guide](https://archive.is/n116i#selection-705.16-705.20) from The Intercepet on how to configure your XMPP client.

### Encryption

Read [Off-the-Record Messaging Protocol version 3](https://otr.cypherpunks.ca/Protocol-v3-4.1.1.html) by cypherpunks.ca to understand OTR encryption.

* [OTR](https://xmpp.org/extensions/xep-0364.html) does not work with [MUC](https://xmpp.org/extensions/xep-0045.html) (Multi-user chat) but is the most widely used.
* [OMEMO](https://xmpp.org/extensions/xep-0384.html) is compatible with Conversations, Pidgin, Dino IM, Gajim and can be used MUC.

OTR is being deprecated on newer clients and they are preferring OMEMO, because it works on offline messages and group chats.