FROM debian:bullseye-slim AS runtime
WORKDIR /app
RUN apt-get update && \
  apt-get install -y \
    curl \
    multitime \
    iputils-ping && \
  rm -rf /var/lib/apt/lists/*
COPY ./raft-scripts /app/
CMD ["bash"]
