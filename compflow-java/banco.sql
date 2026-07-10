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
CREATE TABLE IF NOT EXISTS disciplinas (
  id       BIGINT      NOT NULL AUTO_INCREMENT,
  codigo   VARCHAR(20) NOT NULL UNIQUE,
  nome     VARCHAR(150) NOT NULL,
  creditos INT         NOT NULL,
  tipo     ENUM('INTERNO','EXTERNO') NOT NULL DEFAULT 'INTERNO',
  PRIMARY KEY (id)
);

-- 3. Curriculos (depende de cursos)
CREATE TABLE IF NOT EXISTS curriculos (
  id       BIGINT       NOT NULL AUTO_INCREMENT,
  nome     VARCHAR(150) NOT NULL,
  curso_id BIGINT,
  PRIMARY KEY (id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

-- 4. Usuarios (depende de cursos e curriculos)
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

-- 5. Curriculo x Disciplinas (depende de curriculos e disciplinas)
CREATE TABLE IF NOT EXISTS curriculo_disciplinas (
  id            BIGINT NOT NULL AUTO_INCREMENT,
  curriculo_id  BIGINT NOT NULL,
  disciplina_id BIGINT NOT NULL,
  semestre      INT    NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (curriculo_id)  REFERENCES curriculos(id)  ON DELETE CASCADE,
  FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id) ON DELETE CASCADE
);

-- 6. Progresso do aluno (depende de usuarios e disciplinas)
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

-- 7. Eventos (sem dependências)
CREATE TABLE IF NOT EXISTS eventos (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  titulo      VARCHAR(200) NOT NULL,
  data_inicio DATE         NOT NULL,
  data_fim    DATE,
  tipo        ENUM('PRAZO','EVENTO_ACADEMICO','FERIADO') NOT NULL,
  PRIMARY KEY (id)
);

-- 8. Contatos (sem dependências)
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
-- ============================================================

-- Cursos
INSERT IGNORE INTO cursos (nome, codigo) VALUES
  ('Ciência da Computação',    'CC'),
  ('Engenharia de Computação', 'EC');

-- Disciplinas
-- Fonte: Matriz Curricular oficial do curso de Ciência da Computação da UFPel
-- (currículo vigente 1028) - https://institucional.ufpel.edu.br/cursos/cod/3900
-- Disciplinas de código 22000xxx são do CDTec (INTERNO); as demais são de
-- outras unidades (EXTERNO): Cálculo 1/2, Álgebra Linear, Sociologia, Epistemologia.
INSERT IGNORE INTO disciplinas (codigo, nome, creditos, tipo) VALUES
  -- 1º Semestre
  ('22000294','Algoritmos e Programação',                     4,'INTERNO'),
  ('22000196','Introdução à Ciência da Computação',           4,'INTERNO'),
  ('22000207','Laboratório de Computação',                    2,'INTERNO'),
  ('22000224','Lógica para Computação',                       4,'INTERNO'),
  ('22000293','Sistemas Discretos',                           4,'INTERNO'),
  -- 2º Semestre
  ('22000295','Análise Combinatória e Teoria dos Grafos',     4,'INTERNO'),
  ('11100058','Cálculo 1',                                    4,'EXTERNO'),
  ('22000199','Metodologia Científica para Computação',       4,'INTERNO'),
  ('22000296','Programação de Computadores',                  4,'INTERNO'),
  ('22000211','Técnicas Digitais',                             4,'INTERNO'),
  -- 3º Semestre
  ('22000297','Algoritmos e Estruturas de Dados I',           4,'INTERNO'),
  ('22000181','Arquitetura e Organização de Computadores I',  4,'INTERNO'),
  ('11100059','Cálculo 2',                                    4,'EXTERNO'),
  ('22000197','Linguagens Formais',                           4,'INTERNO'),
  ('22000201','Programação Orientada a Objetos',              4,'INTERNO'),
  ('06560017','Sociologia',                                   2,'EXTERNO'),
  -- 4º Semestre
  ('11100110','Álgebra Linear e Geometria Analítica',         6,'EXTERNO'),
  ('22000299','Algoritmos e Estruturas de Dados II',          4,'INTERNO'),
  ('22000182','Arquitetura e Organização de Computadores II', 4,'INTERNO'),
  ('06730016','Epistemologia',                                2,'EXTERNO'),
  ('22000298','Estatística Básica para Computação',           4,'INTERNO'),
  ('22000205','Teoria da Computação',                         4,'INTERNO'),
  -- 5º Semestre
  ('22000300','Algoritmos e Estruturas de Dados III',         4,'INTERNO'),
  ('22000188','Conceitos de Linguagens de Programação',       4,'INTERNO'),
  ('22000301','Fundamentos de Inteligência Artificial',       4,'INTERNO'),
  ('22000237','Programação de Sistemas',                      4,'INTERNO'),
  ('22000302','Projeto de Banco de Dados',                    4,'INTERNO'),
  ('22000270','Sistemas Operacionais',                        4,'INTERNO'),
  -- 6º Semestre
  ('22000268','Cálculo Numérico Computacional',               4,'INTERNO'),
  ('22000187','Computação Gráfica',                           4,'INTERNO'),
  ('22000189','Engenharia de Software I',                     4,'INTERNO'),
  ('22000273','Redes de Computadores',                        4,'INTERNO'),
  ('22000203','Semântica Formal',                             4,'INTERNO'),
  -- 7º Semestre
  ('22000304','Desenvolvimento de Softwares',                 4,'INTERNO'),
  ('22000174','Engenharia de Software II',                    4,'INTERNO'),
  ('22000272','Introd. Processamento Paralelo e Distribuído', 4,'INTERNO'),
  ('22000303','Projeto de Compiladores',                      4,'INTERNO'),
  ('22000305','Trabalho de Conclusão de Curso I',              8,'INTERNO'),
  -- 8º Semestre
  ('22000186','Computação e Sociedade',                       4,'INTERNO'),
  ('22000255','Processamento Digital de Imagens',              4,'INTERNO'),
  ('22000306','Trabalho de Conclusão de Curso II',             8,'INTERNO');

-- Currículo da Ciência da Computação (curso_id = 1)
INSERT IGNORE INTO curriculos (id, nome, curso_id) VALUES (1, 'Ciência da Computação', 1);

-- Disciplinas por semestre do currículo 1 (grade oficial - 41 disciplinas obrigatórias, 8 semestres)
-- Os IDs abaixo seguem a ordem de inserção acima (1 a 41)
INSERT IGNORE INTO curriculo_disciplinas (curriculo_id, disciplina_id, semestre) VALUES
  (1,  1, 1),(1,  2, 1),(1,  3, 1),(1,  4, 1),(1,  5, 1),
  (1,  6, 2),(1,  7, 2),(1,  8, 2),(1,  9, 2),(1, 10, 2),
  (1, 11, 3),(1, 12, 3),(1, 13, 3),(1, 14, 3),(1, 15, 3),(1, 16, 3),
  (1, 17, 4),(1, 18, 4),(1, 19, 4),(1, 20, 4),(1, 21, 4),(1, 22, 4),
  (1, 23, 5),(1, 24, 5),(1, 25, 5),(1, 26, 5),(1, 27, 5),(1, 28, 5),
  (1, 29, 6),(1, 30, 6),(1, 31, 6),(1, 32, 6),(1, 33, 6),
  (1, 34, 7),(1, 35, 7),(1, 36, 7),(1, 37, 7),(1, 38, 7),
  (1, 39, 8),(1, 40, 8),(1, 41, 8);

-- Usuários (admin + aluno de teste já vinculado ao currículo)
INSERT IGNORE INTO usuarios (nome, email, senha_hash, role, curso_id, curriculo_id) VALUES
  ('Admin',        'admin@inf.ufpel.edu.br', 'admin123', 'ADMIN', NULL, NULL),
  ('Usuário Teste','aluno@inf.ufpel.edu.br', 'aluno123', 'ALUNO', 1,    1);

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
