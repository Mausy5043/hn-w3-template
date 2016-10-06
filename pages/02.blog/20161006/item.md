---
title: QEMU/KVM set-up (after installation)
---

#### Introduction
My main server is running Ubuntu. To increase the server's reliability I wanted to virtualise most of the services
running on it. Initially, I used LXC/LXD to virtualise my local DNS/DHCP services and the MySQL service.
However, I soon discovered that LXC/LXD is really just a fancy jail. The LX[CD] virtual machine uses the main server's
kernel and processes running inside the VM show up in `top` and `ps`. This isn't a problem persé. But it annoys and
confuses me, because it was nolonger clear to me what processes where actually running where.
Also, update/upgrade paths of the OS **inside** the VM were confusing because the kernel might be updated/upgraded
but the packages... maybe, not?
It also meant that I was not able to experiment with other OSes or emulate different CPUs. Which became a desire as
time progressed.

So, I investigated QEMU/KVM as an alternative.

#### QEMU/KVM
QEMU/KVM delivers a virtual environment through emulation that completely contains an OS.
Provided the hardware you want to use is supported anything is possible.
Nothing leaches out to the host system. On the host system the VM is seen as a single process with its own
memory, network stack and disk image.

#### Management environment on the host machine
To manage the virtual machines I started by creating a separate user `vmbeheer` who is part of the
groups `kvm` and `lib-virtd`.

```bash
$ id vmbeheer
uid=1007(vmbeheer) gid=100(users) groups=100(users),27(sudo),125(systemd-journal),115(kvm),131(libvirtd)
```

To get a VM running we need:

1. An XML-file to define the virtual machine.
1. A diskimage that will act as the VM's harddrive.
1. An ISO-file of the OS to be installed.

I created a folder for each of these files. I've also created a `bin` directory to store any scripts
that might get created along the way.

```bash
$ mkdir xml
$ mkdir images
$ mkdir iso
$ ls -l
total 16
drwxr-xr-x 2 vmbeheer users 4096 Oct  2 12:57 bin
drwxr-xr-x 2 vmbeheer users 4096 Oct  3 20:16 images
drwxr-xr-x 2 vmbeheer users 4096 Oct  3 16:17 iso
drwxr-xr-x 2 vmbeheer users 4096 Oct  3 20:25 xml
```

#### Downloading ISO-file
...tbd...

#### Creating a diskimage
...tbd...

#### Assembling an XML-file
...tbd...
