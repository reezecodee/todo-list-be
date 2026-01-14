# ---------------------------------------------------
# STAGE 1: Build Server
# ---------------------------------------------------
FROM dart:stable AS build

WORKDIR /app

# Install Dart Frog CLI (Wajib buat build)
RUN dart pub global activate dart_frog_cli

# Copy file dependency dulu (biar cache layer optimal)
COPY pubspec.* ./
RUN dart pub get

# Copy seluruh source code
COPY . .

# Build project (menghasilkan folder /build)
# Pastikan path environment dart pub global sudah benar
ENV PATH="${PATH}:/root/.pub-cache/bin"
RUN dart_frog build

# Compile hasil build menjadi file binary (AOT) biar kenceng
RUN dart compile exe build/bin/server.dart -o build/bin/server

# ---------------------------------------------------
# STAGE 2: Production Runtime (Size Kecil)
# ---------------------------------------------------
FROM debian:stable-slim

# Install library pendukung (kadang dibutuhkan untuk koneksi DB SSL)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy file binary dari Stage 1
COPY --from=build /app/build/bin/server /app/server
COPY --from=build /app/public /app/public

# Expose port standar Dart Frog
EXPOSE 8080

# Jalankan server
CMD ["./server"]