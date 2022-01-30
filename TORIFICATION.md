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

### Methods examples

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

Normally `torsocks` or `orbot`.

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


### Method conclusion:

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
|Ricochet-refresh|HTTP|IM|yes|uncessesary|yes|yes
|OnionShare|HTTP|IM, site, dropbox|unecessary|unecessary|yes|yes|
|Magic-Wormhole|HTTP|dropbox|yes|unsupported|yes|yes|
|Mumble|VoIP|IM, voice|unsupported|yes|yes|yes|
|Asterisk|VoIP|IM, voice|todo|todo|todo|todo|
|Pidgin|XMPP|IM|yes|yes|yes|yes|
|Newsboat|RSS|News|yes|yes|yes|yes|
|QuiteRSS|RSS|News|yes|yes|yes|yes|
|HexChat|IRC|IM|yes|yes|yes|yes|
|Irssi|IRC|IM|unsupported|yes|yes|yes|
|Remmina|VNC, RDP, SSH|Remote administration|todo|todo|todo|todo
|OpenSSH|SSH|Remote administration|yes|yes|yes|yes|
|APT|HTTP(S)|Misc|yes|yes|yes|yes|
|wget|FTP, HTTP(S)|Misc|yes|yes|yes|yes|
|git|GIT, SSH, HTTP(S)|Misc|yes|yes|yes|yes|
|gpg|HTTP(S), FTP, LDAP|Misc|yes|yes|yes|yes|
|youtube-dl|HTTP(S), SOCKS|Misc|yes|yes|yes|yes|
|cURL|FTP(S), HTTP(S), IMAP(S), LDAP(S), POP3(S), SCP, SFTP and many more|Misc|yes|yes|yes|yes|

- **Unsupported**: can not be configured or can be configured but does not work (leaks DNS or/and IP for example).
- **Unecessary**: client application already run as a onion service, spawning a tor process or connecting to the current controller.
