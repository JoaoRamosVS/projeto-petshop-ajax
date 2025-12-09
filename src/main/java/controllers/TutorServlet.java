package controllers;

import com.google.gson.Gson;
import dao.TutorDAO;
import dao.UsuarioDAO;
import entities.Pet; 
import entities.Tutor;
import entities.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/TutorController")
public class TutorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TutorDAO tutorDAO = new TutorDAO();
    private Gson gson = new Gson();

    
    private static class CadastroDTO {
        Tutor tutor;
        Usuario usuario;
        Pet pet;
    }

    /**
     * Envia uma resposta JSON de sucesso.
     */
    private void sendJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    /**
     * Envia uma resposta JSON de erro com status 500.
     */
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
                    listarTutores(response);
                    break;
                case "listSimple":
                    listarTutoresComNomeECPF(response);
                    break;
                case "getById":
                    buscarTutorPorId(request, response);
                    break;
                case "getByUserId":
                    buscarTutorPorUsuarioId(request, response);
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
                case "createSimple": // Mapeia cadastrarNovoTutor(Tutor tutor, Usuario usuario)
                    cadastrarNovoTutor(jsonBody, response);
                    break;
                case "createWithPet": // Mapeia cadastrarTutorComPet(Tutor tutor, Usuario usuario, Pet pet)
                    cadastrarTutorComPet(jsonBody, response);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação POST não reconhecida: " + action);
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação " + action + ": " + e.getMessage());
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action != null && !action.equals("update")) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação PUT não reconhecida. Use action=update ou deixe vazio.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
        
        try {
            atualizarTutor(jsonBody, response);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação PUT (Atualização de Tutor): " + e.getMessage());
        }
    }
    
    private void listarTutoresComNomeECPF(HttpServletResponse response) throws IOException {
        List<Tutor> listaTutores = tutorDAO.listarTutoresComNomeECPF();
        sendJsonResponse(response, listaTutores);
    }

    private void listarTutores(HttpServletResponse response) throws IOException {
        List<Tutor> listaTutores = tutorDAO.listarTutores();
        sendJsonResponse(response, listaTutores);
    }

    private void buscarTutorPorId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'id' ausente.");
            return;
        }
        int id = Integer.parseInt(idParam);
        
        Tutor tutor = tutorDAO.buscarTutorPorId(id);
        
        if (tutor != null) {
            sendJsonResponse(response, tutor);
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Tutor com ID " + id + " não encontrado.");
        }
    }

    private void buscarTutorPorUsuarioId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String usuarioIdParam = request.getParameter("usuarioId");
        if (usuarioIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'usuarioId' ausente.");
            return;
        }
        int usuarioId = Integer.parseInt(usuarioIdParam);
        
        Tutor tutor = tutorDAO.buscarTutorPorUsuarioId(usuarioId);
        
        if (tutor != null) {
            sendJsonResponse(response, tutor);
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Tutor associado ao UsuarioID " + usuarioId + " não encontrado.");
        }
    }

    private void cadastrarNovoTutor(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            CadastroDTO dto = gson.fromJson(jsonBody, CadastroDTO.class);
            Tutor tutor = dto.tutor;
            Usuario usuario = dto.usuario;
            
            if (tutor == null || usuario == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Dados de Tutor e/ou Usuario ausentes no JSON.");
                return;
            }

            boolean sucesso = tutorDAO.cadastrarNovoTutor(tutor, usuario);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Tutor e Usuário cadastrados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao cadastrar. O e-mail pode já estar em uso ou houve erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para cadastro: " + e.getMessage());
        }
    }

    private void cadastrarTutorComPet(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            CadastroDTO dto = gson.fromJson(jsonBody, CadastroDTO.class);
            Tutor tutor = dto.tutor;
            Usuario usuario = dto.usuario;
            Pet pet = dto.pet;
            
            if (tutor == null || usuario == null || pet == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Dados de Tutor, Usuario e/ou Pet ausentes no JSON.");
                return;
            }

            boolean sucesso = tutorDAO.cadastrarTutorComPet(tutor, usuario, pet);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Tutor, Usuário e Pet cadastrados com sucesso (Transação)."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao cadastrar. O e-mail pode já estar em uso ou houve erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para cadastro com Pet: " + e.getMessage());
        }
    }

    private void atualizarTutor(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            // Deserializa o corpo JSON diretamente para um objeto Tutor
            Tutor tutor = gson.fromJson(jsonBody, Tutor.class);
            
            if (tutor == null || tutor.getId() == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID do Tutor e/ou dados de atualização ausentes no JSON.");
                return;
            }

            // O método atualizarTutor no DAO espera o ID e os campos de endereço preenchidos
            boolean sucesso = tutorDAO.atualizarTutor(tutor);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Dados do Tutor atualizados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao atualizar. Tutor com ID " + tutor.getId() + " não encontrado ou erro no banco de dados.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para atualização: " + e.getMessage());
        }
    }
}