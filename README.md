# OMW OS — projeto independente

Repositório privado: [Ronyzix/omw-os](https://github.com/Ronyzix/omw-os).

Este projeto não deriva de uma imagem de distribuição pronta. As imagens antigas em `/home/ubuntu/omw` foram consultadas somente como evidência técnica; nenhum `.img`, rootfs instalado ou framework Armbian entra no build. O bootloader, kernel, device tree, initramfs e a imagem de ensaio são compilados/montados a partir de fontes e configurações registradas no projeto.

## O que “do zero” significa aqui

O BootROM físico do Allwinner H313 não é substituível: é parte do SoC. Para iniciar Linux, o projeto precisa de software compatível com a cadeia Allwinner, como SPL/U-Boot e Trusted Firmware-A, e de kernel/device tree. OMW compila esses componentes a partir dos fontes e configura o perfil da placa; isso não usa um sistema operacional ou rootfs pronto. O tratamento de DRAM LPDDR3 parte de uma configuração pública específica de board que está identificada e registrada no projeto; precisa ser confirmada no hardware físico.

## Progresso atual

- **M0 — firmware:** TF-A v2.14.0 e U-Boot v2026.07 compilados para o perfil X96Q LPDDR3 v1.3. Build e hashes em [milestone M0](docs/milestone-m0-firmware.md).
- **M1 — kernel/initramfs/imagem de ensaio:** Linux v6.18.1, DTS OMW mínimo (UART0 + MMC0), BusyBox estático e imagem raw de 144 MiB montada em arquivo sandbox. [Relatório M1 e checksums](docs/milestone-m1-kernel-image.md).
- **QEMU genérico:** kernel e initramfs inicializaram juntos em `virt` ARM64 genérico e abriram o shell em RAM. Automatizado por `scripts/test-qemu-initramfs.sh`.
- A imagem raw teve MBR/partição FAT, posição do U-Boot e conteúdo dos arquivos verificados offline; repetir o empacotamento produziu o mesmo SHA-256.
- **Ainda não testado na TV Box.** O QEMU usado não modela Allwinner H313, DRAM LPDDR3, U-Boot nem periféricos da X96Q; logo não comprova boot na placa. O DTS mínimo não habilita HDMI, Wi-Fi, Ethernet, Bluetooth nem MMC2/eMMC. O initramfs abre shell pela UART serial; não há rootfs persistente.

## Build e teste

Com fontes em `source-lock.txt` e dependências de compilação instaladas:

```sh
scripts/build-firmware.sh
scripts/build-kernel.sh
scripts/build-initramfs.sh
scripts/build-sd-test-image.sh
scripts/test-qemu-initramfs.sh  # emulação genérica, não H313
```

A imagem é criada como arquivo regular em `out/sd-test/`. Nenhum script grava em `/dev/mmc*`, cartão físico ou armazenamento interno.

## Segurança e próximos marcos

O alvo declarado é uma Proeletronic X96Q H313 LPDDR3 v1.3. Não presumir que X96Q v5.1 DDR3L ou caixa Prosmart sejam a mesma placa. Próximo marco físico: testar em SD separado, com UART e pinout/nível elétrico confirmados, e verificar SPL/DRAM, U-Boot, kernel e initramfs. A imagem atual é experimental: não grave como sistema pronto. Só depois estabilizar o boot físico entram rootfs persistente, HDMI/periféricos e experiência de usuário.

Veja também o [inventário de boot](docs/boot-chain-inventory.md) e o [plano de bring-up](docs/bring-up-plan.md).

## Imagem experimental para inspeção

A imagem raw de ensaio e seu checksum estão anexados à [release privada `v0.0.1-dev`](https://github.com/Ronyzix/omw-os/releases/tag/v0.0.1-dev). **O download não significa que esteja pronta para uso:** foi testada apenas em QEMU ARM64 genérico, não na TV Box, e requer UART para saída. Leia o aviso completo da release antes de qualquer gravação.


## Fase de identidade e hardware sem fio

Foram criados dois conceitos visuais originais para orientar o futuro ambiente em português: [wallpaper OMW](assets/omw-wallpaper-orange-pink.png) e [conceito de inicialização](assets/omw-startup-concept.png). Eles ainda não estão integrados ao initramfs ou a uma interface gráfica. A direção de usabilidade está em [visual-ux-direction.md](docs/visual-ux-direction.md).

O chip Wi-Fi da unidade física ainda não foi identificado. O arquivo de configuração corrente do Armbian `config/boards/x96q.tvb` ativa a extensão UWE5622/AW859A, enquanto há relatos e builds com módulos/necessidades diferentes; isso não comprova o chip da Proeletronic deste projeto. Veja [pesquisa de hardware Wi-Fi](docs/wifi-hardware-research.md). Por segurança, o DTS OMW continua sem nó Wi-Fi e não promete conectividade interna até haver evidência da placa.

O armazenamento do sandbox está com aproximadamente 3,5 GiB livres (verificação de 2026-10-20). Por isso, não foi iniciada uma compilação completa ou de grande porte nesta etapa.
