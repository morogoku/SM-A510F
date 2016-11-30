#!/bin/bash


# SETUP
# -----

export ARCH=arm64
export SUBARCH=arm64
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-sabermod-7.0/bin/aarch64-
export CROSS_COMPILE=$BUILD_CROSS_COMPILE
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export KERNEL_VERSION="ADM-Kernel-MoroTEST-v0.1"
export KBUILD_BUILD_VERSION="1"

KERNEL_DEFCONFIG=exynos7580-custom_defconfig

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0



# FUNCTIONS
# ---------
FUNC_DELETE_PLACEHOLDERS()
{
	find . -name \.placeholder -type f -delete
        echo "Placeholders Deleted from Ramdisk"
        echo ""
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$MODEL ""

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage

	rm -f $RDIR/ramdisk/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/split_img/boot.img-zImage
	cd $RDIR/ramdisk
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img

}

FUNC_BUILD_FLASHABLES()
{
	cp image-new.img $RDIR/release/zip/boot.img
	cp image-new.img $RDIR/release/tar/boot.img

	cd $RDIR
	cd release/zip
	zip -5 -r $KERNEL_VERSION-$KBUILD_BUILD_VERSION.zip *
	rm boot.img
	cd ..
	cd tar
	tar cf $KERNEL_VERSION-$KBUILD_BUILD_VERSION.tar boot.img && ls -lh $KERNEL_VERSION-$KBUILD_BUILD_VERSION.tar
	rm boot.img

}

# MAIN PROGRAM
# ------------
(
	sh ./clean.sh
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_FLASHABLES
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo ""
) 2>&1	 | tee -a ./build.log

	echo "Your flasheable release can be found in the release/zip or tar folder"
	echo ""


