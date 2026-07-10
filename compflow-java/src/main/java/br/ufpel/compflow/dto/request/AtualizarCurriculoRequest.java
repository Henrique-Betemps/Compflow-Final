package br.ufpel.compflow.dto.request;

import lombok.*;

@Getter @Setter
public class AtualizarCurriculoRequest {
    private Long curriculoId; // pode ser null para "remover" o vínculo
}
