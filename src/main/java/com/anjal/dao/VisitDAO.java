package com.anjal.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.FamilyMember;
import com.anjal.model.Prisoner;
import com.anjal.model.VisitRequest;
import com.anjal.model.VisitSchedule;
import com.anjal.model.User;
import com.anjal.util.DBConnection;

public class VisitDAO {

    public List<VisitRequest> findAllPending() throws SQLException {
        List<VisitRequest> list = new ArrayList<>();
        String sql = "SELECT vr.*, p.full_name as prisoner_name, p.prisoner_id, u.full_name as visitor_name " +
                     "FROM visit_requests vr " +
                     "JOIN prisoners p ON vr.prisoner_id = p.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "JOIN users u ON fm.user_id = u.id " +
                     "WHERE vr.status = 'PENDING' ORDER BY vr.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToVisitRequest(rs));
            }
        }
        return list;
    }

    public VisitRequest findById(int id) throws SQLException {
        String sql = "SELECT vr.*, p.full_name as prisoner_name, p.prisoner_id, u.full_name as visitor_name " +
                     "FROM visit_requests vr " +
                     "JOIN prisoners p ON vr.prisoner_id = p.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "JOIN users u ON fm.user_id = u.id " +
                     "WHERE vr.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToVisitRequest(rs);
                }
            }
        }
        return null;
    }

    public void updateStatusAndSchedule(int requestId, String status, VisitSchedule schedule) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update status
            String sqlUpdate = "UPDATE visit_requests SET status = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setString(1, status);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            // 2. If APPROVED, insert into visit_schedule
            if ("APPROVED".equalsIgnoreCase(status) && schedule != null) {
                String sqlSchedule = "INSERT INTO visit_schedule (visit_request_id, scheduled_date, scheduled_time, room, notes) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlSchedule)) {
                    ps.setInt(1, requestId);
                    ps.setDate(2, Date.valueOf(schedule.getScheduledDate()));
                    ps.setTime(3, Time.valueOf(schedule.getScheduledTime()));
                    ps.setString(4, schedule.getRoom());
                    ps.setString(5, schedule.getNotes());
                    ps.executeUpdate();
                }
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

    public List<VisitRequest> findByFamilyId(int familyId) throws SQLException {
        List<VisitRequest> list = new ArrayList<>();
        String sql = "SELECT vr.*, p.full_name as prisoner_name, p.prisoner_id, u.full_name as visitor_name " +
                     "FROM visit_requests vr " +
                     "JOIN prisoners p ON vr.prisoner_id = p.id " +
                     "JOIN family_members fm ON vr.family_member_id = fm.id " +
                     "JOIN users u ON fm.user_id = u.id " +
                     "WHERE fm.id = ? ORDER BY vr.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, familyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToVisitRequest(rs));
                }
            }
        }
        return list;
    }

    private VisitRequest mapRowToVisitRequest(ResultSet rs) throws SQLException {
        VisitRequest vr = new VisitRequest();
        vr.setId(rs.getInt("id"));
        
        Prisoner p = new Prisoner();
        p.setId(rs.getInt("prisoner_id"));
        p.setFullName(rs.getString("prisoner_name"));
        p.setPrisonerId(rs.getString("prisoner_id"));
        vr.setPrisoner(p);

        FamilyMember fm = new FamilyMember();
        fm.setId(rs.getInt("family_member_id"));
        User u = new User();
        u.setFullName(rs.getString("visitor_name"));
        fm.setUser(u);
        vr.setFamilyMember(fm);

        vr.setRequestDate(rs.getDate("request_date").toLocalDate());
        vr.setPreferredVisitDate(rs.getDate("preferred_visit_date").toLocalDate());
        vr.setRelation(rs.getString("relation"));
        vr.setMessage(rs.getString("message"));
        vr.setStatus(rs.getString("status"));
        
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) vr.setCreatedAt(ts.toLocalDateTime());
        
        return vr;
    }
}
