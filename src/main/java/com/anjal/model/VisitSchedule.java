package com.anjal.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class VisitSchedule {
    private int id;
    private VisitRequest visitRequest;
    private LocalDate scheduledDate;
    private LocalTime scheduledTime;
    private String room;
    private String notes;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public VisitRequest getVisitRequest() {
        return visitRequest;
    }

    public void setVisitRequest(VisitRequest visitRequest) {
        this.visitRequest = visitRequest;
    }

    public LocalDate getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDate scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public LocalTime getScheduledTime() {
        return scheduledTime;
    }

    public void setScheduledTime(LocalTime scheduledTime) {
        this.scheduledTime = scheduledTime;
    }

    public String getRoom() {
        return room;
    }

    public void setRoom(String room) {
        this.room = room;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
