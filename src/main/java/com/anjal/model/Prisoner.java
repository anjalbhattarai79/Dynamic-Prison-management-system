package com.anjal.model;

import java.time.LocalDate;

public class Prisoner {
	private int id;
	private String prisonerId;
	private String fullName;
	private LocalDate dateOfBirth;
	private String gender;
	private String crimeType;
	private int sentenceYears;
	private LocalDate admissionDate;
	private LocalDate releaseDate;
	private String blockNumber;
	private String securityLevel;
	private String status;
	private String emergencyContact;
	private String photoDataUri;
	private String healthStatus;
	private String medicalNotes;
	private boolean deleted;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

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

	public LocalDate getDateOfBirth() {
		return dateOfBirth;
	}

	public void setDateOfBirth(LocalDate dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getCrimeType() {
		return crimeType;
	}

	public void setCrimeType(String crimeType) {
		this.crimeType = crimeType;
	}

	public int getSentenceYears() {
		return sentenceYears;
	}

	public void setSentenceYears(int sentenceYears) {
		this.sentenceYears = sentenceYears;
	}

	public LocalDate getAdmissionDate() {
		return admissionDate;
	}

	public void setAdmissionDate(LocalDate admissionDate) {
		this.admissionDate = admissionDate;
	}

	public LocalDate getReleaseDate() {
		return releaseDate;
	}

	public void setReleaseDate(LocalDate releaseDate) {
		this.releaseDate = releaseDate;
	}

	public String getBlockNumber() {
		return blockNumber;
	}

	public void setBlockNumber(String blockNumber) {
		this.blockNumber = blockNumber;
	}

	public String getSecurityLevel() {
		return securityLevel;
	}

	public void setSecurityLevel(String securityLevel) {
		this.securityLevel = securityLevel;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getEmergencyContact() {
		return emergencyContact;
	}

	public void setEmergencyContact(String emergencyContact) {
		this.emergencyContact = emergencyContact;
	}

	public String getPhotoDataUri() {
		return photoDataUri;
	}

	public void setPhotoDataUri(String photoDataUri) {
		this.photoDataUri = photoDataUri;
	}

	public String getHealthStatus() {
		return healthStatus;
	}

	public void setHealthStatus(String healthStatus) {
		this.healthStatus = healthStatus;
	}

	public String getMedicalNotes() {
		return medicalNotes;
	}

	public void setMedicalNotes(String medicalNotes) {
		this.medicalNotes = medicalNotes;
	}

	public boolean isDeleted() {
		return deleted;
	}

	public void setDeleted(boolean deleted) {
		this.deleted = deleted;
	}
}
