package com.anjal.service;

import java.sql.SQLException;
import java.util.List;

import com.anjal.dao.AdminDAO;

/**
 * Dashboard service that provides data from the database.
 */
public class DashboardService {

    private final AdminDAO adminDAO = new AdminDAO();

    public DashboardSnapshot getSnapshot() {
        try {
            return adminDAO.getDashboardSnapshot();
        } catch (SQLException e) {
            throw new RuntimeException("Error getting dashboard snapshot", e);
        }
    }

    public int getTotalPrisoners() {
        return getSnapshot().getTotalPrisoners();
    }

    public int getTotalStaff() {
        return getSnapshot().getTotalStaff();
    }

    public int getPendingVisitRequests() {
        return getSnapshot().getPendingVisits();
    }

    public int getApprovedVisits() {
        return getSnapshot().getApprovedVisits();
    }

    public List<PrisonerSummary> getRecentPrisoners(int limit) {
        try {
            return adminDAO.getRecentPrisoners(limit);
        } catch (SQLException e) {
            throw new RuntimeException("Error getting recent prisoners", e);
        }
    }

    public List<VisitRequestSummary> getPendingVisitRequests(int limit) {
        try {
            return adminDAO.getPendingVisitRequests(limit);
        } catch (SQLException e) {
            throw new RuntimeException("Error getting pending visit requests", e);
        }
    }

    public List<ActivitySummary> getRecentActivities(int limit) {
        try {
            return adminDAO.getRecentActivities(limit);
        } catch (SQLException e) {
            throw new RuntimeException("Error getting recent activities", e);
        }
    }

    public static class DashboardSnapshot {
        private final int totalPrisoners;
        private final int activePrisoners;
        private final int pendingVisits;
        private final int approvedVisits;
        private final int totalStaff;
        private final int totalFamilies;

        public DashboardSnapshot(int totalPrisoners, int activePrisoners, int pendingVisits,
                int approvedVisits, int totalStaff, int totalFamilies) {
            this.totalPrisoners = totalPrisoners;
            this.activePrisoners = activePrisoners;
            this.pendingVisits = pendingVisits;
            this.approvedVisits = approvedVisits;
            this.totalStaff = totalStaff;
            this.totalFamilies = totalFamilies;
        }

        public int getTotalPrisoners() {
            return totalPrisoners;
        }

        public int getActivePrisoners() {
            return activePrisoners;
        }

        public int getPendingVisits() {
            return pendingVisits;
        }

        public int getApprovedVisits() {
            return approvedVisits;
        }

        public int getTotalStaff() {
            return totalStaff;
        }

        public int getTotalFamilies() {
            return totalFamilies;
        }
    }

    public static class PrisonerSummary {
        private final String prisonerId;
        private final String fullName;
        private final String crimeType;
        private final String blockNumber;
        private final String securityLevel;
        private final String status;

        public PrisonerSummary(String prisonerId, String fullName, String crimeType,
                String blockNumber, String securityLevel, String status) {
            this.prisonerId = prisonerId;
            this.fullName = fullName;
            this.crimeType = crimeType;
            this.blockNumber = blockNumber;
            this.securityLevel = securityLevel;
            this.status = status;
        }

        public String getPrisonerId() {
            return prisonerId;
        }

        public String getFullName() {
            return fullName;
        }

        public String getCrimeType() {
            return crimeType;
        }

        public String getBlockNumber() {
            return blockNumber;
        }

        public String getSecurityLevel() {
            return securityLevel;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class VisitRequestSummary {
        private final int requestId;
        private final String visitorName;
        private final String prisonerName;
        private final String preferredDate;
        private final String status;

        public VisitRequestSummary(int requestId, String visitorName, String prisonerName,
                String preferredDate, String status) {
            this.requestId = requestId;
            this.visitorName = visitorName;
            this.prisonerName = prisonerName;
            this.preferredDate = preferredDate;
            this.status = status;
        }

        public int getRequestId() {
            return requestId;
        }

        public String getVisitorName() {
            return visitorName;
        }

        public String getPrisonerName() {
            return prisonerName;
        }

        public String getPreferredDate() {
            return preferredDate;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class ActivitySummary {
        private final String type;
        private final String description;
        private final String timeAgo;
        private final String performedBy;

        public ActivitySummary(String type, String description, String timeAgo, String performedBy) {
            this.type = type;
            this.description = description;
            this.timeAgo = timeAgo;
            this.performedBy = performedBy;
        }

        public String getType() {
            return type;
        }

        public String getDescription() {
            return description;
        }

        public String getTimeAgo() {
            return timeAgo;
        }

        public String getPerformedBy() {
            return performedBy;
        }
    }
}
