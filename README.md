# opensim_macos_arm64

Opensim Support for Apple Silicon M1/M2

v1.3 / 5 December 2022

This project provides instructions and files to run Opensimulator server software
(http://opensimulator.org) fully native on an Apple Mac computer with an
Apple Silicon chip, and to install a more recent version of the Bullet physics
engine on that system.

Portions of this project have been merged into the Opensim master repository.
The following files in this repository are the latest versions
and mirrored in the Opensim repository:
  - libBulletSim-2.86.1-arm64.dylib
  - libopenjpeg-arm64.dylib
  - libubode-arm64.dylib

These are code-signed with Apple and were built with the process detailed in a later section.

The repository also has "universal" versions with both arm64 and x86_64 architectures embedded
in a single file. These are code-signed and functionally equivalent, but are not currently used
in the Opensim master repository.
  - libBulletSim-2.86.1-arm64-x86\_64.dylib
  - libopenjpeg-arm64-x86\_64.dylib

I am also providing an experimental static library for a much more recent version
of Bullet on arm64, Bullet version 3.25, which is their latest in trunk from 
https://github.com/bulletphysics/bullet3. This is code signed, but experimental.
  - libBulletSim-3.25-arm64.dylib

To install,
first place the file in opensim/bin/lib64/. Back up an original copy of the file
	/bin/OpenSim.Region.PhysicsModule.BulletS.dll.config

then edit that file to point
to the new dylib file by changing the line:

	<dllmap os="osx" cpu="arm64" dll="BulletSim" target="lib64/libBulletSim-2.86.1-arm64.dylib" />

to:

	<dllmap os="osx" cpu="arm64" dll="BulletSim" target="lib64/libBulletSim-3.25-arm64.dylib" />

We are trying to get more feedback from people who are testing this. Please let us know
about your successes or issues!

This work is licensed under Creative Commons BY-NC-SA 3.0:
https://creativecommons.org/licenses/by-nc-sa/3.0/

-------------
**Required Prerequisites to Run Opensim**

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

The instructions that follow aren't really needed by anyone unless you want
to build the libraries yourself for some reason. They are included here
for reference.

You will need to have a shell environment with environment 
variables appropriately set for the development work. Bash (Bourne-again shell)
is the preferred shell when working with older unmanaged software.

Apple sets the default shell to zsh, so this will need to be changed.
Open the Users
and Groups preference pane. Right-click on your username and select Advanced Options.
This opens a window where you can change your default shell to /bin/bash. 

I am providing a sample
bashrc file which is a good replacement for the default that Apple provides.
This includes shell environment paths for an arm64 macOS system that
typically has mix of
installed tools/libraries from Brew (in /opt/homebrew) and from independently
installed packages like Mysql (in /usr/local). 

To install this, back up or rename the file at /private/etc/bashrc, then
move the file _bashrc_ from this repository to /private/etc/bashrc.

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
	
Download the file _openjpeg-mac-arm64.patch_ from this repository and place it in this directory.
This is required for the arm64 architecture or for a fat binary containing that.
Apply it with the following:

	patch -p1 < openjpeg-mac-arm64.patch

Then build and install the shared library:	

	make -f Makefile.osx
	cp -f libopenjpeg-dotnet-2-1.5.0-dotnet-1.dylib /path/to/opensim/bin/lib64/libopenjpeg-dotnet-arm64.dylib

Please note this will work on your system but it will need to be code signed before it will
work on other macOS systems.

-------------
**Installing ubODE**

	cd /path/to/opensim-libs/trunk/unmanaged/ubODE-OpenSim
	brew install libtool automake
	PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
	./bootstrap
	./configure --enable-shared --enable-double-precision 
	make
	cp -f ode/src/.libs/libubode.5.dylib /path/to/opensim/bin/lib64/libubode-arm64.dylib

Please note this will work on your system but it will need to be code signed before it will
work on other macOS systems.
	
-------------
**Installing Bullet** 

Installation is done in 2 steps. First, compile a Bullet distribution and
install library archive files and include files into a temporary directory. Then, compile the
"Bullet Glue" which packages the Bullet libraries, along with connector
libraries, into a single static library.

The version of Bullet currently in opensim-libs repository is 2.74, however, this will not
build on an Apple M1. A more recent version, 2.86, does build and install and
appears to work fine with Opensim.

Download and unpack the tarball for Bullet 2.86 from
	https://codeload.github.com/bulletphysics/bullet3/tar.gz/2.86.1

This version of Bullet builds for arm64 without code patches, but requires a patch to support
x86\_64 architecture or a fat binary containing that. If you are building a fat binary or x86\_64, 
download the file _bullet-2.86-mac-arm64-x86\_64.patch_ from this repository and place it in this directory.
Apply it with the following:

	patch -p1 < bullet-2.86-mac-arm64-x86_64.patch

Then build and install the shared library:	


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

Note that if you are trying to build a fat binary, change the above cmake command
by replacing

	-DCMAKE\_CXX\_FLAGS="-fPIC"
	
with

	-DCMAKE_CXX_FLAGS="-fPIC -arch arm64 -arch x86_64"



Step 2 requires building the Bullet glue:

	cd /path/to/opensim-libs/trunk/unmanaged/BulletSim/

A patch must be applied to build this on arm64 or on a fat binary containing arm64.

Download the file _bulletsim-glue-mac-arm64-x86\_64.patch_ from this repository and place it in this directory.
This patch file contains changes for building for the arm64 architecture only. If you
want to build a fat binary, replace any occurrence of "-arch arm64" with 
"-arch arm64 -arch x86_64".

Apply the patch with the following:

	patch -p1 < bulletsim-glue-mac-arm64-x86_64.patch

Edit the Makefile and set IDIR and LDIR to the path for your .a and include files for Bullet.

	LDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/lib
	IDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/include/bullet

Then build and install:

	make
	cp -f libBulletSim.dylib /path/to/opensim/bin/lib64/libBulletSim-arm64.dylib

Please note this will work on your system but it will need to be code signed before it will
work on other macOS systems.

On my system, the same process works for Bullet 3.24 (stable) or 3.25, although I have not 
done any extensive in-world testing on the new versions.


-------------

Please notify me of any bugs or feature requests.

Cuga Rajal (Second Life and Opensim)

cuga@rajal.org
