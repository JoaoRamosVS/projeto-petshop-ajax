<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || usuario.getPerfil().getId() != 1) { // Perfil ID 1 = Admin
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Administrador";
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
            max-width: 900px;
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
        }
        .user-info {
            text-align: right;
            margin-bottom: 20px;
            font-size: 1.1em;
            color: #6c757d;
        }
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }

        #tabelaUsuarios {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        #tabelaUsuarios thead th {
            background-color: #007bff;
            color: white;
            padding: 12px 15px;
            border: 1px solid #0056b3;
        }
        #tabelaUsuarios tbody td {
            padding: 10px 15px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
        }
        #tabelaUsuarios tbody tr:nth-child(even) {
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
        .btn-edit { background-color: #ffc107; }
        .btn-inactivate { background-color: #dc3545; } 
        .btn-reactivate { background-color: #28a745; } 
        
        .status-ativo { color: #28a745; font-weight: bold; }
        .status-inativo { color: #dc3545; font-weight: bold; }
        
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
    </style>
</head>
<body>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> (<%= usuario.getPerfil().getDescricao() %>)
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/admin/home.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    
    <h1>Gerenciamento de Usuários</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-spinner fa-spin"></i> Carregando lista de usuários...
    </div>
    
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <div class="table-responsive">
        <table id="tabelaUsuarios">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>E-mail</th>
                    <th>Perfil</th>
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

    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function carregarUsuarios() {
            $loadingMessage.show();
            $statusMessage.hide();
            
            $.ajax({
                url: contextPath + '/UsuarioController', 
                data: { action: 'listAll' },
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var tabelaBody = $('#tabelaUsuarios tbody');
                    tabelaBody.empty();
                    
                    if (data.length > 0) {
                        $.each(data, function(index, usuario) {
                            const isAtivo = usuario.ativo === 'S';
                            const statusText = isAtivo ? 'ATIVO' : 'INATIVO';
                            const statusClass = isAtivo ? 'status-ativo' : 'status-inativo';
                            
                            let actionButton;
                            if (isAtivo) {
                                actionButton = 
                                    '<button class="action-button btn-inactivate" title="Inativar Usuário" data-email="' + usuario.email + '">' + 
                                        '<i class="fas fa-user-slash"></i> Inativar' +
                                    '</button>';
                            } else {
                                actionButton = 
                                    '<button class="action-button btn-reactivate" title="Reativar Usuário" data-email="' + usuario.email + '">' + 
                                        '<i class="fas fa-user-check"></i> Reativar' +
                                    '</button>';
                            }
                            
                            var row = '<tr>' +
                                '<td>' + usuario.id + '</td>' +
                                '<td>' + usuario.email + '</td>' +
                                '<td>' + (usuario.perfil ? usuario.perfil.descricao : 'N/A') + '</td>' +
                                '<td><span class="' + statusClass + '">' + statusText + '</span></td>' +
                                '<td>' +
                                    '<button class="action-button btn-edit" title="Editar Dados" data-id="' + usuario.id + '">' + 
                                        '<i class="fas fa-edit"></i> Editar' +
                                    '</button>' +
                                    actionButton +
                                '</td>' +
                                '</tr>';
                            tabelaBody.append(row);
                        });
                    } else {
                        tabelaBody.append('<tr><td colspan="5" style="text-align: center;">Nenhum usuário encontrado.</td></tr>');
                    }
                },
                error: function(xhr, status, error) {
                    let msg = "Erro ao carregar a lista de usuários.";
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
        
        $(document).on('click', '.btn-edit', function() {
            var userId = $(this).data('id');
            window.location.href = 'edicaoUsuario.jsp?id=' + userId;
        });

        $(document).on('click', '.btn-inactivate', function() {
            const email = $(this).data('email');
            if (confirm(`Tem certeza que deseja INATIVAR o usuário: ${email}?`)) {
                realizarAcaoUsuario('inactivate', email);
            }
        });

        $(document).on('click', '.btn-reactivate', function() {
            const email = $(this).data('email');
            if (confirm(`Tem certeza que deseja REATIVAR o usuário: ${email}?`)) {
                realizarAcaoUsuario('reactivate', email);
            }
        });

        function realizarAcaoUsuario(action, email) {
            $.ajax({
                url: contextPath + '/UsuarioController?action=' + action + '&email=' + encodeURIComponent(email),
                type: 'PUT',
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    carregarUsuarios();
                },
                error: function(xhr) {
                    let errorMsg = "Falha na operação.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || errorMsg;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    displayMessage('error', errorMsg);
                }
            });
        }

        carregarUsuarios();
    });
</script>

</body>
</html>