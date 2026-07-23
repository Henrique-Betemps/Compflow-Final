package br.ufpel.compflow.dto.response;
import br.ufpel.compflow.entity.Curso;
import br.ufpel.compflow.entity.Disciplina;
import lombok.*;
import java.util.List;
import java.util.stream.Collectors;
@Getter @Setter @AllArgsConstructor
public class DisciplinaResponse {
    private Long id;
    private String codigo;
    private String nome;
    private Integer creditos;
    private List<Long> cursoIds;
    private List<String> cursoNomes;
    private boolean optativa;
    public static DisciplinaResponse from(Disciplina d) {
        List<Curso> cursos = d.getCursos();
        return new DisciplinaResponse(
            d.getId(), d.getCodigo(), d.getNome(), d.getCreditos(),
            cursos.stream().map(Curso::getId).collect(Collectors.toList()),
            cursos.stream().map(Curso::getNome).collect(Collectors.toList()),
            d.isOptativa()
        );
    }
}
