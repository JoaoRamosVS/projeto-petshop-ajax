USE DB_PETSHOP;

-- POPULAR BASE DE TUTORES E PETS

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('ana.silva@email.com', 'senha123', 2);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_TUTORES (NOME, CPF, TELEFONE, CEP, USUARIO_ID) VALUES ('Ana Silva', '111.222.333-44', '(11) 98765-4321', '01001-000', @usuario_id);
SET @tutor_id = LAST_INSERT_ID();
INSERT INTO TB_PETS (NOME, RACA, TAMANHO, PESO, DT_NASCIMENTO, OBS, OCORRENCIAS, TUTOR_ID) VALUES
('Rex', 'Labrador', 3, 28.5, '2019-01-10', 'Adora brincar de buscar a bolinha.', '', @tutor_id),
('Mia', 'Siamês', 2, 4.2, '2021-05-20', 'Um pouco arisca com estranhos.', '', @tutor_id);


INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('bruno.costa@email.com', 'senha456', 2);
INSERT INTO TB_TUTORES (NOME, CPF, TELEFONE, CEP, USUARIO_ID) VALUES ('Bruno Costa', '222.333.444-55', '(21) 91234-5678', '20040-030', LAST_INSERT_ID());
SET @tutor_id = LAST_INSERT_ID();
INSERT INTO TB_PETS (NOME, RACA, TAMANHO, PESO, DT_NASCIMENTO, OBS, OCORRENCIAS, TUTOR_ID) VALUES
('Thor', 'Golden Retriever', 4, 32.0, '2017-03-15', 'Muito dócil e amigável com outros cães.', 'Alergia a produtos de limpeza com cheiro forte.', @tutor_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('carla.mendes@email.com', 'senha789', 2);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_TUTORES (NOME, CPF, TELEFONE, CEP, USUARIO_ID) VALUES ('Carla Mendes', '333.444.555-66', '(31) 95555-4444', '30112-010', @usuario_id);
SET @tutor_id = LAST_INSERT_ID();
INSERT INTO TB_PETS (NOME, RACA, TAMANHO, PESO, DT_NASCIMENTO, OBS, OCORRENCIAS, TUTOR_ID) VALUES
('Lola', 'Poodle', 2, 6.8, '2022-02-01', 'Energética, precisa de passeios longos.', '', @tutor_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('daniel.oliveira@email.com', 'senha101', 2);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_TUTORES (NOME, CPF, TELEFONE, CEP, USUARIO_ID) VALUES ('Daniel Oliveira', '444.555.666-77', '(41) 94444-3333', '80010-010', @usuario_id);
SET @tutor_id = LAST_INSERT_ID();
INSERT INTO TB_PETS (NOME, RACA, TAMANHO, PESO, DT_NASCIMENTO, OBS, OCORRENCIAS, TUTOR_ID) VALUES
('Bolinha', 'Shih Tzu', 2, 5.5, '2020-08-12', '', '', @tutor_id),
('Frajola', 'Vira-lata (SRD)', 3, 12.0, '2018-06-25', 'Resgatado da rua, muito carinhoso.', '', @tutor_id);

-- POPULAR BASE DE FUNCIONÁRIOS

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('fernanda.lima@email.com', 'senha321', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Fernanda Lima', '555.666.777-88', '(51) 98877-6655', '90010-300', 'Veterinário', 5000.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('gabriel.santos@email.com', 'senha654', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Gabriel Santos', '666.777.888-99', '(61) 97766-5544', '70070-150', 'Tosador', 2500.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('helena.souza@email.com', 'senha987', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Helena Souza', '777.888.999-00', '(71) 96655-4433', '40020-000', 'Tosador', 2600.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('lucas.martins@email.com', 'senhaabc', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Lucas Martins', '888.999.000-11', '(81) 95544-3322', '50030-010', 'Veterinário', 5200.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('mariana.almeida@email.com', 'senhadef', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Mariana Almeida', '999.000.111-22', '(91) 94433-2211', '66010-000', 'Tosador', 2750.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('joana.pereira@email.com', 'senha1234', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Joana Pereira', '123.456.789-00', '(11) 91122-3344', '01234-567', 'Atendente', 2200.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('rodrigo.alves@email.com', 'senha5678', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Rodrigo Alves', '234.567.890-11', '(21) 92233-4455', '02345-678', 'Atendente', 2300.00, @usuario_id);

INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES ('beatriz.ribeiro@email.com', 'senha9012', 3);
SET @usuario_id = LAST_INSERT_ID();
INSERT INTO TB_FUNCIONARIOS (NOME, CPF, TELEFONE, CEP, CARGO, SALARIO, USUARIO_ID) VALUES ('Beatriz Ribeiro', '345.678.901-22', '(31) 93344-5566', '03456-789', 'Atendente', 2250.00, @usuario_id);