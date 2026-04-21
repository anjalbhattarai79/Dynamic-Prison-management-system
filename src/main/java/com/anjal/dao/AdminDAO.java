package com.anjal.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.anjal.service.DashboardService.ActivitySummary;
import com.anjal.service.DashboardService.DashboardSnapshot;
import com.anjal.service.DashboardService.PrisonerSummary;
import com.anjal.service.DashboardService.VisitRequestSummary;
import com.anjal.util.DBConnection;

public class AdminDAO {

    public DashboardSnapshot getDashboardSnapshot() throws SQLException {
        int totalPrisoners = 0;
        int activePrisoners = 0;
        int pendingVisits = 0;
        int approvedVisits = 0;
        int totalStaff = 0;
        int totalFamilies = 0;

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM prisoners");
            if (rs.next()) totalPrisoners = rs.getInt(1);

            rs = stmt.executeQuery("SELECT COUNT(*) FROM prisoners WHERE status = 'Active' AND is_deleted = 0");
            if (rs.next()) activePrisoners = rs.getInt(1);

            rs = stmt.executeQuery("SELECT COUNT(*) FROM visit_requests WHERE status = 'PENDING'");
            if (rs.next()) pendingVisits = rs.getInt(1);

            rs = stmt.executeQuery("SELECT COUNT(*) FROM visit_requests WHERE status = 'APPROVED'");
            if (rs.next()) approvedVisits = rs.getInt(1);

            rs = stmt.executeQuery("SELECT COUNT(*) FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name = 'STAFF'");
            if (rs.next()) totalStaff = rs.getInt(1);

            rs = stmt.executeQuery("SELECT COUNT(*) FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name = 'FAMILY'");
            if (rs.next()) totalFamilies = rs.getInt(1);
        }

        return new DashboardSnapshot(totalPrisoners, activePrisoners, pendingVisits, approvedVisits, totalStaff, totalFamilies);
    }

    public List<PrisonerSummary> getRecentPrisoners(int limit) throws SQLException {
        List<PrisonerSummary> list = new ArrayList<>();
        String sql = "SELECT prisoner_id, full_name, crime_type, block_number, security_level, status FROM prisoners WHERE is_deleted = 0 ORDER BY admission_date DESC LIMIT " + limit;
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new PrisonerSummary(
                        rs.getString("prisoner_id"),
                        rs.getString("full_name"),
                        rs.getString("crime_type"),
                        rs.getString("block_number"),
                        rs.getString("security_level"),
                        rs.getString("status")));
            }
        }
        return list;
    }

    public List<VisitRequestSummary> getPendingVisitRequests(int limit) throws SQLException {
        List<VisitRequestSummary> list = new ArrayList<>();
        String sql = "SELECT vr.id, u.full_name as visitor_name, p.full_name as prisoner_name, vr.preferred_visit_date, vr.status " +
                     "FROM visit_requests vr " +
                     "JOIN prisoners p ON vr.prisoner_id = p.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "JOIN users u ON fm.user_id = u.id " +
                     "WHERE vr.status = 'PENDING' ORDER BY vr.created_at DESC LIMIT " + limit;
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new VisitRequestSummary(
                        rs.getInt("id"),
                        rs.getString("visitor_name"),
                        rs.getString("prisoner_name"),
                        rs.getDate("preferred_visit_date").toString(),
                        rs.getString("status")));
            }
        }
        return list;
    }

    public List<ActivitySummary> getRecentActivities(int limit) throws SQLException {
        List<ActivitySummary> list = new ArrayList<>();
        String sql = "SELECT al.action, al.details, al.created_at, u.full_name FROM activity_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.id ORDER BY al.created_at DESC LIMIT " + limit;
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String action = rs.getString("action");
                String type = "info"; // default
                
                if (action.contains("LOGIN")) type = "login";
                else if (action.contains("PRISONER_ADDED") || action.contains("ADD")) type = "add";
                else if (action.contains("UPDATE")) type = "update";
                else if (action.contains("DELETE") || action.contains("TRASH")) type = "delete";
                else if (action.contains("VISIT") || action.contains("INQUIRY")) type = "visit";

                list.add(new ActivitySummary(
                        type,
                        rs.getString("details"),
                        formatTimeAgo(rs.getTimestamp("created_at")),
                        rs.getString("full_name") != null ? rs.getString("full_name") : "System"));
            }
        }
        return list;
    }

    private String formatTimeAgo(java.sql.Timestamp ts) {
        if (ts == null) return "Unknown";
        long diff = System.currentTimeMillis() - ts.getTime();
        long minutes = diff / (1000 * 60);
        if (minutes < 1) return "Just now";
        if (minutes < 60) return minutes + "m ago";
        long hours = minutes / 60;
        if (hours < 24) return hours + "h ago";
        long days = hours / 24;
        return days + "d ago";
    }
}
