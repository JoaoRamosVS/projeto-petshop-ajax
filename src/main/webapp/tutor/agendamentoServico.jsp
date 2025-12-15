<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="entities.Usuario" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");

    if (usuario == null || usuario.getPerfil() == null || usuario.getPerfil().getId() != 2) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String emailUsuario = usuario.getEmail() != null ? usuario.getEmail() : "Tutor";
    Integer usuarioId = usuario.getId(); 
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CentralPet</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #e9ecef;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #007bff;
            text-align: center;
            margin-bottom: 25px;
            font-size: 1.8em;
        }
        .user-info {
            text-align: right;
            margin-bottom: 20px;
            font-size: 1.1em;
            color: #6c757d;
        }
        .btn-back { margin-bottom: 20px; text-decoration: none; color: #007bff; font-weight: bold; display: inline-block; }
        .btn-back i { margin-right: 5px; }

        .form-section {
            border: 1px solid #dee2e6;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 6px;
        }
        .form-section h3 {
            color: #007bff;
            margin-top: 0;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .row {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
        }
        .row > div {
            flex: 1;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #495057;
        }
        input[type="date"], input[type="time"], select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
        }
        
        #horariosDisponiveis {
            border: 1px solid #007bff;
            padding: 15px;
            border-radius: 6px;
            margin-top: 15px;
            display: none; 
        }
        .horarios-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }
        .horario-item {
            padding: 8px;
            text-align: center;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .horario-disponivel {
            background-color: #d4edda; 
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .horario-disponivel:hover {
            background-color: #28a745;
            color: white;
        }
        .horario-ocupado {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            cursor: not-allowed;
            opacity: 0.6;
        }
        .horario-selecionado {
            background-color: #007bff !important;
            color: white !important;
            border: 1px solid #0056b3 !important;
            font-weight: bold;
        }
        
        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #28aa9a; 
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1.1em;
            margin-top: 20px;
            transition: background-color 0.3s;
        }
        button[type="submit"]:hover {
            background-color: #218579;
        }
        .alert { 
            padding: 15px; 
            margin-bottom: 20px; 
            border: 1px solid transparent;
            border-radius: 4px;
            text-align: center;
            font-weight: bold;
        }
        .alert-error {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="user-info">
        Bem-vindo(a), <%= emailUsuario %> 
        <span style="margin-left: 15px;">|</span>
        <a href="<%= request.getContextPath() %>/LogoutController" style="color: #dc3545; text-decoration: none;">Sair</a>
    </div>
    
    <a href="<%= request.getContextPath() %>/tutor/home.jsp" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
    
    <h1>Agendamento de Serviço</h1>
    
    <div id="loadingMessage" style="text-align: center; margin-bottom: 20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>
    <div id="statusMessage" class="alert" style="display:none;"></div>

    <form id="agendamentoForm" style="display:none;">
        
        <input type="hidden" id="usuarioId" value="<%= usuarioId %>">

        <div class="form-section">
            <h3><i class="fas fa-list-alt"></i> Detalhes do Serviço</h3>
            <div class="row">
                <div>
                    <label for="petId">Selecione o Pet:</label>
                    <select id="petId" required>
                        <option value="">-- Carregando Pets --</option>
                    </select>
                </div>
                <div>
                    <label for="servicoId">Serviço Desejado:</label>
                    <select id="servicoId" required>
                        <option value="">-- Carregando Serviços --</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div>
                    <label for="funcionarioId">Funcionário (Opcional, mas necessário para agenda):</label>
                    <select id="funcionarioId">
                        <option value="">-- Selecione um Funcionário --</option>
                    </select>
                </div>
                <div>
                    <label for="dataAgendamento">Selecione a Data:</label>
                    <input type="date" id="dataAgendamento" required>
                </div>
            </div>
        </div>

        <div id="horariosDisponiveis" class="form-section">
            <h3><i class="fas fa-clock"></i> Horários Disponíveis (<span id="dataSelecionada"></span>)</h3>
            
            <p id="horariosInfo" style="margin-bottom: 10px;"></p>
            
            <div id="horariosGrid" class="horarios-grid">
                </div>
            <input type="hidden" id="horarioSelecionado" required>
        </div>
        
        <button type="submit"><i class="fas fa-calendar-check"></i> Finalizar Agendamento</button>
    </form>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>
<script type="text/javascript">
    const contextPath = '<%= request.getContextPath() %>';
    const currentUsuarioId = $('#usuarioId').val();
    
    const HORARIOS_BASE = ["09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00", "17:00"];
    
    const REGRAS_CARGO = {
            "Tosa": "Tosador",
            "Banho": "Tosador",
            "Banho e Tosa": "Tosador",
            "Consulta Médica": "Veterinário"
        };
    
    let todosServicos = [];
    let todosFuncionarios = [];

    $(document).ready(function() {
        
        const $loadingMessage = $('#loadingMessage');
        const $statusMessage = $('#statusMessage');
        const $form = $('#agendamentoForm');
        const $horariosDisponiveis = $('#horariosDisponiveis');
        const $horarioSelecionado = $('#horarioSelecionado');
        const $funcionarioSelect = $('#funcionarioId');

        let tutorId = null; 
        
        function displayMessage(type, message) {
            $statusMessage.removeClass('alert-success alert-error').addClass('alert-' + type).text(message).show();
            setTimeout(() => $statusMessage.fadeOut(), 7000);
        }
        
        function inicializarDados() {
		    const petPromise = carregarPets();
		    const servicoPromise = carregarServicos();
		    const funcionarioPromise = carregarFuncionarios();
		    const tutorPromise = buscarTutorId(); 
		
		    $form.hide();
		    $loadingMessage.show();
		    
		    Promise.all([petPromise, servicoPromise, funcionarioPromise, tutorPromise])
		        .then(([pets, servicos, funcionarios, idTutor]) => {
		            tutorId = idTutor; 
		            $form.show();
		        })
		        .catch(error => {
		            console.error("Erro na inicialização:", error);
		            displayMessage('error', 'Falha ao carregar dados essenciais: ' + error.message);
		        })
		        .finally(() => {
		            $loadingMessage.hide();
		        });
		}
		
		function buscarTutorId() {
		    return new Promise((resolve, reject) => {
		        $.ajax({
		            url: contextPath + '/TutorController', 
		            data: { action: 'getByUserId', usuarioId: currentUsuarioId }, 
		            type: 'GET',
		            dataType: 'json',
		            success: function(tutor) {
		                if (tutor && tutor.id) {
		                    resolve(tutor.id);
		                } else {
		                    reject(new Error("Tutor não encontrado para o usuário logado."));
		                }
		            },
		            error: function(xhr, status, error) {
		                reject(new Error("Falha ao buscar ID do Tutor. Status: " + xhr.status));
		            }
		        });
		    });
		}
		
		function carregarPets() {
		    return new Promise((resolve, reject) => {
		        $.ajax({
		            url: contextPath + '/PetController', 
		            data: { action: 'getByUserId', userId: currentUsuarioId },
		            type: 'GET',
		            dataType: 'json',
		            success: function(data) {
		                const $select = $('#petId');
		                $select.empty().append('<option value="">-- Selecione o Pet --</option>');
		                
		                if (data.length > 0) {
		                    $.each(data, function(index, pet) {
		                        $select.append('<option value="' + pet.id + '">' + pet.nome +'</option>');
		                    });
		                    resolve(data);
		                } else {
		                    $select.append('<option value="" disabled>Nenhum pet ativo encontrado.</option>');
		                    resolve([]); 
		                }
		            },
		            error: function(xhr, status, error) {
		                reject(new Error("Falha ao carregar Pets. Status: " + xhr.status));
		            }
		        });
		    });
		}
		
		function carregarServicos() {
		    return new Promise((resolve, reject) => {
		        $.ajax({
		            url: contextPath + '/ServicoController', 
		            data: { action: 'listAll' },
		            type: 'GET',
		            dataType: 'json',
		            success: function(data) {
		                todosServicos = data; 
		                const $select = $('#servicoId');
		                $select.empty().append('<option value="">-- Selecione o Serviço --</option>');
		                
		                if (data.length > 0) {
		                    $.each(data, function(index, servico) {
		                        $select.append('<option value="' + servico.id + '" data-nome-servico="' + servico.descricao + '">' + servico.descricao + ' (R$ ' + servico.valor + ')</option>');
		                    });
		                    resolve(data);
		                } else {
		                    $select.append('<option value="" disabled>Nenhum serviço encontrado.</option>');
		                    reject(new Error("Nenhum Serviço disponível."));
		                }
		            },
		            error: function(xhr, status, error) {
		                reject(new Error("Falha ao carregar Serviços. Status: " + xhr.status));
		            }
		        });
		    });
		}
		
		function carregarFuncionarios() {
		    return new Promise((resolve, reject) => {
		        $.ajax({
		            url: contextPath + '/FuncionarioController', 
		            data: { action: 'listAll' }, 
		            type: 'GET',
		            dataType: 'json',
		            success: function(data) {
		                todosFuncionarios = data; 
		                $funcionarioSelect.empty().append('<option value="">-- Selecione um Serviço primeiro --</option>');
		                resolve(data);
		            },
		            error: function(xhr, status, error) {
		                reject(new Error("Falha ao carregar Funcionários. Status: " + xhr.status));
		            }
		        });
		    });
		}
        
        $('#servicoId').change(function() {
            const $selectedOption = $(this).find('option:selected');
            const nomeServico = $selectedOption.data('nome-servico');
            
            filtrarFuncionariosPorServico(nomeServico);
            
            $('#dataAgendamento').trigger('change'); 
        });
        
        function filtrarFuncionariosPorServico(nomeServico) {
            $funcionarioSelect.empty();
            $funcionarioSelect.removeAttr('disabled');
            $funcionarioSelect.attr('required', 'required'); 

            if (!nomeServico) {
                $funcionarioSelect.append('<option value="">-- Selecione um Serviço --</option>');
                $funcionarioSelect.attr('disabled', 'disabled');
                return;
            }

            const cargoRequerido = REGRAS_CARGO[nomeServico];
            
            console.log("Serviço Selecionado:", nomeServico);
            console.log("Cargo Requerido (REGRAS_CARGO):", cargoRequerido);
            console.log("Primeiro Funcionário Carregado para Checagem:", todosFuncionarios[0]);
            
            if (!cargoRequerido) {
                displayMessage('error', `Regra de cargo não definida para o serviço: ${nomeServico}.`);
                $funcionarioSelect.append('<option value="">-- Erro de Mapeamento --</option>');
                return;
            }
            
            const funcionariosFiltrados = todosFuncionarios.filter(func => {
                return func.cargo === cargoRequerido;
            });

            if (funcionariosFiltrados.length > 0) {
                $funcionarioSelect.append('<option value="">-- Selecione o ' + cargoRequerido + ' --</option>');
                $.each(funcionariosFiltrados, function(index, func) {
                    $funcionarioSelect.append('<option value="' + func.id + '">' + func.nome + '</option>');
                });
            } else {
                $funcionarioSelect.append('<option value="">-- Nenhum Funcionário disponível --</option>');
                $funcionarioSelect.attr('disabled', 'disabled');
                displayMessage('error', `Não há ${cargoRequerido}s disponíveis para este serviço.`);
            }
        }

       $('#dataAgendamento, #funcionarioId').change(function() {
            const data = $('#dataAgendamento').val();
            const funcionarioId = $('#funcionarioId').val();
            
            $horarioSelecionado.val('');
            
            if (data && funcionarioId) {
                carregarHorariosOcupados(data, funcionarioId);
            } else {
                $horariosDisponiveis.hide();
            }
        });
        
       function carregarHorariosOcupados(data, funcionarioId) {
           $('#horariosGrid').html('<p style="text-align: center;"><i class="fas fa-spinner fa-spin"></i> Verificando disponibilidade...</p>');
           $horariosDisponiveis.show();
           
           $.ajax({
               url: contextPath + '/AgendamentoController',
               data: { action: 'getHorariosOcupados', data: data, funcionarioId: funcionarioId },
               type: 'GET',
               dataType: 'json',
               success: function(horariosOcupadosMap) {
                   renderizarHorarios(horariosOcupadosMap);
               },
               error: function(xhr) {
                   $('#horariosGrid').html('<p style="color: red; text-align: center;">Erro ao carregar agenda. Tente novamente.</p>');
                   displayMessage('error', 'Falha ao carregar a agenda do funcionário.');
               }
           });
       }
        
        function renderizarHorarios(horariosOcupadosMap) {
            const $grid = $('#horariosGrid');
            $grid.empty();
            let countDisponivel = 0;
            
            $('#dataSelecionada').text(moment($('#dataAgendamento').val()).format('DD/MM/YYYY'));
            
            HORARIOS_BASE.forEach(horario => {
                const dateTimeKey = $('#dataAgendamento').val() + 'T' + horario;
                const status = horariosOcupadosMap[dateTimeKey]; 
                
                const isOcupado = status && status !== 'CANCELADO'; 
                
                let itemClass = 'horario-item';
                let title = horario;
                
                if (isOcupado) {
                    itemClass += ' horario-ocupado';
                    title += ` - ${status}`;
                } else {
                    itemClass += ' horario-disponivel';
                    countDisponivel++;
                }

                $grid.append('<div class="' + itemClass + '" data-hora="' + horario + '" title="' + title + '">' + horario + '</div>');
            });
            
            if (countDisponivel === 0) {
                 $('#horariosInfo').text('Nenhum horário disponível para esta data e funcionário.');
            } else {
                 $('#horariosInfo').text(`Total de ${countDisponivel} horários disponíveis.`);
            }

            $('.horario-disponivel').click(function() {
                $('.horario-item').removeClass('horario-selecionado');
                $(this).addClass('horario-selecionado');
                $horarioSelecionado.val($(this).data('hora'));
            });
        }
        
        $form.submit(function(e) {
            e.preventDefault();
            $statusMessage.hide(); 

            const data = $('#dataAgendamento').val();
            const horario = $horarioSelecionado.val();
            const petId = $('#petId').val();
            const servicoId = $('#servicoId').val();
            const funcionarioId = $('#funcionarioId').val();
            
            if (!data || !horario || !petId || !servicoId) {
                displayMessage('error', 'Por favor, preencha todos os campos e selecione um horário disponível.');
                return;
            }

            if (!confirm(`Confirma o agendamento para ${data} às ${horario}?`)) {
                return;
            }

            const dataHoraCompleta = data + 'T' + horario;

            var dadosAgendamento = {
                dataHora: dataHoraCompleta,
                petId: parseInt(petId),
                servicoId: parseInt(servicoId),
                funcionarioId: funcionarioId ? parseInt(funcionarioId) : null,
                status: 'PENDENTE',
                criadorId: parseInt(currentUsuarioId)
            };
            
            $.ajax({
                url: contextPath + '/AgendamentoController?action=create',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(dadosAgendamento),
                dataType: 'json',
                success: function(response) {
                    displayMessage('success', response.message);
                    $form[0].reset();
                    $horariosDisponiveis.hide();
                },
                error: function(xhr) {
                    let errorMsg = "Falha ao criar agendamento.";
                    try {
                        const jsonResponse = JSON.parse(xhr.responseText);
                        errorMsg = jsonResponse.error || xhr.statusText;
                    } catch (e) {
                        errorMsg += " Status: " + xhr.status;
                    }
                    displayMessage('error', errorMsg);
                }
            });
        });
        inicializarDados();
    });
</script>

</body>
</html>