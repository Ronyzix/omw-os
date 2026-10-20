# Marco M1 — kernel, initramfs e imagem SD de ensaio

**Estado:** artefatos mínimos compilados de fontes, imagem raw montada em arquivo e kernel/initramfs inicializados em QEMU ARM64 genérico. As verificações locais cobrem hashes, DTB, MBR, FAT e extração dos arquivos. **A TV Box X96Q não foi testada; não há alegação de boot físico.**

## Componentes

- Linux v6.18.1, commit `25442251cbda7590d87d8203a8dc1ddf2c93de61`, ARM64. `Image` com 49.330.688 bytes, SHA-256 `6c143907e4f50bba51d3366f5e533a36a6b14c7fe01912bf049434e6503d6402`.
- DTS OMW mínimo: `OMW OS X96Q H313 LPDDR3 minimal bring-up`, compatível com `hechuang,x96-q` / `allwinner,sun50i-h616`. Habilita somente UART0 como `serial0` e MMC0 para o SD removível; não habilita MMC2/eMMC, HDMI, Ethernet, Wi-Fi, Bluetooth ou OPP/DVFS. SHA-256 do fonte: `c79477d69c9eb89c794c62c7c4f603c72ab9371cd7c491c3b60b302b416138ea`.
- DTB `sun50i-h313-x96q-lpddr3.dtb`, 18.124 bytes, SHA-256 `560e7589835501620464a31e4d56b0a7ba4209b59fb33add0b97a99bf68f5332`. `fdtget` confirmou modelo/compatibilidade, alias serial0, alias mmc0, `stdout-path=serial0:115200n8` e `status=okay` nos nós UART0 e MMC0.
- BusyBox v1.37.0, commit `be7d1b7b1701d225379bc1665487ed0871b592a5`, compilado estaticamente para AArch64; `file` identifica ELF ARM64 estático e `ldd` retorna “not a dynamic executable”. O shell e a sintaxe de `/init` foram verificados no sandbox.
- Initramfs gzip com `/init`, `/dev/console` e `/etc/os-release`, 1.194.198 bytes, SHA-256 `610091e2b498026d8cc3991a6ea5330ee40553c38f5cd690633f948bd05e2569`. `/init` monta devtmpfs/proc/sys e abre um shell; não monta root persistente no SD.

## Teste de kernel/initramfs em QEMU

Executado com QEMU 8.2.2 em `-machine virt -cpu cortex-a57 -m 512M`, usando saída serial para arquivo. O kernel ARM64 chegou ao `/init`; o log incluiu a linha de comando, `OMW OS bring-up initramfs`, mensagem de execução em RAM e indicação `UART0 + MMC0 minimal test environment`. O shell permaneceu ativo até o timeout intencional. O teste automatizado está em `scripts/test-qemu-initramfs.sh`.

Este QEMU **não emula Allwinner H313, SPL/U-Boot, treinamento LPDDR3, pinos de boot, MMC real, HDMI ou periféricos da X96Q**. Portanto prova somente que este kernel ARM64 e este initramfs conseguem inicializar juntos em uma máquina virt genérica, não que a imagem inicie na caixa alvo.

## Imagem raw offline

`out/sd-test/OMW-X96Q-LPDDR3-v0.0.1-dev.img` é um arquivo de 150.994.944 bytes (144 MiB), SHA-256 `269bb79d36a1d3c4c415eebdcff33ed5e211638e02976197c0887d766a0481eb`. O checksum portátil fica ao lado em `.img.sha256`.

Layout: MBR no setor 0; firmware `u-boot-sunxi-with-spl.bin` no offset de 8.192 bytes/setor 16 (conforme documentação sunxi do próprio U-Boot); uma partição primária FAT32 tipo LBA `0x0c` inicia no setor 32.768/16 MiB, tem 262.144 setores/128 MiB e contém `boot.scr`, kernel, initramfs e DTB. O script U-Boot carrega os três arquivos do SD e executa `booti` com `console=ttyS0,115200 earlycon rdinit=/init`.

A montagem da imagem é determinística para esses fontes/artefatos: o processo foi repetido e produziu o mesmo SHA-256. A checagem local conferiu magic/entrada MBR, faixa da partição, firmware íntegro no offset e extração byte-a-byte do kernel, initramfs e DTB do FAT. O cabeçalho e as diretivas principais do `boot.scr` também foram inspecionados.

## Limites e segurança

A imagem ainda não foi testada na TV Box real e não é uma release de uso validado. O boot requer que a ROM aceite o SPL, que a configuração LPDDR3 inicialize a DRAM corretamente e que MMC0/UART0 correspondam à placa. O initramfs depende de console serial; HDMI não está habilitado. O risco de falha de boot permanece até teste controlado em SD separado com console de diagnóstico.

Nenhum comando escreveu em cartão físico ou armazenamento interno. `scripts/build-sd-test-image.sh` escreve apenas o arquivo regular ignorado pelo Git em `out/sd-test/`; não contém `dd` para `/dev/*`.

## Reproduzir

Com as fontes fixadas em `source-lock.txt` e dependências de compilação presentes, executar `scripts/build-firmware.sh`, `scripts/build-kernel.sh`, `scripts/build-initramfs.sh` e `scripts/build-sd-test-image.sh`. O teste genérico opcional é `scripts/test-qemu-initramfs.sh`. O builder monta o arquivo raw e valida MBR/FAT sem selecionar dispositivo de bloco.


## Revisão `v0.0.1-dev2` — menu serial e ativos visuais

A revisão `out/sd-test/OMW-X96Q-LPDDR3-v0.0.1-dev2.img` continua com 150.994.944 bytes (144 MiB). SHA-256: `52c1898d0d2ed9d45a63cf503fee0151f7c5120994da7a5a55270892af116507`. O arquivo de checksum correspondente fica ao lado. A imagem antiga `v0.0.1-dev.img` não foi sobrescrita.

O `/init` no initramfs foi atualizado para exibir um menu em português pelo console serial: diagnóstico de leitura, terminal de diagnóstico, ajuda/limites, reiniciar e desligar. O diagnóstico mostra linha de boot, partições e montagens; não grava em armazenamento. A raiz segue no initramfs em RAM, não há rootfs persistente e o DTS continua usando apenas UART0 e MMC0 (SD removível), sem habilitar MMC2/eMMC.

As três artes OMW foram copiadas à partição FAT em `/OMW/visuais/` e um `LEIA-ME.txt` explica que são referências, não uma GUI executável. O construtor lê os PNGs de volta do FAT e compara byte a byte. O espaço livre do FAT após a cópia foi de aproximadamente 72,8 MiB.

### Verificações da revisão dev2

- `bash -n` aprovou os scripts do initramfs, da imagem e do teste.
- O smoke test automatizado iniciou o kernel e o initramfs em QEMU ARM64 `virt`, verificando o menu serial.
- Uma sessão QEMU com entrada serial interativa exercitou diagnóstico, ajuda, abertura/saída do terminal e retorno ao menu.
- Os três PNGs foram extraídos da imagem e comparados byte a byte com os originais.
- MBR, limites da partição FAT, posição do U-Boot e checksum do arquivo foram verificados.

Esses testes **não** emulam a X96Q H313, DRAM LPDDR3, boot ROM, U-Boot físico, HDMI ou Wi‑Fi. O kernel não tem uma cadeia DRM/KMS/HDMI funcional nesta placa. A imagem `v0.0.1-dev2` é somente um incremento de bring-up para quem dispõe de console serial; não é uma imagem com interface gráfica e não foi testada na TV Box.
