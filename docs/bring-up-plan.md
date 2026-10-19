# Plano de bring-up do OMW independente

## M0 — congelar o alvo e o protocolo de teste

Alvo inicial: uma única X96Q Proeletronic que o usuário identificou como LPDDR3 v1.3, usando apenas SD removível. Não abranger Prosmart nem X96Q V5.1 DDR3L. Os metadados da referência ajudam a mapear a variante, mas a revisão física completa e a resposta do hardware a uma imagem nova ainda precisam ser confirmadas durante um teste. Nenhum teste de energia, boot ou escrita foi executado nesta sessão.

Antes de compilar bootloader, preparar: cartão de teste separado (o de 32 GB já citado, se ainda disponível), backup de qualquer conteúdo importante nele, leitor confiável e uma forma de ver o resultado. UART TTL é preferível para diagnóstico de SPL e kernel, mas não assumir pinout nem conectar adaptador sem confirmar tensão/pinos. Sem UART, registrar HDMI, LED e tempos de inicialização, sabendo que isso fornece menos diagnóstico. Android permanece na memória interna; o OMW não terá etapa de instalação nela.

## M1 — SPL e U-Boot do código-fonte

Obter fontes versionadas de U-Boot e Trusted Firmware-A e toolchain ARM64 verificável. Manter fontes, configuração OMW e patches do projeto em diretório próprio. Gerar um manifesto com upstream URL, commit, versão do compilador e SHA-256 de cada fonte e saída.

Criar o perfil específico da placa com o mínimo necessário: SPL, inicialização de DRAM LPDDR3, console serial e leitura do SD. O ponto mais crítico é o treinamento/timing da memória; valores de outra revisão não podem ser simplesmente assumidos. Compilar primeiro e examinar formato/tamanho/offsets offline. Ainda não gravar.

Critério de aprovação no sandbox: build reproduzível, saída de bootloader identificada, binário e SD layout calculados, e análise de que a escrita fica dentro do cartão removível. Critério de aprovação física: console do bootloader observado na própria caixa e confirmação de que a DRAM foi inicializada, sem tocar no armazenamento interno.

## M2 — carregar um teste mínimo próprio

Depois de M1, carregar uma imagem de teste mínima que imprima uma mensagem identificável e pare. A etapa serve para validar caminho SD → bootloader → próxima fase antes de acrescentar Linux. Manter um cartão experimental separado e registrar a sequência observada. Se o bootloader não aparecer, parar e rever variante, DRAM e método físico; não tentar imagens destinadas a V5.1/DDR3L nem escrever eMMC.

## M3 — kernel e device tree próprios para a placa

Compilar kernel a partir de fonte versionada com configuração OMW e device tree escolhido/alterado no projeto. Iniciar com console serial, RAM, SD/MMC e rootfs mínimo. Acrescentar HDMI e USB um subsistema por vez, preservando logs. Wi‑Fi, áudio, vídeo acelerado e desktop ficam fora do primeiro marco; o histórico já indicou Wi‑Fi ausente na referência e não é evidência para o novo sistema.

## M4 — sistema userspace OMW

Criar root filesystem de forma reproduzível, sem desembrulhar ou copiar de uma imagem pronta. Nesta fase escolheremos explicitamente libc, init, ferramentas e sistema de pacotes ou mecanismo próprio. Somente depois de boot estável de console entram shell/menu em português, atualizações controladas, interface gráfica, navegador e apps web.

## Regras de segurança do cartão

O layout final deve reservar a região inicial necessária ao bootloader e alinhar partições depois dela. A primeira imagem de ensaio será produzida como arquivo e validada sem dispositivo físico. O gravador futuro deve mostrar modelo/capacidade de todos os dispositivos, verificar identidade do SD removível, recusar eMMC, exigir confirmação explícita do apagamento e reler os setores escritos. Nenhum comando destrutivo será executado automaticamente ou sobre a memória interna.

## Critérios para chamar de sistema funcional

Uma compilação não basta. A sequência de evidências é: checksum de fontes e artefato; análise do layout; bootloader observado; kernel com console e RAM corretos; rootfs iniciado; desligamento/reboot normais; repetição de ciclos; periféricos testados na unidade e revisão declaradas. Teste de interrupção de energia só em cartão descartável e com expectativa de perda, depois que backup e recuperação estiverem definidos.
