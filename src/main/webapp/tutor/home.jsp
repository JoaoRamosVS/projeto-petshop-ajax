<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setHeader("Pragma", "no-cache"); 
    response.setDateHeader("Expires", 0);
%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || (usuario.getPerfil().getId() != 2)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Tutor";
    String perfilDescricao = usuario.getPerfil().getDescricao() != null ? usuario.getPerfil().getDescricao() : "Tutor";
    
    Integer usuarioId = usuario.getId(); 
%>
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
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
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
            color: #007bff;
            text-align: center;
            margin-bottom: 5px;
        }
        .user-info {
            text-align: right;
            margin-bottom: 20px;
            font-size: 1.1em;
            color: #6c757d;
        }
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .menu-item {
            background-color: #e6f7ff; 
            border: 1px solid #b3e0ff;
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
            background-color: #cceeff;
            box-shadow: 0 0 10px rgba(0, 123, 255, 0.5);
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

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %>
    </div>
    
    <div class="container-header">
    	<h1>Painel do Tutor</h1>
    
    	<img class="logo" src="../assets/logo.png" />
    
    </div>

    <div class="menu-grid">
        
        <a href="<%= request.getContextPath() %>/tutor/gerenciarPetsTutor.jsp" class="menu-item">
            <i class="fas fa-paw"></i>
            Meus Pets
        </a>
        
        <a href="<%= request.getContextPath() %>/tutor/agendarServico.jsp" class="menu-item">
            <i class="fas fa-calendar-plus"></i>
            Agendar Serviço
        </a>
        
        <a href="<%= request.getContextPath() %>/tutor/gerenciarAgendaTutor.jsp" class="menu-item">
            <i class="fas fa-clipboard-list"></i>
            Minha Agenda
        </a>
        
        <a href="<%= request.getContextPath() %>/tutor/edicaoPerfilTutor.jsp?userId=<%= usuarioId %>" class="menu-item">
            <i class="fas fa-user-edit"></i>
            Editar Perfil
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