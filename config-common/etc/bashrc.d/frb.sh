frb() {
	if test $# -ge 1; then
		if [[ ${1: -4} == ".iso" ]]; then
		  # Executar como CD-ROM
			sudo qemu-system-x86_64 \
			  	-machine accel=kvm \
				-cpu host \
			  	-smp "$(nproc)" \
		    	-name 'Chili' \
		    	-m 16G \
			 	-cdrom $1 \
			 	-boot d \
			  	-vga virtio \
			  	-display gtk \
	       	-hda /archlive/qemu/hdc.img \
			  	-device intel-hda\
			  	-audiodev pa,id=snd0,server=localhost \
			  	-device hda-output,audiodev=snd0 \
				-net nic,model=virtio -net bridge,br=br0 \
	        	-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
			  	-serial stdio
		else
		  # Executar como disco RAW
			sudo qemu-system-x86_64 \
			  	-machine accel=kvm \
				-cpu host \
			  	-smp "$(nproc)" \
		    	-name 'Chili' \
			  	-m 16G \
			  	-vga virtio \
	  	      -drive file=${1},if=none,id=disk1 \
            -device ide-hd,drive=disk1,bootindex=1 \
			  	-netdev bridge,br=br0,id=net0 \
				-device virtio-net-pci,netdev=net0 \
	       	-hda /archlive/qemu/hdc.img \
			  	-device intel-hda -audiodev pa,id=snd0,server=localhost \
			  	-device hda-output,audiodev=snd0 \
			  	-serial stdio
		fi
	else
		cat <<EOF
usage:
	frb file.iso
	frb file.img
EOF
   fi
}

#			  	-display gtk \
#			  	-cpu host \
#	        	-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
#			  	-device virtio-net-pci,netdev=net0 -netdev user,id=net0 \
#			  	-net nic,model=virtio -net user \
#				-net nic,model=virtio -net bridge,br=br0
