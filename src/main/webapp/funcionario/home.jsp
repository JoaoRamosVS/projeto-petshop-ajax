<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<%
    // Verificação de Segurança (Sessão)
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    // ID 3 geralmente é o perfil de Funcionário/Veterinário/Tosador conforme seu sistema
    if (usuario == null || usuario.getPerfil().getId() != 3) { 
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Área do Funcionário - CentralPet</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f0f0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; text-align: center; }
        .header { margin-bottom: 40px; }
        .card-menu {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 50px;
        }
        .btn-menu {
            display: block;
            width: 250px;
            height: 150px;
            background-color: #20a064; /* Cor verde do seu Swing */
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-size: 1.5em;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .btn-menu:hover { transform: scale(1.05); background-color: #1b8a56; }
        .btn-sair {
            margin-top: 50px;
            background-color: #dc3545;
            padding: 10px 30px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Olá, Funcionário!</h1> </div>

        <div class="card-menu">
            <a href="minhaAgenda.jsp" class="btn-menu">
                <i class="fas fa-calendar-alt" style="margin-right: 10px;"></i> Minha Agenda
            </a>
            <a href="meusDados.jsp" class="btn-menu">
                <i class="fas fa-user-edit" style="margin-right: 10px;"></i> Meus Dados
            </a>
        </div>

        <a href="<%= request.getContextPath() %>/LogoutController" class="btn-sair">Sair</a>
    </div>
</body>
</html>