<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null) { 
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Minha Agenda</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Estilos baseados no seu Swing (Cards) */
        body { font-family: Arial, sans-serif; background-color: #f0f0f0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card-agendamento {
            background: white;
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .card-info h3 { margin: 0 0 5px 0; font-size: 1.1em; color: #333; }
        .card-info p { margin: 2px 0; color: #666; font-size: 0.9em; }
        .status { font-weight: bold; }
        .status-concluido { color: green; }
        .status-pendente { color: #0064c8; }
        
        .btn-group button {
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 5px;
            color: white;
        }
        .btn-info { background-color: #17a2b8; }
        .btn-edit { background-color: #ffc107; color: #000 !important; }
        .btn-concluir { background-color: #28a745; }
        
        /* Modal simples para InfoAgendamento */
        .modal { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); }
        .modal-content { background: white; width: 400px; padding: 20px; margin: 100px auto; border-radius: 8px; }
    </style>
</head>
<body>

<div class="container">
    <a href="home.jsp" style="text-decoration: none; color: #007bff; font-weight: bold;">
        <i class="fas fa-arrow-left"></i> Voltar
    </a>
    <h2><i class="fas fa-calendar-check"></i> Minha Agenda</h2>
    
    <div id="loading">Carregando agendamentos...</div>
    <div id="listaAgendamentos"></div>
</div>

<div id="modalInfo" class="modal">
    <div class="modal-content">
        <h3>Detalhes do Agendamento</h3>
        <div id="modalBody"></div>
        <button onclick="$('#modalInfo').hide()" style="margin-top:15px; padding: 8px; width: 100%;">Fechar</button>
    </div>
</div>

<script>
    const usuarioLogadoId = <%= usuario.getId() %>;
    let funcionarioId = null;

    $(document).ready(function() {
        // 1. Primeiro busca o ID do funcionário vinculado ao usuário logado
        $.ajax({
            url: '<%= request.getContextPath() %>/FuncionarioController',
            data: { action: 'getByUserId', usuarioId: usuarioLogadoId },
            type: 'GET',
            success: function(func) {
                funcionarioId = func.id;
                carregarAgenda();
            },
            error: function() {
                $('#loading').html('<p style="color:red">Erro: Funcionário não encontrado para este usuário.</p>');
            }
        });
    });

    function carregarAgenda() {
        // 2. Com o ID do funcionário, busca os agendamentos
        $.ajax({
            url: '<%= request.getContextPath() %>/AgendamentoController',
            data: { action: 'getByFuncionarioId', funcionarioId: funcionarioId },
            type: 'GET',
            dataType: 'json',
            success: function(lista) {
                $('#loading').hide();
                const $container = $('#listaAgendamentos');
                $container.empty();

                if (lista.length === 0) {
                    $container.html('<p>Você não possui agendamentos futuros.</p>');
                    return;
                }

                $.each(lista, function(i, ag) {
                    // Formatação de data (simples)
                    let dataObj = new Date(ag.dataHora || ag.dataAgendamento); // Ajuste conforme seu JSON
                    let dataFormatada = dataObj.toLocaleString('pt-BR');

                    let statusClass = (ag.status === 'CONCLUÍDO') ? 'status-concluido' : 'status-pendente';
                    
                    let botoes = `<button class="btn-info" onclick='verDetalhes(${JSON.stringify(ag)})'>Info</button>`;
                    
                    // Só mostra botão de concluir/editar se não estiver concluído
                    if (ag.status !== 'CONCLUÍDO' && ag.status !== 'CANCELADO') {
                        botoes += `<button class="btn-concluir" onclick="mudarStatus(${ag.id}, 'CONCLUÍDO')">Concluir</button>`;
                    }

                    let html = `
                        <div class="card-agendamento">
                            <div class="card-info">
                                <h3>${ag.servico.descricao} para ${ag.pet.nome}</h3>
                                <p><strong>Data:</strong> ${dataFormatada}</p>
                                <p><strong>Tutor:</strong> ${ag.pet.tutor ? ag.pet.tutor.nome : 'N/A'}</p>
                                <p class="status ${statusClass}">Status: ${ag.status}</p>
                            </div>
                            <div class="btn-group">
                                ${botoes}
                            </div>
                        </div>
                    `;
                    $container.append(html);
                });
            },
            error: function(xhr) {
                $('#loading').html('Erro ao carregar agenda: ' + xhr.status);
            }
        });
    }

    // Função equivalente ao InfoAgendamento.java
    window.verDetalhes = function(ag) {
        let pet = ag.pet;
        let html = `
            <p><strong>Raça:</strong> ${pet.raca}</p>
            <p><strong>Peso:</strong> ${pet.peso} kg</p>
            <p><strong>Tutor:</strong> ${pet.tutor ? pet.tutor.nome : 'N/A'}</p>
            <p><strong>Telefone:</strong> ${pet.tutor ? pet.tutor.telefone : 'N/A'}</p>
            <hr>
            <p><strong>Observações:</strong><br>${pet.obs || 'Nenhuma'}</p>
            <p><strong>Ocorrências:</strong><br>${pet.ocorrencias || 'Nenhuma'}</p>
        `;
        $('#modalBody').html(html);
        $('#modalInfo').show();
    };

    window.mudarStatus = function(id, novoStatus) {
        if(!confirm("Deseja marcar este agendamento como " + novoStatus + "?")) return;

        $.ajax({
            url: '<%= request.getContextPath() %>/AgendamentoController?action=updateStatus',
            type: 'PUT',
            contentType: 'application/json',
            data: JSON.stringify({ id: id, novoStatus: novoStatus }),
            success: function() {
                alert('Status atualizado!');
                carregarAgenda();
            },
            error: function() {
                alert('Erro ao atualizar status.');
            }
        });
    };
</script>
</body>
</html>