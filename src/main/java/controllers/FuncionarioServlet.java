package controllers;

import com.google.gson.Gson;
import dao.FuncionarioDAO; // DAO para acesso a dados de Funcionario
import entities.Funcionario; // Entidade Funcionario
import entities.Usuario; // Entidade Usuario

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/FuncionarioController")
public class FuncionarioServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FuncionarioDAO funcionarioDAO = new FuncionarioDAO();
    private Gson gson = new Gson(); 
    
    private static class CadastroFuncionarioDTO {
        Funcionario funcionario;
        Usuario usuario;
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
                    listarFuncionarios(response);
                    break;
                case "listGroomers":
                    listarTosadores(response);
                    break;
                case "listVets": 
                    listarVeterinarios(response);
                    break;
                case "getById": 
                    buscarFuncionarioPorId(request, response);
                    break;
                case "getByUserId":
                    buscarFuncionarioPorUsuarioId(request, response);
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'action' ausente.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));

        try {
            switch (action) {
                case "create": // Mapeia cadastrarNovoFuncionario(Funcionario, Usuario)
                    cadastrarNovoFuncionario(jsonBody, response);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação POST não reconhecida: " + action);
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação POST: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || !action.equals("update")) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação PUT não reconhecida. Deve ser action=update.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
        
        try {
            atualizarFuncionario(jsonBody, response);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação PUT (Atualização de Funcionário): " + e.getMessage());
        }
    }

    private void listarFuncionarios(HttpServletResponse response) throws IOException {
        List<Funcionario> lista = funcionarioDAO.listarFuncionarios();
        sendJsonResponse(response, lista);
    }
    
    private void listarTosadores(HttpServletResponse response) throws IOException {
        List<Funcionario> lista = funcionarioDAO.listarTosadores();
        sendJsonResponse(response, lista);
    }
    
    private void listarVeterinarios(HttpServletResponse response) throws IOException {
        List<Funcionario> lista = funcionarioDAO.listarVeterinarios();
        sendJsonResponse(response, lista);
    }

    private void buscarFuncionarioPorId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'id' ausente.");
            return;
        }
        int id = Integer.parseInt(idParam);
        
        Funcionario funcionario = funcionarioDAO.buscarFuncionarioPorId(id);
        
        if (funcionario != null) {
            sendJsonResponse(response, funcionario);
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Funcionário com ID " + id + " não encontrado.");
        }
    }
    
    private void buscarFuncionarioPorUsuarioId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String usuarioIdParam = request.getParameter("usuarioId");
        if (usuarioIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'usuarioId' ausente.");
            return;
        }
        int usuarioId = Integer.parseInt(usuarioIdParam);
        
        Funcionario funcionario = funcionarioDAO.buscarFuncionarioPorUsuarioId(usuarioId);
        
        if (funcionario != null) {
            sendJsonResponse(response, funcionario);
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Funcionário associado ao UsuarioID " + usuarioId + " não encontrado.");
        }
    }

    private void cadastrarNovoFuncionario(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            CadastroFuncionarioDTO dto = gson.fromJson(jsonBody, CadastroFuncionarioDTO.class);
            Funcionario funcionario = dto.funcionario;
            Usuario usuario = dto.usuario;
            
            if (funcionario == null || usuario == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Dados de Funcionário e/ou Usuário ausentes no JSON.");
                return;
            }
            
            boolean sucesso = funcionarioDAO.cadastrarNovoFuncionario(funcionario, usuario);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Funcionário e Usuário cadastrados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao cadastrar. O e-mail pode já estar em uso ou houve erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para cadastro: " + e.getMessage());
        }
    }

    private void atualizarFuncionario(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            Funcionario funcionario = gson.fromJson(jsonBody, Funcionario.class);
            
            if (funcionario == null || funcionario.getId() == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID do Funcionário e/ou dados de atualização ausentes no JSON.");
                return;
            }
            
            boolean sucesso = funcionarioDAO.atualizarFuncionario(funcionario);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Dados do Funcionário atualizados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao atualizar. Funcionário com ID " + funcionario.getId() + " não encontrado ou erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para atualização: " + e.getMessage());
        }
    }
}