<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cadastro Inicial - Novo Tutor e Pet</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); max-width: 600px; margin: auto; }
        h2 { text-align: center; color: #333; }
        label { display: block; margin-top: 10px; font-weight: bold; }
        input[type="text"], input[type="email"], input[type="password"], input[type="date"], select {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .section { border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .row { display: flex; gap: 20px; }
        .row > div { flex: 1; }
        button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover { background-color: #0056b3; }
        #message { text-align: center; margin-top: 15px; font-weight: bold; }
    </style>
</head>
<body>

<div class="container">
    <h2>Cadastro Inicial de Tutor e Pet</h2>

    <form id="cadastroForm">
        <div class="section">
            <h3>Dados de Login</h3>
            <div class="row">
                <div>
                    <label for="email">E-mail (Login):</label>
                    <input type="email" id="email" required>
                </div>
                <div>
                    <label for="senha">Senha:</label>
                    <input type="password" id="senha" required>
                </div>
            </div>
        </div>

        <div class="section">
            <h3>Dados do Tutor</h3>
            <div class="row">
                <div>
                    <label for="nomeTutor">Nome Completo:</label>
                    <input type="text" id="nomeTutor" required>
                </div>
                <div>
                    <label for="cpf">CPF:</label>
                    <input type="text" id="cpf" required placeholder="Ex: 000.000.000-00">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="telefone">Telefone:</label>
                    <input type="text" id="telefone" required placeholder="Ex: (00) 90000-0000">
                </div>
                <div>
                    <label for="cep">CEP:</label>
                    <input type="text" id="cep" required placeholder="Ex: 00000-000">
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="endereco">Endereço:</label>
                    <input type="text" id="endereco" required>
                </div>
                <div>
                    <label for="bairro">Bairro:</label>
                    <input type="text" id="bairro" required>
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="cidade">Cidade:</label>
                    <input type="text" id="cidade" required>
                </div>
                <div>
                    <label for="uf">UF:</label>
                    <input type="text" id="uf" required maxlength="2">
                </div>
            </div>
        </div>

        <div class="section">
            <h3>Dados do Pet (Primeiro Pet)</h3>
            <div class="row">
                <div>
                    <label for="nomePet">Nome do Pet:</label>
                    <input type="text" id="nomePet" required>
                </div>
                <div>
                    <label for="raca">Raça:</label>
                    <input type="text" id="raca" required>
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="dtNascimento">Data de Nascimento:</label>
                    <input type="date" id="dtNascimento" required>
                </div>
                <div>
                    <label for="peso">Peso (Kg):</label>
                    <input type="text" id="peso" required placeholder="Ex: 5.5">
                </div>
            </div>
            <div>
                <label for="tamanho">Porte/Tamanho:</label>
                <select id="tamanho" required>
                    <option value="">Selecione...</option>
                    <option value="1">Pequeno</option>
                    <option value="2">Médio</option>
                    <option value="3">Grande</option>
                </select>
            </div>
        </div>

        <button type="submit">Finalizar Cadastro</button>
    </form>
    
    <p id="message"></p>
    
    <div style="text-align: center; margin-top: 15px;">
        Já possui conta? <a href="index.jsp">Faça Login</a>
    </div>
</div>

<script type="text/javascript">
    $('#cadastroForm').submit(function(e) {
        e.preventDefault(); // Impede o envio tradicional do formulário
        $('#message').removeClass('error-message success-message').text('Processando...');

        // 1. Coleta e estrutura os dados do formulário
        var dadosCadastro = {
            usuario: {
                email: $('#email').val(),
                senha: $('#senha').val()
            },
            tutor: {
                nome: $('#nomeTutor').val(),
                cpf: $('#cpf').val(),
                endereco: $('#endereco').val(),
                bairro: $('#bairro').val(),
                cidade: $('#cidade').val(),
                uf: $('#uf').val(),
                cep: $('#cep').val(),
                telefone: $('#telefone').val()
            },
            pet: {
                nome: $('#nomePet').val(),
                raca: $('#raca').val(),
                // Converte a data para o formato YYYY-MM-DD esperado pelo seu PetDAO
                dtNascimento: $('#dtNascimento').val(), 
                tamanho: { 
                    id: parseInt($('#tamanho').val()) 
                },
                // Converte peso para BigDecimal, no Java/JSON como String
                peso: $('#peso').val() 
            }
        };

        // 2. Chama o Servlet via AJAX
        $.ajax({
            url: 'TutorController?action=createWithPet', // Action do Servlet para cadastro completo
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(dadosCadastro), // Envia os dados como JSON
            dataType: 'json',
            success: function(response) {
                $('#message').text(response.message).addClass('success-message');
                setTimeout(function() {
                    window.location.href = 'index.jsp';
                }, 2000);
            },
            error: function(xhr) {
                var errorMsg = "Erro no servidor. Tente novamente.";
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    errorMsg = jsonResponse.error || errorMsg;
                } catch (e) {
                    console.error("Falha ao parsear JSON de erro:", xhr.responseText);
                }
                $('#message').text(errorMsg).addClass('error-message');
            }
        });
    });
</script>

</body>
</html>