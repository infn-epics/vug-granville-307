#!../../bin/linux-x86_64/granville307-ioc

# DEVIL611 old-control VUG set using the Granville-Phillips 307 RS-485
# protocol over the Moxa RS-422 serial line.
#
# Moxa serial-lines reference: NPort 1601 (192.168.192.40), port 8,
# configured for 9600 baud, 8 data bits, no parity, 2 stop bits,
# no flow control, RS-422. Configure NPort port 8 in TCP Server mode;
# its default local TCP port is 4008 (change MOXA_TCP_PORT if customized).
#
# The old DEVIL611.DBSta assigns the eight VUGs EXTRA values 1 through 8.
# This startup uses those values as the 307 RS-485 hexadecimal addresses
# 01 through 08. Confirm that the controller address switches are set this way.
# This also assumes the Moxa TX/RX pairs are wired to the 307 RS-485 four-wire
# interface as described in the controller manual, and that each 307 is set to
# 9600 baud, 8 data bits, no parity, 2 stop bits. The 307 factory framing is 8N1.

< envPaths

cd "${TOP}"

dbLoadDatabase "dbd/granville307-ioc.dbd"
granville307_ioc_registerRecordDeviceDriver pdbbase

epicsEnvSet("STREAM_PROTOCOL_PATH", "${TOP}/db")

epicsEnvSet("ASYN_PORT", "DEVIL611_VUG")
epicsEnvSet("MOXA_IP", "192.168.192.40")
epicsEnvSet("MOXA_TCP_PORT", "4008")
epicsEnvSet("PROTO", "granville307-rs485.proto")
#epicsEnvSet("PROTO", "granville307-rs232.proto")
epicsEnvSet("PRES_UNIT_DEFAULT", "0") # 0 = Torr, 1 = Bar; can be changed at runtime.

# Moxa port 8 provides the serial framing; the IOC connects to its raw TCP socket.
drvAsynIPPortConfigure("${ASYN_PORT}", "${MOXA_IP}:${MOXA_TCP_PORT}", 0, 0, 0)

# Series 307 RS-485 address per legacy DEVIL611 EXTRA value.
# dbLoadRecords("db/granville307.db", "P=VUGTM001,PORT=${ASYN_PORT},ADDR=01,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
# dbLoadRecords("db/granville307.db", "P=VUGTS001,PORT=${ASYN_PORT},ADDR=02,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
# dbLoadRecords("db/granville307.db", "P=VUGTT001,PORT=${ASYN_PORT},ADDR=03,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
dbLoadRecords("db/granville307.db", "P=VUGTR001,PORT=${ASYN_PORT},ADDR=04,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
dbLoadRecords("db/granville307.db", "P=VUGTL001,PORT=${ASYN_PORT},ADDR=05,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
dbLoadRecords("db/granville307.db", "P=VUGA3001,PORT=${ASYN_PORT},ADDR=06,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
dbLoadRecords("db/granville307.db", "P=VUGA2001,PORT=${ASYN_PORT},ADDR=07,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")
dbLoadRecords("db/granville307.db", "P=VUGA1001,PORT=${ASYN_PORT},ADDR=08,PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")

cd "${TOP}/iocBoot/${IOC}"
iocInit
