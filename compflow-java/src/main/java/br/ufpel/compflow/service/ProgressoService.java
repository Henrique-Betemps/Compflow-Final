package br.ufpel.compflow.service;

import br.ufpel.compflow.dto.request.ProgressoRequest;
import br.ufpel.compflow.dto.response.ProgressoResponse;
import br.ufpel.compflow.entity.*;
import br.ufpel.compflow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProgressoService {

    private final ProgressoAlunoRepository      progressoRepo;
    private final UsuarioRepository             usuarioRepo;
    private final DisciplinaRepository          disciplinaRepo;
    private final CurriculoDisciplinaRepository cdRepo;
    private final CurriculoRepository           curriculoRepo;

    public ProgressoResponse buscarProgresso(Long usuarioId) {
        Usuario u = usuarioRepo.findById(usuarioId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        Map<Long, String> statusMap = new HashMap<>();
        progressoRepo.findByUsuarioId(usuarioId)
            .forEach(p -> statusMap.put(p.getDisciplina().getId(), p.getStatus().name()));

        // Usa o currículo vinculado diretamente ao aluno.
        // Se o aluno ainda não tem um currículo escolhido (cadastro antigo),
        // cai no comportamento antigo: pega o primeiro currículo do curso.
        List<CurriculoDisciplina> cds = new ArrayList<>();
        Curriculo curriculoDoAluno = u.getCurriculo();

        if (curriculoDoAluno == null && u.getCurso() != null) {
            List<Curriculo> curriculos = curriculoRepo.findByCursoId(u.getCurso().getId());
            if (!curriculos.isEmpty()) {
                curriculoDoAluno = curriculos.get(0);
            }
        }

        if (curriculoDoAluno != null) {
            cds = cdRepo.findByCurriculoIdOrderBySemestre(curriculoDoAluno.getId());
        }

        // Curso do aluno, usado como referência pra decidir interno/externo
        Curso cursoDoAluno = curriculoDoAluno != null ? curriculoDoAluno.getCurso() : null;

        Map<Integer, List<ProgressoResponse.DisciplinaProgressoResponse>> porSemestre = new TreeMap<>();
        int totalCreditos = 0, creditosConcluidos = 0, aprovadas = 0;
        int totalCreditosOptativos = 0, creditosOptativosConcluidos = 0;

        for (CurriculoDisciplina cd : cds) {
            Disciplina d  = cd.getDisciplina();
            String status = statusMap.getOrDefault(d.getId(), "PENDENTE");
            boolean aprovado = "APROVADO".equals(status);
            boolean optativa = d.isOptativa();

            String categoria;
            if (optativa) {
                categoria = "OPTATIVA";
            } else if (cursoDoAluno != null && d.getCursos().stream()
                    .anyMatch(c -> c.getId().equals(cursoDoAluno.getId()))) {
                categoria = "INTERNO";
            } else {
                categoria = "EXTERNO";
            }

            if (optativa) {
                // Optativas têm contagem própria e não entram no total obrigatório
                totalCreditosOptativos += d.getCreditos();
                if (aprovado) {
                    creditosOptativosConcluidos += d.getCreditos();
                }
            } else {
                totalCreditos += d.getCreditos();
                if (aprovado) {
                    creditosConcluidos += d.getCreditos();
                }
            }

            if (aprovado) {
                aprovadas++;
            }

            porSemestre.computeIfAbsent(cd.getSemestre(), k -> new ArrayList<>())
                .add(new ProgressoResponse.DisciplinaProgressoResponse(
                    d.getId(), d.getCodigo(), d.getNome(), d.getCreditos(), status, categoria));
        }

        int percentual = totalCreditos > 0
            ? (int) Math.round((creditosConcluidos * 100.0) / totalCreditos) : 0;

        List<ProgressoResponse.SemestreProgressoResponse> semestresResp = porSemestre.entrySet().stream()
            .map(e -> new ProgressoResponse.SemestreProgressoResponse(e.getKey(), e.getValue()))
            .collect(Collectors.toList());

        return new ProgressoResponse(
            usuarioId, u.getNome(), cds.size(), aprovadas,
            creditosConcluidos, totalCreditos,
            creditosOptativosConcluidos, totalCreditosOptativos,
            percentual, semestresResp
        );
    }

    public void atualizarStatus(Long usuarioId, Long disciplinaId, ProgressoRequest req) {
        ProgressoAluno p = progressoRepo
            .findByUsuarioIdAndDisciplinaId(usuarioId, disciplinaId)
            .orElseGet(() -> {
                ProgressoAluno novo = new ProgressoAluno();
                novo.setUsuario(usuarioRepo.findById(usuarioId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado")));
                novo.setDisciplina(disciplinaRepo.findById(disciplinaId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Disciplina não encontrada")));
                return novo;
            });
        p.setStatus(req.getStatus());
        progressoRepo.save(p);
    }
}
