package com.anjal.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.anjal.dao.FamilyDAO;

public class FamilyDashboardService {

    private final FamilyDAO familyDAO = new FamilyDAO();

    public int getUpcomingVisitsCount(int userId) {
        try {
            return familyDAO.getUpcomingVisitsCount(userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int getPendingRequestsCount(int userId) {
        try {
            return familyDAO.getPendingRequestsCount(userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int getApprovedVisitsCount(int userId) {
        try {
            return familyDAO.getApprovedVisitsCount(userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int getUnreadNotificationsCount(int userId) {
        try {
            return familyDAO.getUnreadNotificationsCount(userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public String getNextVisitDate(int userId) {
        try {
            return familyDAO.getNextVisitDate(userId);
        } catch (SQLException e) {
            return "N/A";
        }
    }

    public List<VisitRequest> getRecentVisitRequests(int userId) {
        try {
            List<com.anjal.model.VisitRequest> models = familyDAO.getRecentVisitRequests(userId);
            List<VisitRequest> list = new ArrayList<>();
            for (com.anjal.model.VisitRequest m : models) {
                VisitRequest v = new VisitRequest();
                v.setRequestId(m.getId());
                v.setPrisonerName("Check Detail"); // Database query join could provide this if needed
                v.setRequestDate(m.getRequestDate().toString());
                v.setPreferredDate(m.getPreferredVisitDate().toString());
                v.setStatus(m.getStatus());
                list.add(v);
            }
            return list;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public List<Prisoner> getLinkedPrisoners(int userId) {
        try {
            List<com.anjal.model.Prisoner> models = familyDAO.getLinkedPrisoners(userId);
            System.out.println("DEBUG: Found " + models.size() + " linked prisoners for user ID: " + userId);
            List<Prisoner> list = new ArrayList<>();
            for (com.anjal.model.Prisoner m : models) {
                Prisoner p = new Prisoner();
                p.setPrisonerId(m.getPrisonerId());
                p.setFullName(m.getFullName());
                p.setGender(m.getGender());
                p.setCrimeType(m.getCrimeType());
                p.setAdmissionDate(m.getAdmissionDate() != null ? m.getAdmissionDate().toString() : "-");
                p.setReleaseDate(m.getReleaseDate() != null ? m.getReleaseDate().toString() : "TBD");
                p.setDateOfBirth(m.getDateOfBirth() != null ? m.getDateOfBirth().toString() : "-");
                p.setBlockNumber(m.getBlockNumber());
                p.setSecurityLevel(m.getSecurityLevel());
                p.setStatus(m.getStatus());
                p.setSentenceYears(m.getSentenceYears());
                p.setHealthStatus(m.getHealthStatus());
                p.setMedicalNotes(m.getMedicalNotes());
                p.setPhotoDataUri(m.getPhotoDataUri());
                p.setEmergencyContact(m.getEmergencyContact());
                list.add(p);
            }
            return list;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public List<Notification> getRecentNotifications(int userId) {
        try {
            List<com.anjal.model.Notification> models = familyDAO.getRecentNotifications(userId);
            List<Notification> list = new ArrayList<>();
            for (com.anjal.model.Notification m : models) {
                Notification n = new Notification();
                n.setNotificationId(m.getId());
                n.setMessage(m.getMessage());
                n.setIsRead(m.isRead());
                n.setTimeAgo(formatTimeAgo(m.getCreatedAt()));
                list.add(n);
            }
            return list;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private String formatTimeAgo(java.time.LocalDateTime dt) {
        if (dt == null) return "Unknown";
        java.time.Duration duration = java.time.Duration.between(dt, java.time.LocalDateTime.now());
        long mins = duration.toMinutes();
        if (mins < 1) return "Just now";
        if (mins < 60) return mins + "m ago";
        long hours = duration.toHours();
        if (hours < 24) return hours + "h ago";
        return duration.toDays() + "d ago";
    }

    public static class VisitRequest {
        private int requestId;
        private String prisonerName;
        private String requestDate;
        private String preferredDate;
        private String status;

        public int getRequestId() { return requestId; }
        public void setRequestId(int requestId) { this.requestId = requestId; }
        public String getPrisonerName() { return prisonerName; }
        public void setPrisonerName(String prisonerName) { this.prisonerName = prisonerName; }
        public String getRequestDate() { return requestDate; }
        public void setRequestDate(String requestDate) { this.requestDate = requestDate; }
        public String getPreferredDate() { return preferredDate; }
        public void setPreferredDate(String preferredDate) { this.preferredDate = preferredDate; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }

    public static class Prisoner {
        private String prisonerId;
        private String fullName;
        private String gender;
        private String crimeType;
        private String admissionDate;
        private String releaseDate;
        private String dateOfBirth;
        private String blockNumber;
        private String securityLevel;
        private String status;
        private int sentenceYears;
        private String healthStatus;
        private String medicalNotes;
        private String photoDataUri;
        private String emergencyContact;

        public String getPrisonerId() { return prisonerId; }
        public void setPrisonerId(String prisonerId) { this.prisonerId = prisonerId; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getGender() { return gender; }
        public void setGender(String gender) { this.gender = gender; }
        public String getCrimeType() { return crimeType; }
        public void setCrimeType(String crimeType) { this.crimeType = crimeType; }
        public String getAdmissionDate() { return admissionDate; }
        public void setAdmissionDate(String admissionDate) { this.admissionDate = admissionDate; }
        public String getReleaseDate() { return releaseDate; }
        public void setReleaseDate(String releaseDate) { this.releaseDate = releaseDate; }
        public String getDateOfBirth() { return dateOfBirth; }
        public void setDateOfBirth(String dateOfBirth) { this.dateOfBirth = dateOfBirth; }
        public String getBlockNumber() { return blockNumber; }
        public void setBlockNumber(String blockNumber) { this.blockNumber = blockNumber; }
        public String getSecurityLevel() { return securityLevel; }
        public void setSecurityLevel(String securityLevel) { this.securityLevel = securityLevel; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public int getSentenceYears() { return sentenceYears; }
        public void setSentenceYears(int sentenceYears) { this.sentenceYears = sentenceYears; }
        public String getHealthStatus() { return healthStatus; }
        public void setHealthStatus(String healthStatus) { this.healthStatus = healthStatus; }
        public String getMedicalNotes() { return medicalNotes; }
        public void setMedicalNotes(String medicalNotes) { this.medicalNotes = medicalNotes; }
        public String getPhotoDataUri() { return photoDataUri; }
        public void setPhotoDataUri(String photoDataUri) { this.photoDataUri = photoDataUri; }
        public String getEmergencyContact() { return emergencyContact; }
        public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }
    }

    public static class Notification {
        private int notificationId;
        private String message;
        private boolean isRead;
        private String timeAgo;

        public int getNotificationId() { return notificationId; }
        public void setNotificationId(int notificationId) { this.notificationId = notificationId; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public boolean getIsRead() { return isRead; }
        public void setIsRead(boolean isRead) { this.isRead = isRead; }
        public String getTimeAgo() { return timeAgo; }
        public void setTimeAgo(String timeAgo) { this.timeAgo = timeAgo; }
    }
}
