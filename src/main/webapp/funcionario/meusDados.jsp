<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null) { response.sendRedirect("../index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Meus Dados</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f0f0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        input[readonly] { background-color: #e9ecef; }
        button { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 4px; font-size: 1.1em; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        .msg { margin-bottom: 15px; padding: 10px; border-radius: 4px; display: none; text-align: center; }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>

<div class="container">
    <a href="home.jsp" style="text-decoration: none; color: #007bff; font-weight: bold; margin-bottom: 20px; display:block;">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    <h2><i class="fas fa-user-edit"></i> Meus Dados Pessoais</h2>
    
    <div id="msg" class="msg"></div>

    <form id="formDados">
        <input type="hidden" id="idFuncionario">
        
        <div class="form-group">
            <label>Nome Completo (Apenas leitura):</label>
            <input type="text" id="nome" readonly>
        </div>
        <div class="form-group">
            <label>Cargo (Apenas leitura):</label>
            <input type="text" id="cargo" readonly>
        </div>
        
        <h3>Dados de Contato</h3>
        <div class="form-group">
            <label>Telefone:</label>
            <input type="text" id="telefone">
        </div>
        <div class="form-group">
            <label>CEP:</label>
            <input type="text" id="cep">
        </div>
        <div class="form-group">
            <label>Endereço:</label>
            <input type="text" id="endereco">
        </div>
        <div class="form-group">
            <label>Bairro:</label>
            <input type="text" id="bairro">
        </div>
        <div class="form-group">
            <label>Cidade:</label>
            <input type="text" id="cidade">
        </div>
        <div class="form-group">
            <label>UF:</label>
            <input type="text" id="uf" maxlength="2">
        </div>

        <p style="font-size: 0.9em; color: #666;">* Para alterar e-mail ou senha, contate o administrador.</p>

        <button type="submit">Salvar Alterações</button>
    </form>
</div>

<script>
    const usuarioLogadoId = <%= usuario.getId() %>;

    $(document).ready(function() {
        // 1. Carregar dados atuais
        $.ajax({
            url: '<%= request.getContextPath() %>/FuncionarioController',
            data: { action: 'getByUserId', usuarioId: usuarioLogadoId },
            type: 'GET',
            success: function(func) {
                if(func) {
                    $('#idFuncionario').val(func.id);
                    $('#nome').val(func.nome);
                    $('#cargo').val(func.cargo);
                    $('#telefone').val(func.telefone);
                    $('#cep').val(func.cep);
                    $('#endereco').val(func.endereco);
                    $('#bairro').val(func.bairro);
                    $('#cidade').val(func.cidade);
                    $('#uf').val(func.uf);
                }
            },
            error: function() {
                $('.msg').addClass('error').text('Erro ao carregar dados do funcionário.').show();
            }
        });

        // 2. Salvar dados (PUT)
        $('#formDados').submit(function(e) {
            e.preventDefault();
            
            var dados = {
                id: $('#idFuncionario').val(),
                telefone: $('#telefone').val(),
                cep: $('#cep').val(),
                endereco: $('#endereco').val(),
                bairro: $('#bairro').val(),
                cidade: $('#cidade').val(),
                uf: $('#uf').val(),
                salario: 0 // Campo obrigatório no DTO Java, envie 0 ou valor atual se tiver
            };

            $.ajax({
                url: '<%= request.getContextPath() %>/FuncionarioController?action=update',
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(dados),
                success: function(response) {
                    $('.msg').removeClass('error').addClass('success').text(response.message || 'Dados atualizados!').show();
                },
                error: function(xhr) {
                    $('.msg').removeClass('success').addClass('error').text('Erro ao atualizar.').show();
                }
            });
        });
    });
</script>
</body>
</html>