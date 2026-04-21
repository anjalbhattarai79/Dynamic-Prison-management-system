package com.anjal.service;

import java.util.ArrayList;
import java.util.List;

public class FamilyDashboardService {

	// Test data - returns mock data without database

	public int getUpcomingVisitsCount() {
		return 2;
	}

	public int getPendingRequestsCount() {
		return 1;
	}

	public int getApprovedVisitsCount() {
		return 3;
	}

	public int getUnreadNotificationsCount() {
		return 3;
	}

	public String getNextVisitDate() {
		return "19 Apr, 10:30 AM";
	}

	public List<VisitRequest> getRecentVisitRequests() {
		List<VisitRequest> visits = new ArrayList<>();

		VisitRequest v1 = new VisitRequest();
		v1.setRequestId(311);
		v1.setPrisonerName("Ramesh Karki");
		v1.setRequestDate("2025-04-10");
		v1.setPreferredDate("2025-04-19");
		v1.setStatus("APPROVED");

		VisitRequest v2 = new VisitRequest();
		v2.setRequestId(324);
		v2.setPrisonerName("Suman Karki");
		v2.setRequestDate("2025-04-12");
		v2.setPreferredDate("2025-04-22");
		v2.setStatus("PENDING");

		VisitRequest v3 = new VisitRequest();
		v3.setRequestId(298);
		v3.setPrisonerName("Ramesh Karki");
		v3.setRequestDate("2025-04-05");
		v3.setPreferredDate("2025-04-15");
		v3.setStatus("COMPLETED");

		visits.add(v1);
		visits.add(v2);
		visits.add(v3);

		return visits;
	}

	public List<Prisoner> getLinkedPrisoners() {
		List<Prisoner> prisoners = new ArrayList<>();

		Prisoner p1 = new Prisoner();
		p1.setPrisonerId("PR-0142");
		p1.setFullName("Ramesh Karki");
		p1.setBlockNumber(2);
		p1.setSecurityLevel("MEDIUM");

		Prisoner p2 = new Prisoner();
		p2.setPrisonerId("PR-0231");
		p2.setFullName("Suman Karki");
		p2.setBlockNumber(1);
		p2.setSecurityLevel("LOW");

		prisoners.add(p1);
		prisoners.add(p2);

		return prisoners;
	}

	public List<Notification> getRecentNotifications() {
		List<Notification> notifications = new ArrayList<>();

		Notification n1 = new Notification();
		n1.setNotificationId(1);
		n1.setMessage("Your visit request for Ramesh Karki has been approved.");
		n1.setIsRead(true);
		n1.setTimeAgo("2 days ago");

		Notification n2 = new Notification();
		n2.setNotificationId(2);
		n2.setMessage("Admin replied to your health status inquiry.");
		n2.setIsRead(true);
		n2.setTimeAgo("3 days ago");

		Notification n3 = new Notification();
		n3.setNotificationId(3);
		n3.setMessage("Visit request #324 sent for review.");
		n3.setIsRead(false);
		n3.setTimeAgo("1 hour ago");

		Notification n4 = new Notification();
		n4.setNotificationId(4);
		n4.setMessage("New visit guidelines published. Please review.");
		n4.setIsRead(false);
		n4.setTimeAgo("5 hours ago");

		notifications.add(n1);
		notifications.add(n2);
		notifications.add(n3);
		notifications.add(n4);

		return notifications;
	}

	// Inner class for VisitRequest
	public static class VisitRequest {
		private int requestId;
		private String prisonerName;
		private String requestDate;
		private String preferredDate;
		private String status;

		public int getRequestId() {
			return requestId;
		}

		public void setRequestId(int requestId) {
			this.requestId = requestId;
		}

		public String getPrisonerName() {
			return prisonerName;
		}

		public void setPrisonerName(String prisonerName) {
			this.prisonerName = prisonerName;
		}

		public String getRequestDate() {
			return requestDate;
		}

		public void setRequestDate(String requestDate) {
			this.requestDate = requestDate;
		}

		public String getPreferredDate() {
			return preferredDate;
		}

		public void setPreferredDate(String preferredDate) {
			this.preferredDate = preferredDate;
		}

		public String getStatus() {
			return status;
		}

		public void setStatus(String status) {
			this.status = status;
		}
	}

	// Inner class for Prisoner
	public static class Prisoner {
		private String prisonerId;
		private String fullName;
		private int blockNumber;
		private String securityLevel;

		public String getPrisonerId() {
			return prisonerId;
		}

		public void setPrisonerId(String prisonerId) {
			this.prisonerId = prisonerId;
		}

		public String getFullName() {
			return fullName;
		}

		public void setFullName(String fullName) {
			this.fullName = fullName;
		}

		public int getBlockNumber() {
			return blockNumber;
		}

		public void setBlockNumber(int blockNumber) {
			this.blockNumber = blockNumber;
		}

		public String getSecurityLevel() {
			return securityLevel;
		}

		public void setSecurityLevel(String securityLevel) {
			this.securityLevel = securityLevel;
		}
	}

	// Inner class for Notification
	public static class Notification {
		private int notificationId;
		private String message;
		private boolean isRead;
		private String timeAgo;

		public int getNotificationId() {
			return notificationId;
		}

		public void setNotificationId(int notificationId) {
			this.notificationId = notificationId;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}

		public boolean getIsRead() {
			return isRead;
		}

		public void setIsRead(boolean isRead) {
			this.isRead = isRead;
		}

		public String getTimeAgo() {
			return timeAgo;
		}

		public void setTimeAgo(String timeAgo) {
			this.timeAgo = timeAgo;
		}
	}
}