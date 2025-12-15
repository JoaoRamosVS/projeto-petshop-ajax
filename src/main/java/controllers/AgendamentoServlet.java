package controllers;

import com.google.gson.Gson;
import dao.AgendamentoDAO; 
import entities.Agendamento; 
import entities.Pet; 
import entities.Funcionario; 
import entities.Servico;
import entities.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@WebServlet("/AgendamentoController")
public class AgendamentoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AgendamentoDAO agendamentoDAO = new AgendamentoDAO();
    private Gson gson = new Gson();
    
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private static final DateTimeFormatter TIME_KEY_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private static class AgendamentoDTO {
        Integer id;
        String dataHora; 
        Integer petId;
        Integer funcionarioId;
        Integer servicoId;
        Integer criadorId;
        String status;
    }

    private static class StatusUpdateDTO {
        Integer id;
        String novoStatus;
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
                case "getByUsuarioId": 
                    listarAgendamentosPorUsuario(request, response);
                    break;
                case "getByFuncionarioId": 
                    listarAgendamentosPorFuncionario(request, response);
                    break;
                case "getHorariosOcupados": 
                    getHorariosOcupados(request, response);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação GET não reconhecida: " + action);
            }
        } catch (NumberFormatException e) {
             sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID de usuário ou funcionário inválido.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro interno do servidor: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || !action.equals("create")) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação POST não reconhecida. Use action=create.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));

        try {
            cadastrarAgendamento(jsonBody, response); 
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação POST (Cadastro de Agendamento): " + e.getMessage());
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
        
        try {
            if (action == null) {
                 sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'action' ausente.");
                 return;
            }
            
            switch (action) {
                case "updateStatus":
                    atualizarStatusAgendamento(jsonBody, response); 
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação PUT não reconhecida: " + action);
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação PUT: " + e.getMessage());
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || !action.equals("delete")) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação DELETE não reconhecida. Use action=delete.");
            return;
        }

        try {
            deletarAgendamento(request, response); 
        } catch (NumberFormatException e) {
             sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID inválido. Deve ser um número inteiro.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação DELETE: " + e.getMessage());
        }
    }

    private void listarAgendamentosPorUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String usuarioIdParam = request.getParameter("usuarioId");
        if (usuarioIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'usuarioId' ausente.");
            return;
        }
        int usuarioId = Integer.parseInt(usuarioIdParam);
        
        List<Agendamento> agendamentos = agendamentoDAO.listarAgendamentosPorUsuario(usuarioId);
        sendJsonResponse(response, agendamentos);
    }

    private void listarAgendamentosPorFuncionario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String funcionarioIdParam = request.getParameter("funcionarioId");
        if (funcionarioIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'funcionarioId' ausente.");
            return;
        }
        int funcionarioId = Integer.parseInt(funcionarioIdParam);
        
        List<Agendamento> agendamentos = agendamentoDAO.listarAgendamentosPorFuncionario(funcionarioId);
        sendJsonResponse(response, agendamentos);
    }
    
    private void getHorariosOcupados(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String dataParam = request.getParameter("data"); 
        String funcionarioIdParam = request.getParameter("funcionarioId");
        
        if (dataParam == null || funcionarioIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetros 'data' e 'funcionarioId' são obrigatórios.");
            return;
        }
        
        try {
            int funcionarioId = Integer.parseInt(funcionarioIdParam);
            LocalDate date = LocalDate.parse(dataParam);
            
            List<Timestamp> timestampsOcupados = agendamentoDAO.getHorariosOcupadosPorDiaEFuncionario(date, funcionarioId);
            
            Map<String, String> horariosOcupadosMap = new HashMap<>();
            
            for (Timestamp ts : timestampsOcupados) {
                LocalDateTime ldt = ts.toLocalDateTime();
                String key = ldt.format(TIME_KEY_FORMATTER);
                
                horariosOcupadosMap.put(key, "OCUPADO"); 
            }
            
            sendJsonResponse(response, horariosOcupadosMap);

        } catch (NumberFormatException e) {
             sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID de funcionário inválido.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao processar horários ocupados: " + e.getMessage());
        }
    }

    private void cadastrarAgendamento(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            AgendamentoDTO dto = gson.fromJson(jsonBody, AgendamentoDTO.class);
            
            if (dto == null || dto.dataHora == null || dto.petId == null || dto.servicoId == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Dados incompletos: Data/Hora, Pet e Serviço são obrigatórios.");
                return;
            }

            Agendamento agendamento = new Agendamento();
            
            LocalDateTime dataHora = LocalDateTime.parse(dto.dataHora, DATE_TIME_FORMATTER);
            Timestamp dataAgendamento = Timestamp.valueOf(dataHora);
            agendamento.setDataAgendamento(dataAgendamento);
            
            agendamento.setPet(new Pet(dto.petId));
            agendamento.setServico(new Servico(dto.servicoId));
            agendamento.setFuncionario(dto.funcionarioId != null ? new Funcionario(dto.funcionarioId) : null);
            agendamento.setStatus(dto.status != null ? dto.status : "PENDENTE");
            agendamento.setCriador(new Usuario(dto.criadorId));
            
            boolean sucesso = agendamentoDAO.agendarServico(agendamento);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Agendamento criado com sucesso para o Pet ID " + dto.petId + "."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao cadastrar o agendamento. Conflito de horário ou dados inválidos.");
            }
        } catch (java.time.format.DateTimeParseException e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato de Data/Hora inválido. Esperado " + DATE_TIME_FORMATTER.toString() + ".");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou erro de processamento: " + e.getMessage());
        }
    }
    
    private void atualizarStatusAgendamento(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            StatusUpdateDTO dto = gson.fromJson(jsonBody, StatusUpdateDTO.class);

            if (dto == null || dto.id == null || dto.novoStatus == null || dto.novoStatus.trim().isEmpty()) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID e novoStatus são obrigatórios para a atualização de status.");
                return;
            }
            
            boolean sucesso = agendamentoDAO.atualizarStatusAgendamento(dto.id, dto.novoStatus);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Status do Agendamento ID " + dto.id + " atualizado para " + dto.novoStatus + "."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao atualizar o status. Agendamento ID " + dto.id + " não encontrado.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou erro de processamento na atualização de status: " + e.getMessage());
        }
    }
    
    private void deletarAgendamento(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'id' ausente.");
            return;
        }
        int id = Integer.parseInt(idParam);
        
        boolean sucesso = agendamentoDAO.cancelarAgendamento(id);
        
        if (sucesso) {
            sendJsonResponse(response, new SuccessResponse("Agendamento ID " + id + " cancelado com sucesso."));
        } else {
            sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao cancelar. Agendamento ID " + id + " não encontrado.");
        }
    }
}