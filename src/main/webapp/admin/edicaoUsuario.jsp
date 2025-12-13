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
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #343a40;
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
            margin-bottom: 15px;
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
        input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
            background-color: #fff;
        }
        input[readonly] {
            background-color: #f1f1f1; 
            color: #007bff; 
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

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
    String userIdParam = request.getParameter("id");
    
    if (usuarioLogado == null || usuarioLogado.getPerfil() == null || usuarioLogado.getPerfil().getId() != 1) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    if (userIdParam == null || userIdParam.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/gerenciarUsuario.jsp");
        return;
    }

    String emailUsuario = usuarioLogado.getEmail() != null ? usuarioLogado.getEmail() : "Administrador";
%>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/admin/gerenciarUsuario.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar à Lista de Usuários
    </a>
    
    <h1>Edição de Usuário (ID: <span id="userIdDisplay"><%= userIdParam %></span>)</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="edicaoUsuarioForm" style="display:none;">
        
        <input type="hidden" id="userId" value="<%= userIdParam %>">
        
        <div class="form-section">
            <h3><i class="fas fa-user-circle"></i> Detalhes do Usuário</h3>
            
            <div class="row">
                <div>
                    <label for="email">E-mail de Acesso:</label>
                    <input type="email" id="email" required>
                </div>
                <div>
                    <label for="statusAtivo">Status do Usuário:</label>
                    <select id="statusAtivo" required>
                        <option value="S">Ativo</option>
                        <option value="N">Inativo</option>
                    </select>
                </div>
            </div>
            
            <div class="row">
                <div>
                    <label for="perfilDescricao">Perfil Atual:</label>
                    <input type="text" id="perfilDescricao" readonly> 
                </div>
                <div>
                    <label for="novaSenha">Nova Senha (opcional):</label>
                    <input type="password" id="novaSenha" placeholder="Deixe vazio para manter a senha">
                </div>
            </div>
        </div>
        
        <button type="submit"><i class="fas fa-sync-alt"></i> Atualizar Credenciais e Status</button>
    </form>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const userId = $('#userId').val();
    
    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#edicaoUsuarioForm');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function carregarDadosUsuario() {
            $loadingMessage.show();
            $form.hide();
            
            $.ajax({
                url: contextPath + '/UsuarioController', 
                data: { action: 'getById', id: userId },
                type: 'GET',
                dataType: 'json',
                success: function(usuario) {
                    if (usuario) {
                        $('#email').val(usuario.email);
                        $('#statusAtivo').val(usuario.ativo); 
                        
                        $('#perfilDescricao').val(usuario.perfil ? usuario.perfil.descricao : 'N/A');
                        
                        $form.show();
                    } else {
                        displayMessage('error', 'Usuário não encontrado com o ID fornecido.');
                    }
                },
                error: function(xhr) {
                    let msg = "Erro ao carregar os dados do usuário.";
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
            
            if (!confirm("Confirmar atualização do E-mail, Status e/ou Senha do usuário?")) {
                return;
            }
            
            const emailLogado = '<%= emailUsuario %>'; 
            const emailEditado = $('#email').val();
            const statusNovo = $('#statusAtivo').val();
            
            if (emailLogado === emailEditado && statusNovo === 'N') {
                displayMessage('error', 'Você não pode inativar sua própria conta de administrador.');
                return;
            }

            var dadosAtualizacao = {
                id: userId,
                email: $('#email').val(),
                ativo: statusNovo
            };
            
            const novaSenha = $('#novaSenha').val();

            if (novaSenha) {
                dadosAtualizacao.senha = novaSenha; 
            }
            
            $.ajax({
                url: contextPath + '/UsuarioController?action=updateData',
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(dadosAtualizacao),
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    $('#novaSenha').val(''); 
                    carregarDadosUsuario(); 
                },
                error: function(xhr) {
                    let errorMsg = "Falha ao atualizar o usuário.";
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

        carregarDadosUsuario();
    });
</script>

</body>
</html>