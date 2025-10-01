

# Yocto Raspberry Pi 4B Build Environment (using Docker)

This repository provides a **Docker-based Yocto build environment** for creating custom Linux images for the Raspberry Pi 4B.  
It is preconfigured to support **embedded features**, including IIO (Industrial I/O) and serial communication.

---

## Features

- Full Yocto Kirkstone environment in Docker.
- Pre-cloned layers:
  - `poky`
  - `meta-raspberrypi`
  - `meta-openembedded`
- Non-root user for safe builds.
- Optional IIO support via `meta-iio` (manual addition).
- Ready to build `core-image-minimal` or custom images.

---

## Getting Started

### 1. Build the Docker image

```bash
git clone https://github.com/<your-username>/yocto-rpi4-docker.git
cd yocto-rpi4-docker
docker build -t yocto-rpi4-build .
````

### 2. Run the container

```bash
docker run -it --rm yocto-rpi4-build
```

This will drop you into a shell inside the container.

### 3. Initialize the Yocto build environment

Inside the container, run:


```bash
source ~/poky/oe-init-build-env ~/yocto-build

```

### 4. Configure your build

Edit `~/yocto-build/conf/local.conf`:

```conf
MACHINE = "raspberrypi4-64"

# Optional embedded features
IMAGE_INSTALL_append = " iio-utils libiio python3-libiio setserial"
```

Ensure `bblayers.conf` includes:

```conf
/home/yocto/poky/meta
/home/yocto/poky/meta-poky
/home/yocto/poky/meta-yocto-bsp
/home/yocto/meta-openembedded/meta-oe
/home/yocto/meta-openembedded/meta-python
/home/yocto/meta-raspberrypi
```

Add `meta-iio` here if you want IIO support.

### 5. Build your image

```bash
bitbake core-image-minimal
```

After a successful build, the images are located in:

```text
~/yocto-build/tmp/deploy/images/raspberrypi4-64/
```

---

## Notes

* Yocto builds **must not run as root**.
* This environment uses Docker to **isolate dependencies** and simplify host setup.
* You can expand this repository with additional layers, recipes, or scripts for embedded applications.

---

## Future Improvements

* Pre-configured `meta-iio` support.
* Scripts to flash images directly to SD cards.
* Examples of adding custom drivers and embedded applications.

---

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

**Author:** Moafk
**Contact:** mwafa2sh@gmail.com

```
