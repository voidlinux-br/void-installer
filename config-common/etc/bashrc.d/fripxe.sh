#!/usr/bin/env bash
declare -a qemu_options=()
declare xmem='16G'
declare network='100.97.0.0/24'
declare tftp_dir='/home/vcatafesta/configs/tftp/'

#qemu-system-x86_64\
# -boot n\
# -net nic,model=virtio\
# -net user,tftp=/srv/tftp/\
# -hda $1\
# -nic user,hostfwd=tcp::8022-:22\
# -net dump,file=dump.pcap\
# -nographic\
# -serial mon:stdio

#		sudo qemu-system-x86_64\
#		 -boot n -net nic,model=virtio\
#		 -net user\
#		 -hda $1\
#		 -nic user,hostfwd=tcp::8022-:22\
#		 -net dump,file=dump.pcap\
#		 -nographic\
#		 -serial mon:stdio\
#		 -bios ipxe.efi

#		sudo qemu-system-x86_64\
#			-boot n\
#		  	-netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no\
#		  	-device e1000,netdev=mynet0,mac=de:37:31:f8:43:d8\
#		  	-nographic\
#			-serial mon:stdio\
#		  	-display curses

#				-nographic\
#  			-display curses\
#				-serial stdio\
#				-netdev user,id=net0,net=100.97.0.0/24,tftp=/srv/tftp/,bootfile=/pxelinux.0 \
#			  	-display gtk \
#			  	-cpu host \
#	        	-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
#			  	-device virtio-net-pci,netdev=net0 -netdev user,id=net0 \
#			  	-net nic,model=virtio -net user \
#				-net nic,model=virtio -net bridge,br=br0

function sh_set_qemu_common_options {
   qemu_options+=(-no-fd-bootchk)
   qemu_options+=(-machine accel=kvm)
   qemu_options+=(-cpu host)
   qemu_options+=(-smp "$(nproc)")
   qemu_options+=(-name 'Chili')
   qemu_options+=(-m ${xmem})
	qemu_options+=(-vga virtio)
	qemu_options+=(-display gtk)
#  qemu_options+=(-device intel-hda)
#	qemu_options+=(-audiodev pa,id=snd0,server=localhost)
#	qemu_options+=(-device hda-output,audiodev=snd0)
#	qemu_options+=(-device ich9-intel-hda)
#  qemu_options+=(-global ICH9-LPC.disable_s3=1)
#	qemu_options+=(-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0)
	qemu_options+=(-serial mon:stdio)
}

fripxe() {
	sh_set_qemu_common_options
	sudo qemu-system-x86_64\
		-hda /archlive/qemu/hdc.img \
		-netdev user,id=net0,net=$network,tftp=$tftp_dir,bootfile=/pxelinux.0 \
		-device virtio-net-pci,netdev=net0 \
		-device virtio-rng-pci,rng=virtio-rng0,id=rng0,bus=pci.0,addr=0x9 \
		-object rng-random,id=virtio-rng0,filename=/dev/urandom \
		-boot n $@ \
		"${qemu_options[@]}"
}

