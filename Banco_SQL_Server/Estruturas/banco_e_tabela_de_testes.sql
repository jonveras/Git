-- Criando o banco de dados
CREATE DATABASE DB_Vendas;
GO

-- Usando o banco de dados
USE DB_Vendas;
GO

-- Criando a tabela de Clientes
CREATE TABLE Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE,
    Telefone VARCHAR(20),
    DataCadastro DATETIME DEFAULT GETDATE()
);
GO

-- Criando a tabela de Produtos
CREATE TABLE Produtos (
    ProdutoID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Categoria VARCHAR(50),
    Preco DECIMAL(10,2) NOT NULL,
    Estoque INT NOT NULL DEFAULT 0,
    DataCadastro DATETIME DEFAULT GETDATE()
);
GO

-- Criando a tabela de Vendedores
CREATE TABLE Vendedores (
    VendedorID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE,
    DataContratacao DATE NOT NULL
);
GO

-- Criando a tabela de Vendas
CREATE TABLE Vendas (
    VendaID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT NOT NULL,
    VendedorID INT NOT NULL,
    DataVenda DATETIME DEFAULT GETDATE(),
    Total DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    FOREIGN KEY (VendedorID) REFERENCES Vendedores(VendedorID)
);
GO

-- Criando a tabela de ItensVendidos
CREATE TABLE ItensVendidos (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    VendaID INT NOT NULL,
    ProdutoID INT NOT NULL,
    Quantidade INT NOT NULL DEFAULT 0,
    PrecoUnitario DECIMAL(10,2) NOT NULL,
    SubTotal AS (Quantidade * PrecoUnitario) PERSISTED,
    FOREIGN KEY (VendaID) REFERENCES Vendas(VendaID),
    FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID)
);
GO
