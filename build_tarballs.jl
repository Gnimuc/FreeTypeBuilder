using BinaryBuilder

# Collection of sources required to build FreeType2
sources = [
    "https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz" =>
    "bf380e4d7c4f3b5b1c1a7b2bf3abb967bda5e9ab480d0df656e0e08c5019c5e6",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd freetype-2.9/builds
cat > exports.patch << 'END'
--- exports.mk
+++ exports.mk
@@ -30,9 +30,7 @@
   # on the host machine.  This isn't necessarily the same as the compiler
   # which can be a cross-compiler for a different architecture, for example.
   #
-  ifeq ($(CCexe),)
-    CCexe := $(CC)
-  endif
+  CCexe := /opt/x86_64-linux-gnu/bin/gcc   # use hard-coded path

   # TE acts like T, but for executables instead of object files.
   ifeq ($(TE),)
END

patch --ignore-whitespace < exports.patch

cd ..
./configure --prefix=$prefix --host=$target
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libfreetype", :libfreetype)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "FreeType2", sources, script, platforms, products, dependencies)
