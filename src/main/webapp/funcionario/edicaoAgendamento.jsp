<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null || usuario.getPerfil().getId() != 3) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Agendamento</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f9; display: flex; justify-content: center; padding-top: 50px; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 500px; box-sizing: border-box; }
        h2 { margin-top: 0; color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        input[type="text"], textarea, select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        textarea { height: 100px; resize: vertical; }
        input[readonly] { background-color: #e9ecef; }
        .btn-group { display: flex; justify-content: space-between; margin-top: 20px; }
        button { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .btn-save { background-color: #28a745; color: white; }
        .btn-save:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; color: white; text-decoration: none; display: inline-block; text-align: center; }
        .btn-cancel:hover { background-color: #5a6268; }
    </style>
</head>
<body>

<div class="container">
    <h2>Editar Agendamento</h2>
    <form id="formEdicao">
        <input type="hidden" id="agendamentoId">
        
        <div class="form-group">
            <label>Tutor / Pet</label>
            <input type="text" id="tutorPet" readonly>
        </div>

        <div class="form-group">
            <label>Serviço</label>
            <input type="text" id="servico" readonly>
        </div>

        <div class="form-group">
            <label>Data</label>
            <input type="text" id="dataHora" readonly>
        </div>

        <div class="form-group">
            <label for="status">Status</label>
            <select id="status">
                <option value="AGENDADO">AGENDADO</option>
                <option value="EM ANDAMENTO">EM ANDAMENTO</option>
                <option value="CONCLUÍDO">CONCLUÍDO</option>
                <option value="CANCELADO">CANCELADO</option>
            </select>
        </div>

        <div class="form-group">
            <label for="obs">Observações</label>
            <textarea id="obs"></textarea>
        </div>

        <div class="btn-group">
            <a href="minhaAgenda.jsp" class="btn-cancel">Cancelar</a>
            <button type="button" class="btn-save" onclick="salvarAlteracoes()">Salvar</button>
        </div>
    </form>
</div>

<script>
    // Captura o ID da URL (ex: edicaoAgendamento.jsp?id=5)
    const urlParams = new URLSearchParams(window.location.search);
    const id = urlParams.get('id');

    async function carregarDados() {
        if (!id) {
            alert("ID do agendamento não fornecido.");
            window.location.href = 'minhaAgenda.jsp';
            return;
        }

        try {
            const response = await fetch('../AgendamentoController?action=getById&id=' + id);
            if (response.ok) {
                const ag = await response.json();
                
                document.getElementById('agendamentoId').value = ag.id;
                document.getElementById('tutorPet').value = ag.pet.tutor.nome + ' - ' + ag.pet.nome;
                document.getElementById('servico').value = ag.servico.descricao;
                document.getElementById('dataHora').value = new Date(ag.dataAgendamento).toLocaleString('pt-BR');
                document.getElementById('status').value = ag.status;
                document.getElementById('obs').value = ag.obs || ''; // Trata null como vazio
                
            } else {
                alert("Erro ao carregar dados.");
            }
        } catch (error) {
            console.error(error);
            alert("Erro de conexão.");
        }
    }

    async function salvarAlteracoes() {
        const dados = {
            id: document.getElementById('agendamentoId').value,
            status: document.getElementById('status').value,
            obs: document.getElementById('obs').value
        };

        try {
            const response = await fetch('../AgendamentoController?action=updateFull', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(dados)
            });

            if (response.ok) {
                alert("Agendamento atualizado com sucesso!");
                window.location.href = 'minhaAgenda.jsp';
            } else {
                alert("Erro ao atualizar agendamento.");
            }
        } catch (error) {
            console.error(error);
            alert("Erro de conexão.");
        }
    }

    window.onload = carregarDados;
</script>

</body>
</html>