USE [SOMA]
GO

/****** Object:  UserDefinedFunction [dbo].[FUNC_SS_ROMANEIO_SAIDA_BKP_20260113]    Script Date: 19/01/2026 16:48:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FUNC_SS_ROMANEIO_SAIDA_BKP_20260113]
	(
	 
	)
	RETURNS VARCHAR(8)
AS
BEGIN
	/* Tiago Carvalho - Sintese Soluções - Função para gerar o numero de romaneio para a tabela LOJA_SAIDAS*/
     declare @intDay char(2),
                  @strRomaneio char(8),
                  @intCount inT,
                  @prCodigoFilial CHAR(6)
                  
      select @intDay = substring(convert(varchar(12), getdate(), 103), 1, 2)

      select @strRomaneio =  char(65 + cast(substring(convert(varchar(12), getdate(), 103), 9, 2) as int))
							+ char(64 + cast(substring(convert(varchar(12), getdate(), 103), 4, 2) as int)) 
							+ case when cast('11' as int) < 10 then substring('11', 2, 1) else char(55 + cast('11' as int)) end
							+ char(65 + convert(char(2), datepart(hh, getdate())))
							+ right('00' + ltrim(convert(varchar(2), datepart(mi, getdate()))), 2)
							+ right('00' + ltrim(convert(varchar(2), datepart(ss, getdate()))), 2)
                                   
      WHILE (SELECT COUNT(*)
                             FROM LOJA_SAIDAS A 
                             INNER JOIN FILIAIS B 
                                   ON B.FILIAL=A.FILIAL
                             WHERE A.ROMANEIO_PRODUTO = @strRomaneio 
                                   AND B.COD_FILIAL = @prCodigoFilial) > 0
      begin 
            select @intDay = substring(convert(varchar(12), getdate(), 103), 1, 2)

            select @strRomaneio = char(65 + cast(substring(convert(varchar(12), getdate(), 103), 9, 2) as int))
									+ char(64 + cast(substring(convert(varchar(12), getdate(), 103), 4, 2) as int)) 
									+ case when cast('11' as int) < 10 then substring('11', 2, 1) else char(55 + cast('11' as int)) end
									+ char(65 + convert(char(2), datepart(hh, getdate())))
									+ right('00' + ltrim(convert(varchar(2), datepart(mi, getdate()))), 2)
									+ right('00' + ltrim(convert(varchar(2), datepart(ss, getdate()))), 2)
            
            select @intCount = @intCount + 1
      end
	return @strRomaneio	
end



GO


