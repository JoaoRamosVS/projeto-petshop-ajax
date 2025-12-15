<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
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
        input[type="text"], input[type="email"], input[type="date"], input[type="number"], select, textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
            background-color: #fff;
        }
        textarea {
            resize: vertical; 
            min-height: 80px;
        }
        input[readonly] {
            background-color: #f1f1f1;
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

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
    String petIdParam = request.getParameter("id");
    
    if (usuarioLogado == null || usuarioLogado.getPerfil() == null || usuarioLogado.getPerfil().getId() != 2) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    if (petIdParam == null || petIdParam.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/tutor/gerenciarMeusPets.jsp");
        return;
    }

    String emailUsuario = usuarioLogado.getEmail() != null ? usuarioLogado.getEmail() : "Tutor";
%>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/tutor/gerenciarMeusPets.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar à Lista de Pets
    </a>
    
    <h1>Edição de Pet (ID: <span id="petIdDisplay"><%= petIdParam %></span>)</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados do Pet...</div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="edicaoPetForm" style="display:none;">
        
        <input type="hidden" id="petId" value="<%= petIdParam %>">
        
        <input type="hidden" id="tutorIdHidden"> 

        <div class="form-section">
            <h3><i class="fas fa-info-circle"></i> Informações Fixas</h3>
            <div class="row">
                <div>
                    <label for="nome">Nome do Pet:</label>
                    <input type="text" id="nome" readonly>
                </div>
                <div>
                    <label for="raca">Raça:</label>
                    <input type="text" id="raca" readonly>
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="dtNascimento">Data de Nascimento:</label>
                    <input type="date" id="dtNascimento" readonly>
                </div>
                <div>
                    <label for="tutorNome">Tutor:</label>
                    <input type="text" id="tutorNome" readonly>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3><i class="fas fa-paw"></i> Detalhes Editáveis</h3>
            <div class="row">
                <div>
                    <label for="tamanho">Tamanho:</label>
                    <select id="tamanho" required>
                        <option value="">-- Selecione o Tamanho --</option>
                        <option value="1">Muito pequeno</option>
                        <option value="2">Pequeno</option>
                        <option value="3">Médio</option>
                        <option value="4">Grande</option>
                    </select>
                </div>
                <div>
                    <label for="peso">Peso (kg):</label>
                    <input type="number" id="peso" step="0.01" required placeholder="Ex: 5.50">
                </div>
            </div>
            
            <div>
                <label for="observacoes">Observações (Comportamento, Histórico, Alergias, etc.):</label>
                <textarea id="observacoes"></textarea>
            </div>
        </div>
        
        <button type="submit"><i class="fas fa-sync-alt"></i> Atualizar Detalhes do Pet</button>
    </form>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const petId = $('#petId').val();
    
    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#edicaoPetForm');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function carregarDadosPet() {
            $loadingMessage.show();
            $form.hide();
            
            $.ajax({
                url: contextPath + '/PetController', 
                data: { action: 'getById', petId: petId },
                type: 'GET',
                dataType: 'json',
                success: function(pet) {
                    if (pet) {
                        $('#nome').val(pet.nome);
                        $('#raca').val(pet.raca);
                        $('#dtNascimento').val(pet.dtNascimento); 
                        $('#tutorNome').val(pet.tutor ? pet.tutor.nome : 'N/A');
                        
                        $('#tutorIdHidden').val(pet.tutor ? pet.tutor.id : ''); 
                        
                        $('#tamanho').val(pet.tamanho.id);
                        $('#peso').val(pet.peso);
                        $('#observacoes').val(pet.obs || ''); 
                        
                        $form.show();
                    } else {
                        displayMessage('error', 'Pet não encontrado com o ID fornecido.');
                    }
                },
                error: function(xhr) {
                    let msg = "Erro ao carregar os dados do Pet.";
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
        
        $form.submit(function(e) {
            e.preventDefault();
            $statusMessage.hide(); 
            
            if (!confirm("Confirmar atualização dos dados do Pet?")) {
                return;
            }

            var dadosAtualizacao = {
                id: petId,
                
                nome: $('#nome').val(),
                raca: $('#raca').val(),
                dtNascimento: $('#dtNascimento').val(), 
                tutor: { 
                    id: parseInt($('#tutorIdHidden').val()) 
                },
                
                tamanho: { id: $('#tamanho').val() },
                peso: parseFloat($('#peso').val()),
                obs: $('#observacoes').val()
            };
            
            if (isNaN(dadosAtualizacao.tutor.id)) {
                 displayMessage('error', 'ID do Tutor inválido. Não foi possível salvar.');
                 return;
            }

            $.ajax({
                url: contextPath + '/PetController?action=update',
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(dadosAtualizacao),
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    carregarDadosPet(); 
                },
                error: function(xhr) {
                    let errorMsg = "Falha ao atualizar o Pet.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || xhr.statusText;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    displayMessage('error', errorMsg);
                }
            });
        });

        carregarDadosPet();
    });
</script>

</body>
</html>