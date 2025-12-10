<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    <style>
        /* Estilos básicos para centralizar e melhorar a aparência */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 300px;
        }
        .logo {
            text-align: center;
            margin-bottom: 20px;
            display: flex;
            justify-content: center;
            width: 100%;
            height: 100%;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box; /* Garante que padding não aumente a largura total */
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #5cb85c;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #4cae4c;
        }
        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 10px;
        }
        .register-link {
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }
        .register-link a {
            color: #337ab7;
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="login-container">
    <img class="logo" src="assets/logo.png" />
    <% 
        String errorMessage = (String) request.getAttribute("erro");
        if (errorMessage != null) { 
    %>
        <p class="error-message"><%= errorMessage %></p>
    <% 
        } 
    %>
    
    <form action="LoginController" method="POST">
        
        <label for="email">E-mail:</label>
        <input type="text" id="email" name="email" required placeholder="Digite seu e-mail">
        
        <label for="senha">Senha:</label>
        <input type="password" id="senha" name="senha" required placeholder="Digite sua senha">
        
        <button type="submit">Entrar</button>
    </form>
    
    <div class="register-link">
        <p>Não tem conta? <a href="cadastro.jsp">Cadastre-se aqui</a></p>
    </div>
</div>

</body>
</html>