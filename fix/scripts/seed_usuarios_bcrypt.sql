-- ============================================================
-- CORREÇÃO: usuários de seed com senha em BCrypt
-- ============================================================
-- Este trecho SUBSTITUI o INSERT de usuários original em banco.sql.
-- Antes (texto puro):
--   INSERT IGNORE INTO usuarios (nome, email, senha_hash, role, curso_id, curriculo_id) VALUES
--     ('Admin',        'admin@inf.ufpel.edu.br', 'admin123', 'ADMIN', NULL, NULL),
--     ('Usuário Teste','aluno@inf.ufpel.edu.br', 'aluno123', 'ALUNO', 1,    1);
--
-- Depois (hash BCrypt, senha real continua sendo admin123 / aluno123
-- ao logar pela tela — o hash abaixo é o que fica gravado no banco):

INSERT IGNORE INTO usuarios (nome, email, senha_hash, role, curso_id, curriculo_id) VALUES
  ('Admin',        'admin@inf.ufpel.edu.br', '$2b$10$SbLBagv4g1hYEycHKJVevuTcGaQ4wh2MgMAV41HZi.M72nXjdAKVG', 'ADMIN', NULL, NULL),
  ('Usuário Teste','aluno@inf.ufpel.edu.br', '$2b$10$sTOQ9lrsXKKWqYi9e0zDReLNm6OytNp3LAt7Nmrr7ESSdYuhT9fNe', 'ALUNO', 1,    1);

-- ============================================================
-- SE O BANCO JÁ EXISTE (você já rodou o banco.sql antigo e tem
-- usuários com senha em texto puro), rode este UPDATE em vez de
-- tentar inserir de novo (o INSERT IGNORE acima não sobrescreve
-- linhas existentes):
-- ============================================================

UPDATE usuarios SET senha_hash = '$2b$10$SbLBagv4g1hYEycHKJVevuTcGaQ4wh2MgMAV41HZi.M72nXjdAKVG'
  WHERE email = 'admin@inf.ufpel.edu.br';

UPDATE usuarios SET senha_hash = '$2b$10$sTOQ9lrsXKKWqYi9e0zDReLNm6OytNp3LAt7Nmrr7ESSdYuhT9fNe'
  WHERE email = 'aluno@inf.ufpel.edu.br';

-- IMPORTANTE: qualquer outro usuário criado ANTES desta correção
-- (via tela "Criar conta") também ficou com senha em texto puro no
-- banco e vai parar de conseguir logar, porque agora o sistema
-- compara com BCrypt.matches(). Ou peça para recriarem a conta,
-- ou rode um UPDATE manual gerando o hash com bcrypt para cada um.
