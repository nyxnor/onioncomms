# Misc

Misc stands for miscellaneous, dealing with diverse subjects.


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

### Proxy

```sh
youtube-dl --proxy socks5://127.0.0.1:9050/ https://www.youtube.com/watch?v=STRING
```

### Torsocks

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

### Proxy

In the `/etc/wgetrc` for system wide or `~/.wgetrc` for user only:
```sh
use_proxy=yes
http_proxy=127.0.0.1:9050
https_proxy=127.0.0.1:9050
```

### Torsocks

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

### Proxy

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

### Torsocks

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
sudo apt install gpg dirm
### Hardening

Read also [kicksecure Wiki](https://www.kicksecure.com/wiki/SSH).
ngr
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

### Proxy

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

### Torsocks

Just prepend torsocks:
```sh
torsocks git clone http://xtlfhaspqtkeeqxk6umggfbr3gyfznvf4jhrge2fujz53433i2fcs3id.onion/project/web/community.git/
```