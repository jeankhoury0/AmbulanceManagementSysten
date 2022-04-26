package com.gtjm.systemambulance;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Hello world!
 *
 */
public class App 
{
    static Statement stmt = null;
    public static void main( String[] args )
    {
        new MainWindow();
        
         
        
    }


    public static String queryQuestion1(){
        String[] fields = { "base_name", "ambulancier_disponible" };
        QuestionQuery q = new QuestionQuery("app/src/main/resources/questions/q1.sql", fields);
        try {
            return q.runQuery();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String queryQuestion2() {
        String[] fields = { "ambulancier_id", "fname", "lname", "duration_mean_in_minutes" };
        QuestionQuery q = new QuestionQuery("app/src/main/resources/questions/q2.sql", fields);
        try {
            return q.runQuery();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String queryQuestion3() {
        String[] fields = { "fname", "lname", "time_in_hours" };
        QuestionQuery q = new QuestionQuery("app/src/main/resources/questions/q3.sql", fields);
        try {
            return q.runQuery();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
