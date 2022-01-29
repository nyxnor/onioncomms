# Prosody

Site: https://prosody.im/


From prosody debian/control:
_Lightweight Jabber/XMPP server_
_Prosody IM is a simple-to-use XMPP server. It is designed to be easy to extend via plugins, and light on resources._


## Server

Install:
```sh
sudo ./setup.sh
```

### Disclaimer

Read the code, it will modify configuration files of prosody and tor.

Registering with a new account as a client is disabled by default, only the server administrator can do that for security reasons. For descentralization, everyone should run their own server.

```sh
sudo -u prosody prosodyctl adduser anotheruser@onionhostname
```
