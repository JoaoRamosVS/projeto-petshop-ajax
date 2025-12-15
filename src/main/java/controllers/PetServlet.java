package controllers;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import dao.PetDAO; 
import entities.Pet; 
import entities.Tutor;
import enums.TamanhoPetEnum;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

@WebServlet("/PetController")
public class PetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PetDAO petDAO = new PetDAO();
    private Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDate.class, new LocalDateAdapter())
            .registerTypeAdapter(TamanhoPetEnum.class, new TamanhoPetEnumTypeAdapter())
            .create();


    private static class CadastroPetDTO {
        String nome;
        String raca;
        String tamanho;
        String dataNascimento;
        BigDecimal peso;
        Tutor tutorSelecionado; 
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
	            case "getById": 
	                buscarPetsPorId(request, response);
	                break;
            	case "getByUserId": 
                    buscarPetsPorUsuario(request, response);
                    break;
                case "getByTutorId": 
                    buscarPetsPorTutor(request, response);
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
        if (action == null || !action.equals("create")) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Ação POST não reconhecida. Use action=create.");
            return;
        }
        
        String jsonBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));

        try {
            cadastrarPet(jsonBody, response); 
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação POST (Cadastro de Pet): " + e.getMessage());
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
            atualizarPet(jsonBody, response);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro na operação PUT (Atualização de Pet): " + e.getMessage());
        }
    }
    
    private void buscarPetsPorId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String petIdParam = request.getParameter("petId");
        if (petIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'petId' ausente.");
            return;
        }
        int petId = Integer.parseInt(petIdParam);
        
        Pet pet = petDAO.buscarPetPorId(petId);
        sendJsonResponse(response, pet);
    }
    
    private void buscarPetsPorTutor(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String tutorIdParam = request.getParameter("tutorId");
        if (tutorIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'tutorId' ausente.");
            return;
        }
        int tutorId = Integer.parseInt(tutorIdParam);
        
        List<Pet> pets = petDAO.listarPetsPorTutor(tutorId);
        sendJsonResponse(response, pets);
    }
    
    private void buscarPetsPorUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdParam = request.getParameter("userId");
        if (userIdParam == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Parâmetro 'tutorId' ausente.");
            return;
        }
        int userId = Integer.parseInt(userIdParam);
        
        List<Pet> pets = petDAO.listarPetsPorUsuario(userId);
        sendJsonResponse(response, pets);
    }

    private void cadastrarPet(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            CadastroPetDTO dto = gson.fromJson(jsonBody, CadastroPetDTO.class);
            
            if (dto == null || dto.tutorSelecionado == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Dados incompletos para cadastro: Tutor ID ausente.");
                return;
            }

            Pet pet = new Pet();
            pet.setNome(dto.nome);
            pet.setRaca(dto.raca);
            pet.setTamanho(TamanhoPetEnum.valueOf(dto.tamanho));
            
            if (dto.dataNascimento != null && !dto.dataNascimento.isEmpty()) {
                LocalDate dataNasc = LocalDate.parse(dto.dataNascimento);
                pet.setDtNascimento(dataNasc); 
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Data de Nascimento é obrigatória.");
                return;
            }
            // =========================================================
            
            pet.setPeso(dto.peso);
            pet.setTutor(dto.tutorSelecionado);
            
            boolean sucesso = petDAO.cadastrarPet(pet);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Pet cadastrado com sucesso para o Tutor ID " + dto.tutorSelecionado.getId() + "."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_CONFLICT, "Falha ao cadastrar o Pet. Verifique o Tutor ID.");
            }
        } catch (java.time.format.DateTimeParseException e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato de Data de Nascimento inválido. Esperado AAAA-MM-DD.");
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para cadastro: " + e.getMessage());
        }
    }

    private void atualizarPet(String jsonBody, HttpServletResponse response) throws IOException {
        try {
            Pet pet = gson.fromJson(jsonBody, Pet.class);
            
            if (pet == null || pet.getId() == null) {
                sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "ID do Pet ausente no JSON.");
                return;
            }
            
            boolean sucesso = petDAO.atualizarPet(pet);
            
            if (sucesso) {
                sendJsonResponse(response, new SuccessResponse("Dados do Pet ID " + pet.getId() + " atualizados com sucesso."));
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Falha ao atualizar. Pet ID " + pet.getId() + " não encontrado.");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Formato JSON inválido ou dados incompletos para atualização: " + e.getMessage());
        }
    }
    
    private static class LocalDateAdapter extends TypeAdapter<LocalDate> {
        private final DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE;

        @Override
        public void write(JsonWriter out, LocalDate value) throws IOException {
            if (value == null) {
                out.nullValue();
            } else {
                out.value(formatter.format(value));
            }
        }

        @Override
        public LocalDate read(JsonReader in) throws IOException {
            if (in.peek() == com.google.gson.stream.JsonToken.NULL) {
                in.nextNull();
                return null;
            }
            return LocalDate.parse(in.nextString(), formatter);
        }
    }
    
    private static class TamanhoPetEnumTypeAdapter extends TypeAdapter<TamanhoPetEnum> {
        @Override
        public void write(JsonWriter out, TamanhoPetEnum value) throws IOException {
            if (value == null) {
                out.nullValue();
                return;
            }
            out.beginObject();
            out.name("id").value(value.getId());
            out.name("descricao").value(value.getDescricao());
            out.endObject();
        }

        @Override
        public TamanhoPetEnum read(JsonReader in) throws IOException {
            if (in.peek() == com.google.gson.stream.JsonToken.NULL) {
                in.nextNull();
                return null;
            }
            
            in.beginObject();
            
            if (!in.nextName().equals("id")) {
                throw new IOException("Esperado campo 'id' para TamanhoPetEnum.");
            }
            
            int id = in.nextInt(); 
            
            in.endObject();
            
            TamanhoPetEnum tamanho = TamanhoPetEnum.fromId(id); 
            if (tamanho == null) {
                throw new IOException("ID de TamanhoPet inválido: " + id);
            }
            return tamanho;
        }
    }
}