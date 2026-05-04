package com.anjal.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.FamilyMember;
import com.anjal.model.Notification;
import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.model.VisitRequest;
import com.anjal.util.DBConnection;

public class FamilyDAO {

	public int getUpcomingVisitsCount(int userId) throws SQLException {
		String sql = "SELECT COUNT(*) FROM visit_requests vr "
				+ "JOIN family_members fm ON vr.family_member_id = fm.id "
				+ "JOIN visit_schedule vs ON vs.visit_request_id = vr.id "
				+ "WHERE fm.user_id = ? AND vs.scheduled_date >= CURDATE()";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}
		return 0;
	}

	public int getPendingRequestsCount(int userId) throws SQLException {
		String sql = "SELECT COUNT(*) FROM visit_requests vr "
				+ "JOIN family_members fm ON vr.family_member_id = fm.id "
				+ "WHERE fm.user_id = ? AND vr.status = 'PENDING'";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}
		return 0;
	}

	public int getApprovedVisitsCount(int userId) throws SQLException {
		String sql = "SELECT COUNT(*) FROM visit_requests vr "
				+ "JOIN family_members fm ON vr.family_member_id = fm.id "
				+ "WHERE fm.user_id = ? AND vr.status = 'APPROVED'";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}
		return 0;
	}

	public int getUnreadNotificationsCount(int userId) throws SQLException {
		String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}
		return 0;
	}

	public String getNextVisitDate(int userId) throws SQLException {
		String sql = "SELECT vs.scheduled_date FROM visit_schedule vs "
				+ "JOIN visit_requests vr ON vs.visit_request_id = vr.id "
				+ "JOIN family_members fm ON vr.family_member_id = fm.id "
				+ "WHERE fm.user_id = ? AND vs.scheduled_date >= CURDATE() " + "ORDER BY vs.scheduled_date ASC LIMIT 1";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getDate("scheduled_date").toString();
				}
			}
		}
		return "N/A";
	}

	public List<VisitRequest> getRecentVisitRequests(int userId) throws SQLException {
		List<VisitRequest> list = new ArrayList<>();
		String sql = "SELECT vr.* FROM visit_requests vr " + "JOIN family_members fm ON vr.family_member_id = fm.id "
				+ "WHERE fm.user_id = ? ORDER BY vr.created_at DESC LIMIT 5";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					VisitRequest vr = new VisitRequest();
					vr.setId(rs.getInt("id"));
					vr.setRequestDate(rs.getDate("request_date").toLocalDate());
					vr.setPreferredVisitDate(rs.getDate("preferred_visit_date").toLocalDate());
					vr.setStatus(rs.getString("status"));
					vr.setRelation(rs.getString("relation"));
					vr.setMessage(rs.getString("message"));
					Timestamp createdAt = rs.getTimestamp("created_at");
					if (createdAt != null) {
						vr.setCreatedAt(createdAt.toLocalDateTime());
					}
					list.add(vr);
				}
			}
		}
		return list;
	}

	public List<Prisoner> getLinkedPrisoners(int userId) throws SQLException {
		List<Prisoner> list = new ArrayList<>();
		String sql = "SELECT p.* FROM prisoners p " + "JOIN family_members fm ON fm.prisoner_id = p.id "
				+ "WHERE fm.user_id = ? AND p.is_deleted = 0";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			System.out.println("DEBUG: Executing DAO.getLinkedPrisoners for userId: " + userId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapRowToPrisoner(rs));
				}
			}
			System.out.println("DEBUG: DAO.getLinkedPrisoners returned " + list.size() + " records.");
		}
		return list;
	}

	public List<Notification> getRecentNotifications(int userId) throws SQLException {
		List<Notification> list = new ArrayList<>();
		String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 5";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					Notification n = new Notification();
					n.setId(rs.getInt("id"));
					n.setTitle(rs.getString("title"));
					n.setMessage(rs.getString("message"));
					n.setRead(rs.getBoolean("is_read"));
					Timestamp createdAt = rs.getTimestamp("created_at");
					if (createdAt != null) {
						n.setCreatedAt(createdAt.toLocalDateTime());
					}
					list.add(n);
				}
			}
		}
		return list;
	}

	public void createDefaultFamilyMember(int userId, int prisonerId, String relation) throws SQLException {
		String sql = "INSERT INTO family_members (user_id, prisoner_id, relation) VALUES (?, ?, ?)";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			ps.setInt(2, prisonerId);
			ps.setString(3, relation);
			ps.executeUpdate();
		}
	}

	public com.anjal.model.FamilyMember getFamilyMemberByUserId(int userId) throws SQLException {
		String sql = "SELECT * FROM family_members WHERE user_id = ?";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					com.anjal.model.FamilyMember fm = new com.anjal.model.FamilyMember();
					fm.setId(rs.getInt("id"));
					fm.setRelation(rs.getString("relation"));
					fm.setPhone(rs.getString("phone"));
					fm.setAddress(rs.getString("address"));
					return fm;
				}
			}
		}
		return null;
	}

	public void saveVisitRequest(VisitRequest vr) throws SQLException {
		String sql = "INSERT INTO visit_requests (prisoner_id, family_member_id, request_date, preferred_visit_date, relation, message, status) "
				+ "VALUES (?, ?, ?, ?, ?, ?, 'PENDING')";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, vr.getPrisoner().getId());
			ps.setInt(2, vr.getFamilyMember().getId());
			ps.setDate(3, Date.valueOf(vr.getRequestDate()));
			ps.setDate(4, Date.valueOf(vr.getPreferredVisitDate()));
			ps.setString(5, vr.getRelation());
			ps.setString(6, vr.getMessage());
			ps.executeUpdate();
		}
	}

	public List<FamilyMember> findAllWithPrisonerDetails() throws SQLException {
		List<FamilyMember> list = new ArrayList<>();
		String sql = "SELECT fm.*, u.full_name as family_name, u.email as family_email, p.prisoner_id, p.full_name as prisoner_name "
				+ "FROM family_members fm " + "JOIN users u ON fm.user_id = u.id "
				+ "JOIN prisoners p ON fm.prisoner_id = p.id " + "WHERE p.is_deleted = 0 ORDER BY fm.id DESC";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				list.add(mapRowToFamilyMember(rs));
			}
		}
		return list;
	}

	public FamilyMember findById(int familyId) throws SQLException {
		String sql = "SELECT fm.*, u.full_name as family_name, u.email as family_email, p.prisoner_id, p.full_name as prisoner_name "
				+ "FROM family_members fm " + "JOIN users u ON fm.user_id = u.id "
				+ "JOIN prisoners p ON fm.prisoner_id = p.id " + "WHERE fm.id = ?";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, familyId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return mapRowToFamilyMember(rs);
				}
			}
		}
		return null;
	}

	private FamilyMember mapRowToFamilyMember(ResultSet rs) throws SQLException {
		FamilyMember fm = new FamilyMember();
		fm.setId(rs.getInt("id"));
		fm.setRelation(rs.getString("relation"));
		fm.setPhone(rs.getString("phone"));
		fm.setAddress(rs.getString("address"));

		User user = new User();
		user.setId(rs.getInt("user_id"));
		user.setFullName(rs.getString("family_name"));
		user.setEmail(rs.getString("family_email"));
		fm.setUser(user);

		Prisoner prisoner = new Prisoner();
		prisoner.setId(rs.getInt("prisoner_id"));
		prisoner.setPrisonerId(rs.getString("prisoner_id"));
		prisoner.setFullName(rs.getString("prisoner_name"));
		fm.setPrisoner(prisoner);

		return fm;
	}

	private Prisoner mapRowToPrisoner(ResultSet rs) throws SQLException {
		Prisoner p = new Prisoner();
		p.setId(rs.getInt("id"));
		p.setPrisonerId(rs.getString("prisoner_id"));
		p.setFullName(rs.getString("full_name"));

		Date dob = rs.getDate("date_of_birth");
		if (dob != null) {
			p.setDateOfBirth(dob.toLocalDate());
		}

		p.setGender(rs.getString("gender"));
		p.setCrimeType(rs.getString("crime_type"));
		p.setSentenceYears(rs.getInt("sentence_years"));

		Date adm = rs.getDate("admission_date");
		if (adm != null) {
			p.setAdmissionDate(adm.toLocalDate());
		}

		Date rel = rs.getDate("release_date");
		if (rel != null) {
			p.setReleaseDate(rel.toLocalDate());
		}

		p.setBlockNumber(rs.getString("block_number"));
		p.setSecurityLevel(rs.getString("security_level"));
		p.setStatus(rs.getString("status"));
		p.setEmergencyContact(rs.getString("emergency_contact"));
		p.setPhotoDataUri(rs.getString("photo_data_uri"));
		p.setHealthStatus(rs.getString("health_status") != null ? rs.getString("health_status") : "Healthy");
		p.setMedicalNotes(rs.getString("medical_notes"));
		p.setDeleted(rs.getBoolean("is_deleted"));
		return p;
	}
}
