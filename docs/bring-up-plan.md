# Plano de bring-up do OMW independente

## Alvo e limites

Alvo inicial: uma única X96Q Proeletronic que o usuário identificou como LPDDR3 v1.3. Não abranger Prosmart nem X96Q V5.1 DDR3L sem identificação independente da placa. Metadados anteriores orientam o mapeamento, mas a revisão física completa e a resposta a esta nova cadeia de boot ainda precisam ser confirmadas.

**Estado físico:** nesta sessão não houve boot na TV Box nem escrita em SD ou eMMC. Builds e imagem atual existem somente em arquivos do sandbox. O Android interno não foi alterado. A imagem mínima de ensaio é não validada e requer console UART; não é uma release para instalação.

## M0 — firmware fonte

Concluído no sandbox: TF-A v2.14.0 + SPL/U-Boot v2026.07 compilados para o perfil LPDDR3. Os commits, configuração, patch específico do board e hashes estão em `docs/milestone-m0-firmware.md`. A configuração de DRAM se baseia numa referência pública para esse perfil; ainda não é prova que inicialize a variante física do usuário.

## M1 — kernel, device tree e initramfs mínimos

Concluído no sandbox: Linux v6.18.1 ARM64; DTS OMW mínimo para UART0 e MMC0; BusyBox estático v1.37.0; initramfs efêmero em RAM com shell serial. Hashes e conteúdo no relatório `docs/milestone-m1-kernel-image.md`.

A saída HDMI e a maioria dos periféricos foram intencionalmente excluídos do primeiro DTS. MMC2/eMMC não é habilitado pelo DTS da placa. O boot argument `rdinit=/init` abre shell pela serial, sem rootfs persistente no SD.

## M2 — imagem raw de ensaio

Concluído offline: arquivo raw de 144 MiB criado em `out/sd-test/`. MBR e partição FAT, offset Allwinner de U-Boot, arquivos copiados byte-a-byte e checksum foram verificados; dois empacotamentos produziram o mesmo hash. Isso valida o formato/integração offline, não a cadeia de boot física.

Próximo passo físico: usar cartão removível de teste separado e console UART TTL com pinout/nível lógico confirmados. Confirmar primeiro SPL, inicialização de DRAM e U-Boot; só então observar kernel e initramfs. Não fazer teste de gravação de energia nessa primeira tentativa. O usuário deve ler o modelo/capacidade do destino e conservar backup do cartão; qualquer ferramenta futura de gravação precisa identificar explicitamente o SD removível e recusar armazenamento interno.

## M3 — completar hardware do Linux

Depois do console e do shell mínimo confirmados, ligar subsistemas progressivamente com logs: reguladores/PMIC, persistência de MMC apenas para a partição SD, HDMI, USB e Ethernet. Cada node de DTS precisa ser validado contra a placa e contra o kernel upstream, não apenas copiado de variante próxima. Wi‑Fi, áudio, vídeo acelerado e desktop ficam para depois; histórico anterior de Wi‑Fi não é evidência de funcionamento nesta imagem nova.

**Bloqueio de HDMI:** o kernel fixado v6.18.1 não tem nós de display H616 no DTS upstream. Uma proposta HDMI de 2026 foi rejeitada por modelagem DE33 incorreta, e o teste alternativo publicado é em H618. Não copiar o patch rejeitado nem habilitar HDMI na placa X96Q até portar a modelagem aceita/atual do driver e verificar a revisão H313. Manter a imagem serial como recuperação e consultar `docs/hdmi-bring-up.md`.

## M4 — sistema userspace OMW

Só depois de kernel/SD estáveis: estruturar rootfs próprio de forma reproduzível, sem desembrulhar/copiar imagem pronta. Escolher explicitamente libc, init, ferramentas, atualização e persistência. A interface gráfica OMW só começa quando o DRM/KMS inicializar a saída HDMI e reportar EDID/modos; até lá, trabalhar apenas na direção visual/protótipo e manter o menu serial de recuperação. Em seguida, preparar configuração em português, menu inicial e interface gráfica leve, apps e medidas de recuperação.

## Regras permanentes de segurança

Não criar etapa de instalação em eMMC/NAND. O layout SD reserva espaço antes da partição para firmware Allwinner. Qualquer gravador futuro deve listar modelo/capacidade/identificador dos dispositivos, exigir confirmação de apagamento, recusar o dispositivo interno e validar leitura após escrita. Não executar teste destrutivo de queda de energia antes de backup e recuperação definidos, em cartão descartável.

## Critério de sistema funcional

Um build não basta. Evidência exigida em sequência: checksums/versões; integridade do arquivo e layout; bootloader e DRAM observados; kernel com console; shell iniciado; rootfs SD estável; desligamento/reboot repetidos; depois periféricos observados na unidade/revisão declaradas. Relatar separadamente cada subsistema e qualquer função ainda não testada.
