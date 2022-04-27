package com.gtjm.systemambulance;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * The class that query in the database. It provide an abstraction to be able to easily 
 * request the database.
 * @author gtjm
 *
 */
public class QuestionQuery {

    private String sql;
    private String[] arrayOfFields;
    private Connection c = PostgreSQLJDBC.connect();

    public QuestionQuery(String sql, String[] arrayOfFields) {
        this.sql = sql;
        this.arrayOfFields = arrayOfFields;
    }



    public String runQuery() {
        try {
            ResultSet rs = getResults();
            return stringifyResults(rs);
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    private ResultSet getResults() throws SQLException {
        Statement stmt = c.createStatement();
        String SQL = sql;
        ResultSet rs = stmt.executeQuery(SQL);
        return rs;
    }

    private String stringifyResults(ResultSet rs) throws SQLException {
        String res = "";

        while (rs.next()) {
            for (int i = 0; i < arrayOfFields.length; i++) {
                if (i == 0) {
                    res += rs.getString(arrayOfFields[i]);
                } else {
                    res += ", " + rs.getString(arrayOfFields[i]);
                }
            }
            res += "\n";
        }

        return res;
    }


}
