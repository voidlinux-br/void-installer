#sáb 21 jan 2023 18:33:23 -04
#Vilmar Catafesta <vcatafesta@gmail.com>

SHELL=/bin/bash
APP=void-install
DESTDIR=
BINDIR=${DESTDIR}/opt/${APP}
DOCDIR=${DESTDIR}/opt/${APP}/doc
INFODIR=${DESTDIR}/usr/share/doc/${APP}
#MODE=775
MODE=664
DIRMODE=755

.PHONY: build

install:
	@echo "void-install - instalador para o Void Linux"
	@echo ":: Aguarde, instalando software ${APP} em: ${BINDIR}"
	@mkdir -p ${BINDIR}
	@mkdir -p ${DOCDIR}
	@mkdir -p ${INFODIR}
	@install -d -m 1777 ${BINDIR}
	@install -m 4755 ${APP} ${BINDIR}/${APP}
	@install -m 4755 void-testmirror ${BINDIR}/void-testmirror
	@install -m 4755 void-wifi ${BINDIR}/void-wifi
	@install -m 4755 void-mirror ${BINDIR}/void-mirror
	@install -m 4755 void-services ${BINDIR}/void-services
	@install -m 4755 void-clonedisk ${BINDIR}/void-clonedisk
	@install -m 4755 void-gitclone ${BINDIR}/void-gitclone
	@install -m 4755 void-remove-vg ${BINDIR}/void-remove-vg
	@install -m 4755 void-xrandr ${BINDIR}/void-xrandr
	@install -m 4755 void-runimage ${BINDIR}/void-runimage
	@install -m 4755 void-maketar ${BINDIR}/void-maketar
	@install -m 4755 void-parted ${BINDIR}/void-parted
	@install -m 4755 void-chroot ${BINDIR}/void-chroot
	@install -m 4755 void-efivar ${BINDIR}/void-efivar
	@install -m 4755 void-setfont ${BINDIR}/void-setfont
	@mkdir -p ${INFODIR}
	@cp Makefile ChangeLog INSTALL LICENSE MAINTAINERS README.md ${DOCDIR}/
	@cp Makefile ChangeLog INSTALL LICENSE MAINTAINERS README.md ${INFODIR}/
    $cp -rf usr/share/locale/* /usr/share/locale/
	@echo ":: Feito! ${APP} software instalado em: ${BINDIR}"
	@echo
	@echo -e "uso:"
	@echo "	cd ${BINDIR}"
	@echo "	./${APP}"
	@echo
	@echo ":: Considere colocar no teu path o ${BINDIR}"
uninstall:
	@rm ${BINDIR}/${APP}
	@rm ${BINDIR}/void-testmirror
	@rm ${BINDIR}/void-wifi
	@rm ${BINDIR}/void-mirror
	@rm ${BINDIR}/void-services
	@rm ${BINDIR}/void-clonedisk
	@rm ${BINDIR}/void-gitclone
	@rm ${BINDIR}/void-remove-vg
	@rm ${BINDIR}/void-xrandr
	@rm ${BINDIR}/void-runimage
	@rm ${BINDIR}/void-maketar
	@rm ${BINDIR}/void-parted
	@rm ${BINDIR}/void-chroot
	@rm ${BINDIR}/void-efivar
	@rm ${BINDIR}/void-setfont
	@rm -fd ${BINDIR}
	@rm -fd ${INFODIR}
	@echo "${APP} foi removido."
