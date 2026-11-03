#!../../bin/linux-x86_64/granville307-ioc

< envPaths

cd "${TOP}"

dbLoadDatabase "dbd/granville307-ioc.dbd"
granville307_ioc_registerRecordDeviceDriver pdbbase

epicsEnvSet("STREAM_PROTOCOL_PATH", "${TOP}/db")

# Replace this loopback endpoint with the configured serial gateway.
epicsEnvSet("ASYN_PORT", "GP307")
epicsEnvSet("TCP_IP", "127.0.0.1")
epicsEnvSet("TCP_PORT", "4001")
epicsEnvSet("PV_PREFIX", "GP307")
epicsEnvSet("PROTO", "granville307-rs232.proto")
epicsEnvSet("ADDR", "01")
epicsEnvSet("PRES_UNIT_DEFAULT", "0") # 0 = Torr, 1 = Bar; can be changed at runtime.

drvAsynIPPortConfigure("${ASYN_PORT}", "${TCP_IP}:${TCP_PORT}", 0, 0, 0)

# For direct serial, replace drvAsynIPPortConfigure above with:
# drvAsynSerialPortConfigure("${ASYN_PORT}", "/dev/ttyUSB0", 0, 0, 0)
# asynSetOption("${ASYN_PORT}", 0, "baud", "300")
# asynSetOption("${ASYN_PORT}", 0, "bits", "7")
# asynSetOption("${ASYN_PORT}", 0, "parity", "none")
# asynSetOption("${ASYN_PORT}", 0, "stop", "2")

# StreamDevice applies the terminators configured in the selected protocol file.
# For RS-485, use granville307-rs485.proto (which uses CR instead of CRLF).
dbLoadRecords("db/granville307.db", "P=${PV_PREFIX},PORT=${ASYN_PORT},ADDR=${ADDR},PROTO=${PROTO},PRES_UNIT_DEFAULT=${PRES_UNIT_DEFAULT}")

cd "${TOP}/iocBoot/${IOC}"
iocInit
