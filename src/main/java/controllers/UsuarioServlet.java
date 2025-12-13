package controllers;

import com.google.gson.Gson;
import dao.UsuarioDAO; 
import entities.Usuario; 
import entities.Perfil; // Necessário para a lista/busca

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/UsuarioController")
public class UsuarioServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UsuarioDAO usuarioDAO = new UsuarioDAO();
    private Gson gson = new Gson();

    private static class CredenciaisDTO {
        Integer id;
        String novoEmail;
        String novaSenha;
    }

    private void sendJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    private void sendErrorResponse(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(new ErrorResponse(message)));
        out.flush();
    }

    private static class ErrorResponse {
        String error;
        public ErrorResponse(String error) {
            this.error = error;
        }
    }
    
    private static class SuccessResponse {
        String message;
        public SuccessResponse(String message) {
            this.message = message;
        }
    }
    
    private static class EmailCheckResponse {
        boolean exists;
        public EmailCheckResponse(boolean exists) {
            this.exists = exists;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'action' ausente.");
            return;
        }

        try {
            switch (action) {
                case "listAll":
                    listarUsuarios(response);
                    break;
                case "getById":
                    buscarUsuarioPorId(request, response);
                    break;
                case "checkEmail":
                    verificarSeEmailJaCadastrado(request, response);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação GET não reconhecida: " + action);
            }
        } catch (NumberFormatException e) {
             sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID inválido. Deve ser um número inteiro.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro interno do servidor: " + e.getMessage());
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'action' ausente.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
        
        try {
            switch (action) {
                case "updateData":
                    atualizarUsuario(jsonBody, response);
                    break;
                case "updateCredentials":
                    atualizarCredenciais(jsonBody, response);
                    break;
                case "reactivate":
                    reativarUsuario(request, response);
                    break;
                case "inactivate":
                    inativarUsuario(request, response);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação PUT não reconhecida: " + action);
            }
        } catch (NumberFormatException e) {
             sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID inválido. Deve ser um número inteiro.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação PUT: " + e.getMessage());
        }
    }

    private void listarUsuarios(HttpServletResponse response) throws IOException {
        List<Usuario> lista = usuarioDAO.listarUsuarios();
        sendJsonResponse(response, lista);
    }
    
    private void buscarUsuarioPorId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Usuario usuario = usuarioDAO.buscarUsuarioPorId(id);
        
        if (usuario != null) {
            sendJsonResponse(response, usuario);
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Usuário com ID " + id + " não encontrado.");
        }
    }
    
    private void verificarSeEmailJaCadastrado(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        if (email == null || email.isEmpty()) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'email' ausente.");
            return;
        }
        
        Boolean existe = usuarioDAO.verificarSeEmailJaCadastrado(email);
        
        if (existe != null) {
             sendJsonResponse(response, new EmailCheckResponse(existe));
        } else {
             sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao consultar e-mail no banco de dados.");
        }
    }

    private void atualizarUsuario(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            Usuario usuario = gson.fromJson(jsonBody, Usuario.class);
            if (usuario == null || usuario.getId() == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID do Usuário e/ou dados de atualização ausentes no JSON.");
                return;
            }

            boolean sucesso = usuarioDAO.atualizarUsuario(usuario);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Dados do Usuário ID " + usuario.getId() + " atualizados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao atualizar. Usuário ID " + usuario.getId() + " não encontrado ou erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido para atualização de dados: " + e.getMessage());
        }
    }

    private void atualizarCredenciais(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            CredenciaisDTO dto = gson.fromJson(jsonBody, CredenciaisDTO.class);
            
            if (dto == null || dto.id == null || (dto.novoEmail == null && dto.novaSenha == null)) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID, e pelo menos Email ou Senha são necessários para atualização de credenciais.");
                return;
            }

            boolean sucesso = usuarioDAO.atualizarCredenciais(dto.id, dto.novoEmail, dto.novaSenha);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Credenciais do Usuário ID " + dto.id + " atualizadas com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao atualizar credenciais. Usuário ID " + dto.id + " não encontrado ou e-mail já cadastrado.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido para atualização de credenciais: " + e.getMessage());
        }
    }

    private void reativarUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        if (email == null || email.isEmpty()) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'email' ausente.");
            return;
        }
        
        boolean sucesso = usuarioDAO.reativarUsuario(email);
        
        if (sucesso) {
            sendJsonResponse(response, new SuccessResponse("Usuário com e-mail '" + email + "' reativado com sucesso."));
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao reativar. Usuário com e-mail '" + email + "' não encontrado.");
        }
    }

    private void inativarUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        if (email == null || email.isEmpty()) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'email' ausente.");
            return;
        }
        
        boolean sucesso = usuarioDAO.inativarUsuario(email);
        
        if (sucesso) {
            sendJsonResponse(response, new SuccessResponse("Usuário com e-mail '" + email + "' inativado com sucesso."));
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao inativar. Usuário com e-mail '" + email + "' não encontrado.");
        }
    }
}