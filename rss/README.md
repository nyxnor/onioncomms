# RSS

## Client

### Newsboat

Newsboat is an Atomm and RSS reader from the terminal.

Install newsboat:
```sh
sudo apt install -y newsboat
```

Configure newsboat to resolve over Tor:
```sh
printf "use-proxy yes
proxy-type socks5h
proxy 127.0.0.1:9050
" | tee -a ~/.newsboat/config
```

Add an onion feed (Qubes OS feed example):
```sh
printf "http://qubesosfasa4zl44o4tws22di6kepyzfeqv3tg4e3ztknltfxqrymdad.onion/feed.xml" | tee -a ~/.newsboat/urls
```

Start newsboat and refresh feeds from start:
```sh
newsboat -r
```

### QuiteRSS

QuiteRSS is a feed reader written in Qt/C++.

Install quiterss:
```sh
sudo apt install -y quiterss
```

Configure the proxy: `Tools` -> `Options` (F8) -> `Network Connections` -> `Manual proxy configuration`:
```
SOCKS5
Proxy server: 127.0.0.1
Port: 9050
```

Add an onion feed (Qubes OS feed example):
`Ctrl+N` -> Paste the following as the url: `http://qubesosfasa4zl44o4tws22di6kepyzfeqv3tg4e3ztknltfxqrymdad.onion/feed.xml`