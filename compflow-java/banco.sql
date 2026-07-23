-- ============================================================
-- CompFlow - Script único de criação do banco de dados
-- Execute no MySQL antes de rodar o Spring Boot:
--   SOURCE banco.sql;
-- ============================================================

CREATE DATABASE IF NOT EXISTS compflow_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE compflow_db;

-- ============================================================
-- TABELAS (ordem respeita dependências de FK)
-- ============================================================

-- 1. Cursos (sem dependências)
CREATE TABLE IF NOT EXISTS cursos (
  id     BIGINT       NOT NULL AUTO_INCREMENT,
  nome   VARCHAR(150) NOT NULL,
  codigo VARCHAR(20)  NOT NULL UNIQUE,
  PRIMARY KEY (id)
);

-- 2. Disciplinas (sem dependências)
-- OBS: não tem mais coluna "tipo" nem "curso_id" — uma disciplina pode
-- pertencer a vários cursos ao mesmo tempo, então esse vínculo mora na
-- tabela disciplina_cursos (item 3 abaixo). "optativa" substitui o antigo
-- valor OPTATIVA do enum.
CREATE TABLE IF NOT EXISTS disciplinas (
  id       BIGINT      NOT NULL AUTO_INCREMENT,
  codigo   VARCHAR(20) NOT NULL UNIQUE,
  nome     VARCHAR(150) NOT NULL,
  creditos INT         NOT NULL,
  optativa BOOLEAN     NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id)
);

-- 3. Disciplina x Cursos (N:N — uma disciplina pode ser própria de vários cursos)
CREATE TABLE IF NOT EXISTS disciplina_cursos (
  disciplina_id BIGINT NOT NULL,
  curso_id      BIGINT NOT NULL,
  PRIMARY KEY (disciplina_id, curso_id),
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id) ON DELETE CASCADE,
  FOREIGN KEY (curso_id)      REFERENCES cursos(id)      ON DELETE CASCADE
);

-- 4. Curriculos (depende de cursos)
CREATE TABLE IF NOT EXISTS curriculos (
  id       BIGINT       NOT NULL AUTO_INCREMENT,
  nome     VARCHAR(150) NOT NULL,
  curso_id BIGINT,
  PRIMARY KEY (id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

-- 5. Usuarios (depende de cursos e curriculos)
CREATE TABLE IF NOT EXISTS usuarios (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(150) NOT NULL,
  email        VARCHAR(150) NOT NULL UNIQUE,
  senha_hash   VARCHAR(255) NOT NULL,
  role         ENUM('ALUNO','ADMIN') NOT NULL DEFAULT 'ALUNO',
  curso_id     BIGINT,
  curriculo_id BIGINT,
  criado_em    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (curso_id)     REFERENCES cursos(id),
  FOREIGN KEY (curriculo_id) REFERENCES curriculos(id)
);

-- 6. Curriculo x Disciplinas (depende de curriculos e disciplinas)
CREATE TABLE IF NOT EXISTS curriculo_disciplinas (
  id            BIGINT NOT NULL AUTO_INCREMENT,
  curriculo_id  BIGINT NOT NULL,
  disciplina_id BIGINT NOT NULL,
  semestre      INT    NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (curriculo_id)  REFERENCES curriculos(id)  ON DELETE CASCADE,
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id) ON DELETE CASCADE
);

-- 7. Progresso do aluno (depende de usuarios e disciplinas)
CREATE TABLE IF NOT EXISTS progresso_aluno (
  id            BIGINT   NOT NULL AUTO_INCREMENT,
  usuario_id    BIGINT   NOT NULL,
  disciplina_id BIGINT   NOT NULL,
  status        ENUM('APROVADO','CURSANDO','PENDENTE') NOT NULL DEFAULT 'PENDENTE',
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_prog (usuario_id, disciplina_id),
  FOREIGN KEY (usuario_id)    REFERENCES usuarios(id)    ON DELETE CASCADE,
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id) ON DELETE CASCADE
);

-- 8. Eventos (sem dependências)
CREATE TABLE IF NOT EXISTS eventos (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  titulo      VARCHAR(200) NOT NULL,
  data_inicio DATE         NOT NULL,
  data_fim    DATE,
  tipo        ENUM('PRAZO','EVENTO_ACADEMICO','FERIADO') NOT NULL,
  PRIMARY KEY (id)
);

-- 9. Contatos (sem dependências)
CREATE TABLE IF NOT EXISTS contatos (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(150) NOT NULL,
  cargo        VARCHAR(150),
  categoria    ENUM('DOCENTE','APOIO') NOT NULL,
  email        VARCHAR(150) NOT NULL,
  departamento VARCHAR(150),
  PRIMARY KEY (id)
);

-- ============================================================
-- DADOS INICIAIS
-- Fonte das disciplinas/currículos: Matriz Curricular oficial da UFPel
-- Ciência da Computação (cód. 3900) e Engenharia de Computação (cód. 3910)
-- https://institucional.ufpel.edu.br/cursos/cod/3900
-- https://institucional.ufpel.edu.br/cursos/cod/3910
-- ============================================================

-- Cursos
INSERT IGNORE INTO cursos (id, nome, codigo) VALUES
  (1, 'Ciência da Computação',    '3900'),
  (2, 'Engenharia de Computação', '3910');

-- Disciplinas
-- (sem coluna de curso aqui — o vínculo vem logo depois, em disciplina_cursos)
INSERT IGNORE INTO disciplinas (codigo, nome, creditos, optativa) VALUES
  -- Compartilhadas entre os dois cursos
  ('11100058', 'Cálculo 1', 4, false),
  ('11100059', 'Cálculo 2', 4, false),
  ('11100060', 'Cálculo 3', 6, false),
  ('11100110', 'Álgebra Linear e Geometria Analítica', 6, false),
  ('06730016', 'Epistemologia', 2, false),
  ('22000199', 'Metodologia Científica para Computação', 4, false),
  ('22000298', 'Estatística Básica para Computação', 4, false),
  ('22000268', 'Cálculo Numérico Computacional', 4, false),
  ('22000186', 'Computação e Sociedade', 4, false),
  ('22000294', 'Algoritmos e Programação', 4, false),
  ('22000224', 'Lógica para Computação', 4, false),
  ('22000293', 'Sistemas Discretos', 4, false),
  ('22000296', 'Programação de Computadores', 4, false),
  ('22000297', 'Algoritmos e Estruturas de Dados I', 4, false),
  ('22000181', 'Arquitetura e Organização de Computadores I', 4, false),
  ('22000197', 'Linguagens Formais', 4, false),
  ('22000201', 'Programação Orientada a Objetos', 4, false),
  ('22000299', 'Algoritmos e Estruturas de Dados II', 4, false),
  ('22000182', 'Arquitetura e Organização de Computadores II', 4, false),
  ('22000205', 'Teoria da Computação', 4, false),
  ('22000270', 'Sistemas Operacionais', 4, false),
  ('22000237', 'Programação de Sistemas', 4, false),
  ('22000273', 'Redes de Computadores', 4, false),
  ('22000189', 'Engenharia de Software I', 4, false),
  ('22000303', 'Projeto de Compiladores', 4, false),
  ('22000272', 'Introd. Processamento Paralelo e Distribuído', 4, false),
  ('22000305', 'Trabalho de Conclusão de Curso I', 8, false),
  ('22000306', 'Trabalho de Conclusão de Curso II', 8, false),
  ('06560017', 'Sociologia', 2, false),

  -- Exclusivas de Ciência da Computação
  ('22000196', 'Introdução à Ciência da Computação', 4, false),
  ('22000207', 'Laboratório de Computação', 2, false),
  ('22000295', 'Análise Combinatória e Teoria dos Grafos', 4, false),
  ('22000211', 'Técnicas Digitais', 4, false),
  ('22000300', 'Algoritmos e Estruturas de Dados III', 4, false),
  ('22000188', 'Conceitos de Linguagens de Programação', 4, false),
  ('22000301', 'Fundamentos de Inteligência Artificial', 4, false),
  ('22000302', 'Projeto de Banco de Dados', 4, false),
  ('22000187', 'Computação Gráfica', 4, false),
  ('22000203', 'Semântica Formal', 4, false),
  ('22000304', 'Desenvolvimento de Softwares', 4, false),
  ('22000174', 'Engenharia de Software II', 4, false),
  ('22000255', 'Processamento Digital de Imagens', 4, false),

  -- Exclusivas de Engenharia de Computação
  ('22000225', 'Introdução a Engenharia de Computação', 4, false),
  ('22000226', 'Circuitos Digitais I', 4, false),
  ('11090032', 'Física Básica I', 4, false),
  ('22000238', 'Circuitos Digitais II', 4, false),
  ('11090033', 'Física Básica II', 4, false),
  ('22000236', 'Análise de Circuitos I', 4, false),
  ('11100050', 'Equações Diferenciais', 4, false),
  ('11090034', 'Física Básica III', 4, false),
  ('22000230', 'Eletrônica Básica I', 4, false),
  ('22000267', 'Análise de Circuitos II', 4, false),
  ('22000269', 'Sistemas Digitais Avançados', 4, false),
  ('22000240', 'Concepção de Circuitos Integrados', 4, false),
  ('22000271', 'Eletrônica Básica II', 4, false),
  ('22000178', 'Sistemas e Sinais', 6, false),
  ('22000274', 'Princípios de Comunicação', 4, false),
  ('22000275', 'Sistemas de Controle', 4, false),

  -- Optativas (disponíveis pra qualquer aluno, sem curso vinculado)
  ('22000308', 'Arquitetura e Organização Comput. Avançados', 4, true),
  ('22000311', 'Segurança de Computadores', 4, true),
  ('22000282', 'Robótica', 4, true),
  ('22000241', 'Interação Humano-Computador', 4, true),
  ('22000231', 'Sistemas Embarcados', 4, true),
  ('20000084', 'Língua Brasileira de Sinais I (LIBRAS I)', 4, true);

-- Disciplina x Cursos — vínculo N:N
-- Disciplinas de Ciência da Computação (inclui as compartilhadas)
INSERT IGNORE INTO disciplina_cursos (disciplina_id, curso_id)
SELECT id, 1 FROM disciplinas WHERE codigo IN (
  '11100058','11100059','11100060','11100110','06730016','22000199','22000298',
  '22000268','22000186','22000294','22000224','22000293','22000296','22000297',
  '22000181','22000197','22000201','22000299','22000182','22000205','22000270',
  '22000237','22000273','22000189','22000303','22000272','22000305','22000306',
  '06560017','22000196','22000207','22000295','22000211','22000300','22000188',
  '22000301','22000302','22000187','22000203','22000304','22000174','22000255'
);
-- Disciplinas de Engenharia de Computação (inclui as compartilhadas)
INSERT IGNORE INTO disciplina_cursos (disciplina_id, curso_id)
SELECT id, 2 FROM disciplinas WHERE codigo IN (
  '11100058','11100059','11100060','11100110','06730016','22000199','22000298',
  '22000268','22000186','22000294','22000224','22000293','22000296','22000297',
  '22000181','22000197','22000201','22000299','22000182','22000205','22000270',
  '22000237','22000273','22000189','22000303','22000272','22000305','22000306',
  '22000225','22000226','11090032','22000238','11090033','22000236','11100050',
  '11090034','22000230','22000267','22000269','22000240','22000271','22000178',
  '22000274','22000275'
);

-- Currículos
INSERT IGNORE INTO curriculos (id, nome, curso_id) VALUES
  (1, 'Ciência da Computação - Currículo 1028', 1),
  (2, 'Engenharia de Computação - Currículo 1030', 2);

-- Currículo x Disciplinas — Ciência da Computação (8 semestres + optativas no 9º)
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 1 FROM disciplinas WHERE codigo IN ('22000294','22000196','22000207','22000224','22000293');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 2 FROM disciplinas WHERE codigo IN ('22000295','11100058','22000199','22000296','22000211');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 3 FROM disciplinas WHERE codigo IN ('22000297','22000181','11100059','22000197','22000201','06560017');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 4 FROM disciplinas WHERE codigo IN ('11100110','22000299','22000182','06730016','22000298','22000205');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 5 FROM disciplinas WHERE codigo IN ('22000300','22000188','22000301','22000237','22000302','22000270');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 6 FROM disciplinas WHERE codigo IN ('22000268','22000187','22000189','22000273','22000203');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 7 FROM disciplinas WHERE codigo IN ('22000304','22000174','22000272','22000303','22000305');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 8 FROM disciplinas WHERE codigo IN ('22000186','22000255','22000306');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 1, id, 9 FROM disciplinas WHERE codigo IN ('22000308','22000311','22000282');

-- Currículo x Disciplinas — Engenharia de Computação (10 semestres + optativas no 11º)
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 1 FROM disciplinas WHERE codigo IN ('22000294','11100058','22000225','22000224','22000293');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 2 FROM disciplinas WHERE codigo IN ('11100110','11100059','22000226','11090032','22000296');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 3 FROM disciplinas WHERE codigo IN ('22000297','11100060','22000238','06730016','11090033','22000197');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 4 FROM disciplinas WHERE codigo IN ('22000299','22000236','22000181','11100050','11090034','22000201');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 5 FROM disciplinas WHERE codigo IN ('22000182','22000230','22000298','22000199','22000237','22000205');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 6 FROM disciplinas WHERE codigo IN ('22000267','22000268','22000186','22000269','22000270');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 7 FROM disciplinas WHERE codigo IN ('22000240','22000271','22000273','22000178');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 8 FROM disciplinas WHERE codigo IN ('22000189','22000272','22000303');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 9 FROM disciplinas WHERE codigo IN ('22000274','22000305');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 10 FROM disciplinas WHERE codigo IN ('22000275','22000306');
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre)
SELECT 2, id, 11 FROM disciplinas WHERE codigo IN ('22000241','22000231','20000084');

-- Usuários (admin + aluno de teste já vinculado ao currículo de CC)
-- ATENÇÃO: as senhas abaixo já são hashes BCrypt de verdade, gerados
-- especificamente pra esse script — NÃO são texto puro como estava antes.
-- Login do admin: admin@inf.ufpel.edu.br / senha: admin123
-- Login do aluno: aluno@inf.ufpel.edu.br / senha: aluno123
INSERT IGNORE INTO usuarios (nome, email, senha_hash, role, curso_id, curriculo_id) VALUES
  ('Admin',        'admin@inf.ufpel.edu.br', '$2b$12$oj7LcN91UFJE0kApN/ehaeFfcSHfVbz3N6xNby4Z9P/OMH9sMpFqe', 'ADMIN', NULL, NULL),
  ('Usuário Teste','aluno@inf.ufpel.edu.br', '$2b$12$PDvBMXqpKX.g6rSxHNSmyeLKggORyNahA99.T/sr91eIfRiF456Qu', 'ALUNO', 1,    1);

-- Eventos
INSERT IGNORE INTO eventos (titulo, data_inicio, tipo) VALUES
  ('Prazo Final Trancamento',   '2026-05-30', 'PRAZO'),
  ('Corpus Christi',            '2026-06-04', 'FERIADO'),
  ('Período de Rematrícula',    '2026-06-15', 'EVENTO_ACADEMICO'),
  ('Início das Avaliações',     '2026-06-20', 'EVENTO_ACADEMICO'),
  ('Independência do Brasil',   '2026-09-07', 'FERIADO'),
  ('Início do Semestre 2026/2', '2026-08-12', 'EVENTO_ACADEMICO');

-- Contatos
INSERT IGNORE INTO contatos (nome, cargo, categoria, email) VALUES
  ('Prof. Dr. Ana Marilza Pernas',       'Docente',            'DOCENTE','marilza@inf.ufpel.edu.br'),
  ('Prof. Dr. Andre Rauber Du Bois',     'Docente',            'DOCENTE','dubois@inf.ufpel.edu.br'),
  ('Secretaria da Ciência da Computação','Secretaria Acadêmica','APOIO',  'secretaria-ccomp@inf.ufpel.edu.br'),
  ('Coordenação Ciência da Computação',  'Coordenação',        'APOIO',  'coord_ccomp@inf.ufpel.edu.br'),
  ('Ouvidoria UFPel',                    'Apoio',              'APOIO',  'ouvidoria@ufpel.edu.br');