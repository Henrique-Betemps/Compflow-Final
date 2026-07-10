package br.ufpel.compflow.service;

import br.ufpel.compflow.dto.request.CriarUsuarioRequest;
import br.ufpel.compflow.dto.request.LoginRequest;
import br.ufpel.compflow.dto.response.UsuarioResponse;
import br.ufpel.compflow.entity.Curriculo;
import br.ufpel.compflow.entity.Curso;
import br.ufpel.compflow.entity.Usuario;
import br.ufpel.compflow.repository.CurriculoRepository;
import br.ufpel.compflow.repository.CursoRepository;
import br.ufpel.compflow.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository    usuarioRepo;
    private final CursoRepository      cursoRepo;
    private final CurriculoRepository  curriculoRepo;

    public List<UsuarioResponse> listarTodos() {
        return usuarioRepo.findAll().stream()
            .map(UsuarioResponse::from).toList();
    }

    public UsuarioResponse buscarPorId(Long id) {
        return UsuarioResponse.from(getOuErro(id));
    }

    public UsuarioResponse registrar(CriarUsuarioRequest req) {
        if (usuarioRepo.existsByEmail(req.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "E-mail já cadastrado");
        }
        Usuario u = new Usuario();
        u.setNome(req.getNome());
        u.setEmail(req.getEmail());
        u.setSenhaHash(req.getSenha()); // TODO: BCrypt
        u.setRole(Usuario.Role.ALUNO);

        if (req.getCursoId() != null) {
            Curso curso = cursoRepo.findById(req.getCursoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Curso não encontrado"));
            u.setCurso(curso);

            List<Curriculo> curriculosDoCurso = curriculoRepo.findByCursoId(curso.getId());

            if (req.getCurriculoId() != null) {
                // Aluno escolheu explicitamente — valida que pertence ao curso
                Curriculo escolhido = curriculosDoCurso.stream()
                    .filter(c -> c.getId().equals(req.getCurriculoId()))
                    .findFirst()
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Currículo não pertence ao curso selecionado"));
                u.setCurriculo(escolhido);
            } else if (curriculosDoCurso.size() == 1) {
                // Só existe um currículo possível: vincula automaticamente
                u.setCurriculo(curriculosDoCurso.get(0));
            }
            // Se houver 2+ currículos e nenhum foi escolhido, fica sem
            // (admin define depois em admin-alunos.html)
        }
        return UsuarioResponse.from(usuarioRepo.save(u));
    }

    public UsuarioResponse login(LoginRequest req) {
        Usuario u = usuarioRepo.findByEmail(req.getEmail())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenciais inválidas"));
        // TODO: BCrypt.matches
        if (!u.getSenhaHash().equals(req.getSenha())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenciais inválidas");
        }
        return UsuarioResponse.from(u);
    }

    public UsuarioResponse atualizarNome(Long id, String novoNome) {
        Usuario u = getOuErro(id);
        u.setNome(novoNome);
        return UsuarioResponse.from(usuarioRepo.save(u));
    }

    // Admin escolhe/troca qual currículo aparece para o aluno
    public UsuarioResponse atualizarCurriculo(Long usuarioId, Long curriculoId) {
        Usuario u = getOuErro(usuarioId);

        if (curriculoId == null) {
            u.setCurriculo(null);
        } else {
            Curriculo c = curriculoRepo.findById(curriculoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Currículo não encontrado"));
            u.setCurriculo(c);
        }
        return UsuarioResponse.from(usuarioRepo.save(u));
    }

    private Usuario getOuErro(Long id) {
        return usuarioRepo.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));
    }
}
