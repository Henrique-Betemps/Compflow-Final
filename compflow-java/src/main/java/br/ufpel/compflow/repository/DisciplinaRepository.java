package br.ufpel.compflow.repository;

import br.ufpel.compflow.entity.Disciplina;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface DisciplinaRepository extends JpaRepository<Disciplina, Long> {

    List<Disciplina> findByNomeContainingIgnoreCase(String nome);

    boolean existsByCodigo(String codigo);

    // Traz todas as disciplinas JÁ com os cursos delas numa única consulta
    // (LEFT JOIN FETCH), em vez de deixar o Hibernate carregar a coleção
    // "cursos" sob demanda depois — isso evitaria uma query extra POR
    // disciplina (N+1), o que fica bem lento em bancos remotos como o Aiven.
    @Query("SELECT DISTINCT d FROM Disciplina d LEFT JOIN FETCH d.cursos")
    List<Disciplina> findAllComCursos();
}
