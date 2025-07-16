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

# Set NVCC flags for RTX 5090 support (sm_120)
ENV NVCC_APPEND_FLAGS="-gencode=arch=compute_120,code=sm_120"

# Build the bento agent
RUN cargo build --release -p bento-agent

# Create app directory and copy the agent
RUN mkdir -p /app
RUN cp target/release/bento-agent /app/agent

WORKDIR /app
ENTRYPOINT ["/app/agent"]