package com.anjal.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Mock dashboard service that provides Nepali-themed sample data until the
 * real persistence layer is implemented.
 */
public class DashboardService {

    private static final String[] PRISONER_FIRST_NAMES = {
            "Suman", "Ramesh", "Bikash", "Nabin", "Prakash", "Suresh", "Roshan", "Aakash",
            "Kamal", "Dipesh", "Arjun", "Birendra", "Saroj", "Manoj", "Kiran", "Tek"
    };

    private static final String[] PRISONER_LAST_NAMES = {
            "Thapa", "Gurung", "Karki", "Tamang", "Rai", "Shrestha", "Basnet", "Magar",
            "Lama", "Khadka", "Bhandari", "Maharjan", "Poudel", "Koirala", "Adhikari", "Ale"
    };

    private static final String[] VISITOR_FIRST_NAMES = {
            "Sunita", "Mina", "Sita", "Gita", "Asmita", "Kabita", "Nirmala", "Saraswati",
            "Rupa", "Anjana", "Dawa", "Pabitra", "Nisha", "Sushma"
    };

    private static final String[] VISITOR_LAST_NAMES = {
            "Thapa", "Shrestha", "Gurung", "Karki", "Basnet", "Lama", "Rai", "Tamang",
            "Khadka", "Maharjan", "Bista", "Kunwar"
    };

    private static final String[] STAFF_NAMES = {
            "Inspector Nabin Karki", "Officer Sita Rai", "Warden Prakash Thapa",
            "Officer Mina Basnet", "Inspector Roshan Gurung", "Officer Kabita Lama"
    };

    private static final String[] CRIME_TYPES = {
            "Fraud", "Cyber Fraud", "Narcotics Trafficking", "Organized Theft",
            "Illegal Arms Possession", "Human Trafficking", "Assault", "Financial Embezzlement"
    };

    private static final String[] BLOCKS = { "A", "B", "C", "D", "E" };
    private static final String[] SECURITY_LEVELS = { "Low", "Medium", "High" };
    private static final String[] STATUS_TYPES = { "Active", "Active", "Active", "Transferred", "Released" };
    private static final String[] ACTIVITY_TYPES = { "add", "update", "visit", "login", "delete" };

    public DashboardSnapshot getSnapshot() {
        Random random = createRandom("snapshot");

        int totalPrisoners = randomBetween(random, 148, 224);
        int activePrisoners = totalPrisoners - randomBetween(random, 8, 24);
        int pendingVisits = randomBetween(random, 7, 21);
        int approvedVisits = randomBetween(random, 32, 68);
        int totalStaff = randomBetween(random, 24, 41);
        int totalFamilies = randomBetween(random, 74, 136);

        return new DashboardSnapshot(
                totalPrisoners,
                activePrisoners,
                pendingVisits,
                approvedVisits,
                totalStaff,
                totalFamilies);
    }

    public int getTotalPrisoners() {
        return getSnapshot().getTotalPrisoners();
    }

    public int getTotalStaff() {
        return getSnapshot().getTotalStaff();
    }

    public int getPendingVisitRequests() {
        return getSnapshot().getPendingVisits();
    }

    public int getApprovedVisits() {
        return getSnapshot().getApprovedVisits();
    }

    public List<PrisonerSummary> getRecentPrisoners(int limit) {
        Random random = createRandom("recent-prisoners");
        int count = Math.max(1, limit);
        List<PrisonerSummary> prisoners = new ArrayList<>();

        for (int i = 0; i < count; i++) {
            int serial = 100 + i + random.nextInt(30);
            prisoners.add(new PrisonerSummary(
                    String.format("NP-PMS-%03d", serial),
                    buildName(random, PRISONER_FIRST_NAMES, PRISONER_LAST_NAMES),
                    pick(random, CRIME_TYPES),
                    pick(random, BLOCKS),
                    pick(random, SECURITY_LEVELS),
                    pick(random, STATUS_TYPES)));
        }
        return prisoners;
    }

    public List<VisitRequestSummary> getPendingVisitRequests(int limit) {
        Random random = createRandom("pending-visits");
        int count = Math.max(1, limit);
        List<VisitRequestSummary> requests = new ArrayList<>();

        for (int i = 0; i < count; i++) {
            requests.add(new VisitRequestSummary(
                    4000 + random.nextInt(500) + i,
                    buildName(random, VISITOR_FIRST_NAMES, VISITOR_LAST_NAMES),
                    buildName(random, PRISONER_FIRST_NAMES, PRISONER_LAST_NAMES),
                    LocalDate.now().plusDays(1 + random.nextInt(10)).toString(),
                    "PENDING"));
        }
        return requests;
    }

    public List<ActivitySummary> getRecentActivities(int limit) {
        Random random = createRandom("activity-feed");
        int count = Math.max(1, limit);
        List<ActivitySummary> activities = new ArrayList<>();

        String[] descriptions = {
                "New prisoner intake approved for Block B after Kathmandu District Court transfer.",
                "Visit request reviewed for family member from Pokhara and moved to verification stage.",
                "Security classification updated after monthly internal assessment.",
                "Medical appointment recorded for inmate under medium-security observation.",
                "Night-shift handover completed and custody log verified by duty officer.",
                "Temporary transfer request prepared for hearing attendance at Patan High Court."
        };

        String[] timeAgo = {
                "12 minutes ago", "28 minutes ago", "54 minutes ago",
                "1 hour ago", "2 hours ago", "3 hours ago"
        };

        for (int i = 0; i < count; i++) {
            activities.add(new ActivitySummary(
                    pick(random, ACTIVITY_TYPES),
                    descriptions[i % descriptions.length],
                    timeAgo[i % timeAgo.length],
                    STAFF_NAMES[i % STAFF_NAMES.length]));
        }
        return activities;
    }

    private Random createRandom(String scope) {
        long seed = LocalDate.now().toEpochDay() * 37L + scope.hashCode();
        return new Random(seed);
    }

    private static int randomBetween(Random random, int min, int max) {
        return min + random.nextInt(max - min + 1);
    }

    private static String pick(Random random, String[] values) {
        return values[random.nextInt(values.length)];
    }

    private static String buildName(Random random, String[] firstNames, String[] lastNames) {
        return pick(random, firstNames) + " " + pick(random, lastNames);
    }

    public static class DashboardSnapshot {
        private final int totalPrisoners;
        private final int activePrisoners;
        private final int pendingVisits;
        private final int approvedVisits;
        private final int totalStaff;
        private final int totalFamilies;

        public DashboardSnapshot(int totalPrisoners, int activePrisoners, int pendingVisits,
                int approvedVisits, int totalStaff, int totalFamilies) {
            this.totalPrisoners = totalPrisoners;
            this.activePrisoners = activePrisoners;
            this.pendingVisits = pendingVisits;
            this.approvedVisits = approvedVisits;
            this.totalStaff = totalStaff;
            this.totalFamilies = totalFamilies;
        }

        public int getTotalPrisoners() {
            return totalPrisoners;
        }

        public int getActivePrisoners() {
            return activePrisoners;
        }

        public int getPendingVisits() {
            return pendingVisits;
        }

        public int getApprovedVisits() {
            return approvedVisits;
        }

        public int getTotalStaff() {
            return totalStaff;
        }

        public int getTotalFamilies() {
            return totalFamilies;
        }
    }

    public static class PrisonerSummary {
        private final String prisonerId;
        private final String fullName;
        private final String crimeType;
        private final String blockNumber;
        private final String securityLevel;
        private final String status;

        public PrisonerSummary(String prisonerId, String fullName, String crimeType,
                String blockNumber, String securityLevel, String status) {
            this.prisonerId = prisonerId;
            this.fullName = fullName;
            this.crimeType = crimeType;
            this.blockNumber = blockNumber;
            this.securityLevel = securityLevel;
            this.status = status;
        }

        public String getPrisonerId() {
            return prisonerId;
        }

        public String getFullName() {
            return fullName;
        }

        public String getCrimeType() {
            return crimeType;
        }

        public String getBlockNumber() {
            return blockNumber;
        }

        public String getSecurityLevel() {
            return securityLevel;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class VisitRequestSummary {
        private final int requestId;
        private final String visitorName;
        private final String prisonerName;
        private final String preferredDate;
        private final String status;

        public VisitRequestSummary(int requestId, String visitorName, String prisonerName,
                String preferredDate, String status) {
            this.requestId = requestId;
            this.visitorName = visitorName;
            this.prisonerName = prisonerName;
            this.preferredDate = preferredDate;
            this.status = status;
        }

        public int getRequestId() {
            return requestId;
        }

        public String getVisitorName() {
            return visitorName;
        }

        public String getPrisonerName() {
            return prisonerName;
        }

        public String getPreferredDate() {
            return preferredDate;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class ActivitySummary {
        private final String type;
        private final String description;
        private final String timeAgo;
        private final String performedBy;

        public ActivitySummary(String type, String description, String timeAgo, String performedBy) {
            this.type = type;
            this.description = description;
            this.timeAgo = timeAgo;
            this.performedBy = performedBy;
        }

        public String getType() {
            return type;
        }

        public String getDescription() {
            return description;
        }

        public String getTimeAgo() {
            return timeAgo;
        }

        public String getPerformedBy() {
            return performedBy;
        }
    }
}
