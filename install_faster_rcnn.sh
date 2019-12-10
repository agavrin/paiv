#!/bin/bash

#prerequisite_fn(){
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
#}

#export -f prerequisite_fn

#prerequisite_fn
#su  -c prerequisite_fn

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
sed -i '/vision_layers.hpp/d' ./src/caffe/test/test_smooth_L1_loss_layer.cpp

# Jetson to performance mode
# echo "Setting Jetson to performance mode
# sudo nvpmodel -m 0
# sudo /home/nvidia/jetson_clocks.sh

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
