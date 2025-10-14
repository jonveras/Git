/* 

    1 - se parar o job SPED(000_0110_MIT_PROCESSAR_LF_ERROS_MIT_PROCESSAR_SPED), tem que rodar o ultimo step

    2 - geralmente quem locka o banco é o job lx_processos

    3 - se a fila de restauração do AG tiver alta, verificar o 9.100 e derrubar quem tiver fudendo o SA

    4 - sempre q for mexer em algum job ou trigger que já existe, alterar um codigo que esteja dentro, salva o codigo antigo ai: \\192.168.9.91\File Server AAF\Departamentos\TI\SuporteDB\Documentacao\Jobs

    5 - a tabela job_audit mostra todas as modificações

    6 - Solicitar a power para acompanhar o sped nos primeiros 5 dias do mês, o mais importante são os steps 6, 7, 8

    7 - TIME LINX SUPORTE:
    de manha maicon santana
    a tarde rodrigo ferreira ou johnny bittencourt
    de madrugada marcus oliveira

    8 - os jobs 000_DD_04HR_UPDATE_OBJETOS_BI e 000_DD_01HR_LX_GS_PROCESSOS_PCP_MRP_PLANEJAMENTO podem se travar
    step 10 do objetos_bi trava o 5 do mrp
 /*