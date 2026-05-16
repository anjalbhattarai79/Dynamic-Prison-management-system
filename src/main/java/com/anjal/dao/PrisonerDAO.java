package com.anjal.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.Prisoner;
import com.anjal.util.DBConnection;

public class PrisonerDAO {

    private static final DateTimeFormatter dtFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    private String getTimestamp() {
        return LocalDateTime.now().format(dtFormatter);
    }

    public List<Prisoner> findAll() throws SQLException {
        long startTime = System.currentTimeMillis();
        List<Prisoner> prisoners = new ArrayList<>();
        String sql = "SELECT * FROM prisoners WHERE is_deleted = 0";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                prisoners.add(mapRowToPrisoner(rs));
            }
        }
        long duration = System.currentTimeMillis() - startTime;
        System.out.println("[" + getTimestamp() + "] [METRIC] findAll: Fetched " + prisoners.size() + " records in " + duration + "ms");
        return prisoners;
    }

    public Prisoner findByPrisonerId(String prisonerId) throws SQLException {
        long startTime = System.currentTimeMillis();
        String sql = "SELECT * FROM prisoners WHERE prisoner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prisonerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Prisoner p = mapRowToPrisoner(rs);
                    long duration = System.currentTimeMillis() - startTime;
                    System.out.println("[" + getTimestamp() + "] [METRIC] findByPrisonerId: Fetched ID " + prisonerId + " in " + duration + "ms");
                    return p;
                }
            }
        }
        return null;
    }

    public List<Prisoner> search(String query) throws SQLException {
        long startTime = System.currentTimeMillis();
        List<Prisoner> prisoners = new ArrayList<>();
        String sql = "SELECT * FROM prisoners WHERE is_deleted = 0 AND (prisoner_id LIKE ? OR full_name LIKE ? OR crime_type LIKE ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    prisoners.add(mapRowToPrisoner(rs));
                }
            }
        }
        long duration = System.currentTimeMillis() - startTime;
        System.out.println("[" + getTimestamp() + "] [METRIC] search: Query '" + query + "' returned " + prisoners.size() + " results in " + duration + "ms");
        return prisoners;
    }

    public void save(Prisoner p) throws SQLException {
        String sql = "INSERT INTO prisoners (prisoner_id, full_name, date_of_birth, gender, crime_type, sentence_years, " +
                     "admission_date, release_date, block_number, security_level, status, emergency_contact, photo_data_uri, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getPrisonerId());
            ps.setString(2, p.getFullName());
            ps.setDate(3, Date.valueOf(p.getDateOfBirth()));
            ps.setString(4, p.getGender());
            ps.setString(5, p.getCrimeType());
            ps.setInt(6, p.getSentenceYears());
            ps.setDate(7, Date.valueOf(p.getAdmissionDate()));
            ps.setDate(8, p.getReleaseDate() != null ? Date.valueOf(p.getReleaseDate()) : null);
            ps.setString(9, p.getBlockNumber());
            ps.setString(10, p.getSecurityLevel());
            ps.setString(11, p.getStatus());
            ps.setString(12, p.getEmergencyContact());
            ps.setString(13, p.getPhotoDataUri());
            ps.setBoolean(14, p.isDeleted());
            ps.executeUpdate();
        }
    }

    public void update(Prisoner p) throws SQLException {
        String sql = "UPDATE prisoners SET full_name=?, date_of_birth=?, gender=?, crime_type=?, sentence_years=?, " +
                     "admission_date=?, release_date=?, block_number=?, security_level=?, status=?, emergency_contact=?, photo_data_uri=? " +
                     "WHERE prisoner_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getFullName());
            ps.setDate(2, Date.valueOf(p.getDateOfBirth()));
            ps.setString(3, p.getGender());
            ps.setString(4, p.getCrimeType());
            ps.setInt(5, p.getSentenceYears());
            ps.setDate(6, Date.valueOf(p.getAdmissionDate()));
            ps.setDate(7, p.getReleaseDate() != null ? Date.valueOf(p.getReleaseDate()) : null);
            ps.setString(8, p.getBlockNumber());
            ps.setString(9, p.getSecurityLevel());
            ps.setString(10, p.getStatus());
            ps.setString(11, p.getEmergencyContact());
            ps.setString(12, p.getPhotoDataUri());
            ps.setString(13, p.getPrisonerId());
            ps.executeUpdate();
        }
    }

    public void softDelete(String prisonerId, int deletedBy, String reason) throws SQLException {
        // First get the numeric ID
        Prisoner p = findByPrisonerId(prisonerId);
        if (p == null) return;

        String sqlUpdate = "UPDATE prisoners SET is_deleted = 1 WHERE prisoner_id = ?";
        String sqlArchive = "INSERT INTO deleted_prisoners (prisoner_id, deleted_by, reason) VALUES (?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setString(1, prisonerId);
                psUpdate.executeUpdate();
            }

            try (PreparedStatement psArchive = conn.prepareStatement(sqlArchive)) {
                psArchive.setInt(1, p.getId());
                psArchive.setInt(2, deletedBy);
                psArchive.setString(3, reason != null ? reason : "Soft deleted");
                psArchive.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void restore(String prisonerId) throws SQLException {
        String sql = "UPDATE prisoners SET is_deleted = 0 WHERE prisoner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prisonerId);
            ps.executeUpdate();
        }
    }

    public void permanentlyDelete(String prisonerId) throws SQLException {
        String sql = "DELETE FROM prisoners WHERE prisoner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prisonerId);
            ps.executeUpdate();
        }
    }

    private Prisoner mapRowToPrisoner(ResultSet rs) throws SQLException {
        Prisoner p = new Prisoner();
        p.setId(rs.getInt("id"));
        p.setPrisonerId(rs.getString("prisoner_id"));
        p.setFullName(rs.getString("full_name"));
        p.setDateOfBirth(rs.getDate("date_of_birth").toLocalDate());
        p.setGender(rs.getString("gender"));
        p.setCrimeType(rs.getString("crime_type"));
        p.setSentenceYears(rs.getInt("sentence_years"));
        p.setAdmissionDate(rs.getDate("admission_date").toLocalDate());
        if (rs.getDate("release_date") != null) {
            p.setReleaseDate(rs.getDate("release_date").toLocalDate());
        }
        p.setBlockNumber(rs.getString("block_number"));
        p.setSecurityLevel(rs.getString("security_level"));
        p.setStatus(rs.getString("status"));
        p.setEmergencyContact(rs.getString("emergency_contact"));
        p.setPhotoDataUri(rs.getString("photo_data_uri"));
        p.setDeleted(rs.getBoolean("is_deleted"));
        return p;
    }

    public List<Prisoner> findTrashed() throws SQLException {
        List<Prisoner> prisoners = new ArrayList<>();
        String sql = "SELECT * FROM prisoners WHERE is_deleted = 1";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                prisoners.add(mapRowToPrisoner(rs));
            }
        }
        return prisoners;
    }

    public String getNextPrisonerId() throws SQLException {
        String sql = "SELECT prisoner_id FROM prisoners WHERE prisoner_id LIKE 'NP-PMS-%' ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                String lastId = rs.getString("prisoner_id");
                if (lastId != null && lastId.length() > 7) {
                    try {
                        int num = Integer.parseInt(lastId.substring(7));
                        return String.format("NP-PMS-%04d", num + 1);
                    } catch (NumberFormatException e) {
                        // fallback
                    }
                }
            }
        }
        return "NP-PMS-0001";
    }
}
