package com.anjal.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.Notification;
import com.anjal.model.Prisoner;
import com.anjal.model.VisitRequest;
import com.anjal.util.DBConnection;

public class FamilyDAO {

    public int getUpcomingVisitsCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visit_schedule vs " +
                     "JOIN visit_requests vr ON vs.visit_request_id = vr.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "WHERE fm.user_id = ? AND vs.scheduled_date >= CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getPendingRequestsCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visit_requests vr " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "WHERE fm.user_id = ? AND vr.status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getApprovedVisitsCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM visit_requests vr " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "WHERE fm.user_id = ? AND vr.status = 'APPROVED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getUnreadNotificationsCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public String getNextVisitDate(int userId) throws SQLException {
        String sql = "SELECT vs.scheduled_date, vs.scheduled_time FROM visit_schedule vs " +
                     "JOIN visit_requests vr ON vs.visit_request_id = vr.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "WHERE fm.user_id = ? AND vs.scheduled_date >= CURDATE() " +
                     "ORDER BY vs.scheduled_date ASC, vs.scheduled_time ASC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate("scheduled_date").toString() + " " + rs.getTime("scheduled_time").toString();
                }
            }
        }
        return "None";
    }

    public List<VisitRequest> getRecentVisitRequests(int userId) throws SQLException {
        List<VisitRequest> requests = new ArrayList<>();
        String sql = "SELECT vr.*, p.full_name as prisoner_name FROM visit_requests vr " +
                     "JOIN prisoners p ON vr.prisoner_id = p.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "WHERE fm.user_id = ? ORDER BY vr.created_at DESC LIMIT 5";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VisitRequest vr = new VisitRequest();
                    vr.setId(rs.getInt("id"));
                    vr.setRequestDate(rs.getDate("request_date").toLocalDate());
                    vr.setPreferredVisitDate(rs.getDate("preferred_visit_date").toLocalDate());
                    vr.setStatus(rs.getString("status"));
                    // Note: model doesn't have prisonerName field, usually handled in view or DTO
                    // but for this task I will use what's available or suggest DTO
                    requests.add(vr);
                }
            }
        }
        return requests;
    }

    public List<Prisoner> getLinkedPrisoners(int userId) throws SQLException {
        List<Prisoner> prisoners = new ArrayList<>();
        String sql = "SELECT p.* FROM prisoners p " +
                     "JOIN family_members fm ON fm.prisoner_id = p.id " +
                     "WHERE fm.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Prisoner p = new Prisoner();
                    p.setId(rs.getInt("id"));
                    p.setPrisonerId(rs.getString("prisoner_id"));
                    p.setFullName(rs.getString("full_name"));
                    p.setBlockNumber(rs.getString("block_number"));
                    p.setSecurityLevel(rs.getString("security_level"));
                    prisoners.add(p);
                }
            }
        }
        return prisoners;
    }

    public List<Notification> getRecentNotifications(int userId) throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 5";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    n.setRead(rs.getBoolean("is_read"));
                    n.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    notifications.add(n);
                }
            }
        }
        return notifications;
    }
}
