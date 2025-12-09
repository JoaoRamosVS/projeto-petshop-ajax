package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import database.DBConnection;
import entities.Agendamento;
import entities.Funcionario;
import entities.Pet;
import entities.Servico;
import entities.Tutor;

public class AgendamentoDAO {

	public boolean agendarServico(Agendamento agendamento) {
		String sql = "INSERT INTO TB_AGENDAMENTO (SERVICO_ID, DT_AGENDAMENTO, CRIADOR_ID, PET_ID, FUNC_ID) VALUES (?, ?, ?, ?, ?)";

		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, agendamento.getServico().getId());
			ps.setTimestamp(2, agendamento.getDataAgendamento());
			ps.setInt(3, agendamento.getCriador().getId());
			ps.setInt(4, agendamento.getPet().getId());
			ps.setInt(5, agendamento.getFuncionario().getId());

			int linhasAfetadas = ps.executeUpdate();
			return linhasAfetadas > 0;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	public List<Timestamp> getHorariosOcupadosPorDiaEFuncionario(LocalDate data, int funcionarioId) {
		List<Timestamp> horariosOcupados = new ArrayList<>();
		String sql = "SELECT DT_AGENDAMENTO FROM TB_AGENDAMENTO WHERE DATE(DT_AGENDAMENTO) = ? AND FUNC_ID = ? AND STATUS = 'AGENDADO'";

		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setDate(1, java.sql.Date.valueOf(data));
			ps.setInt(2, funcionarioId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					horariosOcupados.add(rs.getTimestamp("DT_AGENDAMENTO"));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return horariosOcupados;
	}

	public List<Agendamento> listarAgendamentosPorUsuario(int usuarioId) {
		List<Agendamento> agendamentos = new ArrayList<>();
		String sql = "SELECT a.ID, a.DT_AGENDAMENTO, a.STATUS, p.NOME as PET_NOME, s.DESCRICAO as SERVICO_DESC, f.NOME as FUNC_NOME " + 
				"FROM TB_AGENDAMENTO a " + 
				"JOIN TB_PETS p ON a.PET_ID = p.ID " + 
				"JOIN TB_SERVICOS s ON a.SERVICO_ID = s.ID " + 
				"LEFT JOIN TB_FUNCIONARIOS f ON a.FUNC_ID = f.ID " + "WHERE a.CRIADOR_ID = ? " + 
				"ORDER BY a.DT_AGENDAMENTO DESC";

		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, usuarioId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Agendamento agendamento = new Agendamento();
				agendamento.setId(rs.getInt("ID"));
				agendamento.setDataAgendamento(rs.getTimestamp("DT_AGENDAMENTO"));
				agendamento.setStatus(rs.getString("STATUS"));

				Pet pet = new Pet();
				pet.setNome(rs.getString("PET_NOME"));
				agendamento.setPet(pet);

				Servico servico = new Servico();
				servico.setDescricao(rs.getString("SERVICO_DESC"));
				agendamento.setServico(servico);
				
				Funcionario funcionario = new Funcionario();
                funcionario.setNome(rs.getString("FUNC_NOME"));
                agendamento.setFuncionario(funcionario);

				agendamentos.add(agendamento);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return agendamentos;
	}

	public boolean cancelarAgendamento(int agendamentoId) {
		String sql = "UPDATE TB_AGENDAMENTO SET STATUS = 'CANCELADO' WHERE ID = ?";

		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, agendamentoId);
			int linhasAfetadas = ps.executeUpdate();
			return linhasAfetadas > 0;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
	public List<Agendamento> listarAgendamentosPorFuncionario(int funcionarioId) {
	    List<Agendamento> agendamentos = new ArrayList<>();
	    String sql = "SELECT a.ID AS AG_ID, a.DT_AGENDAMENTO, a.STATUS, " +
	                 "p.ID AS PET_ID, p.NOME AS PET_NOME, p.RACA, p.DT_NASCIMENTO, p.TAMANHO, p.PESO, p.OBS, p.OCORRENCIAS, " +
	                 "s.DESCRICAO AS SERVICO_DESC, " +
	                 "t.NOME AS TUTOR_NOME, t.TELEFONE AS TUTOR_TELEFONE " +
	                 "FROM TB_AGENDAMENTO a " +
	                 "JOIN TB_PETS p ON a.PET_ID = p.ID " +
	                 "JOIN TB_TUTORES t ON p.TUTOR_ID = t.ID " +
	                 "JOIN TB_SERVICOS s ON a.SERVICO_ID = s.ID " +
	                 "WHERE a.FUNC_ID = ? AND a.STATUS != 'CANCELADO' " +
	                 "ORDER BY " +
	                 "  CASE a.STATUS " +
	                 "    WHEN 'EM ANDAMENTO' THEN 1 " +
	                 "    WHEN 'AGENDADO' THEN 2 " +
	                 "    WHEN 'CONCLUÍDO' THEN 3 " +
	                 "    ELSE 4 " +
	                 "  END, " +
	                 "a.DT_AGENDAMENTO DESC";

	    try (DBConnection db = new DBConnection();
	         Connection conn = db.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {

	        ps.setInt(1, funcionarioId);
	        ResultSet rs = ps.executeQuery();

	        while (rs.next()) {
	            Agendamento ag = new Agendamento();
	            ag.setId(rs.getInt("AG_ID"));
	            ag.setDataAgendamento(rs.getTimestamp("DT_AGENDAMENTO"));
	            ag.setStatus(rs.getString("STATUS"));

	            Pet pet = new Pet();
	            pet.setId(rs.getInt("PET_ID"));
	            pet.setNome(rs.getString("PET_NOME"));
	            pet.setRaca(rs.getString("RACA"));
	            if (rs.getDate("DT_NASCIMENTO") != null) {
	                pet.setDtNascimento(rs.getDate("DT_NASCIMENTO").toLocalDate());
	            }
	            pet.setPeso(rs.getBigDecimal("PESO"));
	            pet.setObs(rs.getString("OBS"));
	            pet.setOcorrencias(rs.getString("OCORRENCIAS"));

	            int tamanhoId = rs.getInt("TAMANHO");
	            for (enums.TamanhoPetEnum t : enums.TamanhoPetEnum.values()) {
	                if (t.getId() == tamanhoId) {
	                    pet.setTamanho(t);
	                    break;
	                }
	            }
	            
	            ag.setPet(pet);
	            
	            Tutor tutor = new Tutor();
	            tutor.setNome(rs.getString("TUTOR_NOME"));
	            tutor.setTelefone(rs.getString("TUTOR_TELEFONE"));
	            pet.setTutor(tutor);

	            Servico servico = new Servico();
	            servico.setDescricao(rs.getString("SERVICO_DESC"));
	            ag.setServico(servico);
	            
	            agendamentos.add(ag);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return agendamentos;
	}

	public boolean atualizarStatusAgendamento(int agendamentoId, String novoStatus) {
	    String sql = "UPDATE TB_AGENDAMENTO SET STATUS = ? WHERE ID = ?";
	    try (DBConnection db = new DBConnection();
	         Connection conn = db.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        ps.setString(1, novoStatus);
	        ps.setInt(2, agendamentoId);
	        return ps.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}
}