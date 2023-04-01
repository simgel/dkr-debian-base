![GitHub](https://img.shields.io/github/license/simgel/dkr-debian-base?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/simgel/dkr-debian-base?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/simgel/dkr-debian-base?style=for-the-badge)

## About

Minimal Debian base image with nightly updates.
The uncompressed image is `~80MB`  in size.

## Usage

```Dockerfile
FROM ghcr.io/simgel/dkr-debian-base:bullseye
```


## Optimizations

The image contains a random/unique ID. Any Images derived from this base image can use this ID to identify updates of this image.

```sh
cat /opt/dkr-image/simgel/dkr-debian-base.id

docker run --rm ghcr.io/simgel/dkr-debian-base:bullseye cat /opt/dkr-image/simgel/dkr-debian-base.id
```

### Mirror

Apt uses a faster mirror from leaseweb: `http://mirror.leaseweb.net/debian` 

### DNS

The default DNS server is Quad9: `9.9.9.9`


## License

Distributed under the MIT License. See `LICENSE` for more information.


## Acknowledgments

* [debian](https://www.debian.org/)
* [debuerreotype](https://github.com/debuerreotype/debuerreotype): Slimify script optimizations
* [Leaseweb](https://mirror.leaseweb.net/): Debian mirror
* [Quad9](https://www.quad9.net/): DNS Server