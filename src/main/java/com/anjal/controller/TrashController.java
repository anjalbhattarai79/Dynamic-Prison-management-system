package com.anjal.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.anjal.model.DeletedPrisoner;
import com.anjal.model.Prisoner;
import com.anjal.model.User;
import com.anjal.service.PrisonerService;
import com.anjal.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/trash")
public class TrashController extends HttpServlet {
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

		request.setAttribute("trashedJson", buildTrashedJson(prisonerService.findTrashed()));
		request.setAttribute("role", role);
		request.setAttribute("userName", user.getFullName() != null ? user.getFullName() : "User");
		request.setAttribute("activePage", "trash");
		request.getRequestDispatcher("/WEB-INF/pages/trash.jsp").forward(request, response);
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
		if ("restore".equalsIgnoreCase(action)) {
			boolean restored = prisonerService.restoreByPrisonerId(request.getParameter("prisonerId"));
			writeJson(response, "{\"success\":" + restored + "}");
			return;
		}

		if ("permanentDelete".equalsIgnoreCase(action)) {
			boolean deleted = prisonerService.permanentlyDeleteByPrisonerId(request.getParameter("prisonerId"));
			writeJson(response, "{\"success\":" + deleted + "}");
			return;
		}

		if ("bulkRestore".equalsIgnoreCase(action)) {
			writeJson(response, "{\"success\":true,\"updated\":"
					+ prisonerService.bulkRestoreByPrisonerIds(readIds(request)) + "}");
			return;
		}

		if ("bulkPermanentDelete".equalsIgnoreCase(action)) {
			writeJson(response, "{\"success\":true,\"updated\":"
					+ prisonerService.bulkPermanentDeleteByPrisonerIds(readIds(request)) + "}");
			return;
		}

		response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		writeJson(response, "{\"success\":false,\"error\":\"Unsupported action.\"}");
	}

	private static void writeJson(HttpServletResponse response, String json) throws IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write(json);
	}

	private static List<String> readIds(HttpServletRequest request) {
		String idsRaw = request.getParameter("ids");
		List<String> ids = new ArrayList<>();
		if (idsRaw != null && !idsRaw.trim().isEmpty()) {
			for (String id : idsRaw.split(",")) {
				if (id != null && !id.trim().isEmpty()) {
					ids.add(id.trim());
				}
			}
		}
		return ids;
	}

	private static String buildTrashedJson(List<DeletedPrisoner> trashedPrisoners) {
		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < trashedPrisoners.size(); i++) {
			DeletedPrisoner deleted = trashedPrisoners.get(i);
			Prisoner p = deleted.getPrisoner();
			if (i > 0) {
				json.append(',');
			}
			json.append('{').append("\"prisonerId\":\"").append(escape(p != null ? p.getPrisonerId() : null))
					.append("\",").append("\"fullName\":\"").append(escape(p != null ? p.getFullName() : null))
					.append("\",").append("\"photoDataUri\":\"").append(escape(p != null ? p.getPhotoDataUri() : null))
					.append("\",").append("\"crimeType\":\"").append(escape(p != null ? p.getCrimeType() : null))
					.append("\",").append("\"status\":\"").append(escape(p != null ? p.getStatus() : null))
					.append("\",").append("\"blockNumber\":\"").append(escape(p != null ? p.getBlockNumber() : null))
					.append("\",").append("\"securityLevel\":\"")
					.append(escape(p != null ? p.getSecurityLevel() : null)).append("\",").append("\"deletedAt\":\"")
					.append(deleted.getDeletedAt() != null ? deleted.getDeletedAt() : "").append("\",")
					.append("\"reason\":\"").append(escape(deleted.getReason())).append("\"").append('}');
		}
		return json.append(']').toString();
	}

	private static String escape(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
