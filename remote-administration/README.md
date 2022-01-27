# SSH

From OpenSSH manual page:

_ssh (SSH client) is a program for logging into a remote machine and for executing commands on a remote machine.  It is intended to provide secure encrypted communications between two untrusted hosts over an insecure network.  X11 connections, arbitrary TCP ports and UNIX-domain sockets can also be forwarded over the secure channel_

## Client

Install the openssh-client:
```sh
sudo apt install -y openssh-client
```

### Hardening

Read also [kicksecure Wiki](https://www.kicksecure.com/wiki/SSH).

Generate a new key pair:
```
ssh-keygen -o -a 75 -t ed25519
```
- `-o` produces a key that is compatible with OpenSSH instead of the older style .pem.
- `-a` refers to the number of rounds of KDF (key derivation function). This strengthens the key against a brute force attack to break the passphrase if the (private) key were to be stolen. A value of 75 to 100 is more than adequate. Remember that the more rounds that are specified, the longer it takes to authenticate (sign in). This depends on your CPU, your workload at the time of sign in, the amount of cores, and available memory among other factors.
- `-t` specifies what type of key to generate. The choices are: rsa, ecdsa and ed25519. RSA and ECDSA are older keys, and OpenSSH recommends ed25519 as the best choice.

Copy the key to the server you want to sign into:
```ssh
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@127.0.0.1
```
- This only needs to be done once per server.
- Replace `127.0.0.1` with the actual IP address of the server.
- Replace `root` for the user you will actually sign in.
- If this is a first time login and/or password based login, enter the SSH login password. Password should be provided by server provider. No password might be provided if the server provider already pre-installed a ssh key.

On the client configuration file `/etc/ssh/ssh_config` or `/etc/ssh/ssh_config.d/hadening.conf`:
```
Host *

## ipv4
AddressFamily inet

IdentityFile ~/.ssh/id_ed25519

Port 22
Protocol 2
ForwardX11 no
PubkeyAuthentication yes
StrictHostKeyChecking ask
VisualHostKey yes
HashKnownHosts yes
User user
Host host
SendEnv LANG LC_*

## Strongest ciphers:
Ciphers chacha20-poly1305@openssh.com

## Most secure MACs:
MACs hmac-sha2-512-etm@openssh.com

## Secure Kex algos:
KexAlgorithms curve25519-sha256

Tunnel no
#TunnelDevice any:any
#PermitLocalCommand no
#ProxyCommand ssh -q -W %h:%p gateway.example.com
```

## Server

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

### Hardening

Read also [kicksecure Wiki](https://www.kicksecure.com/wiki/SSH).


# VNC

From remmina manual page:

_Remmina is a remote desktop client written in GTK+, aiming to be useful for system administrators and travellers, who need to work with lots of remote computers in front of either large monitors or tiny netbooks. Remmina supports multiple network protocols in an integrated and consistent user interface.  Currently RDP, VNC, SSH, SPICE, NX, XDMCP, and WWW are supported._

_Remmina supports multiple network protocols in an integrated and consistent user interface. Currently RDP, VNC, SPICE, WWW, NX, XDMCP, EXEC and SSH are supported._

Read also [Whonix wiki](https://www.whonix.org/wiki/Remote_Administration#Remmina), [Remmina wiki](https://gitlab.com/Remmina/Remmina/-/wikis/home).

Install remmina:
```sh
sudo apt install -y remmina
```
