# OMW OS — projeto independente

Este diretório inicia o novo OMW sem derivar uma imagem de distribuição pronta. As imagens antigas em `/home/ubuntu/omw` são somente evidência técnica; nenhum artefato de build deste projeto deve usar um `.img`, rootfs ou sistema instalado anterior como base.

## Princípio de construção

OMW terá configuração de boot, seleção de kernel, device tree, initramfs, root filesystem, serviços e interface sob controle do projeto. Vamos construir a imagem SD a partir de fontes e componentes escolhidos explicitamente, com manifesto e hashes reproduzíveis. Não vamos copiar o rootfs Debian/Armbian nem modificar uma imagem pronta.

“Do zero” não significa reescrever o BootROM físico, que vem dentro do SoC. Para chegar a um Linux na placa, OMW ainda precisará de código executável compatível com a cadeia Allwinner — por exemplo SPL/U-Boot e, para o caminho ARM64 suportado, Trusted Firmware-A — além de um kernel. Esses componentes podem ser compilados a partir do código-fonte e configurados/alterados para OMW; não são uma distribuição. Nenhuma escrita em eMMC/NAND será feita pelo processo de desenvolvimento.

## Primeiro marco

**M0 — SD bring-up seguro:** produzir a partir do código-fonte um bootloader mínimo próprio para o perfil exato LPDDR3 v1.3, gravável em cartão de teste, que alcance uma saída observável (preferencialmente UART; HDMI/LED como sinais auxiliares). M0 não inclui rootfs, desktop ou instalação interna.

Não considerar M0 aprovado até que a imagem seja verificada antes da gravação e o boot seja observado na própria TV Box. Uma compilação bem-sucedida no sandbox não prova que a DRAM ou o boot físico funcionam.

## Documentos

- [Inventário da cadeia de boot e evidências](docs/boot-chain-inventory.md)
- [Plano de construção e critérios de avanço](docs/bring-up-plan.md)
- [Marco M0: firmware compilado, boot físico pendente](docs/milestone-m0-firmware.md)

## Estado atual

O primeiro firmware SPL/U-Boot para o perfil LPDDR3 foi compilado com sucesso a partir das fontes upstream fixadas. Ainda não existe imagem completa do OMW e o firmware não foi testado na TV Box; o próximo passo é validar o boot em SD de teste, idealmente com UART, antes de adicionar kernel ou rootfs.

## Segurança de armazenamento

O alvo é um cartão SD removível de teste. Os scripts futuros terão como padrão recusar dispositivos com características de eMMC, listar e exigir confirmação do destino, e nunca instalar U-Boot, kernel ou rootfs em `/dev/mmcblk*` interno. A regra ainda será testada; não há ferramenta de gravação publicada neste estágio.
