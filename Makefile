#  Created: sáb 21 jan 2023 18:33:23 -04
#  Altered: seg 23 set 2024 02:57:04 -04
#
#  Copyright (c) 2023-2024, Vilmar Catafesta <vcatafesta@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##############################################################################
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
	@cp Makefile LICENSE README.md ${DOCDIR}/
	@cp Makefile LICENSE README.md ${INFODIR}/
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
