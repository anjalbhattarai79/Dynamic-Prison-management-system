package com.anjal.controller;

import java.io.IOException;
import java.util.List;

import com.anjal.service.DashboardService;
import com.anjal.service.DashboardService.ActivitySummary;
import com.anjal.service.DashboardService.DashboardSnapshot;
import com.anjal.service.DashboardService.PrisonerSummary;
import com.anjal.service.DashboardService.VisitRequestSummary;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Provides mock JSON data for the admin dashboard widgets.
 */
@WebServlet({ "/api/admin/dashboard/stats", "/api/admin/dashboard/prisoners", "/api/admin/dashboard/visits",
		"/api/admin/dashboard/activity" })
public class AdminDashboardDataController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final DashboardService dashboardService = new DashboardService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");

		String servletPath = request.getServletPath();
		int limit = parseLimit(request.getParameter("limit"), 5);

		switch (servletPath) {
		case "/api/admin/dashboard/stats":
			writeJson(response, buildStatsJson(dashboardService.getSnapshot()));
			break;
		case "/api/admin/dashboard/prisoners":
			writeJson(response, buildPrisonersJson(dashboardService.getRecentPrisoners(limit)));
			break;
		case "/api/admin/dashboard/visits":
			writeJson(response, buildVisitsJson(dashboardService.getPendingVisitRequests(limit)));
			break;
		case "/api/admin/dashboard/activity":
			writeJson(response, buildActivityJson(dashboardService.getRecentActivities(limit)));
			break;
		default:
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			writeJson(response, "{\"error\":\"Endpoint not found.\"}");
			break;
		}
	}

	private static int parseLimit(String rawLimit, int defaultValue) {
		try {
			return rawLimit == null ? defaultValue : Math.max(1, Integer.parseInt(rawLimit));
		} catch (NumberFormatException ex) {
			return defaultValue;
		}
	}

	private static void writeJson(HttpServletResponse response, String json) throws IOException {
		response.getWriter().write(json);
	}

	private static String buildStatsJson(DashboardSnapshot snapshot) {
		return "{" + "\"totalPrisoners\":" + snapshot.getTotalPrisoners() + "," + "\"activePrisoners\":"
				+ snapshot.getActivePrisoners() + "," + "\"pendingVisits\":" + snapshot.getPendingVisits() + ","
				+ "\"approvedVisits\":" + snapshot.getApprovedVisits() + "," + "\"totalStaff\":"
				+ snapshot.getTotalStaff() + "," + "\"totalFamilies\":" + snapshot.getTotalFamilies() + "}";
	}

	private static String buildPrisonersJson(List<PrisonerSummary> prisoners) {
		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < prisoners.size(); i++) {
			PrisonerSummary prisoner = prisoners.get(i);
			if (i > 0) {
				json.append(',');
			}
			json.append('{').append("\"prisonerId\":\"").append(escape(prisoner.getPrisonerId())).append("\",")
					.append("\"fullName\":\"").append(escape(prisoner.getFullName())).append("\",")
					.append("\"crimeType\":\"").append(escape(prisoner.getCrimeType())).append("\",")
					.append("\"blockNumber\":\"").append(escape(prisoner.getBlockNumber())).append("\",")
					.append("\"securityLevel\":\"").append(escape(prisoner.getSecurityLevel())).append("\",")
					.append("\"status\":\"").append(escape(prisoner.getStatus())).append("\"").append('}');
		}
		return json.append(']').toString();
	}

	private static String buildVisitsJson(List<VisitRequestSummary> visits) {
		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < visits.size(); i++) {
			VisitRequestSummary visit = visits.get(i);
			if (i > 0) {
				json.append(',');
			}
			json.append('{').append("\"requestId\":").append(visit.getRequestId()).append(',')
					.append("\"visitorName\":\"").append(escape(visit.getVisitorName())).append("\",")
					.append("\"prisonerName\":\"").append(escape(visit.getPrisonerName())).append("\",")
					.append("\"preferredDate\":\"").append(escape(visit.getPreferredDate())).append("\",")
					.append("\"status\":\"").append(escape(visit.getStatus())).append("\"").append('}');
		}
		return json.append(']').toString();
	}

	private static String buildActivityJson(List<ActivitySummary> activities) {
		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < activities.size(); i++) {
			ActivitySummary activity = activities.get(i);
			if (i > 0) {
				json.append(',');
			}
			json.append('{').append("\"type\":\"").append(escape(activity.getType())).append("\",")
					.append("\"description\":\"").append(escape(activity.getDescription())).append("\",")
					.append("\"timeAgo\":\"").append(escape(activity.getTimeAgo())).append("\",")
					.append("\"performedBy\":\"").append(escape(activity.getPerformedBy())).append("\"").append('}');
		}
		return json.append(']').toString();
	}

	private static String escape(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "\\r").replace("\n", "\\n");
	}
}
