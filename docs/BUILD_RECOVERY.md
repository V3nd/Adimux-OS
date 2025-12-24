# Adimux OS — LFS Chapter 6 Recovery (Missing /usr)

## Summary
During LFS 12.4 Chapter 6, several packages (m4, ncurses, bash, coreutils) were built while the target filesystem
inside `$LFS` did not have a proper `/usr` directory layout. This caused installs to land in unexpected locations,
leading to a broken chroot environment.

## Symptoms
- Packages appeared to build, but binaries were not found where expected.
- `chroot` failures such as:
  - `chroot: failed to run command '/usr/bin/env': No such file or directory`
  - `chroot: failed to run command '/bin/bash': No such file or directory`
- `find $LFS -name ld-linux-x86-64.so.2` returned nothing, indicating the dynamic loader was missing/unusable.

## Root Cause
`/usr` (and the standard LFS directory/symlink layout) was missing or incorrect at the time of installing critical
Chapter 6 packages. Without a correct filesystem hierarchy, installs were effectively misplaced and the resulting
system could not provide `/usr/bin/env`, `/bin/bash`, or the dynamic loader.

## Corrective Actions (High-level)
1. Ensure base directories exist under `$LFS`:
   - `$LFS/{bin,boot,etc,home,lib,lib64,mnt,opt,sbin,srv,tmp,usr,var}`
   - `$LFS/usr/{bin,lib,lib64,sbin,share}`
   - `$LFS/var/{log,mail,spool,opt,cache,lib,local}`
2. Ensure LFS symlink layout:
   - `$LFS/bin -> usr/bin`
   - `$LFS/sbin -> usr/sbin`
   - `$LFS/lib -> usr/lib`
   - `$LFS/lib64 -> usr/lib64`
3. If virtual filesystems are mounted inside `$LFS`, unmount them before `chown -R`:
   - `$LFS/dev/pts`, `$LFS/dev`, `$LFS/proc`, `$LFS/sys`, `$LFS/run`
4. Remount virtual filesystems correctly, then re-enter chroot.
5. Reinstall, in order:
   - **Glibc** (restores dynamic loader)
   - **Coreutils** (restores `/usr/bin/env`)
   - **Bash** (restores shell correctly)
6. Resume Chapter 6 from **Diffutils** onward.

## Why this matters
This recovery is done the “clean LFS way” (no hacks), ensuring the build becomes reproducible and suitable for
automation and CI validation.

## Status
- Filesystem hierarchy fixed.
- Recovery in progress: Glibc/Coreutils/Bash reinstall pending, then resume Chapter 6.
