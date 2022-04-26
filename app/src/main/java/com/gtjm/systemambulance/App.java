package com.gtjm.systemambulance;

/**
 * Main class is the main access point to the MainWindow query 
 * @author gtjm
 * 

 */
public class App {
    public static void main(String[] args) {
        new MainWindow();

    }

    public static String queryQuestion1() {
        String[] fields = { "base_name", "ambulancier_disponible" };
        String path = "app/src/main/resources/questions/q1.sql";
        QuestionQuery q = new QuestionQuery(path, fields);
        return q.runQuery();
    }

    public static String queryQuestion2() {
        String[] fields = { "ambulancier_id", "fname", "lname", "duration_mean_in_minutes" };
        String path = "app/src/main/resources/questions/q2.sql";
        QuestionQuery q = new QuestionQuery(path, fields);
        return q.runQuery();
    }

    public static String queryQuestion3() {
        String[] fields = { "fname", "lname", "time_in_hours" };
        String path = "app/src/main/resources/questions/q3.sql";
        QuestionQuery q = new QuestionQuery(path, fields);
        return q.runQuery();
    }
}
