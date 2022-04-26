package com.gtjm.systemambulance;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

/**
 * Contains the helper to access config.properties
 * @author gtjm
 */
public class Config {
    
    public static String getProperty(String property) {
        try {
            InputStream input = new FileInputStream("app/config.properties");
            Properties prop = new Properties();
            prop.load(input);
            return prop.getProperty(property);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
