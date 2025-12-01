--verifica a porta que o coletor ta usando
select * from sys.dm_exec_sessions where program_name like /*coloca a porta aqui*/'%1018%' and original_login_name ='APP_COLETOR'

--olha no 200
--cria um trace pra verificar os objetos que estão rodando e atualiza as estatisticas