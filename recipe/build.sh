set -e -x

./configure --enable-python --prefix=$PREFIX
make
make install
