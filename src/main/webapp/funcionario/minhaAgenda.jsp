<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setHeader("Pragma", "no-cache"); 
    response.setDateHeader("Expires", 0);
%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || (usuario.getPerfil().getId() != 3)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Funcionário";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background-color: #e9ecef; 
            padding: 20px; 
            margin: 0;
        }
        .main-container { 
            max-width: 800px; 
            margin: 0 auto; 
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h2 { 
            color: #28a745; 
            margin-top: 0;
            margin-bottom: 25px;
            text-align: center;
        }
        
        .card-agendamento {
            background: #f8f9fa; 
            border: 1px solid #dee2e6;
            border-left: 5px solid #28a745; 
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            transition: box-shadow 0.3s;
        }
        .card-agendamento:hover {
             box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .card-info h3 { 
            margin: 0 0 5px 0; 
            font-size: 1.2em; 
            color: #343a40; 
        }
        .card-info p { 
            margin: 2px 0; 
            color: #6c757d; 
            font-size: 0.9em; 
        }
        
        .status { font-weight: bold; }
        .status-concluido { color: #28a745; } 
        .status-pendente { color: #ffc107; }
        
        .btn-group {
            display: flex; 
            gap: 8px; 
        }
        .btn-group button {
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            color: white;
            font-weight: bold;
            transition: background-color 0.2s;
        }
        .btn-info { 
            background-color: #17a2b8; 
        }
        .btn-info:hover { background-color: #138496; }
        
        .btn-concluir { 
            background-color: #28a745; 
        }
        .btn-concluir:hover { background-color: #1e7e34; }

        .btn-cancelar { 
            background-color: #dc3545; 
        }
        .btn-cancelar:hover { background-color: #c82333; }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .back-link:hover {
            color: #0056b3;
        }
        
        .modal { 
            display: none; position: fixed; z-index: 10; left: 0; top: 0; 
            width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4); 
        }
        .modal-content { 
            background: white; width: 90%; max-width: 450px; padding: 25px; 
            margin: 10% auto; border-radius: 8px; box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .modal-content h3 { color: #343a40; margin-top: 0; }
    </style>
</head>
<body>

<div class="main-container">
    <a href="home.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    <h2><i class="fas fa-calendar-check"></i> Minha Agenda de Agendamentos</h2>
    
    <div id="loading" style="text-align: center; color: #6c757d;">Carregando agendamentos...</div>
    <div id="listaAgendamentos"></div>
</div>

<div id="modalInfo" class="modal">
    <div class="modal-content">
        <h3>Detalhes do Agendamento</h3>
        <div id="modalBody"></div>
        <button onclick="$('#modalInfo').hide()" class="btn-info" style="margin-top:20px;">Fechar</button>
    </div>
</div>

<script>
    const usuarioLogadoId = <%= usuario.getId() %>;
    let funcionarioId = null;

    $(document).ready(function() {
        $.ajax({
            url: '<%= request.getContextPath() %>/FuncionarioController',
            data: { action: 'getByUserId', usuarioId: usuarioLogadoId },
            type: 'GET',
            dataType: 'json',
            success: function(func) {
                if (func && func.id) {
                    funcionarioId = func.id;
                    carregarAgenda();
                } else {
                     $('#loading').html('<p style="color:red">Erro: Funcionário não encontrado ou ID inválido.</p>');
                }
            },
            error: function() {
                $('#loading').html('<p style="color:red">Erro ao buscar dados do funcionário.</p>');
            }
        });
    });

    function carregarAgenda() {
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
                    $container.html('<p style="text-align: center; color: #6c757d;">Você não possui agendamentos futuros.</p>');
                    return;
                }

                $.each(lista, function(i, ag) {
                    let dataObj = new Date(ag.dataHora || ag.dataAgendamento); 
                    let dataFormatada = dataObj.toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' }); 

                    let statusClass = (ag.status === 'CONCLUIDO') ? 'status-concluido' : 'status-pendente';
                    
                    let botoes = '<button class="btn-info" onclick=\'verDetalhes(' + JSON.stringify(ag) + ')\'>Info</button>';
                    
                    if (ag.status === 'AGENDADO') {
                        botoes += '<button class="btn-cancelar" onclick="mudarStatus(' + ag.id + ', \'CANCELADO\')">Cancelar</button>';
                        botoes += '<button class="btn-concluir" onclick="mudarStatus(' + ag.id + ', \'CONCLUIDO\')">Concluir</button>';
                    }

                    if (ag.status !== 'AGENDADO' && ag.status !== 'CONCLUIDO' && ag.status !== 'CANCELADO') {
                         botoes += '<button class="btn-concluir" onclick="mudarStatus(' + ag.id + ', \'CONCLUIDO\')">Concluir</button>';
                    }
                    
                    let html = '';
                    html += '<div class="card-agendamento">';
                    html += '    <div class="card-info">';
                    html += '        <h3>' + ag.servico.descricao + ' para ' + ag.pet.nome + '</h3>';
                    html += '        <p><strong>Data:</strong> ' + dataFormatada + '</p>';
                    html += '        <p><strong>Tutor:</strong> ' + (ag.pet && ag.pet.tutor ? ag.pet.tutor.nome : 'N/A') + '</p>';
                    html += '        <p class="status ' + statusClass + '">Status: ' + ag.status + '</p>';
                    html += '    </div>';
                    html += '    <div class="btn-group">';
                    html += botoes;
                    html += '    </div>';
                    html += '</div>';
                    
                    $container.append(html);
                });
            },
            error: function(xhr) {
                $('#loading').html('Erro ao carregar agenda: ' + xhr.status);
            }
        });
    }

    window.verDetalhes = function(ag) {
        let pet = ag.pet;
        
        let html = '';
        html += '<p><strong>Raça:</strong> ' + (pet.raca || 'N/A') + '</p>';
        html += '<p><strong>Peso:</strong> ' + (pet.peso || 'N/A') + ' kg</p>';
        html += '<p><strong>Tutor:</strong> ' + (pet.tutor && pet.tutor.nome ? pet.tutor.nome : 'N/A') + '</p>';
        html += '<p><strong>Telefone:</strong> ' + (pet.tutor && pet.tutor.telefone ? pet.tutor.telefone : 'N/A') + '</p>';
        html += '<hr>';
        html += '<p><strong>Observações:</strong><br>' + (pet.obs || 'Nenhuma') + '</p>';
        html += '<p><strong>Ocorrências:</strong><br>' + (pet.ocorrencias || 'Nenhuma') + '</p>';
        
        $('#modalBody').html(html);
        $('#modalInfo').show();
    };

    window.mudarStatus = function(id, novoStatus) {
        let msg = (novoStatus === 'CONCLUIDO') ? "Deseja marcar este agendamento como CONCLUÍDO?" : "Tem certeza que deseja CANCELAR este agendamento?";
        
        if(!confirm(msg)) return;

        $.ajax({
            url: '<%= request.getContextPath() %>/AgendamentoController?action=updateStatus',
            type: 'PUT',
            contentType: 'application/json',
            data: JSON.stringify({ id: id, novoStatus: novoStatus }),
            success: function() {
                alert('Status atualizado para ' + novoStatus + '!');
                carregarAgenda(); 
            },
            error: function(xhr) {
                let errorMsg = 'Erro ao atualizar status.';
                try {
                    errorMsg = JSON.parse(xhr.responseText).error || errorMsg;
                } catch(e) {}
                alert(errorMsg);
            }
        });
    };
</script>
</body>
</html>