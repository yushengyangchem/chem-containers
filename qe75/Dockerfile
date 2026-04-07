# ==========================================
# Stage 1: Build Stage
# ==========================================
FROM quay.io/rockylinux/rockylinux:10.1.20251126 AS build

LABEL maintainer="yangys" \
      description="Build Quantum ESPRESSO 7.5 in RockyLinux 10.1"

# Copy the source code package to the /opt directory in the container
COPY ./q-e-qe-7.5.tar.gz /opt/

# Configure mirror repositories and install build dependencies
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
      -i.bak /etc/yum.repos.d/rocky*.repo && \
    dnf makecache && \
    dnf -y install dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf -y install epel-release && \
    dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install gcc-gfortran \
      openmpi openmpi-devel \
      fftw fftw-devel \
      openblas openblas-devel \
      scalapack-openmpi scalapack-openmpi-devel \
      hdf5-openmpi hdf5-openmpi-devel \
      which

# Set OpenMPI environment variables and update dynamic linker run-time bindings
ENV PATH=/usr/lib64/openmpi/bin:$PATH
RUN echo "/usr/lib64/openmpi/lib" > /etc/ld.so.conf.d/openmpi.conf && ldconfig

# Extract, initialize external repositories, and compile QE 7.5
WORKDIR /opt
RUN tar -xf q-e-qe-7.5.tar.gz && \
    mkdir -p /opt/qe75 && \
    cd q-e-qe-7.5/external && ./initialize_external_repos.sh

WORKDIR /opt/q-e-qe-7.5
RUN ./configure \
      LIBDIRS="/usr/lib64 /usr/lib64/openmpi/lib" \
      LIBS="-fopenmp" \
      CC=mpicc \
      FC=mpif90 \
      F77=mpif77 \
      --prefix=/opt/qe75 \
      BLAS_LIBS="-lopenblas" \
      LAPACK_LIBS="-lopenblas" \
      SCALAPACK_LIBS="-lscalapack" \
      --enable-parallel=yes \
      --enable-openmp=yes \
      --with-hdf5=yes \
      --with-hdf5-include=/usr/lib64/gfortran/modules/openmpi \
      --with-libxc=no && \
    make all -j$(nproc) && \
    make install

# ==========================================
# Stage 2: Final Runtime Image
# ==========================================
FROM quay.io/rockylinux/rockylinux:10.1.20251126 AS runtime

LABEL maintainer="yangys" \
      description="App Quantum ESPRESSO 7.5 in RockyLinux 10.1"

# Configure mirror repositories, install only runtime dependencies, and clean cache to reduce image size
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
      -i.bak /etc/yum.repos.d/rocky*.repo && \
    dnf makecache && \
    dnf -y install dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf -y install epel-release && \
    dnf -y update && \
    dnf -y install \
      openmpi \
      fftw-libs-double \
      openblas-serial \
      scalapack-openmpi \
      hdf5-openmpi && \
    dnf -y autoremove && \
    dnf clean all && \
    rm -rf /var/cache/dnf/* /root/.cache

# Copy the compiled QE core files and MPI dynamic library configuration from the build stage
COPY --from=build /opt/qe75 /opt/qe75
COPY --from=build /etc/ld.so.conf.d/openmpi.conf /etc/ld.so.conf.d/openmpi.conf

RUN ldconfig

# Set runtime environment variables
ENV PATH=/opt/qe75/bin:/usr/lib64/openmpi/bin:$PATH \
    OPENBLAS_NUM_THREADS=1 \
    OMP_NUM_THREADS=1 \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

# Default command when the container starts
CMD ["/bin/bash"]
