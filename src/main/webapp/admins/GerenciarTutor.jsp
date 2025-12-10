<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gerenciar Tutores</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<style>
    table, th, td {
        border: 1px solid black;
        border-collapse: collapse;
        padding: 8px;
    }
</style>
</head>
<body>

    <h1>Gerenciamento de Tutores (AJAX)</h1>
    
    <table id="tabelaTutores">
        <thead>
            <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>CPF</th>
                <th>Telefone</th>
                <th>E-mail</th>
            </tr>
        </thead>
        <tbody>
            </tbody>
    </table>

    <script type="text/javascript">
        $(document).ready(function() {
            // Função para carregar a lista de tutores via AJAX
            function carregarTutores() {
                $.ajax({
                    // URL mapeada no TutorServlet
                    url: 'TutorController', 
                    // Parâmetros da requisição (action=list)
                    data: { action: 'list' },
                    type: 'GET',
                    dataType: 'json', // Espera uma resposta JSON
                    success: function(data) {
                        // Limpa o corpo da tabela antes de adicionar novos dados
                        var tabelaBody = $('#tabelaTutores tbody');
                        tabelaBody.empty();
                        
                        // 'data' é um array de objetos Tutor (que veio do JSON)
                        if (data.length > 0) {
                            $.each(data, function(index, tutor) {
                                // Cria uma nova linha na tabela para cada tutor
                                var row = '<tr>' +
                                    '<td>' + tutor.id + '</td>' +
                                    '<td>' + tutor.nome + '</td>' +
                                    '<td>' + tutor.cpf + '</td>' +
                                    '<td>' + tutor.telefone + '</td>' +
                                    '<td>' + tutor.usuario.email + '</td>' + // Acessa o email dentro do objeto Usuario
                                    '</tr>';
                                tabelaBody.append(row);
                            });
                        } else {
                            tabelaBody.append('<tr><td colspan="5">Nenhum tutor encontrado.</td></tr>');
                        }
                    },
                    error: function(xhr, status, error) {
                        alert("Erro ao carregar a lista de tutores: " + xhr.responseText);
                    }
                });
            }

            // Chama a função ao carregar a página
            carregarTutores();
        });
    </script>

</body>
</html>