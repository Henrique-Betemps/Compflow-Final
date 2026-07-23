package br.ufpel.compflow.entity;
 
import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;
 
@Entity
@Table(name = "disciplinas")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Disciplina {
 
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
 
    @Column(nullable = false, unique = true, length = 20)
    private String codigo;
 
    @Column(nullable = false, length = 150)
    private String nome;
 
    @Column(nullable = false)
    private Integer creditos;
 
    // Cursos "donos" da disciplina. Uma disciplina pode pertencer a mais de
    // um curso ao mesmo tempo (ex: CÁLCULO 1 sendo própria de Ciência da
    // Computação E de Engenharia de Computação). Usado para decidir se,
    // dentro de um currículo, ela é INTERNA (o curso do currículo está
    // nessa lista) ou EXTERNA (não está). Fica vazia para disciplinas que
    // não pertencem oficialmente a nenhum curso específico.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "disciplina_cursos",
        joinColumns = @JoinColumn(name = "disciplina_id"),
        inverseJoinColumns = @JoinColumn(name = "curso_id")
    )
    private List<Curso> cursos = new ArrayList<>();
 
    // Optativa é uma categoria à parte: independe de quais cursos são donos
    // da disciplina, e não entra no cálculo de créditos obrigatórios.
    @Column(nullable = false)
    private boolean optativa = false;
}
