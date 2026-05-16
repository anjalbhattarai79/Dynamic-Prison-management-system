package com.anjal.controller;

import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Base64;

import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.service.PrisonerService;
import com.anjal.util.SessionUtil;
import com.anjal.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

/**
 * Serves the add-prisoner form from a stable URL instead of exposing the JSP.
 */
@MultipartConfig
@WebServlet("/add-prisoner")
public class AddPrisonerController extends HttpServlet {
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

		request.setAttribute("role", role);
		request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
		request.setAttribute("activePage", "prisoners");
		request.getRequestDispatcher("/WEB-INF/pages/add-prisoner.jsp").forward(request, response);
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
		if (!"add".equalsIgnoreCase(action)) {
			request.setAttribute("errorMsg", "Edit mode is not implemented yet.");
			request.setAttribute("role", role);
			request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
			request.getRequestDispatcher("/WEB-INF/pages/add-prisoner.jsp").forward(request, response);
			return;
		}

		String fullName = request.getParameter("fullName");
		String dateOfBirth = request.getParameter("dateOfBirth");
		String gender = request.getParameter("gender");
		String crimeType = request.getParameter("crimeType");
		String sentenceYears = request.getParameter("sentenceYears");
		String admissionDate = request.getParameter("admissionDate");
		String releaseDate = request.getParameter("releaseDate");
		String blockNumber = request.getParameter("blockNumber");
		String securityLevel = request.getParameter("securityLevel");
		String status = request.getParameter("status");
		String emergencyContact = request.getParameter("emergencyContact");

		if (!ValidationUtil.isValidFullName(fullName)) {
			reject(request, response, role, user, "Full name is required and must contain letters only.");
			return;
		}
		if (!ValidationUtil.isNotEmpty(dateOfBirth) || !ValidationUtil.isNotEmpty(gender)
				|| !ValidationUtil.isNotEmpty(crimeType) || !ValidationUtil.isNotEmpty(sentenceYears)
				|| !ValidationUtil.isNotEmpty(admissionDate) || !ValidationUtil.isNotEmpty(blockNumber)
				|| !ValidationUtil.isNotEmpty(securityLevel) || !ValidationUtil.isNotEmpty(status)) {
			reject(request, response, role, user, "Please complete all required fields.");
			return;
		}

		try {
			Prisoner prisoner = new Prisoner();
			prisoner.setFullName(fullName.trim());
			prisoner.setDateOfBirth(LocalDate.parse(dateOfBirth));
			prisoner.setGender(gender.trim());
			prisoner.setCrimeType(crimeType.trim());
			prisoner.setSentenceYears(Integer.parseInt(sentenceYears.trim()));
			prisoner.setAdmissionDate(LocalDate.parse(admissionDate));
			prisoner.setReleaseDate(ValidationUtil.isNotEmpty(releaseDate) ? LocalDate.parse(releaseDate) : null);
			prisoner.setBlockNumber(blockNumber.trim());
			prisoner.setSecurityLevel(securityLevel.trim());
			prisoner.setStatus(status.trim());
			prisoner.setEmergencyContact(ValidationUtil.isNotEmpty(emergencyContact) ? emergencyContact.trim() : null);
			prisoner.setPhotoDataUri(readUploadedPhoto(request));

			Prisoner saved = prisonerService.save(prisoner);

			request.setAttribute("successMsg", "Prisoner saved successfully with ID " + saved.getPrisonerId() + ".");
			request.setAttribute("role", role);
			request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
			request.getRequestDispatcher("/WEB-INF/pages/add-prisoner.jsp").forward(request, response);
		} catch (NumberFormatException | DateTimeParseException ex) {
			reject(request, response, role, user, "Please enter valid values for date and sentence fields.");
		} catch (Exception ex) {
			reject(request, response, role, user, "Unable to save prisoner right now. Please try again.");
		}
	}

	private void reject(HttpServletRequest request, HttpServletResponse response, String role, User user,
			String message) throws ServletException, IOException {
		request.setAttribute("errorMsg", message);
		request.setAttribute("role", role);
		request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
		request.setAttribute("fullName", request.getParameter("fullName"));
		request.setAttribute("dateOfBirth", request.getParameter("dateOfBirth"));
		request.setAttribute("gender", request.getParameter("gender"));
		request.setAttribute("crimeType", request.getParameter("crimeType"));
		request.setAttribute("sentenceYears", request.getParameter("sentenceYears"));
		request.setAttribute("admissionDate", request.getParameter("admissionDate"));
		request.setAttribute("releaseDate", request.getParameter("releaseDate"));
		request.setAttribute("blockNumber", request.getParameter("blockNumber"));
		request.setAttribute("securityLevel", request.getParameter("securityLevel"));
		request.setAttribute("status", request.getParameter("status"));
		request.setAttribute("emergencyContact", request.getParameter("emergencyContact"));
		request.getRequestDispatcher("/WEB-INF/pages/add-prisoner.jsp").forward(request, response);
	}

	private String readUploadedPhoto(HttpServletRequest request) {
		try {
			Part photoPart = request.getPart("photo");
			if (photoPart == null || photoPart.getSize() == 0) {
				return null;
			}
			String contentType = photoPart.getContentType();
			if (contentType == null || !contentType.startsWith("image/")) {
				return null;
			}
			byte[] bytes = readAllBytes(photoPart.getInputStream());
			String mime = contentType.equalsIgnoreCase("image/jpeg") ? "image/jpeg"
					: contentType.equalsIgnoreCase("image/png") ? "image/png"
							: contentType.equalsIgnoreCase("image/gif") ? "image/gif"
									: contentType.equalsIgnoreCase("image/webp") ? "image/webp" : contentType;
			return "data:" + mime + ";base64," + Base64.getEncoder().encodeToString(bytes);
		} catch (Exception ex) {
			return null;
		}
	}

	private byte[] readAllBytes(InputStream inputStream) throws IOException {
		return inputStream.readAllBytes();
	}
}
