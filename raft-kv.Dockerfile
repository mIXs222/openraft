# prepare dependency skeleton
FROM lukemathwalker/cargo-chef:latest-rust-1.59.0 AS chef

FROM chef AS planner
WORKDIR /openraft
COPY openraft .
WORKDIR /coruscant
COPY coruscant .
WORKDIR /app
COPY example-raft-kv .
RUN cargo chef prepare --recipe-path recipe.json

# build dependencies separately from current project
FROM chef AS builder 
WORKDIR /openraft
COPY openraft .
WORKDIR /coruscant
COPY coruscant .
WORKDIR /app
COPY --from=planner /app/recipe.json recipe.json
RUN rustup install nightly && \
  cargo +nightly chef cook --release --recipe-path recipe.json
COPY example-raft-kv .
RUN cargo +nightly build --release --bin raft-key-value

# copy over the compiled binary and start up a box
FROM debian:bullseye-slim AS runtime
WORKDIR /app
RUN apt-get update && \
  apt-get install -y \
    cpulimit \
    curl \
    iproute2 \
    less \
    procps \
    && \
  rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/raft-key-value /usr/local/bin
COPY ./raft-scripts /app/
CMD ["bash"]
