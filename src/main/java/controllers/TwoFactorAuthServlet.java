package controllers;

import dao.UsuarioDAO;
import entities.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/TwoFactorAuthController")
public class TwoFactorAuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String codigo2fa = request.getParameter("codigo2fa");
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("usuario2FAId") == null || codigo2fa == null || codigo2fa.isEmpty()) {
            response.sendRedirect("index.jsp"); 
            return;
        }

        Integer usuarioId = (Integer) session.getAttribute("usuario2FAId");
        
        Usuario usuarioAutenticado = usuarioDAO.verificarEValidarCodigo2FA(usuarioId, codigo2fa);

        if (usuarioAutenticado != null) {
            session.removeAttribute("usuario2FAId");
            session.setAttribute("usuarioLogado", usuarioAutenticado);
            
            String paginaDestino = determinarPaginaDestino(usuarioAutenticado.getPerfil().getId()); 
            response.sendRedirect(paginaDestino);
        } else {
            request.setAttribute("erro", "Código 2FA inválido ou expirado.");
            request.getRequestDispatcher("verificar2FA.jsp").forward(request, response);
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