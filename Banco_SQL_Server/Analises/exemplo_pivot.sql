/*
1️ - Relatório de Vendas Mensais por Vendedor (PIVOT)
Pergunta:
Crie um relatório que mostre o total vendido por cada vendedor, distribuído por mês.

Colunas esperadas: Vendedor, Jan, Fev, Mar, ..., Dez (com os valores das vendas de cada mês).

Dica:

Use a função FORMAT(DataVenda, 'MMM') para agrupar por mês.
Utilize SUM(Total) para consolidar os valores.
Aplique PIVOT para transformar os meses em colunas.
*/

SELECT
	Vendedor, 
	ISNULL([1], 0) AS Jan, ISNULL([2], 0) AS Fev, ISNULL([3], 0) AS Mar, 
	ISNULL([4], 0) AS Abr, ISNULL([5], 0) AS Mai, ISNULL([6], 0) AS Jun,
	ISNULL([7], 0) AS Jul, ISNULL([8], 0) AS Ago, ISNULL([9], 0) AS [Set], 
	ISNULL([10], 0) AS Out, ISNULL([11], 0) AS Nov, ISNULL([12], 0) AS Dez
FROM(
	SELECT
		B.NOME AS VENDEDOR,
		MONTH(A.DataVenda) AS MES_VENDA,
		A.TOTAL AS TOTAL_DE_VENDAS
	FROM
		VENDAS AS A
		JOIN VENDEDORES AS B ON A.VendedorID = B.VendedorID
	) AS C
	PIVOT(
		SUM(TOTAL_DE_VENDAS)
		FOR MES_VENDA IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS TABELA_PIVOT
