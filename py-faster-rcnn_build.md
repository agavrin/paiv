# Using py-faster-rcnn on Jetson TX2

Building caffe FasterRCNN on Jetson TX2 requires a few modifications to the code and makefiles. It has been built on one of the systems  at ` /home/pointr/caffe_fasterrcnn_source/py-faster-rcnn/ `. It can be used for reference.

## Prerequisites
Install prerequisites for caffe
```
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-dev libhdf5-serial-dev protobuf-compiler
sudo apt-get install --no-install-recommends libboost-all-dev
sudo apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev
sudo apt-get install libatlas-base-dev libopenblas-dev
sudo pip2 install easydict
```

## Clone BVLC caffe
We will need the original Caffe repository for the latest cudnn files
```
echo "Cloning BVLC Caffe repository"
git clone https://github.com/BVLC/caffe.git bvlc-caffe
```

## Clone rbgirshick py-faster-rcnn repository
```
git clone --recursive https://github.com/rbgirshick/py-faster-rcnn.git
```

## Copy CUDNN files from BVLC caffe to py-faster-rcnn
```
cd py-faster-rcnn/caffe-fast-rcnn
cp ../../bvlc-caffe/include/caffe/util/cudnn.hpp ./include/caffe/util/
cp ../../bvlc-caffe/src/caffe/layers/cudnn* ./src/caffe/layers/
cp ../../bvlc-caffe/include/caffe/layers/cudnn* ./include/caffe/layers/
```

## Remove caffe/vision_layers.hpp (Lin 11) in test_smooth_L1_loss_layer.hpp
```
sed -i '/vision_layers.hpp/d' ./src/caffe/test/test_smooth_L1_loss_layer.cpp
```

## Set Jetson to performance mode (Optional)
```
sudo nvpmodel -m 0
sudo /home/nvidia/jetson_clocks.sh
```

## Copy working Makefile.config
```
wget https://jkjung-avt.github.io/assets/2017-11-30-ssd/Makefile.config
```

## Make modules
```
make -j4 all pycaffe
```

## Make test modules
```
make -j4 test
```

## Building Cython modules
```
cd ../lib
make
```
--------
--------

## Shell script
You can use the following shell script to perform all the above actions with a single command
```
#!/bin/bash
echo "Updating system"
sudo apt-get update -y
sudo apt-get upgrade -y

# Install prerequisites
echo "Installing Caffe prerequisites"
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-dev libhdf5-serial-dev protobuf-compiler -y
sudo apt-get install --no-install-recommends libboost-all-dev -y
sudo apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev -y
sudo apt-get install libatlas-base-dev libopenblas-dev -y
sudo pip2 install easydict

# Clone BVLC caffe
echo "Cloning BVLC Caffe repository"
git clone https://github.com/BVLC/caffe.git bvlc-caffe

# Clone rbgirshick py-faster-rcnn repository
echo "Cloning py-faster-rcnn repository"
git clone --recursive https://github.com/rbgirshick/py-faster-rcnn.git

# Copy CUDNN files from BVLC caffe to py-faster-rcnn
echo "Copying CUDNN files from BVLC Caffe to py-faster-rcnn"
cd py-faster-rcnn/caffe-fast-rcnn
cp ../../bvlc-caffe/include/caffe/util/cudnn.hpp ./include/caffe/util/
cp ../../bvlc-caffe/src/caffe/layers/cudnn* ./src/caffe/layers/
cp ../../bvlc-caffe/include/caffe/layers/cudnn* ./include/caffe/layers/

# Remove caffe/vision_layers.hpp in test_smooth_L1_loss_layer.hpp
echo "Modifying test_smooth_L1_loss_layer.hpp
sed -i '/vision_layers.hpp/d' ./src/caffe/test/test_smooth_L1_loss_layer.cpp

# Jetson to performance mode
echo "Setting Jetson to performance mode"
sudo nvpmodel -m 0
sudo /home/nvidia/jetson_clocks.sh

# Copy JK Jung's Makefile.config
wget https://jkjung-avt.github.io/assets/2017-11-30-ssd/Makefile.config

# Make modules
echo "Building py-faster-rcnn and pycaffe"
make -j4 all pycaffe

# Make test
echo "Building tests"
make -j4 test

# Building Cython modules
echo "Building Cython modules"
cd ../lib
make
```
-----
-----

## Building on a new system

You can build caffe faster rcnn by copying over the `py-faster-rcnn` folder from an already installed system to the new system and running

```
PY_CAFFE_ROOT=/path/to/py-faster-rcnn

cd $PY_CAFFE_ROOT/caffe-fast-rcnn
make -j4 all pycaffe
```
Run tests (optional)
The jetson device might run out of memory when running the test.
```
make -j4 test
make runtest
```

Build Cython modules
```
cd $PY_CAFFE_ROOT/lib
make
```

To perform a fresh build from original source, you can reproduce the initial modification steps by referring to this blog post: [https://jkjung-avt.github.io/faster-rcnn](https://jkjung-avt.github.io/faster-rcnn)

