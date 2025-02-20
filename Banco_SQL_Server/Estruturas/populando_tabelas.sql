USE DB_Vendas;
GO

-- Inserindo Clientes
INSERT INTO Clientes (Nome, Email, Telefone, DataCadastro) VALUES
('Carlos Silva', 'carlos.silva@email.com', '(11) 99999-1111', '20240110'),
('Ana Souza', 'ana.souza@email.com', '(21) 98888-2222', '20240215'),
('Marcos Oliveira', 'marcos.oliveira@email.com', '(31) 97777-3333', '20240320'),
('Fernanda Lima', 'fernanda.lima@email.com', '(41) 96666-4444', '20240405'),
('Roberto Mendes', 'roberto.mendes@email.com', '(51) 95555-5555', '20240512');
GO

-- Inserindo Produtos
INSERT INTO Produtos (Nome, Categoria, Preco, Estoque, DataCadastro) VALUES
('Notebook Dell Inspiron', 'Eletrônicos', 4500.00, 10, '20240101'),
('Mouse Logitech MX', 'Periféricos', 350.00, 25, '20240105'),
('Teclado Mecânico RGB', 'Periféricos', 700.00, 20, '20240110'),
('Monitor 27" 144Hz', 'Monitores', 1800.00, 15, '20240201'),
('Cadeira Gamer', 'Móveis', 1200.00, 5, '20240301'),
('Smartphone Samsung S23', 'Eletrônicos', 5200.00, 8, '20240210'),
('Fone Bluetooth JBL', 'Áudio', 350.00, 30, '20240215'),
('Impressora HP LaserJet', 'Periféricos', 1250.00, 12, '20240305'),
('HD Externo 2TB', 'Armazenamento', 600.00, 18, '20240310'),
('Placa de Vídeo RTX 4070', 'Hardware', 3700.00, 6, '20240401'),
('Processador Intel i9', 'Hardware', 2900.00, 10, '20240415'),
('Tablet iPad Air', 'Eletrônicos', 4200.00, 7, '20240501'),
('Mousepad Gamer XXL', 'Periféricos', 120.00, 50, '20240510');
GO

-- Inserindo Vendedores
INSERT INTO Vendedores (Nome, Email, DataContratacao) VALUES
('Julia Ramos', 'julia.ramos@email.com', '20230510'),
('Fernando Alves', 'fernando.alves@email.com', '20230620'),
('Bruna Martins', 'bruna.martins@email.com', '20230715');
GO

-- Inserindo Vendas
INSERT INTO Vendas (ClienteID, VendedorID, DataVenda, Total) VALUES
(1, 1, '20240601', 5500.00),
(2, 2, '20240605', 2150.00),
(3, 1, '20240610', 3500.00),
(4, 3, '20240615', 4700.00),
(5, 2, '20240620', 1800.00),
(1, 2, '20240625', 7400.00),
(2, 3, '20240701', 1650.00),
(3, 1, '20240705', 9200.00),
(4, 2, '20240710', 3150.00),
(5, 3, '20240715', 5100.00),
(1, 1, '20240720', 3200.00),
(2, 2, '20240725', 8900.00),
(3, 3, '20240730', 4500.00);
GO

-- Inserindo Itens Vendidos
INSERT INTO ItensVendidos (VendaID, ProdutoID, Quantidade, PrecoUnitario) VALUES
(1, 1, 1, 4500.00), -- Notebook
(1, 2, 2, 350.00), -- Mouse x2
(2, 3, 3, 700.00), -- Teclado x3
(3, 1, 1, 4500.00), -- Notebook
(4, 4, 2, 1800.00), -- Monitor x2
(5, 5, 1, 1800.00), -- Cadeira Gamer
(6, 1, 1, 4500.00),  -- Notebook
(6, 6, 1, 2900.00),  -- Processador Intel i9
(7, 2, 2, 350.00),   -- Mouse x2
(7, 8, 3, 120.00),   -- Mousepad Gamer x3
(8, 5, 1, 3700.00),  -- Placa de Vídeo RTX 4070
(8, 7, 1, 4200.00),  -- iPad Air
(9, 4, 2, 600.00),   -- HD Externo 2TB x2
(9, 3, 1, 1250.00),  -- Impressora HP
(10, 5, 2, 3700.00), -- Placa de Vídeo RTX 4070 x2
(10, 6, 1, 2900.00), -- Processador Intel i9
(11, 1, 1, 4500.00), -- Notebook
(11, 2, 1, 350.00),  -- Mouse
(11, 3, 1, 1250.00), -- Impressora HP
(12, 4, 1, 600.00),  -- HD Externo 2TB
(12, 7, 1, 4200.00), -- iPad Air
(13, 8, 5, 120.00);  -- Mousepad Gamer x5
GO
