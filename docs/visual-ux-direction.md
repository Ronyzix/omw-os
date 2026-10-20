# Direção visual e experiência do OMW OS

## Princípio

OMW deve ser próprio e fácil de usar em uma TV, com conceitos de navegação familiares para quem conhece o Windows — menu principal, barra inferior, janelas, pastas e atalhos — sem copiar logotipo, papel de parede, ícones proprietários ou recursos gráficos do Windows. A referência de “Windows inspirado” é uma orientação de organização e facilidade, não uma promessa de compatibilidade nem uma cópia visual literal.

## Identidade visual

A paleta principal combina laranja/coral com rosa/magenta, com superfícies em creme claro e ameixa escura para contraste. O wallpaper original foi composto como ondas e formas abstratas em 16:9, deixando área limpa para ícones. O conceito de inicialização usa um emblema geométrico OMW abstrato sobre fundo escuro. Ambos são conceitos visuais do projeto; ainda não foram integrados a um sistema gráfico executável.

- Wallpaper: `assets/omw-wallpaper-orange-pink.png`.
- Conceito de inicialização: `assets/omw-startup-concept.png`.

## Diretrizes de usabilidade

A primeira tela deverá priorizar poucos destinos compreensíveis: **Início**, **Arquivos**, **Internet**, **Configurações** e **Desligar**. A interface deve ser operável com teclado e controle remoto, com foco visível, alvos grandes e nomes em português. O primeiro assistente deve solicitar idioma, fuso horário e rede, sem exigir comandos de terminal para a configuração comum. Um menu textual numerado em português continuará disponível como modo de recuperação quando a interface gráfica não iniciar.

A área de arquivos deve usar nomes previsíveis e mostrar o cartão SD como armazenamento do OMW. Nenhuma função deve propor “instalar no Android/eMMC”. A atualização do sistema precisa ser reversível e proteger os dados do usuário; a estratégia de partições e recuperação ainda precisa ser definida antes de tornar isso real.

YouTube e Rave são objetivos de acesso, não funções já implementadas. A possibilidade poderá começar como atalhos web em navegador compatível, condicionada a rede, desempenho, disponibilidade dos sites e testes no hardware. Não declarar aplicativo nativo ou reprodução acelerada antes de validar vídeo, áudio HDMI e memória na unidade.

## Critérios de aceitação visual e operacional

1. Identidade laranja/rosa visível em inicialização, fundo, ícones e painel, com contraste legível numa TV.
2. Textos, botões e mensagens em português brasileiro.
3. Navegação por teclado/controle e alternativa de menu numerado.
4. Configuração de rede que mostre o estado real do driver; não exibir “Wi‑Fi conectado” quando o módulo não foi detectado.
5. Interface leve e sem animações pesadas, respeitando a memória física disponível.
6. Nenhum acesso de escrita ao eMMC interno; armazenamento de sistema e usuário restrito ao SD nesta fase.
7. Testes em QEMU descritos como genéricos, sem inferir funcionamento de HDMI, Wi‑Fi ou GUI no H313.
