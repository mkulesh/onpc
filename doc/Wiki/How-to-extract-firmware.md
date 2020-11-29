This instruction describes how to extract Onkyo firmware on the Linux workstation. 

* Download new firmware from Onkyo site, for example [from here](https://www.eu.onkyo.com/en/articles/firmware-update-ns-6130-135371.html)
You will have following file:

_NKNAP0002_0000000000NANO_N_124.zip

* Unzip it and you obtain following files:

> unzip _NKNAP0002_0000000000NANO_N_124.zip

> Archive:  ONKNAP0002_0000000000NANO_N_124.zip
 extracting: ONKNAP0002_0000000000NANO.of0  
 extracting: ONKNAP0002_0000000000NANO.of1  
  inflating: ONKNAP0002_0000000000NANO.of2  
  inflating: ONKNAP0002_0000000000NANO.of3  
 extracting: ONKNAP0002_0000000000NANO_N.of0  
 extracting: ONKNAP0002_0000000000NANO_N.of1  
  inflating: ONKNAP0002_0000000000NANO_N.of2  
  inflating: ONKNAP0002_0000000000NANO_N.of3

* The firmware is decrypted. [Here](http://divideoverflow.com/2014/04/decrypting-onkyo-firmware-files/) 
you can find a good description how to decrypt it.

* For decryption, download [this utility](https://github.com/mkulesh/onpc/blob/master/doc/Wiki/onkyo-decrypt64.c) 
in the directory where *.of files are extracted and compile it:

> gcc -o onkyo-dec onkyo-decrypt64.c

* Run this utility

> onkyo-dec

* you obtain new directory "extracted" with a set of files. You can check the file types using 
command "file". One of this file is an UBI image, version 1 that contains Linux distribution

> file *

> of2.AM335XNA_010203040506.07299:     UBI image, version 1

* This UBI image can be extracted using [this tool](https://github.com/nlitsme/ubidump)

> python ./ubidump.py --savedir ubi of2.AM335XNA_010203040506.07299

Desired output is

> ==> of2.AM335XNA_010203040506.07299 <==
1 named volumes found, 2 physical volumes, blocksize=0x20000
== volume rootfs ==
saved 563 files

and you will have a new directory "ubi". This is a rootfs of the Linux system.

* Directory "ubi/rootfs/home/root/" contains two files:

> ll ubi/rootfs/home/root/

> -rw-rw-r--. 1 family family 25964544 Oct 15 22:39 system.img

> -rw-rw-r--. 1 family family 40263680 Oct 15 22:39 usr.img

One file is the Google chrome, and the second - the player software. You can simply mount 
these files using squashfs

> su

> cd ubi/rootfs/

> mkdir usr

> mount -t squashfs -o loop home/root/usr.img ./usr

> mkdir system

> mount -t squashfs -o loop home/root/system.img ./system

* After it, you can explore the whole firmware.  

