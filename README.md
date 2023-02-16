
# guardian server

performs a full security audit of your linux server

![Linux](https://svgshare.com/i/Zhy.svg)

Version: Beta



## feature

- ClamAV test :heavy_check_mark:
- lynis test :heavy_check_mark:
- audit :heavy_check_mark:
- send audit by mail
- send audit by ntfy
- backup system 
- ssh alert 
## Requirement

- Lynis
- ClamAV
- bash
## Installation

```
git clone https://github.com/bubudotsh/guardian-server.git
cd guardian-server
chmod +x setup.sh
sudo ./setup.sh
```
## Configuration

The guardian server configuration happens in the file: 

```/usr/share/guardian-server/guardian.conf```
## Usage/Examples

```
sudo guardian 
```


## Authors

- [@bubudotsh](https://github.com/bubudotsh)

