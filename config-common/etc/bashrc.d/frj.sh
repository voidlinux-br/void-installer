frj() {
	if test $# -ge 1; then
		if [[ ${1: -4} == ".iso" ]]; then
		  # Executar como CD-ROM
			sudo qemu-system-x86_64 \
		    -enable-kvm \
		    -m 16G \
		    -smp 36 \
		    -name 'Chili' \
			 -boot d \
	       -hda /archlive/qemu/hdc.img \
			 -cdrom $1
		else
		  # Executar como disco RAW
			sudo qemu-system-x86_64 \
	        	-no-fd-bootchk \
	        	-cpu host \
	        	-drive file=${1},if=none,id=disk1,format=raw \
	        	-device ide-hd,drive=disk1,bootindex=1 \
	        	-drive file=/archlive/qemu/hda.img,format=raw \
	        	-drive file=/archlive/qemu/hdb.img,format=raw \
	        	-drive file=/archlive/qemu/hdc.img \
	        	-drive file=/archlive/qemu/hdd.img \
	        	-m 16G \
	        	-name archiso,process=archiso_0 \
	        	-device virtio-scsi-pci,id=scsi0 \
	        	-device virtio-net-pci,romfile=,netdev=net0 -netdev user,id=net0,hostfwd=tcp::60022-:22 \
	        	-audiodev pa,id=snd0,server=localhost \
	        	-device ich9-intel-hda \
	        	-device hda-output,audiodev=snd0 \
	        	-global ICH9-LPC.disable_s3=1 \
				-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
	         -enable-kvm \
				-smp "$(nproc)" \
	        	"${qemu_options[@]}" \
	        	-serial stdio
		fi
	else
		cat <<EOF
usage:
	frj file.iso
EOF
   fi
}

