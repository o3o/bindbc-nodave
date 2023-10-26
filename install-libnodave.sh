#!/bin/sh
git clone git://github.com/netdata/libnodave.git
cd libnodave
make
sudo make install
cd ..
