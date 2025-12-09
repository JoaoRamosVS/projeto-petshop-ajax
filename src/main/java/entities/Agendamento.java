package entities;

import java.sql.Timestamp;

public class Agendamento {
    private Integer id;
    private Timestamp dataCriacao;
    private Timestamp dataAgendamento;
    private String descricao;
    private String obs;
    private String status;
    private Servico servico;
    private Usuario criador;
    private Pet pet;
    private Funcionario funcionario;

    public Agendamento() {
    }

    public Agendamento(Integer id, Timestamp dataCriacao, Timestamp dataAgendamento, String descricao, String obs, String status, Servico servico, Usuario criador, Pet pet, Funcionario funcionario) {
        this.id = id;
        this.dataCriacao = dataCriacao;
        this.dataAgendamento = dataAgendamento;
        this.descricao = descricao;
        this.obs = obs;
        this.status = status;
        this.servico = servico;
        this.criador = criador;
        this.pet = pet;
        this.funcionario = funcionario;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Timestamp getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(Timestamp dataCriacao) {
        this.dataCriacao = dataCriacao;
    }

    public Timestamp getDataAgendamento() {
        return dataAgendamento;
    }

    public void setDataAgendamento(Timestamp dataAgendamento) {
        this.dataAgendamento = dataAgendamento;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getObs() {
        return obs;
    }

    public void setObs(String obs) {
        this.obs = obs;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Servico getServico() {
        return servico;
    }

    public void setServico(Servico servico) {
        this.servico = servico;
    }

    public Usuario getCriador() {
        return criador;
    }

    public void setCriador(Usuario criador) {
        this.criador = criador;
    }

    public Pet getPet() {
        return pet;
    }

    public void setPet(Pet pet) {
        this.pet = pet;
    }

    public Funcionario getFuncionario() {
        return funcionario;
    }

    public void setFuncionario(Funcionario funcionario) {
        this.funcionario = funcionario;
    }
}