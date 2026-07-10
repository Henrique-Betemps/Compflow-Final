package br.ufpel.compflow.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter
public class CriarUsuarioRequest {
    @NotBlank
    private String nome;

    @NotBlank @Email
    private String email;

    @NotBlank @Size(min = 6)
    private String senha;

    private Long cursoId;

    // Opcional: só é enviado pelo front quando o curso tem
    // mais de um currículo e o aluno precisou escolher um.
    private Long curriculoId;
}
