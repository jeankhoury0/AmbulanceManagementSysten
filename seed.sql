-- sql script for project
ROLLBACK;
begin transaction;

DROP SCHEMA IF EXISTS ambulancesystem CASCADE;

CREATE SCHEMA ambulancesystem;

set search_path to ambulancesystem;


CREATE TABLE Base_type(
    Base_type_name VARCHAR(255) NOT NULL PRIMARY KEY
    );

CREATE TABLE Base(
    base_id SERIAL PRIMARY KEY,
    base_name VARCHAR(255),
    city_sector VARCHAR(255),
    base_type_name VARCHAR(255),
    base_address VARCHAR(255),
    phone_number VARCHAR(20),
    CONSTRAINT fk_base_type FOREIGN KEY(base_type_name) REFERENCES Base_type(Base_type_name)
);


CREATE TABLE Ambulancier(
    ambulancier_id SERIAL PRIMARY KEY,
    base_id INT not NULL,
    fname VARCHAR(20) NOT NULL,
    lname VARCHAR(20) NOT NULL,
    CONSTRAINT fk_base FOREIGN KEY(base_id) REFERENCES Base(base_id)
);

CREATE TABLE Ambulance_cluster(
    cluster_id SERIAL PRIMARY KEY,
    base_id INT NOT NULL,
    CONSTRAINT fk_base FOREIGN KEY(base_id) REFERENCES Base(base_id)
);

CREATE TABLE Ambulance(
    registration_number VARCHAR(255) PRIMARY KEY NOT NULL,
    cluster_id INT NOT NULL,
    service_start_date INT NOT NULL,
    is_ready_intervention BOOLEAN NOT NULL,
    CONSTRAINT fk_ambulance_cluster FOREIGN KEY(cluster_id) REFERENCES Ambulance_cluster(cluster_id)
);



CREATE TABLE Intervention(
    intervention_id SERIAL PRIMARY KEY,
    ambulancier_id INT NOT NULL,
    ambulance_id VARCHAR(255) NOT NULL,
    intervention_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    duration INT,
    distance decimal,
    CONSTRAINT fk_ambulancier FOREIGN KEY(ambulancier_id) REFERENCES Ambulancier(ambulancier_id),
    CONSTRAINT fk_ambulance FOREIGN KEY(ambulance_id) REFERENCES Ambulance(registration_number)
);

-- Questions as view

CREATE OR REPLACE VIEW Question1 AS (
    -- max is 10h per week
    -- we are using mock date range to not return null value

    WITH OP_IN_THE_WEEK AS
        (SELECT AMBULANCIER_ID,
                DURATION
            FROM INTERVENTION
            WHERE INTERVENTION_DATE BETWEEN '2022-04-18' AND '2022-04-25' ),
        HEURE_CUMULEE AS
        (SELECT AMBULANCIER_ID,
                (SUM(DURATION) / 60) AS TIME_IN_HOURS_THIS_WEEK
            FROM OP_IN_THE_WEEK
            GROUP BY AMBULANCIER_ID),
        BY_BASE AS
        (SELECT HEURE_CUMULEE.AMBULANCIER_ID,
                BASE_ID
            FROM HEURE_CUMULEE
            JOIN AMBULANCIER ON HEURE_CUMULEE.AMBULANCIER_ID = AMBULANCIER.AMBULANCIER_ID),
        GETCOUNT AS
        (SELECT BASE_ID,
                COUNT(AMBULANCIER_ID) AS AMBULANCIER_DISPONIBLE
            FROM BY_BASE
            GROUP BY BASE_ID)
    SELECT BASE_NAME,
        AMBULANCIER_DISPONIBLE
    FROM GETCOUNT
    JOIN BASE ON GETCOUNT.BASE_ID = BASE.BASE_ID
);

CREATE OR REPLACE VIEW Question2 AS (
    -- Question 2

    WITH AVGDURATION AS
        (SELECT AMBULANCIER_ID,
                ROUND(AVG(DURATION),
                    2) AS DURATION_MEAN_IN_MINUTES
            FROM INTERVENTION
            GROUP BY AMBULANCIER_ID),
        AMBINFO AS
        (SELECT AMBULANCIER_ID,
                FNAME,
                LNAME
            FROM AMBULANCIER)

    SELECT *
    FROM AMBINFO
    JOIN AVGDURATION USING (AMBULANCIER_ID)
);

CREATE OR REPLACE VIEW Question3 AS (
    -- Question 3

    -- utilisation d'une date "mock" car notre date n'est pas active
    -- le temps de travail journalier max est de 3h
    WITH IN_THE_DAY AS
        (SELECT AMBULANCIER_ID,
                DURATION
            FROM INTERVENTION
            WHERE INTERVENTION_DATE = '2022-04-18' ),
        HEURE_CUMULEE AS
        (SELECT AMBULANCIER_ID,
                (SUM(DURATION) / 60) AS TIME_IN_HOURS
            FROM IN_THE_DAY
            GROUP BY AMBULANCIER_ID)
    SELECT FNAME,
        LNAME,
        TIME_IN_HOURS
    FROM HEURE_CUMULEE
    JOIN AMBULANCIER ON HEURE_CUMULEE.AMBULANCIER_ID = AMBULANCIER.AMBULANCIER_ID
    WHERE TIME_IN_HOURS < 3
    ORDER BY TIME_IN_HOURS
);

CREATE OR REPLACE VIEW Question4 AS (
    -- Question 4

    WITH
    AMBULANCIERS AS
    (
        SELECT AMBULANCIER_ID , concat(FNAME, ' ' , LNAME) AS FULLNAME
        FROM AMBULANCIER
    ),
    HEURES_DU_MOIS AS
    (
        SELECT
            AMBULANCIER_ID,
            SUM(DURATION/60) AS HEURES_TRAVAIL_MENSUEL
        FROM INTERVENTION
        WHERE INTERVENTION_DATE >= date_trunc('month', CURRENT_DATE)
        GROUP BY AMBULANCIER_ID
    )
    SELECT
        AMBULANCIER_ID AS ID,
		FULLNAME,
        HEURES_TRAVAIL_MENSUEL,
        concat(32.52 * HEURES_TRAVAIL_MENSUEL,  ' $' ) AS SALAIRE
    FROM AMBULANCIERS
    NATURAL JOIN HEURES_DU_MOIS
);

-- Seeds
-- Generated using mockaroo.com

INSERT INTO Base_type (base_type_name) values ('hopital');
INSERT INTO Base_type (base_type_name) values ('clinique medicale');

insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (1, 'Conopco Inc. d/b/a Unilever', 'Bibis', 'clinique medicale', '42 Alpine Center', '756-143-3863');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (2, 'St Marys Medical Park Pharmacy', 'Aţ Ţīrah', 'clinique medicale', '067 La Follette Avenue', '867-935-5916');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (3, 'Betco Corporation, Ltd.', 'Haolin', 'clinique medicale', '49 Clarendon Center', '705-338-3063');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (4, 'Conopco Inc. d/b/a Unilever', 'Santo Domingo', 'hopital', '595 Upham Junction', '321-286-6032');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (5, 'Walgreen Company', 'Abovyan', 'clinique medicale', '7 Cardinal Street', '872-156-1095');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (6, 'McKesson Packaging Services a business unit of McKesson Corporation', 'Banjing', 'hopital', '74 Warner Lane', '117-320-1962');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (7, 'SHISEIDO CO., LTD.', 'Khlong Sam Wa', 'clinique medicale', '0594 Meadow Valley Way', '406-286-1097');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (8, 'Kimberly-Clark Corporation', 'Trincomalee', 'hopital', '9 Truax Terrace', '435-629-2270');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (9, 'WAL-MART STORES INC', 'Mantes-la-Jolie', 'clinique medicale', '351 Kensington Street', '976-231-2777');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (10, 'Army & Air Force Exchange Service', 'Xiantang', 'hopital', '35 Ludington Point', '928-989-3136');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (11, 'Baxter Healthcare Corporation', 'Benger', 'clinique medicale', '928 Crowley Drive', '808-746-3959');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (12, 'Hannaford Brothers Company', 'Makar’yev', 'hopital', '6 Algoma Court', '695-206-5174');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (13, 'Western Family Foods Inc', 'Ramon Magsaysay', 'clinique medicale', '871 Pearson Street', '555-107-7936');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (14, 'Cardinal Health', 'Cholpon-Ata', 'hopital', '1772 Onsgard Center', '961-118-8602');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (15, 'AMERICAN SALES COMPANY', 'Yuhang', 'clinique medicale', '5 Hoard Crossing', '406-373-2949');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (16, 'ALK-Abello, Inc.', 'Maogou', 'clinique medicale', '988 Butternut Alley', '871-740-4387');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (17, 'St Marys Medical Park Pharmacy', 'Drumcondra', 'clinique medicale', '2334 Lunder Circle', '799-256-0459');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (18, 'Natural Health Supply', 'Dembeni', 'hopital', '677 Acker Place', '686-283-3163');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (19, 'Nelco Laboratories, Inc.', 'Bauta', 'clinique medicale', '6120 Northfield Plaza', '662-997-4198');
insert into Base (base_id, base_name, city_sector, base_type_name, base_address, phone_number) values (20, 'Kroger Company', 'Czarna Białostocka', 'clinique medicale', '53 Shopko Court', '797-624-8946');

insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (1, 4, 'Stévina', 'McCloughen');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (2, 4, 'Nadège', 'Lockless');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (3, 11, 'Thérèsa', 'Darnbrough');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (4, 16, 'Marie-noël', 'Neames');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (5, 20, 'Bérangère', 'Whilder');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (6, 4, 'Loïs', 'Martlew');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (7, 20, 'Amélie', 'Kneeshaw');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (8, 16, 'Josée', 'Corless');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (9, 14, 'Laïla', 'Semrad');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (10, 11, 'Eliès', 'Dall');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (11, 11, 'Bénédicte', 'Lazenby');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (12, 13, 'Lài', 'Clacson');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (13, 4, 'Noëlla', 'MacGebenay');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (14, 8, 'Mélodie', 'Caulcott');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (15, 4, 'Tán', 'Peggram');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (16, 20, 'Méng', 'Sturrock');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (17, 4, 'Clémentine', 'Tummasutti');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (18, 13, 'Andréanne', 'Naish');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (19, 13, 'Lén', 'Stranieri');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (20, 7, 'Kallisté', 'Cuddon');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (21, 11, 'Océanne', 'Porch');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (22, 18, 'Réservés', 'Golt');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (23, 9, 'Dà', 'Brocklebank');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (24, 19, 'Loïs', 'Kilgallen');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (25, 10, 'Frédérique', 'Traut');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (26, 19, 'Börje', 'Dosdale');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (27, 15, 'Mégane', 'Milam');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (28, 19, 'Lucrèce', 'Coase');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (29, 11, 'Agnès', 'Demschke');
insert into Ambulancier (ambulancier_id, base_id, fname, lname) values (30, 8, 'Régine', 'BURWIN');

insert into Ambulance_cluster (cluster_id, base_id) values (1, 14);
insert into Ambulance_cluster (cluster_id, base_id) values (2, 6);
insert into Ambulance_cluster (cluster_id, base_id) values (3, 1);
insert into Ambulance_cluster (cluster_id, base_id) values (4, 17);
insert into Ambulance_cluster (cluster_id, base_id) values (5, 6);
insert into Ambulance_cluster (cluster_id, base_id) values (6, 18);
insert into Ambulance_cluster (cluster_id, base_id) values (7, 10);
insert into Ambulance_cluster (cluster_id, base_id) values (8, 15);
insert into Ambulance_cluster (cluster_id, base_id) values (9, 15);
insert into Ambulance_cluster (cluster_id, base_id) values (10, 8);
insert into Ambulance_cluster (cluster_id, base_id) values (11, 20);


insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WUAPV54B03N154484', 11, 2010, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WP0CB2A89FS501327', 5, 2000, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WBAKG1C59CJ345184', 9, 1995, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('4JGBF2FE9BA651870', 1, 1985, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('TRUSX28N121757217', 10, 1999, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JTHFE2C21F2693581', 6, 2012, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUEF78EX8A599263', 10, 2006, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1FTSW3B53AE364125', 5, 1996, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1G4GE5G37FF088771', 2, 1994, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('3GYFNAE30FS767413', 5, 1993, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1N6AA0CC3FN050116', 1, 1994, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUDH74F77N848503', 7, 1999, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JN1AZ4EH4FM818948', 10, 2010, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JN1CV6EK0CM001998', 9, 2009, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('4A31K2DF7CE651915', 11, 1996, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WP1AE2A20BL744230', 9, 2006, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('3VWJX7AJ5AM161701', 1, 2009, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JM1NC2JF7B0117749', 10, 1997, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WBALL5C56EP427364', 10, 2002, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1N4AL3APXDC704161', 5, 2000, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1G4GD5GG2AF580767', 8, 2002, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1G6DG5EG8A0535663', 2, 2005, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUBFAFL5CA911760', 1, 1964, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUBF78E78A645988', 10, 2007, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WA1CGBFE6CD074246', 1, 2005, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUMK98K49A588608', 1, 2008, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1D7RW3BK8AS619365', 8, 2010, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WUARU78E47N900369', 9, 2003, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1B3CB7HB9AD390176', 11, 2006, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('2LMDJ6JC5AB819032', 11, 2009, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WAUVT58EX3A261352', 3, 2010, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('SCFEBBBK5BG749124', 6, 2003, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1FMJK1G54BE683664', 11, 1990, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('3C3CFFDR1ET806239', 1, 1989, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('2T1BURHE8FC677331', 11, 1989, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('WDDGF4HB3EG455410', 11, 2000, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JTHDU5EF8C5655108', 10, 1987, false);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('JTHBK1GG9D1193758', 3, 1991, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('4T1BF1FK8EU862366', 3, 2004, true);
insert into Ambulance (registration_number, cluster_id, service_start_date, is_ready_intervention) values ('1D7RB1CT6BS522125', 4, 2004, false);

INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (1,12,'3VWJX7AJ5AM161701','2022-04-13','1:55:53','1:57:53',2,3.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (2,3,'1D7RW3BK8AS619365','2022-04-15','11:59:10','12:33:10',34,6.07);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (3,6,'1B3CB7HB9AD390176','2022-04-21','18:57:06','19:36:06',39,4.7);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (4,2,'WBAKG1C59CJ345184','2022-04-20','5:02:16','6:12:16',70,62.7);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (5,18,'4T1BF1FK8EU862366','2022-04-19','23:31:32','23:42:32',11,78.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (6,15,'WAUVT58EX3A261352','2022-04-14','1:25:12','2:43:12',78,93.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (7,13,'1G4GE5G37FF088771','2022-04-20','14:39:01','15:47:01',68,76.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (8,13,'JTHBK1GG9D1193758','2022-04-21','1:12:04','2:15:04',63,71.59);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (9,3,'WUAPV54B03N154484','2022-04-16','22:07:33','22:25:33',18,24.9);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (10,13,'WAUDH74F77N848503','2022-04-12','11:46:30','11:47:30',1,22.54);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (11,9,'WAUBF78E78A645988','2022-04-18','15:31:54','16:50:54',79,42.3);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (12,15,'JM1NC2JF7B0117749','2022-04-19','16:14:30','16:59:30',45,35.09);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (14,10,'4A31K2DF7CE651915','2022-04-12','16:02:48','17:21:48',79,28.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (15,4,'3GYFNAE30FS767413','2022-04-19','15:16:18','16:17:18',61,2.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (16,8,'WA1CGBFE6CD074246','2022-04-16','0:56:45','2:18:45',82,68.55);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (17,10,'WP1AE2A20BL744230','2022-04-14','3:11:31','4:50:31',99,44.23);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (18,9,'3VWJX7AJ5AM161701','2022-04-11','11:39:55','12:24:55',45,39.88);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (19,9,'WAUBF78E78A645988','2022-04-17','5:10:46','5:47:46',37,44.09);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (20,12,'JTHDU5EF8C5655108','2022-04-16','18:44:27','20:15:27',91,49.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (21,5,'3VWJX7AJ5AM161701','2022-04-20','15:45:45','15:56:45',11,93.45);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (22,2,'TRUSX28N121757217','2022-04-18','22:31:04','22:57:04',26,41.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (23,9,'TRUSX28N121757217','2022-04-19','9:38:37','10:55:37',77,9.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (24,14,'1B3CB7HB9AD390176','2022-04-17','3:02:53','3:12:53',10,12.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (25,13,'WBALL5C56EP427364','2022-04-14','4:56:23','4:57:23',1,91.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (26,6,'JTHDU5EF8C5655108','2022-04-22','11:08:27','11:44:27',36,8.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (27,7,'WBALL5C56EP427364','2022-04-17','0:48:45','1:58:45',70,53.1);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (28,7,'WAUBFAFL5CA911760','2022-04-22','18:13:18','18:45:18',32,65.43);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (29,13,'WUAPV54B03N154484','2022-04-22','18:26:33','19:44:33',78,48.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (30,1,'JTHFE2C21F2693581','2022-04-22','2:19:52','3:38:52',79,64.76);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (31,1,'JN1CV6EK0CM001998','2022-04-17','22:20:05','22:50:05',30,5.23);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (32,14,'WBAKG1C59CJ345184','2022-04-14','8:43:58','10:06:58',83,88.38);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (33,5,'TRUSX28N121757217','2022-04-16','5:11:49','5:45:49',34,24.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (34,1,'WUARU78E47N900369','2022-04-20','18:30:31','19:35:31',65,50.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (35,12,'WAUMK98K49A588608','2022-04-20','11:53:53','12:25:53',32,17.42);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (36,11,'WA1CGBFE6CD074246','2022-04-18','17:33:32','19:00:32',87,46.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (37,19,'WAUMK98K49A588608','2022-04-12','1:25:28','1:35:28',10,68.51);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (38,19,'WAUMK98K49A588608','2022-04-13','7:39:44','8:45:44',66,32.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (39,17,'WAUBF78E78A645988','2022-04-17','14:14:17','15:35:17',81,25.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (41,19,'JN1CV6EK0CM001998','2022-04-14','8:11:06','8:59:06',48,38.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (42,7,'WAUVT58EX3A261352','2022-04-11','2:20:48','2:35:48',15,3.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (43,11,'1D7RW3BK8AS619365','2022-04-12','17:06:19','18:41:19',95,47.39);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (44,12,'2LMDJ6JC5AB819032','2022-04-16','13:17:20','14:30:20',73,49.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (45,7,'WBALL5C56EP427364','2022-04-22','21:59:55','23:02:55',63,75.07);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (46,18,'1D7RB1CT6BS522125','2022-04-13','21:18:43','22:09:43',51,86.05);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (47,7,'WBALL5C56EP427364','2022-04-18','9:48:48','10:02:48',14,1.43);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (48,15,'3VWJX7AJ5AM161701','2022-04-12','2:23:19','3:48:19',85,40.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (49,12,'WDDGF4HB3EG455410','2022-04-18','17:13:47','18:26:47',73,81.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (50,11,'WDDGF4HB3EG455410','2022-04-17','14:35:07','15:02:07',27,36.94);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (51,13,'WAUBF78E78A645988','2022-04-15','2:10:15','3:04:15',54,66.19);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (52,18,'1G4GE5G37FF088771','2022-04-21','19:25:58','19:48:58',23,47.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (53,19,'WAUVT58EX3A261352','2022-04-17','9:01:51','9:50:51',49,49.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (54,18,'JN1CV6EK0CM001998','2022-04-16','17:10:10','17:18:10',8,37.82);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (55,16,'WAUMK98K49A588608','2022-04-11','3:14:18','3:54:18',40,85.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (56,11,'2LMDJ6JC5AB819032','2022-04-13','17:59:25','19:12:25',73,40.54);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (57,4,'WAUBF78E78A645988','2022-04-16','17:44:10','18:41:10',57,71.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (58,11,'TRUSX28N121757217','2022-04-18','1:29:36','2:13:36',44,66.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (59,18,'1N4AL3APXDC704161','2022-04-13','16:36:36','16:40:36',4,6.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (60,11,'1B3CB7HB9AD390176','2022-04-16','10:25:57','12:04:57',99,34.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (61,8,'1B3CB7HB9AD390176','2022-04-18','2:50:33','3:08:33',18,47.65);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (62,4,'JN1CV6EK0CM001998','2022-04-19','7:34:11','8:31:11',57,28.59);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (63,17,'SCFEBBBK5BG749124','2022-04-20','2:59:14','3:35:14',36,96.83);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (64,7,'WAUBF78E78A645988','2022-04-13','8:21:48','8:55:48',34,94.42);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (65,11,'3C3CFFDR1ET806239','2022-04-22','7:26:49','7:48:49',22,27.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (66,1,'WDDGF4HB3EG455410','2022-04-13','23:14:40','23:23:40',9,21.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (67,15,'3VWJX7AJ5AM161701','2022-04-16','9:55:05','10:35:05',40,56.85);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (68,13,'3GYFNAE30FS767413','2022-04-14','0:44:45','1:02:45',18,7.45);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (69,10,'WAUVT58EX3A261352','2022-04-11','8:32:17','10:03:17',91,73.04);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (70,6,'WAUBF78E78A645988','2022-04-16','7:49:09','8:06:09',17,75.62);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (71,11,'WAUEF78EX8A599263','2022-04-16','3:30:07','4:14:07',44,58.94);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (72,10,'WUARU78E47N900369','2022-04-11','18:55:01','19:08:01',13,99.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (73,20,'JM1NC2JF7B0117749','2022-04-16','8:13:39','9:35:39',82,30.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (74,1,'3C3CFFDR1ET806239','2022-04-17','18:48:51','19:00:51',12,1.54);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (75,5,'WUARU78E47N900369','2022-04-14','9:40:35','10:10:35',30,71.52);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (76,3,'3C3CFFDR1ET806239','2022-04-19','5:16:41','6:02:41',46,9.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (77,5,'JTHFE2C21F2693581','2022-04-13','22:50:41','23:33:41',43,51.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (78,17,'2T1BURHE8FC677331','2022-04-16','6:36:15','6:58:15',22,82.57);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (79,11,'WDDGF4HB3EG455410','2022-04-20','4:59:31','5:20:31',21,52.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (80,19,'1D7RW3BK8AS619365','2022-04-18','4:07:58','4:46:58',39,59.78);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (81,1,'1N6AA0CC3FN050116','2022-04-19','16:32:54','17:27:54',55,45.38);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (82,15,'3VWJX7AJ5AM161701','2022-04-13','22:15:32','22:22:32',7,73.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (83,7,'1G4GD5GG2AF580767','2022-04-18','16:45:39','17:15:39',30,30.58);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (84,17,'1D7RB1CT6BS522125','2022-04-18','21:07:30','22:29:30',82,17.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (85,17,'1G4GE5G37FF088771','2022-04-12','15:38:08','17:17:08',99,54.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (86,8,'1FMJK1G54BE683664','2022-04-19','4:27:00','5:55:00',88,7.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (87,20,'WAUBF78E78A645988','2022-04-22','18:32:20','19:35:20',63,69.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (88,11,'2T1BURHE8FC677331','2022-04-16','4:12:55','5:23:55',71,49.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (89,5,'WUAPV54B03N154484','2022-04-21','18:09:58','18:31:58',22,61.52);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (90,4,'WBAKG1C59CJ345184','2022-04-18','0:08:13','0:45:13',37,21.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (91,12,'WAUVT58EX3A261352','2022-04-12','13:00:05','13:19:05',19,22.26);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (92,15,'3VWJX7AJ5AM161701','2022-04-18','15:24:55','15:36:55',12,23.85);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (93,5,'JN1CV6EK0CM001998','2022-04-14','14:55:52','15:41:52',46,86.97);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (94,3,'1FMJK1G54BE683664','2022-04-12','16:10:34','17:01:34',51,98.06);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (96,18,'1D7RB1CT6BS522125','2022-04-22','14:28:47','14:47:47',19,5.33);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (97,14,'JN1CV6EK0CM001998','2022-04-19','10:22:18','11:21:18',59,14.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (98,8,'JM1NC2JF7B0117749','2022-04-19','17:45:17','18:02:17',17,84.39);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (99,3,'WAUBF78E78A645988','2022-04-16','15:23:25','16:25:25',62,58.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (100,1,'4A31K2DF7CE651915','2022-04-19','20:37:14','21:01:14',24,43.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (101,1,'WA1CGBFE6CD074246','2022-04-18','15:27:29','15:52:29',25,85.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (102,13,'1N4AL3APXDC704161','2022-04-22','3:10:38','4:10:38',60,18.64);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (103,16,'TRUSX28N121757217','2022-04-21','9:38:18','9:51:18',13,32.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (104,18,'2T1BURHE8FC677331','2022-04-11','2:11:00','2:37:00',26,86.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (105,5,'3VWJX7AJ5AM161701','2022-04-20','9:06:28','9:37:28',31,16.06);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (106,1,'4JGBF2FE9BA651870','2022-04-14','12:01:31','13:05:31',64,72.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (107,7,'1D7RW3BK8AS619365','2022-04-21','13:31:33','13:41:33',10,34.16);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (108,10,'WP0CB2A89FS501327','2022-04-15','19:03:07','20:40:07',97,83.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (109,5,'1D7RW3BK8AS619365','2022-04-11','2:39:52','3:35:52',56,65.02);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (110,10,'2T1BURHE8FC677331','2022-04-12','11:11:54','11:33:54',22,99.8);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (111,10,'WP1AE2A20BL744230','2022-04-16','3:16:04','3:43:04',27,81.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (112,4,'3GYFNAE30FS767413','2022-04-12','0:56:15','1:40:15',44,53.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (113,14,'WDDGF4HB3EG455410','2022-04-19','22:08:55','23:38:55',90,44.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (114,2,'2LMDJ6JC5AB819032','2022-04-15','1:43:25','2:58:25',75,8.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (115,12,'WA1CGBFE6CD074246','2022-04-15','19:45:33','20:47:33',62,29.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (116,9,'1N4AL3APXDC704161','2022-04-18','13:01:58','13:36:58',35,67.97);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (117,20,'1B3CB7HB9AD390176','2022-04-11','5:41:27','6:23:27',42,94.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (118,11,'2T1BURHE8FC677331','2022-04-16','12:41:20','14:12:20',91,24.78);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (119,20,'4JGBF2FE9BA651870','2022-04-15','21:58:53','23:35:53',97,77.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (120,12,'4A31K2DF7CE651915','2022-04-15','18:02:05','19:34:05',92,26.78);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (121,9,'TRUSX28N121757217','2022-04-17','4:53:40','6:17:40',84,72.64);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (122,14,'WP1AE2A20BL744230','2022-04-14','8:00:42','9:11:42',71,18.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (123,12,'WUAPV54B03N154484','2022-04-17','2:32:22','2:52:22',20,67.64);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (124,10,'4A31K2DF7CE651915','2022-04-21','16:28:16','17:44:16',76,51.35);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (125,14,'1N6AA0CC3FN050116','2022-04-19','18:40:27','18:46:27',6,48.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (126,12,'3GYFNAE30FS767413','2022-04-20','4:04:35','4:34:35',30,26.11);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (127,9,'1FMJK1G54BE683664','2022-04-12','22:30:54','22:56:54',26,71.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (128,19,'WAUMK98K49A588608','2022-04-13','9:13:34','10:36:34',83,52.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (129,7,'4JGBF2FE9BA651870','2022-04-20','1:05:59','1:26:59',21,39.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (130,7,'WDDGF4HB3EG455410','2022-04-15','0:19:32','0:30:32',11,44.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (131,4,'1D7RW3BK8AS619365','2022-04-22','4:06:55','4:58:55',52,96.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (132,8,'3VWJX7AJ5AM161701','2022-04-14','16:25:20','16:26:20',1,83.55);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (133,12,'4A31K2DF7CE651915','2022-04-21','13:50:02','14:46:02',56,87.9);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (134,13,'1B3CB7HB9AD390176','2022-04-14','17:25:51','18:00:51',35,85.15);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (135,15,'2T1BURHE8FC677331','2022-04-14','4:15:42','4:26:42',11,87.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (136,10,'WBAKG1C59CJ345184','2022-04-18','18:04:27','18:33:27',29,21.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (137,8,'TRUSX28N121757217','2022-04-12','3:55:28','4:31:28',36,11.77);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (138,1,'WAUBF78E78A645988','2022-04-13','1:20:14','2:03:14',43,83.77);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (139,18,'JN1CV6EK0CM001998','2022-04-17','9:49:54','10:13:54',24,70.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (140,3,'WAUMK98K49A588608','2022-04-16','2:25:52','3:58:52',93,95.11);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (141,7,'1G4GD5GG2AF580767','2022-04-21','16:47:26','17:02:26',15,89.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (142,2,'WAUDH74F77N848503','2022-04-14','19:19:09','20:53:09',94,16.88);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (143,11,'1FTSW3B53AE364125','2022-04-13','10:53:41','11:32:41',39,86.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (144,17,'JTHFE2C21F2693581','2022-04-20','23:07:53','23:28:53',21,13.62);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (145,6,'WBALL5C56EP427364','2022-04-15','10:23:41','10:51:41',28,94.38);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (146,18,'WUAPV54B03N154484','2022-04-16','6:54:39','8:12:39',78,9.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (147,8,'1FMJK1G54BE683664','2022-04-13','14:16:52','15:15:52',59,81.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (148,1,'WUARU78E47N900369','2022-04-19','6:46:11','7:33:11',47,55.06);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (149,17,'1G4GD5GG2AF580767','2022-04-17','3:33:12','4:44:12',71,95.95);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (150,5,'TRUSX28N121757217','2022-04-11','12:58:49','13:20:49',22,75.26);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (151,4,'4A31K2DF7CE651915','2022-04-21','19:19:53','20:41:53',82,86.65);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (152,7,'2LMDJ6JC5AB819032','2022-04-18','7:11:11','7:28:11',17,9.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (153,9,'JN1CV6EK0CM001998','2022-04-21','12:06:07','13:07:07',61,33.76);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (154,14,'WAUMK98K49A588608','2022-04-18','18:40:50','18:47:50',7,12.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (155,9,'WP1AE2A20BL744230','2022-04-22','0:25:39','0:26:39',1,63.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (156,9,'WBALL5C56EP427364','2022-04-19','16:07:22','16:38:22',31,90.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (157,19,'WP0CB2A89FS501327','2022-04-21','21:39:17','21:43:17',4,40.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (158,17,'WP0CB2A89FS501327','2022-04-18','10:55:52','11:33:52',38,56.42);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (159,20,'WAUBF78E78A645988','2022-04-14','3:36:39','4:32:39',56,19.28);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (160,15,'WP1AE2A20BL744230','2022-04-15','18:54:57','19:56:57',62,99.82);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (161,15,'WUARU78E47N900369','2022-04-14','3:19:39','3:47:39',28,17.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (162,9,'1D7RB1CT6BS522125','2022-04-11','0:25:07','1:41:07',76,99.47);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (163,7,'3GYFNAE30FS767413','2022-04-17','9:16:33','10:19:33',63,84.88);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (164,16,'WAUEF78EX8A599263','2022-04-17','19:40:03','20:48:03',68,55.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (165,8,'4A31K2DF7CE651915','2022-04-20','5:58:31','6:37:31',39,86.19);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (166,12,'WAUDH74F77N848503','2022-04-19','19:37:28','20:08:28',31,96.1);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (167,8,'3GYFNAE30FS767413','2022-04-19','19:35:34','20:05:34',30,52.3);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (168,2,'WP0CB2A89FS501327','2022-04-17','11:57:35','13:36:35',99,22.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (169,17,'1FMJK1G54BE683664','2022-04-20','13:48:22','14:23:22',35,54.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (170,6,'2LMDJ6JC5AB819032','2022-04-17','4:18:13','5:52:13',94,71.66);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (171,2,'3C3CFFDR1ET806239','2022-04-11','5:38:34','5:52:34',14,19.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (172,11,'1G6DG5EG8A0535663','2022-04-22','21:02:03','21:23:03',21,94.1);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (173,12,'1G4GE5G37FF088771','2022-04-19','15:45:22','17:01:22',76,26.63);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (174,19,'JN1AZ4EH4FM818948','2022-04-21','13:44:03','13:56:03',12,17.15);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (175,6,'JM1NC2JF7B0117749','2022-04-18','1:08:05','2:15:05',67,55.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (176,11,'3VWJX7AJ5AM161701','2022-04-11','15:04:54','15:32:54',28,3.27);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (177,5,'WDDGF4HB3EG455410','2022-04-19','21:02:09','22:23:09',81,22.29);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (178,20,'TRUSX28N121757217','2022-04-18','4:49:58','6:04:58',75,37.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (179,16,'2T1BURHE8FC677331','2022-04-17','6:37:29','6:54:29',17,27.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (180,9,'1G4GE5G37FF088771','2022-04-20','11:31:02','12:34:02',63,54.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (181,16,'JTHBK1GG9D1193758','2022-04-21','14:37:28','14:59:28',22,76.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (182,4,'WAUDH74F77N848503','2022-04-20','18:17:21','19:13:21',56,57.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (184,1,'WP1AE2A20BL744230','2022-04-14','0:52:08','1:06:08',14,74.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (185,4,'WAUMK98K49A588608','2022-04-17','4:24:11','5:33:11',69,38.02);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (186,9,'JN1AZ4EH4FM818948','2022-04-22','21:18:12','21:38:12',20,34.65);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (187,1,'1N6AA0CC3FN050116','2022-04-14','1:36:19','2:04:19',28,43.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (188,10,'WP0CB2A89FS501327','2022-04-12','18:16:03','19:01:03',45,47.18);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (189,1,'TRUSX28N121757217','2022-04-19','2:42:14','4:16:14',94,97.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (191,11,'WBALL5C56EP427364','2022-04-21','9:06:44','9:30:44',24,80.46);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (192,3,'WAUEF78EX8A599263','2022-04-11','7:25:22','7:40:22',15,7.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (193,19,'WP0CB2A89FS501327','2022-04-11','18:38:38','19:04:38',26,73.73);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (194,17,'3GYFNAE30FS767413','2022-04-16','11:25:54','11:51:54',26,37.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (195,4,'WAUEF78EX8A599263','2022-04-15','5:53:30','6:24:30',31,52.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (196,15,'WUARU78E47N900369','2022-04-14','8:42:24','8:50:24',8,30.83);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (198,20,'1G4GD5GG2AF580767','2022-04-20','15:46:05','17:10:05',84,62.42);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (199,3,'3C3CFFDR1ET806239','2022-04-14','11:29:52','13:05:52',96,88.47);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (200,3,'JM1NC2JF7B0117749','2022-04-20','9:22:46','10:16:46',54,88.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (201,9,'4T1BF1FK8EU862366','2022-04-12','9:22:51','10:06:51',44,53.53);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (202,2,'WBAKG1C59CJ345184','2022-04-20','17:10:30','17:35:30',25,47.05);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (203,13,'1N6AA0CC3FN050116','2022-04-16','0:52:39','2:12:39',80,88.62);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (204,15,'4JGBF2FE9BA651870','2022-04-22','16:08:07','16:21:07',13,29.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (205,5,'WA1CGBFE6CD074246','2022-04-22','7:46:13','8:22:13',36,90.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (206,7,'WP0CB2A89FS501327','2022-04-12','17:03:11','17:33:11',30,12.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (207,7,'TRUSX28N121757217','2022-04-11','4:56:09','6:22:09',86,93.92);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (208,12,'1FTSW3B53AE364125','2022-04-11','5:16:48','5:49:48',33,30.06);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (209,9,'1FMJK1G54BE683664','2022-04-21','20:00:45','20:45:45',45,83.02);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (210,4,'2LMDJ6JC5AB819032','2022-04-11','6:47:56','7:54:56',67,60.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (211,18,'JN1AZ4EH4FM818948','2022-04-22','13:43:28','14:15:28',32,68.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (212,6,'WAUBF78E78A645988','2022-04-14','20:40:01','21:43:01',63,26.15);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (213,5,'WAUVT58EX3A261352','2022-04-12','1:00:38','2:09:38',69,71.8);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (214,9,'WP1AE2A20BL744230','2022-04-21','11:23:34','12:13:34',50,8.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (215,9,'JN1CV6EK0CM001998','2022-04-22','21:53:55','23:11:55',78,76.64);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (216,15,'WP0CB2A89FS501327','2022-04-12','13:52:52','14:52:52',60,20.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (217,18,'2LMDJ6JC5AB819032','2022-04-12','10:09:58','10:29:58',20,49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (219,1,'1N4AL3APXDC704161','2022-04-12','18:56:43','19:58:43',62,76.18);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (220,15,'WA1CGBFE6CD074246','2022-04-12','0:05:44','0:49:44',44,31.94);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (221,6,'WUAPV54B03N154484','2022-04-22','4:21:08','5:11:08',50,69.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (222,20,'4A31K2DF7CE651915','2022-04-11','5:38:21','5:57:21',19,24.58);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (223,16,'1N4AL3APXDC704161','2022-04-19','12:34:44','13:51:44',77,35.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (224,5,'WAUMK98K49A588608','2022-04-14','7:46:17','9:12:17',86,65.07);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (225,16,'WAUVT58EX3A261352','2022-04-17','5:13:15','5:46:15',33,9.64);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (226,4,'WP0CB2A89FS501327','2022-04-22','8:50:02','9:23:02',33,93.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (227,15,'WAUBF78E78A645988','2022-04-11','6:56:34','7:16:34',20,33.08);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (228,14,'3C3CFFDR1ET806239','2022-04-16','10:53:11','12:32:11',99,99.63);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (229,6,'1FMJK1G54BE683664','2022-04-22','19:41:15','19:44:15',3,79.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (230,19,'WDDGF4HB3EG455410','2022-04-17','4:51:52','6:12:52',81,7.28);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (231,4,'1D7RB1CT6BS522125','2022-04-15','22:55:53','23:33:53',38,89.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (232,11,'SCFEBBBK5BG749124','2022-04-13','8:51:28','9:27:28',36,22.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (233,12,'WBAKG1C59CJ345184','2022-04-19','20:59:27','22:39:27',100,51.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (234,17,'TRUSX28N121757217','2022-04-16','10:18:11','10:27:11',9,7.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (235,6,'1G6DG5EG8A0535663','2022-04-19','13:56:37','15:05:37',69,25.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (236,6,'WAUVT58EX3A261352','2022-04-18','1:06:39','1:14:39',8,57.09);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (237,2,'TRUSX28N121757217','2022-04-19','18:13:23','19:27:23',74,67);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (238,18,'JN1CV6EK0CM001998','2022-04-15','17:17:56','18:20:56',63,2.77);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (239,10,'4A31K2DF7CE651915','2022-04-13','14:37:47','16:13:47',96,48.93);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (240,5,'1G4GE5G37FF088771','2022-04-13','14:08:29','15:25:29',77,39.24);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (241,7,'WUARU78E47N900369','2022-04-12','0:43:34','2:05:34',82,53.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (242,18,'JM1NC2JF7B0117749','2022-04-14','0:27:30','1:34:30',67,17.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (243,18,'JN1AZ4EH4FM818948','2022-04-16','8:42:11','9:11:11',29,15.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (244,19,'1FTSW3B53AE364125','2022-04-18','22:10:00','23:47:00',97,44.67);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (245,11,'WAUBF78E78A645988','2022-04-14','11:50:00','13:28:00',98,8.93);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (246,7,'WAUVT58EX3A261352','2022-04-11','11:46:15','12:38:15',52,78.77);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (247,16,'1N6AA0CC3FN050116','2022-04-14','22:19:12','22:20:12',1,64.92);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (248,18,'1G4GE5G37FF088771','2022-04-22','11:26:22','12:36:22',70,22.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (249,9,'WP0CB2A89FS501327','2022-04-15','5:47:15','5:54:15',7,92.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (250,6,'1G4GD5GG2AF580767','2022-04-13','14:37:55','15:12:55',35,30.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (251,10,'2LMDJ6JC5AB819032','2022-04-13','7:19:49','8:45:49',86,80.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (252,19,'3C3CFFDR1ET806239','2022-04-18','14:24:48','16:01:48',97,19.07);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (253,15,'JN1CV6EK0CM001998','2022-04-14','17:06:19','17:29:19',23,2.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (254,1,'SCFEBBBK5BG749124','2022-04-16','22:26:10','23:15:10',49,4.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (255,8,'WP0CB2A89FS501327','2022-04-22','8:19:34','9:01:34',42,37.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (256,12,'3VWJX7AJ5AM161701','2022-04-12','2:55:58','2:57:58',2,80.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (257,2,'4JGBF2FE9BA651870','2022-04-18','14:48:28','15:24:28',36,43.9);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (258,12,'4T1BF1FK8EU862366','2022-04-20','9:57:42','11:03:42',66,40.21);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (259,20,'WP1AE2A20BL744230','2022-04-16','3:32:31','3:35:31',3,70.83);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (260,8,'WP1AE2A20BL744230','2022-04-16','8:15:00','9:38:00',83,33.33);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (261,13,'3VWJX7AJ5AM161701','2022-04-18','11:25:10','12:01:10',36,15.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (262,20,'1D7RB1CT6BS522125','2022-04-14','13:02:57','13:22:57',20,69.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (263,2,'WBAKG1C59CJ345184','2022-04-13','15:24:59','15:53:59',29,93.54);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (264,16,'4T1BF1FK8EU862366','2022-04-22','3:37:53','3:43:53',6,11.24);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (265,9,'2LMDJ6JC5AB819032','2022-04-15','18:51:27','19:22:27',31,8.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (266,6,'4JGBF2FE9BA651870','2022-04-22','1:36:18','2:31:18',55,33.65);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (267,7,'3GYFNAE30FS767413','2022-04-14','4:49:25','5:56:25',67,58.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (268,10,'4A31K2DF7CE651915','2022-04-14','4:49:25','5:56:25',41,13.04);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (269,10,'WDDGF4HB3EG455410','2022-04-11','17:07:53','18:09:53',62,35.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (270,7,'1D7RB1CT6BS522125','2022-04-22','2:18:35','3:33:35',75,40.9);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (271,9,'3VWJX7AJ5AM161701','2022-04-11','9:06:49','9:50:49',44,24.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (272,12,'WAUMK98K49A588608','2022-04-13','21:19:41','22:24:41',65,26.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (273,7,'3GYFNAE30FS767413','2022-04-11','17:36:13','19:05:13',89,74.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (274,16,'WDDGF4HB3EG455410','2022-04-16','13:29:10','13:35:10',6,9.43);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (275,13,'WAUBFAFL5CA911760','2022-04-22','3:10:41','4:15:41',65,19.78);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (276,18,'1D7RW3BK8AS619365','2022-04-15','2:33:33','3:56:33',83,53.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (277,4,'2LMDJ6JC5AB819032','2022-04-16','0:43:21','2:16:21',93,96.15);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (278,15,'WDDGF4HB3EG455410','2022-04-15','4:33:46','5:54:46',81,43.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (279,4,'3C3CFFDR1ET806239','2022-04-19','10:56:14','12:32:14',96,39.39);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (280,2,'WA1CGBFE6CD074246','2022-04-13','10:59:39','12:20:39',81,49.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (282,19,'3GYFNAE30FS767413','2022-04-11','15:20:53','15:39:53',19,80.57);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (283,9,'3C3CFFDR1ET806239','2022-04-15','15:12:30','16:33:30',81,76.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (284,4,'1G4GE5G37FF088771','2022-04-16','5:10:25','5:31:25',21,63.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (285,11,'1N4AL3APXDC704161','2022-04-16','19:28:07','20:39:07',71,87.47);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (286,2,'1D7RB1CT6BS522125','2022-04-14','13:02:51','13:12:51',10,80.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (287,3,'JN1AZ4EH4FM818948','2022-04-15','17:51:03','18:49:03',58,95.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (288,19,'SCFEBBBK5BG749124','2022-04-13','19:43:44','21:23:44',100,35.3);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (289,18,'JTHBK1GG9D1193758','2022-04-12','21:55:25','23:08:25',73,62.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (290,14,'WA1CGBFE6CD074246','2022-04-19','3:27:05','3:37:05',10,8.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (291,13,'SCFEBBBK5BG749124','2022-04-22','19:14:25','20:42:25',88,64.55);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (292,4,'3C3CFFDR1ET806239','2022-04-22','3:33:32','4:20:32',47,92.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (293,7,'WA1CGBFE6CD074246','2022-04-14','8:27:20','9:35:20',68,7.53);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (295,15,'WAUMK98K49A588608','2022-04-12','15:39:51','16:09:51',30,19.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (296,11,'JN1AZ4EH4FM818948','2022-04-13','1:09:45','1:35:45',26,46.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (297,5,'1G4GD5GG2AF580767','2022-04-21','1:03:53','2:37:53',94,16.76);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (298,6,'WUAPV54B03N154484','2022-04-18','16:58:07','17:43:07',45,11.66);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (299,9,'WDDGF4HB3EG455410','2022-04-14','17:59:47','19:35:47',96,77.23);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (300,11,'WA1CGBFE6CD074246','2022-04-11','21:17:10','21:59:10',42,36.59);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (301,8,'WP1AE2A20BL744230','2022-04-12','14:51:12','15:24:12',33,38.04);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (302,6,'WAUDH74F77N848503','2022-04-19','2:24:32','2:56:32',32,82.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (303,11,'1FTSW3B53AE364125','2022-04-12','18:57:34','19:01:34',4,61.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (304,10,'WA1CGBFE6CD074246','2022-04-19','10:51:12','11:07:12',16,57);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (305,10,'4A31K2DF7CE651915','2022-04-21','2:18:14','2:52:14',34,18.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (306,11,'4A31K2DF7CE651915','2022-04-20','2:47:02','3:53:02',66,42.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (307,10,'JM1NC2JF7B0117749','2022-04-22','15:19:09','15:20:09',1,80.02);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (308,11,'JTHDU5EF8C5655108','2022-04-18','21:16:52','22:31:52',75,7.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (310,11,'1D7RW3BK8AS619365','2022-04-11','10:45:01','11:43:01',58,99.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (311,7,'WAUVT58EX3A261352','2022-04-15','10:20:12','11:30:12',70,33.27);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (312,9,'WDDGF4HB3EG455410','2022-04-18','23:11:08','23:15:08',4,51.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (313,14,'WAUBFAFL5CA911760','2022-04-21','6:34:36','7:12:36',38,28.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (314,18,'1N4AL3APXDC704161','2022-04-14','20:54:40','20:59:40',5,49.95);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (315,18,'1FTSW3B53AE364125','2022-04-18','15:04:05','16:29:05',85,13.16);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (316,17,'1FTSW3B53AE364125','2022-04-17','5:53:37','7:19:37',86,87.58);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (317,10,'3C3CFFDR1ET806239','2022-04-13','18:09:49','19:15:49',66,8.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (318,2,'4T1BF1FK8EU862366','2022-04-11','20:05:30','20:25:30',20,26.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (319,19,'3GYFNAE30FS767413','2022-04-11','21:15:15','21:44:15',29,51.19);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (320,6,'JTHDU5EF8C5655108','2022-04-13','9:42:15','10:28:15',46,28.58);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (322,9,'1D7RW3BK8AS619365','2022-04-22','13:44:14','13:50:14',6,10.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (323,7,'WAUVT58EX3A261352','2022-04-22','2:52:31','4:30:31',98,11.75);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (324,11,'WAUMK98K49A588608','2022-04-20','9:12:58','10:49:58',97,73.55);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (325,12,'WUARU78E47N900369','2022-04-19','11:57:01','12:15:01',18,28.67);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (326,11,'1D7RW3BK8AS619365','2022-04-15','5:38:41','5:42:41',4,95.2);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (327,6,'WAUEF78EX8A599263','2022-04-12','6:59:26','7:26:26',27,57.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (329,1,'3C3CFFDR1ET806239','2022-04-11','17:39:12','18:43:12',64,81.28);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (330,16,'SCFEBBBK5BG749124','2022-04-21','15:05:42','16:16:42',71,98.18);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (331,20,'SCFEBBBK5BG749124','2022-04-20','15:58:05','16:38:05',40,49.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (332,2,'JTHBK1GG9D1193758','2022-04-19','17:09:07','18:45:07',96,71.92);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (333,20,'1D7RB1CT6BS522125','2022-04-21','10:07:09','11:02:09',55,97.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (334,2,'1G4GE5G37FF088771','2022-04-14','21:18:24','22:13:24',55,50.61);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (335,18,'WAUVT58EX3A261352','2022-04-12','22:33:46','22:45:46',12,16.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (336,17,'SCFEBBBK5BG749124','2022-04-12','4:20:22','4:31:22',11,33.47);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (337,5,'JM1NC2JF7B0117749','2022-04-19','11:16:19','11:34:19',18,53.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (338,16,'WA1CGBFE6CD074246','2022-04-19','10:42:29','12:17:29',95,32.42);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (339,15,'3C3CFFDR1ET806239','2022-04-14','13:11:44','14:15:44',64,81.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (340,17,'4JGBF2FE9BA651870','2022-04-16','18:48:50','20:12:50',84,85.1);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (341,14,'1G4GD5GG2AF580767','2022-04-18','4:30:23','5:20:23',50,2.73);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (342,5,'WP0CB2A89FS501327','2022-04-16','2:14:59','3:29:59',75,61.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (343,9,'3GYFNAE30FS767413','2022-04-13','21:08:39','21:31:39',23,98.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (344,20,'WP1AE2A20BL744230','2022-04-20','13:14:46','14:18:46',64,9.88);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (345,14,'4T1BF1FK8EU862366','2022-04-11','19:27:49','20:01:49',34,25.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (346,13,'3GYFNAE30FS767413','2022-04-13','15:44:38','17:23:38',99,72.28);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (347,4,'WP1AE2A20BL744230','2022-04-11','17:30:14','18:45:14',75,45.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (348,17,'1N4AL3APXDC704161','2022-04-11','13:29:19','14:22:19',53,35.95);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (349,16,'1D7RW3BK8AS619365','2022-04-18','8:12:12','8:57:12',45,49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (350,7,'1G4GE5G37FF088771','2022-04-16','4:24:03','5:17:03',53,74.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (351,6,'3GYFNAE30FS767413','2022-04-21','5:47:57','6:07:57',20,88.56);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (352,12,'JTHDU5EF8C5655108','2022-04-13','4:30:12','6:07:12',97,77.63);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (353,14,'4JGBF2FE9BA651870','2022-04-12','23:02:02','23:17:02',15,99.55);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (354,1,'3C3CFFDR1ET806239','2022-04-22','3:33:48','5:13:48',100,2.1);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (355,19,'JTHBK1GG9D1193758','2022-04-20','9:44:28','10:19:28',35,95.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (356,20,'JN1AZ4EH4FM818948','2022-04-11','1:37:51','2:47:51',70,94.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (357,16,'2T1BURHE8FC677331','2022-04-19','17:10:54','18:09:54',59,81.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (358,6,'3VWJX7AJ5AM161701','2022-04-20','16:07:45','17:44:45',97,6.05);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (359,12,'2LMDJ6JC5AB819032','2022-04-19','2:14:41','3:26:41',72,26.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (360,12,'JTHDU5EF8C5655108','2022-04-19','18:22:12','19:47:12',85,51.39);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (361,9,'1G4GD5GG2AF580767','2022-04-19','17:43:04','19:22:04',99,9.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (362,11,'WBAKG1C59CJ345184','2022-04-19','20:45:42','20:56:42',11,99.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (363,7,'3C3CFFDR1ET806239','2022-04-17','4:29:21','5:30:21',61,2.95);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (364,14,'1FTSW3B53AE364125','2022-04-21','22:47:14','22:48:14',1,32.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (365,19,'1G4GD5GG2AF580767','2022-04-19','13:28:41','13:57:41',29,22.67);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (366,12,'1G4GD5GG2AF580767','2022-04-12','4:04:53','4:49:53',45,85.44);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (367,19,'WBAKG1C59CJ345184','2022-04-22','5:39:33','5:50:33',11,63.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (368,8,'1D7RW3BK8AS619365','2022-04-11','8:53:03','10:06:03',73,45.05);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (369,14,'1FTSW3B53AE364125','2022-04-12','17:35:34','19:12:34',97,12.12);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (370,8,'JTHDU5EF8C5655108','2022-04-15','2:08:16','2:11:16',3,69.63);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (371,18,'4A31K2DF7CE651915','2022-04-11','23:38:27','23:48:27',10,98.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (372,14,'JTHDU5EF8C5655108','2022-04-13','10:35:23','11:02:23',27,56.25);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (373,7,'WAUDH74F77N848503','2022-04-21','22:30:41','23:39:41',69,19.43);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (374,8,'WAUDH74F77N848503','2022-04-17','20:30:49','21:57:49',87,9.21);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (375,9,'WBALL5C56EP427364','2022-04-15','1:17:30','1:56:30',39,35.77);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (376,2,'WAUDH74F77N848503','2022-04-13','0:14:00','1:13:00',59,12.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (377,7,'WAUBFAFL5CA911760','2022-04-22','9:11:10','10:07:10',56,12.24);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (378,14,'1FTSW3B53AE364125','2022-04-16','7:23:27','8:00:27',37,33.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (380,6,'4JGBF2FE9BA651870','2022-04-21','5:42:29','6:38:29',56,67.33);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (382,20,'1G6DG5EG8A0535663','2022-04-11','17:49:53','18:07:53',18,74.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (383,5,'1G4GE5G37FF088771','2022-04-19','2:26:56','3:58:56',92,23.16);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (384,10,'WBALL5C56EP427364','2022-04-22','20:50:35','21:07:35',17,29.8);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (385,7,'4T1BF1FK8EU862366','2022-04-11','10:17:52','10:34:52',17,30.21);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (386,15,'JTHFE2C21F2693581','2022-04-12','7:53:53','9:17:53',84,69.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (387,7,'TRUSX28N121757217','2022-04-13','5:04:09','5:34:09',30,64.56);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (388,15,'1N6AA0CC3FN050116','2022-04-13','19:56:56','19:57:56',1,63.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (389,13,'WAUVT58EX3A261352','2022-04-14','15:01:41','15:09:41',8,89.92);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (390,6,'1D7RW3BK8AS619365','2022-04-11','1:21:09','1:28:09',7,25.62);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (391,14,'WUAPV54B03N154484','2022-04-22','17:45:42','18:11:42',26,12.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (392,7,'2T1BURHE8FC677331','2022-04-22','8:18:26','9:49:26',91,77.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (393,9,'WUAPV54B03N154484','2022-04-17','6:41:56','7:13:56',32,8.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (394,12,'1FTSW3B53AE364125','2022-04-20','13:41:05','13:54:05',13,14.24);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (395,19,'JN1AZ4EH4FM818948','2022-04-19','19:05:26','19:35:26',30,39.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (396,7,'1N4AL3APXDC704161','2022-04-15','20:43:20','21:09:20',26,71.87);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (397,14,'WDDGF4HB3EG455410','2022-04-12','5:17:40','6:43:40',86,91.33);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (398,3,'1FMJK1G54BE683664','2022-04-13','17:33:25','17:52:25',19,41.04);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (399,17,'3VWJX7AJ5AM161701','2022-04-11','11:52:21','12:30:21',38,54.04);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (400,3,'WAUBF78E78A645988','2022-04-22','15:48:54','16:43:54',55,30.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (401,9,'4T1BF1FK8EU862366','2022-04-18','11:59:39','12:53:39',54,50.68);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (402,14,'1D7RB1CT6BS522125','2022-04-13','12:08:00','13:15:00',67,13.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (403,20,'WP1AE2A20BL744230','2022-04-12','17:03:53','17:33:53',30,6.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (404,17,'4A31K2DF7CE651915','2022-04-12','22:20:51','23:55:51',95,17.36);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (405,2,'2T1BURHE8FC677331','2022-04-11','3:29:04','4:26:04',57,73.02);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (406,10,'WDDGF4HB3EG455410','2022-04-21','2:44:54','3:23:54',39,82.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (407,17,'WP1AE2A20BL744230','2022-04-21','17:27:51','17:31:51',4,40.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (408,15,'JTHDU5EF8C5655108','2022-04-17','15:18:33','16:05:33',47,42.45);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (409,1,'4A31K2DF7CE651915','2022-04-17','19:56:08','20:53:08',57,82.92);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (410,11,'JTHBK1GG9D1193758','2022-04-13','12:20:14','12:21:14',1,22.21);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (411,2,'SCFEBBBK5BG749124','2022-04-14','1:16:10','2:15:10',59,82.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (412,9,'WUAPV54B03N154484','2022-04-19','16:17:27','17:34:27',77,23.24);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (413,15,'1D7RW3BK8AS619365','2022-04-20','20:46:27','22:08:27',82,82.23);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (414,3,'3C3CFFDR1ET806239','2022-04-18','10:13:37','11:48:37',95,29.4);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (415,11,'1N6AA0CC3FN050116','2022-04-17','10:57:01','10:58:01',1,9.76);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (416,12,'JN1AZ4EH4FM818948','2022-04-18','17:06:52','18:14:52',68,51.16);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (417,3,'SCFEBBBK5BG749124','2022-04-19','15:07:45','16:46:45',99,27.8);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (418,12,'JM1NC2JF7B0117749','2022-04-13','6:27:17','6:52:17',25,86.13);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (419,5,'2T1BURHE8FC677331','2022-04-14','0:50:20','1:41:20',51,34.38);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (420,6,'1G6DG5EG8A0535663','2022-04-14','16:27:02','17:51:02',84,64.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (421,12,'3C3CFFDR1ET806239','2022-04-12','12:43:19','14:05:19',82,4.09);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (422,7,'WA1CGBFE6CD074246','2022-04-13','4:18:32','5:21:32',63,81.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (423,6,'WAUBFAFL5CA911760','2022-04-16','9:53:39','10:57:39',64,42.71);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (424,19,'4T1BF1FK8EU862366','2022-04-21','20:02:44','21:25:44',83,30.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (425,4,'WUAPV54B03N154484','2022-04-16','14:24:09','15:14:09',50,78.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (426,9,'3GYFNAE30FS767413','2022-04-19','10:14:41','11:28:41',74,3.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (427,20,'1G6DG5EG8A0535663','2022-04-16','11:39:16','12:49:16',70,36.46);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (428,10,'JN1CV6EK0CM001998','2022-04-11','20:54:49','21:17:49',23,68.81);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (429,17,'JTHFE2C21F2693581','2022-04-22','1:18:28','2:53:28',95,9);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (430,11,'WAUVT58EX3A261352','2022-04-20','8:46:58','9:35:58',49,97.53);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (432,6,'WA1CGBFE6CD074246','2022-04-11','18:11:07','19:02:07',51,87.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (433,16,'2T1BURHE8FC677331','2022-04-11','22:14:53','23:30:53',76,82.48);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (434,13,'WUAPV54B03N154484','2022-04-15','11:31:17','11:58:17',27,76.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (435,12,'WUARU78E47N900369','2022-04-14','16:19:33','16:20:33',1,70.72);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (436,16,'WAUVT58EX3A261352','2022-04-19','8:58:30','9:10:30',12,51.27);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (437,14,'1G4GD5GG2AF580767','2022-04-17','19:40:53','20:33:53',53,77.86);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (439,4,'WAUBF78E78A645988','2022-04-21','7:11:40','8:10:40',59,78.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (440,12,'WAUMK98K49A588608','2022-04-14','16:40:51','18:09:51',89,71.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (441,4,'WDDGF4HB3EG455410','2022-04-18','2:19:51','3:12:51',53,21.93);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (442,14,'WAUBF78E78A645988','2022-04-16','21:14:45','21:38:45',24,5.44);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (443,16,'1N6AA0CC3FN050116','2022-04-15','5:18:49','6:43:49',85,64.58);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (444,5,'1D7RB1CT6BS522125','2022-04-14','14:00:13','14:11:13',11,31.23);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (445,18,'3C3CFFDR1ET806239','2022-04-18','22:06:16','23:27:16',81,21.59);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (446,5,'JTHFE2C21F2693581','2022-04-19','9:21:26','10:48:26',87,65.11);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (447,10,'WDDGF4HB3EG455410','2022-04-16','7:51:56','8:10:56',19,84.26);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (448,13,'WAUEF78EX8A599263','2022-04-12','1:19:52','1:42:52',23,23.01);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (449,7,'WDDGF4HB3EG455410','2022-04-18','17:06:26','18:41:26',95,91.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (450,4,'1B3CB7HB9AD390176','2022-04-11','18:27:38','19:28:38',61,75.49);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (451,3,'WAUEF78EX8A599263','2022-04-16','21:00:32','21:14:32',14,64.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (452,16,'2LMDJ6JC5AB819032','2022-04-17','1:57:05','2:57:05',60,4.5);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (453,8,'WAUVT58EX3A261352','2022-04-11','3:08:00','4:06:00',58,83.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (454,1,'JN1CV6EK0CM001998','2022-04-22','6:51:24','7:49:24',58,11.08);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (455,14,'2T1BURHE8FC677331','2022-04-14','6:01:43','6:35:43',34,97.44);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (456,2,'WP0CB2A89FS501327','2022-04-19','17:33:27','18:33:27',60,81.15);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (457,5,'WBAKG1C59CJ345184','2022-04-20','3:25:17','4:50:17',85,6.35);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (458,2,'JN1AZ4EH4FM818948','2022-04-14','0:44:48','1:53:48',69,99.33);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (459,18,'WBALL5C56EP427364','2022-04-17','0:52:10','1:40:10',48,45.89);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (460,2,'1G4GE5G37FF088771','2022-04-17','18:07:39','18:58:39',51,64.83);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (461,16,'WUARU78E47N900369','2022-04-12','18:49:39','19:20:39',31,51.74);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (462,10,'WBALL5C56EP427364','2022-04-13','4:47:47','5:24:47',37,52.2);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (463,8,'4JGBF2FE9BA651870','2022-04-19','19:43:56','20:25:56',42,61.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (464,18,'4A31K2DF7CE651915','2022-04-14','19:28:20','20:47:20',79,74.45);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (466,10,'1G4GE5G37FF088771','2022-04-16','20:52:26','22:02:26',70,24.85);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (467,6,'WUAPV54B03N154484','2022-04-12','3:01:11','3:08:11',7,92.98);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (468,19,'3VWJX7AJ5AM161701','2022-04-12','5:35:42','6:29:42',54,98.41);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (469,16,'WAUBF78E78A645988','2022-04-12','12:18:52','12:43:52',25,49.29);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (470,13,'SCFEBBBK5BG749124','2022-04-19','23:26:08','23:59:08',33,40.52);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (472,18,'2LMDJ6JC5AB819032','2022-04-20','1:02:15','2:33:15',91,50.37);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (473,3,'WDDGF4HB3EG455410','2022-04-14','0:50:33','2:02:33',72,2.34);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (474,1,'1B3CB7HB9AD390176','2022-04-14','20:10:43','21:40:43',90,5.79);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (475,2,'JTHDU5EF8C5655108','2022-04-20','15:00:59','16:19:59',79,75.97);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (476,18,'WUARU78E47N900369','2022-04-11','6:11:58','6:59:58',48,85.27);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (477,4,'2T1BURHE8FC677331','2022-04-14','11:22:44','11:33:44',11,68.97);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (478,2,'1N6AA0CC3FN050116','2022-04-16','6:22:36','7:01:36',39,6.03);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (479,12,'JTHBK1GG9D1193758','2022-04-18','6:14:52','7:24:52',70,23.22);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (480,3,'1B3CB7HB9AD390176','2022-04-16','6:16:04','7:03:04',47,6.84);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (481,14,'WUAPV54B03N154484','2022-04-15','9:57:36','11:25:36',88,1.27);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (482,7,'3VWJX7AJ5AM161701','2022-04-21','21:12:22','22:21:22',69,18.96);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (484,2,'WAUMK98K49A588608','2022-04-16','18:47:05','20:13:05',86,53.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (485,11,'4T1BF1FK8EU862366','2022-04-12','20:08:54','21:38:54',90,52.14);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (486,1,'3GYFNAE30FS767413','2022-04-20','10:41:19','11:04:19',23,95.7);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (487,14,'1N4AL3APXDC704161','2022-04-21','17:19:49','18:12:49',53,64.18);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (488,13,'WAUMK98K49A588608','2022-04-21','10:34:26','11:09:26',35,83.65);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (489,1,'WAUDH74F77N848503','2022-04-13','0:06:40','0:21:40',15,94.6);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (490,20,'1FTSW3B53AE364125','2022-04-21','20:23:30','20:52:30',29,80.35);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (491,14,'SCFEBBBK5BG749124','2022-04-18','5:19:02','5:38:02',19,37.17);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (492,11,'1N4AL3APXDC704161','2022-04-12','21:19:29','21:42:29',23,4.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (493,9,'1G4GD5GG2AF580767','2022-04-19','1:10:05','2:38:05',88,19.28);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (494,20,'WAUBF78E78A645988','2022-04-13','5:07:52','5:14:52',7,66.32);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (495,3,'3VWJX7AJ5AM161701','2022-04-16','4:56:20','6:28:20',92,71.69);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (496,9,'1D7RB1CT6BS522125','2022-04-17','21:44:55','22:08:55',24,40.46);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (497,17,'SCFEBBBK5BG749124','2022-04-15','9:35:33','11:06:33',91,38.91);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (498,10,'WP1AE2A20BL744230','2022-04-16','17:12:57','17:23:57',11,87.31);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (499,14,'WUAPV54B03N154484','2022-04-14','23:25:51','23:56:51',31,63.99);
INSERT INTO Intervention(intervention_id,ambulancier_id,ambulance_id,intervention_date,start_time,end_time,duration,distance) VALUES (500,14,'WDDGF4HB3EG455410','2022-04-11','12:45:42','12:51:42',6,45.82);

commit;

