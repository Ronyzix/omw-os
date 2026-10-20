# OMW OS 0.0.1-dev2 — imagem experimental de bring-up

**Estado: não testada na TV Box física.** Esta imagem é destinada a diagnóstico inicial pelo console UART serial.

## O que mudou

O initramfs agora oferece um menu de recuperação em português com diagnóstico somente leitura, terminal, ajuda, reiniciar e desligar. As três artes de referência OMW ficam na partição FAT em `/OMW/visuais/`. U-Boot, TF-A, Linux e BusyBox continuam compilados a partir das fontes travadas pelo projeto, sem rootfs de distribuição. O menu foi exercitado em QEMU ARM64 genérico, e os PNGs foram extraídos do FAT e comparados byte a byte.

## Limites importantes

**Não há desktop, interface gráfica, HDMI, Wi-Fi ou rootfs persistente nesta imagem.** Os PNGs são arquivos de referência, não uma tela que o sistema desenha. QEMU genérico não testa boot ROM Allwinner, U-Boot físico, DRAM LPDDR3, a X96Q H313 nem seus periféricos; nenhum boot físico foi validado.

Só considere um teste se houver console UART compatível e use um cartão SD removível separado. Se você só consegue observar pela TV/HDMI, não espere aparecer imagem e aguarde uma revisão com vídeo validado. O DTS usa UART0 e MMC0 para o SD, não habilita MMC2/eMMC. Não instale nem grave a imagem na memória Android interna.

## Integridade

Arquivo `OMW-X96Q-LPDDR3-v0.0.1-dev2.img`, tamanho 150.994.944 bytes (144 MiB), SHA-256 `52c1898d0d2ed9d45a63cf503fee0151f7c5120994da7a5a55270892af116507`. O arquivo `.sha256` correspondente também acompanha a release.
