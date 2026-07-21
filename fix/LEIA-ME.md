# Correções aplicadas — CompFlow

## 1. Senha em texto puro → BCrypt (crítico)

**Arquivos:**
- `pom.xml` → substitua o seu por este (adiciona `spring-security-crypto`)
- `src/main/java/br/ufpel/compflow/service/UsuarioService.java` → substitua o seu por este

**O que mudou:**
- `registrar()`: a senha agora é gravada como `passwordEncoder.encode(req.getSenha())` em vez de texto puro.
- `login()`: a comparação agora usa `passwordEncoder.matches(senhaDigitada, hashSalvo)` em vez de `.equals()`.

**Passo a passo para aplicar:**
1. Substitua `compflow-java/pom.xml` pelo `pom.xml` deste pacote.
2. Substitua `compflow-java/src/main/java/br/ufpel/compflow/service/UsuarioService.java` pelo daqui.
3. Rode `mvn clean install` para baixar a nova dependência.
4. **Importante:** usuários já cadastrados com senha em texto puro (inclusive os de seed do `banco.sql`) vão parar de logar, porque agora o sistema compara com hash. Aplique a correção do banco (próximo item).

## 2. Corrigir senhas já gravadas no banco

**Arquivo:** `scripts/seed_usuarios_bcrypt.sql`

- Se você **ainda não rodou** o `banco.sql` original: troque o bloco de `INSERT` de usuários pelo bloco novo (hashes já prontos).
- Se você **já rodou** o `banco.sql` antigo e o banco já existe: rode os dois `UPDATE` do arquivo para corrigir os usuários `admin@inf.ufpel.edu.br` e `aluno@inf.ufpel.edu.br` sem perder o resto dos dados.
- As senhas continuam sendo `admin123` e `aluno123` na tela de login — só o que está gravado no banco muda (vira hash).
- Qualquer conta criada pela tela "Criar conta" **antes** dessa correção ficou com senha em texto puro e vai precisar ser recriada ou ter o hash corrigido manualmente.

## 3. Duplicação de frontend (3 cópias dos mesmos arquivos)

**Arquivo:** `scripts/limpar_duplicacao_frontend.sh`

Rode a partir da raiz do projeto:
```bash
chmod +x scripts/limpar_duplicacao_frontend.sh
./scripts/limpar_duplicacao_frontend.sh
```

O que ele faz:
- Move `compflow-integrado/` para uma pasta de backup com timestamp (não apaga, só tira do caminho).
- Remove `compflow-java/target/` (é sempre regerado pelo Maven, não deveria ser editado nem versionado).
- A partir daí, a única pasta de frontend a editar é `compflow-java/src/main/resources/static/`.

## 4. O que **não** precisou de correção de código

Conferido e OK, sem necessidade de alteração:
- Contratos DTO ↔ JS (`ContatoResponse`, `DisciplinaResponse`, `EventoResponse`, `UsuarioResponse`, `CurriculoResponse`, enums de status/categoria/tipo) batendo entre backend e frontend.
- As páginas realmente servidas (`src/main/resources/static/login.html` e `dashboard.html`) **não** têm a referência quebrada a `api.js` — esse problema só existia na cópia solta `compflow-integrado/`, que este pacote já resolve via limpeza.
- `docker-compose.yml` e `Dockerfile` — corretos, só lembre de rodar `mvn clean package` antes de `docker compose up --build`.

## 5. Débito técnico registrado (não corrigido agora, de propósito)

- `ProgressoResponse.creditorConcluidos` tem um typo (deveria ser `creditosConcluidos`), mas como o mesmo nome é usado consistentemente no backend e no frontend, **funciona**. Só mexa nisso numa refatoração deliberada, tocando os dois lados ao mesmo tempo, para não quebrar nada à toa.

## Ordem recomendada de aplicação

1. `./scripts/limpar_duplicacao_frontend.sh`
2. Substituir `pom.xml` e `UsuarioService.java`
3. `mvn clean install`
4. Aplicar `scripts/seed_usuarios_bcrypt.sql` no banco (INSERT se for banco novo, UPDATE se já existir)
5. Subir o backend e testar login com `admin@inf.ufpel.edu.br` / `admin123` e `aluno@inf.ufpel.edu.br` / `aluno123`
