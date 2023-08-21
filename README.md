# opensim_macOS_arm64

Opensim Support for Apple Silicon M1/M2

v2.5 / 21 August 2023

This project provides files and instructions to run
[Opensimulator server software](http://opensimulator.org) fully native on macOS
(Apple Silicon or Intel),
and to install a more recent version of the [Bullet physics engine](https://github.com/bulletphysics/bullet3)
on the macOS port of Opensimulator.

The repository contains files required to run Opensimulator server
software that are unique to the Apple arm64 architecture, allowing it
to run natively. Some of these have been merged into the Opensimulator
main distribution. This page also documents the build process. Some files
in this repository are patches required to build the libraries for the
macOS platform, and some are development versions of libraries.

The three main unmanaged libraries in Opensimulator are provided here for
Apple arm64. These have been merged into the main distribution of
Opensimulator. The project will continue to provide updates for unmanaged libraries
as bug fixes become available.

There is still ongoing work with a new version of the Bullet physics engine, details below.

-------------
**What's New**

ubODE received a bug fix in August 2023. The file _libubode-5-20230821-universal.dylib_ in this
repository is a release of the updated version. This is expected to be merged 
into the OS distribution in the near future.


-------------
**Summary**

The following files in this repository have been 
merged into the main Opensimulator distribution (dotnet6 branch). These
were built as Universal Binaries
containing arm64 and x86_64 architectures and are code signed with Apple:

  - libBulletSim-2.86-20230316-universal.dylib
  - libopenjpeg-2-1.5.0-20230316-universal.dylib
  - libubode.5-20230316-universal.dylib

The build process is documented further down on this page.

General instructions to run Opensimuator server on macOS can be found
[here](http://opensimulator.org/wiki/Build_Instructions#Building_on_Linux_.2F_Mac)

You will need to install dotnet6 from a download at Microsoft's website
and libgdiplus from either Homebrew or Macports. If you are already using one of these package managers
then use the one you have. I have only tested it with Homebrew.

If you use Brew to install Libgdiplus, on an Apple Silicon computer, you
also need to create a symbolic link:

	sudo ln -s /opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/libgdiplus.dylib /usr/local/lib/libgdiplus.dylib

This link is required because on Apple Silicon, brew installs into
/opt/homebrew/ instead of /usr/local. Dotnet uses /usr/local as a hard-coded path 
and ignores shell environments.
You will need to re-create this symbolic link each time there is a
version update to libgdiplus. 

There are mixed reviews of Mono and dotnet6 co-existing. If you have Mono installed
and then install dotnet6, and run into problems, it's likely due to mixed
library sources at compile time.
You may need to uninstall Mono, or adjust
your environment variables so that you don't have a mix of source libraries.
Then recompile Opensim. 

-------------
**Bullet Development**

For the past few months there has been ongoing work in developing a new version of Bullet for
all Opensim platforms, 
based on the latest version of Bullet, 3.25, and other bug fixes. 

I was initially tinkering with Bullet 3.25 for macOS as an experimental version after
I developed a process that supported building the new Bullet version for Apple Silicon hardware.
Opensimulator is currently on Bullet version 2.86.

Misterblue, the lead developer for Bullet implementation on Opensimulator,
adapted my build process for other platforms and created a new build automation for multiple
architectures, along with some enhancements and bug fixes on top of the latest Bullet version.
The general plan is to build Bullet libraries for all the major architectures used in Opensimulator
from the same code base and build method, to provide the best parity across all platforms.
His streamlined build process works well on macOS and is being used for all test versions
of 3.25. 

Misterblue also updated the Bullet wrapper to version 1.2
which displays the correct Bullet version number when queried in-world through scripting functions.
It updates some 32-bit variables to 64-bit which may give minor performance improvements.
It also integrates some Mac-compatibility patches previously posted here, so those patches
will no longer be needed when building Bullet with the v1.2 wrapper.

Misterblue and I were aware of some physics-related bugs and we compared notes
to make a full list of issues. These were not resolved in version 3.25. We wanted to resolve
at least the biggest issues in the forthcoming Bullet version for Opensimuator.

One issue involved use cases where
the Bullet physics sleep function did not wake from sleep properly in some cases.
Initially, Misterblue was going to develop a patch for the Bullet library to resolve this.
But the physics sleep code was so deeply engrained in the project,
any potential changes 
would have required major work and would have potentially introduced other instabilities. 
In his research Misterblue discovered an API to disable physics sleep from individual objects.
This allowed him to address the problems by adding a new scripting option to the [Extended Physics
module](http://opensimulator.org/wiki/ExtendedPhysics).
The new option can disable physics sleep of individual objects through a new extended LSL scripting function.

A bug was discovered in July 2023 involving a scripting function llDetectedLinkNumber(n)
being non-operational in Bullet for physics-enabled linksets. We believe the
bug has always been there but only recently discovered. Misterblue is exploring a fix for this.
This bug is likely an issue with the interface to Bullet in the Opensimulator code, and not the
the Bullet library itself. Misterblue wants to take a deeper look to confirm this
before Bullet 3.25 is released to Opensimulator.
This is the main issue currently being worked on before the new version of Bullet is ready.

Initially, we expected the new Bullet version to be different enough from the
current version that some extended testing would be required.
However it turns out this is not the case.
Bullet 3.25 is not significantly different despite a large jump in the version number from 
2.86, the one currently used in Opensimulator. We expect it can be released to
the main Opensimulator distribution without any major testing once the bug reviews are completed.

I'm providing a pre-release of the Bullet 3.25 library for macOS in this repository.
This should be at least as good as the current version, built with the latest versions of Bullet
(3.25) and wrapper (1.2).

  - libBulletSim-3.25-20230527-universal.dylib (x86\_64 and arm64, macOS 10.15-13.x)

To install,
first place the file in opensim/bin/lib64/. Back up an original copy of the file
	
	/bin/OpenSim.Region.PhysicsModule.BulletS.dll.config

then edit that file to point to the new dylib file.
  

We are looking for feedback from people who are testing this. Please let us know
about your successes or issues!

This work is licensed under Creative Commons BY-NC-SA 3.0:
https://creativecommons.org/licenses/by-nc-sa/3.0/

-------------
**How to build universal libraries (arm64/x86_64) from source**

The following documents the build process for the macOS unmanaged libraries.
You can build the libraries yourself if you want to for some reason. 
I updated the instructions for universal binaries.

You will need to have a shell environment with environment 
variables appropriately set for the development work. Bash (Bourne-again shell)
is the preferred shell when working with older unmanaged software as some
software may require it.

Apple sets the default shell to zsh, so this will need to be changed.
Open the Users
and Groups preference pane. Right-click on your username and select Advanced Options.
This opens a window where you can change your default shell to /bin/bash. 

I am including in this repository  a sample
bashrc file which is a good replacement for the default that Apple provides.
This has a configuration that merges paths for
installed apps and libs from Brew (in /opt/homebrew) and from independently
installed packages like MySQL (in /usr/local). 

To install this, backup or rename the file at /private/etc/bashrc, then
move the file _bashrc_ from this repository to /private/etc/bashrc.

Once this is installed it will take effect in any new terminal windows
that you open. If you want these environment variables to be applied
to a terminal window already open, you can apply the changes by typing:

	source /etc/bashrc

On most systems, installing Brew will also trigger the installation of
Apple's "Command Line Developer Tools". If for some reason it was not installed, 
that needs to be installed at this time. There is no harm if you re-install it. 
You can install it by typing the following at the command line:

	xcode-select --install

Before you begin building, your environment variables must include MACOSX\_DEPLOYMENT\_TARGET
in order for the libraries to run on macOS versions earlier than the machine doing the
building. At the time of this writing the macOS versions supported by dotnet6
are 10.15 through 13.x, so MACOSX\_DEPLOYMENT\_TARGET should be set to 10.15.

Please note that when building your own libraries, they will work on your system,
but they will need to be code signed with Apple before they will work on other macOS systems.

-------------
**Installing Libopenjpeg**

Visit https://bitbucket.org/opensimulator/libopenmetaverse/src/master/openjpeg-dotnet/

Go to Downloads -> Download Repository. Download and unpack.

	cd opensimulator-libopenmetaverse-*/openjpeg-dotnet
	
Download the file _openjpeg-mac-arm64.patch_ from this repository and place it in this directory.
This is required for the arm64 architecture or for a universal binary containing that.
Apply it with the following:

	patch -p1 < openjpeg-mac-arm64.patch

Then build and install the shared library:	

	make -f Makefile.osx
	cp -f libopenjpeg-dotnet-2-1.5.0-dotnet-1.dylib /path/to/opensim/bin/lib64/libopenjpeg-[version]-[date]-universal.dylib



-------------
**Installing ubODE**

The build process for ubODE changed in August 2023 when I updated macOS to 13.5 (Ventura).
The following should work on Ventura and earlier versions.

Install the GNU version of libtool and automake, since the versions on macODS don't work with ubODE:

	brew install libtool automake
	
Download the repository for opensim-libs, which contains projects needed for the
physics engines. 

	git clone git://opensimulator.org/git/opensim-libs
	
Then start the build process:

	cd /path/to/opensim-libs/trunk/unmanaged/ubODE-OpenSim
	PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
	./bootstrap

The build system doesn't support multi-CPU options without hand-editing some
configure files. Edit the following two _configure_ files:

- [path to ubODE-OpenSim]/configure
- [path to ubODE-OpenSim]/ou/configure

In each of these, search for the occurence of the string "-g -O2" and in each occurence
add the following compiler flags:

	-arch arm64 -arch x86_64 -stdlib=libc++

The flag "-stdlib=libc++" is required when building on macOS Ventura, but may not be required for earlier macOS versions.

Then you should be able to run configure and make at the top level of the project to finish the build:

	./configure --enable-shared --enable-double-precision 
	make
	cp -f ode/src/.libs/libubode.5.dylib /path/to/opensim/bin/lib64/libubode-[version]-[date]-universal.dylib

	
-------------
**Installing Bullet** 

Building Bullet requires cmake. If not already installed, install it with brew:

	brew install cmake

Bullet installation is done in 2 steps. First, compile a Bullet distribution and
install library archive files (.a) and include files into temporary directories. Then, compile the
"Bullet Glue" which packages the Bullet libraries, along with connector
libraries, into a single static library.


The build process described here works the same on Bullet version 2.86, the version currently
used in Opensim trunk, and the latest version 3.25. The only differences are the
patches that need to be applied before compiling.

For version 2.86, download and unpack the tarball from:

	https://codeload.github.com/bulletphysics/bullet3/tar.gz/2.86.1

Or, if you want to try the latest Bullet version 3.25, download a ZIP file from:

	https://github.com/bulletphysics/bullet3

Apply this [patch](https://bitbucket.org/opensimulator/opensim-libs/src/master/trunk/unmanaged/BulletSim/0001-Call-setWorldTransform-when-object-is-going-inactive.patch)
provided by Misterblue to fix an issue involving wandering prims. This patch has been used on all the
architectures of Bullet libraries in the Opensim distribution.

Bullet version 2.86 also requires a patch if it is being compiled for macOS x86\_64 architecture
or a universal binary containing x86\_64. This patch is not required for Bullet 3.25 as it is already applied. 
The patch is provided in the file _bullet-2.86-mac-arm64-x86\_64.patch_ from this repository. 
Place it in the top level directory and apply it with the following:

	patch -p1 < bullet-2.86-mac-arm64-x86_64.patch

At the terminal, change directory to the top level or your
Bullet distribution. Depending on your version this will be _bullet3-2.86.1_ or _bullet-master_.
The following instructions reference bullet3-2.86.1, but the steps are the same for
either version.

Note that the cmake command listed below merges flags needed for either Bullet version. You can use the
same command for either version; flags not recognized will just be ignored.

	cd bullet3-2.86.1
	mkdir bullet-build
	cd bullet-build
	cmake .. -G "Unix Makefiles" -DBUILD_BULLET2_DEMOS=off -DBUILD_BULLET3=on -DBUILD_CLSOCKET=off -DBUILD_CPU_DEMOS=off -DBUILD_ENET=off -DBUILD_EXTRAS=on -DBUILD_DEMOS=off -DBUILD_OPENGL_DEMOS=off -DBUILD_PYBULLET=off -DBUILD_SHARED_LIBS=off -DBUILD_BULLET_ROBOTICS_GUI_EXTRA=off -DBUILD_BULLET_ROBOTICS_EXTRA=off -DBUILD_OPENGL3_DEMOS=off -DBUILD_UNIT_TESTS=off -DINSTALL_LIBS=ON -DINSTALL_EXTRA_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-fPIC -arch arm64 -arch x86_64" -DCMAKE_INSTALL_PREFIX=./install
	make
	make install

This installs
  - Bullet .a files to bullet3-2.86.1/bullet-build/install/lib
  - Bullet includes into bullet3-2.86.1/bullet-build/install/include/bullet


Step 2 requires building the Bullet glue:

	cd /path/to/opensim-libs/trunk/unmanaged/BulletSim/

A patch must be applied to build this on arm64 or on a universal binary containing arm64.

Download the file _bulletsim-glue-mac-arm64-x86\_64.patch_ from this repository and place it in this directory.
This patch file contains changes needed only for building the arm64 architecture.

Apply the patch with the following:

	patch -p1 < bulletsim-glue-mac-arm64-x86_64.patch

Edit the Makefile and set IDIR and LDIR to the path for your .a and include files for Bullet.

	LDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/lib
	IDIR = /full/path/to/bullet3-2.86.1/bullet-build/install/include/bullet

To build a universal binary, also replace any occurrence of "-arch arm64" with 
"-arch arm64 -arch x86_64".

Then build and install:

	make
	cp -f libBulletSim.dylib /path/to/opensim/bin/lib64/libBulletSim-[version]-[date]-universal.dylib


-------------

This is a work in progress. Please notify me of any bugs or feature requests.

Cuga Rajal (Second Life and Opensim)

cuga@rajal.org
