<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || (usuario.getPerfil().getId() != 2)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Tutor";
    Integer userId = usuario.getId(); 
    
    
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
            max-width: 1000px;
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
        #tabelaPets {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        #tabelaPets thead th {
            background-color: #007bff;
            color: white;
            padding: 12px 15px;
            border: 1px solid #0056b3;
        }
        #tabelaPets tbody td {
            padding: 10px 15px;
            border: 1px solid #dee2e6;
            vertical-align: middle;
        }
        #tabelaPets tbody tr:nth-child(even) {
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
        .btn-delete { background-color: #dc3545; } 
        
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }
        
        .btn-new-pet {
            background-color: #28a745;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.6em;
            transition: background-color 0.3s;
        }
        .btn-new-pet:hover {
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
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/tutor/home.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    
    <h1>
        Meus Pets
        <a href="<%= request.getContextPath() %>/tutor/cadastroPetTutor.jsp" class="btn-new-pet">
            <i class="fas fa-plus"></i> Adicionar Novo Pet
        </a>
    </h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-spinner fa-spin"></i> Carregando seus pets...
    </div>
    
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <div class="table-responsive">
        <table id="tabelaPets">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>Raça</th>
                    <th>Tamanho</th>
                    <th>Nascimento</th>
                    <th>Peso (kg)</th>
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
    const currentUserId = '<%= userId %>';

    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        var tutorId = null;

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function formatDate(dateString) {
            if (!dateString) return 'N/A';
            try {
                const parts = dateString.split('-');
                
                if (parts.length === 3) {
                    return parts[2] + '/' + parts[1] + '/' + parts[0];
                }
                return dateString;
            } catch(e) {
                return dateString; 
            }
        }
        
        function carregarMeusPets(tutorId) {
            if (!tutorId) {
                $loadingMessage.hide();
                displayMessage('error', 'Não foi possível encontrar o ID do tutor logado.');
                return;
            }
            
            $loadingMessage.show();
            
            $.ajax({
                url: contextPath + '/PetController', 
                data: { action: 'getByTutorId', tutorId: tutorId },
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var tabelaBody = $('#tabelaPets tbody');
                    tabelaBody.empty();
                    
                    if (data.length > 0) {
                        $.each(data, function(index, pet) {
                            const dataNascFormatada = formatDate(pet.dtNascimento); 
                            
                            var row = '<tr>' +
                                '<td>' + pet.id + '</td>' +
                                '<td>' + pet.nome + '</td>' +
                                '<td>' + pet.raca + '</td>' +
                                '<td>' + (pet.tamanho.descricao || 'N/A') + '</td>' +
                                '<td>' + dataNascFormatada + '</td>' +
                                '<td>' + (pet.peso || 'N/A') + '</td>' +
                                '<td>' +
                                    '<button class="action-button btn-edit" title="Editar Dados do Pet" data-id="' + pet.id + '">' + 
                                        '<i class="fas fa-edit"></i> Editar' +
                                    '</button>' +
                                '</td>' +
                                '</tr>';
                            tabelaBody.append(row);
                        });
                    } else {
                        tabelaBody.append('<tr><td colspan="7" style="text-align: center;">Você não tem nenhum pet cadastrado.</td></tr>');
                    }
                },
                error: function(xhr, status, error) {
                    let msg = "Erro ao carregar a lista de seus pets.";
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
        
        function carregarTutorEIniciarPets() {
            $.ajax({
                url: contextPath + '/TutorController', 
                data: { action: 'getByUserId', usuarioId: currentUserId },
                type: 'GET',
                dataType: 'json',
                success: function(tutor) {
                    if (tutor && tutor.id) {
                        carregarMeusPets(tutor.id);
                    } else {
                        $loadingMessage.hide();
                        displayMessage('error', "Não há tutor associado ao seu usuário.");
                    }
                },
                error: function(xhr, status, error) {
                    $loadingMessage.hide();
                    let msg = "Erro ao carregar informações do tutor. Você tem um perfil de Tutor associado?";
                    displayMessage('error', msg);
                }
            });
        }
        
        $(document).on('click', '.btn-edit', function() {
            var petId = $(this).data('id');
            window.location.href = 'edicaoPet.jsp?id=' + petId; 
        });

        carregarTutorEIniciarPets();
    });
</script>

</body>
</html>