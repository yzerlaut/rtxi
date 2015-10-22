#
# The Real-Time eXperiment Interface (RTXI)
# Copyright (C) 2011 Georgia Institute of Technology, University of Utah, Weill Cornell Medical College
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#	Created by Yogi Patel <yapatel@gatech.edu> 2014.1.31
#

#!/bin/bash

###############################################################################
# Set directory variable for compilation
###############################################################################
DIR=$PWD
ROOT=${DIR}/../
DEPS=${ROOT}/deps
HDF=${DEPS}/hdf
QWT=${DEPS}/qwt
PLG=${ROOT}/plugins

###############################################################################
# Check for all RTXI *.deb dependencies and install them. Includes:
#  - Kernel tools
#  - C/C++ compiler and debugger
#  - Qt5, HDF, and Qwt6 libraries
#  - R and some R packages
###############################################################################
echo "Checking dependencies..."

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install autotools-dev automake libtool kernel-package gcc g++ \
                        gdb fakeroot kexec-tools kernel-wedge libncurses5-dev \
                        libelf-dev binutils-dev libgsl0-dev libboost-dev git\
                        vim stress libqt5svg5-dev libqt5opengl5 \
                        libqt5gui5 libqt5core5a libqt5xml5 qt5-default
sudo apt-get -y build-dep linux

# Start at top
cd ${DEPS}


# Installing Qwt
echo "----->Checking for Qwt"

if [ -f "/usr/local/lib/qwt/include/qwt.h" ]; then
	echo "----->Qwt already installed."
else
	echo "----->Installing Qwt..."
	cd ${QWT}
	tar xf qwt-6.1.0.tar.bz2
	cd qwt-6.1.0
	qmake qwt.pro
	make -sj2
	sudo make install
	sudo cp /usr/local/lib/qwt/lib/libqwt.so.6.1.0 /usr/lib/.
	sudo ln -sf /usr/lib/libqwt.so.6.1.0 /usr/lib/libqwt.so
	sudo ldconfig
	if [ $? -eq 0 ]; then
		echo "----->Qwt installed."
	else
		echo "----->Qwt installation failed."
	exit
	fi
fi

# Install rtxi_includes
sudo rsync -a ${DEPS}/rtxi_includes /usr/local/lib/.
if [ $? -eq 0 ]; then
	echo "----->rtxi_includes synced."
else
	echo "----->rtxi_includes sync failed."
	exit
fi
find ${PLG}/. -name "*.h" -exec cp -t /usr/local/lib/rtxi_includes/ {} +
