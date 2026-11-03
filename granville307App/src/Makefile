TOP = ../..
include $(TOP)/configure/CONFIG

PROD_IOC = granville307-ioc
DBD += granville307-ioc.dbd
granville307-ioc_DBD += base.dbd
granville307-ioc_DBD += asyn.dbd drvAsynIPPort.dbd drvAsynSerialPort.dbd stream.dbd
granville307-ioc_SRCS += granville307-ioc_registerRecordDeviceDriver.cpp
granville307-ioc_SRCS_DEFAULT += granville307-iocMain.cpp
granville307-ioc_LIBS += asyn stream
granville307-ioc_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
