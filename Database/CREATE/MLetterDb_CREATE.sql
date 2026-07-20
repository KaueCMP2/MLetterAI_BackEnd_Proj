CREATE DATABASE MLetterDb
GO

USE MLetterDb
GO

CREATE TABLE MotivoExclusao
(
	motivoExclusaoID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	nomeMotivo VARCHAR(30),
	descricaoMotivo NVARCHAR(100)
)
GO

CREATE TABLE Plano
(
	planoID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	nomePlano VARCHAR(30) UNIQUE NOT NULL,
	valorAquisicao DECIMAL(18, 6) NOT NULL,
	descricao VARCHAR(max) NOT NULL,
)
GO

CREATE TABLE TipoArquivo
(
	tipoArquivoID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	nomeTipo VARCHAR(30)
)

CREATE TABLE Usuario
(
	usuarioID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	planoID UNIQUEIDENTIFIER NOT NULL,
	nomeUsuario VARCHAR(100) NOT NULL,
	emailUsuario VARCHAR(254) UNIQUE NOT NULL,
	senha VARBINARY(32) NULL,
	telefone VARCHAR(15) NULL,
	dataCadastro DATETIME2(2) DEFAULT GETDATE(),
	tipoUsuario VARCHAR(10) NOT NULL,
	statusUsuario BIT DEFAULT 1,
)
GO

CREATE TABLE PreferenciasUsuario
(
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	modeloPadraoID UNIQUEIDENTIFIER NOT NULL,
	modoCor BIT DEFAULT 0,

	CONSTRAINT PK_PreferenciasUsuario_UsuarioID_ModeloPadraoID PRIMARY KEY (usuarioID, modeloPadraoID),
	CONSTRAINT FK_PreferenciasUsuairo_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID)
)
GO

CREATE TABLE SessaoUsuario
(
	sessaoUsuarioID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	dataHoraLogin DATETIME2(2) DEFAULT GETDATE(),
	dataHoraLogout DATETIME2(2) NULL,
	totalMensagens INT DEFAULT 0

	CONSTRAINT FK_SessaoUsuario_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID)
)
GO

CREATE TABLE ProvedorAI
(
	provedorID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	proprietarioID UNIQUEIDENTIFIER NULL,
	nomeProvedor NVARCHAR(30),
	apiKey VARCHAR(100),
	dataCadastro DATETIME2(2) DEFAULT GETDATE(),
	statusProvedor BIT DEFAULT 1,

	CONSTRAINT FK_ProvedorAI_Usuario_ProprietarioID FOREIGN KEY (proprietarioID) REFERENCES Usuario(usuarioID)
)
GO

CREATE TABLE ModeloAI
(
	modeloID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	provedorID UNIQUEIDENTIFIER NOT NULL,
	nome NVARCHAR(50) NOT NULL,
	identificadorAPI VARCHAR(150) UNIQUE,
	precoTokenInput DECIMAL(18, 6) NOT NULL,
	precoTokenOutput DECIMAL(18, 6) NOT NULL,
	limiteRequest INT,
	statusModelo BIT DEFAULT 1,

	CONSTRAINT FK_ModeloAI_Provedor_ProvedorID FOREIGN KEY (provedorID) REFERENCES ProvedorAI(provedorID)
)
GO

CREATE TABLE Chat
(
	chatID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	dataHoraCriacao DATETIME2(2) DEFAULT GETDATE(),
	statusChat BIT DEFAULT 1,
	totalMensagens INT DEFAULT 0,

	CONSTRAINT FK_Chat_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID)
)
GO

CREATE TABLE LogExclusaoChat
(
	logExclusaoChatID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	chatID UNIQUEIDENTIFIER NOT NULL,
	motivoExclusaoID UNIQUEIDENTIFIER NOT NULL,
	dataExclusaoChat DATETIME2(2) DEFAULT GETDATE(),

	CONSTRAINT FK_LogExclusaoChat_Chat_ChatID FOREIGN KEY (chatID) REFERENCES Chat(chatID),
	CONSTRAINT FK_LogExclusaoChat_MotivoExclusao_MotivoExclusaoID FOREIGN KEY (motivoExclusaoID) REFERENCES MotivoExclusao(motivoExclusaoID)
)
GO

CREATE TABLE LogUsuario
(
	logUsuarioID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	modeloPadraoID UNIQUEIDENTIFIER NOT NULL,
	nomeAnterior VARCHAR(100) NOT NULL,
	senhaAnterior VARBINARY(32) NULL,
	telefoneAnterior VARCHAR(15) NULL,
	statusUsuario BIT DEFAULT 1,

	CONSTRAINT FK_LogUsuario_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID),
	CONSTRAINT FK_LogUsuario_ModeloAI_ModeloPadraoID FOREIGN KEY (modeloPadraoID) REFERENCES ModeloAI(modeloID)
)
GO

CREATE TABLE Mensagem
(
	mensagemID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	chatID UNIQUEIDENTIFIER NOT NULL,
	modeloID UNIQUEIDENTIFIER NOT NULL,
	remetente VARCHAR(20),
	dataHoraEnvio DATETIME2(2) DEFAULT GETDATE()

	CONSTRAINT FK_Mensagem_Chat_ChatID FOREIGN KEY (ChatID) REFERENCES Chat(chatID),
	CONSTRAINT FK_Mensagem_ModeloAI_ModeloID FOREIGN KEY (modeloID) REFERENCES ModeloAI(modeloID)
)
GO

CREATE TABLE Arquivo 
(
	arquivoID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	mensagemID UNIQUEIDENTIFIER NOT NULL,
	tipoArquivoID UNIQUEIDENTIFIER NOT NULL,
	conteudoArquivo VARBINARY(max)

	CONSTRAINT FK_Arquivo_Mensagem_MensagemID FOREIGN KEY (mensagemID) REFERENCES Mensagem(mensagemID),
	CONSTRAINT FK_Arquivo_TipoArquivo_TipoArquivoID FOREIGN KEY (tipoArquivoID) REFERENCES TipoArquivo(tipoArquivoID)
)
GO

CREATE TABLE HistoricoConsumoToken
(
	historicoConsumoID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	mensagemID UNIQUEIDENTIFIER NOT NULL,
	quantidadeToken INT,
	dataHoraConsumo DATETIME2(2) DEFAULT GETDATE(),

	CONSTRAINT FK_HistoricoConsumo_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID),
	CONSTRAINT FK_HistoricoConsumo_Mensagem_MensagemID FOREIGN KEY (mensagemID) REFERENCES Mensagem(mensagemID)
)
GO

CREATE TABLE LimiteTokenPlanoModelo
(
	planoID UNIQUEIDENTIFIER NOT NULL,
	modeloID UNIQUEIDENTIFIER NOT NULL,
	limiteToken INT,

	CONSTRAINT PK_LimiteTokenPlanoModelo_PlanoID_ModeloID PRIMARY KEY (planoID, modeloID),
	CONSTRAINT FK_LimiteTokenPlanoModelo_Plano_PlanoID FOREIGN KEY (planoID) REFERENCES Plano(planoID),
	CONSTRAINT FK_LimiteTokenPlanoModelo_Modelo_ModeloID FOREIGN KEY (modeloID) REFERENCES ModeloAI(modeloID)
)
GO

CREATE TABLE TokenRestanteUsuairoModelo
(
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	modeloID UNIQUEIDENTIFIER NOT NULL,
	tokensRestantes INT,

	CONSTRAINT PK_TokenRestanteUsuarioModelo_UsuarioID PRIMARY KEY (usuarioID),
	CONSTRAINT FK_TokenRestanteUsuarioModelo_Usuairo_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID),
	CONSTRAINT FK_TokenRestanteUsuarioModelo_Modelo_ModeloID FOREIGN KEY (modeloID) REFERENCES ModeloAI(modeloID)
)
GO

CREATE TABLE RecuperacaoSenha
(
	recuperacaoSenhaID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	codigoRecuperacao VARCHAR(10) NOT NULL,
	dataHoraExpiracao DATETIME2(2) NOT NULL
)
GO


GO

CREATE TABLE TokenSessaoJWT
(
	tokenSessaoJWT UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	usuarioID UNIQUEIDENTIFIER NOT NULL,
	tokenJWT VARCHAR(max),
	horaExpiracao DATETIME2(2),

	CONSTRAINT FK_TokenSessaoJWT_Usuario_UsuarioID FOREIGN KEY (usuarioID) REFERENCES Usuario(usuarioID)
)
GO
