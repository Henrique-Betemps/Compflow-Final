package br.ufpel.compflow.repository;

import br.ufpel.compflow.entity.CurriculoDisciplina;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

public interface CurriculoDisciplinaRepository extends JpaRepository<CurriculoDisciplina, Long> {

    // Antes: método derivado simples (findByCurriculoIdOrderBySemestre) causava
    // N+1 queries, porque cada d.getCursos() acessado depois disparava uma
    // consulta extra ao banco (uma por disciplina). Localmente isso passava
    // despercebido (latência baixíssima); num banco remoto (Aiven, cross-region)
    // cada consulta extra soma ~150-300ms, deixando a tela muito lenta.
    //
    // Agora: uma única query já traz a disciplina E os cursos dela junto
    // (JOIN FETCH), evitando qualquer consulta extra depois.
    @Query("SELECT DISTINCT cd FROM CurriculoDisciplina cd " +
           "JOIN FETCH cd.disciplina d " +
           "LEFT JOIN FETCH d.cursos " +
           "WHERE cd.curriculo.id = :curriculoId " +
           "ORDER BY cd.semestre")
    List<CurriculoDisciplina> findByCurriculoIdOrderBySemestre(@Param("curriculoId") Long curriculoId);

    @Transactional
    void deleteByCurriculoId(Long curriculoId);
}
