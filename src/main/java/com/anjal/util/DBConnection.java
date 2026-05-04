package com.anjal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Simple JDBC utility for obtaining MySQL connections.
 * Adjust URL, user, and password to match your local MySQL setup.
 */
public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/prison_management_db?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root"; // change as needed
    private static final String PASSWORD = "";  // change as needed

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
        initializeDatabase(conn);
        return conn;
    }

    private static boolean initialized = false;
    private static void initializeDatabase(Connection conn) {
        if (initialized) return;
        synchronized (DBConnection.class) {
            if (initialized) return;
            System.out.println("DEBUG: Starting database self-healing initialization...");
            try (java.sql.Statement stmt = conn.createStatement()) {
                
                // Aggressive check for activity_logs
                boolean tableOk = false;
                try {
                    stmt.executeQuery("SELECT 1 FROM activity_logs LIMIT 1").close();
                    tableOk = true;
                } catch (SQLException e) {
                    System.out.println("DEBUG: activity_logs table inaccessible or missing. Attempting force fix...");
                }

                if (!tableOk) {
                    stmt.execute("DROP TABLE IF EXISTS activity_logs");
                    stmt.execute("CREATE TABLE activity_logs (" +
                                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                "user_id INT, " +
                                "action VARCHAR(255) NOT NULL, " +
                                "details TEXT, " +
                                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                    System.out.println("DEBUG: Force-recreated activity_logs table.");
                }

                // Standard check for others
                stmt.execute("CREATE TABLE IF NOT EXISTS notifications (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "user_id INT NOT NULL, " +
                            "title VARCHAR(255), " +
                            "message TEXT, " +
                            "is_read BOOLEAN DEFAULT FALSE, " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                stmt.execute("CREATE TABLE IF NOT EXISTS login_attempts (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "user_id INT, " +
                            "email VARCHAR(255), " +
                            "success BOOLEAN, " +
                            "ip_address VARCHAR(45), " +
                            "attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                
                initialized = true;
                System.out.println("DEBUG: Database initialization completed successfully.");
            } catch (SQLException e) {
                System.err.println("CRITICAL: Database auto-initialization failed!");
                e.printStackTrace();
            }
        }
    }
}
