# HDMI e pré-requisitos da interface gráfica

## Situação no kernel fixado pelo projeto

O kernel do OMW está preso ao commit `25442251cbda7590d87d8203a8dc1ddf2c93de61` (Linux v6.18.1). No device tree H616 dessa revisão não existem nós de display engine, mixer, TCON, HDMI ou HDMI PHY. O DTS específico do OMW ativa somente UART0 e o slot removível MMC0. Assim, a imagem experimental atual não tem um caminho validado para acender a saída HDMI e não contém uma interface gráfica. [1] [2]

A configuração do kernel gerada para o bring-up também não foi montada para fornecer uma sessão gráfica; habilitar símbolos DRM, sem um device tree e drivers corretos, não cria uma saída de vídeo.

## Por que não aplicar um patch de HDMI encontrado na web

Em 4 de setembro de 2026 foi enviada uma proposta de nós de device tree para HDMI H616. O próprio autor anotou que os nós não bastam: são necessários um variant de PHY HDMI para H616 e um ajuste no pad select do TCON, que estavam em patches desenvolvidas para outra árvore. O teste publicado foi feito num Orange Pi Zero 3 com H618, não numa X96Q H313. [3]

O repositório de reprodução registra que o mantenedor rejeitou a proposta por descrever incorretamente o hardware DE33; a forma proposta teria problemas com dois mixers e TCON_TOP. O mesmo repositório cita uma refatoração do driver/modelo de display testada em H618, em Linux 7.1-rc2. Isso é evidência útil para orientar o trabalho, mas não é um backport pronto nem prova de compatibilidade com H313/X96Q. [4]

Por esse motivo, não copiei os nós rejeitados nem as alterações de driver atribuídas a outro autor para o kernel do OMW. Isso poderia produzir uma imagem sem HDMI ou com um device tree incorreto. Tampouco vou declarar que HDMI ou GUI foram testados: até agora não há ensaio físico desta imagem na TV Box.

## Caminho seguro para o primeiro teste gráfico

1. Manter a versão atual como imagem serial de recuperação e preservar seu checksum. O slot eMMC interno permanece desabilitado no DTS da placa OMW; não existe etapa de instalação no Android.
2. Acompanhar e importar apenas a descrição de hardware e os drivers DE33/HDMI que forem aceitos no kernel upstream, ou partir de uma base pública atualizada cuja derivação possa ser explicada e revisada. Revalidar no próprio código os nós de clock/reset/PHY e compatíveis do SoC antes de habilitar a placa.
3. Não declarar HDMI habilitado até o build incluir o driver DRM correspondente e os nós de display completos. O primeiro artefato deve continuar sendo de SD removível e ter um caminho de retorno à imagem serial.
4. Validar por UART o bind do display engine, a detecção de `connected`, leitura de EDID e os modos anunciados pelo monitor/TV. A imagem no painel, sozinha, não revela todos os erros. Manter a saída serial ativa para recuperação.
5. Só depois de DRM/KMS ter um conector e modo válidos iniciar a sessão OMW em tela cheia. O próximo shell gráfico deve usar o wallpaper, paleta laranja/rosa e navegação simples definida no projeto. A experiência precisa continuar inicializável pelo menu serial se o vídeo falhar.
6. Verificar os limites de desempenho e a memória da unidade física antes de oferecer navegador, YouTube ou Rave. Esses serviços dependem de conectividade e de um navegador compatível; a imagem e os atalhos de referência não significam que estejam implementados.

## Fontes

[1]: https://github.com/torvalds/linux/blob/25442251cbda7590d87d8203a8dc1ddf2c93de61/arch/arm64/boot/dts/allwinner/sun50i-h616.dtsi "Device tree H616 no commit Linux fixado pelo OMW"
[2]: https://github.com/Ronyzix/omw-os/blob/main/patches/omw-sun50i-h313-x96q-lpddr3.dts "Device tree mínimo da placa OMW"
[3]: https://lists.infradead.org/pipermail/linux-arm-kernel/2026-September/1168998.html "Proposta HDMI H616 e dependências de driver em setembro de 2026"
[4]: https://github.com/BarzinL/h616-hdmi-mainline "Patches, resultado de revisão e teste H618 do HDMI mainline"
