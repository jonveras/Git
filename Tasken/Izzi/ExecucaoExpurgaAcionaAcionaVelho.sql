ALTER PROCEDURE ExecucaoExpurgaAcionaAcionaVelho    
    @DATA DATETIME, @BLOCO INT    
AS    
/* *********************************************************************************************** *                                                      
 * NOME DO OBJETO : ExecucaoExpurgaAcionaAcionaVelho                                                                    
 * CRIAÇÃO: 16/05/2025                                                                                           
 * PROFISSIONAL: Jonathan Veras                                                                         
 * PROJETO: Expurgo                                                                              
 * *********************************************************************************************** */                                                      
BEGIN TRY    
    SET NOCOUNT ON;    
    
    DECLARE  @DELETED_VELHO INT, @DELETED_ACIONA INT,     
    @HORA_ATUAL INT, @DATA_INICIO DATETIME, @DATA_FIM DATETIME,
	@DIA INT
    
    WHILE (SELECT COUNT(1) FROM ACIONA_VELHO AS A JOIN CAD_ACIONAMENTO AS B ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO WHERE A.COD_RECUP = 1 AND B.CLASSIFICACAO_ACIONAMENTO = 0 AND A.DATA_ACIONA < @DATA) > 0  
    BEGIN    
        SET @HORA_ATUAL = DATEPART(HOUR, GETDATE())    
		SET @DIA = DATEPART(WEEKDAY, GETDATE())
    
        IF (@HORA_ATUAL >= 21 OR @HORA_ATUAL < 7) OR @DIA = 1
        BEGIN    
		SET @DATA_INICIO = GETDATE()    
    
            DELETE TOP (@BLOCO) A    
            FROM ACIONA_VELHO AS A    
            JOIN CAD_ACIONAMENTO AS B ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO    
            WHERE     
                A.COD_RECUP = 1    
                AND B.CLASSIFICACAO_ACIONAMENTO = 0    
                AND A.DATA_ACIONA < @DATA    
    
            SET @DELETED_VELHO = @@ROWCOUNT    
			SET @DATA_FIM = GETDATE();    
    
            IF @DELETED_VELHO > 0    
            BEGIN    
                INSERT INTO Log_Expurgo_Aciona_AcionaVelho (Tabela, DataInicio, DataFim, RegistrosExcluidos)    
                VALUES ('ACIONA_VELHO', @DATA_INICIO, @DATA_FIM, @DELETED_VELHO);    
            END    
    
        END    
        ELSE    
        BEGIN    
            BREAK;    
        END    
    END    
END TRY                                                        
BEGIN CATCH                                                        
 EXEC STP_LOG_ERRO 'ExecucaoExpurgaAcionaAcionaVelho'                                                        
END CATCH