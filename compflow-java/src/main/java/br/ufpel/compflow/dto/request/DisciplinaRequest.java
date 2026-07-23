package br.ufpel.compflow.dto.request;
import jakarta.validation.constraints.*;
import lombok.*;
import java.util.List;
@Getter @Setter
public class DisciplinaRequest {
    @NotBlank
    private String codigo;
    @NotBlank
    private String nome;
    @NotNull @Min(1)
    private Integer creditos;
    // Cursos "donos" da disciplina. Pode ter mais de um (ex: disciplina
    // comum a Ciência da Computação e Engenharia), ou nenhum (lista vazia
    // ou null) se ela não for vinculada a um curso específico.
    private List<Long> cursoIds;
    @NotNull
    private Boolean optativa;
}
