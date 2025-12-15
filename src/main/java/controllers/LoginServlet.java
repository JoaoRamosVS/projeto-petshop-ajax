package controllers;

import dao.UsuarioDAO;
import entities.Usuario;
import utils.MailSender;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;

@WebServlet("/LoginController")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UsuarioDAO usuarioDAO;

    public LoginServlet() {
        this.usuarioDAO = new UsuarioDAO(); 
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");

        Usuario usuarioAutenticado = null;
        try {
            usuarioAutenticado = usuarioDAO.autenticarUsuario(email, senha); 
        } catch (Exception e) {
            System.err.println("Erro durante a autenticação: " + e.getMessage());
        }

        if (usuarioAutenticado != null) {
            
            try {
                String codigo2FA = MailSender.generate2FACode();
                Calendar calendar = Calendar.getInstance();
                calendar.add(Calendar.MINUTE, 5); 
                Timestamp expiracao = new Timestamp(calendar.getTimeInMillis());

                usuarioDAO.salvarCodigo2FA(usuarioAutenticado.getId(), codigo2FA, expiracao);

                MailSender mailSender = new MailSender();
                String subject = "CentralPet - Seu Código de Acesso 2FA";
                String html = "<h1>Verificação de Dois Fatores</h1>"
                            + "<p>Seu código de verificação é: <strong>" + codigo2FA + "</strong></p>"
                            + "<p>Este código é válido por 5 minutos.</p>";
                mailSender.sendHtml(usuarioAutenticado.getEmail(), subject, html);

                HttpSession session = request.getSession();
                session.setAttribute("usuario2FAId", usuarioAutenticado.getId());
                response.sendRedirect("verificar2FA.jsp");

            } catch (Exception e) {
                System.err.println("Erro no processo de 2FA: " + e.getMessage());
                request.setAttribute("erro", "Erro ao preparar a autenticação de 2 fatores. Tente novamente.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            }
            
        } else {
            request.setAttribute("erro", "E-mail ou senha inválidos.");
            
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}