package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import database.DBConnection;
import entities.Pet;

public class PetDAO {

    public boolean cadastrarPet(Pet novoPet) {
        String sql = "INSERT INTO TB_PETS (NOME, RACA, DT_NASCIMENTO, TAMANHO, PESO, OBS, OCORRENCIAS, TUTOR_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, novoPet.getNome());
            ps.setString(2, novoPet.getRaca());
            ps.setDate(3, java.sql.Date.valueOf(novoPet.getDtNascimento()));
            ps.setInt(4, novoPet.getTamanho().getId());
            ps.setBigDecimal(5, novoPet.getPeso());
            ps.setString(6, novoPet.getObs());
            ps.setString(7, novoPet.getOcorrencias());
            ps.setInt(8, novoPet.getTutor().getId());

            int linhasAfetadas = ps.executeUpdate();
            return linhasAfetadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Pet> listarPetsPorUsuario(int idUsuario) {
        List<Pet> listaPets = new ArrayList<>();
        String sql = "SELECT p.* FROM TB_PETS p JOIN TB_TUTORES t ON p.TUTOR_ID = t.ID WHERE t.USUARIO_ID = ?";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pet pet = new Pet();
                    pet.setId(rs.getInt("ID"));
                    pet.setNome(rs.getString("NOME"));
                    listaPets.add(pet);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaPets;
    }
    
    public boolean atualizarPet(Pet pet) {
        String sql = "UPDATE TB_PETS SET NOME = ?, RACA = ?, DT_NASCIMENTO = ?, TAMANHO = ?, PESO = ?, OBS = ?, OCORRENCIAS = ? WHERE ID = ?";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, pet.getNome());
            ps.setString(2, pet.getRaca());
            ps.setDate(3, java.sql.Date.valueOf(pet.getDtNascimento()));
            ps.setInt(4, pet.getTamanho().getId());
            ps.setBigDecimal(5, pet.getPeso());
            ps.setString(6, pet.getObs());
            ps.setString(7, pet.getOcorrencias());
            ps.setInt(8, pet.getId());

            int linhasAfetadas = ps.executeUpdate();
            return linhasAfetadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Pet> listarPetsPorTutor(int idTutor) {
        List<Pet> listaPets = new ArrayList<>();
        String sql = "SELECT * FROM TB_PETS WHERE TUTOR_ID = ?";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, idTutor);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pet pet = new Pet();
                    pet.setId(rs.getInt("ID"));
                    pet.setNome(rs.getString("NOME"));
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
                    listaPets.add(pet);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaPets;
    }
    public boolean atualizarInfoServico(Pet pet) {
        String sql = "UPDATE TB_PETS SET PESO = ?, OBS = ?, OCORRENCIAS = ? WHERE ID = ?";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBigDecimal(1, pet.getPeso());
            ps.setString(2, pet.getObs());
            ps.setString(3, pet.getOcorrencias());
            ps.setInt(4, pet.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}