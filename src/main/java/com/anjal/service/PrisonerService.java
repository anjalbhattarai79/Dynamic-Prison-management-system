package com.anjal.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import com.anjal.model.DeletedPrisoner;
import com.anjal.model.Prisoner;

/**
 * In-memory prisoner store for test mode when MySQL is not in use.
 */
public class PrisonerService {

    private static final AtomicInteger ID_SEQUENCE = new AtomicInteger(1);
    private static final List<Prisoner> PRISONERS = Collections.synchronizedList(new ArrayList<>());
    private static final List<DeletedPrisoner> TRASH = Collections.synchronizedList(new ArrayList<>());

    public Prisoner save(Prisoner prisoner) {
        if (prisoner == null) {
            throw new IllegalArgumentException("Prisoner is required");
        }

        if (prisoner.getId() <= 0) {
            prisoner.setId(ID_SEQUENCE.getAndIncrement());
        }

        if (prisoner.getPrisonerId() == null || prisoner.getPrisonerId().trim().isEmpty()) {
            prisoner.setPrisonerId(String.format("PR-%05d", prisoner.getId()));
        }
        prisoner.setDeleted(false);

        synchronized (PRISONERS) {
            PRISONERS.removeIf(existing -> existing.getId() == prisoner.getId());
            PRISONERS.add(copy(prisoner));
        }

        return copy(prisoner);
    }

    public List<Prisoner> findAll() {
        synchronized (PRISONERS) {
            List<Prisoner> snapshot = new ArrayList<>();
            for (Prisoner prisoner : PRISONERS) {
                if (!prisoner.isDeleted()) {
                    snapshot.add(copy(prisoner));
                }
            }
            return snapshot;
        }
    }

    public List<DeletedPrisoner> findTrashed() {
        synchronized (TRASH) {
            List<DeletedPrisoner> snapshot = new ArrayList<>();
            for (DeletedPrisoner deletedPrisoner : TRASH) {
                snapshot.add(copy(deletedPrisoner));
            }
            return snapshot;
        }
    }

    public Prisoner findByPrisonerId(String prisonerId) {
        if (prisonerId == null) {
            return null;
        }
        synchronized (PRISONERS) {
            for (Prisoner prisoner : PRISONERS) {
                if (prisonerId.equalsIgnoreCase(prisoner.getPrisonerId())) {
                    return copy(prisoner);
                }
            }
        }
        return null;
    }

    public Prisoner updateByPrisonerId(String prisonerId, Prisoner updatedPrisoner) {
        if (prisonerId == null || updatedPrisoner == null) {
            return null;
        }

        synchronized (PRISONERS) {
            for (int i = 0; i < PRISONERS.size(); i++) {
                Prisoner existing = PRISONERS.get(i);
                if (prisonerId.equalsIgnoreCase(existing.getPrisonerId())) {
                    updatedPrisoner.setId(existing.getId());
                    updatedPrisoner.setPrisonerId(existing.getPrisonerId());
                    updatedPrisoner.setDeleted(false);
                    if (updatedPrisoner.getPhotoDataUri() == null || updatedPrisoner.getPhotoDataUri().isBlank()) {
                        updatedPrisoner.setPhotoDataUri(existing.getPhotoDataUri());
                    }
                    PRISONERS.set(i, copy(updatedPrisoner));
                    return copy(updatedPrisoner);
                }
            }
        }
        return null;
    }

    public boolean softDeleteByPrisonerId(String prisonerId) {
        if (prisonerId == null) {
            return false;
        }
        synchronized (TRASH) {
            synchronized (PRISONERS) {
                for (int i = 0; i < PRISONERS.size(); i++) {
                    Prisoner prisoner = PRISONERS.get(i);
                    if (prisonerId.equalsIgnoreCase(prisoner.getPrisonerId())) {
                        DeletedPrisoner deletedPrisoner = new DeletedPrisoner();
                        deletedPrisoner.setId(TRASH.size() + 1);
                        deletedPrisoner.setPrisoner(copy(prisoner));
                        deletedPrisoner.setDeletedAt(LocalDateTime.now());
                        deletedPrisoner.setReason("Moved to trash");
                        TRASH.add(deletedPrisoner);
                        PRISONERS.remove(i);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public boolean restoreByPrisonerId(String prisonerId) {
        if (prisonerId == null) {
            return false;
        }
        synchronized (TRASH) {
            for (int i = 0; i < TRASH.size(); i++) {
                DeletedPrisoner deletedPrisoner = TRASH.get(i);
                Prisoner prisoner = deletedPrisoner.getPrisoner();
                if (prisoner != null && prisonerId.equalsIgnoreCase(prisoner.getPrisonerId())) {
                    Prisoner restored = copy(prisoner);
                    restored.setDeleted(false);
                    synchronized (PRISONERS) {
                        PRISONERS.removeIf(existing -> prisonerId.equalsIgnoreCase(existing.getPrisonerId()));
                        PRISONERS.add(restored);
                    }
                    TRASH.remove(i);
                    return true;
                }
            }
        }
        return false;
    }

    public boolean permanentlyDeleteByPrisonerId(String prisonerId) {
        if (prisonerId == null) {
            return false;
        }
        synchronized (TRASH) {
            for (int i = 0; i < TRASH.size(); i++) {
                DeletedPrisoner deletedPrisoner = TRASH.get(i);
                Prisoner prisoner = deletedPrisoner.getPrisoner();
                if (prisoner != null && prisonerId.equalsIgnoreCase(prisoner.getPrisonerId())) {
                    TRASH.remove(i);
                    return true;
                }
            }
        }
        return false;
    }

    public int bulkDeleteByPrisonerIds(List<String> prisonerIds) {
        if (prisonerIds == null || prisonerIds.isEmpty()) {
            return 0;
        }
        int updated = 0;
        for (String prisonerId : prisonerIds) {
            if (softDeleteByPrisonerId(prisonerId)) {
                updated++;
            }
        }
        return updated;
    }

    public int bulkRestoreByPrisonerIds(List<String> prisonerIds) {
        if (prisonerIds == null || prisonerIds.isEmpty()) {
            return 0;
        }
        int updated = 0;
        for (String prisonerId : prisonerIds) {
            if (restoreByPrisonerId(prisonerId)) {
                updated++;
            }
        }
        return updated;
    }

    public int bulkPermanentDeleteByPrisonerIds(List<String> prisonerIds) {
        if (prisonerIds == null || prisonerIds.isEmpty()) {
            return 0;
        }
        int updated = 0;
        for (String prisonerId : prisonerIds) {
            if (permanentlyDeleteByPrisonerId(prisonerId)) {
                updated++;
            }
        }
        return updated;
    }

    public void clear() {
        synchronized (PRISONERS) {
            PRISONERS.clear();
            ID_SEQUENCE.set(1);
        }
        synchronized (TRASH) {
            TRASH.clear();
        }
    }

    private Prisoner copy(Prisoner source) {
        Prisoner target = new Prisoner();
        target.setId(source.getId());
        target.setPrisonerId(source.getPrisonerId());
        target.setFullName(source.getFullName());
        target.setDateOfBirth(source.getDateOfBirth());
        target.setGender(source.getGender());
        target.setCrimeType(source.getCrimeType());
        target.setSentenceYears(source.getSentenceYears());
        target.setAdmissionDate(source.getAdmissionDate());
        target.setReleaseDate(source.getReleaseDate());
        target.setBlockNumber(source.getBlockNumber());
        target.setSecurityLevel(source.getSecurityLevel());
        target.setStatus(source.getStatus());
        target.setEmergencyContact(source.getEmergencyContact());
        target.setPhotoDataUri(source.getPhotoDataUri());
        target.setDeleted(source.isDeleted());
        return target;
    }

    private DeletedPrisoner copy(DeletedPrisoner source) {
        DeletedPrisoner target = new DeletedPrisoner();
        target.setId(source.getId());
        target.setPrisoner(source.getPrisoner() != null ? copy(source.getPrisoner()) : null);
        target.setDeletedAt(source.getDeletedAt());
        target.setDeletedBy(source.getDeletedBy());
        target.setReason(source.getReason());
        return target;
    }

    public LocalDate calculateReleaseDate(LocalDate admissionDate, int sentenceYears) {
        if (admissionDate == null || sentenceYears <= 0) {
            return null;
        }
        return admissionDate.plusYears(sentenceYears);
    }
}
