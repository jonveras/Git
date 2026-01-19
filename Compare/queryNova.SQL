IF NOT EXISTS (SELECT * FROM sys.objects WHERE NAME ='FUNC_SS_ROMANEIO_SAIDA')
BEGIN
	EXECUTE ('CREATE FUNCTION [dbo].[FUNC_SS_ROMANEIO_SAIDA] () RETURNS VARCHAR(8) AS BEGIN DECLARE @RETORNO VARCHAR(1) return @RETORNO END')
END
GO
ALTER FUNCTION [dbo].[FUNC_SS_ROMANEIO_SAIDA]
	(
	 
	)
	RETURNS VARCHAR(9)
AS
BEGIN
	/* Tiago Carvalho	- 13/01/2026 - Alterado para não gerar caracter especial no ano*/
	/* Danilo Aires		- Sintese Soluções - Alterada função para gerar o Romaneio_produto com 8 dígitos, com 9 dígitos esta ocorrendo erro ao pesquisar no Linx POS.*/
	/* Tiago Carvalho	- Sintese Soluções - Função para gerar o numero de romaneio para a tabela LOJA_SAIDAS*/
     declare @intDay char(2),
                  @strRomaneio char(9),
                  @intCount inT,
				  @bUtilizaMileSegundos bit = 0 

	if exists (select * from ss_wms_parametros (nolock) where parametro ='UTILIZA_MILESEGUNDO_ROMANEIO_SAIDA' and valor_atual ='.T.')
	BEGIN
		SELECT @bUtilizaMileSegundos = 1 
	END        
		
    select @intDay = substring(convert(varchar(12), getdate(), 103), 1, 2)

    select @strRomaneio = char(39 + cast(substring(convert(varchar(12), getdate(), 103), 9, 2) as int))
							+ char(64 + cast(substring(convert(varchar(12), getdate(), 103), 4, 2) as int)) 
							+ case when cast('11' as int) < 10 then substring('11', 2, 1) else char(55 + cast('11' as int)) end
							+ char(65 + convert(char(2), datepart(hh, getdate())))
							+ right('00' + ltrim(convert(varchar(2), datepart(mi, getdate()))), 2)
							+ right('00' + ltrim(convert(varchar(2), datepart(ss, getdate()))), 1)
							+ CASE WHEN @bUtilizaMileSegundos = 0 THEN '' ELSE right('00' + ltrim(convert(varchar(3), datepart(ss, getdate()))), 1) END
    select @intCount = @intCount + 1
   
	return LTRIM(RTRIm(@strRomaneio))
end
