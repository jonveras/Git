/*
1 - Banco do live update:
servidor: cloud.tasken.com
usu�rio: dba
senha: 5w0rdf15h@DBA

BANCO LIVEUPDATE:
1 - CAD_ATUCLIENTES - SABER QUAL A ULTIMA VERS�O
2 - CAD_CLI - DADOS DO CLIENTE
3 - CAD_ATUALIZACOES - � OS SCRIPTS DE ATUALIZA��O

BANCO CLIENTE(SRC):
1 - CONFIGURALIVEUPDATE -  VAI TER AS CONFIGS DO CLIENTE

*****QUANDO FOR CRIAR UMA NOVA BASE(RESTORE) UTILIZANDO UMA BASE J� EXISTENTE, 
*****ATUALIZAR O COD_ATU DA CAD_ATUCLIENTES CONFORME O COD_ATU DA BASE UTILIZADA

SE CRIAR UM NOVA BASE UTILIZANDO A BASE NOVAS_CLIENTES, N�O PRECISA, 
S� UTILIZAR O INSERT NA CAD_CLI INSERT cad_cli VALUES ('TESTE_DBA', 0, 1, NULL)

CRIA��O DA NOVA BASE:
--Acessar conex�o remota no 10.10.10.17

--Acessar servidor 34.225.255.6
servidor: 34.225.255.6
usu�rio: dba
senha: 5w0rdf15h@DBA

--Tabela LIVEUPDATE
INSERT cad_cli VALUES ('SRC-EMDIA-CALLCENTER_9054', 0, 1, NULL)

--Acessar a base configurada, isso j� fora da 10.10.10.17

*****select * from cad_base
*****update cad_base set ip_base = '', BANCO_BASE = 'SRC', USU_BASE = 'src', senha_base = '5w0rdf15h'

select * from configuraliveupdate
--nome_base, cod_base

UPDATE CONFIGURALIVEUPDATE SET CLIENTE = 'NomeCadastrado_CAD_CLI", COD_CLIENTE = 'cod_cli']


------------------------------------------------------------------------------------------------------------------------


ERROS LIVEUPDATE:

1 - ENTRAR NO APLICATIVO DO LIVEUPDATE OU OLHAR A CAD_ATUALIZACOES NO BANCO DO LIVE UPDATE
2 - OLHAR O LOG E VER QUAL SCRIPT ESTA COM ERRO E AJUSTAR

*/