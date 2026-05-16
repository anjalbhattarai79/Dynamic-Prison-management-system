package com.anjal.model;

public class FamilyMember {
    private int id;
    private User user;
    private Prisoner prisoner;
    private String relation;
    private String phone;
    private String address;
    private int totalVisits;
    private int pendingVisits;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Prisoner getPrisoner() {
        return prisoner;
    }

    public void setPrisoner(Prisoner prisoner) {
        this.prisoner = prisoner;
    }

    public String getRelation() {
        return relation;
    }

    public void setRelation(String relation) {
        this.relation = relation;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getTotalVisits() {
        return totalVisits;
    }

    public void setTotalVisits(int totalVisits) {
        this.totalVisits = totalVisits;
    }

    public int getPendingVisits() {
        return pendingVisits;
    }

    public void setPendingVisits(int pendingVisits) {
        this.pendingVisits = pendingVisits;
    }
}
