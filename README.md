# OMW OS — projeto independente

Repositório privado: [Ronyzix/omw-os](https://github.com/Ronyzix/omw-os).

Este projeto não deriva de uma imagem de distribuição pronta. As imagens antigas em `/home/ubuntu/omw` foram consultadas somente como evidência técnica; nenhum `.img`, rootfs instalado ou framework Armbian entra no build. O bootloader, kernel, device tree, initramfs e a imagem de ensaio são compilados/montados a partir de fontes e configurações registradas no projeto.

## O que “do zero” significa aqui

O BootROM físico do Allwinner H313 não é substituível: é parte do SoC. Para iniciar Linux, o projeto precisa de software compatível com a cadeia Allwinner, como SPL/U-Boot e Trusted Firmware-A, e de kernel/device tree. OMW compila esses componentes a partir dos fontes e configura o perfil da placa; isso não usa um sistema operacional ou rootfs pronto. O tratamento de DRAM LPDDR3 parte de uma configuração pública específica de board que está identificada e registrada no projeto; precisa ser confirmada no hardware físico.

## Progresso atual

- **M0 — firmware:** TF-A v2.14.0 e U-Boot v2026.07 compilados para o perfil X96Q LPDDR3 v1.3. Build e hashes em [milestone M0](docs/milestone-m0-firmware.md).
- **M1 — kernel/initramfs/imagem de ensaio:** Linux v6.18.1, DTS OMW mínimo (UART0 + MMC0), BusyBox estático e uma imagem raw de 144 MiB montada em arquivo sandbox. [Relatório M1 e checksums](docs/milestone-m1-kernel-image.md).
- A imagem raw teve seu MBR/partição FAT, posição do U-Boot e conteúdo dos arquivos verificados offline; a repetição do empacotamento produziu o mesmo SHA-256.
- **Não foi testada na TV Box e não foi emulada.** O sandbox não tem QEMU de sistema nesta sessão. Logo não alegamos que inicialize, nem que preserve comprovadamente o Android em um boot real, embora nenhum código atual escreva no armazenamento interno.
- O DTS mínimo não habilita HDMI, Wi-Fi, Ethernet, Bluetooth nem MMC2/eMMC. O initramfs abre um shell pela UART serial; para primeiro teste físico é necessário console serial compatível. Ainda não há instalador para SD nem rootfs persistente.

## Build

Com as fontes fixadas em `source-lock.txt` e as ferramentas de compilação instaladas, executar nesta ordem:

```sh
scripts/build-firmware.sh
scripts/build-kernel.sh
scripts/build-initramfs.sh
scripts/build-sd-test-image.sh
```

A imagem resultante é criada como arquivo regular sob `out/sd-test/`. Nenhum dos scripts grava em `/dev/mmc*`, cartão físico ou armazenamento interno.

## Segurança e próximos marcos

O alvo declarado é uma única Proeletronic X96Q H313 com LPDDR3 v1.3. Não presumir que X96Q v5.1 DDR3L ou caixa Prosmart sejam a mesma placa. Próximo marco: teste controlado em SD separado, com UART, verificando SPL/DRAM, U-Boot, kernel e initramfs. Só depois estabilizar MMC/rootfs, acrescentar saída HDMI e periféricos e trabalhar na experiência de instalação. Não grave a imagem atual como se fosse release pronta.

Veja também o [inventário de boot](docs/boot-chain-inventory.md) e o [plano de bring-up](docs/bring-up-plan.md).
