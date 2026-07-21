# 🎓 CompFlow - Planejamento Acadêmico UFPel

O **CompFlow** é um sistema web desenvolvido para auxiliar os alunos de Ciência da Computação da UFPel no gerenciamento de sua jornada acadêmica. O projeto fornece uma interface intuitiva para o rastreamento de disciplinas cursadas, visualização interativa do fluxograma com validação de pré-requisitos, e um painel centralizado para eventos e contatos do curso.

## 🚀 Tecnologias Utilizadas

O sistema foi construído utilizando uma arquitetura monolítica, com o backend servindo as APIs REST e os recursos estáticos do frontend.

*   **Backend:** Java 17, Spring Boot, Spring Data JPA, Maven.
*   **Segurança:** Spring Security Crypto (hashing de senhas com algoritmo BCrypt).
*   **Banco de Dados:** MySQL 8.0 (orquestrado via Docker Compose).
*   **Frontend:** HTML5, CSS3 e JavaScript Vanilla (desenvolvido sem frameworks externos para máxima leveza e performance).

## ✨ Funcionalidades

### 👨‍🎓 Visão do Aluno
*   **Dashboard Dinâmico:** Resumo visual do progresso geral, contabilizando créditos obtidos e disciplinas aprovadas.
*   **Fluxograma Interativo:** Motor de validação de pré-requisitos em tempo real. O sistema mapeia o progresso do aluno e bloqueia/libera visualmente as disciplinas seguintes com base na matriz curricular.
*   **Calendário Acadêmico:** Acompanhamento de prazos, feriados e eventos lançados pela coordenação.
*   **Contatos Rápidos:** Acesso direto a e-mails e departamentos de docentes e equipe de apoio.

### 🛡️ Visão Administrativa (Admin)
*   **Gestão de Matriz Curricular:** Criação e edição de currículos, organizando as disciplinas por semestre.
*   **Controle de Disciplinas:** Cadastro completo de matérias (código, créditos e tipo).
*   **Administração de Alunos:** Gerenciamento da base de usuários e definição do currículo vigente para cada estudante.
*   **Gestão de Eventos e Prazos:** Painel para inclusão e exclusão de datas importantes do semestre.

## ⚙️ Como Executar o Projeto Localmente

### Pré-requisitos
*   [Java JDK 17+](https://adoptium.net/)
*   [Maven](https://maven.apache.org/)
*   [Docker](https://www.docker.com/) e Docker Compose

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/seu-usuario/compflow.git](https://github.com/seu-usuario/compflow.git)
   cd compflow

    Inicie o Banco de Dados:
       Suba o contêiner do MySQL configurado no projeto utilizando o Docker Compose:
       Bash

       docker-compose up -d

    Inicie o Servidor Spring Boot:
    Compile e execute a aplicação Java via Maven:

   Bash
   mvn clean install
   mvn spring-boot:run

    Acesse a Aplicação:
    Abra o seu navegador e acesse a tela de login: http://localhost:8080/login.html

🔑 Credenciais de Teste

Para explorar as funcionalidades do sistema, utilize os usuários previamente populados no banco de dados através do script SQL inicial:

    Administrador (Acesso ao Painel de Controle):

        E-mail: teste@inf.ufpel.edu.br

        Senha: teste123

    Aluno (Acesso ao Fluxograma e Progresso):

        Você pode criar uma nova conta na tela de registro ou usar  E-mail: teste1@inf.ufpel.edu.br e Senha: teste123
        
Projeto desenvolvido como requisito acadêmico (desenvolvido exclusivamente em Java Spring Boot) para o curso de Ciência da Computação da Universidade Federal de Pelotas (UFPel).
