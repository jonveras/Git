CREATE PROCEDURE [DBO].[STPLAN_ACIONA]                  
----------------------------------------------------------------------                
/*  
NOME DO OBJETO: [STPLAN_ACIONA]  
FUNÇÃO DO OBJETO: RESPONSÁVEL POR INSERIR ACIONAMENTOS NA TABELA ACIONA  
USADA EM: TELA DE ATENDIMENTO, JOBS, MALA DIRETA E ETC...  
CAMINHO: F_LANCAACIONA  
ULTIMA ALTERAÇÃO: 29/03/2021  
PROFISSIONAL: ALEXANDRO OLIVEIRA  
  
ALTERAÇÃO: ADICIONADO PARAMETRO ID_GRAVACAO  
  
*/                
----------------------------------------------------------------------
@FLAGTEL                         TINYINT = 0,  
@CONTRATO_FIN                    CHAR(20) = NULL,                        
@COD_ACIONAMENTO                 INT = 0,                        
@COD_RECUP                       INT = 0,                        
@AGENDA_ACIONA                   VARCHAR(5000) = NULL,                        
@COD_STCB                        INT = 0,                        
@LOCTEL_ACIONAMENTO              INT = 0,                        
@COD_TIPAC                       INT = 0,                        
@RETCOB_STCB                     INT = 0,                        
@PESO_STCB                       INT = 0,                        
@PESO_ATUAL                      INT = 0,                        
@TEL_TEL                         CHAR(9) = NULL,                        
@COD_TEL                         INT = NULL,                        
@CPF_DEV                         CHAR(14) = NULL,                        
@COD_STCB_ATUAL                  INT = 0,                        
@DATA_AGENDA                     DATETIME = NULL,                        
@ARQUIVO_SOM                     CHAR(150) = NULL,                        
@RETORNO                         CHAR(50) = NULL OUTPUT,                        
@CONTROLE_DATA                   INT = 0,                        
@PRIOR_STCB                      INT = 99,                        
@COD_MOTIVOACIONA                CHAR(30) = NULL,                        
@DATAAGENDAMENTO_ACIONA          DATETIME = NULL,                        
@RETORNOID                       INT = 0 OUTPUT,                        
@TMPREPIC                        INT = 0,                        
@FLAGALTERDTULTAC                INT = 0,                        
@TMPPROPRIEDADE                  INT = 0,                        
@FLAGALTERSTCB                   INT = 0,                        
@FLAGALTERRECUP                  INT = 0,                        
@SISTEMA                         VARCHAR(10) = '',                        
@COD_CLI                         INT = 0,                        
@RECUP_AGENDA                    INT = NULL,                        
@DATA_AGENDA2                    DATETIME = NULL,                      
@FLAG_ACIONA_DISCADOR            INT = 1,                    
@ALTERATELEFONECHAVE             INT = 1,              
@TELA_ACIONA                     INT = 0,          
@ID_ATENDIMENTO                  INT = 0,        
@FLAGALTERPERCTEL                INT = 0,  
@USAEVENTOACIONANEGATIVARTEL_CAR TINYINT = 1,  
@USAEVENTOACIONAPOSITIVARTEL_CAR TINYINT = 1,  
@DISCADOR                        VARCHAR(100) = '',  
@TIPOLIGACAO                     INT = 0,  
@ID_LIGACAO                      VARCHAR(500) = '',  
  
  
---PARAMETROS SMARTWAYBI--  
  
@FLAGINCLUSAOBI      INT = 1,         
@PERCENTUAL_DESCONTO FLOAT = 0.00,             
@VALOR_DEVIDO        FLOAT = 0.00,             
@VALOR_ACORDO        FLOAT = 0.00,  
@NUMERO_PARCELAS     INT   = 0,  
@DDD_TEL             VARCHAR(5) = '',  
@ID_GRAVACAO         VARCHAR(100) = ''  
  
AS
BEGIN              
    DECLARE @ERRNO                         INT               
    DECLARE @ERRSQL                        INT              
    DECLARE @ERRLEVEL                      INT                        
    DECLARE @DESCRIPTION                   CHAR(100)              
    DECLARE @L_IND_TRANS_STP               SMALLINT              
    DECLARE @L_CODIGO                      SMALLINT                        
    DECLARE @LNFLAGTEL                     SMALLINT                        
    DECLARE @RETORNOSMS                    INT                        
    DECLARE @PROPRIEDADE_ACIONAMENTO       INT                        
    DECLARE @COD_RECUP_FICHA               INT                         
    DECLARE @DATA_REPIC                    DATETIME                   
    DECLARE @EFICAZ                        INT                   
    DECLARE @USA_LIM_TENTATIVAS            INT              
    DECLARE @QTD_LIM_TENTATIVAS            INT              
    DECLARE @STCB_LIM_TENTATIVAS           INT              
    DECLARE @QTD_ACUMULADO                 INT              
    DECLARE @TMPREPIC_FLT                  FLOAT            
    DECLARE @BLACKLIST_ACIONAMENTO         INT    
    DECLARE @HORA_INI                      DATETIME  
    DECLARE @HORA_FIM                      DATETIME  
    DECLARE @REPICDIASUTEIS_CONF           INT  
    --DECLARE @USAEVENTOACIONANEGATIVARTEL_CAR TINYINT  -- FLAG  
    DECLARE @ACIONARNEGATIVARTELEFONE_CONF INT -- CÓDIGO EVENTO NEGATIVO CONFIGURA  
    DECLARE @ACIONARPOSITIVARTELEFONE_CONF INT -- CÓDIGO EVENTO POSITIVO CONFIGURA  
    DECLARE @DATAEVENTO                    DATETIME = GETDATE()  
    DECLARE @MOTIVO_EVENTO                 VARCHAR(200) =''   
    DECLARE @VERSAOSRC_EVENTO              CHAR(10)    
    DECLARE @PERC_TEL                      INT  
    DECLARE @VCOD_EVENTO                   INT -- RECEBE O CÓDIGO DO EVENTO @AcionarPositivarTelefone_Conf OR @AcionarNegativarTelefone_Conf  
    DECLARE @LIMITAPERCTEL100_CONF         INT = 0 -- CONFIGURAÇÃO SISTÊMICA PARA PODER LIMITAR O PERCENTUAL DO TELEFONE EM 100% OU PERMITIR QUE CHEGUE A 110% -- OS 130711   
    DECLARE @VPERC_TEL                     INT -- VARIÁVEL QUE RECEBE O VALOR DO PERCENTUAL DE ACORDO COM A CONFIGURAÇÃO – ESSA VARIÁVEL RECEBE 100% OU 110% - OS 130711  
    DECLARE @CLASSIFICACAO_ACIONAMENTO     INT  
    DECLARE @POSITIVO_ACIONAMENTO          INT  
    DECLARE @ACIONACONTRATODEVOLVIDO_CAR   TINYINT = 0
    DECLARE @GERAEVENTOACIONATEL_CAR       BIT = 1  
    DECLARE @OBS                           VARCHAR(255) = ''  
    DECLARE @ALTERTEL_CONF                 INT = 1  
    DECLARE @GERAEVENTO                    BIT = 0  
    DECLARE @PERC_TEL_OLD                  INT = 0  
    DECLARE @PERC_TEL_NEW                  INT = 0  
    DECLARE @DIAS_STCB                     INT = 0  
    DECLARE @RETIRAHOT_ACIONAMENTO         INT = 1 -- OS 147216 

    IF @TEL_TEL = '00'  
    BEGIN  
        SELECT @TEL_TEL = ''  
    END;  
  
    SELECT    
        @L_IND_TRANS_STP = 0,               
        @L_CODIGO   = 0,               
        @LNFLAGTEL   = 0,              
        @QTD_ACUMULADO   = 0            
  
    IF (@CONTROLE_DATA <> 1) OR (@CONTROLE_DATA IS NULL)                        
    BEGIN                      
        SELECT @DATA_AGENDA = GETDATE()         
    END                        
  
    /*  
    ---------------------------------------------PEGANDO A CONFIGURAÇÃO PARA USAR EVENTO DE NEGATIVAÇÃO DO TELEFONE---------------------------------------------  
    --SELECT @USAEVENTOACIONANEGATIVARTEL_CAR = COALESCE(USAEVENTOACIONANEGATIVARTEL_CAR, 0)   
    --FROM   
    -- CAD_CAR_AUX (NOLOCK) AS A   
    -- JOIN CAD_DEVF (NOLOCK) AS B ON A.COD_CLI = B.COD_CLI AND A.COD_CAR = B.COD_CAR   
    --WHERE   
    -- CONTRATO_FIN = @CONTRATO_FIN  
    -- PEGANDO A CONFIGURAÇÃO PARA USAR EVENTO DE NEGATIVAÇÃO DO TELEFONE  
   
   
    PROCESSO NÃO MAIS UTILIZADO POIS O PARÂMETRO USAEVENTOACIONANEGATIVARTEL AGORA É PASSADO COMO PARÂMETRO  
           
  
    ---------------------------------------------PEGANDO A CONFIGURAÇÃO PARA USAR EVENTO DE NEGATIVAÇÃO DO TELEFONE---------------------------------------------  
    */  
  
    ------------------------------------------------------PEGA DADOS DO ACIONAMENTO QUE ESTÃO SENDO INSERIDOS---------------------------------------------------   
    SELECT                         
        @COD_STCB                  = COD_STCB,    
        @LOCTEL_ACIONAMENTO        = LOCTEL_ACIONAMENTO,                        
        @COD_TIPAC                 = COD_TIPAC,                        
        @TMPREPIC_FLT              = TMPREPIC_ACIONAMENTO,                        
        @TMPPROPRIEDADE            = TPPROPRIEDADE_ACIONAMENTO,              
        @EFICAZ                    = EFICAZ_ACIONAMENTO,              
        @ALTERATELEFONECHAVE       = ALTERATELEFONECHAVE,              
        @RETORNOSMS                = RETORNOSMS_ACIONAMENTO,              
        @PROPRIEDADE_ACIONAMENTO   = PROPRIEDADE_ACIONAMENTO,            
        @FLAGALTERDTULTAC          = COALESCE(ALTDTULTAC_ACIONAMENTO,0),                               
        @BLACKLIST_ACIONAMENTO     = COALESCE(BLACKLIST_ACIONAMENTO,1),  
        @CLASSIFICACAO_ACIONAMENTO = COALESCE(CLASSIFICACAO_ACIONAMENTO, 0),    
        @POSITIVO_ACIONAMENTO      = COALESCE(POSITIVO_ACIONAMENTO, 1),   
        @RETIRAHOT_ACIONAMENTO     = COALESCE(RETIRAHOT_ACIONAMENTO, 1)  
    FROM               
        CAD_ACIONAMENTO (NOLOCK)                        
    WHERE               
        COD_ACIONAMENTO = @COD_ACIONAMENTO               
  
    ------------------------------------------------------PEGA DADOS DO ACIONAMENTO QUE ESTÃO SENDO INSERIDOS---------------------------------------------------   
  
    --PEGA DADOS DO STATUS DE COBRANÇA NOVO 
    SELECT                         
        @PESO_STCB  = PESO_STCB,                        
        @RETCOB_STCB = RETCOB_STCB,  
        @DIAS_STCB = COALESCE(DIAS_STCB, 0)
    FROM               
        CAD_STCB(NOLOCK)                        
    WHERE               
        COD_STCB = @COD_STCB             
  
    --PEGA DADOS DO STATUS DE COBRANÇA NOVO              

    --PEGA DADOS ATUAIS DO CONTRATO
    SELECT                         
        @COD_STCB_ATUAL  = COALESCE(COD_STCB, 0),                        
        @COD_RECUP_FICHA = COD_RECUP,                        
        @COD_CLI   = COD_CLI                  
    FROM               
        CAD_DEVF(NOLOCK)                        
    WHERE    
        CONTRATO_FIN = @CONTRATO_FIN

    --PEGA DADOS ATUAIS DO CONTRATO
    --PEGA O PESO DO STATUS DE COBRANÇA ATUAL                      
    SELECT                         
        @PESO_ATUAL    = PESO_STCB,              
        @USA_LIM_TENTATIVAS  = COALESCE(LIMITATENT_STCB, 1),              
        @QTD_LIM_TENTATIVAS  = COALESCE(QTDTENTATIVAS_STCB, 0),            
        @STCB_LIM_TENTATIVAS = COALESCE(STATALTERNATIVO_STCB, @COD_STCB_ATUAL)              
    FROM                         
        CAD_STCB(NOLOCK)                        
    WHERE                 
        COD_STCB = @COD_STCB_ATUAL

     --PEGA O PESO DO STATUS DE COBRANÇA ATUAL
    -- PEGAR A VERSÃO  
    SELECT 
        @VERSAOSRC_EVENTO = VERATU 
    FROM 
        ERROVER 

    --PEGA O NUMERO DE TENTATIVAS JA FEITAS              
    SELECT              
        @QTD_ACUMULADO = COALESCE(QTDTENTATIVAS_STCB, 0) + 1              
    FROM              
        TBL_CONTROLEEMUSO (NOLOCK)              
    WHERE              
        CONTRATO_FIN = @CONTRATO_FIN           
  
    SELECT   
        @REPICDIASUTEIS_CONF = CAST(INFORMACAO AS INT)   
    FROM   
        CONFIGURA_VERTICAL (NOLOCK)  
    WHERE   
        CAMPO = 'REPICDIASUTEIS_CONF'
  
    -- PEGAR O EVENTO CASO O PERCENTUAL DO TELEFONE SEJA ZERO E TENHA A OPÇÃO USAR EVENTO MARCADA  
    SELECT   
        @ACIONARNEGATIVARTELEFONE_CONF = CAST(INFORMACAO AS INT)  
    FROM  
        CONFIGURA_VERTICAL (NOLOCK)  
    WHERE  
        CAMPO = 'ACIONARNEGATIVARTELEFONE_CONF'
  
    SELECT   
        @ACIONARPOSITIVARTELEFONE_CONF = CAST(INFORMACAO AS INT)  
    FROM  
        CONFIGURA_VERTICAL (NOLOCK)  
    WHERE  
        CAMPO = 'ACIONARPOSITIVARTELEFONE_CONF'

    SELECT   
        @AlterTel_conf = CAST(INFORMACAO AS INT)  
    FROM  
        CONFIGURA_VERTICAL (NOLOCK)  
    WHERE  
        CAMPO = 'AlterTel_conf'

    SELECT   
        @GERAEVENTOACIONATEL_CAR = COALESCE(GERAEVENTOACIONATEL_CAR, 1)   
    FROM   
        CAD_CAR_AUX_AUX AS A (NOLOCK)   
        JOIN CAD_DEVF AS B (NOLOCK) ON A.COD_CLI = B.COD_CLI AND A.COD_CAR = B.COD_CAR AND B.CONTRATO_FIN = @CONTRATO_FIN
  
    -- CONFIGURAÇÃO FEITA PARA LIMITAR O PERCENTUAL ATÉ 100%  
    SELECT   
        @LIMITAPERCTEL100_CONF = COALESCE(CAST(INFORMACAO AS INT), 0)  
    FROM   
        CONFIGURA_VERTICAL (NOLOCK)  
    WHERE   
        CAMPO = 'LIMITAPERCTEL100_CONF'
  
    IF (@LIMITAPERCTEL100_CONF = 0)  
    BEGIN  
        SELECT @VPERC_TEL = 100  
    END ELSE  
    BEGIN  
        SELECT @VPERC_TEL = 110  
    END  
   
    --TELEFONE INFORMADO EXISTE                           
    IF (@FLAG_ACIONA_DISCADOR = 1)              
    BEGIN                   
        IF EXISTS (SELECT 1 FROM CAD_DEVT (NOLOCK) WHERE COD_TEL = @COD_TEL AND CPF_DEV = @CPF_DEV)                        
        BEGIN                      
            SELECT  @LNFLAGTEL = 1                                     
        END                                  
    END ELSE                      
    BEGIN                
    IF EXISTS (SELECT 1 FROM CAD_DEVT (NOLOCK) WHERE TEL_TEL = @TEL_TEL AND CPF_DEV = @CPF_DEV)                      
        BEGIN         
            SELECT @LNFLAGTEL = 1                      
  
            SELECT               
                @COD_TEL = COD_TEL               
            FROM               
                CAD_DEVT(NOLOCK)                 
            WHERE               
                TEL_TEL = @TEL_TEL                      
                AND CPF_DEV = @CPF_DEV   
        END                      
    END                       
  
    --TELEFONE INFORMADO EXISTE                      
    IF (
        SELECT 
            COALESCE(ACIONACONTRATODEVOLVIDO_CAR, 0)  
        FROM   
            CAD_CAR_AUX AS A   
            JOIN CAD_DEVF AS B ON A.COD_CLI = B.COD_CLI AND A.COD_CAR = B.COD_CAR  
        WHERE   
            COALESCE(ACIONACONTRATODEVOLVIDO_CAR, 0) = 1  
            AND B.CONTRATO_FIN = @CONTRATO_FIN --OR (B.cpf_dev = @CPF_DEV))  -- Remoção feita para atender a OS 135521 dia 27/07/2017  
            AND STATCONT_FIN = 1  
        
    ) = 1 -- NÃO ACIONA CONTRATOS DEVOLVIDOS    
    BEGIN     
        SET @ACIONACONTRATODEVOLVIDO_CAR = 1     
    END -- VERIFICAÇÃO DE CONTRATOS | ATIVO\INATIVO   

    IF @ACIONACONTRATODEVOLVIDO_CAR <> 1  
    BEGIN
        --ACIONAMENTO SMARTWAYBI                       
        --IF @FLAGINCLUSAOBI = 0       
        --BEGIN       
        -- SELECT        
        --  @HORA_INI = HORA_INI ,        
        --  @HORA_FIM = COALESCE(HORA_FIM,GETDATE())       
        -- FROM        
        --  CAD_ATENDIMENTO        
        -- WHERE        
        --  ID= @ID_ATENDIMENTO          
        
        -- INSERT SMARTWAYBI.DBO.SBI_TBL_ACIONAMENTO(       
        --   ACI_CONTRATO_FIN,ACI_CPF_DEV,ACI_COD_RECUP,       
        --   ACI_TEL_TEL,       
        --   ACI_COD_MOTIVOACIONAMENTO,ACI_COD_ACIONAMENTO,ACI_AGENDA_ACIONA,ACI_DATA_AGENDA,ACI_ID_ATENDIMENTO,ACI_DATA_HORA_INICIO_ATENDIMENTO,ACI_DATA_HORA_FIM_ATENDIMENTO,       
        --   ACI_PERCENTUAL_DESCONTO,ACI_VALOR_DEVIDO,ACI_VALOR_ACORDO,ACI_NUMERO_PARCELAS,ACI_DDD_TEL       
        -- )             
        -- VALUES(@CONTRATO_FIN,@CPF_DEV,@COD_RECUP,  
        
        --   --VERIFICAR QUAL O TIPO DE LIGAÇÃO       
        --   CASE       
        --    WHEN        
        --     @FLAGTEL = 0    THEN  @TEL_TEL        
        --    WHEN ISNUMERIC(@TEL_TEL) = 1 THEN 'ATIVO'        
        --    ELSE 'RECEPTIVO'        
        --   END,                   
        --   @COD_MOTIVOACIONA,@COD_ACIONAMENTO,@AGENDA_ACIONA,@DATA_AGENDA,@ID_ATENDIMENTO,@HORA_INI,@HORA_FIM,         
        --   @PERCENTUAL_DESCONTO,@VALOR_DEVIDO, @VALOR_ACORDO,@NUMERO_PARCELAS,@DDD_TEL       
        --   )       
        
        --END;      
        
        IF @FLAGTEL=0       
        BEGIN       
            IF ISNUMERIC(@TEL_TEL) = 1                              
            BEGIN       
                INSERT ACIONA(CONTRATO_FIN,DATA_ACIONA,COD_ACIONAMENTO,AGENDA_ACIONA,COD_RECUP,TEL_TEL,COD_TIPAC,ARQUIVO_SOM,COD_MOTIVOACIONA,DATAAGENDAMENTO_ACIONA, DATA_ACIONA2, RECUP_AGENDA, DATA_AGENDA, TELA_ACIONA, COD_TEL,DDD_TEL)                             
                VALUES(@CONTRATO_FIN, @DATA_AGENDA,@COD_ACIONAMENTO,@AGENDA_ACIONA,@COD_RECUP,@TEL_TEL,@COD_TIPAC,@ARQUIVO_SOM,@COD_MOTIVOACIONA,@DATAAGENDAMENTO_ACIONA, DBO.FNDBADATASEMHORA(GETDATE()), @RECUP_AGENDA, @DATA_AGENDA2, @TELA_ACIONA, @COD_TEL,@DDD_TEL)  

                IF @CLASSIFICACAO_ACIONAMENTO = 1 -- CLASSIFICAÇÃO ACIONAMENTOS HUMANO E MÁQUINA  
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        QTD_ACIONAMENTOS_HUMANO = COALESCE(QTD_ACIONAMENTOS_HUMANO, 0) + 1, DATA_ULTIMO_ACIONAMENTO_HUMANO = @DATA_AGENDA  
                    WHERE   
                        CONTRATO_FIN = @CONTRATO_FIN    
                END ELSE   
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        QTD_ACIONAMENTOS_MAQUINA = COALESCE(QTD_ACIONAMENTOS_MAQUINA, 0) + 1, DATA_ULTIMO_ACIONAMENTO_MAQUINA = @DATA_AGENDA  
                    WHERE 
                        CONTRATO_FIN = @CONTRATO_FIN   
                END  

                IF @POSITIVO_ACIONAMENTO = 0  
                BEGIN   
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        DATA_ULTIMO_ATENDIMENTO = @DATA_AGENDA  
                    WHERE 
                        CONTRATO_FIN = @CONTRATO_FIN  
                END  

                IF @EFICAZ = 0  
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        DATA_ULTIMO_CPC = @DATA_AGENDA  
                    WHERE  
                        CONTRATO_FIN = @CONTRATO_FIN  
                END
            END ELSE       
            BEGIN
                SET @LNFLAGTEL = 0              
    
                INSERT ACIONA(CONTRATO_FIN,DATA_ACIONA,COD_ACIONAMENTO,AGENDA_ACIONA,COD_RECUP,TEL_TEL,COD_TIPAC,ARQUIVO_SOM,COD_MOTIVOACIONA,DATAAGENDAMENTO_ACIONA, DATA_ACIONA2, RECUP_AGENDA, DATA_AGENDA, TELA_ACIONA, COD_TEL, DDD_TEL)                             
                VALUES(@CONTRATO_FIN, @DATA_AGENDA,@COD_ACIONAMENTO,@AGENDA_ACIONA,@COD_RECUP,'ATIVO',@COD_TIPAC,@ARQUIVO_SOM,@COD_MOTIVOACIONA,@DATAAGENDAMENTO_ACIONA, DBO.FNDBADATASEMHORA(GETDATE()), @RECUP_AGENDA, @DATA_AGENDA2, @TELA_ACIONA, @COD_TEL, @DDD_TEL) 

                IF @CLASSIFICACAO_ACIONAMENTO = 1 -- CLASSIFICAÇÃO ACIONAMENTOS HUMANO E MÁQUINA  
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        QTD_ACIONAMENTOS_HUMANO = COALESCE(QTD_ACIONAMENTOS_HUMANO, 0) + 1, DATA_ULTIMO_ACIONAMENTO_HUMANO = @DATA_AGENDA  
                    WHERE 
                        CONTRATO_FIN = @CONTRATO_FIN    
                END ELSE   
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        QTD_ACIONAMENTOS_MAQUINA = COALESCE(QTD_ACIONAMENTOS_MAQUINA, 0) + 1, DATA_ULTIMO_ACIONAMENTO_MAQUINA = @DATA_AGENDA  
                    WHERE 
                        CONTRATO_FIN = @CONTRATO_FIN   
                END

                IF @POSITIVO_ACIONAMENTO = 0  
                BEGIN   
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        DATA_ULTIMO_ATENDIMENTO = @DATA_AGENDA  
                    WHERE  
                        CONTRATO_FIN = @CONTRATO_FIN  
                END

                IF @EFICAZ = 0  
                BEGIN  
                    UPDATE 
                        AUX_DEVF 
                    SET 
                        DATA_ULTIMO_CPC = @DATA_AGENDA  
                    WHERE 
                        CONTRATO_FIN = @CONTRATO_FIN  
                END
            END
        END ELSE                             
        BEGIN 
            SET @LNFLAGTEL = 0  

            INSERT ACIONA(CONTRATO_FIN,DATA_ACIONA,COD_ACIONAMENTO,AGENDA_ACIONA,COD_RECUP,TEL_TEL,COD_TIPAC,ARQUIVO_SOM,COD_MOTIVOACIONA,DATAAGENDAMENTO_ACIONA, DATA_ACIONA2, RECUP_AGENDA, DATA_AGENDA, TELA_ACIONA, COD_TEL,DDD_TEL)              
            VALUES(@CONTRATO_FIN, @DATA_AGENDA,@COD_ACIONAMENTO,@AGENDA_ACIONA,@COD_RECUP,'RECEPTIVO',@COD_TIPAC,@ARQUIVO_SOM,@COD_MOTIVOACIONA,@DATAAGENDAMENTO_ACIONA, DBO.FNDBADATASEMHORA(GETDATE()), @RECUP_AGENDA, @DATA_AGENDA2, @TELA_ACIONA, @COD_TEL,@DDD_TEL)       

            IF @CLASSIFICACAO_ACIONAMENTO = 1 -- CLASSIFICAÇÃO ACIONAMENTOS HUMANO E MÁQUINA  
            BEGIN  
                UPDATE 
                    AUX_DEVF 
                SET 
                    QTD_ACIONAMENTOS_HUMANO = COALESCE(QTD_ACIONAMENTOS_HUMANO, 0) + 1, DATA_ULTIMO_ACIONAMENTO_HUMANO = @DATA_AGENDA  
                WHERE   
                    CONTRATO_FIN = @CONTRATO_FIN    
            END ELSE   
            BEGIN  
                UPDATE   
                    AUX_DEVF 
                SET 
                    QTD_ACIONAMENTOS_MAQUINA = COALESCE(QTD_ACIONAMENTOS_MAQUINA, 0) + 1, DATA_ULTIMO_ACIONAMENTO_MAQUINA = @DATA_AGENDA  
                WHERE   
                    CONTRATO_FIN = @CONTRATO_FIN   
            END  
            
            IF @POSITIVO_ACIONAMENTO = 0  
            BEGIN   
                UPDATE 
                    AUX_DEVF 
                SET 
                    DATA_ULTIMO_ATENDIMENTO = @DATA_AGENDA  
                WHERE  
                    CONTRATO_FIN = @CONTRATO_FIN  
            END

            IF @EFICAZ = 0  
            BEGIN  
                UPDATE 
                    AUX_DEVF 
                SET 
                    DATA_ULTIMO_CPC = @DATA_AGENDA  
                WHERE  
                    CONTRATO_FIN = @CONTRATO_FIN  
            END
        END                        
                    
        SELECT @RETORNOID = @@IDENTITY      
                
        -- INSERI CONTRATOS NA BLACKLIST         
        IF (@BLACKLIST_ACIONAMENTO = 0)         
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM CAD_BLOQUEIO(NOLOCK) WHERE CONTRATO_FIN = @CONTRATO_FIN)         
            BEGIN         
                INSERT INTO CAD_BLOQUEIO(CONTRATO_FIN, DATA_BLOQUEIO, STATCONT_BLOQUEIO)VALUES(@CONTRATO_FIN, GETDATE(), 0)         
            END ELSE         
            BEGIN           
                UPDATE 
                    CAD_BLOQUEIO 
                SET          
                    STATCONT_BLOQUEIO = 0,         
                    DATA_BLOQUEIO = GETDATE()         
                WHERE          
                    CONTRATO_FIN =@CONTRATO_FIN         
            END
        END
        -- INSERI CONTRATOS NA BLACKLIST
        --ATUALIZA CAD_ATENDIMENTO                  
        IF @ID_ATENDIMENTO > 0               
        BEGIN          
            UPDATE 
                CAD_ATENDIMENTO 
            SET                
                COD_ACIONAMENTO = @COD_ACIONAMENTO,               
                ID_ACIONA = @RETORNOID               
            WHERE                
                ID = @ID_ATENDIMENTO
        
            INSERT SDM_STAGE_ACIONAMENTO (SSA_CONTRATO_FIN, SSA_CPF_DEV, SSA_COD_RECUP, SSA_COD_ACIONAMENTO, SSA_ID_ATENDIMENTO, SSA_COD_MOTIVOACIONAMENTO, SSA_DATA)  
            VALUES (@CONTRATO_FIN, @CPF_DEV, @COD_RECUP, @COD_ACIONAMENTO, @ID_ATENDIMENTO, TRY_CAST(@COD_MOTIVOACIONA AS INT), @DATA_AGENDA)
        END

        -- INICIO GUARDA INFORMAÇÃO NA TABELA AUXILIAR DE DISCADOR        
        IF @DISCADOR <> ''  
        BEGIN   
            INSERT INTO CAD_ACIONA_DISCADOR (ID_ACIONA, DISCADOR, TIPO_LIGACAO, DDD, TELEFONE)    
            VALUES (@RETORNOID, @DISCADOR, @TIPOLIGACAO,  SUBSTRING(COALESCE(@DDD_TEL, ''), LEN(COALESCE(@DDD_TEL, ''))-1, 2), SUBSTRING(COALESCE(@TEL_TEL, ''), LEN(COALESCE(@TEL_TEL, ''))-8, 9))  
            
            IF @ID_LIGACAO <> ''  
            BEGIN  
                INSERT INTO TAB_IDLIGACAODISCADOR_ACIONA (ID_ACIONA,ID_LIGACAO,TELEFONE, DISCADOR, TIPO_LIGACAO, ID_GRAVACAO)  
                VALUES (@RETORNOID, @ID_LIGACAO, @TEL_TEL, @DISCADOR, @TIPOLIGACAO, @ID_GRAVACAO)  
            END  
        END

        -- INICIO PRIORIDADE               
        SELECT 
            @PRIOR_STCB = PRIOR_STCB                           
        FROM 
            CAD_PRIORSTCB (NOLOCK)                             
        WHERE 
            COD_STCB = @COD_STCB                             
            AND COD_GRUPO IN (SELECT COD_GRUPO FROM CAD_RECUP (NOLOCK) WHERE COD_RECUP = @COD_RECUP_FICHA)  
                                        
        IF (@PRIOR_STCB IS NULL)                             
        BEGIN                        
            SELECT @PRIOR_STCB = 99                                 
        END                               
        
        IF (@PRIOR_STCB = '')                             
        BEGIN                                      
            SELECT  @PRIOR_STCB = 99                                        
        END
        
        --CONTROLE PARA TEMPO DE REPIC POR ACIONAMENTO                                                
        IF @TMPREPIC_FLT > 0                              
        BEGIN
            IF @REPICDIASUTEIS_CONF = 0       
            BEGIN       
                SELECT @DATA_REPIC = DBO.FNSRCRETORNARDIAUTIL(@DATA_AGENDA + @TMPREPIC_FLT)       
            END ELSE       
            BEGIN       
                SELECT @DATA_REPIC = @DATA_AGENDA + @TMPREPIC_FLT       
            END
        END
        /* MARCOS REBITTE | 04/06/2019 */ -- OS 143018  
        -- VERIFICA SE RETIRA DE COBRANÇA E SE HÁ DIAS CONFIGURADOS  
        IF (@RETCOB_STCB = 1 AND @DIAS_STCB > 0)  
        BEGIN          
            INSERT INTO TBL_CONTROLE_STCB (CONTRATO_FIN, CPF_DEV, COD_STCB, DIAS_STCB)  
            VALUES (@CONTRATO_FIN, @CPF_DEV, @COD_STCB, @DIAS_STCB)          
        END

        IF (@PESO_ATUAL <= @PESO_STCB AND @FLAGALTERSTCB <> 1) OR (@USA_LIM_TENTATIVAS = 0 AND @QTD_LIM_TENTATIVAS <= @QTD_ACUMULADO)                   
        BEGIN
            IF (@USA_LIM_TENTATIVAS = 0) AND (@QTD_LIM_TENTATIVAS <= @QTD_ACUMULADO)                   
            BEGIN                                        
                SELECT @COD_STCB = @STCB_LIM_TENTATIVAS                
        
                UPDATE 
                    TBL_CONTROLEEMUSO 
                SET 
                    QTDTENTATIVAS_STCB = 0                   
                WHERE 
                    CONTRATO_FIN = @CONTRATO_FIN                                                
            END                              
        
            IF (@FLAGALTERDTULTAC = 1)                   
            BEGIN--NAO ALTERA DTULTAC_FIN
                IF (
                    NOT EXISTS (SELECT * FROM CAD_DEVP WHERE CONTRATO_FIN = @CONTRATO_FIN AND COD_STPA = 0)   
                    AND   
                    NOT EXISTS (SELECT * FROM CAD_ACO WHERE CONTRATO_FIN = @CONTRATO_FIN AND COD_STAC IN (0,1,3,4,6,7,10,11))
                    ) -- OS 145284  
                BEGIN
                    UPDATE 
                        CAD_DEVF 
                    SET                        
                        COD_STCB  = @COD_STCB,                
                        COBRANCA_FIN = @RETCOB_STCB,                    
                        PRIOR_STCB  = @PRIOR_STCB ,  
                        COD_STCBANT = @COD_STCB_ATUAL  
                    WHERE   
                        CONTRATO_FIN = @CONTRATO_FIN
                END ELSE  
                BEGIN  
                    UPDATE 
                        CAD_DEVF 
                    SET                        
                        COD_STCB  = @COD_STCB,                
                        PRIOR_STCB  = @PRIOR_STCB ,  
                        COD_STCBANT = @COD_STCB_ATUAL  
                    WHERE   
                        CONTRATO_FIN = @CONTRATO_FIN     
                END

                IF @TMPREPIC_FLT > 0                              
                BEGIN--TEMPO DE REPIQUE MAIOR QUE 0 (ZERO)                           
                    UPDATE 
                        TBL_CONTROLEEMUSO 
                    SET 
                        DT_FICHAVISUALIZADA = @DATA_REPIC  --FNSRCRETORNARDIAUTIL                            
                    WHERE 
                        CPF_DEV = @CPF_DEV                                        
                END
            END ELSE --NAO ALTERA DTULTAC_FIN                                          
            BEGIN--ALTERA DATA DO ÚLTIMO ACIONAMENTO

                UPDATE CAD_DEVF SET                             
                    COD_STCB  = @COD_STCB,                              
                    DTULTAC_FIN  = @DATA_AGENDA,                           
                    ULTAC_FIN  = @COD_ACIONAMENTO,               
                    ULTIDACIONA_FIN = @RETORNOID,                           
                    COBRANCA_FIN = @RETCOB_STCB,                             
                    PRIOR_STCB  = @PRIOR_STCB,  
                    COD_STCBANT = @COD_STCB_ATUAL       
                WHERE        
                    CONTRATO_FIN = @CONTRATO_FIN                                                        
        
                IF (@TMPREPIC_FLT > 0)                   
                BEGIN--TEMPO DE REPIQUE MAIOR QUE 0 (ZERO)                                               
                    UPDATE TBL_CONTROLEEMUSO SET DT_FICHAVISUALIZADA = @DATA_REPIC                              
                    WHERE CPF_DEV = @CPF_DEV                                                       
                END
            END
        END ELSE                             
        BEGIN
            IF COALESCE(@FLAGALTERDTULTAC, 0) <> 1                              
            BEGIN--ALTERA DATA DO ÚLTIMO ACIONAMENTO         
                UPDATE 
                    CAD_DEVF 
                SET        
                    DTULTAC_FIN  = @DATA_AGENDA,                             
                    ULTAC_FIN  = @COD_ACIONAMENTO,                           
                    ULTIDACIONA_FIN = @RETORNOID                           
                WHERE                    
                    CONTRATO_FIN = @CONTRATO_FIN                                                  
        
                IF @TMPREPIC_FLT > 0           
                BEGIN--TEMPO DE REPIQUE MAIOR QUE 0                                                                
                    UPDATE 
                        TBL_CONTROLEEMUSO 
                    SET        
                        DT_FICHAVISUALIZADA = @DATA_REPIC                              
                    WHERE                    
                        CPF_DEV = @CPF_DEV                                                          
                END
            END

            --SOMANDO A QTD DE TENTATIVAS                   
            IF (@USA_LIM_TENTATIVAS = 0)            
            BEGIN                                 
                UPDATE 
                    TBL_CONTROLEEMUSO 
                SET                    
                    QTDTENTATIVAS_STCB = COALESCE(QTDTENTATIVAS_STCB, 0) + 1           
                WHERE             
                    CONTRATO_FIN = @CONTRATO_FIN                          
            END
        END
        
        --TRATAMENTO DE SMS                                                           
        IF (@RETORNOSMS = 0)                   
        BEGIN                                                      
            UPDATE 
                CAD_SMS
            SET                    
                DTRETORNO_SMS = GETDATE()                             
            WHERE                    
                CONTRATO_FIN = @CONTRATO_FIN                              
                AND DTENVIO_SMS =  (SELECT MAX(DTENVIO_SMS) FROM CAD_SMS (NOLOCK) WHERE CAD_SMS.CONTRATO_FIN = @CONTRATO_FIN)                                                  
        END

        --TRANSFERE PROPRIEDADE                                                 
        IF (@PROPRIEDADE_ACIONAMENTO =0) AND (@FLAGALTERRECUP <> 1)                             
        BEGIN                                                     
            UPDATE
                CAD_DEVF
            SET
                COD_RECUP = @COD_RECUP,                             
                COD_GRUPO = 0,                             
                DTLIMPROPR_FIN= DATEADD(DD,@TMPPROPRIEDADE,GETDATE())                         
            WHERE
                CONTRATO_FIN = @CONTRATO_FIN                                                    
        END
        
        --ALTERA TELEFONE PRIORITARIO - REDEBRASIL                                                            
        IF (@ALTERATELEFONECHAVE = 0)                          
        BEGIN                                     
            UPDATE 
                CAD_DEVT 
            SET
                PRIORIDADE_TEL = 0                         
            WHERE                    
                CPF_DEV = @CPF_DEV                         
                AND COD_TEL = @COD_TEL                                       
        END
        
        IF (@GERAEVENTOACIONATEL_CAR = 0 AND COALESCE(@ALTERTEL_CONF, 0) <> 0) -- OS 135008   
        BEGIN         
            SELECT 
                @PERC_TEL_OLD = PERC_TEL                
            FROM 
                CAD_DEVT (NOLOCK)   
            WHERE 
                COD_TEL = @COD_TEL AND CPF_DEV  = @CPF_DEV   

            SET @PERC_TEL_NEW = 
                CASE   
                    WHEN @PERC_TEL_OLD + @LOCTEL_ACIONAMENTO > @VPERC_TEL THEN @VPERC_TEL  
                    WHEN @PERC_TEL_OLD + @LOCTEL_ACIONAMENTO < 0 THEN 0  
                    ELSE @PERC_TEL_OLD + @LOCTEL_ACIONAMENTO   
                END  

            
            SET @VCOD_EVENTO = @ALTERTEL_CONF  
            SET @MOTIVO_EVENTO = (
                CASE   
                    WHEN @PERC_TEL_NEW = 0 AND @ALTERTEL_CONF <> 0   
                    THEN 'TELEFONE NEGATIVADO PELO ACIONAMENTO. TELEFONE: ' + ' ' + COALESCE(@TEL_TEL, '0')
                    WHEN @PERC_TEL_NEW >= 100 AND (@ALTERTEL_CONF <> 0)   
                    THEN 'TELEFONE POSITIVADO PELO ACIONAMENTO. TELEFONE: ' + ' ' + COALESCE(@TEL_TEL, '0')   
                END
            )  
            
            SET @OBS = ' PERCENTUAL ANTES DA ALTERAÇÃO = ' +  cast(@PERC_TEL_OLD AS VARCHAR(50)) + ' | PERCENTUAL APÓS A ALTERAÇÃO = ' + CAST(@PERC_TEL_NEW AS VARCHAR(50))          
            
            SET @GERAEVENTO = 
            CASE   
                WHEN @PERC_TEL_OLD <> @PERC_TEL_NEW THEN  1  
                ELSE 0  
            END
        END  

        IF (@FLAGALTERPERCTEL <> 1)      --MUDA O PERCENTUAL DE LOCALIZAÇÃO DO TELEFONE     
        BEGIN        
            IF (@FLAGTEL = 0)              
            BEGIN          
                IF (@LNFLAGTEL = 1)              
                BEGIN                     
                    UPDATE 
                        CAD_DEVT 
                    SET               
                        PERC_TEL = 
                    CASE                       
                        WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) > @VPERC_TEL THEN @VPERC_TEL                       
                        WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) < 0 THEN 0  
                        ELSE PERC_TEL + @LOCTEL_ACIONAMENTO                        
                    END,              
                        EFICAZ_TEL = @EFICAZ                            
                    WHERE               
                        COD_TEL = @COD_TEL AND CPF_DEV  = @CPF_DEV                 
                                    
                    IF @RETIRAHOT_ACIONAMENTO = 0 -- OS 147216  
                    BEGIN  
                        UPDATE 
                            AUX_DEVT 
                        SET   
                            HOT_TEL = 1   
                        WHERE   
                            COD_TEL = @COD_TEL
                            AND CPF_DEV  = @CPF_DEV   
                    END

                    IF EXISTS (SELECT COALESCE(INFORMACAO, 1) FROM CONFIGURA_VERTICAL WHERE CAMPO = 'UTILIZA_DELAY_PERCENTUAL_TELEFONE_CONF' AND INFORMACAO = 0)  
                    BEGIN  
                        IF (SELECT 1 FROM TBL_RELATORIO_PERCENTUAL_TELEFONE WHERE CPF_DEV = @CPF_DEV AND COD_TEL = @COD_TEL) = 1  
                        BEGIN  
                            UPDATE 
                                TBL_RELATORIO_PERCENTUAL_TELEFONE 
                            SET   
                                PERC_TEL = 
                                CASE                       
                                    WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) > @VPERC_TEL THEN @VPERC_TEL                       
                                    WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) < 0 THEN 0  
                                    ELSE PERC_TEL + @LOCTEL_ACIONAMENTO   
                                END,   
                                COD_RECUP = @COD_RECUP,            
                                DESCRICAO = 
                                CASE   
                                    WHEN @POSITIVO_ACIONAMENTO = 0 THEN 'ACIONAMENTO CLIENTE - ALTERANDO PERCENTUAL DEVIDO A ACIONAMENTO POSITIVO'  
                                    ELSE 'ACIONAMENTO CLIENTE - ALTERANDO PERCENTUAL '  
                                END,
                                [DATA] = 
                                CASE   
                                    WHEN @POSITIVO_ACIONAMENTO = 0 THEN GETDATE()  
                                    ELSE [DATA]   
                                END  
                            WHERE   
                                CPF_DEV = @CPF_DEV AND COD_TEL = @COD_TEL  
                        END ELSE  
                        BEGIN  
                            INSERT INTO TBL_RELATORIO_PERCENTUAL_TELEFONE (PERC_TEL, COD_TEL, CPF_DEV, DESCRICAO, COD_RECUP, DATA)   
                            SELECT   
                                PERC_TEL = 
                                CASE                 
                                    WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) > @VPERC_TEL THEN @VPERC_TEL                       
                                    WHEN (PERC_TEL + @LOCTEL_ACIONAMENTO) < 0 THEN 0  
                                    ELSE PERC_TEL + @LOCTEL_ACIONAMENTO   
                                END,   
                                COD_TEL,   
                                CPF_DEV,   
                                'ACIONAMENTO CLIENTE - PRIMEIRO CONTADOR',  
                                @COD_RECUP,   
                                GETDATE()  
                            FROM   
                                CAD_DEVT   
                            WHERE   
                                CPF_DEV = @CPF_DEV AND COD_TEL = @COD_TEL  
                        END  
                    END        
                    SELECT   
                        @PERC_TEL = PERC_TEL,  
                        @TEL_TEL  = TEL_TEL  
                        --CASE WHEN TEL_TEL = '' THEN @TEL_TEL END  
                    FROM   
                        CAD_DEVT (NOLOCK)   
                    WHERE  
                        COD_TEL = @COD_TEL AND CPF_DEV  = @CPF_DEV                   
                                
                    IF (@PERC_TEL = 0 AND @UsaEventoAcionaNegativarTel_Car = 0 AND @GERAEVENTOACIONATEL_CAR = 1) OR (@PERC_TEL = 100 AND  @UsaEventoAcionaPositivarTel_Car = 0 AND @GERAEVENTOACIONATEL_CAR = 1)  
                    BEGIN -- ABRE A VALIDAÇÃO PARA GERAR EVENTO
                        SELECT 
                            @MOTIVO_EVENTO = (  
                            CASE   
                                WHEN @PERC_TEL = 0 AND @USAEVENTOACIONANEGATIVARTEL_CAR = 0 THEN 'TELEFONE NEGATIVADO PELO ACIONAMENTO. TELEFONE: ' + ' ' + COALESCE(@TEL_TEL, '0')
                                WHEN @PERC_TEL > = 100 AND @USAEVENTOACIONAPOSITIVARTEL_CAR = 0 THEN 'TELEFONE POSITIVADO PELO ACIONAMENTO. TELEFONE: ' + ' ' + COALESCE(@TEL_TEL, '0')   
                            END  
                            )

                        SELECT 
                            @VCOD_EVENTO = (  
                            CASE   
                                WHEN @PERC_TEL = 0   and @UsaEventoAcionaNegativarTel_Car = 0 THEN coalesce(@AcionarNegativarTelefone_conf,0)  
                                WHEN @PERC_TEL > = 100 and @UsaEventoAcionaPositivarTel_Car = 0 THEN coalesce(@AcionarPositivarTelefone_Conf,0)  
                            END  
                            )  
                        
                        SET @GERAEVENTO = 1  
                        
                        SELECT 
                            @MOTIVO_EVENTO =  @MOTIVO_EVENTO  
                    END  
                                                            
                    IF  @GERAEVENTO = 1  
                    BEGIN       
                        IF @VCOD_EVENTO <> 0  
                        BEGIN   
                            EXEC STPLAN_EVENTO       
                            @CPF_DEV = @CPF_DEV,       
                            @DATA = @DATA_AGENDA,       
                            @DATA_EVENTO = @DATAEVENTO,       
                            @COD_EVENTO = @VCOD_EVENTO,       
                            @COD_RECUP = @COD_RECUP,       
                            @CONTRATO_FIN = @CONTRATO_FIN,       
                            @COD_TEL = @COD_TEL,       
                            @MOTIVO_EVENTO = @MOTIVO_EVENTO,       
                            @VERSAOSRC_EVENTO = @VERSAOSRC_EVENTO,  
                            @OBS = @OBS,  
                            @JOB = 1             
                        END
                    END
                END
            END
        END
    END
END