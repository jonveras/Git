USE [SOMA]
GO
/****** Object:  Trigger [dbo].[LXI_LOJA_SAIDAS_PRODUTO]    Script Date: 19/02/2026 14:02:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  trigger [dbo].[LXI_LOJA_SAIDAS_PRODUTO] 
on [dbo].[LOJA_SAIDAS_PRODUTO]    
  for INSERT NOT FOR REPLICATION    
  as    
/* INSERT trigger on LOJA_SAIDAS_PRODUTO */    
/* default body for LXI_LOJA_SAIDAS_PRODUTO */

-- 05/02/2016 - Szalontai		- #1# - Demanda 1658   - Tratamento de custo por matriz contabil
-- 12/03/2019 - Gilvano Santos/Carlos Alberto  - #2# - Demanda 112679 - Correção para atualizar coluna ultima_saida da tabela estoque_produto 
-- 20/01/2025 - Marcelo Faria				   - #3# - ENTERMODA-14817- Controle de historico/saldo de crédito de transferência.
  
begin    
  declare  @numrows int,    
           @nullcnt int,    
           @validcnt int,    
           @insPRODUTO char(12),     
           @insCOR_PRODUTO char(10),     
           @insROMANEIO_PRODUTO char(15),     
           @insFILIAL varchar(25),    
           @errno   int,    
           @errmsg  varchar(255),
		   @Emissao datetime  
    
  select @numrows = @@rowcount    
    
/*-- Verifica Movimentacao Estoque PA ---------------------------------------------------------------------------------*/    
	/*
	DECLARE @xDataSaldo DateTime    
    
	SELECT @xDataSaldo='18000101'    
	SELECT @xDataSaldo=ISNULL(CONVERT(DATETIME,VALOR_ATUAL,103),'18000101') FROM PARAMETROS WHERE PARAMETRO='DATA_BLOQUEIO_MOV_PA'    
    
	IF ( SELECT  COUNT(*)    
		FROM Inserted, LOJA_SAIDAS    
		WHERE Inserted.ROMANEIO_PRODUTO = LOJA_SAIDAS.ROMANEIO_PRODUTO AND     
                        Inserted.FILIAL = LOJA_SAIDAS.FILIAL AND    
		LOJA_SAIDAS.EMISSAO <= @xDataSaldo    
       
		) > 0    
	BEGIN    
		SELECT  @errno=30002,    
			@errmsg='Não é possível Incluir Movimentacao de Estoque anterior a #'+CONVERT(Char(10),@xDataSaldo,103)+' !'    
		GOTO error    
	 END    
	 */

	/*
	#1#
	-------------------------------------------------------------------------------------------------------------------------
	INICIO
	-------------------------------------------------------------------------------------------------------------------------
	*/
	--/*
	DECLARE @xDataSaldoI DateTime,@xfilial char(25)
	SELECT @xDataSaldoI='18000101'

	SELECT @xDataSaldoI=C.DATA_SALDO_PA,@xfilial = B.FILIAL	
   	FROM Inserted A	 
	INNER JOIN LOJA_SAIDAS B ON			A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND 
										A.FILIAL = B.FILIAL
	INNER JOIN CM_DATA_FECHAMENTO C	ON	B.FILIAL = C.FILIAL AND B.EMISSAO<=C.DATA_SALDO_PA

	
	IF	(
			SELECT COUNT(*)    
   			FROM Inserted A	 
			INNER JOIN LOJA_SAIDAS B ON			A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND 
												A.FILIAL = B.FILIAL
			INNER JOIN CM_DATA_FECHAMENTO C	ON	B.FILIAL = C.FILIAL AND B.EMISSAO<=@xDataSaldoI 
		)> 0	

	BEGIN
		SELECT 	@errno=30002,
			@errmsg='Não é possível Incluir Movimentacao de Estoque anterior a #'+CONVERT(Char(10),@xDataSaldoI,103)+' para a filial '+rtrim(ltrim(@xfilial))+' !'
		GOTO error
	END

	--*/
	/*
	-------------------------------------------------------------------------------------------------------------------------
	FIM
	-------------------------------------------------------------------------------------------------------------------------
	*/
    
     
     
    
 /*--- BLOQUEIO POR AJUSTE ---*/    
 IF EXISTS(SELECT *    
  FROM Inserted, LOJA_SAIDAS, ESTOQUE_PRODUTOS     
  WHERE INSERTED.ROMANEIO_PRODUTO = LOJA_SAIDAS.ROMANEIO_PRODUTO AND     
                        INSERTED.FILIAL = LOJA_SAIDAS.FILIAL AND    
   ESTOQUE_PRODUTOS.FILIAL=INSERTED.FILIAL AND    
   ESTOQUE_PRODUTOS.PRODUTO=INSERTED.PRODUTO AND    
   ESTOQUE_PRODUTOS.COR_PRODUTO=INSERTED.COR_PRODUTO AND    
   LOJA_SAIDAS.EMISSAO < ESTOQUE_PRODUTOS.DATA_AJUSTE )     
 BEGIN    
  SELECT  @errno=30002,    
   @errmsg='Não é possível Incluir Movimentacao de Estoque anterior ao Ajuste !'    
  GOTO error    
 END    
    
     
     
/*---------------------------------------------------------------------------------------------------------------------*/    
    
/* LOJA_SAIDAS R/947 LOJA_SAIDAS_PRODUTO ON CHILD INSERT RESTRICT */    
  if     
     update(ROMANEIO_PRODUTO) or     
     update(FILIAL)    
  begin    
    select	@nullcnt = 0    
    
	select	@validcnt = count(*) 
	from	inserted,LOJA_SAIDAS    
     where     
           inserted.ROMANEIO_PRODUTO = LOJA_SAIDAS.ROMANEIO_PRODUTO and    
           inserted.FILIAL = LOJA_SAIDAS.FILIAL    
        
    if @validcnt + @nullcnt != @numrows    
    begin    
      select @errno  = 30002,    
             @errmsg = 'Impossível Incluir #LOJA_SAIDAS_PRODUTO #porque #LOJA_SAIDAS #não existe.'    
      goto error    
    end    
  end    
    
/* PRODUTO_CORES R/946 LOJA_SAIDAS_PRODUTO ON CHILD INSERT RESTRICT */    
  if     
     update(PRODUTO) or     
     update(COR_PRODUTO)    
  begin    
    select @nullcnt = 0    
    select @validcnt = count(*)    
      from inserted,PRODUTO_CORES    
     where     
           inserted.PRODUTO = PRODUTO_CORES.PRODUTO and    
           inserted.COR_PRODUTO = PRODUTO_CORES.COR_PRODUTO    
        
    if @validcnt + @nullcnt != @numrows    
    begin    
      select @errno  = 30002,    
             @errmsg = 'Impossível Incluir #LOJA_SAIDAS_PRODUTO #porque #PRODUTO_CORES #não existe.'    
      goto error    
    end    
  end    
    
    
    
/*--- GERA ENTRADA AUTOMATICA --------------------------------------------------------------------------*/    
  
INSERT INTO LX_PROCESSO_LOG (PROCESSO,COMANDO,ORIGEM)    
SELECT 'LX_GERA_TRANSFERENCIA_AUTOMATICA', 'LX_GERA_TRANSFERENCIA_AUTOMATICA @FILIAL='''+RTRIM(A.FILIAL)+''', @ROMANEIO_PRODUTO='''+RTRIM(A.ROMANEIO_PRODUTO)+''',@FILIAL_DESTINO='''+RTRIM(B.FILIAL_DESTINO)+''',@SERIE_NF='''', @ORIGEM=''S'', @EXCLUSAO=''N''','LXI_LOJA_SAIDAS_PRODUTO'    
FROM INSERTED A    
 JOIN LOJA_SAIDAS B ON B.FILIAL=A.FILIAL AND B.ROMANEIO_PRODUTO=A.ROMANEIO_PRODUTO    
 LEFT JOIN LX_PROCESSO_LOG L ON L.COMANDO='LX_GERA_TRANSFERENCIA_AUTOMATICA @FILIAL='''+RTRIM(A.FILIAL)+''', @ROMANEIO_PRODUTO='''+RTRIM(A.ROMANEIO_PRODUTO)+''',@FILIAL_DESTINO='''+RTRIM(B.FILIAL_DESTINO)+''',@SERIE_NF='''', @ORIGEM=''S'', @EXCLUSAO=''N''
'    
     AND L.STATUS=0    
WHERE L.COMANDO IS NULL    
AND B.SAIDA_ENCERRADA = 1  
/*-----------------------------------------------------------------------------------------------------*/    
    
/*-- Atualiza Estoque PA ----------------------------------------------------------------------------------------------*/    
/* Atualizacao de Estoque */    
    
IF UPDATE(PRODUTO) OR UPDATE(COR_PRODUTO) OR UPDATE(FILIAL) OR    
     UPDATE(EN1) OR UPDATE(EN2) OR UPDATE(EN3) OR     
     UPDATE(EN4) OR UPDATE(EN5) OR UPDATE(EN6) OR     
     UPDATE(EN7) OR UPDATE(EN8) OR UPDATE(EN9) OR     
     UPDATE(EN10) OR UPDATE(EN11) OR UPDATE(EN12) OR     
     UPDATE(EN13) OR UPDATE(EN14) OR UPDATE(EN15) OR     
     UPDATE(EN16) OR UPDATE(EN17) OR UPDATE(EN18) OR     
     UPDATE(EN19) OR UPDATE(EN20) OR UPDATE(EN21) OR     
     UPDATE(EN22) OR UPDATE(EN23) OR UPDATE(EN24) OR     
     UPDATE(EN25) OR UPDATE(EN26) OR UPDATE(EN27) OR     
     UPDATE(EN28) OR UPDATE(EN29) OR UPDATE(EN30) OR     
     UPDATE(EN31) OR UPDATE(EN32) OR UPDATE(EN33) OR     
     UPDATE(EN34) OR UPDATE(EN35) OR UPDATE(EN36) OR     
     UPDATE(EN37) OR UPDATE(EN38) OR UPDATE(EN39) OR     
     UPDATE(EN40) OR UPDATE(EN41) OR UPDATE(EN42) OR     
     UPDATE(EN43) OR UPDATE(EN44) OR UPDATE(EN45) OR     
     UPDATE(EN46) OR UPDATE(EN47) OR UPDATE(EN48)     
  BEGIN    
       
    DECLARE cur_LOJA_SAIDAS_PRODUTO CURSOR    
    FOR    
      SELECT Produto, Cor_Produto, Inserted.Filial, LOJA_SAIDAS.EMISSAO,  /*#02#*/    
            SUM(EN1), SUM(EN2), SUM(EN3), SUM(EN4),    
            SUM(EN5), SUM(EN6), SUM(EN7), SUM(EN8),    
            SUM(EN9), SUM(EN10),SUM(EN11),SUM(EN12),    
            SUM(EN13),SUM(EN14),SUM(EN15),SUM(EN16),    
            SUM(EN17),SUM(EN18),SUM(EN19),SUM(EN20),    
            SUM(EN21),SUM(EN22),SUM(EN23),SUM(EN24),    
            SUM(EN25),SUM(EN26),SUM(EN27),SUM(EN28),    
            SUM(EN29),SUM(EN30),SUM(EN31),SUM(EN32),    
            SUM(EN33),SUM(EN34),SUM(EN35),SUM(EN36),    
            SUM(EN37),SUM(EN38),SUM(EN39),SUM(EN40),    
            SUM(EN41),SUM(EN42),SUM(EN43),SUM(EN44),    
            SUM(EN45),SUM(EN46),SUM(EN47),SUM(EN48)    
     FROM Inserted     
	--- VERIFICA SAIDA ENCERRADA
	INNER JOIN LOJA_SAIDAS ON Inserted.FILIAL = LOJA_SAIDAS.FILIAL AND Inserted.ROMANEIO_PRODUTO = LOJA_SAIDAS.ROMANEIO_PRODUTO 
	WHERE
		LOJA_SAIDAS.SAIDA_ENCERRADA = 1		
	--- VERIFICA SAIDA ENCERRADA
     GROUP BY Produto, Cor_Produto, Inserted.Filial, LOJA_SAIDAS.EMISSAO /*#02#*/
    
    
    OPEN cur_LOJA_SAIDAS_PRODUTO    
    
    DECLARE @cProduto Char(12), @cCor_Produto Char(10), @cFilial VarChar(25), @nEstoque Int,    
       @nEs1  Int, @nEs2  Int, @nEs3  Int, @nEs4  Int, @nEs5  Int, @nEs6  Int, @nEs7  Int, @nEs8  Int,    
            @nEs9  Int, @nEs10 Int, @nEs11 Int, @nEs12 Int, @nEs13 Int, @nEs14 Int, @nEs15 Int, @nEs16 Int,    
            @nEs17 Int, @nEs18 Int, @nEs19 Int, @nEs20 Int, @nEs21 Int, @nEs22 Int, @nEs23 Int, @nEs24 Int,     
            @nEs25 Int, @nEs26 Int, @nEs27 Int, @nEs28 Int, @nEs29 Int, @nEs30 Int, @nEs31 Int, @nEs32 Int,     
            @nEs33 Int, @nEs34 Int, @nEs35 Int, @nEs36 Int, @nEs37 Int, @nEs38 Int, @nEs39 Int, @nEs40 Int,     
            @nEs41 Int, @nEs42 Int, @nEs43 Int, @nEs44 Int, @nEs45 Int, @nEs46 Int, @nEs47 Int, @nEs48 Int    
    
    FETCH NEXT FROM cur_LOJA_SAIDAS_PRODUTO INTO @cProduto,@cCor_Produto,@cFilial, @EMISSAO, /*#02#*/
                            @nEs1,  @nEs2,  @nEs3,  @nEs4,  @nEs5,  @nEs6,  @nEs7,  @nEs8,  @nEs9,  @nEs10, @nEs11, @nEs12,     
                            @nEs13, @nEs14, @nEs15, @nEs16, @nEs17, @nEs18, @nEs19, @nEs20, @nEs21, @nEs22, @nEs23, @nEs24,     
                            @nEs25, @nEs26, @nEs27, @nEs28, @nEs29, @nEs30, @nEs31, @nEs32, @nEs33, @nEs34, @nEs35, @nEs36,     
                            @nEs37, @nEs38, @nEs39, @nEs40, @nEs41, @nEs42, @nEs43, @nEs44, @nEs45, @nEs46, @nEs47, @nEs48    
    
    WHILE (@@Fetch_Status = 0)    
      BEGIN    
            
        SELECT @nEstoque = @nEs1 + @nEs2 + @nEs3 + @nEs4 + @nEs5 + @nEs6 + @nEs7 + @nEs8 + @nEs9 + @nEs10 + @nEs11 + @nEs12 +     
                  @nEs13 + @nEs14 + @nEs15 + @nEs16 + @nEs17 + @nEs18 + @nEs19 + @nEs20 + @nEs21 + @nEs22 + @nEs23 + @nEs24 +     
                  @nEs25 + @nEs26 + @nEs27 + @nEs28 + @nEs29 + @nEs30 + @nEs31 + @nEs32 + @nEs33 + @nEs34 + @nEs35 + @nEs36 +     
                  @nEs37 + @nEs38 + @nEs39 + @nEs40 + @nEs41 + @nEs42 + @nEs43 + @nEs44 + @nEs45 + @nEs46 + @nEs47 + @nEs48    
    
 IF (SELECT COUNT(*) FROM estoque_produtos WHERE PRODUTO=@cProduto AND COR_PRODUTO=@cCor_Produto AND FILIAL=@cFilial) > 0    
  UPDATE ESTOQUE_PRODUTOS    
  SET ESTOQUE = ESTOQUE - @nEstoque,     
             ULTIMA_SAIDA = @Emissao,    
             ES1 =ES1  - @nES1,  ES2 =ES2  - @nES2,  ES3 =ES3  - @nES3,    
             ES4 =ES4  - @nES4,  ES5 =ES5  - @nES5,  ES6 =ES6  - @nES6,    
             ES7 =ES7  - @nES7,  ES8 =ES8  - @nES8,  ES9 =ES9  - @nES9,    
             ES10=ES10 - @nES10, ES11=ES11 - @nES11, ES12=ES12 - @nES12,     
             ES13=ES13 - @nES13, ES14=ES14 - @nES14, ES15=ES15 - @nES15,    
             ES16=ES16 - @nES16, ES17=ES17 - @nES17, ES18=ES18 - @nES18,    
             ES19=ES19 - @nES19, ES20=ES20 - @nES20, ES21=ES21 - @nES21,    
             ES22=ES22 - @nES22, ES23=ES23 - @nES23, ES24=ES24 - @nES24,    
             ES25=ES25 - @nES25, ES26=ES26 - @nES26, ES27=ES27 - @nES27,    
             ES28=ES28 - @nES28, ES29=ES29 - @nES29, ES30=ES30 - @nES30,    
             ES31=ES31 - @nES31, ES32=ES32 - @nES32, ES33=ES33 - @nES33,    
             ES34=ES34 - @nES34, ES35=ES35 - @nES35, ES36=ES36 - @nES36,    
             ES37=ES37 - @nES37, ES38=ES38 - @nES38, ES39=ES39 - @nES39,    
             ES40=ES40 - @nES40, ES41=ES41 - @nES41, ES42=ES42 - @nES42,    
             ES43=ES43 - @nES43, ES44=ES44 - @nES44, ES45=ES45 - @nES45,    
             ES46=ES46 - @nES46, ES47=ES47 - @nES47, ES48=ES48 - @nES48    
  FROM estoque_produtos    
  WHERE PRODUTO=@cProduto AND COR_PRODUTO=@cCor_Produto AND FILIAL=@cFilial    
  ELSE    
          INSERT INTO Estoque_Produtos (Produto,Cor_Produto,Filial,Estoque, ULTIMA_SAIDA,    
                    Es1,  Es2,  Es3,  Es4,  Es5,  Es6,  Es7,  Es8,  Es9,  Es10, Es11, Es12, Es13, Es14, Es15, Es16,      
                    Es17, Es18, Es19, Es20, Es21, Es22, Es23, Es24, Es25, Es26, Es27, Es28, Es29, Es30, Es31, Es32,    
                    Es33, Es34, Es35, Es36, Es37, Es38, Es39, Es40, Es41, Es42, Es43, Es44, Es45, Es46, Es47, Es48)    
             VALUES(@cProduto, @cCor_Produto, @cFilial, @nEstoque*-1, @Emissao,    
                    @nEs1*-1,  @nEs2*-1,@nEs3*-1,  @nEs4*-1,@nEs5*-1,  @nEs6*-1,@nEs7*-1,  @nEs8*-1,    
                    @nEs9*-1,  @nEs10*-1,@nEs11*-1, @nEs12*-1,@nEs13*-1, @nEs14*-1,@nEs15*-1, @nEs16*-1,    
                    @nEs17*-1, @nEs18*-1,@nEs19*-1, @nEs20*-1,@nEs21*-1, @nEs22*-1,@nEs23*-1, @nEs24*-1,    
                    @nEs25*-1, @nEs26*-1,@nEs27*-1, @nEs28*-1,@nEs29*-1, @nEs30*-1,@nEs31*-1, @nEs32*-1,    
                    @nEs33*-1, @nEs34*-1,@nEs35*-1, @nEs36*-1,@nEs37*-1, @nEs38*-1,@nEs39*-1, @nEs40*-1,    
                    @nEs41*-1, @nEs42*-1,@nEs43*-1, @nEs44*-1,@nEs45*-1, @nEs46*-1,@nEs47*-1, @nEs48*-1)    
    
          IF @@ROWCOUNT = 0    
   BEGIN    
            select @errno  = 30002,    
                   @errmsg = 'Operação Cancelada, Não foi Possível Atualizar #ESTOQUE_PRODUTOS#.'    
            goto error    
          END    
    
    
        FETCH NEXT FROM cur_LOJA_SAIDAS_PRODUTO INTO @cProduto, @cCor_Produto, @cFilial, @EMISSAO, /*#02#*/   
                            @nEs1,  @nEs2,  @nEs3,  @nEs4,  @nEs5,  @nEs6,  @nEs7,  @nEs8,  @nEs9,  @nEs10, @nEs11, @nEs12,     
                            @nEs13, @nEs14, @nEs15, @nEs16, @nEs17, @nEs18, @nEs19, @nEs20, @nEs21, @nEs22, @nEs23, @nEs24,     
                            @nEs25, @nEs26, @nEs27, @nEs28, @nEs29, @nEs30, @nEs31, @nEs32, @nEs33, @nEs34, @nEs35, @nEs36,     
                            @nEs37, @nEs38, @nEs39, @nEs40, @nEs41, @nEs42, @nEs43, @nEs44, @nEs45, @nEs46, @nEs47, @nEs48    
      END    
    
    
    CLOSE cur_LOJA_SAIDAS_PRODUTO    
    DEALLOCATE cur_LOJA_SAIDAS_PRODUTO    
    
END    
       
    
/*---------------------------------------------------------------------------------------------------------------------*/    
    
/*---LINX-INSERT---------------------------------------------------------------------------------------*/    
 UPDATE  LOJA_SAIDAS_PRODUTO     
 SET  DATA_PARA_TRANSFERENCIA = GETDATE()
 FROM  LOJA_SAIDAS_PRODUTO, INSERTED    
 WHERE  LOJA_SAIDAS_PRODUTO.PRODUTO = INSERTED.PRODUTO and    
        LOJA_SAIDAS_PRODUTO.COR_PRODUTO = INSERTED.COR_PRODUTO and    
        LOJA_SAIDAS_PRODUTO.ROMANEIO_PRODUTO = INSERTED.ROMANEIO_PRODUTO and    
        LOJA_SAIDAS_PRODUTO.FILIAL = INSERTED.FILIAL     
  AND INSERTED.DATA_PARA_TRANSFERENCIA IS NULL    
/*-----------------------------------------------------------------------------------------------------*/   

	--#3# Inicio
	IF EXISTS(SELECT VALOR_ATUAL FROM PARAMETROS WHERE PARAMETRO='CTRL_CUSTO_PARA_TRANSF' AND RTRIM(LTRIM(VALOR_ATUAL)) = '.T.')
	BEGIN    
		WITH CTE_COMPRAS_HISTORICO AS
		(
			SELECT 
				'1' AS TIPO_MOVIMENTO,
				b.NUMERO_NF_TRANSFERENCIA AS DOC,
				A.ROMANEIO_PRODUTO AS OP_PED_ROMAN,
				B.NUMERO_NF_TRANSFERENCIA AS NOTA_FISCAL,
				B.SERIE_NF AS SERIE_NF, 
				NULL ESPECIE_SERIE,
				A.PRODUTO,
				A.COR_PRODUTO, 
				A.FILIAL, 
				b.EMISSAO, 
				null NATUREZA,
				A.QTDE_SAIDA QTDE,
				A.VALOR,
				'LOJA SAÍDAS' AS DESC_TIPO_MOVIMENTO,
				GETDATE() AS DATA_HISTORICO,
				A.ROMANEIO_PRODUTO
			FROM INSERTED A
			INNER JOIN PRODUTOS WITH (NOLOCK) ON PRODUTOS.PRODUTO = A.PRODUTO 
			 INNER JOIN LOJA_SAIDAS B WITH (NOLOCK) ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND
										 A.FILIAL = B.FILIAL
		)

		INSERT INTO CUSTO_COMPRAS_HISTORICO 
			(TIPO_MOVIMENTO, DOC, OP_PED_ROMAN, NOTA_FISCAL, SERIE_NF, ESPECIE_SERIE, PRODUTO, COR_PRODUTO, FILIAL, EMISSAO, NATUREZA, QTDE, VALOR, DESC_TIPO_MOVIMENTO, DATA_HISTORICO, ROMANEIO_PRODUTO)
		SELECT 
			TIPO_MOVIMENTO, DOC, OP_PED_ROMAN, NOTA_FISCAL, SERIE_NF, ESPECIE_SERIE, 
			PRODUTO, COR_PRODUTO, FILIAL, EMISSAO, NATUREZA, QTDE, VALOR, 
			DESC_TIPO_MOVIMENTO, DATA_HISTORICO, ROMANEIO_PRODUTO
		FROM CTE_COMPRAS_HISTORICO;
	END
	--#3# Fim


  return    
error:    
    raiserror (@errmsg, 16, 1)    
    rollback transaction    
end

