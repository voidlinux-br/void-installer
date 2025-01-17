frd() {
	if test $# -ge 1; then
		if [[ ${1: -4} == ".iso" ]]; then
		  # Executar como CD-ROM
			sudo qemu-system-x86_64 \
			-cdrom $1 -boot d \
	       -drive file=/archlive/qemu/hda.img,format=raw \
	       -drive file=/archlive/qemu/hdb.img,format=raw \
	       -drive file=/archlive/qemu/hdc.img \
	       -drive file=/archlive/qemu/hdd.img \
		    -m 16G \
		    -device virtio-scsi-pci,id=scsi0 \
		    -audiodev pa,id=snd0,server=localhost \
		    -device ich9-intel-hda -device hda-output,audiodev=snd0 \
		    -machine type=q35,accel=kvm,usb=on,pcspk-audiodev=snd0,smm=on \
		    -smp 36 \
		    -enable-kvm \
			-serial stdio ${qemu_options[*]}
		else
		  # Executar como disco RAW
			sudo qemu-system-x86_64 \
	        -no-fd-bootchk \
	        -drive file=${1},if=none,id=disk1 \
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
	         -smp 36 \
	         -enable-kvm \
	        "${qemu_options[@]}" \
	        -serial stdio
		fi
	fi
}
