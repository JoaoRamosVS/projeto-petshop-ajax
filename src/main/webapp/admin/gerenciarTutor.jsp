<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    // =======================================================
    // 1. PREVENÇÃO DE CACHE E SEGURANÇA
    // =======================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    // É necessário ter o objeto Perfil no Usuário, mas se estiver null,
    // usamos uma verificação mais segura se o getPerfil() retornar null.
    if (usuario == null || usuario.getPerfil() == null || usuario.getPerfil().getId() != 1) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Administrador";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Petshop - Gerenciar Tutores</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        /* Estilos baseados no design admin */
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #343a40;
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
        /* Estilos da Tabela */
        #tabelaTutores {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        #tabelaTutores thead th {
            background-color: #007bff;
            color: white;
            padding: 12px 15px;
            border: 1px solid #0056b3;
        }
        #tabelaTutores tbody td {
            padding: 10px 15px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
        }
        #tabelaTutores tbody tr:nth-child(even) {
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
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }
        .alert { 
            padding: 15px; 
            margin-bottom: 20px; 
            border: 1px solid transparent;
            border-radius: 4px;
            text-align: center;
            font-weight: bold; /* Adicionado para destacar a mensagem */
        }
        .alert-error {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .alert-success { /* Adicionado estilo para sucesso */
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .btn-new-tutor {
            background-color: #28a745;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9em; /* Ajustado para um tamanho legível */
            transition: background-color 0.3s;
        }
        .btn-new-tutor:hover {
            background-color: #218838;
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
    
    <h1>
    	Gerenciamento de Tutores
    	<a href="<%= request.getContextPath() %>/admin/cadastroTutor.jsp" class="btn-new-tutor">
            <i class="fas fa-plus"></i> Novo Tutor
        </a>
    </h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-spinner fa-spin"></i> Carregando lista de tutores...
    </div>
    
    <%-- CORRIGIDO: Usaremos um único ID para mensagens de status --%>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <div class="table-responsive">
        <table id="tabelaTutores">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>CPF</th>
                    <th>Telefone</th>
                    <th>E-mail</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    // Define o contexto da aplicação
    const contextPath = '<%= request.getContextPath() %>';

    $(document).ready(function() {
        
        // Define as variáveis do DOM dentro do ready
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');

        // Função para exibir mensagens de status (success ou error)
        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            // Faz a mensagem desaparecer após 5 segundos
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function carregarTutores() {
            $loadingMessage.show();
            $statusMessage.hide(); // Oculta mensagens antigas
            
            $.ajax({
                url: contextPath + '/TutorController', 
                data: { action: 'listAll' },
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var tabelaBody = $('#tabelaTutores tbody');
                    tabelaBody.empty();
                    
                    if (data.length > 0) {
                        $.each(data, function(index, tutor) {
                            const emailUsuario = tutor.usuario ? tutor.usuario.email : '';
                            
                            var row = '<tr>' +
                                '<td>' + tutor.id + '</td>' +
                                '<td>' + tutor.nome + '</td>' +
                                '<td>' + tutor.cpf + '</td>' +
                                '<td>' + (tutor.telefone || 'N/A') + '</td>' +
                                '<td>' + (emailUsuario || 'N/A') + '</td>' +
                                '<td>' +
                                	'<button class="action-button btn-edit" title="Editar Dados" data-id="' + tutor.id + '">' + 
                                    	'<i class="fas fa-edit"></i>' +
                                	'</button>' +
                                    '<button class="action-button btn-inactivate" title="Inativar Tutor (e Usuário)" data-email="' + emailUsuario + '">' + 
                                    	'<i class="fas fa-user-slash"></i> Inativar' +
                                	'</button>' +
                                '</td>' +
                                '</tr>';
                            tabelaBody.append(row);
                        });
                    } else {
                        tabelaBody.append('<tr><td colspan="6" style="text-align: center;">Nenhum tutor ativo encontrado.</td></tr>');
                    }
                },
                error: function(xhr, status, error) {
                    let msg = "Erro ao carregar a lista de tutores.";
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

        // Listener para o botão de Edição (mantido)
        $(document).on('click', '.btn-edit', function() {
            var tutorId = $(this).data('id');
            window.location.href = 'edicaoTutor.jsp?id=' + tutorId;
        });
        
        // Listener para o botão de Inativar (mantido)
        $(document).on('click', '.btn-inactivate', function() {
            const email = $(this).data('email');
            
            if (!email) {
                displayMessage('error', 'E-mail do usuário não encontrado para inativação.');
                return;
            }

            if (confirm(`Tem certeza que deseja INATIVAR o tutor com o e-mail: ${email}? Isso removerá o acesso ao sistema.`)) {
                $.ajax({
                    url: contextPath + '/UsuarioController?action=inactivate&email=' + encodeURIComponent(email),
                    type: 'PUT',
                    dataType: 'json',
                    success: function(response) {
                        displayMessage('success', response.message);
                        carregarTutores();
                    },
                    error: function(xhr) {
                        let errorMsg = "Falha ao inativar usuário.";
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

        // Inicia o carregamento da lista
        carregarTutores();
    });
</script>

</body>
</html>