FROM sagemathinc/cocalc

# Install useful utilities missing in original CoCalc image

# Be sure we're working with most recent packages in distro
RUN apt update && UCF_FORCE_CONFOLD=1 DEBIAN_FRONTEND=noninteractive \
    apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq -y upgrade -y && \
    apt autoremove -y

# Install NVIDIA driver (440.59) from Ubuntu official packages (focal, 19.10)
RUN echo "deb http://archive.ubuntu.com/ubuntu disco main restricted universe multiverse" > /etc/apt/sources.list.d/disco.list && \
    echo "deb http://archive.ubuntu.com/ubuntu eoan main restricted universe multiverse" > /etc/apt/sources.list.d/eoan.list && \
    echo "deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse" > /etc/apt/sources.list.d/eoan.list && \
    echo "APT::Default-Release \"bionic\";" > /etc/apt/apt.conf && \
    apt update && \
    apt install -y --no-install-recommends \
    nvidia-driver-440=440.59-0ubuntu2 \
    libnvidia-gl-440=440.59-0ubuntu2 \
    nvidia-dkms-440=440.59-0ubuntu2 \
    nvidia-kernel-source-440=440.59-0ubuntu2 \
    nvidia-kernel-common-440=440.59-0ubuntu2 \
    libnvidia-compute-440=440.59-0ubuntu2 \
    nvidia-compute-utils-440=440.59-0ubuntu2 \
    libnvidia-decode-440=440.59-0ubuntu2 \
    libnvidia-encode-440=440.59-0ubuntu2 \
    nvidia-utils-440=440.59-0ubuntu2 \
    xserver-xorg-video-nvidia-440=440.59-0ubuntu2 \
    libnvidia-cfg1-440=440.59-0ubuntu2 \
    libnvidia-ifr1-440=440.59-0ubuntu2 \
    libnvidia-fbc1-440=440.59-0ubuntu2

# Install CUDA 10.2 from NVIDIA Ubuntu 18.04 packages
# Packages should be locally available in cuda-repo
# Origin: cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb from NVIDIA site
COPY cuda-repo /cuda-repo
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
    mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    apt-key add /cuda-repo/key.pub && \
    echo "deb file:///cuda-repo /" > /etc/apt/sources.list.d/cuda-repo.list && \
    apt-get update && \
    apt-get -y install cuda cuda-10-2 cuda-runtime-10-2 cuda-demo-suite-10-2

# Install TensorRT development and runtime libraries (and doc)
# TensorRT 7.0.0.11 for CUDA 10.2 from local deb package
# includes cuDNN 7.6.5 & nvinfer7 7.0.0
# Packages should be locally available in tensorrt-repo
# Origin: nv-tensorrt-repo-ubuntu1804-cuda10.2-trt7.0.0.11-ga-20191216_1-1_amd64.deb from NVIDIA site
COPY tensorrt-repo /tensorrt-repo
RUN echo "deb file:///tensorrt-repo /" > /etc/apt/sources.list.d/tensorrt-repo.list && \
    apt-key add /tensorrt-repo/7fa2af80.pub && \
    apt-get update && \
    apt-get -y install tensorrt

# Install NVIDIA Collective Communications Library (NCCL)
# from NVIDIA machine learning development repo
# Packages should be locally available in nccl-repo
# Origin: nccl-repo-ubuntu1804-2.5.6-ga-cuda10.2_1-1_amd64.deb from NVIDIA site
COPY nccl-repo /nccl-repo
RUN echo "deb file:///nccl-repo /" > /etc/apt/sources.list.d/nccl-repo.list && \
    apt-get update && \
    apt-get -y install libnccl-dev

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.2"

#Start CuCalc

CMD /root/run.py

EXPOSE 80 443
