# Instalação do Mkdocs Server no Void Linux

## 🎯 Objetivo - Subir o Servidor MkDocs, um gerador de sites de documentação estática rápido, simples e focado em projetos. Ele transforma arquivos Markdown simples em um site de documentação profissional e totalmente navegável. A configuração é feita através de um único arquivo YAML (mkdocs.yml), e o conteúdo é escrito em Markdown padrão. É ideal para criar documentação técnica, manuais de usuário ou bases de conhecimento, oferecendo um servidor de desenvolvimento embutido para visualização em tempo real.

---

## Instalar as dependências do sistema (Python e pipx) via XBPS

```bash
sudo xbps-install -S python3 python3-pipx
```

## 🏠 Instale o pacote mkdocs no ambiente virtual do Python

```bash
pipx install mkdocs
```

## Adicione o novo path ao Sistema Operacional, de forma local ou global

## Local

```bash
pipx ensurepath
```

## Global

```bash
sudo pipx ensurepath --global
```

## Local vai constar no .bashrc do usuário

```bash
# Created by `pipx` on 2025-11-27 14:07:54
export PATH="$PATH:/home/suporte/.local/bin"
```

## Valide o novo path do usuário para o Sistema Operacional

```bash
source ~/.bashrc
```

## Valide a instalação do pacote

```bash
mkdocs --version
```

## Instalação do tema Material no ambiente virtual do Python

```bash
pipx inject mkdocs mkdocs-material
```

## O injection vai instalar o pacote do tema em um path oculto, no home do usuário

```bash
/home/suporte/.local/bin/mkdocs
```

## Sequência de uso da ferramenta:

## 1. Criar um Novo Projeto

## 🔧 Para iniciar um novo projeto de documentação, navegue até o diretório onde deseja criar o projeto e execute:

```bash
mkdocs new Void_Artigos
```

## Isso criará um novo diretório chamado Void_Artigos com a estrutura básica do MkDocs.

## 2. Usar o Tema Material (Opcional)

## 🧩 Se você criou um novo projeto, edite o arquivo de configuração mkdocs.yml dentro do diretório do projeto (Void_Artigos/mkdocs.yml) e adicione a configuração do tema Material:

```bash
site_name: Void Artigos
nav:
    - Home: index.md
    - Sobre: about.md

theme:
  name: material # Adicione esta linha para usar o tema Material
```

## 3. Iniciar o Servidor de Desenvolvimento

## Para visualizar sua documentação localmente enquanto a edita, navegue até o diretório do projeto e inicie o servidor de desenvolvimento:

```bash
cd void-Artigos
```

```bash
mkdocs serve
```

## O servidor será iniciado e você poderá acessar a documentação no seu navegador, geralmente em http://127.0.0.1:8000. O MkDocs monitorará automagicamente as alterações nos seus arquivos e recarregará a página.

## Para servir a rede interna, disponibilize o ip e a porta do Servidor

```bash
mkdocs serve 192.168.70.100:8000
```

## Sendo acessível de qualquer navegador da rede interna

```bash
http://192.168.70.100:8000
```

## 4. Construir a Documentação Estática

## Quando sua documentação estiver pronta para ser publicada, construa os arquivos estáticos:

```bash
mkdocs build
```

## Isso criará um diretório chamado site/ contendo todos os arquivos HTML, CSS e JavaScript necessários para hospedar sua documentação em qualquer servidor web. Em resumo, o fato de estar no Void Linux não altera o fluxo de trabalho do MkDocs, graças ao uso do pipx que isola a aplicação de forma eficaz.

---

🎯 THAT'S ALL FOLKS!

👉 Contato: zerolies@disroot.org
👉 https://t.me/z3r0l135
