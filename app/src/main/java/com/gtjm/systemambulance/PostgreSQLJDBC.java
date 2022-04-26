package com.gtjm.systemambulance;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * PostgreSQLJDBC 
 * Connect to the Postgres JDBC 
 */
public class PostgreSQLJDBC {
    
    public static Connection connect() {
        Connection c = null;
        String dbUrl = Config.getProperty("config.JDBC.url");
        String dbUser = Config.getProperty("config.JDBC.user");
        String dbPassword = Config.getProperty("config.JDBC.password");

        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
                .getConnection(
                            dbUrl, dbUser, dbPassword);
            c.setAutoCommit(false);
            
            System.out.println("Opened database successfully");

        } catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
        return c; 
    }
    
}