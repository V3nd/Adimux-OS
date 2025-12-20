#!/usr/bin/env bash
set -e
cd kernel/linux
make -j"$(nproc)"
