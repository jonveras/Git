USE [master]
GO
--DESABILITAR
SELECT 'ALTER LOGIN [' + name + '] DISABLE'
FROM syslogins 
WHERE name NOT IN (
    'sa',
    '##MS_SQLResourceSigningCertificate##',
    '##MS_SQLReplicationSigningCertificate##',
    '##MS_SQLAuthenticatorCertificate##',
    '##MS_PolicySigningCertificate##',
    '##MS_SmoExtendedSigningCertificate##',
    '##MS_PolicyTsqlExecutionLogin##',
    '##MS_AgentSigningCertificate##',
    '##MS_PolicyEventProcessingLogin##',
    'NT SERVICE\SQLWriter',
    'NT SERVICE\Winmgmt',
    'NT SERVICE\MSSQLSERVER',
    'NT AUTHORITY\SYSTEM',
    'NT SERVICE\SQLSERVERAGENT',
    'NT SERVICE\SQLTELEMETRY',
    'ANIMALE\sql.admin',
    'marco.banaggia_c',
    'animale\lucas.miranda',
    --logins que já estavam desabilitados
    --colocados como excecao pra nao serem ativados
	'ANIMALE\dbaonline',
	'ANIMALE\Administrador',
	'ANIMALE\backup',
	'DBAONLINE',
	'DBSleek',
	'DBVIEWS',
	'LinxDbWeb',
	'RAFAEL.MEDEIROS',
	'SB_FINANCEIRO',
	'TI_CONSULTA',
	'SOMASUPORTE',
	'DBSleekMF',
	'LUIZ.SENA',
	'CONSTANTINO.NETO',
	'Planejamento_animale',
	'Atacado_soma',
	'Time_nv',
	'Omni.Sustentacao',
	'Inovacao_Animale',
	'Linx_trace',
    --fim
    --DBA
    'GUILHERME.ROCHA',
    'JONATHAN.VERAS',
    'PAULO.TAVARES'
    --fim
) AND sysadmin = 0
ORDER BY name
OPTION (RECOMPILE)
 
----HABILITAR
SELECT 'ALTER LOGIN [' + name + '] ENABLE'
FROM syslogins 
WHERE name NOT IN (
    'sa',
    '##MS_SQLResourceSigningCertificate##',
    '##MS_SQLReplicationSigningCertificate##',
    '##MS_SQLAuthenticatorCertificate##',
    '##MS_PolicySigningCertificate##',
    '##MS_SmoExtendedSigningCertificate##',
    '##MS_PolicyTsqlExecutionLogin##',
    '##MS_AgentSigningCertificate##',
    '##MS_PolicyEventProcessingLogin##',
    'NT SERVICE\SQLWriter',
    'NT SERVICE\Winmgmt',
    'NT SERVICE\MSSQLSERVER',
    'NT AUTHORITY\SYSTEM',
    'NT SERVICE\SQLSERVERAGENT',
    'NT SERVICE\SQLTELEMETRY',
    'ANIMALE\sql.admin',
    'marco.banaggia_c',
    --logins que já estavam desabilitados
    --colocados como excecao pra nao serem ativados
	'ANIMALE\dbaonline',
	'ANIMALE\Administrador',
	'ANIMALE\backup',
	'DBAONLINE',
	'DBSleek',
	'DBVIEWS',
	'LinxDbWeb',
	'RAFAEL.MEDEIROS',
	'SB_FINANCEIRO',
	'TI_CONSULTA',
	'SOMASUPORTE',
	'DBSleekMF',
	'LUIZ.SENA',
	'ANIMALE\power.g.saraiva',
	'CONSTANTINO.NETO',
	'Planejamento_animale',
	'Atacado_soma',
	'Time_nv',
	'Omni.Sustentacao',
	'Inovacao_Animale',
	'Linx_trace',
    --fim
    --DBA
    'GUILHERME.ROCHA',
    'JONATHAN.VERAS',
    'PAULO.TAVARES'
    --fim
) AND sysadmin = 0
ORDER BY name
OPTION (RECOMPILE)