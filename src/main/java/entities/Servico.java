package entities;

import java.math.BigDecimal;

public class Servico {
    private Integer id;
    private String descricao;
    private BigDecimal valor;

    public Servico() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public BigDecimal getValor() { return valor; }
    public void setValor(BigDecimal valor) { this.valor = valor; }

    @Override
    public String toString() {
        return this.getDescricao();
    }
}