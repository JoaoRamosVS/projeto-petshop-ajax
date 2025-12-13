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
        }
        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #28a745; 
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
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil().getId() != 1) { // Perfil ID 1 = Admin
        response.sendRedirect(request.getContextPath() + "/index.jsp");
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
    
    <h1>Cadastro de Novo Funcionário</h1>
    
    <div id="message" style="display:none;"></div>

    <form id="cadastroFuncionarioForm">
        
        <div class="form-section">
            <h3><i class="fas fa-user-lock"></i> Dados de Acesso</h3>
            <div class="row">
                <div>
                    <label for="email">E-mail:</label>
                    <input type="email" id="email" required>
                </div>
                <div>
                    <label for="senha">Senha:</label>
                    <input type="password" id="senha" required>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3><i class="fas fa-user-tie"></i> Informações Pessoais</h3>
            <div class="row">
                <div>
                    <label for="nome">Nome Completo:</label>
                    <input type="text" id="nome" required>
                </div>
                <div>
                    <label for="cpf">CPF:</label>
                    <input type="text" id="cpf" required placeholder="000.000.000-00">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="telefone">Telefone:</label>
                    <input type="text" id="telefone" required placeholder="(00) 90000-0000">
                </div>
                <div>
                    <label for="cep">CEP:</label>
                    <input type="text" id="cep" required placeholder="00000-000">
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
        
        <div class="form-section">
            <h3><i class="fas fa-briefcase"></i> Dados Funcionais</h3>
            <div class="row">
                <div>
                    <label for="cargo">Cargo:</label>
                    <select id="cargo" required>
                        <option value="">Selecione o Cargo</option>
                        <option value="Administrador">Administrador</option>
                        <option value="Recepcionista">Recepcionista</option>
                        <option value="Tosador">Tosador</option>
                        <option value="Veterinário">Veterinário</option>
                    </select>
                </div>
                <div>
                    <label for="salario">Salário (R$):</label>
                    <input type="text" id="salario" required placeholder="Ex: 2500.00">
                </div>
            </div>
        </div>

        <button type="submit"><i class="fas fa-save"></i> Cadastrar Funcionário</button>
    </form>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        
        $('#cadastroFuncionarioForm').submit(function(e) {
            e.preventDefault(); 
            const $message = $('#message');
            $message.hide().removeClass('alert-success alert-error').text('');

            // 1. Coleta e estrutura os dados do formulário
            var dadosCadastro = {
                usuario: {
                    email: $('#email').val(),
                    senha: $('#senha').val()
                },
                funcionario: {
                    nome: $('#nome').val(),
                    cpf: $('#cpf').val(),
                    endereco: $('#endereco').val(),
                    bairro: $('#bairro').val(),
                    cidade: $('#cidade').val(),
                    uf: $('#uf').val(),
                    cep: $('#cep').val(),
                    telefone: $('#telefone').val(),
                    cargo: $('#cargo').val(),
                    salario: $('#salario').val() 
                }
            };
            
            $.ajax({
                url: '<%= request.getContextPath() %>/FuncionarioController?action=create', 
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(dadosCadastro),
                dataType: 'json',
                success: function(response) {
                    $message.text(response.message).addClass('alert-success').show();
                    
                    $('#cadastroFuncionarioForm')[0].reset();
                    
                    setTimeout(function() {
                         window.location.href = '<%= request.getContextPath() %>/admin/gerenciarFuncionario.jsp';
                    }, 2000);
                },
                error: function(xhr) {
                    var errorMsg = "Erro no servidor. Verifique os dados.";
                    try {
                        var jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || errorMsg;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    $message.text(errorMsg).addClass('alert-error').show();
                }
            });
        });
        
    });
</script>

</body>
</html>