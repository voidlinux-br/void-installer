trap cleanup_working_dir EXIT

cleanup_working_dir() {
	if [[ -d "${working_dir}" ]]; then
		rm -rf -- "${working_dir}"
	fi
}

frv() {
	if test $# -ge 1; then
	   local ovmf_code='/usr/share/edk2-ovmf/x64/OVMF_CODE.fd'
		local working_dir="$(mktemp -dt frv.XXXXXXXXXX)"

		if [[ ! -f '/usr/share/edk2-ovmf/x64/OVMF_VARS.fd' ]]; then
			printf 'ERROR: %s\n' "OVMF_VARS.fd not found. Install edk2-ovmf."
			exit 1
		fi
		cp -av -- '/usr/share/edk2-ovmf/x64/OVMF_VARS.fd' "${working_dir}/"

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
			  	-device virtio-net-pci,netdev=net0 -netdev user,id=net0 \
			  	-device intel-hda -audiodev pa,id=snd0,server=localhost \
			  	-device hda-output,audiodev=snd0 \
			  	-net nic,model=virtio -net user \
 				-drive if=pflash,format=raw,unit=0,file=${ovmf_code},read-only=off \
				-drive if=pflash,format=raw,unit=1,file=${working_dir}/OVMF_VARS.fd \
	        	-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
			  	-serial stdio
		else
		  # Executar como disco RAW
			sudo qemu-system-x86_64 \
			  	-machine accel=kvm \
			  	-smp "$(nproc)" \
		    	-name 'Chili' \
			  	-m 16G \
			  	-drive file=${1},if=virtio,format=raw \
			  	-device virtio-net-pci,netdev=net0 -netdev user,id=net0 \
			  	-vga virtio \
			  	-display gtk \
	       	-hda /archlive/qemu/hdc.img \
			  	-device intel-hda -audiodev pa,id=snd0,server=localhost \
			  	-device hda-output,audiodev=snd0 \
			  	-net nic,model=virtio -net user \
				-drive if=pflash,format=raw,unit=0,file=${ovmf_code},read-only=off \
				-drive if=pflash,format=raw,unit=1,file=${working_dir}/OVMF_VARS.fd \
	        	-machine type=q35,smm=on,accel=kvm,usb=on,pcspk-audiodev=snd0 \
			  	-serial stdio
		fi
	else
		cat <<EOF
usage:
	frv file.iso
	frv file.img
	frv /dev/sdX
EOF
   fi
}

#			  	-cpu host \
