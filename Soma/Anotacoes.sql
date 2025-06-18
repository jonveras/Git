/* 

    1 - se parar o job SPED(000_0110_MIT_PROCESSAR_LF_ERROS_MIT_PROCESSAR_SPED), tem que rodar o ultimo step
    2 - geralmente quem locka o banco é o job lx_processos
    3 - se a fila de restauração do AG tiver alta, verificar o 9.100 e derrubar quem tiver fudendo o SA
    4 - sempre q for mexer em algum job que já existe, alterar um codigo que esteja dentro, salva o codigo antigo ai: \\192.168.9.91\File Server AAF\Departamentos\TI\SuporteDB\Documentacao\Jobs
    5 - a tabela job_audit mostra todas as modificações
 
 /*