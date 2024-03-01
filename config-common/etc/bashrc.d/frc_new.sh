frc_new() {
   # Verificar se o caminho para a imagem do disco foi fornecido
   if [ -z "$1" ]; then
     echo "Você precisa fornecer o caminho para a imagem do disco como argumento."
     echo "Exemplo: $0 <caminho_para_imagem_hd>"
     exit 1
   fi

   # Verificar se o arquivo de imagem do disco existe
   if [ ! -f "$1" ]; then
     echo "O arquivo de imagem do disco não existe: $1"
     exit 1
   fi

   # Executar o QEMU com ncurses
   sudo qemu-system-x86_64 \
      -drive file=${1} \
      -m 8G \
      -device virtio-scsi-pci,id=scsi0 \
      -audiodev pa,id=snd0,server=localhost \
      -device ich9-intel-hda -device hda-output,audiodev=snd0 \
      -machine type=q35,accel=kvm,usb=on,pcspk-audiodev=snd0,smm=on \
      -smp 36 \
      -enable-kvm
   #  -nographic
   #  -display curses \

   #sudo qemu-system-x86_64 \
   #  -drive file=${1},format=raw \
   #  -display curses \
   #  -smp 36 \
   #  -enable-kvm \
   #  -nographic
}
