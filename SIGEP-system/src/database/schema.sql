CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    
    -- Dados de Autenticação e Acesso
    matricula VARCHAR(20) UNIQUE NOT NULL,
    senha TEXT NOT NULL,
	foto_url TEXT,
    role VARCHAR(20) CHECK (role IN ('ADMIN', 'INSPETOR', 'DIRETOR')) NOT NULL,
    
    -- Dados Pessoais e Civis
    nome_completo VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
	estado_civil VARCHAR(20) CHECK (estado_civil IN ('SOLTEIRO', 'CASADO', 'DIVORCIADO', 'VIUVO', 'UNIAO_ESTAVEL')),
    telefone VARCHAR(15),
    email_funcional VARCHAR(100) UNIQUE NOT NULL,
    
    -- Dados Funcionais
    cargo VARCHAR(50) NOT NULL,
    data_admissao DATE DEFAULT CURRENT_DATE,
    
    -- Controle de Sistema
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detentos (
    id SERIAL PRIMARY KEY,
    
    -- Dados Pessoais e Físicos
    nome_completo VARCHAR(150) NOT NULL,
	cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    nome_mae VARCHAR(150), -- Filiação é crucial no sistema prisional (evita homônimos)
    nome_pai VARCHAR(150),
    foto_url TEXT,
    sinais_particulares TEXT, -- Descrição de tatuagens, cicatrizes ou biometria
	estado_civil VARCHAR(20) CHECK (estado_civil IN ('SOLTEIRO', 'CASADO', 'DIVORCIADO', 'VIUVO', 'UNIAO_ESTAVEL')),
    
    -- Dados Jurídicos e de Segurança
    status_liberdade VARCHAR(30) CHECK (status_liberdade IN ('PRESO', 'ALVARA_CONCEDIDO', 'FORAGIDO', 'TRANSFERIDO')) DEFAULT 'PRESO',
    reincidente BOOLEAN DEFAULT FALSE,
    nivel_periculosidade INT CHECK (nivel_periculosidade IN (1, 2, 3)) NOT NULL, -- 1: Baixo, 2: Médio, 3: Alto
    numero_processo VARCHAR(50) UNIQUE,
    
    -- Auditoria (Chave Estrangeira ligando à tabela que criamos antes)
    cadastrado_por INT REFERENCES usuarios(id) ON DELETE SET NULL, 
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unidade_origem VARCHAR(100),
	tipo_entrada VARCHAR(30) CHECK (tipo_entrada IN ('CUSTODIA_INICIAL', 'TRANSFERENCIA')) DEFAULT 'CUSTODIA_INICIAL',

    -- Controle de Sistema
    ativo BOOLEAN DEFAULT TRUE

);

CREATE TABLE infracoes_penais (
    id SERIAL PRIMARY KEY,
    
    -- Vínculo com o Detento (A Chave Estrangeira)
    detento_id INT REFERENCES detentos(id) ON DELETE CASCADE NOT NULL,
    
    -- Dados do Delito
    artigo_penal VARCHAR(50) NOT NULL, -- Ex: "Art. 157 do CP"
    descricao_crime VARCHAR(255) NOT NULL, -- Ex: "Roubo qualificado"
    grau_gravidade INT CHECK (grau_gravidade IN (1, 2, 3)) NOT NULL, -- 1: Leve, 2: Médio, 3: Grave/Hediondo
    
    -- Datas e Prazos
    data_delito DATE,
    data_condenacao DATE,
    tempo_pena_anos INT DEFAULT 0,
    tempo_pena_meses INT DEFAULT 0,
    
    -- Controle de Sistema
    status_pena VARCHAR(30) CHECK (status_pena IN ('CUMPRINDO', 'EXTINTA', 'SUSPENSA')) DEFAULT 'CUMPRINDO',
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pavilhoes (
    id SERIAL PRIMARY KEY,
    
	--Só temos 3 pavilões A,B e C.
    nome CHAR(1) UNIQUE NOT NULL CHECK (nome IN ('A', 'B', 'C')),
    
    -- Regras de Negócio e Segurança
    capacidade_total INT NOT NULL CHECK (capacidade_total > 0),
    nivel_seguranca INT CHECK (nivel_seguranca IN (1, 2, 3)) NOT NULL,
    perfil_crime VARCHAR(100),
    
    -- Controle de Sistema
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE celas (
    id SERIAL PRIMARY KEY,
    
    -- Vínculo com o Pavilhão (Chave Estrangeira)
    pavilhao_id INT REFERENCES pavilhoes(id) ON DELETE CASCADE NOT NULL,
    
    -- Identificação e Regras da Cela
    codigo_cela VARCHAR(10) UNIQUE NOT NULL, -- Ex: 'A-01', 'C-15'
    capacidade INT NOT NULL CHECK (capacidade > 0),
	tipo_cela VARCHAR(30) CHECK (tipo_cela IN ('COMUM', 'SOLITARIA', 'PCD', 'INTIMA','LGBT','MAIS VELHOS','TIPO_FACÇÃO')) DEFAULT 'COMUM',
    
    -- Controle de Sistema (Soft Delete mantido)
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alocacao_historico (
    id SERIAL PRIMARY KEY,
    
    -- Os Atores da Movimentação (Chaves Estrangeiras)
    detento_id INT REFERENCES detentos(id) ON DELETE CASCADE NOT NULL,
    cela_id INT REFERENCES celas(id) ON DELETE CASCADE NOT NULL,
    
    -- A Linha do Tempo
    data_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_saida TIMESTAMP, -- Fica vazio (NULL) enquanto ele estiver morando nesta cela
    
    -- O Motivo (Regra de Negócio)
    motivo_movimentacao VARCHAR(100) NOT NULL, -- Ex: 'Entrada Inicial', 'Punição', 'Risco de Vida', 'Progressão'
    
    -- Auditoria (Quem apertou o botão no sistema?)
    registrado_por INT REFERENCES usuarios(id) ON DELETE SET NULL,
    
    -- Controle de Sistema (Soft Delete)
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ocorrencias_disciplinares (
    id SERIAL PRIMARY KEY,
    
    -- Vínculo Principal (Quem cometeu a infração?)
    detento_id INT REFERENCES detentos(id) ON DELETE CASCADE NOT NULL,
    
    -- Detalhes da Ocorrência
    tipo_ocorrencia VARCHAR(30) CHECK (tipo_ocorrencia IN ('FALTA_LEVE', 'FALTA_MEDIA', 'FALTA_GRAVE', 'ELOGIO')) NOT NULL,
    descricao TEXT NOT NULL, -- O relato detalhado do inspetor
    data_ocorrencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    -- Consequência
    gerou_punicao BOOLEAN DEFAULT FALSE, -- O Node.js pode usar isso para bloquear visitas, por exemplo
    
    -- Auditoria (Quem registrou isso no sistema?)
    registrado_por INT REFERENCES usuarios(id) ON DELETE SET NULL,
    
    -- Controle de Sistema (Soft Delete)
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE visitantes (
    id SERIAL PRIMARY KEY,
    
    -- Dados Pessoais de Identificação
    nome_completo VARCHAR(150) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    rg VARCHAR(20) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(15),
    foto_documento_url TEXT, -- Caminho para a foto do RG ou CNH (igual fizemos com o detento)
    
    -- Dados de Perfil
    tipo_visitante VARCHAR(30) CHECK (tipo_visitante IN ('FAMILIAR', 'CONJUGE', 'ADVOGADO', 'AMIGO', 'RELIGIOSO')) NOT NULL,
	grau_parentesco VARCHAR(30) CHECK (grau_parentesco IN ('PAI', 'MAE', 'FILHO_A', 'IRMAO_A', 'AVO', 'NETO_A', 'TIO_A', 'SOBRINHO_A', 'CONJUGE', 'UNIAO_ESTAVEL', 'NENHUM')) DEFAULT 'NENHUM',
    numero_oab VARCHAR(20) UNIQUE, -- Só será preenchido se o tipo for 'ADVOGADO'
    
    -- Segurança e Auditoria
    status_aprovacao VARCHAR(30) CHECK (status_aprovacao IN ('PENDENTE', 'APROVADO', 'BLOQUEADO')) DEFAULT 'PENDENTE',
    cadastrado_por INT REFERENCES usuarios(id) ON DELETE SET NULL,
    
    -- Controle de Sistema (Soft Delete)
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registros_visitas (
    id SERIAL PRIMARY KEY,
    
    -- Chaves Estrangeiras (Quem visita Quem?)
    visitante_id INT REFERENCES visitantes(id) ON DELETE CASCADE NOT NULL,
    detento_id INT REFERENCES detentos(id) ON DELETE CASCADE NOT NULL,
    
    -- O Vínculo Específico desta visita
    parentesco VARCHAR(50) NOT NULL, -- Ex: 'Mãe', 'Advogado', 'Cônjuge'
    
    -- Controle de Tempo (A Catraca)
    data_hora_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_hora_saida TIMESTAMP, -- Fica vazio (NULL) até o visitante ir embora
    
    -- Auditoria (Qual inspetor liberou a entrada na portaria?)
    liberado_por INT REFERENCES usuarios(id) ON DELETE SET NULL,
    
    -- Controle de Sistema
    status_visita VARCHAR(30) CHECK (status_visita IN ('EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA')) DEFAULT 'EM_ANDAMENTO',
    ativo BOOLEAN DEFAULT TRUE
);

ALTER TABLE detentos
ADD COLUMN trabalhador_interno BOOLEAN DEFAULT FALSE,
ADD COLUMN status_confianca VARCHAR(30) CHECK (status_confianca IN ('ALTO', 'MEDIO', 'BAIXO')) DEFAULT 'BAIXO';

ALTER TABLE celas
ADD COLUMN andar INT CHECK (andar IN (1, 2)) NOT NULL DEFAULT 1,
ADD COLUMN posicao_corredor VARCHAR(30) CHECK (posicao_corredor IN ('ENTRADA', 'MEIO', 'FUNDO')) NOT NULL DEFAULT 'MEIO',
ADD COLUMN cela_estrategica BOOLEAN DEFAULT FALSE; -- Marca se é a cela reservada para os "faxinas"
