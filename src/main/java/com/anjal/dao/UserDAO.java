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

    public void updatePassword(int userId, String passwordHash, String salt) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, password_salt = ?, reset_token = NULL, reset_token_expiry = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setString(2, salt);
            ps.setInt(3, userId);
            ps.executeUpdate();
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
        String sql = "SELECT u.id, u.role_id, r.name AS role_name, u.full_name, u.email, u.password_hash, u.password_salt, u.is_locked, u.created_at, u.updated_at, u.reset_token, u.reset_token_expiry "
                   + "FROM users u JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.email = ? AND u.reset_token = ? AND u.reset_token_expiry IS NOT NULL AND u.reset_token_expiry > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
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
