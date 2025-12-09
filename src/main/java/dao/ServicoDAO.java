package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import database.DBConnection;
import entities.Servico;

public class ServicoDAO {

    public List<Servico> listarServicos() {
        List<Servico> listaServicos = new ArrayList<>();
        String sql = "SELECT * FROM TB_SERVICOS ORDER BY DESCRICAO";

        try (DBConnection db = new DBConnection();
             Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Servico servico = new Servico();
                servico.setId(rs.getInt("ID"));
                servico.setDescricao(rs.getString("DESCRICAO"));
                servico.setValor(rs.getBigDecimal("VALOR"));
                listaServicos.add(servico);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaServicos;
    }
}