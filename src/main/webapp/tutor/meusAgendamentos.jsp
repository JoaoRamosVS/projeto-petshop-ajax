<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || usuario.getPerfil().getId() != 2) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Tutor";
    Integer usuarioId = usuario.getId();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1100px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #007bff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        .user-info {
            text-align: right;
            margin-bottom: 20px;
            font-size: 1.1em;
            color: #6c757d;
        }
        .table-responsive {
            margin-top: 20px;
            overflow-x: auto;
        }
        #tabelaAgendamentos {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        #tabelaAgendamentos thead th {
            background-color: #007bff;
            color: white;
            padding: 12px 15px;
            border: 1px solid #0056b3;
        }
        #tabelaAgendamentos tbody td {
            padding: 10px 15px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
        }
        #tabelaAgendamentos tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        .action-button {
            padding: 5px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 5px;
            color: white;
            transition: opacity 0.3s;
        }
        .action-button:hover {
            opacity: 0.8;
        }
        .btn-cancel { 
            background-color: #dc3545; 
            font-weight: bold;
        }
        
        .btn-new-agenda {
            background-color: #28aa9a;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.6em;
            transition: background-color 0.3s;
        }
        .btn-new-agenda:hover {
            background-color: #218579;
        }
        
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }
        
        .alert { 
            padding: 15px; 
            margin-bottom: 20px; 
            border: 1px solid transparent;
            border-radius: 4px;
            text-align: center;
            font-weight: bold;
        }
        .alert-error {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-PENDENTE { background-color: #ffc107; color: #333; }
        .status-AGENDADO { background-color: #28a745; color: white; }
        .status-CANCELADO { background-color: #dc3545; color: white; }
        .status-CONCLUIDO { background-color: #007bff; color: white; }
    </style>
</head>
<body>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/tutor/home.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    
    <h1>
        Minha Agenda de Serviços
        <a href="<%= request.getContextPath() %>/tutor/agendamentoServico.jsp" class="btn-new-agenda">
            <i class="fas fa-calendar-plus"></i> Novo Agendamento
        </a>
    </h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-spinner fa-spin"></i> Carregando seus agendamentos...
    </div>
    
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <div class="table-responsive">
        <table id="tabelaAgendamentos">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Data e Hora</th>
                    <th>Pet</th>
                    <th>Serviço</th>
                    <th>Profissional</th>
                    <th>Status</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const currentUsuarioId = '<%= usuarioId %>';

    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 7000);
        }

        function formatDateTime(dateTimeString) {
            if (!dateTimeString) return 'N/A';
            
            try {
                const date = new Date(dateTimeString);

                if (isNaN(date.getTime())) {
                    const cleanString = dateTimeString.replace(/[\u202F]/g, ' '); 
                    const cleanedDate = new Date(cleanString);
                    if (isNaN(cleanedDate.getTime())) {
                        return dateTimeString; 
                    }
                    date = cleanedDate;
                }
                
                const dateFormatter = new Intl.DateTimeFormat('pt-BR', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false 
                });

                return dateFormatter.format(date).replace(',', ''); 

            } catch(e) {
                console.error("Erro de formatação de data:", e);
                return dateTimeString;
            }
        }
        
        function carregarMeusAgendamentos() {
            $loadingMessage.show();
            $statusMessage.hide();
            
            $.ajax({
                url: contextPath + '/AgendamentoController', 
                data: { action: 'getByUsuarioId', usuarioId: currentUsuarioId },
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var tabelaBody = $('#tabelaAgendamentos tbody');
                    tabelaBody.empty();
                    
                    if (data.length > 0) {
                        data.sort((a, b) => new Date(a.dataHora) - new Date(b.dataHora));

                        $.each(data, function(index, agendamento) {
                            const dataHoraFormatada = formatDateTime(agendamento.dataAgendamento);
                            const profissional = agendamento.funcionario ? agendamento.funcionario.nome : 'A Designar';
                            const status = agendamento.status || 'N/A';
                            
                            const podeCancelar = status === 'PENDENTE' || status === 'AGENDADO';
                            
                            let acoesHtml = '';
                            if (podeCancelar) {
                                acoesHtml = '<button class="action-button btn-cancel" title="Cancelar Agendamento" data-id="' + agendamento.id + '">' + 
                                            '<i class="fas fa-times"></i> Cancelar' +
                                            '</button>';
                            } else {
                                acoesHtml = 'N/A';
                            }

                            var row = '<tr>' +
                                '<td>' + agendamento.id + '</td>' +
                                '<td>' + dataHoraFormatada + '</td>' +
                                '<td>' + (agendamento.pet ? agendamento.pet.nome : 'N/A') + '</td>' +
                                '<td>' + (agendamento.servico ? agendamento.servico.descricao : 'N/A') + '</td>' +
                                '<td>' + profissional + '</td>' +
                                '<td><span class="status-badge status-' + status + '">' + status + '</span></td>' +
                                '<td>' + acoesHtml + '</td>' +
                                '</tr>';
                            tabelaBody.append(row);
                        });
                    } else {
                        tabelaBody.append('<tr><td colspan="7" style="text-align: center;">Nenhum agendamento encontrado na sua agenda.</td></tr>');
                    }
                },
                error: function(xhr, status, error) {
                    let msg = "Erro ao carregar sua agenda de serviços.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        msg += " Detalhes: " + (jsonResponse.error || xhr.statusText);
                    } catch (e) {
                        msg += " Status: " + xhr.status;
                    }
                    displayMessage('error', msg);
                },
                complete: function() {
                    $loadingMessage.hide();
                }
            });
        }
        
        $(document).on('click', '.btn-cancel', function() {
            const agendamentoId = $(this).data('id');
            
            if (confirm(`Tem certeza que deseja CANCELAR o Agendamento ID ${agendamentoId}?`)) {
                $.ajax({
                    url: contextPath + '/AgendamentoController?action=delete&id=' + agendamentoId,
                    type: 'DELETE',
                    dataType: 'json',
                    success: function(response) {
                        displayMessage('success', response.message);
                        carregarMeusAgendamentos(); 
                    },
                    error: function(xhr) {
                        let errorMsg = "Falha ao cancelar o agendamento.";
                        try {
                            const jsonResponse = JSON.parse(xhr.responseText);
                            errorMsg = jsonResponse.error || xhr.statusText;
                        } catch (e) {
                            errorMsg += " Status: " + xhr.status;
                        }
                        displayMessage('error', errorMsg);
                    }
                });
            }
        });

        carregarMeusAgendamentos();
    });
</script>

</body>
</html>