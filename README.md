Firmware builder xwith Docker Container __And now with docker-compose__

======================

**Modified to use __docker-compose build__ and __docker-compose up__ to build and get the image out of the build.
**

This repository is intended to create a simple environment to generate builds of custom micropython firmware at [Odditive](https://odditive.com). However, you can also freely use it providing links to your repo as the arguments.

Usage
------------------

Using the build function of docker-compose we can consistently build a firmware image with modules frozen into the firmware.

This is a two stage build for an ESP32 micropython firmare.  Where the toolchain and the cross compiler is built in the first stage and micropython firmware is built in the second stage.

In the second stage, a module to be add to be frozen into the firmware.  

Create a local copy in the modules directory.  Then, in the file Dockerfile.uPybuild add a line like this:
```
ADD modules/foobar /micropython/ports/esp32/modules/foobar
```

To build use the docker-compose build like this:

```bash
docker-compose build
```

Now, the firmware is in the image that has just been built.  To get the firmware out of the image, there is another docker compose configuration to run a web server for a short amount of time.

Environment Variables need to be set for docker-compose to serve the firmware

`OUTIP` - IP address where the server is listening.

`SERVETIME` - Time (in seconds) that the server will run.

This command will run the server for 2 minutes.

```bash
docker-compose -f servefirmware.yml build
OUTIP=1.2.3.4 SERVETIME=120 docker-compose -f servefirmware.yml up
```

The output of that command will contain a line like this.  Use that location to pull the firmware.

```bash
Pull firmware here ----> http://1.2.3.4:8000/9e94ec38/firmware.bin
```

Now see the deployment section to erase and flash your ESP32

Old..

To freeze modules into the image 

Build the docker image:

```bash
  docker build -t odditive-micropython .
```

Use `build-args` to provide arguments such as:

```bash
  docker build -t odditive-micropython --build-arg BRANCH=add-wps-and-netstatus .
```

Then create a container from the image using:

```bash
  docker create --name odditive-micropython odditive-micropython
```

Then copy the the firmware into your filesystem.

```bash
  docker cp odditive-micropython:/micropython/ports/esp32/build/firmware.bin firmware.bin
```


Deployment
------------------

Clear your ESP:

```bash
  esptool.py --chip esp32 --port /dev/tty.SLAB_USBtoUART erase_flash
```

Install firmware into the ESP:

```bash
  esptool.py --chip esp32 --port /dev/tty.SLAB_USBtoUART --baud 460800 write_flash -z 0x1000 firmware.bin
```

Configurations
------------------

Environment Variables to set for docker-compose to serve the firmware

`OUTIP` - IP address where the server is listening.

`SERVETIME` - Time (in seconds) that the server will run.

OLD...

Provided arguments are following:

`REPOSITORY` - Link to your fork of micropython.

`BRANCH` - Git branch of your fork to be deployed.

`VERSION` - Hash of supported ESP-IDF version.
