#!/usr/bin/env bash
set -e
cd kernel/linux

cp ../../configs/base.config .config

scripts/kconfig/merge_config.sh -m .config \
  ../../configs/policy-security.config \
  ../../configs/profile-personal.config \
  ../../configs/policy-rust.config \
  ../../configs/kill-switch.config

make olddefconfig
