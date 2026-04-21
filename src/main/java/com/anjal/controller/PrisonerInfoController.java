package com.anjal.controller;

import java.io.IOException;
import java.time.LocalDate;

import com.anjal.model.Prisoner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/family-prisoner-info")
public class PrisonerInfoController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// Mocking the Prisoner model based on your class
		Prisoner p = new Prisoner();
		p.setPrisonerId("PR-0142");
		p.setFullName("Ramesh Karki");
		p.setGender("Male");
		p.setDateOfBirth(LocalDate.of(1985, 5, 12));
		p.setAdmissionDate(LocalDate.of(2023, 10, 15));
		p.setReleaseDate(LocalDate.of(2028, 10, 14));
		p.setBlockNumber("2");
		p.setSecurityLevel("MEDIUM");
		p.setStatus("ACTIVE");
		p.setCrimeType("Theft"); // Note: You can choose to hide this from family if preferred
		p.setSentenceYears(5);
		p.setEmergencyContact("+977 9800000000");

		request.setAttribute("p", p);
		request.getRequestDispatcher("/WEB-INF/pages/prisoner-info.jsp").forward(request, response);
	}
}