# Granville-Phillips Series 307 IOC

EPICS IOC support for the Granville-Phillips Series 307 Vacuum Measurement Controller. The IOC uses asyn and StreamDevice to read pressure and status and to issue the documented ion-gauge and degas commands.

## Supported protocol options

- RS-232 command/response, with CRLF terminators.
- RS-485 addressed command/response, with CR terminators and a hexadecimal controller address.
- TCP-to-serial gateways and direct serial ports, configured in `iocBoot/iocgranville307/st.cmd`.

The IOC does not assume which gauge modules are installed. A read for a missing channel can return the controller's high numeric sentinel. Raw pressure records alarm INVALID for values at or above `1e8`; the value remains visible as the raw device response. For converted `PRES_RB` values, configure the controller to report Torr, then select Torr or Bar from `$(P):UNIT_RB`.

State-changing records control IG1, IG2, and degas. An `OK` response means the command was accepted, not that the requested state was achieved. Check the corresponding pressure or degas status readback. The manual also documents `INVALID` replies when repeating an already-active state or when a precondition is not met; StreamDevice reports that as a write error.

## Build

The default `configure/RELEASE` uses the lab EPICS installation under `/epics`. Override paths in `configure/RELEASE.local` for another installation. Required modules are EPICS Base, asyn, and StreamDevice.

```sh
make
```

## Configure and run

Edit the connection settings near the top of `iocBoot/iocgranville307/st.cmd`:

- `TCP_IP` and `TCP_PORT` for a serial gateway (or replace the TCP driver call with the direct serial example there).
- `PROTO` to `granville307-rs232.proto` or `granville307-rs485.proto`.
- `ADDR` to the RS-485 hexadecimal address (ignored by RS-232).
- Keep the physical 307 pressure output configured in Torr. `PRES_UNIT_DEFAULT` in the startup file selects the initial unit (`0` = Torr, `1` = Bar); the OPI can switch `$(P):UNIT_RB` between units at runtime.

The sample startup defaults to RS-232 at a loopback TCP endpoint so it cannot operate a real controller until configured. Match the serial framing at the gateway to the controller switch settings. The Series 307 RS-232 factory defaults in manual 307024 Rev. A are 300 baud, 7 data bits, no parity, and 2 stop bits; the RS-485 defaults are 9600 baud, 8 data bits, no parity, and 1 stop bit. RS-232 handshaking and RS-485 timing/address rules are described in `docs/Granville_Phillips_307_Vacuum_Controller_Instruction_Manual.pdf`.

For the DEVIL611 VUG set, `iocBoot/iocgranville307/st-vug-oldcontrol.cmd` connects with `drvAsynIPPortConfigure` to NPort 1601 at `192.168.192.40:4008`. The active database loads are VUGTR001 at address 04, VUGTL001 at 05, VUGA3001 at 06, VUGA2001 at 07, and VUGA1001 at 08; VUGTM001 through VUGTT001 at addresses 01-03 are currently commented out. Configure Moxa port 8 in TCP Server mode and its serial side for 9600/8N2, as listed in the line reference. TCP port 4008 is the NPort default for serial port 8; change `MOXA_TCP_PORT` if it has been customized. The address mapping follows the legacy `EXTRA` values 1-8; confirm the 307 address switches match before using this startup. The 307 RS-485 modules must also be set to 9600/8N2 (their factory framing is 8N1), and the Moxa TX/RX pairs must be wired to the 307 four-wire RS-485 interface per the manual.

## iBec deployment

The Granville 307 support module is in `ibek-support-infn/granville307`, and the IOC template is `ibek-templates/templates/vac/granville/granville307.yaml.j2` (`template: granville307`). `epik8s-btf/deploy/values-vac.yaml` lists each gauge by name, sensor channel, and decimal RS-485 address. The template converts that address to the controller's two-digit hexadecimal wire format. RS-485 is the protocol default. The tested VUGTR001 uses decimal address `4` (`04` on the wire); the remaining addresses follow the legacy `EXTRA` values. The startup unit defaults to Bar (`unit_default: 1`), and operators can switch each gauge's `UNIT_RB` between Torr and Bar at runtime.

```sh
cd iocBoot/iocgranville307
../../bin/linux-x86_64/granville307-ioc st.cmd
```

Use the DEVIL611 VUG startup instead with:

```sh
../../bin/linux-x86_64/granville307-ioc st-vug-oldcontrol.cmd
```

## PVs

Set `PV_PREFIX` in `st.cmd` for the desired prefix (it is passed as database macro `P`). Records include:

- Raw pressure PVs in Torr: `$(P):IG1:Pressure`, `$(P):IG2:Pressure`, `$(P):IG:Pressure`, `$(P):CG1:Pressure`, `$(P):CG2:Pressure`
- UniVac-style readbacks: `$(P):IG1:PRES_RB`, `$(P):IG2:PRES_RB`, `$(P):IG:PRES_RB`, `$(P):CG1:PRES_RB`, `$(P):CG2:PRES_RB`; `$(P):UNIT_RB` is the writable Torr/Bar selector.
- UniVac-style state readbacks: `$(P):IG1:STATE_RB`, `$(P):IG2:STATE_RB`, `$(P):IG:STATE_RB`, `$(P):CG1:STATE_RB`, `$(P):CG2:STATE_RB`. These are 1 when the pressure reply is below the 307's high-pressure sentinel and 0 otherwise; they indicate valid measurement availability, not serial-link health.
- `$(P):IG1:Valid`, `$(P):IG2:Valid`, `$(P):IG:Valid`, `$(P):CG1:Valid`, `$(P):CG2:Valid`
- `$(P):IG1:Enable`, `$(P):IG2:Enable`, `$(P):Degas:Enable`
- `$(P):Degas:Status`, `$(P):Relay1:Status` through `$(P):Relay6:Status`

The IOC implements the controller protocol and generic record set, but the repository does not contain the commissioned endpoint, installed-module inventory, site-specific channel map, or interlock policy. The six relay PVs expose instrument status by channel number only; map relay functions and apply access security at deployment.
