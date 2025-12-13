<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);=
        }
        .container-header {
        	display: flex;
        	flex-direction: column;
        	align-items: center;
        	justify-content: center;
        }
        .logo {
            display: flex;
            justify-content: center;
            max-width: 300px;
            max-height: 300px;
            width: 100%;
            height: 100%;
        }
        h1 {
            color: #343a40;
            text-align: center;
            margin-bottom: 5px;
        }
        .user-info {
            text-align: right;
            font-size: 1.1em;
            color: #6c757d;
        }
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .menu-item {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            text-align: center;
            padding: 30px 15px;
            transition: background-color 0.3s, box-shadow 0.3s;
            text-decoration: none;
            color: #007bff;
            font-weight: bold;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .menu-item:hover {
            background-color: #e2e6ea;
            box-shadow: 0 0 10px rgba(0, 123, 255, 0.3);
        }
        .menu-item i {
            font-size: 3em;
            margin-bottom: 10px;
        }
        .logout {
            margin-top: 30px;
            text-align: center;
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
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
    </div>
    
    <div class="container-header">
    	<h1>Painel de Administração</h1>
    
    	<img class="logo" src="../assets/logo.png" />
    
    </div>

    <div class="menu-grid">
        
        <a href="<%= request.getContextPath() %>/admin/gerenciarUsuario.jsp" class="menu-item">
            <i class="fas fa-users-cog"></i>
            Gerenciar Usuários
        </a>
        
        <a href="<%= request.getContextPath() %>/admin/gerenciarTutor.jsp" class="menu-item">
            <i class="fas fa-user-tag"></i>
            Gerenciar Tutores
        </a>
        
        <a href="<%= request.getContextPath() %>/admin/gerenciarFuncionario.jsp" class="menu-item">
            <i class="fas fa-user-tie"></i>
            Gerenciar Funcionários
        </a>

        <a href="<%= request.getContextPath() %>/admin/gerenciarServicos.jsp" class="menu-item">
            <i class="fas fa-cut"></i>
            Gerenciar Serviços
        </a>
        
    </div>
    
    <div class="logout">
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none; font-weight: bold;">
            <i class="fas fa-sign-out-alt"></i> Sair do Sistema
        </a>
    </div>

</div>

</body>
</html>