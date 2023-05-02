# opensim_macOS_arm64

Opensim Support for Apple Silicon M1/M2

v2.1.1 / 2 May 2023

This project provides files and instructions to run Opensimulator server software
(http://opensimulator.org) fully native on Apple Silicon (M1/M2) computers,
and to install a more recent version of the Bullet physics engine on 
Apple Silicon or Intel based Apple Macs, or on Intel-based Linux computers (Ubuntu).

This project has mostly been merged into the main distribution of Opensimulator.
Work is still ongoing with a new version of Bullet Physics.

This project provides the following unmanaged libraries for Opensimulator server software
to run on Apple Silicon hardware. These
were built as "Universal Binaries"
containing multi-architecture including arm64 (Apple Silicon) and x86_64 (Intel):

  - libBulletSim-2.86-20230316-universal.dylib
  - libopenjpeg-2-1.5.0-20230316-universal.dylib
  - libubode.5-20230316-universal.dylib

The build process is detailed further down on this page.

If you just want to run Opensim on Apple Silicon and are not interested in details for developers,
the build instructions [here](http://opensimulator.org/wiki/Build_Instructions#Building_on_Linux_.2F_Mac)
are up to date and correct. You will need to install dotnet6 from a download at Microsoft's website
and libgdiplus from either Homebrew or Macports. If you are already using one of these package managers
then use the one you have. I have only tested it with Homebrew.

If you use Brew to install Libgdiplus, on an Apple Silicon computer, you
also need to create a symbolic link:

	sudo ln -s /opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/libgdiplus.dylib /usr/local/lib/libgdiplus.dylib

Note that you will need to re-create this symbolic link each time there is a
version update to libgdiplus. This link is required because on Apple Silicon, brew installs into
/opt/homebrew/ instead of /usr/local. Dotnet uses /usr/local as a hard-coded path 
and ignores shell environments.

There are mixed reviews of Mono and dotnet6 co-existing. If you have Mono installed
and then install dotnet6, and run into problems, it's likely due to mixed
library sources at compile time.
You may need to uninstall Mono, or adjust
your environment variables so that you don't have a mix of source libraries.
Then recompile Opensim. 


*What's New*

There is ongoing work in developing a new version of Bullet for all Opensim platforms, 
based on the latest version of Bullet, 3.25, and other bug fixes. 
I was initially tinkering with Bullet 3.25 for macOS as an experimental version after
I developed a process that supported building the new Bullet version for Apple Silicon hardware.
Opensimulator is currently on Bullet version 2.86.

Misterblue is the lead developer for Bullet implementation on Opensimulator
and adapted my work to create a plan for updating Bullet on all supported architectures of Opensimulator.
He developed a new build automation process for multiple
architectures and added a number of enhancements and bug fixes on top of the
latest Bullet version. We are working together to look at test cases and known issues:

1) Some of the console commands to change Bullet parameters do not appear to be taking hold

2) Physics objects that go into physics "sleep" state do not wake up properly in some use cases

Misterblue is also upgrading the Bullet wrapper. This includes reporting the actual
Bullet physics version, and be mostly 64-bit clean which may improve performance.

The long term plan is to have the same version, patches, and feature parity across all platforms.
Eventually, after appropriate testing, discussions and fixes,
the new test versions of Bullet will be merged into Opensimulator main distribution.

Until then, I will try to keep this page updated with the latest status.

I'm providing experimental versions of the Bullet 3.25 library for macOS and
Ubuntu Linux. 
These should be at least as good as the current version, adding the latest
Bullet engine, although they still use the old (current) Bullet wrapper and
don't yet resolve the bugs described above.

  - libBulletSim-3.25-20230315-universal.dylib  (x86\_64 and arm64, macOS 10.15-13.x)
  - libBulletSim-3.25-x86_64-20230211.so (64-bit Linux, built on Ubuntu)

To install,
first place the file in opensim/bin/lib64/. Back up an original copy of the file
	
	/bin/OpenSim.Region.PhysicsModule.BulletS.dll.config

then edit that file to point to the new dylib file.


And lastly, I am providing an experimental version of Bullet 3.25, the same as the one
above but with the Bullet sleep feature disabled using the patch _Bullet-disable-sleeping.patch_
from this repository. This replaces the 0001 patch and effectively 
disables the switching between object sleep and wake states.

  - libBulletSim-3.25-20221215-universal-NOSLEEP.dylib

This is a hack
and not the best way to accomplish shutting off the physics sleep feature. But it is an 
easy way to determine if an observed bug is related to the physics sleep feature.
This hack resolves bugs for some use cases with "stuck" prims but regresses the wandering-prim
issue on other use cases. A cleaner long-term solution is needed.
The change may have the effect of using more CPU on physics-enabled objects.
  

We are looking for feedback from people who are testing this. Please let us know
about your successes or issues!

This work is licensed under Creative Commons BY-NC-SA 3.0:
https://creativecommons.org/licenses/by-nc-sa/3.0/

-------------
**To build universal libraries (arm64/x86_64) from source**

The following documents the build process.
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

Download the repository for opensim-libs, which contains projects needed for the
physics engines. 

	git clone git://opensimulator.org/git/opensim-libs

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

	cd /path/to/opensim-libs/trunk/unmanaged/ubODE-OpenSim
	brew install libtool automake
	PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
	./bootstrap
	./configure --enable-shared --enable-double-precision 

The build system doesn't support multi-CPU options without hand-editing Makefiles.	
At this point, for building a universal binary, you need to hand-edit the following three Makefiles:

- [path to ubODE-OpenSim]/Makefile
- [path to ubODE-OpenSim]/ou/Makefile
- [path to ubODE-OpenSim]/ou/src/ou/Makefile

In each of these add the following compiler flags to any occurrence of CFLAGS, CPPFLAGS and CXXFLAGS:

	-arch arm64 -arch x86_64

Then you should be able to run the following commands at the top level of the project to finish the build:

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
