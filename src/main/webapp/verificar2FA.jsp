<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4; 
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .auth-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 320px; 
            text-align: center;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }
        p {
            margin-bottom: 15px;
            line-height: 1.4;
        }
        input[type="text"] {
            width: 150px; 
            padding: 10px; 
            margin: 10px auto 25px auto;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 20px;
            text-align: center;
            letter-spacing: 5px; 
            display: block; 
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
            margin-bottom: 15px;
            font-weight: bold;
        }
        .expiration-note {
            font-size: 12px;
            color: #666;
            margin-top: 15px;
        }
    </style>
</head>
<body>

<div class="auth-container">
    <h1>Verificação de Dois Fatores</h1>
    
    <% 
        String errorMessage = (String) request.getAttribute("erro");
        if (errorMessage != null) { 
    %>
        <p class="error-message"><%= errorMessage %></p>
    <% 
        } else {
    %>
        <p>Um código de verificação foi enviado para o seu e-mail. Por favor, insira-o abaixo para continuar.</p>
    <% 
        }
    %>
    
    <form action="TwoFactorAuthController" method="post">
        
        <label for="codigo2fa" style="display: none;">Código 2FA:</label>
        <input type="text" id="codigo2fa" name="codigo2fa" required placeholder="000000" 
               maxlength="6" pattern="\d{6}" autofocus>
        
        <button type="submit">Verificar Código</button>
    </form>
    
    <p class="expiration-note">O código é válido por 5 minutos. Verifique sua caixa de entrada (incluindo spam).</p>
    
</div>

</body>
</html>