package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import database.DBConnection;
import entities.Pet;
import entities.Tutor;
import entities.Usuario;

public class TutorDAO {

	public List<Tutor> listarTutoresComNomeECPF() {
		List<Tutor> listaDeTutores = new ArrayList<>();
		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT ID, NOME, CPF FROM TB_TUTORES ORDER BY NOME");
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Tutor tutor = new Tutor();
				tutor.setId(rs.getInt("ID"));
				tutor.setNome(rs.getString("NOME"));
				tutor.setCpf(rs.getString("CPF"));
				listaDeTutores.add(tutor);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return listaDeTutores;
	}

	public List<Tutor> listarTutores() {
		List<Tutor> listaDeTutores = new ArrayList<>();
		try (DBConnection db = new DBConnection();
				Connection conn = db.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT TT.ID, TT.NOME, TT.CPF, TT.TELEFONE, TU.EMAIL FROM TB_TUTORES AS TT INNER JOIN TB_USUARIOS AS TU ON TT.USUARIO_ID = TU.ID WHERE TU.ATIVO = 'S' ORDER BY NOME;");
				ResultSet rs = ps.executeQuery()) {
			while(rs.next()) {
				Tutor tutor = new Tutor();
				Usuario usuario = new Usuario();
				tutor.setId(rs.getInt("ID"));
				tutor.setNome(rs.getString("NOME"));
				tutor.setCpf(rs.getString("CPF"));
				tutor.setTelefone(rs.getString("TELEFONE"));
				usuario.setEmail(rs.getString("EMAIL"));
				tutor.setUsuario(usuario);
				listaDeTutores.add(tutor);
			}
		}
		catch (SQLException e) {
			e.printStackTrace();
		}
		return listaDeTutores;
	}

	public Tutor buscarTutorPorId(int id) {
	    Tutor tutor = null;
	    try (DBConnection db = new DBConnection();
	         Connection conn = db.getConnection();
	         PreparedStatement ps = conn.prepareStatement("SELECT T.*, U.EMAIL FROM TB_TUTORES T JOIN TB_USUARIOS U ON T.USUARIO_ID = U.ID WHERE T.ID = ?")) {
	        ps.setInt(1, id);
	        ResultSet rs = ps.executeQuery();
	        if (rs.next()) {
	            tutor = new Tutor();
	            Usuario usuario = new Usuario();
	            tutor.setId(rs.getInt("ID"));
	            tutor.setNome(rs.getString("NOME"));
	            tutor.setCpf(rs.getString("CPF"));
	            tutor.setEndereco(rs.getString("ENDERECO"));
	            tutor.setBairro(rs.getString("BAIRRO"));
	            tutor.setCidade(rs.getString("CIDADE"));
	            tutor.setUf(rs.getString("UF"));
	            tutor.setCep(rs.getString("CEP"));
	            tutor.setTelefone(rs.getString("TELEFONE"));
	            usuario.setEmail(rs.getString("EMAIL"));
	            tutor.setUsuario(usuario);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return tutor;
	}

	public boolean cadastrarNovoTutor(Tutor tutor, Usuario usuario) {
		Connection conn = null;
		UsuarioDAO usuarioDAO = new UsuarioDAO();
		try (DBConnection db = new DBConnection()) {
			conn = db.getConnection();
			conn.setAutoCommit(false);
			if (!usuarioDAO.verificarSeEmailJaCadastrado(usuario.getEmail())) {
				String sqlUsuario = "INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES (?, ?, ?)";
				try (PreparedStatement psUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
					psUsuario.setString(1, usuario.getEmail());
					psUsuario.setString(2, usuario.getSenha());
					psUsuario.setInt(3, 2); // Perfil ID 2 = Tutor

					if (psUsuario.executeUpdate() > 0) {
						try (ResultSet generatedKeys = psUsuario.getGeneratedKeys()) {
							if (generatedKeys.next()) {
								int idNovoUsuario = generatedKeys.getInt(1);
								String sqlTutor = "INSERT INTO TB_TUTORES (NOME, CPF, TELEFONE, CEP, USUARIO_ID) VALUES (?, ?, ?, ?, ?)";
								try (PreparedStatement psTutor = conn.prepareStatement(sqlTutor)) {
									psTutor.setString(1, tutor.getNome());
									psTutor.setString(2, tutor.getCpf());
									psTutor.setString(3, tutor.getTelefone());
									psTutor.setString(4, tutor.getCep());
									psTutor.setInt(5, idNovoUsuario);
									psTutor.executeUpdate();
								}
							} else {
								throw new SQLException("Falha ao obter o ID do usuário.");
							}
						}
					}
				}
				conn.commit();
				return true;
			} else {
				throw new SQLException("E-mail já cadastrado.");
			}
		} catch (SQLException e) {
			System.err.println("Erro ao cadastrar tutor: " + e.getMessage());
			try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
			return false;
		}
	}
	
	public boolean atualizarTutor(Tutor tutor) {
        String sql = "UPDATE TB_TUTORES SET ENDERECO = ?, BAIRRO = ?, CIDADE = ?, UF = ?, CEP = ?, TELEFONE = ? WHERE ID = ?";
        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tutor.getEndereco());
            ps.setString(2, tutor.getBairro());
            ps.setString(3, tutor.getCidade());
            ps.setString(4, tutor.getUf());
            ps.setString(5, tutor.getCep());
            ps.setString(6, tutor.getTelefone());
            ps.setInt(7, tutor.getId());
            int linhasAfetadas = ps.executeUpdate();
            return linhasAfetadas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
	
	public Tutor buscarTutorPorUsuarioId(int usuarioId) {
	    String sql = "SELECT * FROM TB_TUTORES WHERE USUARIO_ID = ?";
	    Tutor tutor = null;
	    try (DBConnection db = new DBConnection();
	         Connection conn = db.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        ps.setInt(1, usuarioId);
	        try (ResultSet rs = ps.executeQuery()) {
	            if (rs.next()) {
	                tutor = new Tutor();
	                tutor.setId(rs.getInt("ID"));
	                tutor.setNome(rs.getString("NOME"));
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return tutor;
	}

	public boolean cadastrarTutorComPet(Tutor tutor, Usuario usuario, Pet pet) {
	    Connection conn = null;
	    UsuarioDAO usuarioDAO = new UsuarioDAO();
	    try (DBConnection db = new DBConnection()) {
	        conn = db.getConnection();
	        conn.setAutoCommit(false);

	        if (!usuarioDAO.verificarSeEmailJaCadastrado(usuario.getEmail())) {
	            String sqlUsuario = "INSERT INTO TB_USUARIOS (EMAIL, SENHA, PERFIL_ID) VALUES (?, ?, ?)";
	            try (PreparedStatement psUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
	                psUsuario.setString(1, usuario.getEmail());
	                psUsuario.setString(2, usuario.getSenha());
	                psUsuario.setInt(3, 2); // Perfil ID 2 = Tutor

	                if (psUsuario.executeUpdate() > 0) {
	                    try (ResultSet generatedKeys = psUsuario.getGeneratedKeys()) {
	                        if (generatedKeys.next()) {
	                            int idNovoUsuario = generatedKeys.getInt(1);
	                            
	                            String sqlTutor = "INSERT INTO TB_TUTORES (NOME, CPF, ENDERECO, BAIRRO, CIDADE, UF, CEP, TELEFONE, USUARIO_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
	                            try (PreparedStatement psTutor = conn.prepareStatement(sqlTutor, Statement.RETURN_GENERATED_KEYS)) {
	                                psTutor.setString(1, tutor.getNome());
	                                psTutor.setString(2, tutor.getCpf());
	                                psTutor.setString(3, tutor.getEndereco());
	                                psTutor.setString(4, tutor.getBairro());
	                                psTutor.setString(5, tutor.getCidade());
	                                psTutor.setString(6, tutor.getUf());
	                                psTutor.setString(7, tutor.getCep());
	                                psTutor.setString(8, tutor.getTelefone());
	                                psTutor.setInt(9, idNovoUsuario);

	                                if (psTutor.executeUpdate() > 0) {
	                                    try (ResultSet tutorKeys = psTutor.getGeneratedKeys()) {
	                                        if (tutorKeys.next()) {
	                                            int idNovoTutor = tutorKeys.getInt(1);

	                                            String sqlPet = "INSERT INTO TB_PETS (NOME, RACA, DT_NASCIMENTO, TAMANHO, PESO, TUTOR_ID) VALUES (?, ?, ?, ?, ?, ?)";
	                                            try(PreparedStatement psPet = conn.prepareStatement(sqlPet)) {
	                                                psPet.setString(1, pet.getNome());
	                                                psPet.setString(2, pet.getRaca());
	                                                psPet.setDate(3, java.sql.Date.valueOf(pet.getDtNascimento()));
	                                                psPet.setInt(4, pet.getTamanho().getId());
	                                                psPet.setBigDecimal(5, pet.getPeso());
	                                                psPet.setInt(6, idNovoTutor);
	                                                psPet.executeUpdate();
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        } else {
	                            throw new SQLException("Falha ao obter o ID do usuário.");
	                        }
	                    }
	                }
	            }
	            conn.commit();
	            return true;
	        } else {
	            throw new SQLException("E-mail já cadastrado.");
	        }
	    } catch (SQLException e) {
	        System.err.println("Erro ao cadastrar tutor com pet: " + e.getMessage());
	        try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
	        return false;
	    }
	}
}