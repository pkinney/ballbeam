BallBeam Control with PIDControl
===

Example application using [PIDControl](https://github.com/pkinney/pid_control) to control a ball-beam system.


Running Locally
---

You can start the application just like any Phoenix project:

```bash
iex -S mix phx.server
```

The repository includes a simple simulator that will be injected when `MIX_TARGET` is set to `host`, so you can run it locally without needing any hardware.


Hardware Setup
---

Coming Soon.


Flashing to a Device
---

You can burn the first image with the following commands:

```bash
# If you want to enable wifi:
# export NERVES_SSID="NetworkName" && export NERVES_PSK="password"
MIX_ENV=prod MIX_TARGET=host mix do deps.get, assets.deploy
MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware, burn
```

Once the image is running on the device, the following will build and update the firmware
over ssh.

```bash
# If you want to enable wifi:
# export NERVES_SSID="NetworkName" && export NERVES_PSK="password"
MIX_ENV=prod MIX_TARGET=host mix do deps.get, assets.deploy
MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware, upload your_app_name.local
```


Network Configuration
---

The network and WiFi configuration are specified in the `target.exs` file.  In order to
specify the network name and password, they must be set as environment variables `NERVES_SSID`
`NERVES_PSK` at runtime.

If they are not specified, a warning will be printed when building firmware, which either
gives you a chance to stop the build and add the environment variables or a clue as to 
why you are no longer able to access the device over WiFi.

