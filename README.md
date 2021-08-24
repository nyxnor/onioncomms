# Prosody XMPP Server as a Hidden Service with message encryption (OTR/OMEMO) on Debian and derived systems

## Stage

* Under development, really, do not trust it, run on a disposable instance.
* I want to add MUC, but Tor does not resolve DNS and hidden services subdomains are encapsulated inside the host header, so the web server manages it with HTTP(s). A solution is to add a second hidden service to be the conference room, but that lowers the UX needing to have two domains to navigate.

## Which encryption mod_ to used, otr or omemo_all_access?

OTR does not work with MUC (Multi-user chat) and [Conversations](https://conversations.im/) client works with Omemo.