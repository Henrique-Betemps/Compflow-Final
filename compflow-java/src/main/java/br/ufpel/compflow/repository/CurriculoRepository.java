package br.ufpel.compflow.repository;

import br.ufpel.compflow.entity.Curriculo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface CurriculoRepository extends JpaRepository<Curriculo, Long> {

    List<Curriculo> findByCursoId(Long cursoId);

    // Traz todos os currículos já com o curso vinculado numa única consulta,
    // evitando uma query extra por currículo (o mesmo padrão de N+1 corrigido
    // em Disciplina/CurriculoDisciplina).
    @Query("SELECT DISTINCT c FROM Curriculo c LEFT JOIN FETCH c.curso")
    List<Curriculo> findAllComCurso();
}
