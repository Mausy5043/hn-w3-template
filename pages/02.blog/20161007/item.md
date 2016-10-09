---
title: Debian minimal on QEMU/KVM
---

#### Introduction
Having [set up the QEMU/KVM installation](../20161006) I decided to try out Debian first.

First I `wget`ed the ISO-file. Then I created an XML-file for a guest system called "debbi3".
I also created a diskimage called `debbi3.qcow2`:

```bash
$ qemu-img create -f qcow2 "$HOME/images/debbi3.qcow2" 10G
```

The next step: create the VM and point the VNC-server at the host.

```bash
$ virsh create xml/debbi3.xml
Domain debbi3 created from xml/debbi3.xml
```

![Step 1](step1.jpg)

Click `Install`

##### Language selection:

![Step 2](step2.png)

##### Locale selection
Find your location

![Step 3a](step3a.png)
![Step 3b](step3b.png)
![Step 3c](step3c.png)

and choose your locale

![Step 4](step4.png)

##### Keyboard layout:

![Step 5](step5.png)

Some packages are installed.
##### Network setup:
You're asked to enter the hostname and domainname (mine is `.lan`):

![Step 6a](step6a.png)
![Step 6b](step6b.png)

##### User set-up
Set a root password

![Step 7a](step7a.png)

Then create a new user (I'm low on imagination) so I just call the user `debbi3`

Their username will be the same as the real name.
![Step 7b](step7b.png)
![Step 7c](step7c.png)

...and set a password...

![Step 7d](step7d.png)

##### Disk set-up

![Step 8a](step8a.png)
![Step 8b](step8b.png)
![Step 8c](step8c.png)
![Step 8d](step8d.png)
![Step 8e](step8e.png)

##### System installation

![Step 9](step9.png)

Wait for the base system to be installed.

##### Package manager

![Step 10a](step10a.png)
![Step 10b](step10b.png)

I don't use a proxy, so leave that blank.

##### Wrapping up

![Step 11](step11.png)

Next make sure to select the SSH server.

![Step 12](step12.png)

Wait...

![Step 13](step13.png)

Set-up GRUB

![Step 14a](step14a.png)
![Step 14b](step14b.png)

Reboot

![Step 15](step15.png)

#### Restart the Guest
Once the VM has restarted, I close the VNC window and return to the terminal on the host.
Here, I stop the VM.

```bash
$ virsh destroy debbi3
Domain debbi3 destroyed
```

Then I edit the XML and disable the cdrom device section by removing it, or commenting it out:
```html
    </disk>
    <!--ignore>
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw"/>
      <source file="/srv/array1/homes/vmbeheer/iso/debian-8.6.0-amd64-netinst.iso"/>
      <target dev="hdc" bus="ide"/>
      <readonly/>
      <address type="drive" controller="0" bus="1" target="0" unit="0"/>
    </disk>
    </ignore-->
    <interface type='bridge'>
```

I also disable the VNC-server:
```xml
    <!--ignore>
    <graphics type='vnc' port='-1' autoport="yes" listen='0.0.0.0'/>
    </ignore-->
```

After that the VM is ready to be booted for the first time.
```bash
$ virsh create xml/debbi3.xml
Domain debbi3 created from xml/debbi3.xml
```

I can now use SSH from any machine on the network to login to debbi3.
```bash
$ ssh debbi3@debbi3.lan
The authenticity of host 'debbi3.lan (10.0.1.xxx)' can't be established.
ECDSA key fingerprint is de:ad:de:ad:ca:fe:ba:be:de:ca:fb:ad:de:ad:de:ad.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'debbi3.lan,10.0.1.xxx' (ECDSA) to the list of known hosts.
debbi3@debbi3.lan's password:

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
debbi3@debbi3:~$ 
