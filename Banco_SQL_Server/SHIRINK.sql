-- #############################################
-- VARIÁVEIS DE CONFIGURAÇÃO (AJUSTE AQUI)
-- #############################################
 
-- Nome lógico do arquivo que você quer encolher (Ex: 'SEU_ARQUIVO_DE_DADOS_PRIMARY')
DECLARE @FileName sysname = N'NOME DO ARQUIVO LOGICO';
 
-- Tamanho MÍNIMO em MegaBytes (MB) que o arquivo DEVE ter no final.
-- Coloque um valor um pouco acima do espaço usado.
DECLARE @TargetSizeMB int = 50000; -- Exemplo: 50 GB
 
-- Tamanho do bloco a ser encolhido a cada iteração (em MB).
-- 1024 MB = 1 GB.
DECLARE @ShrinkStepMB int = 1024;
 
-- Tempo de espera (em milissegundos) entre cada tentativa de shrink.
-- 1000 ms = 1 segundo. Ajuda a evitar bloqueios.
DECLARE @DelayMS int = 1000;
 
-- #############################################
-- VARIÁVEIS DE CONTROLE
-- #############################################
DECLARE @CurrentSizeMB int;
DECLARE @SQL nvarchar(MAX);
DECLARE @DBName sysname = DB_NAME();
 
-- 1. Obtém o tamanho atual do arquivo em MB
SELECT @CurrentSizeMB = size * 8 / 1024
FROM sys.database_files
WHERE name = @FileName AND type_desc = 'ROWS';
 
IF @CurrentSizeMB IS NULL
BEGIN
    PRINT 'ERRO: Arquivo "' + @FileName + '" não encontrado ou não é um arquivo de dados.';
    RETURN;
END
 
PRINT '--- INÍCIO DO PROCESSO DE SHRINK ---';
PRINT 'Banco de Dados: ' + @DBName;
PRINT 'Arquivo Alvo: ' + @FileName;
PRINT 'Tamanho Atual: ' + CAST(@CurrentSizeMB AS varchar) + ' MB';
PRINT 'Tamanho Desejado: ' + CAST(@TargetSizeMB AS varchar) + ' MB';
PRINT 'Passo de Encolhimento: ' + CAST(@ShrinkStepMB AS varchar) + ' MB';
PRINT '--------------------------------------';
 
-- 2. LOOP DE ENCOLHIMENTO
WHILE @CurrentSizeMB > @TargetSizeMB
BEGIN
    -- Calcula o novo tamanho que o arquivo deve ter
    DECLARE @NewTarget int = @CurrentSizeMB - @ShrinkStepMB;
 
    -- Garante que o novo alvo não seja menor que o alvo final
    IF @NewTarget < @TargetSizeMB
    BEGIN
        SET @NewTarget = @TargetSizeMB;
    END
 
    -- Constrói o comando DBCC SHRINKFILE
    SET @SQL = N'DBCC SHRINKFILE (' + QUOTENAME(@FileName, '''') + N', ' + CAST(@NewTarget AS nvarchar) + N');';
 
    PRINT 'Tentando encolher para: ' + CAST(@NewTarget AS varchar) + ' MB. (' + CONVERT(nvarchar, GETDATE(), 120) + ')';
    -- 3. Executa o Shrink (Emite o comando)
    EXEC sp_executesql @SQL;
 
    -- 4. Aguarda o delay para liberar locks
    WAITFOR DELAY @DelayMS;
 
    -- 5. Atualiza o tamanho atual do arquivo para a próxima iteração
    SELECT @CurrentSizeMB = size * 8 / 1024
    FROM sys.database_files
    WHERE name = @FileName AND type_desc = 'ROWS';
 
    -- Se o shrink não conseguiu reduzir mais do que a redução esperada,
    -- pode ser que o espaço usado tenha chegado no limite.
    IF @CurrentSizeMB > @NewTarget AND @NewTarget = @TargetSizeMB
    BEGIN
        PRINT 'AVISO: O arquivo não pode ser encolhido mais do que o tamanho atual de ' + CAST(@CurrentSizeMB AS varchar) + ' MB.';
        BREAK;
    END
END
 
PRINT '--- PROCESSO CONCLUÍDO ---';
PRINT 'Tamanho Final: ' + CAST(@CurrentSizeMB AS varchar) + ' MB';