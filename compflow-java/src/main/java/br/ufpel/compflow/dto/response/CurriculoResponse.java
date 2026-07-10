package br.ufpel.compflow.dto.response;

import lombok.*;
import java.util.List;

@Getter @Setter @AllArgsConstructor
public class CurriculoResponse {
    private Long id;
    private String nome;
    private Long cursoId;
    private String nomeCurso;
    private List<SemestreResponse> semestres;

    @Getter @Setter @AllArgsConstructor
    public static class SemestreResponse {
        private Integer semestre;
        private List<DisciplinaResponse> disciplinas;
    }
}
