package controllers;

import dao.UsuarioDAO; // Certifique-se de que esta classe está disponível
import entities.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LoginController")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UsuarioDAO usuarioDAO;

    public LoginServlet() {
        this.usuarioDAO = new UsuarioDAO(); // Instancia o DAO
    }

    /**
     * Recebe e processa as credenciais de login via POST do index.jsp.
     */
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
            HttpSession session = request.getSession();
            
            session.setAttribute("usuarioLogado", usuarioAutenticado);
            
            String paginaDestino = determinarPaginaDestino(usuarioAutenticado.getPerfil().getId()); 
            response.sendRedirect(paginaDestino);
            
        } else {
            request.setAttribute("erro", "E-mail ou senha inválidos.");
            
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
    
    private String determinarPaginaDestino(int perfilId) {
        switch (perfilId) {
            case 1: 
                return "admin/home.jsp"; 
            case 2: 
                return "tutor/home.jsp"; 
            case 3: 
                return "funcionario/home.jsp"; 
            default:
                return "index.jsp";
        }
    }
}