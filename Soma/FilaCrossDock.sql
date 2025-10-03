SELECT	b.rede_lojas, sum(qtde_estoque) qtde_estoque, sum(qtde_embalada) qtde_embalada, sum(qtde_transito) qtde_transito,
		sum(qtde_disponivel) qtde_disponivel
FROM W_SS_ESTOQUE_DISPONIVEL a
JOIN produtos b on a.produto=b.produto
WHERE	filial = 'ESTOQUE ATACADO'
		AND QTDE_ESTOQUE > 0
GROUP BY b.rede_lojas
OPTION (RECOMPILE)
 