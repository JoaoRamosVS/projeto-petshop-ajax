<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
    String agendamentoIdParam = request.getParameter("id");

    if (usuarioLogado == null || usuarioLogado.getPerfil() == null || (usuarioLogado.getPerfil().getId() != 3 && usuarioLogado.getPerfil().getId() != 1)) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    if (agendamentoIdParam == null || agendamentoIdParam.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/funcionario/minhaAgenda.jsp");
        return;
    }

    String emailUsuario = usuarioLogado.getEmail() != null ? usuarioLogado.getEmail() : "Funcionário";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 700px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #007bff;
            text-align: center;
            margin-bottom: 25px;
            font-size: 1.8em;
        }
        .user-info {
            text-align: right;
            margin-bottom: 20px;
            font-size: 1.1em;
            color: #6c757d;
        }
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }

        .form-section {
            border: 1px solid #dee2e6;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 6px;
        }
        .form-section h3 {
            color: #007bff;
            margin-top: 0;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .row {
            display: flex;
            gap: 20px;
            margin-bottom: 10px;
        }
        .row > div {
            flex: 1;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #495057;
        }
        input[type="text"], input[type="number"], select, textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
            background-color: #fff;
        }
        textarea {
            resize: vertical;
        }
        input[readonly] {
            background-color: #f1f1f1;
            font-weight: bold;
        }
        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1.1em;
            margin-top: 10px;
            transition: background-color 0.3s;
        }
        button[type="submit"]:hover {
            background-color: #0056b3;
        }
        .alert { 
            padding: 15px; 
            margin-bottom: 20px; 
            border: 1px solid transparent;
            border-radius: 4px;
            text-align: center;
            font-weight: bold;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .alert-error {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/funcionario/minhaAgenda.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar à Minha Agenda
    </a>
    
    <h1>Edição de Agendamento (ID: <span id="agendamentoIdDisplay"><%= agendamentoIdParam %></span>)</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="edicaoAgendamentoForm" style="display:none;">
        
        <input type="hidden" id="agendamentoId" value="<%= agendamentoIdParam %>">
        <input type="hidden" id="petIdHidden"> 

        <div class="form-section">
            <h3><i class="fas fa-file-invoice"></i> Detalhes da Reserva</h3>
            <div class="row">
                <div>
                    <label for="petNome">Pet:</label>
                    <input type="text" id="petNome" readonly>
                </div>
                <div>
                    <label for="servicoNome">Serviço Agendado:</label>
                    <input type="text" id="servicoNome" readonly>
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="tutorNome">Tutor Responsável:</label>
                    <input type="text" id="tutorNome" readonly>
                </div>
                <div>
                    <label for="dataAgendamentoFixa">Data e Hora:</label>
                    <input type="text" id="dataAgendamentoFixa" readonly>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3><i class="fas fa-paw"></i> Dados do Pet (Atualização de Serviço)</h3>
            <div class="row">
                <div>
                    <label for="peso">Peso (kg):</label>
                    <input type="number" id="peso" step="0.01" required placeholder="Ex: 5.50">
                </div>
                <div style="flex: 1;">
                    </div>
            </div>
            <div>
                <label for="obs">Observações do Pet (Registro do Tutor):</label>
                <textarea id="obs"></textarea>
            </div>
            <div>
                <label for="ocorrencias">Ocorrências (Histórico/Problemas no Serviço):</label>
                <textarea id="ocorrencias"></textarea>
            </div>
        </div>
        
        <div class="form-section">
            <h3><i class="fas fa-wrench"></i> Ajustes de Status</h3>
            <div class="row">
                <div>
                    <label for="statusNovo">Novo Status:</label>
                    <select id="statusNovo" required>
                        <option value="AGENDADO">AGENDADO</option>
                        <option value="CONCLUIDO">CONCLUÍDO</option>
                        <option value="CANCELADO">CANCELADO</option>
                    </select>
                </div>
                <div style="flex: 1;">
                    </div>
            </div>
        </div>
        
        <button type="submit"><i class="fas fa-sync-alt"></i> Salvar Alterações</button>
    </form>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const agendamentoId = $('#agendamentoId').val();

    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#edicaoAgendamentoForm');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 7000);
        }

        function formatDateTime(dateTimeString) {
            if (!dateTimeString) return 'N/A';
            try {
                const date = new Date(dateTimeString);
                const dateFormatter = new Intl.DateTimeFormat('pt-BR', {
                    year: 'numeric', month: '2-digit', day: '2-digit',
                    hour: '2-digit', minute: '2-digit', hour12: false
                });
                return dateFormatter.format(date).replace(',', ''); 
            } catch(e) {
                return dateTimeString;
            }
        }
        
        function carregarDadosAgendamento() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: contextPath + '/AgendamentoController', 
                    data: { action: 'getById', id: agendamentoId },
                    type: 'GET',
                    dataType: 'json',
                    success: function(agendamento) {
                        if (agendamento) {
                            resolve(agendamento);
                        } else {
                            reject(new Error('Agendamento não encontrado.'));
                        }
                    },
                    error: function(xhr) {
                        reject(new Error('Falha ao buscar dados do Agendamento. Status: ' + xhr.status));
                    }
                });
            });
        }

        function inicializarTela() {
            $loadingMessage.show();
            $form.hide();
            
            carregarDadosAgendamento()
                .then((agendamento) => {
                    preencherFormulario(agendamento);
                    $form.show();
                })
                .catch(error => {
                    console.error("Erro na inicialização:", error);
                    displayMessage('error', 'Falha ao carregar tela: ' + error.message);
                })
                .finally(() => {
                    $loadingMessage.hide();
                });
        }

        function preencherFormulario(agendamento) {
            
            $('#petNome').val(agendamento.pet ? agendamento.pet.nome : 'N/A');
            $('#servicoNome').val(agendamento.servico ? agendamento.servico.descricao : 'N/A'); 
            $('#tutorNome').val(agendamento.pet && agendamento.pet.tutor ? agendamento.pet.tutor.nome : 'N/A');
            
            $('#dataAgendamentoFixa').val(formatDateTime(agendamento.dataAgendamento));

            $('#petIdHidden').val(agendamento.pet ? agendamento.pet.id : '');

            $('#peso').val(agendamento.pet && agendamento.pet.peso ? parseFloat(agendamento.pet.peso).toFixed(2) : '0.00'); 
            $('#obs').val(agendamento.pet ? agendamento.pet.obs : '');
            $('#ocorrencias').val(agendamento.pet ? agendamento.pet.ocorrencias : '');

            $('#statusNovo').val(agendamento.status);
            
            if(agendamento.status === 'CONCLUIDO' || agendamento.status === 'CANCELADO') {
                $('#statusNovo').attr('disabled', 'disabled');
                $('#peso, #obs, #ocorrencias').attr('readonly', 'readonly');
            }
        }

        $form.submit(function(e) {
            e.preventDefault();
            $statusMessage.hide(); 
            
            if (!confirm("Confirmar atualização do Pet e Status do Agendamento?")) {
                return;
            }

            var dadosAtualizacao = {
                agendamentoId: parseInt(agendamentoId),
                
                petId: parseInt($('#petIdHidden').val()),
                peso: $('#peso').val(), 
                obs: $('#obs').val(),
                ocorrencias: $('#ocorrencias').val(),
                status: $('#statusNovo').val()
            };
            
            if (isNaN(dadosAtualizacao.petId) || dadosAtualizacao.petId <= 0) {
                displayMessage('error', 'O ID do Pet é inválido. Não é possível salvar.');
                return;
            }

            $.ajax({
                url: contextPath + '/AgendamentoController?action=updateFull', 
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(dadosAtualizacao),
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    setTimeout(() => {
                        window.location.href = 'minhaAgenda.jsp'; 
                    }, 1000);
                },
                error: function(xhr) {
                    let errorMsg = "Ocorreu um erro ao salvar as alterações.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || errorMsg;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    displayMessage('error', errorMsg);
                }
            });
        });

        inicializarTela();
    });
</script>

</body>
</html>