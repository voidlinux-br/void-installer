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
	@mkdir -p ${INFODIR}
	@cp Makefile ChangeLog INSTALL LICENSE MAINTAINERS README.md ${DOCDIR}/
	@cp Makefile ChangeLog INSTALL LICENSE MAINTAINERS README.md ${INFODIR}/
	@echo ":: Feito! ${APP} software instalado em: ${BINDIR}"
	@echo
	@echo -e "uso:"
	@echo "	cd ${BINDIR}"
	@echo "	./${APP}"
	@echo
	@echo ":: Considere colocar no teu path o ${BINDIR}"
uninstall:
	@rm ${BINDIR}/${APP}
	@rm -fd ${BINDIR}
	@rm -fd ${INFODIR}
	@echo "${APP} foi removido."
