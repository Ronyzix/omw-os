# Wi‑Fi do X96Q: evidências e decisão de implementação

## Conclusão prática

Ainda não há evidência suficiente para ativar um módulo Wi‑Fi específico no device tree da placa do usuário. X96Q é uma família com revisões e componentes diferentes. O nome da placa e o SoC, sozinhos, não identificam o módulo sem fio. Não vou adicionar pinos, GPIOs de reset/wake ou reguladores de XR819 por suposição: um device tree incorreto pode deixar o Wi‑Fi ausente ou interferir em outros sinais da placa.

O DTS atual do OMW continua intencionalmente limitado a UART0 e ao cartão SD em MMC0. Ele não habilita Wi‑Fi, HDMI, Ethernet nem o eMMC interno. A imagem existente segue sendo apenas uma imagem de bring-up, ainda não testada na TV Box.

## O que as fontes mostram

O arquivo de configuração corrente do Armbian `config/boards/x96q.tvb` identifica o alvo como **X96Q TV Box**, família `sun50iw9`, usa `x96q_lpddr3_defconfig` e ativa uma extensão denominada `uwe5622-allwinner`. O código-fonte dessa extensão descreve explicitamente o módulo como Spreadtrum UWE5622 / AW859A. Isso é uma pista sobre o alvo do Armbian, não prova de que a placa física do usuário tenha esse chip, e tampouco confirma que o OMW atual consiga inicializá-lo. O nome do arquivo não deve ser tratado como um identificador `BOARD` diferente sem conferir a lógica do build. [1] [2]

O tópico do X96Q H313 LPDDR3 tem relatos de Wi‑Fi funcional em determinados builds e de ausência de Wi‑Fi em outros. Na página 5, um usuário da revisão DDR3L v5.1 relata suspeita de XR819, mas a conversa não confirma o chip; outro relato descreve uma placa LPDDR3 v1.3 cujo Wi‑Fi só funcionou depois de aplicar uma configuração de device tree. Esses casos demonstram diferenças entre revisões, não identificam o módulo da unidade Proeletronic deste projeto. [3]

Para XR819 existe um driver Linux fora da árvore principal (`xradio_wlan`) e firmware separado. O mantenedor descreve limitações importantes: driver não pronto para produção, risco de travamento em situações de erro e perdas de quadros/desempenho. O exemplo de device tree depende de detalhes elétricos específicos — reguladores, barramento SDIO, pinos de reset e wake. Portanto, mesmo que a unidade tenha XR819, copiar esse exemplo sem confirmar o esquema/pinos não é uma implementação segura nem uma garantia de Wi‑Fi confiável. [4]

A documentação Linux-sunxi lista XR819 como dispositivo SDIO e identifica drivers/firmware necessários; também lista outros chips, incluindo AW859A e variantes Realtek, com necessidades de suporte diferentes. O repositório alternativo ImmortalWrt para X96Q H313, por sua vez, declara que o Wi‑Fi interno não é suportado naquele build. Nenhuma dessas fontes prova o componente da unidade específica do usuário. [5] [6]

## Próxima decisão técnica

Antes de tocar no DTS ou incluir firmware binário, identificar o módulo da placa LPDDR3 v1.3 por uma destas evidências: extração do device tree/boot log do Android da própria unidade; leitura dos identificadores SDIO (`vendor:device`) no Linux quando houver um boot funcional; ou foto nítida da placa e do módulo/chip Wi‑Fi. O procedimento de leitura deve evitar comandos de escrita e não deve instalar nada no eMMC. A caixa Prosmart e a X96Q v5.1 DDR3L permanecem fora da declaração de compatibilidade até serem identificadas e testadas separadamente.

Se o identificador confirmar XR819, a integração exigirá avaliar licença e proveniência dos blobs, compilar o driver para exatamente o kernel OMW, obter o mapeamento elétrico da revisão e testar repetidos ciclos de Wi‑Fi/reboot com UART. Se confirmar UWE5622/AW859A ou RTL8189, será outro caminho de driver/firmware e outro device tree. Até essa confirmação, Wi‑Fi interno deve aparecer como **não confirmado**, não como funcional.

Uma alternativa futura de baixo risco é permitir adaptador Wi‑Fi USB cujo ID e driver estejam presentes no kernel, mas nenhum adaptador específico está incluído ou testado nesta fase.

## Fontes

[1]: https://raw.githubusercontent.com/armbian/build/main/config/boards/x96q.tvb "Configuração atual do board X96Q no Armbian"
[2]: https://raw.githubusercontent.com/armbian/build/main/extensions/uwe5622-allwinner.sh "Extensão UWE5622/AW859A do Armbian"
[3]: https://forum.armbian.com/topic/43682-armbian-for-h313-x96-q-lpdddr3-tv-box/page/5/ "Relatos de Wi-Fi e variantes no tópico X96Q"
[4]: https://github.com/fifteenhex/xradio "Driver Linux fora da árvore para XR819"
[5]: https://linux-sunxi.org/Wifi "Matriz de dispositivos Wi-Fi Allwinner no Linux-sunxi"
[6]: https://github.com/vlukjanenko/immortalwrt_x96q_tv_box "Build ImmortalWrt para X96Q que declara Wi-Fi interno não suportado"
