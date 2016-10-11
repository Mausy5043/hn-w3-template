---
title: QEMU/KVM set-up (after installation)
date: 10/06/2016
---

#### Introduction
My main server is running Ubuntu. To increase the server's reliability I wanted to virtualise most of the services
running on it. Initially, I used LXC/LXD to virtualise my local DNS/DHCP services and the MySQL service.
However, I soon discovered that LXC/LXD is really just a fancy jail. The LX[CD] virtual machine uses the main server's
kernel and processes running inside the VM show up in `top` and `ps`. This isn't a problem persé. But it annoyed and
confused me, because it was nolonger clear to me what processes where actually running where.
Also, update/upgrade paths of the OS **inside** the VM were confusing because the kernel might be updated/upgraded
but the packages..., maybe, not?
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

#### Headless install
My main challenge was that my host does not have a monitor. So, I needed to find a way to install the guest OS
on a headless system. As it turned out QEMU comes with a built-in VNC-server, so it was relatively easy to
access the system using a VNC-client on my laptop.

#### Downloading ISO-file
I prefer to use a minimal install or net-install version, because these can be customised to the greatest degree.
Larger versions tend to come with all kinds of crud that is not needed on a headless server providing a single
service.

Most Linux distributions offer installation media in an ISO-format available for download.

For example, [Debian](https://www.debian.org/CD/http-ftp/) offers various images.
To get one just obtain the URL and `wget` the image into the `iso` directory.

```bash
$ cd ~/iso
$ wget http://cdimage.debian.org/debian-cd/8.6.0/amd64/iso-cd/debian-8.6.0-amd64-netinst.iso
```

###### note that the link above may not work when you're reading this.

#### Creating a diskimage
The next step is to create a diskimage. My preferred format for diskimages is `qcow2`. This diskimage
is initially created as a relatively small file which will grow automagically as the VM requires more diskspace, upto
the maximum size given at creation. 10 GB is usually more than enough for simple servers.

```bash
$ qemu-img create -f qcow2 "$HOME/images/diskimage.qcow2" 10G
```

#### Assembling an XML-file

The default XML-file I'm using:

```xml
<domain type='kvm'>
  <name>%NAME%</name>
  <uuid>%UUID%</uuid>
  <memory>1048576</memory>
  <currentMemory>1048576</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type>hvm</type>
    <boot dev='cdrom'/>
  </os>
  <features>
    <acpi/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2"/>
      <source file="/srv/array1/homes/vmbeheer/images/diskimage.qcow2"/>
      <target dev="vda" bus="virtio"/>
      <address type="pci" domain="0x0000" bus="0x00" slot="0x04" function="0x0"/>
    </disk>
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw"/>
      <source file="/srv/array1/homes/vmbeheer/iso/debian-8.6.0-amd64-netinst.iso"/>
      <target dev="hdc" bus="ide"/>
      <readonly/>
      <address type="drive" controller="0" bus="1" target="0" unit="0"/>
    </disk>
    <interface type='bridge'>
      <source bridge='br0'/>
      <mac address="%MAC%"/>
    </interface>
    <controller type="ide" index="0">
      <address type="pci" domain="0x0000" bus="0x00" slot="0x01" function="0x1"/>
    </controller>
    <!--ignore>
    <input type='mouse' bus='ps2'/>
    </ignore-->
    <graphics type='vnc' port='-1' autoport="yes" listen='0.0.0.0'/>
    <console type='pty'>
      <target port='0'/>
    </console>
  </devices>
</domain>
```

In this file
- `%NAME%` is replaced by a short name for the VM. Usually, I use the hostname here.
- `%UUID%` becomes the output of the `uuid` command. If not available: install it first with `apt install uuid`.
- `%MAC%` becomes the output of `echo guest.example.com  | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/00:50:56:\3:\4:\5/'`. Obviously, replace `guest.example.com` by the
FQDN of your VM.

The MAC address generated by the code given here uses the [Organizationally Unique Identifier](https://en.wikipedia.org/wiki/MAC_address) (OUI) `02:50:56:xx:xx:xx` for manually and locally generated addresses. Where `xx:xx:xx` is in the range `00:00:00` to `FF:FF:FF`. 
