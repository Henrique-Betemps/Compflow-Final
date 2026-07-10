console.log("O ARQUIVO API.JS FOI CARREGADO COM SUCESSO!");

const API_URL = "http://localhost:8080/api";

// Função assíncrona para buscar os dados
async function buscarCursos() {
    try {
        console.log("Buscando dados no backend...");

        // Faz a requisição GET para a rota de cursos
        const resposta = await fetch(`${API_URL}/cursos`);

        if (!resposta.ok) {
            throw new Error(`Erro na API: ${resposta.status}`);
        }

        // Converte a resposta do Java (JSON) para um objeto JavaScript
        const cursos = await resposta.json();

        console.log("Sucesso! Cursos recebidos do banco de dados:", cursos);

        // Aqui é onde você usaria o JavaScript para criar as <div> ou <li> na tela
        // Por exemplo: popularListaNaTela(cursos);

    } catch (erro) {
        console.error("Falha ao conectar com o servidor Spring Boot:", erro);
    }
}

// Executa a função assim que o script carregar
buscarCursos();