package com.anjal.service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import com.anjal.dao.FamilyDAO;
import com.anjal.dao.PrisonerDAO;
import com.anjal.dao.UserDAO;
import com.anjal.model.DeletedPrisoner;
import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.util.PasswordUtil;
import java.time.format.DateTimeFormatter;

/**
 * Service for managing prisoners, backed by MySQL database.
 */
public class PrisonerService {

    private final PrisonerDAO prisonerDAO = new PrisonerDAO();
    private final UserDAO userDAO = new UserDAO();
    private final FamilyDAO familyDAO = new FamilyDAO();
    private static final DateTimeFormatter dtFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    private String getTimestamp() {
        return LocalDateTime.now().format(dtFormatter);
    }

    public Prisoner save(Prisoner prisoner) {
        if (prisoner == null) {
            throw new IllegalArgumentException("Prisoner is required");
        }
        try {
            if (prisoner.getPrisonerId() == null || prisoner.getPrisonerId().trim().isEmpty()) {
                prisoner.setPrisonerId(prisonerDAO.getNextPrisonerId());
            }
            prisoner.setDeleted(false);
            prisonerDAO.save(prisoner);
            Prisoner saved = prisonerDAO.findByPrisonerId(prisoner.getPrisonerId());

            // Automatically create a default Family Portal account
            // Username (Email) = Prisoner ID, Password = Family@123
            System.out.println("[" + getTimestamp() + "] [PROVISION] Creating default family portal for Prisoner: " + saved.getPrisonerId());
            String salt = PasswordUtil.generateSalt();
            String hash = PasswordUtil.hashPassword("Family@123", salt);
            User familyUser = userDAO.createFamilyUser(
                saved.getFullName() + " Family", 
                saved.getPrisonerId(), // Use the Prisoner ID as the identifier
                hash, 
                salt
            );
            
            if (familyUser != null) {
                System.out.println("[" + getTimestamp() + "] [PROVISION] SUCCESS: Family User Account created. ID: " + familyUser.getId());
                familyDAO.createDefaultFamilyMember(familyUser.getId(), saved.getId(), "Family Contact");
                System.out.println("[" + getTimestamp() + "] [PROVISION] Linked Portal Account to Prisoner record.");
            } else {
                System.err.println("[" + getTimestamp() + "] [PROVISION] FAILED: Could not create family user for prisoner: " + saved.getPrisonerId());
            }

            return saved;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error saving prisoner", e);
        }
    }

    public List<Prisoner> findAll() {
        try {
            return prisonerDAO.findAll();
        } catch (SQLException e) {
            throw new RuntimeException("Error finding all prisoners", e);
        }
    }

    public List<DeletedPrisoner> findTrashed() {
        try {
            List<Prisoner> trashed = prisonerDAO.findTrashed();
            return trashed.stream().map(p -> {
                DeletedPrisoner dp = new DeletedPrisoner();
                dp.setPrisoner(p);
                dp.setDeletedAt(LocalDateTime.now()); // DB doesn't store this yet in schema but we can mock for now or update schema
                dp.setReason("Moved to trash");
                return dp;
            }).collect(Collectors.toList());
        } catch (SQLException e) {
            throw new RuntimeException("Error finding trashed prisoners", e);
        }
    }

    public Prisoner findByPrisonerId(String prisonerId) {
        try {
            return prisonerDAO.findByPrisonerId(prisonerId);
        } catch (SQLException e) {
            throw new RuntimeException("Error finding prisoner by ID", e);
        }
    }

    public Prisoner updateByPrisonerId(String prisonerId, Prisoner updatedPrisoner) {
        try {
            Prisoner existing = prisonerDAO.findByPrisonerId(prisonerId);
            if (existing != null) {
                updatedPrisoner.setPrisonerId(existing.getPrisonerId());
                if (updatedPrisoner.getPhotoDataUri() == null || updatedPrisoner.getPhotoDataUri().isBlank()) {
                    updatedPrisoner.setPhotoDataUri(existing.getPhotoDataUri());
                }
                prisonerDAO.update(updatedPrisoner);
                return prisonerDAO.findByPrisonerId(prisonerId);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error updating prisoner", e);
        }
        return null;
    }

    public boolean softDeleteByPrisonerId(String prisonerId) {
        try {
            // Defaulting auditor ID to 1 (Admin) for now
            prisonerDAO.softDelete(prisonerId, 1, "Moved to trash");
            return true;
        } catch (SQLException e) {
            throw new RuntimeException("Error soft deleting prisoner", e);
        }
    }

    public boolean restoreByPrisonerId(String prisonerId) {
        try {
            prisonerDAO.restore(prisonerId);
            return true;
        } catch (SQLException e) {
            throw new RuntimeException("Error restoring prisoner", e);
        }
    }

    public boolean permanentlyDeleteByPrisonerId(String prisonerId) {
        try {
            prisonerDAO.permanentlyDelete(prisonerId);
            return true;
        } catch (SQLException e) {
            throw new RuntimeException("Error permanently deleting prisoner", e);
        }
    }

    public int bulkDeleteByPrisonerIds(List<String> prisonerIds) {
        int count = 0;
        for (String id : prisonerIds) {
            if (softDeleteByPrisonerId(id)) count++;
        }
        return count;
    }

    public int bulkRestoreByPrisonerIds(List<String> prisonerIds) {
        int count = 0;
        for (String id : prisonerIds) {
            if (restoreByPrisonerId(id)) count++;
        }
        return count;
    }

    public int bulkPermanentDeleteByPrisonerIds(List<String> prisonerIds) {
        int count = 0;
        for (String id : prisonerIds) {
            if (permanentlyDeleteByPrisonerId(id)) count++;
        }
        return count;
    }

    public LocalDate calculateReleaseDate(LocalDate admissionDate, int sentenceYears) {
        if (admissionDate == null || sentenceYears <= 0) {
            return null;
        }
        return admissionDate.plusYears(sentenceYears);
    }
}
