FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    clang \
    cmake \
    python3 \
    python3-pip \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:${PATH}"

# Install RISC Zero toolchain
RUN curl -L https://risczero.com/install | bash
ENV PATH="/root/.risc0/bin:${PATH}"
RUN rzup install

# Clone RISC Zero repository
RUN git clone https://github.com/risc0/risc0.git /risc0
WORKDIR /risc0

# Set NVCC_APPEND_FLAGS to include sm_120 for RTX 5090 support
ENV NVCC_APPEND_FLAGS="-arch=sm_120"

# Build RISC Zero with CUDA support
RUN cargo build --release

# Set working directory for agent
WORKDIR /app

# Copy agent binary (will be mounted from host)
CMD ["/risc0/target/release/risc0-zkvm"]