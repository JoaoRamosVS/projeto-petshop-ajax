<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Petshop - Agendamento de Serviço</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        /* Estilos baseados no design tutor/admin */
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 650px;
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

        /* Estilos do Formulário */
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
        input[type="date"], input[type="time"], select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
            background-color: #fff;
        }
        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #28a745; /* Verde para ação de criação */
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1.1em;
            margin-top: 10px;
            transition: background-color 0.3s;
        }
        button[type="submit"]:hover {
            background-color: #218838;
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

<%
    // =======================================================
    // PREVENÇÃO DE CACHE E SEGURANÇA
    // =======================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
    
    // 1. Verifica autenticação e perfil (Deve ser Tutor ID 2)
    if (usuarioLogado == null || usuarioLogado.getPerfil() == null || usuarioLogado.getPerfil().getId() != 2) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String emailUsuario = usuarioLogado.getEmail() != null ? usuarioLogado.getEmail() : "Tutor";
    // ID do usuário logado será usado para buscar o ID do Tutor
    Integer userId = usuarioLogado.getId(); 
%>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/tutor/home.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    
    <h1><i class="fas fa-calendar-check"></i> Agendar Serviço</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-spinner fa-spin"></i> Carregando dados necessários...
    </div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="agendamentoForm" style="display:none;">
        
        <input type="hidden" id="tutorIdHidden" value="">
        
        <div class="form-section">
            <h3><i class="fas fa-cut"></i> O quê e Para Quem?</h3>
            <div class="row">
                <div>
                    <label for="petId">Selecione o Pet:</label>
                    <select id="petId" required>
                        <option value="">-- Carregando Pets... --</option>
                    </select>
                </div>
                <div>
                    <label for="servicoId">Selecione o Serviço:</label>
                    <select id="servicoId" required>
                        <option value="">-- Carregando Serviços... --</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3><i class="fas fa-clock"></i> Quando?</h3>
            <div class="row">
                <div>
                    <label for="dtAgendamento">Data:</label>
                    <input type="date" id="dtAgendamento" required>
                </div>
                <div>
                    <label for="hrAgendamento">Hora:</label>
                    <input type="time" id="hrAgendamento" required>
                </div>
            </div>
        </div>
        
        <button type="submit"><i class="fas fa-plus-circle"></i> Confirmar Agendamento</button>
    </form>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const currentUserId = '<%= userId %>';
    
    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#agendamentoForm');
        const $petSelect = $('#petId');
        const $servicoSelect = $('#servicoId');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }
        
        // =================================================================
        // 1. FUNÇÕES DE CARREGAMENTO (ASINCRÔNO)
        // =================================================================
        
        function carregarServicos() {
            return $.ajax({
                url: contextPath + '/ServicoController', 
                data: { action: 'getAll' },
                type: 'GET',
                dataType: 'json'
            }).done(function(servicos) {
                $servicoSelect.empty().append('<option value="">-- Selecione o Serviço --</option>');
                if (servicos && servicos.length > 0) {
                    $.each(servicos, function(index, servico) {
                        $servicoSelect.append(
                            `<option value="${servico.id}">${servico.nome} (R$ ${servico.valor ? servico.valor.toFixed(2).replace('.', ',') : 'N/A'})</option>`
                        );
                    });
                } else {
                    $servicoSelect.append('<option value="" disabled>Nenhum serviço encontrado.</option>');
                }
            }).fail(function(xhr) {
                $servicoSelect.empty().append('<option value="" disabled>Erro ao carregar serviços.</option>');
                console.error("Erro ao carregar serviços:", xhr);
            });
        }
        
        function carregarPetsDoTutor(tutorId) {
            return $.ajax({
                url: contextPath + '/PetController', 
                data: { action: 'getByTutorId', tutorId: tutorId },
                type: 'GET',
                dataType: 'json'
            }).done(function(pets) {
                $petSelect.empty().append('<option value="">-- Selecione o Pet --</option>');
                if (pets && pets.length > 0) {
                    $.each(pets, function(index, pet) {
                        $petSelect.append(
                            `<option value="${pet.id}">${pet.nome} (${pet.raca})</option>`
                        );
                    });
                } else {
                    $petSelect.append('<option value="" disabled>Você não tem pets cadastrados.</option>');
                    displayMessage('error', 'Você precisa cadastrar um pet antes de agendar um serviço.');
                }
            }).fail(function(xhr) {
                $petSelect.empty().append('<option value="" disabled>Erro ao carregar seus pets.</option>');
                console.error("Erro ao carregar pets:", xhr);
            });
        }
        
        function inicializarAgendamento() {
            $loadingMessage.show();
            $form.hide();
            
            // Passo 1: Obter o ID do Tutor
            $.ajax({
                url: contextPath + '/TutorController', 
                data: { action: 'getByUserId', usuarioId: currentUserId },
                type: 'GET',
                dataType: 'json'
            }).done(function(tutor) {
                if (tutor && tutor.id) {
                    const tutorId = tutor.id;
                    $('#tutorIdHidden').val(tutorId);
                    
                    // Passo 2: Carregar Pets e Serviços simultaneamente
                    $.when(carregarPetsDoTutor(tutorId), carregarServicos())
                        .done(function() {
                            $form.show();
                            // Define a data mínima como hoje
                            const today = new Date().toISOString().split('T')[0];
                            $('#dtAgendamento').attr('min', today);
                            
                        }).fail(function() {
                            displayMessage('error', 'Falha ao carregar todos os dados. Verifique a console.');
                        }).always(function() {
                            $loadingMessage.hide();
                        });

                } else {
                    $loadingMessage.hide();
                    displayMessage('error', 'Tutor não encontrado para o usuário logado.');
                }
            }).fail(function(xhr) {
                $loadingMessage.hide();
                displayMessage('error', 'Erro ao obter dados do Tutor.');
                console.error("Erro ao obter Tutor:", xhr);
            });
        }

        // =================================================================
        // 2. LÓGICA DE SUBMISSÃO
        // =================================================================
        $form.submit(function(e) {
            e.preventDefault();
            $statusMessage.hide();
            
            if (!confirm("Confirmar o agendamento do serviço?")) {
                return;
            }

            const dataAgendamento = $('#dtAgendamento').val();
            const horaAgendamento = $('#hrAgendamento').val();
            
            // Monta o objeto Agendamento
            const agendamentoData = {
                // A data e hora devem ser combinadas, se o seu backend aceitar no formato String
                // Ex: "2025-12-15 10:30:00" ou apenas a data completa (DateTime)
                dtAgendamento: `${dataAgendamento} ${horaAgendamento}:00`, 
                status: 'AGENDADO', // Status inicial padrão
                
                // Relacionamentos
                pet: { 
                    id: parseInt($petSelect.val()) 
                },
                servico: { 
                    id: parseInt($servicoSelect.val()) 
                },
                tutor: { 
                    id: parseInt($('#tutorIdHidden').val()) 
                }
            };
            
            $.ajax({
                url: contextPath + '/AgendamentoController?action=create',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(agendamentoData),
                dataType: 'json',
                beforeSend: function() {
                    $loadingMessage.text('Enviando Agendamento...').show();
                },
                success: function(response) {
                    displayMessage('success', response.message);
                    // Limpa o formulário após o sucesso
                    $form[0].reset();
                },
                error: function(xhr) {
                    let errorMsg = "Falha ao agendar o serviço.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || xhr.statusText;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    displayMessage('error', errorMsg);
                },
                complete: function() {
                    $loadingMessage.text('Carregando dados necessários...').hide();
                }
            });
        });

        // Inicia o processo de carregamento de dados
        inicializarAgendamento();
    });
</script>

</body>
</html>