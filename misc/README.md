# Misc

Misc stands for miscellaneous, dealing with diverse subjects.

---
Table of contents
---
- [Misc](#misc)
  - [APT](#apt)
  - [Youtube-dl](#youtube-dl)
    - [Proxy youtube-dl](#proxy-youtube-dl)
    - [Torsocks youtube-dl](#torsocks-youtube-dl)
  - [Wget](#wget)
    - [Proxy wget](#proxy-wget)
    - [Torsocks wget](#torsocks-wget)
  - [Curl](#curl)
    - [Proxy curl](#proxy-curl)
    - [Torsocks curl](#torsocks-curl)
  - [GPG](#gpg)
  - [git](#git)
    - [Proxy git](#proxy-git)
    - [Torsocks git](#torsocks-git)
  - [Ricochet-refresh](#ricochet-refresh)
    - [Install Ricochet-refresh](#install-ricochet-refresh)
    - [Build Ricochet-refresh](#build-ricochet-refresh)
    - [Backup Ricochet-refresh](#backup-ricochet-refresh)
  - [TEG](#teg)

---

## APT

From apt manual page:

_apt provides a high-level commandline interface for the package management system. It is intended as an end user interface and enables some options better suited for interactive usage by default compared to more specialized APT tools like apt-get(8) and apt-cache(8)._

Read also [TPO TorifyHowTO apt](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/apt) and [TPO Apt over Tor](https://support.torproject.org/apt/apt-over-tor/)

Install apt-transport-tor:
```sh
sudo apt install install -y apt-transport-tor
```

Edit your sources.list (use the list folder `/etc/apt/sources.list.d/tor.list`) to include only `tor+http://` for onion service URLs or `tor:https://` for plainnet URLs. Note: apt sources that have a `.onion` domain but do not have `tor://` prefix will fail to work as a security measure, atherwise, a rogue malicious DNS server could redirect users to a false domain and trick them into thinking they are using Tor when they are really not.

`<DIST>` is your debian release version, also known as codename. You can find it by running: `grep -oP "VERSION_CODENAME=\K.*" /etc/os-release`, or `cat /etc/debian_version` or `lsb_release -sc`.


Configure Debian plainnet repository to use tor:
```sh
deb tor+https://deb.debian.org/debian <DIST> main contrib non-free
```

Configure [Debian onion service repository](https://onion.debian.org/):
```sh
deb tor+http://2s4yqjx5ul6okpp3f2gaunr2syex5jgbfpfvhxxbbjwnrsvbk5v3qbid.onion/debian <DIST> main contrib non-free
```

Configure [Tor Project onion service repository](https://support.torproject.org/apt/apt-over-tor/):
```sh
deb tor+http://2s4yqjx5ul6okpp3f2gaunr2syex5jgbfpfvhxxbbjwnrsvbk5v3qbid.onion/debian <DIST> main
```

## Youtube-dl

From youtube-dl manual page:

_youtube-dl  is  a  command-line program to download videos from YouTube.com and a few more sites.  It requires the Python interpreter, version 2.6, 2.7, or 3.2+, and it is not platform specific.  It should work on your Unix box, on Windows or on macOS.  It is  released  to  the  public  domain, which means you can modify it, redistribute it or use it however you like._

Read also [TPO TorifyHowTO youtube-dl](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install youtube-dl:
```sh
sudo apt install -y youtube-dl
```

### Proxy youtube-dl

```sh
youtube-dl --proxy socks5://127.0.0.1:9050/ https://www.youtube.com/watch?v=STRING
```

### Torsocks youtube-dl

```sh
torsocks youtube-dl https://www.youtube.com/watch?v=STRING
```


## Wget

From wget manual page:

_Wget is a free utility for non-interactive download of files from the Web.  It supports HTTP, HTTPS, and FTP protocols, as well as retrieval through HTTP proxies._

Read also [TPO TorifyHowTO wget](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install wget:
```sh
sudo apt install wget
```

### Proxy wget

In the `/etc/wgetrc` for system wide or `~/.wgetrc` for user only:
```sh
use_proxy=yes
http_proxy=127.0.0.1:9050
https_proxy=127.0.0.1:9050
```

### Torsocks wget

Just prepend torsocks:
```sh
torsocks wget <URL>
```


## Curl

From curl manual page:

_curl is a tool to transfer data from or to a server, using one of the supported protocols (DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, MQTT, POP3, POP3S, RTMP, RTMPS, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET and TFTP). The command is  designed  to  work  without user interaction._

Read also [TPO TorifyHowTO cURL](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install curl:
```sh
sudo apt install curl
```

### Proxy curl

To configure the proxy, use socks5h (socks5-hostname) to not leak DNS.

Configure per user on `~/.curlrc`:
```sh
http_proxy=socks5h://127.0.0.1:9050
HTTPS_PROXY=socks5h://127.0.0.1:9050
ALL_PROXY=socks5h://127.0.0.1:9050
```

Or for one time run
```sh
curl -x socks5h://127.0.0.1:9050 <URL>
```

### Torsocks curl

Just prepend torsocks:
```sh
torsocks curl <URL>
```


## GPG

From gpg manual page:

_gpg  is  the OpenPGP part of the GNU Privacy Guard (GnuPG). It is a tool to provide digital encryption and signing services using the OpenPGP standard. gpg features complete key management and all the bells and whistles you would expect from a full OpenPGP implementation._

Read also [TPO TorifyHowTO GnuPG](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/GnuPG).

Install gpg and dirmngr (to facilitate communication with keyservers):
```sh
sudo apt install gpg dirmanager
```

The option `--use-tor` switches Dirmngr and thus GnuPG into “Tor mode” to route all network access via the Tor Network. Certain other features are disabled in this mode. The effect of `--use-tor` cannot be overridden by any other command or even be reloading gpg-agent. The use of `--no-use-tor` disables the use of Tor. The default is to use Tor if it is available on startup or after reloading dirmngr."

Another option is to insert use-tor into the `~/.gnupg/dirmngr.conf` file.


## git

From git manual page:

_Git is a fast, scalable, distributed revision control system with an unusually rich command set that provides both high-level operations and full access to internals._

Read also [Pastly Use Git over Tor](https://matt.traudt.xyz/posts/2016-10-29-use-git-over-tor/).

Install git:
```sh
sudo apt install git
```

### Proxy git

Set the global proxy:
```git
git config --global http.proxy 'socks5://127.0.0.1:9050'
```

Set per repository proxy:
```sh
git config http.proxy 'socks5://127.0.0.1:9050'
```

Or one time per connection:
```git
git -c http.proxy=socks5h://127.0.0.1:9050 clone http://xtlfhaspqtkeeqxk6umggfbr3gyfznvf4jhrge2fujz53433i2fcs3id.onion/project/web/community.git/
```

### Torsocks git

Just prepend torsocks:
```sh
torsocks git clone http://xtlfhaspqtkeeqxk6umggfbr3gyfznvf4jhrge2fujz53433i2fcs3id.onion/project/web/community.git/
```


## Ricochet-refresh

From its [README](https://github.com/blueprint-freespeech/ricochet-refresh#how-does-it-work):

_Ricochet Refresh uses the Tor network to establish a peer-to-peer connection between you and your contact. Ricochet Refresh creates a service on the Tor network which contacts can connect to. Tor's rendezvous system makes it extremely difficult for anyone to learn the identity of a Tor user, including you._

### Install Ricochet-refresh

Visit the [releases page](https://github.com/blueprint-freespeech/ricochet-refresh/releases) and download the version you desire. On the same page, also download the files ` ricochet-refresh-release-signing.pub`, `sha256-sums.txt` and `sha256-sums.txt.asc`.

GPG Fingerprint: 07AA9DAA7088B94AF3D40084D83A26FDF5050FE0

Define ricochet-refresh version you want available on the [releases page](https://github.com/blueprint-freespeech/ricochet-refresh/releases):
```sh
ricochet_version="3.0.10"
```

Define the download path:
```sh
dist_path="https://github.com/blueprint-freespeech/ricochet-refresh/releases"
```

Define binary file name:
```sh
dist_file="ricochet-refresh-${ricochet_version}-linux-$(uname -m).tar.gz"
```

Download binary, public key, message digest and its signed version,:
```sh
curl --tlsv1.3 --proto =https --location --remote-name-all --remote-header-name ${dist_path}/download/v${ricochet_version}-release/${dist_file} ${dist_path}/download/v${ricochet_version}-release/sha256-sums.txt{,.asc} ${dist_path}/download/v${ricochet_version}-release/ricochet-refresh-release-signing.pub
```

Check fingerprints/owners without importing anything:
```sh
gpg --keyid-format long --import --import-options show-only --with-fingerprint ricochet-refresh-release-signing.pub
```
Note: you should see `Key fingerprint = 07AA 9DAA 7088 B94A F3D4  0084 D83A 26FD F505 0FE0`. If that is not what you see, you must not procede.

Import key to keyring:
```
gpg --import ricochet-refresh-release-signing.pub
```

Verify hashsum file against its signed version:
```sh
gpg --verify sha256-sums.txt.asc sha256-sums.txt
```

Check sha hashsum:
```sh
sha256sum --check sha256-sums.txt --ignore-missing
```
Note: the output must be the file name with `OK` at the end, else, you must not procede.

Enter the directory:
```sh
cd ricochet-refresh
```

Run ricochet-refresh without installing it:
```sh
./ricochet-refresh &
```

Install ricochet-refresh:
```sh
sudo cp ricochet-refresh /usr/bin/
```
It also contains a separate tor binary, but it is not necessary to use it if you already have tor installed. This also prevents against using an old tor version.

### Build Ricochet-refresh

Read also [BUILDING.md](https://github.com/blueprint-freespeech/ricochet-refresh/blob/main/BUILDING.md).

Install requirements:
```sh
requirements="libubsan1 libasan6 libgl-dev devscripts build-essential libssl-dev pkg-config libprotobuf-dev protobuf-compiler qt5-qmake qtbase5-dev qttools5-dev-tools qtdeclarative5-dev qtmultimedia5-dev qml-module-qtquick-controls qml-module-qtquick-dialogs qml-module-qtmultimedia qttools5-dev tor git"
sudo apt install -y ${requirements}
```
Note: upstream requirements are incomplete on [BUILDING.md](https://github.com/blueprint-freespeech/ricochet-refresh/blob/main/BUILDING.md).

Clone the repository and its submodules
```git
git clone --recurse-submodules https://github.com/blueprint-freespeech/ricochet-refresh.git
```

Enter the directory:
```sh
cd ricochet-refresh
```

In the event that you cloned the repo without fetching the submodules, you can still get them with:
```git
git submodule --init --update
```

Later, you should update your local repository with:
```git
git pull --recurse-submodules
```

Install dependencies from debian/control:
```sh
sudo mk-build-deps --remove --install
```
Note: requirements were already installed, just in case if there is any different dependency on debian/control file

Build package without signing it:
```sh
dpkg-buildpackage -b --no-sign
```

Install package
```sh
sudo dpkg -i ../ricochet-refresh_*.deb
```

### Backup Ricochet-refresh

To backup all the data, your ID, contact list and configurations, backup the `~/.local/share/ricochet-refresh` directory.

## TEG

From its [README](https://github.com/wfx/teg):

_Tenes Emapandas Graciela (TEG) is a clone of 'Plan Táctico y Estratégico de la Guerra', which is a pseudo-clone of Risk, a multiplayer turn-based strategy game. Some rules are different._


TODO

https://github.com/wfx/teg

https://www.whonix.org/wiki/Onion_Gaming
