![Texto alternativo](https://i.ibb.co/Ng3PHPp2/image.png)

## Requisitos 🚨

 Esse script ele e um ponto de partida, ou seja, ele se baseia do fato de voce ja ter instalado o Arch em seu computador
 com KDE e no momento da instalacao ter selecionado os drivers da Nvidia/AMD/Intel.

## Como utilizar❓
**Basta copiar e colar o comando abaixo:**  
   - Terminal: 🚀
     ```
     curl -fsSL https://raw.githubusercontent.com/gabrielmf1998/Arch-Helper/main/ArchHelper.sh | bash
     ```


## Porque foi Criado❓


Com cada vez mais usuarios saindo do Windows e querendo ir para uma distro leve como o Arch, nasceu o **ArchHelper**.

  O projeto foi criado por amor ao Arch Linux e pela vontade de ajudar quem ainda nao migrou, ou quem
  acabou de instalar Linux e se sente perdido nos primeiros passos. A ideia e dar um ponto de partida
  simples, visual e direto, sem esconder o que esta acontecendo por baixo do sistema.

     O ArchHelper nao tenta transformar Linux em Windows. Ele tenta mostrar que Linux pode ser entendido,
  ajustado e usado com seguranca, mesmo por quem ainda nao tem experiencia com terminal.

  ## O que ele consegue fazer❓

  Logo na tela inicial, o ArchHelper mostra um resumo do estado atual do sistema:

  - distro, host, kernel em uso e uptime
  - sessao grafica, KDE/Plasma, IPv4 e IPv6 local
  - discos detectados, uso da particao raiz e pacotes instalados
  - pacotes AUR/foreign, pacotes orfaos e helpers como yay/paru
  - bootloader, EFI, tempo de boot e servicos importantes
  - status de SSH, Flatpak e GPU

  Nos menus, ele oferece funcoes para pos-instalacao, diagnostico, programas, rede, tweaks e manutencao.
  Tambem ajuda em tarefas comuns como instalar codecs, ajustar PipeWire, configurar Fastfetch, instalar
  programas populares, liberar firewall, configurar ZeroTier, corrigir problemas do KDE, restaurar GRUB,
  corrigir NTFS dirty, configurar IP fixo ou DHCP e manter o sistema atualizado.

  Antes de executar comandos que alteram o sistema, o ArchHelper mostra o que sera feito, mostra o comando
  exato e pede confirmacao. Assim o usuario nao apenas clica e espera: ele aprende o que esta sendo
  feito.

  ## Por que Arch❓

  O foco principal e Arch Linux porque Arch representa liberdade, controle e aprendizado. Para quem vem
  do Windows, isso pode parecer dificil no inicio, mas tambem e uma das melhores formas de entender Linux
  de verdade.

  O ArchHelper existe para diminuir essa barreira inicial. Ele organiza tarefas importantes, mostra
  informacoes essenciais do sistema e ajuda o usuario a ganhar confianca para continuar usando Linux.

  ## Compatibilidade

  O script foi escrito em Bash puro e hoje e focado em Arch/KDE, usando ferramentas como pacman, AUR
  helpers, Flatpak, systemd e NetworkManager.
