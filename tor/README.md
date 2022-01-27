# tor

From tor debian control:

_Description: anonymizing overlay network for TCP_
_Tor is a connection-based low-latency anonymous communication system._

Install tor:
```sh
sudo apt install -y tor
```

## Modifying configuration - Optional

The tor package comes pre-configured on Debian, the defaults are on `/usr/share/tor/tor-service-defaults-torrc` or `/usr/local/etc/tor/torrc-defaults`, and the torrc is on `/etc/tor/torrc` or `/usr/local/etc/tor/torrc` (depends on your build), or `$HOME/.torrc` if that file is not found.

Modifying the torrc might cause diversion conflicts when the tor package is upgraded, because of this, this project recommends to modify alternatives files that will be included and read by tor when it starts. These files can be include with the key `%include`. Unfortunately the tor debian package does not commed with this configuration enabled by default, so you will need to edit the `torrc` anyway, add:
```
%include /etc/tor/torrc.d/*.conf
```
This will make every `.conf` file that is inside `/etc/tor/torrc.d/` directory to be included and interpreted as a tor run commands file. It is also great for organization purposes. The next time there is a package diversion in tor, signal it to `N`ot override the configuration file, and if it is overridden, you just have to included that line again and your alternative configurations will be loaded.

## Apply configuration changes

Reload tor if you have made any configuration changes so it can be applied to the running instance:
```sh
sudo systemctl reload tor
```

## SocksPort

This is needed for client applications to use tor as a SOCKS proxy:
```
SocksPort 127.0.0.1:9050
```

## Bridges

Configure the bridges:
Then configure the bridges using the following format:
```
UseBridges 1
UpdateBridgesFromAuthority 1
ClientTransportPlugin transport exec path-to-binary [options]
Bridge [transport] IP:ORPort [fingerprint]
```
- `UseBridges 0|1` ([ref](https://2019.www.torproject.org/docs/tor-manual.html.en#UseBridges)): When set, Tor will fetch descriptors for each bridge listed in the "Bridge" config lines, and use these relays as both entry guards and directory guards. (Default: 0)
- `UpdateBridgesFromAuthority 0|1` ([ref](https://2019.www.torproject.org/docs/tor-manual.html.en#UpdateBridgesFromAuthority)): When set (along with UseBridges), Tor will try to fetch bridge descriptors from the configured bridge authorities when feasible. It will fall back to a direct request if the authority responds with a 404. (Default: 0)
- `ClientTransportPlugin transport exec path-to-binary [options]` ([ref](https://2019.www.torproject.org/docs/tor-manual.html.en#ClientTransportPlugin)): In its first form, when set along with a corresponding Bridge line, the Tor client forwards its traffic to a SOCKS-speaking proxy on "IP:PORT". (IPv4 addresses should written as-is; IPv6 addresses should be wrapped in square brackets.) It’s the duty of that proxy to properly forward the traffic to the bridge. In its second form, when set along with a corresponding Bridge line, the Tor client launches the pluggable transport proxy executable in path-to-binary using options as its command-line options, and forwards its traffic to it. It’s the duty of that proxy to properly forward the traffic to the bridge.
- `Bridge [transport] IP:ORPort [fingerprint]` ([ref](https://2019.www.torproject.org/docs/tor-manual.html.en#Bridge)): When set along with UseBridges, instructs Tor to use the relay at "IP:ORPort" as a "bridge" relaying into the Tor network. If "fingerprint" is provided (using the same format as for DirAuthority), we will verify that the relay running at that location has the right fingerprint. We also use fingerprint to look up the bridge descriptor at the bridge authority, if it’s provided and if UpdateBridgesFromAuthority is set too. If "transport" is provided, it must match a ClientTransportPlugin line. We then use that pluggable transport’s proxy to transfer data to the bridge, rather than connecting to the bridge directly. Some transports use a transport-specific method to work out the remote address to connect to. These transports typically ignore the "IP:ORPort" specified in the bridge line. Tor passes any "key=val" settings to the pluggable transport proxy as per-connection arguments when connecting to the bridge. Consult the documentation of the pluggable transport for details of what arguments it supports.

### obfs4 and meek

To use obfs4 or meek bridges, it is required to install obfs4proxy:
```sh
sudo apt install -y obfs4proxy
```

Value of `ClientTransportPlugin` should be:
```
ClientTransportPlugin meek_lite,obfs4 exec /usr/bin/obfs4proxy
```

Configure obfs4 bridges. You have three ways to get new bridge-addresses:
- Go to https://bridges.torproject.org/ -> Advanced Options -> obfs4 -> Get Bridges
- Send an email to bridges@torproject.org, using an address from Riseup or Gmail with "get transport obfs4" in the body of the mail.
- Via Telegram (official): https://t.me/GetBridgesBot and type the command `/bridges` to get a bridge.
The bridge format must be:
```
Bridge obfs4 IP:PORT FINGERPRINT cert=STRING iat-mode=INTEGER
```

Configure meek bridge (there is only one):
```
Bridge meek_lite 192.0.2.2:2 97700DFE9F483596DDA6264C4D7DF7641E1E39CE url=https://meek.azureedge.net/ front=ajax.aspnetcdn.com
```

### snowflake

To use obfs4 or meek bridges, it is required to install snowflake-client (this might not work if the torproject dor org domain is blocked, because some dependencies are extracted from that domain, git subomain). Requirements is Go 1.13+.
```sh
sudo apt install -y git golang
git clone https://github.com/keroserene/snowflake
export GO111MODULE="on"
cd snowflake/client
go get
go build
sudo cp client /usr/bin/snowflake-client
cd -
rm -rf snowflake
```

Value of `ClientTransportPlugin` can be:
```
ClientTransportPlugin snowflake exec /usr/bin/snowflake-client -url https://snowflake-broker.torproject.net.global.prod.fastly.net/ -front cdn.sstatic.net -ice stun:stun.l.google.com:19302,stun:stun.voip.blackberry.com:3478,stun:stun.altar.com.pl:3478,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.sonetel.net:3478,stun:stun.stunprotocol.org:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478
```

Configure snowflake bridge (there is only one broker):
```
Bridge snowflake 192.0.2.3:1 2B280B23E1107BB62ABFC40DDCC8824814F80A72
```



# Tor Browser

Note, if torproject dot org is blocked, try this mirror: https://cyberside.net.ee/sibul/download/

## Graphical installation

Visit `https://www.torproject.org/download/` -> Download for linux and also download the signature file.

## Command line installation

Define the download root url:
```
dist_url="https://dist.torproject.org/torbrowser"
```

Choose the version (Note: if you have tor service installed, you can torify curl with `torsocks curl`):
```sh
curl -s "${dist_url}" | grep -oP "alt=\"\[DIR\]\"> <a href=\"\K[0-9]{2}.[0-9]{1,}.[0-9]{1,}"
```

Define the version:
```
tor_browser_version="VERSION_YOU_WANT"
```

Check for requirements and install the compressed archive and the signature file, that depends on your architecture and locale:
```sh
case "$(uname -m)" in x86_64|amd64) arch="64"; esac
! command -v curl && sudo apt update -y && sudo apt install -y curl
dist_file="tor-browser-linux${arch}-${tor_browser_version}_${LANG%%.*}.tar.xz"
curl --tlsv1.3 --proto =https --location --remote-name-all --remote-header-name ${dist_url%*/}/${tor_browser_version}/${dist_file}{,asc}
```

## Verify the signature

### Import the key

Read also [TPO How can I verify Tor Browser's signature?](https://support.torproject.org/tbb/how-to-verify-signature/)

Import the Tor Browser Developers signing key. There are four methods:

1. Import the Tor Browser Developers signing key with gpg locate:
```sh
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
```

2. Import the Tor Browser Developers public key from torproject dot org with curls:
```sh
curl -s https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf | gpg --import -
```

3. Import the Tor Browser Developers public key from openpgp dot org with curl:
```sh
curl -s https://keys.openpgp.org/vks/v1/by-fingerprint/EF6E286DDA85EA2A4BA7DE684E2C6E8793298290 | gpg --import -
```

4. Import the Tor Browser Developers public key from openpgp dot org with gpg:
```sh
gpg --keyserver keys.openpgp.org --search-keys torbrowser@torproject.org
```

### Save the key to a file

```sh
gpg --output ./tor.key --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290
```

### Verify the signature

`dist_file` was defined on the command line installation. It is something like `tor-browser-linux64-11.0.4_en-US.tar.xz`, where `linux64` is the kernel and the architecture, `11.0.4` the version you are installing and `en-US` is the language locale you want.
```sh
gpgv --keyring ./tor.keyring ${dist_file}.asc ${dist_file}
```


## torbrowser-launcher

From torbrowser-launcher debian control:

_Tor Browser Launcher is intended to make the Tor Browser Bundle (TBB) easier
to maintain and use for GNU/Linux users. torbrowser-launcher handles
downloading the most recent version of TBB for you, in your language and for
your architecture. It also adds a "Tor Browser" application launcher to your
operating system's menu._

_When you first launch Tor Browser Launcher, it will download TBB from
https://www.torproject.org/ and extract it to ~/.local/share/torbrowser,
and then execute it._
_Cache and configuration files will be stored in ~/.cache/torbrowser and
~/.config/torbrowser._
_Each subsequent execution after installation will simply launch the most
recent TBB, which is updated using Tor Browser's own update feature._

Install torbrowser-launcher:
```sh
sudo apt install -y torbrowser-launcher
```

If you already have tor (the service, not the browser) already installed, the download will be over tor.

It is better to have tor service installed before launching torbrowser

torbrowser-launcher will attempt to download Tor Browser over Tor, using tor service if available, on its first run. It is safer to download using tor because you won't need to worry about the mirror being blocked by your country or ISP. If your tor `SocksPort` is not the standard `127.0.0.1:9050`, you should change the field `Tor server` to your configuration by running `torbrowser-launcher --settings`.

Install Tor Browser:
```sh
torbrowser-launcher
```

## Security level - Optional

Disable certain web features that can be used to attack your security and anonymity.

On the URL bar type `about:preferences#privacy` -> Security -> Security Level -> Choose your [level](https://tb-manual.torproject.org/security-settings/)

## Onion Location - Optional

Prioritize `.onion` sites when know, meaning that when the service operator has set the [`Onion-Location` header](https://community.torproject.org/onion-services/advanced/onion-location/) for the page you are visiting, you will be automatically redirected from the normal domain `.org` for example to the `.onion` domain.

On the URL bar type `about:preferences#privacy` -> Browser Privacy -> Onion Services -> Prioritize .onion sites when known -> Always

## Bridges - Optional

If you live in a censored environment, you might want to configure [bridges](https://tb-manual.torproject.org/bridges/) first to circumnvent censorship.

On the URL bar type `about:preferences#tor` -> Bridges -> Use a bridge -> Select the option that best fit your threat model.

## Debugging - Optional

If you can't connect to the Tor network, you can view Tor Browser logs.

On the URL bar type `about:preferences#tor` -> Advanced -> View the Tor logs