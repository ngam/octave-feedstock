#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

set -ex

export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"

chmod +x configure
chmod +x build-aux/mk-opts.pl

if [[ $target_platform == "linux-ppc64le" ]]; then
    # Needs to be set for cross-compilation
    export ax_blas_integer_size=4
fi

./configure --help
./configure --prefix=$PREFIX \
    --enable-readline \
    --enable-shared \
    --with-lapack="-lopenblas" \
    --with-fltk \
    --enable-dl \
    --without-qrupdate \
    --with-qt=5 \
    --with-magick=GraphicsMagick \
    --without-framework-carbon \
    --with-hdf5-includedir=${PREFIX}/include \
    --with-hdf5-libdir=${PREFIX}/lib

make -j${CPU_COUNT}
make install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

