# Remote-administration

This section is dedicated to administrators of remote servers and how to interact with external hosts over Tor.

---
Table of contents
---

- [Remote-administration](#remote-administration)
  - [SSH](#ssh)
    - [OpenSSH Client](#openssh-client)
      - [Torsocks ssh](#torsocks-ssh)
      - [netcat-openbsd ssh](#netcat-openbsd-ssh)
    - [OpenSSH Server](#openssh-server)
  - [VNC](#vnc)

---

## SSH

From OpenSSH manual page:

_ssh (SSH client) is a program for logging into a remote machine and for executing commands on a remote machine.  It is intended to provide secure encrypted communications between two untrusted hosts over an insecure network.  X11 connections, arbitrary TCP ports and UNIX-domain sockets can also be forwarded over the secure channel_

Read also [TPO TorifyHowTO ssh](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/ssh).

### OpenSSH Client

Install the openssh-client:
```sh
sudo apt install -y openssh-client
```

**Warning**: 'ssh some.host' will leak your UNIX username. If you do 'ssh theloginyouwant@some.host' it will not leak your username. That is why we suggest using non-identifying usernames on your machines to prevent such leaks in the first place.

**Warning**: OpenSSH has a feature for looking up remote host keys in SSHFP DNS records;  don't use it, or it will try to resolve hostnames before it invokes your ProxyCommand and creates a leak.  To make sure this doesn't happen, pass -o VerifyHostKeyDNS=no on your ssh command line. A good command for checking for DNS leakage is: `tcpdump -vvvv -i <your_device> dst port 53`

#### Torsocks ssh

To use SSH with torsocks, simply use the command:
```sh
torsocks ssh loginname@example.com
```
You may want to add an alias like so:
```sh
alias ssh-tor='torsocks ssh'
```
Then you can simply issue the command `ssh-tor example.com`.

#### netcat-openbsd ssh

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

### OpenSSH Server

Install the openssh-server:
```sh
sudo apt install -y openssh-server
```

Create an onion service for your ssh server. Add to your torrc:
```sh
HiddenServiceDir /var/lib/tor/services/ssh
HiddenServiceVersion 3
HiddenServicePort 22 127.0.0.1:22
```

Reload tor:
```sh
sudo systemctl reload tor
```

## VNC

From remmina manual page:

_Remmina is a remote desktop client written in GTK+, aiming to be useful for system administrators and travellers, who need to work with lots of remote computers in front of either large monitors or tiny netbooks. Remmina supports multiple network protocols in an integrated and consistent user interface.  Currently RDP, VNC, SSH, SPICE, NX, XDMCP, and WWW are supported._

_Remmina supports multiple network protocols in an integrated and consistent user interface. Currently RDP, VNC, SPICE, WWW, NX, XDMCP, EXEC and SSH are supported._

Read also [Whonix wiki](https://www.whonix.org/wiki/Remote_Administration#Remmina), [Remmina wiki](https://gitlab.com/Remmina/Remmina/-/wikis/home).

Install remmina:
```sh
sudo apt install -y remmina
```
