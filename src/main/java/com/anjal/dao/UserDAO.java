package com.anjal.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import com.anjal.model.Role;
import com.anjal.model.User;
import com.anjal.util.DBConnection;

/**
 * DAO responsible for user authentication and account state.
 * Uses prepared statements for all queries.
 */
public class UserDAO {

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_WINDOW_MINUTES = 15;

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.full_name, u.email, u.password_hash, u.password_salt, u.is_locked, u.created_at, u.updated_at, u.reset_token, u.reset_token_expiry "
                   + "FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        }
        return null;
    }

    public User findFamilyByPrisonerId(String prisonerId) throws SQLException {
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.full_name, u.email, u.password_hash, u.password_salt, u.is_locked, u.created_at, u.updated_at, u.reset_token, u.reset_token_expiry "
                   + "FROM users u "
                   + "JOIN roles r ON u.role_id = r.id "
                   + "JOIN family_members fm ON fm.user_id = u.id "
                   + "JOIN prisoners p ON fm.prisoner_id = p.id "
                   + "WHERE p.prisoner_id = ? AND r.name = 'FAMILY'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prisonerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        }
        return null;
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public User createFamilyUser(String fullName, String email, String passwordHash, String salt) throws SQLException {
        // Find FAMILY role id
        int roleId = getRoleIdByName("FAMILY");
        String sql = "INSERT INTO users (role_id, full_name, email, password_hash, password_salt, is_locked) VALUES (?,?,?,?,?,0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, roleId);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, passwordHash);
            ps.setString(5, salt);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    User user = new User();
                    user.setId(id);
                    Role role = new Role();
                    role.setId(roleId);
                    role.setName("FAMILY");
                    user.setRole(role);
                    user.setFullName(fullName);
                    user.setEmail(email);
                    user.setPasswordHash(passwordHash);
                    user.setPasswordSalt(salt);
                    user.setLocked(false);
                    user.setCreatedAt(LocalDateTime.now());
                    user.setUpdatedAt(LocalDateTime.now());
                    return user;
                }
            }
        }
        return null;
    }

    private int getRoleIdByName(String roleName) throws SQLException {
        String sql = "SELECT id FROM roles WHERE name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        throw new SQLException("Role not found: " + roleName);
    }

    public void recordLoginAttempt(Integer userId, String email, boolean success, String ipAddress) throws SQLException {
        String sql = "INSERT INTO login_attempts (user_id, email, success, ip_address) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, email);
            ps.setBoolean(3, success);
            ps.setString(4, ipAddress);
            ps.executeUpdate();
        }
    }

    public void evaluateAndLockAccountIfNeeded(User user) throws SQLException {
        if (user == null) {
            return;
        }
        String sql = "SELECT COUNT(*) AS failures FROM login_attempts "
                   + "WHERE email = ? AND success = 0 AND attempt_time > (NOW() - INTERVAL ? MINUTE)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getEmail());
            ps.setInt(2, LOCK_WINDOW_MINUTES);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int failures = rs.getInt("failures");
                    if (failures >= MAX_FAILED_ATTEMPTS) {
                        lockAccount(user.getId());
                    }
                }
            }
        }
    }

    public void lockAccount(int userId) throws SQLException {
        String sql = "UPDATE users SET is_locked = 1 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void unlockAccount(int userId, String email) throws SQLException {
        String sqlUpdate = "UPDATE users SET is_locked = 0 WHERE id = ?";
        String sqlDeleteAttempts = "DELETE FROM login_attempts WHERE user_id = ? OR email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps1 = conn.prepareStatement(sqlUpdate)) {
                    ps1.setInt(1, userId);
                    ps1.executeUpdate();
                }
                try (PreparedStatement ps2 = conn.prepareStatement(sqlDeleteAttempts)) {
                    ps2.setInt(1, userId);
                    ps2.setString(2, email);
                    ps2.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void updatePassword(int userId, String email, String passwordHash, String salt) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, password_salt = ?, reset_token = NULL, reset_token_expiry = NULL, is_locked = 0 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, passwordHash);
                    ps.setString(2, salt);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
                // Also clear login attempts when password is reset
                String sqlDeleteAttempts = "DELETE FROM login_attempts WHERE user_id = ? OR email = ?";
                try (PreparedStatement ps2 = conn.prepareStatement(sqlDeleteAttempts)) {
                    ps2.setInt(1, userId);
                    ps2.setString(2, email);
                    ps2.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public String createPasswordResetToken(String email) throws SQLException {
        User user = findByEmail(email);
        if (user == null) {
            return null;
        }
        String token = java.util.UUID.randomUUID().toString();
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE id = ?";
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(30);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, Timestamp.valueOf(expiry));
            ps.setInt(3, user.getId());
            ps.executeUpdate();
        }
        return token;
    }

    public User findByEmailAndValidToken(String email, String token) throws SQLException {
        String trimmedToken = token != null ? token.trim() : "";
        System.out.println("DEBUG: Looking for token for email: " + email);
        System.out.println("DEBUG: Provided Token: [" + trimmedToken + "]");
        
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.full_name, u.email, u.password_hash, u.password_salt, u.is_locked, u.created_at, u.updated_at, u.reset_token, u.reset_token_expiry "
                   + "FROM users u JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.email = ?";
                   
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String dbToken = rs.getString("reset_token");
                    Timestamp dbExpiry = rs.getTimestamp("reset_token_expiry");
                    
                    System.out.println("DEBUG: DB Stored Token: [" + dbToken + "]");
                    System.out.println("DEBUG: DB Stored Expiry: " + dbExpiry);
                    
                    if (dbToken != null && dbToken.equals(trimmedToken)) {
                        if (dbExpiry != null && dbExpiry.after(new Timestamp(System.currentTimeMillis()))) {
                            return mapRowToUser(rs);
                        } else {
                            System.out.println("DEBUG: Token EXPIRED. DB Time: " + dbExpiry + " vs Current Time: " + new Timestamp(System.currentTimeMillis()));
                        }
                    } else {
                        System.out.println("DEBUG: Token MISMATCH.");
                    }
                } else {
                    System.out.println("DEBUG: User not found for email reset.");
                }
            }
        }
        return null;
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        Role role = new Role();
        role.setId(rs.getInt("role_id"));
        role.setName(rs.getString("role_name"));
        user.setRole(role);
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setPasswordSalt(rs.getString("password_salt"));
        user.setLocked(rs.getBoolean("is_locked"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            user.setCreatedAt(created.toLocalDateTime());
        }
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) {
            user.setUpdatedAt(updated.toLocalDateTime());
        }
        return user;
    }
}
