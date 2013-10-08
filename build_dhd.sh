#!/bin/bash
#NF3101 Driver Automation Porting
#Driver version: 1.88.2
#Module: NF3101
#BSP: Timesys R90
#Date: 2013.4.10
#Copyrighted: nFore Technology Inc. 2013
#Author: cj.chang@nforetek.com 
#Users guide:
# 1. Create bcmdhd folder under timesys folder
# 2. untar driver package under bcmdhd folder. Put this script under bcmdhd folder too,
# 3. run this script.
#History:
#2013.05.06 Yusuke add make clean before building driver
#2013.06.18 CJ add BUILD_TARGET option

curdir=`pwd`
TIMESYSDIR=`cd ..; pwd`
BCMDIR=${curdir}"/src"
SOURCEFILE=$BCMDIR/dhd/linux/dhd-cdc-sdmmc-cfg80211-gpl-3.0.35/dhd.ko
## TARGETFILE=$TIMESYSDIR/factory-20130218/build_armv7l-timesys-linux-gnueabi/rfs/lib/modules/3.0.35-ts-armv7l-2026-geaaf30e/kernel/drivers/net/wireless/bcmdhd/bcmdhd.ko
TARGETFILE=${curdir}/dhd.ko

N4_ARCH="arm"
N4_CROSS_COMPILE=$TIMESYSDIR"/factory-20130218/build_armv7l-timesys-linux-gnueabi/toolchain/bin/armv7l-timesys-linux-gnueabi-"
N4_LINUXVER="3.0.35"
N4_LINUXDIR=$TIMESYSDIR"/linux-3.0"
# N4_MAKELOG=0
N4_MAKELOG=1
N4_MAKETARGET="dhd-cdc-sdmmc-cfg80211-gpl"


###############################################################################
#                            nFore patch options

## (nFore) Add flags for Linux kernel which is backported P2P functions
## from 3.4.
#export N4_P2P_PATCH=y

## (nFore) For increasing Tx/Rx speed
export N4_THROUGHPUT_PATCH=y

## (nFore) "bus:txglom" - If set this, Rx throughput will decrease.
## I don't know why.
#export N4_ENABLE_TXGLOM=y

###############################################################################

cd ${BCMDIR}/dhd/linux
echo `env LC_ALL=C date`
make CROSS_COMPILE=${N4_CROSS_COMPILE} ARCH=${N4_ARCH} LINUXDIR=${N4_LINUXDIR} LINUXVER=${N4_LINUXVER} KBUILD_VERBOSE=${N4_MAKELOG} clean
make CROSS_COMPILE=${N4_CROSS_COMPILE} ARCH=${N4_ARCH} LINUXDIR=${N4_LINUXDIR} LINUXVER=${N4_LINUXVER} KBUILD_VERBOSE=${N4_MAKELOG} ${N4_MAKETARGET}

if test $? != 0
then
	echo "Making bcmdhd driver error!! Building procedure is terminated."
	echo ""
	exit 1
fi

if test -f $SOURCEFILE
then
	echo "cp $SOURCEFILE $TARGETFILE"
else
	echo "$SOURCEFILE is not exist!! Please check building process!!"
	exit 2
fi

rm -f $TARGETFILE
cp -f $SOURCEFILE $TARGETFILE
if test $? != 0
then
	echo ""
	echo "Copy driver error!!"
	exit 3
fi

if test -f $TARGETFILE 
then
	echo ""
	echo "  Bcmdhd driver installed OK."
	exit 4
fi


