package com.gtjm.systemambulance;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.stream.Collectors;

/**
 * The class that query in the database. It provide an abstraction to be able to easily 
 * request the database.
 * @author gtjm
 *
 */
public class QuestionQuery {

    private String path;
    private String[] arrayOfFields;
    private Connection c = PostgreSQLJDBC.connect();

    public QuestionQuery(String path, String[] arrayOfFields) {
        this.path = path;
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
        String SQL = getSQLQueryFromFile(path);
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

    private String getSQLQueryFromFile(String path) {
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader(path));
            String SQL = reader.lines().collect(Collectors.joining("\n"));
            reader.close();
            return SQL;
        } catch (FileNotFoundException e) {
            System.out.println("File not found");
            e.printStackTrace();
        } catch (IOException e) {
            System.out.println("Not able to close file");
            e.printStackTrace();
        }
        return null;

    }

}
