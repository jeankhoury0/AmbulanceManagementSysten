-- Question 2

WITH AVGDURATION AS
	(SELECT AMBULANCIER_ID,
			ROUND(AVG(DURATION),
				2) AS DURATION_MEAN_IN_MINUTES
		FROM AMBULANCESYSTEM.INTERVENTION
		GROUP BY AMBULANCIER_ID),
	AMBINFO AS
	(SELECT AMBULANCIER_ID,
			FNAME,
			LNAME
		FROM AMBULANCESYSTEM.AMBULANCIER)

SELECT *
FROM AMBINFO
JOIN AVGDURATION USING (AMBULANCIER_ID);