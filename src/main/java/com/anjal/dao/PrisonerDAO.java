package com.anjal.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.Prisoner;
import com.anjal.util.DBConnection;

public class PrisonerDAO {

    public List<Prisoner> findAll() throws SQLException {
        List<Prisoner> prisoners = new ArrayList<>();
        String sql = "SELECT * FROM prisoners WHERE is_deleted = 0";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                prisoners.add(mapRowToPrisoner(rs));
            }
        }
        return prisoners;
    }

    public Prisoner findByPrisonerId(String prisonerId) throws SQLException {
        String sql = "SELECT * FROM prisoners WHERE prisoner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prisonerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToPrisoner(rs);
                }
            }
        }
        return null;
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
        Prisoner p = findByPrisonerId(prisonerId);
        if (p == null)
            return;

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int id = p.getId();

            // 1. Delete visit_schedule (via visit_requests)
            String sql1 = "DELETE FROM visit_schedule WHERE visit_request_id IN (SELECT id FROM visit_requests WHERE prisoner_id = ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // 2. Delete visit_requests
            String sql2 = "DELETE FROM visit_requests WHERE prisoner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // 3. Delete prisoner_activities
            String sql3 = "DELETE FROM prisoner_activities WHERE prisoner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql3)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // 4. Delete deleted_prisoners records
            String sql4 = "DELETE FROM deleted_prisoners WHERE prisoner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql4)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // 5. Identify and handle Family Members and Users
            List<Integer> familyMemberIds = new ArrayList<>();
            List<Integer> familyUserIds = new ArrayList<>();
            String sqlFindFM = "SELECT id, user_id FROM family_members WHERE prisoner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlFindFM)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        familyMemberIds.add(rs.getInt("id"));
                        familyUserIds.add(rs.getInt("user_id"));
                    }
                }
            }

            // 6. Delete Inquiries (must be before family_members)
            if (!familyMemberIds.isEmpty()) {
                for (Integer fmId : familyMemberIds) {
                    String sqlDeleteInq = "DELETE FROM inquiries WHERE family_member_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sqlDeleteInq)) {
                        ps.setInt(1, fmId);
                        ps.executeUpdate();
                    }
                }
            }

            // 7. Delete family_members links
            String sql5 = "DELETE FROM family_members WHERE prisoner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql5)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // 8. Delete Family Users and their related data
            if (!familyUserIds.isEmpty()) {
                for (Integer userId : familyUserIds) {
                    // Check if this user is a 'FAMILY' role user before deleting
                    String sqlCheckRole = "SELECT r.name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?";
                    boolean isFamilyUser = false;
                    try (PreparedStatement ps = conn.prepareStatement(sqlCheckRole)) {
                        ps.setInt(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next() && "FAMILY".equalsIgnoreCase(rs.getString("name"))) {
                                isFamilyUser = true;
                            }
                        }
                    }

                    if (isFamilyUser) {
                        // Delete related user data
                        String[] userRelatedTables = { "login_attempts", "notifications", "activity_logs" };
                        for (String table : userRelatedTables) {
                            String sqlDelete = "DELETE FROM " + table + " WHERE user_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(sqlDelete)) {
                                ps.setInt(1, userId);
                                ps.executeUpdate();
                            }
                        }
                        
                        String sqlDeleteUser = "DELETE FROM users WHERE id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sqlDeleteUser)) {
                            ps.setInt(1, userId);
                            ps.executeUpdate();
                        }
                    }
                }
            }

            // 9. Finally delete the prisoner
            String sql9 = "DELETE FROM prisoners WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql9)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null)
                conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
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
