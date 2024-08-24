# opensim_macOS_arm64

Opensim Support for Apple Silicon M1/M2

v2.8.2 / 24 Aug 2024

This project provides files and instructions to run
[Opensimulator server software](http://opensimulator.org) fully native on macOS
(Apple Silicon or Intel),
and to install a more recent version of the [Bullet physics engine](https://github.com/bulletphysics/bullet3)
on the macOS port of Opensimulator.

Files in this project are now fully merged into the
OpenSimulator trunk at opensimulator.org, and the project remains here for
reference. If there are new developments with OpenSimulator or Bullet Physics on
Apple Silicon hardware that require further development, this page will be
updated.

This page provides reference information for macOS users on
installing OpenSimulator server software and how to build the unmanaged libraries for the macOS platform.

See below for a general status of the Bullet physics engine implementation on
OpenSimulator and known bugs.

-------------
**Project Timeline**

December 2022 - This project documented an experimental version of OpenSimulator running native on Apple Silicon hardware and using Bullet 3.25

January 2023 - Support for native Apple Silicon from this project merged to OpenSimulator.org trunk

March 2024 - Developed roadmap to fix bugs and update OS Bullet from 2.86 to 3.25 with MisterBlue

July 2023 - MisterBlue adapts the process developed here for Bullet 3.25 to create a multi-platform build process 

November 2023 - macOS binaries provided here were re-code-signed with Apple to resolve a non-loading problem on some systems

December 2023 - Bullet 3.26 released to OS trunk for all architectures, opensim-libs updated

April 2024 - Note added to summary: Opensimulator now requires dotnet8 which is only supported on macOS 12 and above. 

June 2024 - Rescinded April 2024 note. Dotnet 8 runs fine on macOS 10.15 and macOS 11, although officially supported only on macOS 12 or higher.

August 2024 - Dotnet 8 security releases and Opensimulator still compatible with macOS 10.15 and later.

-------------
**Installing OpenSimulator on an macOS system - Summary**

General instructions to run Opensimuator server on macOS can be found
[here](http://opensimulator.org/wiki/Build_Instructions#Building_on_Linux_.2F_Mac)

Opensimulator currently requires dotnet8. If you are using Mono or
Dotnet6 you will need to switch to Dotnet8. Dotnet8 is officially supported on
macOS 12.x or higher but continues to work fine on macOS 10.15 or higher. 

Similarly, macOS 10.15 is the oldest version that will run the unmanaged libraries bundled with
Opensimulator, which include libopenjpeg and the Bullet and ubODE physics engines.

Microsoft has been issuing frequent security updates to Dotnet 8.
Make sure you keep your Dotnet 8 installation up to date as new versions are released.
Check their download page regularly.
macOS 10.15 (and later) so far remain compatible with the updates.

For those installing Opensimulator for the first time, you will need to install dotnet8 from a download at Microsoft's website.

You will also need to install libgdiplus from either Brew or Macports. If you are already using one of these package managers,
then use the one you have. I have only tested it with Brew.

If you use Brew to install Libgdiplus on an Apple Silicon computer, you
also need to create a symbolic link:

	sudo ln -s /opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/libgdiplus.dylib /usr/local/lib/libgdiplus.dylib

This link is required because on Apple Silicon, brew installs into
/opt/homebrew/ instead of /usr/local. Dotnet uses /usr/local as a hard-coded path 
and ignores shell environments.
You will need to re-create this symbolic link each time there is a
version update to libgdiplus. 

There are mixed reviews of Mono and dotnet co-existing. If you have Mono installed
and then install dotnet, you may run into problems, likely from mixed
library sources at compile time.
You may need to uninstall Mono, or adjust
your environment variables so that you don't have a mix of source libraries. 

-------------
**Bullet Development**

The current implementation of Bullet in OpenSimulator uses a build process first
developed in this project and then later adapted by MisterBlue for multiple
architectures. The process added some compatibility code changes in the form of
diffs and a somewhat different build method than previous releases. The new
method provided compatibility with the latest version of Bullet, 3.25, allowing a 
significant version upgrade in addition to the new supported architecture. 
Bullet version 2.86 had been in use by OpenSimulator for many years.

In March 2023 MisterBlue and I consolidated a list of current bugs and created a
roadmap to provide an updated version of Bullet for use in OpenSimulator. There
were 2 out standing bugs documented through OpenSimulator's Mantis bug tracking
system that we wanted to fix before releasing a new public version.

1) Physics sleep issue - resolved
One issue involved use cases where a physics object that had entered physics sleep state
did not wake from sleep properly in some cases. The classic case that demonstrated this bug
was a labyrinth game where you tilt the surface to move the rolling ball into a hole. 
Initially, Misterblue was going to develop a patch for the Bullet library to resolve this.
But the physics sleep code was so deeply engrained in the project,
any potential changes 
would have required major work and would have potentially introduced other instabilities. 
In his research Misterblue discovered an API to disable physics sleep from individual objects.
This allowed him to address the problems by adding a new scripting option to the [Extended Physics
module](http://opensimulator.org/wiki/ExtendedPhysics).
The new option can disable physics sleep of individual objects through a new extended LSL scripting function.

So while this wasn't a bug fix per-se, the issue was more than adequately addressed. 

2) llDetectedLinkNumber(n) - not resolved
A bug was discovered in July 2023 involving a scripting function llDetectedLinkNumber(n)
being non-operational in Bullet for physics-enabled linksets. 
Misterblue is exploring a fix.

There were hopes that this could be fixed before the December 2023 release but
close evaluation showed this would require a deep dive and significant time.
There are a couple possible paths to resolving it but both involve significant
coding and testing. We found that the issue was present at least as far back as
2019, on an older Bullet version. So the fact that the bug was only now
documented indicates it likely does not affect many people. I had been testing
Bullet 3.25 all year at my grid in a variety of use cases, and no other issues
came up. As a result of this, and due to he time required to fix the one bug, we
agreed to make a general release of Bullet 3.26 to OpenSimulator and explore the
Bullet fix at a later time. 

Given that the bug existed on an older Bullet version, we suspect the issue is in the Bullet
connector code in OpenSimulator core and not in the Bullet library itself. So a fix for this
issue is not likely to require an update to the Bullet library.

If there are any new developments in the status of Bullet on OpenSimulator 
they will be posted here. On occasion, this repository provides development versions of
unmanaged libraries (Bullet or other) as they are related to Apple Silicon hardware.
When development versions are provided here, they are licensed under Creative Commons BY-NC-SA 3.0:
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
building. For a few years 2020-2024, Opensimulator used dotnet6, which was supported
on macOS 10.15 through 13.x. At the time of this writing Opensimulator now requires dotnet8 
which is only supported on macOS 12.x and above. For compatibility with recent distributions, 
it is best to set MACOSX\_DEPLOYMENT\_TARGET to 10.15. 

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


The project to build Bullet is located within the opensim-libs project. If you
haven't already downloaded opensim-libs, see instructions in the ubODE Physics section above.

	cd /path/to/opensim-libs/trunk/unmanaged/BulletSim/

As of Dec 18. 2023 the build process for Bullet is greatly simplified compared
to the previous method which required multiple stages, thanks to MisterBlue's
all-in-one script. Just run this script:

	./makeBullets.sh
	

This will run multiple stages of building with one command --
download the latest Bullet source, apply patches, and compile both the Bullet
project binaries, Bullet wrapper, and output the binary in the same top level
directory. The resulting binary will have a name in the form

	libBulletSim-[version]-[date]-universal.dylib

The general release of Bullet 3.26 in OpenSimulator is renamed libBulletSim.dylib
and is located in /path/to/opensim/bin/lib64/. Although not preserved in its filename, 
this is a universal binary for macOS supporting x86_64 and arm64 architectures 
and code-signed by Apple.

If you wish to test a development version of Bullet, it's recommended to keep the default
Bullet library filename unchanged and place your development library into the lib64 directory
along side the original:

	cp -f libBulletSim-[version]-[date]-universal.dylib /path/to/opensim/bin/lib64/
	
Then, control which Bullet binary loads into the simulator by editing the configuration file
"osx" section:

	/path/to/opensim/bin/OpenSim.Region.PhysicsModule.BulletS.dll.config
	


-------------

This is a work in progress. Please notify me of any bugs or feature requests.

Cuga Rajal (Second Life and Opensim)

cuga@rajal.org
