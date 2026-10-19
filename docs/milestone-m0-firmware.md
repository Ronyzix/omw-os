# Marco M0 — firmware compilado, boot físico pendente

**Estado:** compilação de firmware concluída em sandbox ARM64 a partir de fontes upstream fixadas. Não foi criada nem gravada uma imagem de cartão. Nenhum dispositivo SD ou eMMC foi escrito e nenhum teste físico foi executado.

## Fontes e configuração

- U-Boot `v2026.07`, commit `ece349ade2973e220f524ce59e59711cc919263f`.
- Trusted Firmware-A `v2.14.0`, commit `1d5aa939bc8d3d892e2ed9945fa50e36a1a924cc`.
- Perfil de build `x96q_lpddr3_defconfig` compilado com `aarch64-linux-gnu-gcc`.
- DT escolhido: `allwinner/sun50i-h313-x96q-lpddr3`.
- SPL habilitado e suporte LPDDR3 H616/H313 ativado, com clock de DRAM configurado em 600 conforme o patch de perfil.
- Patch específico de board usado como referência e aplicado ao U-Boot: SHA-256 `13bd2a44aa7171899f56fe7774bb353bbabd31c18b68d4eaa9e377c3adfd9a69`. Fonte original: patch U-Boot X96Q LPDDR3 no repositório Armbian. A imagem/rootfs/framework de build Armbian não foram usados na compilação.

## Artefatos gerados

O binário integrado `out/firmware/u-boot-sunxi-with-spl-x96q-lpddr3.bin` tem **887.145 bytes**, SHA-256 `dd3053b277c96a4463e40491ddc628fb08e1523c1584f48fa5a64e1d8664d7cc`.

Componentes verificados por hash e tamanho: SPL `spl/sunxi-spl.bin`, 40.960 bytes, SHA-256 `a99b45b17b0a21d482f010f4df49cb0f8f8fd96d2784842a5e7b0104feed8022`; U-Boot+DTB `u-boot-dtb.img`, 791.824 bytes, SHA-256 `c6af31d4a6d8ac4f77f6fa7cfb65fedcd1c08e64c8aa93d49d078812e8b77039`; TF-A BL31, 53.364 bytes, SHA-256 `619105add78ad158db86168cdfdb8ce1f5b4f1241a1c61fc68d9556fc7585e03`.

O artefato resultante existe e os componentes foram inspecionados localmente. Compilar e identificar o binário **não** prova inicialização bem-sucedida da DRAM nesta revisão da caixa. O próximo critério é confirmar SPL/U-Boot observável em hardware real via UART ou outra saída confiável, a partir de cartão SD de teste descartável, preservando eMMC/NAND.

## Como repetir

Com as duas árvores de fonte correspondentes aos commits registrados em `source-lock.txt`, dependências de compilação presentes e o patch em `patches/u-boot-x96q-lpddr3.patch`, executar `scripts/build-firmware.sh`. O script aplica apenas o patch de board ao código U-Boot, compila BL31, SPL e U-Boot e grava artefatos em `out/firmware/`; não contém escrita em dispositivo de bloco.
