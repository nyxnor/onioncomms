# Prosody Hidden Service

**Prosody XMPP Server as a Hidden Service with message encryption (OTR/OMEMO) on Debian and derived systems**

## Stage

* Under development, really, do not trust it, run on a disposable instance.
* I want to add MUC, but Tor does not resolve DNS and hidden services subdomains are encapsulated inside the host header, so the web server manages it with HTTP(s). A solution is to add a second hidden service to be the conference room, but that lowers the UX needing to have two domains to navigate.

## Objective

Finding the best solution requires avaliation of the current problems, analisis and results.

### Problems

XMPP network is federated, this leads too centralization on third party hosted servers resulting on:

* Plainnet servers exposing clients IP address (not your server, not your obfuscation technique).
* Few servers accept Tor connection (not your server, not your freedom).
* Normally no encryption, so no private conversations (not your server, not your recipient).
* You can be censored (not your server, not your rules).
* Ony modules made available by the server admin (not your server, not your configuration).

### Analysis

[XMPP](https://xmpp.org/) is the open standard for messaging and presence, this means:

* Any client can connect to any other client from a different server.
* No one owns XMPP. It's free and open for everyone. It is openly federated, anyone can host their own server.
* It's a living standard. Engineers actively extend and improve it.

### Solution

Sovereignty, host your own server, your configuration, your rules, your privacy, your recipient.

* Host your own server with [Prosody XMPP Server](https://prosody.im/)
* Make it available via a [hidden service](https://community.torproject.org/onion-services/overview/), hiding your IP address and much more.
* Require encryption to all connections to avoid MITM (Man In The Middle) with OTR (Off-the-Reconrd-Encryption) or OMEMO.
* You are the only client by default, registration is disabled in the configuration. This incites people to host their own server instead of asking to be your client or registering themselves.
* Choose your modules, enable what you want and disable what you dislike or find harmful

## Clients

https://riseup.net/de/chat/clients

## Which encryption to use (OTR/OMEMO)?

* [OTR](https://xmpp.org/extensions/xep-0364.html) does not work with [MUC](https://xmpp.org/extensions/xep-0045.html) (Multi-user chat) but is the most widely used.
* [OMEMO](https://xmpp.org/extensions/xep-0384.html) is compatible with [Conversations](https://conversations.im/) and MUC.

## Usage

### Clone the repo

```bash
git clone https://github.com/nyxnor/prosody-hidden-service
cd prosody-hidden-service
```

### Edit your variables

```bash
nano setup.sh
XMPP_SERVER_USER_NAME=CHANGEME
XMPP_SERVER_USER_PASS=CHANGEME
Ctrl+X Y
```

or

```bash
XMPP_SERVER_USER_NAME=CHANGEME
XMPP_SERVER_USER_PASS=CHANGEME
sed -i "s/XMPP_SERVER_USER_NAME=.*/XMPP_SERVER_USER_NAME='${XMPP_SERVER_USER_NAME}'/" setup.sh
sed -i "s/XMPP_SERVER_USER_PASS=.*/XMPP_SERVER_USER_PASS='${XMPP_SERVER_USER_PASS}'/" setup.sh
```