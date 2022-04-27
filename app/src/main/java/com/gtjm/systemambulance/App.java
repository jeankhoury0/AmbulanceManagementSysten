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
        String sql = "select * from ambulancesystem.question1;";
        QuestionQuery q = new QuestionQuery(sql, fields);
        return q.runQuery();
    }

    public static String queryQuestion2() {
        String[] fields = { "ambulancier_id", "fname", "lname", "duration_mean_in_minutes" };
        String sql = "select * from ambulancesystem.question2;";
        QuestionQuery q = new QuestionQuery(sql, fields);
        return q.runQuery();
    }

    public static String queryQuestion3() {
        String[] fields = { "fname", "lname", "time_in_hours" };
        String sql = "select * from ambulancesystem.question3;";
        QuestionQuery q = new QuestionQuery(sql, fields);
        return q.runQuery();
    }

    public static String queryQuestion4() {
        String[] fields = { "id", "fullname", "heures_travail_mensuel", "salaire" };
        String sql = "select * from ambulancesystem.question4;";
        QuestionQuery q = new QuestionQuery(sql, fields);
        return q.runQuery();
    }
}
