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
            max-width: 700px;
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

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    String funcionarioIdParam = request.getParameter("id");
    
    if (usuario == null || usuario.getPerfil() == null || usuario.getPerfil().getId() != 1) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    if (funcionarioIdParam == null || funcionarioIdParam.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/gerenciarFuncionario.jsp");
        return;
    }

    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Administrador";
%>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/admin/gerenciarFuncionario.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar à Lista de Funcionários
    </a>
    
    <h1>Edição de Funcionário (ID: <span id="funcionarioIdDisplay"><%= funcionarioIdParam %></span>)</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="edicaoFuncionarioForm" style="display:none;">
        
        <input type="hidden" id="funcionarioId" value="<%= funcionarioIdParam %>">

        <div class="form-section">
            <h3><i class="fas fa-info-circle"></i> Informações Básicas</h3>
            <div class="row">
                <div>
                    <label for="nome">Nome Completo:</label>
                    <input type="text" id="nome" readonly>
                </div>
                <div>
                    <label for="cpf">CPF:</label>
                    <input type="text" id="cpf" readonly>
                </div>
            </div>
            <div>
                <label for="email">E-mail de Acesso:</label>
                <input type="email" id="email" readonly>
            </div>
        </div>

        <div class="form-section">
            <h3><i class="fas fa-address-card"></i> Detalhes do Funcionário</h3>
            <div class="row">
                <div>
                    <label for="cargo">Cargo:</label>
                    <input type="text" id="cargo">
                </div>
                <div>
                    <label for="salario">Salário (R$):</label>
                    <input type="text" id="salario" placeholder="Ex: 2500.00">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="telefone">Telefone:</label>
                    <input type="text" id="telefone">
                </div>
                <div>
                    <label for="cep">CEP:</label>
                    <input type="text" id="cep">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="endereco">Endereço:</label>
                    <input type="text" id="endereco">
                </div>
                <div>
                    <label for="bairro">Bairro:</label>
                    <input type="text" id="bairro">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="cidade">Cidade:</label>
                    <input type="text" id="cidade">
                </div>
                <div>
                    <label for="uf">UF:</label>
                    <input type="text" id="uf" maxlength="2">
                </div>
            </div>
        </div>
        
        <button type="submit"><i class="fas fa-sync-alt"></i> Atualizar Dados do Funcionário</button>
    </form>
</div>

<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const funcionarioId = $('#funcionarioId').val();
    
    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#edicaoFuncionarioForm');

        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 5000);
        }

        function carregarDadosFuncionario() {
            $loadingMessage.show();
            $form.hide();
            
            $.ajax({
                url: contextPath + '/FuncionarioController', 
                data: { action: 'getById', id: funcionarioId },
                type: 'GET',
                dataType: 'json',
                success: function(func) {
                    if (func) {
                        $('#nome').val(func.nome);
                        $('#cpf').val(func.cpf);
                        $('#email').val(func.usuario ? func.usuario.email : 'N/A');
                        
                        $('#cargo').val(func.cargo);
                        $('#salario').val(func.salario);
                        $('#telefone').val(func.telefone);
                        $('#cep').val(func.cep);
                        $('#endereco').val(func.endereco);
                        $('#bairro').val(func.bairro);
                        $('#cidade').val(func.cidade);
                        $('#uf').val(func.uf);
                        
                        $form.show();
                    } else {
                        displayMessage('error', 'Funcionário não encontrado com o ID fornecido.');
                    }
                },
                error: function(xhr) {
                    let msg = "Erro ao carregar os dados do funcionário.";
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
            
            if (!confirm("Confirmar atualização dos dados do funcionário?")) {
                return;
            }

            var dadosAtualizacao = {
                id: funcionarioId,
                salario: $('#salario').val(),
                endereco: $('#endereco').val(),
                bairro: $('#bairro').val(),
                cidade: $('#cidade').val(),
                uf: $('#uf').val(),
                cep: $('#cep').val(),
                telefone: $('#telefone').val()
            };
            
            $.ajax({
                url: contextPath + '/FuncionarioController?action=update',
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(dadosAtualizacao),
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    carregarDadosFuncionario();
                },
                error: function(xhr) {
                    let errorMsg = "Falha ao atualizar o funcionário.";
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

        carregarDadosFuncionario();
    });
</script>

</body>
</html>