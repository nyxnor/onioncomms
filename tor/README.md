# Tor's onion routing

[A Peel of Onion](https://www.acsac.org/2011/program/keynotes/syverson.pdf) describes onion rounting sa follows:

_Onion routing was invented to facilitate anonymous low-latency bidirectional communication, such as occurs in web browsing, remote login, chat, and other interactive applications. By only using public-key cryptography to establish session keys it allows for throughput and latency that would not be feasible if public-key operations were needed for each message (or packet) passing through the system. By following a multihop free-route path selection through a network of independently managed onion routers, it makes it hard for an adversary to observe traffic entering and leaving the system._

## tor daemon

From tor debian control:

_Description: anonymizing overlay network for TCP_
_Tor is a connection-based low-latency anonymous communication system._

### Install

From [TPO support for Relay Operators](https://support.torproject.org/relay-operators/packaged-tor/) (still valid for any Debian and derivatives user):

If you're using Debian or Ubuntu especially, there are a number of benefits to installing Tor from the Tor Project's repository.
- Your ulimit -n gets set to 32768 high enough for Tor to keep open all the connections it needs.
- A user profile is created just for Tor, so Tor doesn't need to run as root.
- An init script is included so that Tor runs at boot.
- Tor runs with --verify-config, so that most problems with your config file get caught.
- Tor can bind to low level ports, then drop privileges.

Install tor:
```sh
sudo apt install -y tor
```

### Build

Great for no trust on the maintainers of the tor package.

Install requirements:
```sh
sudo apt install -y git build-essential automake libevent-dev libssl-dev zlib1g-dev
```

Clone the repository:
```sh
git clone https://github.com/torproject/tor
```
Note: github dot com was chosen because it is less likely do be blocked than a torproject dot org domain.

Enter the directory:
```sh
cd tor
```

Select one of the 10 (arbitrary) latest stable releases:
```git
git tag --sort=-version:refname | grep -v -E "\-rc|\-alpha|\-alpha\-dev" | head -n 10
```

Checkout tag, where `<TAG>` is one of sorted from above output:
```git
git checkout <TAG>
```

Autogenerate the configure script:
```sh
./autogen.sh
```
Note: if the script is not finding the libraries, set libvent directory:
```sh
./configure --with-libevent-dir=/usr/local
```

Configure the build:
```sh
./configure.sh
```

Make build:
```sh
sudo make
```

Install build:
```sh
sudo make install
```


### Modifying configuration - Optional

The tor package comes pre-configured on Debian, the defaults are on `/usr/share/tor/tor-service-defaults-torrc` or `/usr/local/etc/tor/torrc-defaults`, and the torrc is on `/etc/tor/torrc` or `/usr/local/etc/tor/torrc` (depends on your build), or `$HOME/.torrc` if that file is not found.

### Diversion - Conflicts

Modifying the torrc might cause diversion conflicts when the tor package is upgraded, because of this, this project recommends to modify alternatives files that will be included and read by tor when it starts. These files can be include with the key `%include`. Unfortunately the tor debian package does not commed with this configuration enabled by default, so you will need to edit the `torrc` anyway, add:
```
%include /etc/tor/torrc.d/*.conf
```
This will make every `.conf` file that is inside `/etc/tor/torrc.d/` directory to be included and interpreted as a tor run commands file. It is also great for organization purposes. The next time there is a package diversion in tor, signal it to `N`ot override the configuration file, and if it is overridden, you just have to included that line again and your alternative configurations will be loaded.

### Apply configuration changes

After modifying the configuration files, reload tor so it can be applied to the running instance:
```sh
sudo systemctl reload tor
```

### SocksPort

This is needed for client applications to use tor as a SOCKS proxy:
```
SocksPort 127.0.0.1:9050
```

### Bridges

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

### Obfs4 and Meek

To use obfs4 or meek bridges, it is required to install obfs4proxy:
```sh
sudo apt install -y obfs4proxy
```

Value of `ClientTransportPlugin` should be:
```
ClientTransportPlugin meek_lite,obfs4 exec /usr/bin/obfs4proxy
```

Configure obfs4 bridges. These are some ways to get new bridge-addresses:
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

### Snowflake

To use obfs4 or meek bridges, it is required to install snowflake-client (this might not work if the torproject dor org domain is blocked, because some dependencies are extracted from that domain, git subomain). Requirements is Go 1.13+.
```sh
## install requirements
sudo apt install -y git golang
## clone repository
git clone https://github.com/keroserene/snowflake
## change directory to snowflake/client
cd snowflake/client
## will force using Go modules even if the project is in your GOPATH
export GO111MODULE="on"
## install packages and dependencies
go get
## compile package and dependencies
go build
## move binary to path
sudo cp client /usr/bin/snowflake-client
## go back to previous folder
cd -
## delete repository
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

### Client Authorization

From [TPO community client-auth](https://community.torproject.org/onion-services/advanced/client-auth/):
_Client authorization is a method to make an onion service private and authenticated. It requires Tor clients to provide an authentication credential in order to connect to the onion service. For v3 onion services, this method works with a pair of keys (a public and a private). The service side is configured with a public key and the client can only access it with a private key._

_Note: Once you have configured client authorization, anyone with the address will not be able to access it from this point on. If no authorization is configured, the service will be accessible to anyone with the onion address._

#### Generate key pair

The key pair generation can be done by the server or the client. For security reasons, the best option is for the client to generate the keys and let the server only know the public part.

Install requirements:
```sh
sudo apt install -y openssl basez
```

Generate a key using the algorithm x25519:
```sh
openssl genpkey -algorithm x25519 -out /tmp/k1.prv.pem
```

Generate the private key and format into base32:
```sh
grep -v " PRIVATE KEY" /tmp/k1.prv.pem | base64pem -d | tail -c 32 | base32 | sed "s/=//g" > /tmp/k1.prv.key
```

Generate the public key and format into base32:
```sh
openssl pkey -in /tmp/k1.prv.pem -pubout | grep -v " PUBLIC KEY" | base64pem -d | tail -c 32 | base32 | sed "s/=//g" > /tmp/k1.pub.key
```

#### Server

The server should include a file inside the `<HiddenServiceDir>/authorized_clients/` directory, where `HiddenServiceDir` is the directory there the onion service directory is, and the file should have a suffix `.auth`, for example, `alice.auth`. The content format must be: `descriptor:x25519:<base32-encoded-public-key>`

Substitute the `<base32-encoded-public-key>` for the correct value of the client public key in base32 format. For example, the file `/var/lib/tor/hidden_service/authorized_clients/alice.auth` should look like:
```
descriptor:x25519:N2NU7BSRL6YODZCYPN4CREB54TYLKGIE2KYOQWLFYC23ZJVCE5DQ
```

If you are planning to have more authenticated clients, each file must contain one line only. Any malformed file will be ignored.

Note: Reload tor to apply the changes.

**Important**: Revoking a client can be done by removing their ".auth" file, however the revocation will be in effect only after the tor process gets reloaded/restarted.

**Important**: Revoking all clients means the service is no longer authenticated, anyone with the onion service hostname will be able to connect to the server.

#### Client

To access a version 3 onion service with client authorization as a client, make sure you have ClientOnionAuthDir set in your torrc. For example, add this line to `/etc/tor/torrc`:
```
ClientOnionAuthDir /var/lib/tor/onion_auth
```

Then, inside the `<ClientOnionAuthDir>` directory, create a file with the suffix `.auth_private` for the onion service corresponding to this key (i.e. `bob_onion.auth_private`).

The content of the `<ClientOnionAuthDir>/<user>.auth_private` file should look like this: `<56-char-onion-addr-without-.onion-part>:descriptor:x25519:<x25519 private key in base32>`

For example:
```
rh5d6reakhpvuxe2t3next6um6iiq4jf43m7gmdrphfhopfpnoglzcyd:descriptor:x25519:ZDUVQQ7IKBXSGR2WWOBNM3VP5ELNOYSSINDK7CAUN2WD7A3EKZWQ
```

Notice: Reload tor to apply configuration changes.

The tor daemon will read files from `<ClientOnionAuthDir>` when the server requests client authorization, so no need to type the key during login.

If on the other hand the client is using Tor Browser to authenticate to the onion site, the user does not necessarily need to edit Tor Browser's torrc. It is possible to enter the private key directly in the Tor Browser interface, see how to on [tb-manual](https://tb-manual.torproject.org/onion-services/).



## torsocks

[What is torsocks?](https://gitweb.torproject.org/torsocks.git/tree/README.md)

_Torsocks allows you to use most applications in a safe way with Tor. It ensures
that DNS requests are handled safely and explicitly rejects any traffic other
than TCP from the application you're using._

_Torsocks is an ELF shared library that is loaded before all others. The
library overrides every needed Internet communication libc function calls such
as connect(2) or gethostbyname(3)._

_BE ADVISE: It uses the LD\_PRELOAD mechanism (man ld.so.8) which means that if
the application is not using the libc or for instance uses raw syscalls,
torsocks will be useless and the traffic will not go through Tor._

_This process is transparent to the user and if torsocks detects any
communication that can't go through the Tor network such as UDP traffic, for
instance, the connection is denied. If, for any reason, there is no way for
torsocks to provide the Tor anonymity guarantee to your application, torsocks
will force the application to quit and stop everything._

### Install

Install torsocks:
```sh
sudo apt install -y torsocks
```

### Build

Install requirements:
```sh
sudo apt install -y autoconf automake libtool gcc
```

Clone repository:
```git
git clone https://git.torproject.org/torsocks.git
```

Enter the directory:
```sh
cd torsocks
```

Build torsocks:
```sh
./autogen.sh
./configure
sudo make
```

Install torsocks:
```sh
sudo make install
```

Usage: `torsocks [application]`. Example:
```
torsocks ssh username@somehostname.onion
```


## Tor Browser

Tor Browser is a ESR Firefox hardened and modified by the Tor Project to be used with the Tor network.

Note, if torproject dot org is blocked, try this mirror: https://cyberside.net.ee/sibul/download/

### Graphical installation

Visit `https://www.torproject.org/download/` -> Download for linux and also download the signature file.

### Command line installation

Define the download root url:
```
dist_url="https://dist.torproject.org/torbrowser"
```

Choose the version (Note: if you have tor service installed, you can torify curl with `torsocks curl`):
```sh
curl --silent --location "${dist_url%*/}/" | grep -oP "alt=\"\[DIR\]\"> <a href=\"\K[0-9]{2}.[0-9]{1,}.[0-9]{1,}"
```

Define the version (avoid `a`lpha releases):
```
tor_browser_version="VERSION_YOU_WANT"
```

Check for requirements and install the compressed archive and the signature file, that depends on your architecture and locale:
```sh
## define architecture
case "$(uname -m)" in x86_64|amd64) arch="64"; esac
## check requirements and if not installed, install it
! command -v curl >/dev/null && sudo apt update -y && sudo apt install -y curl
## define file name
dist_lang="$(echo "${LANG%%.*}" | tr "_" "-")"
dist_file="tor-browser-linux${arch}-${tor_browser_version}_${dist_lang}.tar.xz"
## download file and signature
curl --tlsv1.3 --proto =https --location --remote-name-all --remote-header-name ${dist_url%*/}/${tor_browser_version}/${dist_file}{,.asc}
```

### Verify the signature

Keyring and public key verification will be covered in this topic, you only need to choose one.

#### Keyring

##### Import the keyring

Read also [TPO How can I verify Tor Browser's signature?](https://support.torproject.org/tbb/how-to-verify-signature/)

Import the Tor Browser Developers signing key with gpg locate:
```sh
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
```

##### Save the keyring to a file

```sh
gpg --output ./tor.keyring --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290
```

##### Verify the signature

Verify the file against the signed file using the keyring
```sh
gpgv --keyring ./tor.keyring ${dist_file}.asc ${dist_file}
```
From gpg output, `Good signature` is what you need, with the primary key fingerprint matching the one verified by the user earlier on.
Ignore `WARNING: This key is not certified with a trusted signature!`, it is a local trust level configuration for that key.

#### Public key

##### Import the public key

Import the Tor Browser Developers signing key. These are some methods:

- Import the Tor Browser Developers public key from torproject dot org with curls:
```sh
curl -s https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf | gpg --import -
```

- Import the Tor Browser Developers public key from openpgp dot org with curl:
```sh
curl -s https://keys.openpgp.org/vks/v1/by-fingerprint/EF6E286DDA85EA2A4BA7DE684E2C6E8793298290 | gpg --import -
```

- Import the Tor Browser Developers public key from openpgp dot org with gpg:
```sh
gpg --keyserver keys.openpgp.org --search-keys torbrowser@torproject.org
```

##### Verify the signature

Verify the file against the signed file and the signers public key:
```sh
gpg --verify ${dist_file}.asc ${dist_file}
```
From gpg output, `Good signature` is what you need, with the primary key fingerprint matching the one verified by the user earlier on.
Ignore `WARNING: This key is not certified with a trusted signature!`, it is a local trust level configuration for that key.

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

torbrowser-launcher will verify Tor Browser's signature for you, to ensure the version you downloaded was cryptographically signed by Tor developers and was not tampered, read more about it on the program [security-design.md](https://github.com/micahflee/torbrowser-launcher/blob/develop/security_design.md).

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

### Security level

Disable certain web features that can be used to attack your security and anonymity.

On the URL bar type `about:preferences#privacy` -> Security -> Security Level -> Choose your [level](https://tb-manual.torproject.org/security-settings/)

### Onion Location

Prioritize `.onion` sites when know, meaning that when the service operator has set the [`Onion-Location` header](https://community.torproject.org/onion-services/advanced/onion-location/) for the page you are visiting, you will be automatically redirected from the normal domain `.org` for example to the `.onion` domain.

On the URL bar type `about:preferences#privacy` -> Browser Privacy -> Onion Services -> Prioritize .onion sites when known -> Always

### Bridges

If you live in a censored environment, you might want to configure [bridges](https://tb-manual.torproject.org/bridges/) first to circumnvent censorship.

On the URL bar type `about:preferences#tor` -> Bridges -> Use a bridge -> Select the option that best fit your threat model.

### Debugging

If you can't connect to the Tor network, you can view Tor Browser logs.

On the URL bar type `about:preferences#tor` -> Advanced -> View the Tor logs



# Orbot

Orbot: Android Onion Routing Robot

From its [README](https://github.com/guardianproject/orbot):

_Orbot is a freely licensed open-source application developed for the Android platform. It acts as a front-end to the Tor binary application, and also provides an HTTP Proxy for connecting web browsers and other HTTP client applications into the Tor SOCKS interface._

- Download a free and open source program to check message digest, one example is [hash-checker](https://github.com/hash-checker/hash-checker)

- Download F-Droid and its signed version on [f-droid.org](https://f-droid.org/)

- Check the message digest of the F-Droid apk and the signature (.asc) file.

- [Add](https://www.f-droid.org/en/tutorials/add-repo/) the [Guardian Project repo](https://guardianproject.info/fdroid/) to F-Droid and check the signing key fingerprint available at the end of the meta repository above.

- Fetch sources by updating the repository.

- Install Orbot through F-Droid by using the search bar.

- See this [guide](https://nerdschalk.com/orbot/) about usage.

- Optionally, use Orbot vpn mode on F-Droid to fetch from the Guardian Project [onion service repository](http://uzfomcxbx24d3esy7akpdbiovcfoorupz4aez6fpabmyh45nnqdp7mqd.onion/fdroid/repo).