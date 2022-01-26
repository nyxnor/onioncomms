# Torify, how to?

The documents contained within this section provide information and instructions on configuring various software to securely connect to the Internet via Tor.

In short, do not torify any applications yourself unless you know exactly what you are doing. If, however, you wish to study the complexities surrounding the subject, then please feel free to indulge yourself and even go as far as providing new instructions or implementations. In the meantime, see this article more as a reference for developers and advanced users. If you do not fall into one of these two categories then for your own security, stick with the Tor Browser from https://www.torproject.org.

This document is based on [TorifyHOWTO](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO) ([credits](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/legal)), it has updated links and information and used [Whonix wiki](https://www.whonix.org/wiki/Remote_Administration#Remmina) for reference.

This guide is intended for client side applications to be used by any *nix user. Debian apt is used as an example to install the client software, but nonetheless, application configuration apply to all plainnet operating system. If you are using Whonix, you don't need to configure any client to be torified, as all of the traffic is already torified on your machine.

## Terminology

- **Torify/Torification**: The generic term. Either by proxification, socksification or transsocksification. Take measures to ensure that an application, which has not been designed for use with Tor (such as TorChat), will use only Tor for internet connectivity. Also ensure that there are no leaks from DNS, UDP or the application protocol.

- **Proxify/Proxification**: This is not exclusively a Tor term and has two meanings
  - Use the proxy settings of the application and add a HTTP or SOCKS proxy
  - Use an external wrapper to force the application to use an HTTP or SOCKS proxy

- **Socksify/Socksification**: Also not exclusively a Tor term and also has two meanings:
  - Use the proxy settings of the application and add a SOCKS proxy
  - Use an external wrapper to force the application to use a SOCKS proxy

- **Transsocksify/Transsocksification**: Not exclusively a Tor term. Redirect an application or operating system transparently through a SOCKS proxy using a gateway and/or packet filter. For example: Tor's transparent proxy or Squid


## Warnings and advisories

The following section contains several security and privacy focused topics that users should be aware of. Please be sure to read it carefully, and take the time to fully understand the potential and limitations of Tor. You will make yourself and the entire network safer in the process!

### Protocol leaks

Tor provides only anonymity for DNS and the transmission of the TCP stream. Everything inside the stream, the application protocol, needs to be scrubbed. For example, if the application uses advanced techniques to determine your real external IP and sends it over the anonymized TCP stream, then what you wanted to hide, your real external IP, isn't hidden. This is exactly what happens with BitTorrent. Some applications may also choose to ignore and therefore not honor the proxy configuration you provide. This is something else you need to consider. Firefox was prone to this issue, as noted here: [Firefox Proxy Bypass Bugs](https://blog.torproject.org/blog/firefox-security-bug-proxy-bypass-current-tbbs).

Many applications have been written to work around firewalls and blocking Internet service providers, such as [BitTorrent clients](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/Misc) and [Skype](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/InstantMessaging). Regardless of your use of "correct" proxy settings (SOCKS5) and/or external applications for torification, some applications will use advanced techniques to determine your external non-Tor IP address. As said previously, those applications were never made with anonymity in mind, but were designed to evade firewalls to allow them to function as expected.

All-in-all, you do not have to believe the statements of any random wiki contributor. However do take note and understand the [official warnings from torproject.org](https://www.torproject.org/download/download-easy.html.en#warning).

Quote: "Tor does not protect all of your computer's Internet traffic when you run it. Tor only protects your applications that are properly configured to send their Internet traffic through Tor. To avoid problems with Tor configuration, we strongly recommend you use the Tor Browser. It is pre-configured to protect your privacy and anonymity on the web as long as you're browsing with the Tor Browser itself. Almost any other web browser configuration is likely to be unsafe to use with Tor."

Many applications can also leak other problematic and/or sensitive data, such as:
- Your real external non-Tor IP address, as described above
- Your time zone (for example: IRC clients through CTCP)
- Your user name (for example: ssh through login)
- The name and version of the client or server you are using (for example: Apache web server leaks software name and version number; IRC clients leak client name and client version number through CTCP)
- [Metadata](https://en.wikipedia.org/wiki/Metadata) can be a risk. Click [MAT](http://archives.seul.org/or/talk/Oct-2011/msg00378.html) and read 'What is a metadata?' and 'Why metadata can be a risk for your privacy?'
- Depending on your Mode Of Anonymity you obviously shouldn't mix your use of protected (anonymous) applications with applications not passing through the Tor network or some other form of anonymity. For example, if a login name or password of yours can be traced back to your personal identity, then you are defeating the purpose entirely. Tor can not protect you from this kind of activity
- Even sending the contents of your RAM can be dangerous. For example: error reporting, leading to [Transparent Proxy Leaks](https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxyLeaks))
- A lot of information which the application sends on request from a server (for example: most [web browsers](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/WebBrowsers) besides the Tor Browser)
- Hardware serial numbers might be used for fingerprinting and in the worst case scenario, lead back to you.
- License keys of non-free software is often transmitted and might lead back to you.

You should take care not to leak such information. Information along these lines can be potentially used for de-anonymizing, fingerprinting or to exploit your application. This is what this article is all about: it provides instructions on how applications must be configured to prevent protocol leaks.

### Deceiving Authorship Detection

When you post material online on a forum or chatroom using Tor, then repeat this process again without using Tor, you put your identity at risk.

Public available research and circumvention of this threat is rare:

- [Deceiving Authorship Detection](https://events.ccc.de/congress/2011/Fahrplan/events/4781.en.html)
- [Anonymous Writing Style (academic background dubious, not sure if that is a complete solution)](http://7jguhsfwruviatqe.onion/index.php/Anonymous_Writing_Style)
- [Privacy, Security and Automation Lab](https://psal.cs.drexel.edu/index.php/Main_Page)
- [JStylo-Anonymouth](https://psal.cs.drexel.edu/index.php/JStylo-Anonymouth)

### Proxy and SOCKS settings

Proxy and SOCKS settings are mostly implemented by programmers to improve connectivity, not anonymity. Many people think developers implemented the application's proxy settings with anonymity in mind. That is a big mistake. They did not. See BitTorrent and Mumble for example.

### Exit Nodes Eavesdropping

In the TPO support, [when I'm using Tor, can eavesdroppers still see the information I share with websites, like login information and things I type into forms?](https://support.torproject.org/https/https-1/). In short, every exit node can spy on your unencrypted exit traffic and even worse, inject malicious code into the stream - be aware of this.

### Avoid letting identities cross

It's highly recommended that you do not connect to any remote server in this manner. That is, do not create a Tor link and a non-Tor link to the same remote server at the same time. In the event your Internet connection breaks down (and it will eventually), all your connections will break at the same time and it won't be hard for an adversary to put the pieces together and determine what public IP belongs to what Tor IP, potentially identifying you directly.

### Modes of anonymity

**Remember: Modes of anonymity do not mix!**

||mode 1. User anonymous, any recipient|mode 2. User knows recipient, both user Tor|mode 3. User with no anonymity using Tor, any recipient|mode 4. User with no anonymity, any recipient|
-|-|-|-|-
**Scenario**|post anonymously a message in a message board/mailing list/comment field, whistleblower and such|both sender and recipient know each other and both use Tor.| Login with your real name into any services, such as webmail, Twitter, Facebook, etc...|normal browsing without Tor|
**Anonimity**|yes|no|no|no|
**IP hidden**|yes|yes|yes|no|
**Location hidden**|yes|yes|yes|no|


It's not wis
e to combine mode(1) and mode(2). For example, if you have an IM or email account and use that via mode(1), you are advised not to use the same account for mode(2). We have explained previously why this is an issue.


It's also not wise to mix two or more modes in
side the same Tor session, as they could share the same exit node (identity correlation).
It's also possible that other combinations of modes are dangerous and could lead to the leakage of personal information or your physical location.


## Methods

There are three different methods to torify applications:
Security overall:
- Leaks of your real IP address after you got rooted are only impossible if your machine has no other option than exiting traffic through Tor (Transparent or [Isolating Proxy](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/IsolatingProxy)).
- About protocol leaks (leak of your time zone through CTCP/IRC; browser fingerprinting; [Bittorent leaks](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/Misc); [See warning above!](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO#ExamplesandreasoningfortheWARNING))

| |Application proxy settings|Force the application to use a proxy (torsocks or orbot)|Transparent Proxy|Isolating Proxy|
---|---|---|---|---
|**Example**|manual configuration|torsocks, orbot|Tails|Whonix|
|**Security**| - Configuring the proxy settings manually does not ensure the protocol won't leak DNS requests and IP address. This method is unreliable. | - Torsocks uses the LD_PRELOAD mechanism (man ld.so.8) which means that if the application is not using the libc or for instance uses raw syscalls, torsocks will be useless and the traffic will not go through Tor. <br> <br> - Torsocks allows you to use most applications in a safe way with Tor. It ensures that DNS requests are handled safely and explicitly rejects any traffic other than TCP from the application you're using. This process is transparent to the user and if torsocks detects any communication that can't go through the Tor network such as UDP traffic, for instance, the connection is denied. If, for any reason, there is no way for torsocks to provide the Tor anonymity guarantee to your application, torsocks will force the application to quit and stop everything. | - Safety against leak of real IP address depends on implementation <br> <br> - [Anonymizing Middlebox](https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy#AnonymizingMiddlebox) can prevent IP and DNS leaks, but there are other kinds of critical leaks (time zone, time sync, list of installed packages, identity correlation, and much more...) <br> <br> - Other implementations such [transparently anonymizing traffic for a specific user and local redirection through Tor](https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy#Transparentlyanonymizingtrafficforaspecificuser) do not provide strong IP and DNS leak protection like Anonymizing Middlebox | - Connections are forced through Tor. DNS leaks are impossible, and even malware with root privileges cannot discover the user's real IP address. Leak tested through [corridor](https://github.com/Whonix/corridor) (Tor traffic whitelisting gateway) and other [leak tests](https://www.whonix.org/wiki/Dev/Leak_Tests). <br> <br> - Depending on the implementation, this can provide some protocol leak and fingerprinting protection. For example see [Whonix's Protocol-Leak-Protection and Fingerprinting-Protection](https://whonix.org/wiki/Whonix%27s_Protocol-Leak-Protection_and_Fingerprinting-Protection) |
|**Advantages**| - Does not need third party software (wrapper) <br> <br> - Only a few proxy settings needed, sometimes a few more settings like 'use remote DNS' are required | - No proxy settings inside the application are needed <br> <br> - The use of 'Use Remote DNS' is not required, nor can it be forgotten | - No proxy settings inside the application needed <br> <br> - The use of 'Use Remote DNS' is not required, nor can it be forgotten | - All applications can only access internet over Tor. Direct connections are impossible due to either a virtual internal network and/or physical isolation. <br> <br> - Each application gets their own SocksPort. This can still be combined with Trans- and DnsPort |
|**Disadvantages**| - Each application has to be checked and configured against DNS leaks <br> <br> - The application is not forced to honor the proxy settings. Some applications such as Skype and BitTorrent do not care what the proxy settings are and use direct connections anyway. Also once the application is infected, it's not forced to honor the application settings | - It's a redirector, not a jail. Applications may still decide to use fancy techniques to achieve direct connections. Also once the application or machine is infected with malware, it can break out of the redirector <br> <br> - There is no guarantees of it remaining bug-free <br> <br> - It also does not magically prevent protocol leaks, see [torsocks homepage](https://gitweb.torproject.org/torsocks.git/) for details. | - More complex and complicated, requires additional software <br> <br> - Too many non-IP related leaks, which are nonetheless serious issues. Rather use an [Isolating Proxy](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/IsolatingProxy) | - An Isolating Proxy requires at least two machines. Those machines can be either virtual machines or two physically isolated machines. Both machines are connected through an isolated LAN. One machine is called Gateway. The other one is called Workstation. |

**Conclusion**:

- The best method is using Isolating Proxy, mostly done by Whonix with [Security by Isolation](https://www.whonix.org/wiki/About#Security_by_Isolation) to have online anonymity via Tor. The Gateways runs Tor processes while the Workstation runs user applications on a completely isolated network, therefore only connections through Tor are permitted. Read [Whonix design](https://www.whonix.org/wiki/Main_Page#Whonix_%E2%84%A2_Design)

- The second best is Transparent Proxy, mostly done by Tails [implementation](https://tails.boum.org/contribute/design/#index30h3) and [TorBox](https://github.com/radio24/TorBox/blob/master/etc/tor/torrc). It does not have security against an infected host with root privileges or access to the tor user, as it can control the tor process directly, altough onion-grater can filter on port 9051, it does not filter on port 9052 and the unix domain socket /run/tor/control. It can route all traffic on a standalone machine through Tor and every network application will make its TCP connections through Tor, no application will be able to reveal your IP address by connecting directly. The other option is creating an anonymizing middlebox that intercepts traffic from other machines and redirects it through Tor.

- Torsocks works on most cases but the drawbacks enough to expose user location and DNS leaks by not routing through Tor when the application is not using the libc or for instance uses raw syscalls, torsocks will be useless and the traffic will not go through Tor.

- Configuring application proxy settings is the last resort if the program respects proxy settings and breaks down when it can not connect via proxy anymore or if it does not have protocol leaks.

- If no method applies to you, you are more safe using Tor Browser to avoid DNS leaks and protocol leaks. Be aware browsers can increase the attack surface, such as fingerprintg of screen size, HTML5 canvas extraction, ad
dons not shipped with tor browser, any bookmark in a page unique to you and javascript based attacks. Some of these behaviours do not occurr on the *Safest* mode of Tor Browser. More details on [unsafe Tor Browser habits](https://www.whonix.org/wiki/Tor_Browser#Unsafe_Tor_Browser_Habits).


## Client Applications

Remember what was discussed on [methods](#methods), per application proxy settings are recommended against because regardless of your use of "correct" proxy settings and/or external applications for torification, some applications will use advanced techniques to determine your external non-Tor IP address. As said previously, those applications were never made with anonymity in mind, but were designed to evade firewalls to allow them to function as expected.

|Application|Protocol|Class|Application proxy settings|Force the application to use a proxy (torsocks)|Transparent Proxy|Isolating Proxy|
---|---|---|---|---|---|---
|[Mumble](#mumble)|VoIP|IM and Voice chat|DNS leaks|yes|yes|yes|
|[HexChat](#hexchat)|IRC|IM|yes|yes|yes|yes
|[Irssi](#irssi)|IRC|IM|unsupported|yes|yes|yes|
|[APT](#apt)|HTTP(S)|Package manager|yes|yes|yes|yes|
|[SSH](#ssh)|SSH|Remote administration|yes|yes|yes|yes|
|[wget](#wget)|FTP, HTTP(S)|Misc|yes|yes|yes|yes|
|[git](#git)|GIT, SSH, HTTP(S)|Misc|yes|yes|yes|yes|
|[gpg](#gpg)|HTTP(S), FTP, LDAP|Misc|yes|yes|yes|yes|
|[youtube-dl](#youtube-dl)|HTTP(S), SOCKS|Misc|yes|yes|yes|yes|
|[cURL](#apt)|FTP(S), HTTP(S), IMAP(S), LDAP(S), POP3(S), SCP, SFTP and many more|MISC|yes|yes|yes|yes|


## Mobile applications

### Orbot

On Android, configure [Orbot](https://guardianproject.info/apps/org.torproject.android/) to proxy the client application with Tor.

After downlo
ading (available on F-droid via Guardian Project repository), click the engine icon and select the applications to use Tor proxy, then to finish, enable `VPN mode`.

It is also posible to [build](https://github.com/guardianproject/orbot/blob/master/BUILD.md) Orbot.

Read also [this guide](https://nerdschalk.com/orbot/) for graphical interpretation.

### TorBox

If you have a [TorBox](https://github.com/radio24/TorBox) (Tor router), a separate host that creates a WiFi that routes data over the Tor network, connecting to this LAN is enough.

### Comparison

Orbot requires and Android operating system and it is an external wrapper to force the application to use a SOCKS proxy. Vulnerabilities of this method are that applications can try to circumnvent and router over plain net.

TorBox requires a dedicated machine, normally a Raspberry Pi to serve as the router. It is less know than Orbot meaning less eyes on the code, but instead proxyfying the applications as Orbot does, it serves as an anonymizing middlebox (the router) that intercepts traffic from the clients and redirects  it through Tor.

The other option is creating an anonymizing middlebox that intercepts traffic from other machines and redirects it through Tor.


## Desktop applications

### Configure tor

Download tor:
```sh
sudo apt install -y tor
```

The tor package comes pre-configured on Debian, but in the case it is not found on `/usr/share/tor/tor-service-defaults-torrc` because it was built from source or deleted, add the following line to your tor configuration file, normally `/etc/tor/torrc`:
```
SocksPort 9050
```

### Connect via Tor

`curl` is just an example

1. **Application proxy settings**

**Warning**: depending on the implementation, it may leak DNS request.

And on the client application, normally on `Network` -> `Proxy`, setup `SOCKS5` proxy with `Address: 127.0.0.1` and `Port: 9050`.

Usage:
```sh
curl -x socks5h://127.0.0.1:9050 https://check.torproject.org/api/ip
```

2. **Enforce proxy**

Normally `torsocks` or `orbox`.

**Warning**: if the applications does not use `LD_PRELOAD` and do raw syscalls, it is gonna leak DNS requests.

Usage:
```sh
torsocks curl https://check.torproject.org/api/ip
```

3. **Transparent Proxy**

**Warning**:  Too many non-IP related leaks, which are nonetheless serious issues.

Usage:
```
curl https://check.torproject.org/api/ip
```

4. **Isolating Proxy**

All trafic must be routed through tor, no need to chage anything.

Usage:
```
curl https://check.torproject.org/api/ip
```

### Mumble

From mumble manual page:

_Mumble is an open source, low-latency, high quality voice chat software primarily intended for use while gaming._

Read also [TPO TorifyHowTo](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Mumble) and [Whonix wiki](https://www.whonix.org/wiki/VoIP#Mumble_Client).

Install mumble:
```sh
sudo apt install -y mumble
```

Torify mumble:
```
torsocks mumble
```

**Warning**: Do not use mumble proxy settings, as of today (2021-01-25), mumble leaks DNS requests.


### HexChat

From hexchat site page:

_HexChat is an IRC client based on XChat, but unlike XChat it’s completely free for both Windows and Unix-like systems. Since XChat is open source, it’s perfectly legal. For more info, please read the Shareware background._

Read also [TPO TorifyHowTO](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/HexChat) and [Whonix wiki](https://www.whonix.org/wiki/HexChat).

```sh
sudo apt install -y hexchat hexchat-otr
```

When the chat window opens, click the `Settings` drop-down menu on the toolbar and select `Preferences`, then select `Network Setup` from the leftside menu. Configure `Proxy server` with your SOCKS infromation.


### Irssi

From irssi manual page:

_Irssi  is  a  modular  Internet Relay Chat client; it is highly extensible and very secure. Being a fullscreen, termcap based client with many features, Irssi is easily extensible through scripts and modules._

Read also [TPO TorifyHowTO](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/irssi).

Install irssi:
```sh
sudo apt install -y irssi
```

#### Torsocks

Torify irssi:
```
torsocks irssi
```

#### MapAddress

Or without Torsocks, use MapAddress on your torrc. This will allow you to connect to the local 10.10.x address directly, and Tor will translate it to the desired address. Note: The map address is generic, though it must be one not in use on your local network.
```
MapAddress 10.10.10.10 examplesite.onion
```
Then start irssi as you normally would.


### APT

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


### SSH

From OpenSSH manual page:

_ssh (SSH client) is a program for logging into a remote machine and for executing commands on a remote machine.  It is intended to provide secure encrypted communications between two untrusted hosts over an insecure network.  X11 connections, arbitrary TCP ports and UNIX-domain sockets can also be forwarded over the secure channel._

Read also [TPO TorifyHowTO ssh](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/ssh).

**Warning**: 'ssh some.host' will leak your UNIX username. If you do 'ssh theloginyouwant@some.host' it will not leak your username. That is why we suggest using non-identifying usernames on your machines to prevent such leaks in the first place.

**Warning**: OpenSSH has a feature for looking up remote host keys in SSHFP DNS records;  don't use it, or it will try to resolve hostnames before it invokes your ProxyCommand and creates a leak.  To make sure this doesn't happen, pass -o VerifyHostKeyDNS=no on your ssh command line. A good command for checking for DNS leakage is: `tcpdump -vvvv -i <your_device> dst port 53`

#### Torsocks

To use SSH with torsocks, simply use the command:
```sh
torsocks ssh loginname@example.com
```
You may want to add an alias like so:
```sh
alias ssh-tor='torsocks ssh'
```
Then you can simply issue the command `ssh-tor example.com`.

#### netcat-openbsd

Install netcat-openbsd
```sh
sudo apt install -y netcat-openbsd
```

When using netcat-openbsd, you can use the ssh ProxyCommand option:
```sh
ssh -o "ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p" <target_host>
```

To do it for every `.onion` host, use globs and edit your `~/.ssh/config` to look something like this:
```
host *.onion
    user bar
    port 22
    ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p
```

If preferred, it is possible to make an alias for this and place it in your `~/.bash_aliases` like so:
```
alias ssh-tor='ssh -o "ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p"'
```
Then you can simply issue the command `ssh-tor example.com`.


### Youtube-dl

From youtube-dl manual page:

_youtube-dl  is  a  command-line program to download videos from YouTube.com and a few more sites.  It requires the Python interpreter, version 2.6, 2.7, or 3.2+, and it is not platform specific.  It should work on your Unix box, on Windows or on macOS.  It is  released  to  the  public  domain, which means you can modify it, redistribute it or use it however you like._

Read also [TPO TorifyHowTO youtube-dl](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install youtube-dl:
```sh
sudo apt install -y youtube-dl
```

#### Proxy

```sh
youtube-dl --proxy socks5://127.0.0.1:9050/ https://www.youtube.com/watch?v=STRING
```

#### Torsocks

```sh
torsocks youtube-dl https://www.youtube.com/watch?v=STRING
```


### Wget

From wget manual page:

_Wget is a free utility for non-interactive download of files from the Web.  It supports HTTP, HTTPS, and FTP protocols, as well as retrieval through HTTP proxies._

Read also [TPO TorifyHowTO wget](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install wget:
```sh
sudo apt install wget
```

#### Proxy

In the `/etc/wgetrc` for system wide or `~/.wgetrc` for user only:
```sh
use_proxy=yes
http_proxy=127.0.0.1:9050
https_proxy=127.0.0.1:9050
```

#### Torsocks

Just prepend torsocks:
```sh
torsocks wget <URL>
```


### Curl

From curl manual page:

_curl is a tool to transfer data from or to a server, using one of the supported protocols (DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, MQTT, POP3, POP3S, RTMP, RTMPS, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET and TFTP). The command is  designed  to  work  without user interaction._

Read also [TPO TorifyHowTO cURL](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Misc).

Install curl:
```sh
sudo apt install curl
```

#### Proxy

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

#### Torsocks

Just prepend torsocks:
```sh
torsocks curl <URL>
```


### GPG

From gpg manual page:

_gpg  is  the OpenPGP part of the GNU Privacy Guard (GnuPG). It is a tool to provide digital encryption and signing services using the OpenPGP standard. gpg features complete key management and all the bells and whistles you would expect from a full OpenPGP implementation._

Read also [TPO TorifyHowTO GnuPG](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/GnuPG).

Install gpg and dirmngr (to facilitate communication with keyservers):
```sh
sudo apt install gpg dirmngr
```

The option `--use-tor` switches Dirmngr and thus GnuPG into “Tor mode” to route all network access via the Tor Network. Certain other features are disabled in this mode. The effect of `--use-tor` cannot be overridden by any other command or even be reloading gpg-agent. The use of `--no-use-tor` disables the use of Tor. The default is to use Tor if it is available on startup or after reloading dirmngr."

Another option is to insert use-tor into the `~/.gnupg/dirmngr.conf` file.


### git

From git manual page:

_Git is a fast, scalable, distributed revision control system with an unusually rich command set that provides both high-level operations and full access to internals._

Read also [Pastly Use Git over Tor](https://matt.traudt.xyz/posts/2016-10-29-use-git-over-tor/).

Install git:
```sh
sudo apt install git
```

#### Proxy

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

#### Torsocks

Just prepend torsocks:
```sh
torsocks git clone http://xtlfhaspqtkeeqxk6umggfbr3gyfznvf4jhrge2fujz53433i2fcs3id.onion/project/web/community.git/
```