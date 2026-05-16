package com.anjal.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.service.PrisonerService;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Serves the prisoner list page from a stable URL.
 */
@WebServlet("/prisoner-list")
public class PrisonerListController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final PrisonerService prisonerService = new PrisonerService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		User user = SessionUtil.getLoggedInUser(request.getSession(false));
		if (user == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String role = user.getRole() != null ? user.getRole().getName() : "";
		if (!"ADMIN".equalsIgnoreCase(role) && !"STAFF".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/unauthorized");
			return;
		}

		String action = request.getParameter("action");
		if ("export".equalsIgnoreCase(action)) {
			response.setContentType("text/csv");
			response.setHeader("Content-Disposition", "attachment; filename=prisoners.csv");
			response.getWriter().write(buildCsv(prisonerService.findAll()));
			return;
		}

		request.setAttribute("prisonersJson", buildPrisonersJson(prisonerService.findAll()));
		request.setAttribute("role", role);
		request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
		request.setAttribute("activePage", "prisoners");
		request.getRequestDispatcher("/WEB-INF/pages/prisoner-list.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		User user = SessionUtil.getLoggedInUser(request.getSession(false));
		if (user == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String role = user.getRole() != null ? user.getRole().getName() : "";
		if (!"ADMIN".equalsIgnoreCase(role) && !"STAFF".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/unauthorized");
			return;
		}

		String action = request.getParameter("action");
		if ("softDelete".equalsIgnoreCase(action)) {
			boolean deleted = prisonerService.softDeleteByPrisonerId(request.getParameter("prisonerId"));
			writeJson(response, "{\"success\":" + deleted + "}");
			return;
		}

		if ("update".equalsIgnoreCase(action)) {
			try {
				Prisoner prisoner = buildPrisonerFromRequest(request);
				Prisoner updated = prisonerService.updateByPrisonerId(request.getParameter("prisonerId"), prisoner);
				if (updated != null) {
					writeJson(response, "{\"success\":true}");
				} else {
					response.setStatus(HttpServletResponse.SC_NOT_FOUND);
					writeJson(response, "{\"success\":false,\"error\":\"Prisoner not found.\"}");
				}
			} catch (RuntimeException ex) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				writeJson(response, "{\"success\":false,\"error\":\"Invalid prisoner data.\"}");
			}
			return;
		}

		if ("bulkDelete".equalsIgnoreCase(action)) {
			String idsRaw = request.getParameter("ids");
			List<String> ids = new ArrayList<>();
			if (idsRaw != null && !idsRaw.trim().isEmpty()) {
				for (String id : idsRaw.split(",")) {
					if (id != null && !id.trim().isEmpty()) {
						ids.add(id.trim());
					}
				}
			}
			int updated = prisonerService.bulkDeleteByPrisonerIds(ids);
			writeJson(response, "{\"success\":true,\"updated\":" + updated + "}");
			return;
		}

		response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		writeJson(response, "{\"error\":\"Unsupported action.\"}");
	}

	private static void writeJson(HttpServletResponse response, String json) throws IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write(json);
	}

	private static String buildPrisonersJson(List<Prisoner> prisoners) {
		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < prisoners.size(); i++) {
			Prisoner p = prisoners.get(i);
			if (i > 0) {
				json.append(',');
			}
			json.append('{').append("\"prisonerId\":\"").append(escape(p.getPrisonerId())).append("\",")
					.append("\"fullName\":\"").append(escape(p.getFullName())).append("\",")
					.append("\"photoDataUri\":\"").append(escape(p.getPhotoDataUri())).append("\",")
					.append("\"dateOfBirth\":\"").append(p.getDateOfBirth() != null ? p.getDateOfBirth() : "")
					.append("\",").append("\"gender\":\"").append(escape(p.getGender())).append("\",")
					.append("\"crimeType\":\"").append(escape(p.getCrimeType())).append("\",")
					.append("\"sentenceYears\":").append(p.getSentenceYears()).append(',')
					.append("\"admissionDate\":\"").append(p.getAdmissionDate() != null ? p.getAdmissionDate() : "")
					.append("\",").append("\"releaseDate\":\"")
					.append(p.getReleaseDate() != null ? p.getReleaseDate() : "").append("\",")
					.append("\"blockNumber\":\"").append(escape(p.getBlockNumber())).append("\",")
					.append("\"securityLevel\":\"").append(escape(p.getSecurityLevel())).append("\",")
					.append("\"status\":\"").append(escape(p.getStatus())).append("\",")
					.append("\"emergencyContact\":\"").append(escape(p.getEmergencyContact())).append("\"").append('}');
		}
		return json.append(']').toString();
	}

	private static String buildCsv(List<Prisoner> prisoners) {
		StringBuilder csv = new StringBuilder();
		csv.append("Prisoner ID,Full Name,Crime Type,Sentence Years,Block,Security,Status\n");
		for (Prisoner p : prisoners) {
			csv.append(csvValue(p.getPrisonerId())).append(',').append(csvValue(p.getFullName())).append(',')
					.append(csvValue(p.getCrimeType())).append(',').append(p.getSentenceYears()).append(',')
					.append(csvValue(p.getBlockNumber())).append(',').append(csvValue(p.getSecurityLevel())).append(',')
					.append(csvValue(p.getStatus())).append('\n');
		}
		return csv.toString();
	}

	private static String csvValue(String value) {
		if (value == null) {
			return "\"\"";
		}
		return "\"" + value.replace("\"", "\"\"") + "\"";
	}

	private static String escape(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}

	private Prisoner buildPrisonerFromRequest(HttpServletRequest request) {
		Prisoner prisoner = new Prisoner();
		prisoner.setFullName(request.getParameter("fullName"));
		String dob = request.getParameter("dateOfBirth");
		if (dob != null && !dob.isBlank()) {
			prisoner.setDateOfBirth(java.time.LocalDate.parse(dob));
		}
		prisoner.setGender(request.getParameter("gender"));
		prisoner.setCrimeType(request.getParameter("crimeType"));
		String sentenceYears = request.getParameter("sentenceYears");
		prisoner.setSentenceYears(
				sentenceYears == null || sentenceYears.isBlank() ? 0 : Integer.parseInt(sentenceYears));
		String admissionDate = request.getParameter("admissionDate");
		if (admissionDate != null && !admissionDate.isBlank()) {
			prisoner.setAdmissionDate(java.time.LocalDate.parse(admissionDate));
		}
		String releaseDate = request.getParameter("releaseDate");
		if (releaseDate != null && !releaseDate.isBlank()) {
			prisoner.setReleaseDate(java.time.LocalDate.parse(releaseDate));
		}
		prisoner.setBlockNumber(request.getParameter("blockNumber"));
		prisoner.setSecurityLevel(request.getParameter("securityLevel"));
		prisoner.setStatus(request.getParameter("status"));
		prisoner.setEmergencyContact(request.getParameter("emergencyContact"));
		return prisoner;
	}
}
