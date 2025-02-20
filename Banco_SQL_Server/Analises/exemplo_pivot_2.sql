/*
Relat�rio de Quantidade Vendida por Categoria de Produto (PIVOT)
Pergunta:
Crie um relat�rio mostrando a quantidade total de produtos vendidos, agrupado por categoria e distribu�do por m�s.

Colunas esperadas: Categoria, Jan, Fev, ..., Dez.

Dica:

Fa�a um JOIN entre ItensVendidos e Produtos para obter a categoria.
Agrupe por categoria e m�s (FORMAT(DataVenda, 'MMM')).
Use PIVOT para organizar os meses em colunas.
*/

--DESCOBRIR AS TABELAS
SELECT
	*
FROM
	SYS.TABLES

--SAMPLE DE DADOS
SELECT
	*
FROM
	Produtos

SELECT
	*
FROM
	ItensVendidos

SELECT
	*
FROM
	Vendas
		
--QUERY SEM PIVOT
SELECT
	A.Categoria,
	MONTH(C.DataVenda) AS MES_VENDA,
	SUM(B.Quantidade) AS QTD_PRODUTOS
FROM
	PRODUTOS AS A
	JOIN ItensVendidos AS B ON A.ProdutoID = B.ProdutoID
	JOIN Vendas AS C ON B.VendaID = C.VendaID
GROUP BY
	A.Categoria, MONTH(C.DataVenda)

--QUERY COM PIVOT
SELECT
	*
FROM (
	SELECT
		A.Categoria,
		B.QUANTIDADE,
		MONTH(C.DataVenda) AS MES_VENDA		
	FROM
		PRODUTOS AS A
		JOIN ItensVendidos AS B ON A.ProdutoID = B.ProdutoID
		JOIN Vendas AS C ON B.VendaID = C.VendaID
) AS D
PIVOT(
	SUM(QUANTIDADE)
	FOR MES_VENDA IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PIVOT_TABLE