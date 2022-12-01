# opensim_macos_arm64

Opensim Support for Apple Silicon M1/M2

v1.1 / 30 November 2022

This project provides instructions and files to run Opensimulator server software
(http://opensimulator.org) fully native on an Apple computer with an M1/M2
'Apple silicon' chip, and to install a more recent version of the Bullet physics
engine.

This package was tested and developed on a Macbook Pro 14" M1 Pro, macOS 12.6.1
Monterey, Dotnet 6.0.11.

These instructions and files are likely to change as they become merged into the
main distribution. I will update this project as needed. Eventually this project
will be superceded.

The static libraries that were previously included in this repository have been
added to the main distribution, so they are no longer needed here and have been removed..

This work is licensed under Creative Commons BY-NC-SA 3.0:
https://creativecommons.org/licenses/by-nc-sa/3.0/

-------------
**Required Prerequisites**

An Apple computer with an M1 or M2 chip. Currently the entire line of Apple Macs
are using these.

You will need to install the package manager Brew, which will be used to
install a number of required packages. To do this run the following at the terminal:

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Next, use Brew to install libgdiplus, which is required for Opensimulator.

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

Use git to pull in the latest source with

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
If you are migrating an existing system, just copy over your config files. 
If you are new to opensim, config file requirements are explained in BUILDING.md.

-------------
**Start Up Opensim, the Dotnet Way**

Once the config files are set up, you arr ready to start the server:

	cd /path/to/opensim/bin; ./opensim.sh


-------------
**To build arm64 libraries from source**

For reference I am including the steps to build the three shared library files
now included in the distribution. Should there be a need to recompile a
physics engine or openjpeg library for the Apple arm64 platform these steps
can be used. There is also an opportunity to build a more recent version of the
Bullet physics engine using the steps provided. 

You will need to have a shell environment with a complete set of environment 
variables appropriately set for the development work. Bash (Bourne-again shell)
is the preferred shell when working with older unmanaged software.

Apple sets the default shell to zsh, so this will need to be changed.
Open the Users
and Groups preference pane. Right-click on your username and select Advanced Options.
This opens a window where you can change your default shell to /bin/bash. 

The steps involving compiling code (cmake or make) will throw errors if you do not
set your PATH and related environment variables. I am providing a sample
bashrc file which is a good replacement for the default that Apple provides.
This includes enviroinment paths for a mix of
installed tools/libraries from Brew (in /opt/homebrew) and from independently
installed packages like Mysql (in /usr/local). 

To install this, back up or rename the file at /private/etc/bashrc, then
move the file _bashrc_ from this repository to /etc/bashrc.

Once this is installed it will take effect in any new terminal windows
that you open. If you want these environment variables to be applied
to a terminal window already open, you can apply the changes by typing:

	source /etc/bashrc

Next you will need to install the latest Xcode Command Line Tools which is
provided free by Apple. As of this writing the Xcode Command Line Tools version
is 14.1. You may need to sign a developer license with Apple to access the
installer.

Download the repository for opensim-libs, which contains projects needed for the
physics engines. 

	git clone git://opensimulator.org/git/opensim-libs

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
	cp -f libopenjpeg-dotnet-2-1.5.0-dotnet-1.dylib /path/to/opensim/bin/lib64/libopenjpeg-dotnet-arm64.dylib

-------------
**Installing ubODE**

	cd /path/to/opensim-libs/trunk/unmanaged/ubODE-OpenSim
	brew install libtool automake
	PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
	./bootstrap
	./configure --enable-shared --enable-double-precision 
	make
	cp -f ode/src/.libs/libubode.5.dylib /path/to/opensim/bin/lib64/libubode-arm64.dylib
	
-------------
**Installing Bullet** 

Installation is done in 2 steps. First, compile a Bullet distribution and
install .a and include files into a temporary directory. Then, compile the
"Bullet Glue" which packages the Bullet libraries, along with connector
libraries, into a single static library.

The version of Bullet currently in opensim-libs repository is 2.74, however, this will not
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

	cd /path/to/opensim-libs/trunk/unmanaged/BulletSim/

Download the file _BulletSim.diff_ from this repository and place it in this directory.
Apply the patch with the following:

	patch -p0 < BulletSim.diff

Edit the Makefile and set IDIR and LDIR to the path for your .a and include files for Bullet.

	LDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/lib
	IDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/include/bullet

Then build and install:

	make
	cp -f libBulletSim.dylib /path/to/opensim/bin/lib64/libBulletSim-arm64.dylib

On my system, the same process works for Bullet 3.24 (stable) although I have not tested
to see if there are problems or advantages with that version.


-------------

If you like this project, please give me a star. 

Please notify me of any bugs or feature requests.

Cuga Rajal (Second Life and Opensim)

cuga@rajal.org
