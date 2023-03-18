export CFLAGS="-Wall -O2 -pipe -I/opt/homebrew/include -I/usr/local/include -I/usr/include"

export CPPFLAGS="-Wall -O2 -I/usr/local/include -I/usr/include -I/opt/homebrew/include"

export LDFLAGS="-L/opt/homebrew/lib -L/usr/local/lib -L/usr/lib"

export LD_LIBRARY_PATH="/opt/homebrew/lib:/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}"

export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"

export ACLOCAL_FLAGS="-I /opt/homebrew/share/aclocal"

export MANPATH="/opt/homebrew/share/man:/usr/local/share/man:/usr/share/man"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/bin:/usr/libexec:/usr/local/mysql/bin:/System/Library/CoreServices:${PATH}"

export MACOSX_DEPLOYMENT_TARGET=10.15

export BASH_SILENCE_DEPRECATION_WARNING=1

# set the umask
umask 022

export G_FILENAME_ENCODING="@locale"

alias ls="ls -G"
alias rgrep="grep -r"


