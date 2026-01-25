AC_INIT([rmdal], [0.0.1])

# Find the compiler and compiler flags
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi

CC=`"${R_HOME}/bin/R" CMD config CC`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`
CXX=`"${R_HOME}/bin/R" CMD config CXX`
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`

# Check for pkg-config
AC_PATH_PROG([PKG_CONFIG], [pkg-config])

# Try pkg-config first for MDAL
MDAL_CFLAGS=""
MDAL_LIBS=""

if test "x$PKG_CONFIG" != "x"; then
  if $PKG_CONFIG --exists mdal; then
    MDAL_CFLAGS=`$PKG_CONFIG --cflags mdal`
    MDAL_LIBS=`$PKG_CONFIG --libs mdal`
    AC_MSG_NOTICE([Found MDAL via pkg-config])
  fi
fi

# If pkg-config didn't work, try standard locations
if test "x$MDAL_LIBS" = "x"; then
  # Check common include paths
  AC_MSG_CHECKING([for mdal.h in standard locations])
  for dir in /usr/local/include /usr/include /opt/local/include; do
    if test -f "$dir/mdal.h"; then
      MDAL_CFLAGS="-I$dir"
      AC_MSG_RESULT([found in $dir])
      break
    fi
  done
  
  if test "x$MDAL_CFLAGS" = "x"; then
    AC_MSG_RESULT([not found])
  fi
  
  # Check common lib paths
  AC_MSG_CHECKING([for libmdal in standard locations])
  for dir in /usr/local/lib /usr/lib /usr/lib64 /opt/local/lib; do
    if test -f "$dir/libmdal.so" -o -f "$dir/libmdal.dylib"; then
      MDAL_LIBS="-L$dir -lmdal"
      AC_MSG_RESULT([found in $dir])
      break
    fi
  done
  
  if test "x$MDAL_LIBS" = "x"; then
    # Try just -lmdal and hope the linker finds it
    MDAL_LIBS="-lmdal"
    AC_MSG_RESULT([trying default -lmdal])
  fi
fi

# Verify we can actually compile and link with MDAL
AC_MSG_CHECKING([whether MDAL library works])
LIBS_SAVE="$LIBS"
CPPFLAGS_SAVE="$CPPFLAGS"
LIBS="$MDAL_LIBS $LIBS"
CPPFLAGS="$MDAL_CFLAGS $CPPFLAGS"

AC_LANG_PUSH([C++])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
  #include <mdal.h>
]], [[
  const char* v = MDAL_Version();
]])], [
  AC_MSG_RESULT([yes])
], [
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([Cannot compile/link with MDAL. Please install MDAL development files.
  
  On Ubuntu/Debian: Build from source (https://github.com/lutraconsulting/MDAL)
  With conda: conda install -c conda-forge mdal
  
  If MDAL is installed in a non-standard location, set:
    PKG_CONFIG_PATH=/path/to/mdal/lib/pkgconfig
  or:
    MDAL_CFLAGS=-I/path/to/include MDAL_LIBS=-L/path/to/lib\ -lmdal
  ])
])
AC_LANG_POP([C++])

LIBS="$LIBS_SAVE"
CPPFLAGS="$CPPFLAGS_SAVE"

# Output
AC_SUBST(MDAL_CFLAGS)
AC_SUBST(MDAL_LIBS)

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT

echo "
  rmdal configuration:
    MDAL_CFLAGS: $MDAL_CFLAGS
    MDAL_LIBS:   $MDAL_LIBS
"
