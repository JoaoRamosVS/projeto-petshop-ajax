<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Tutores</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        /* Estilos do HomeAdmin.jsp */
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px; /* Aumentado para caber a tabela */
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
        .btn-view { background-color: #17a2b8; }
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }
        .alert { 
            padding: 15px; 
            margin-bottom: 20px; 
            border: 1px solid transparent;
            border-radius: 4px;
        }
        .alert-error {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .btn-new-tutor {
            background-color: #28a745;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.6em;
            margin-left: 20px;
            transition: background-color 0.3s;
        }
        .btn-new-tutor:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.
%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil().getId() != 1) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Administrador";
%>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> (<%= usuario.getPerfil().getId() == 1 ? "ADMIN" : "Outro Perfil" %>)
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
    
    <div id="errorMessage" class="alert alert-error" style="display:none;"></div>

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
    $(document).ready(function() {
        
        function carregarTutores() {
            $('#loadingMessage').show();
            $('#errorMessage').hide();
            
            $.ajax({
                url: '<%= request.getContextPath() %>/TutorController', 
                data: { action: 'listAll' },
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var tabelaBody = $('#tabelaTutores tbody');
                    tabelaBody.empty();
                    
                    if (data.length > 0) {
                        $.each(data, function(index, tutor) {
                            var row = '<tr>' +
                                '<td>' + tutor.id + '</td>' +
                                '<td>' + tutor.nome + '</td>' +
                                '<td>' + tutor.cpf + '</td>' +
                                '<td>' + (tutor.telefone || 'N/A') + '</td>' +
                                '<td>' + (tutor.usuario ? tutor.usuario.email : 'N/A') + '</td>' +
                                '<td>' +
                                    '<button class="action-button btn-view" title="Detalhes/Pets" data-id="' + tutor.id + '">' + 
                                        '<i class="fas fa-eye"></i>' +
                                    '</button>' +
                                    '<button class="action-button btn-edit" title="Editar Dados" data-id="' + tutor.id + '">' + 
                                        '<i class="fas fa-edit"></i>' +
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
                    var msg = "Erro ao carregar a lista de tutores.";
                    try {
                        var jsonResponse = JSON.parse(xhr.responseText);
                        msg += " Detalhes: " + (jsonResponse.error || xhr.statusText);
                    } catch (e) {
                        msg += " Status: " + xhr.status;
                    }
                    $('#errorMessage').text(msg).show();
                },
                complete: function() {
                    $('#loadingMessage').hide();
                }
            });
        }

        // Adicionar Listeners para os botões (Exemplo de como iniciar a navegação para outras telas)
        $(document).on('click', '.btn-edit', function() {
            var tutorId = $(this).data('id');
            window.location.href = 'edicaoTutor.jsp?id=' + tutorId;
        });
        
        $(document).on('click', '.btn-view', function() {
            var tutorId = $(this).data('id');
            window.location.href = 'detalhesTutor.jsp?id=' + tutorId;
        });

        // Chama a função ao carregar a página
        carregarTutores();
    });
</script>

</body>
</html>