# Prosody

Site: https://prosody.im/


From prosody debian/control:
_Lightweight Jabber/XMPP server_
_Prosody IM is a simple-to-use XMPP server. It is designed to be easy to extend via plugins, and light on resources._

---
Table of Contents
---
- [Prosody](#prosody)
  - [Installation](#installation)
  - [Register users](#register-users)
---

## Installation

The server script will modify the default prosofy configuration file only to include a new directory of virtual host. The onion host configuration will be placed in a separate file for organization purposes.

Install:
```sh
sudo ./setup.sh
```

It will ask for password of a non admin account, either way, use a secure and long password generated preferably by a password manager.

## Register users

Registration is disable by default, only the server can add new users with:
```sh
sudo -u prosody prosodyctl adduser anotheruser@onionhostname
```

Why disable registration by default?
- Security: prevent dos attacks
- Descentralization: everyone should run their own servers
