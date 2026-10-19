# Inventário técnico: cadeia de boot da X96Q

## Evidência local disponível

O arquivo de referência é `Armbian-unofficial_25.05.0-trunk_X96q-lpddr3-v1-3_bookworm_edge_6.12.11_xfce_desktop.img.xz`, guardado em `/home/ubuntu/omw/reference/`, com o respectivo SHA-256. O raw de trabalho está em `/home/ubuntu/omw/work/Armbian-X96Q-LPDDR3-v1.3-reference.img`. Ele foi montado em modo somente leitura para esta inspeção; não foi gravado em cartão ou na TV Box nesta etapa.

A leitura do MBR do raw encontrou a assinatura `55 aa` e uma entrada Linux tipo `0x83`: início no setor 8192 (4 MiB), extensão 9.486.336 setores. Isso descreve o layout daquela imagem de referência, não um requisito imutável do OMW. A imagem contém também dados de boot fora da partição; portanto, particionar somente o ext4 não bastará para criar um cartão inicializável.

O metadata dentro do rootfs registra:

- `BOARD=x96q-lpddr3-v1-3`
- `BOARD_NAME="X96Q LPDDR3 V1.3"`
- `BOARDFAMILY=sun50iw9`, `LINUXFAMILY=sunxi64`, `ARCH=arm64`
- kernel `6.12.11-edge-sunxi64`
- `fdtfile=allwinner/sun50i-h313-x96-q-lpddr3.dtb`
- `overlay_prefix=sun50i-h616`
- `rootdev=UUID=...`, `rootfstype=ext4`

O `boot.cmd` da referência carrega DTB, `uInitrd` e `Image`, e chama `booti`. Isso permite localizar componentes e parâmetros da imagem de teste; não torna o sistema de arquivos dessa imagem uma base aprovada para o novo OMW.

## Divergência importante de identificadores

A página atual do catálogo Armbian apresenta a receita `BOARD=x96q` para uma X96Q TV Box. O arquivo atual `config/boards/x96q.tvb` aponta a `BOARDFAMILY=sun50iw9` e `BOOTCONFIG=x96q_lpddr3_defconfig`. Já a imagem histórica registra `BOARD=x96q-lpddr3-v1-3`. São nomes e revisões/configurações de momentos diferentes. Não vamos tratá-los como intercambiáveis sem comparar o código do bootloader, os parâmetros de DRAM e o DTB com a placa física exata.

O patch upstream atual para U-Boot contém um defconfig e um DT próprio para X96Q LPDDR3. Ele seleciona parâmetros de DRAM e o DT H313/H616. Esses dados são pistas críticas para o bring-up, não prova de compatibilidade com qualquer revisão da X96Q. O DTS correspondente define os controladores MMC e dispositivos de placa, mas não confirma por si só a montagem física do usuário.

## Cadeia de boot conhecida e não conhecida

A documentação de U-Boot Allwinner descreve que o BootROM carrega um SPL/U-Boot do cartão SD a partir de offsets convencionais (setor 16/8 KiB; SoCs H3 e posteriores também consultam setor 256/128 KiB). Esse detalhe é para planejar uma imagem de SD; gravar nesses offsets apaga dados do meio de destino e, por isso, o script futuro deve aceitar somente um SD de teste identificado. Não será emitido nenhum comando para eMMC/NAND.

Ainda falta provar na unidade física do usuário: se esta revisão tenta de fato o SD primeiro no procedimento usado, qual procedimento do botão/slot/energia é necessário, qual saída serial está acessível e se o artefato OMW compilado consegue inicializar DRAM. O relato histórico do usuário de boot por SD e Ethernet/USB funcionais foi na imagem comunitária anterior; não é teste do OMW independente.

## Fontes técnicas consultadas

- [Documentação U-Boot: Allwinner/Sunxi boot](https://docs.u-boot.org/en/v2024.10/board/allwinner/sunxi.html) — formato `u-boot-sunxi-with-spl.bin`, dependência TF-A em SoCs 64-bit e offsets convencionais de SD.
- [Catálogo Armbian X96Q](https://www.armbian.com/boards/x96q) — receita de build publicada para `BOARD=x96q`.
- [Código Armbian `x96q.tvb`](https://raw.githubusercontent.com/armbian/build/main/config/boards/x96q.tvb) — `BOOTCONFIG`, família SoC e extensão configurados atualmente.
- [Patch U-Boot X96Q LPDDR3](https://raw.githubusercontent.com/armbian/build/main/patch/u-boot/v2026.07-sunxi64/board_x96q/0001-add-x96q-lpddr3-dt-and-defconfig.patch) — defconfig e parâmetros de DRAM específicos, sujeitos a validação na placa.
- [DTS X96Q H313 LPDDR3](https://raw.githubusercontent.com/armbian/build/main/patch/kernel/archive/sunxi-6.18/dt_64/sun50i-h313-x96q-lpddr3.dts) — mapeamento de periféricos da variante no patch de kernel.
- [Tópico Armbian H313 X96-Q LPDDR3](https://forum.armbian.com/topic/43682-armbian-for-h313-x96-q-lpddr3-tv-box/) — histórico comunitário de boot por SD e diferenças físicas entre revisões. Relatos de usuários, não especificação garantida.
- [Guia Armbian de adição de placas](https://docs.armbian.com/build-framework/adding-a-board/) — campos e organização do framework; usado somente para compreender a integração pública, não como base do OMW.
- [linux-sunxi: H616](https://linux-sunxi.org/H616) — contexto para a família H616/H313; a identificação exata do SoC precisa continuar sendo vinculada à placa observada.
