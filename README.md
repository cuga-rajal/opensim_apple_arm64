# opensim_macos_arm64

Opensim Support for Apple Silicon M1/M2

v1.0 / 17 November 2022

Instructions and files are provided to support running Opensimulator server software
(http://opensimulator.org) fully native on an Apple computer with an M1/M2
"Apple Silicon" chip.

This package was tested and developed on a Macbook Pro 14" M1 Pro, macOS 12.6.1
Monterey only. It has not been tested on Big Sur (macOS 11) or Ventura (macOS 13).

These instructions and files are likely to change as they become absorbed
in the main distribution. I will update this as needed and expect this project
will eventually become superceded.

Until then, this work is licensed under Creative Commons BY-NC-SA 3.0:
https://creativecommons.org/licenses/by-nc-sa/3.0/

-------------
**Required Prerequisites**

An Apple computer with an M1 or M2 chip. Currently the entire line of Apple Macs
are using these.

You will need to install the package manager Brew, which will be used to
install a number of required packages. To do this run the following at the terminal:

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Next, use Brew to install libgdiplus, which is required for Opensimultor.

	brew install mono-libgdiplus

This will install about 30 packages which include prerequisites.

To complete the installation, create a symbolic link:

	sudo ln -s /opt/homebrew/Cellar/mono-libgdiplus/6.1_1/lib/libgdiplus.dylib /usr/local/lib/libgdiplus.dylib

This link is required since Dotnet ignores shell environments and uses /usr/local
as a hard coded location.

Download and install Dotnet6 SDK Installer for Arm64:
	https://dotnet.microsoft.com/en-us/download/dotnet/6.0

Download and install the latest stable Mysql Community Server:
	https://dev.mysql.com/downloads/mysql/

  - After selecting the DMG package, on the next screen, click “No thanks, just start my download.”
  - After the file has downloaded, you will need to use a special step to open it
  since it is not notarized by Apple. Right-click on the DMG installer file and select Open.
  In the dialog that follows, click Open again.
  - During the installation you will be prompted to choose Legacy or Secure encryption.
    Select "Use Legacy Password Encryption” unless you know what you’re doing.
    Opensim does support Secure Encryption but this option is more complex to set up
    and is not needed for standalone or test systems.
    
Mysql will work fine with the default settings, but if you want to change the 
settings you can install a file at /private/etc/my.cnf and use MySQL Pref Pane
to Apply the changes.

Once the server is up and running, then either import your existing opensim database or
create a new empty database for a fresh install of opensim. 

Set up a Mysql user account that has all priveleges granted for the opensim database. 
Confirm the account can access the database by logging in to it with a database client.

-------------
**Installing Opensim**

Unpack opensim source code use git to pull in the latest source with

	git clone git://opensimulator.org/git/opensim

You should place the folder where it will permanently reside; problems will occur
if you move it's path later. On my system I place it in my top level user folder, at
/Users/myname/opensim, or ~/opensim.

Switch to the dotnet6 branch with

	git checkout dotnet6
	
Follow the instructions in BUILDING.md to build opensim. On macOS this typically is:

	./runprebuild.sh
	cp -f bin/System.Drawing.Common.dll.linux bin/System.Drawing.Common.dll
	dotnet build --configuration Release OpenSim.sln

You will also need to create some configuration files before Opensim will run.
If you are migrating an existing system just copy over your config files. 
If you are new to opensim, config file information is in BUILDING.md.

-------------
**Quick Start**

If you just want to run Opensimulator with the fewest steps, and don't want to
build your own libraries, you can copy the three pre-built .dylib files provided
in this repository to the /bin directory in your opemsim file tree. Overwrite
any files that might share the filename. Thats it. Then you are ready to start
up opensim with the command: 

	cd /path/to/opensim/bin; ./opensim.sh

Note: The file libopenjpeg-dotnet-x86\_64.dylib in this repository is not built for
the x86_64 architecture!! It is built for arm64 and this file naming is required by
dotnet.

-------------
**To build arm64 libraries from source**

You will need to have a shell environment with a complete set of environment 
variables appropriately set for the development work. I am providing a sample
bashrc file which is a good replacement for the default that Apple provides.
This includes paths for typical Apple silicon systems that have a mix of
installed tools/libraries from Brew (in /opt/homebrew) and from independently
installed packages like Mysql (in /usr/local). 

To install this, back up or rename the file at /private/etc/bashrc, then
move the file _bashrc_ from this repository to /etc/bashrc. If you are already in a terminal, you will
need to close it and open a new one to take effect, or you can apply the changes by typing:

	source /etc/bashrc

You also need to set your default shell to /bin/bash, by using the Users
and Groups preference pane. Right-click on a user and select Advanced Options.
This opens a window where you can set your default shell to /bin/bash. Bash
is the preferred shell when working with older unmanaged software.

Next you will need to install the latest Xcode Command Line Tools which is
provided free by Apple. As of this writing the Xcode Command Line Tools version
is 14.1. You may need to sign a developer license with Apple to access the
installer.

-------------
**Installing Libopenjpeg**

Visit https://bitbucket.org/opensimulator/libopenmetaverse/src/master/openjpeg-dotnet/

Go to Downloads -> Download Repository. Download and unpack.

	cd opensimulator-libopenmetaverse-*/openjpeg-dotnet
	
Download the file _Makefile.osx.diff_ from this repository and place it in this directory.
Apply it with the following:

	patch Makefile.osx Makefile.osx.diff

Then build and install the shared library:	

	make -f Makefile.osx
	cp -f libopenjpeg-dotnet-2-1.5.0-dotnet-1.dylib ~/opensim/bin/libopenjpeg-dotnet-x86_64.dylib

Note: This copy step changes the filename to indicate an incorrect architecture, x86\_64, even though
the file is built for arm64. This file naming is required by dotnet, because it cannot detect
architecture.

-------------
**Installing ubODE**

	cd trunk/unmanaged/ubODE-OpenSim
	brew install libtool automake
	PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
	./bootstrap
	./configure --enable-shared --enable-double-precision 
	make
	cp -f ode/src/.libs/libubode.5.dylib ~/opensim/bin/libubode.dylib
	
-------------
**Installing Bullet** 

Installation is done in 2 steps. First, compile a Bullet distribution and
install .a and include files into a temporary directory. Then, compile the
"Bullet Glue" which packages the Bullet libraries, along with connector
libraries, into a single static library.

The version of Bullet currently in opensim-libs is 2.74, however, this will not
build on an Apple M1. A more recent version, 2.86, does build and install and
appears to work fine with Opensim.

Download the tarball for Bullet 2.86 from
	https://codeload.github.com/bulletphysics/bullet3/tar.gz/2.86.1
	
	brew install cmake
	cd bullet3-2.86.1
	mkdir bullet-build
	cd bullet-build
	cmake .. -G "Unix Makefiles" -DBUILD_EXTRAS=ON -DBUILD_DEMOS=OFF -DBUILD_SHARED_LIBS=OFF -DINSTALL_LIBS=ON -DINSTALL_EXTRA_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX=./install
	make
	make install

This installs
  - Bullet .a files to bullet3-2.86.1/bullet-build/install/lib
  - Bullet includes into bullet3-2.86.1/bullet-build/install/include/bullet

Step 2 requires building the Bullet glue:

	cd opensim-libs/trunk/unmanaged/BulletSim/

Download the file _BulletSim.diff_ from this repository and place it in this directory.
Apply the patch with the following:

	patch -p0 < BulletSim.diff

Edit the Makefile and set IDIR and LDIR to the path for your .a and include files for Bullet.

	LDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/lib
	IDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/include/bullet

Then build and install:

	make
	cp -f libBulletSim.dylib ~/opensim/bin/libBulletSim.dylib

On my system, the same process works for Bullet 3.24 (stable) although I have not tested
to see if there are problems or advantages with that version.

-------------
**Start Up Opensim, the Dotnet Way**

Edit config files for your Opensim: OpenSim.ini, Regions.ini, etc. Then:

	cd opensim/bin; ./opensim.sh



-------------

This is a work in progress. Please notify me of bugs or feature requests.

Cuga Rajal (Second Life and Opensim)

cuga@rajal.org
