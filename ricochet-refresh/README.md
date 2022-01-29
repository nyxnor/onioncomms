# Ricochet-refresh

From its [README](https://github.com/blueprint-freespeech/ricochet-refresh#how-does-it-work):

_Ricochet Refresh uses the Tor network to establish a peer-to-peer connection between you and your contact. Ricochet Refresh creates a service on the Tor network which contacts can connect to. Tor's rendezvous system makes it extremely difficult for anyone to learn the identity of a Tor user, including you._

## Install

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

## Build

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
