-- Abigail Rhea: Sleep quality and physical factors analysis
-- 3/19/2024

CREATE TABLE sleep_health(
	id SERIAL PRIMARY KEY,
	gender VARCHAR(10),
	age smallint,
	occupation VARCHAR(250),
	sleep_duration numeric,
	sleep_quality smallint,
	physical_activity smallint,
	stress_level smallint,
	bmi VARCHAR(250),
	blood_pressure VARCHAR(10),
	heart_rate smallint,
	daily_steps smallint,
	sleep_disorder VARCHAR(250)
)
;

COPY sleep_health(id, gender, age, occupation, sleep_duration, sleep_quality,
				 physical_activity, stress_level, bmi, blood_pressure,
				 heart_rate, daily_steps, sleep_disorder)
FROM 'D:\Data Science MS\SQL\Sleep_health_and_lifestyle_dataset.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM sleep_health;

UPDATE sleep_health
SET bmi = 'Normal'
WHERE bmi = 'Normal Weight';

/*Below, I display the average sleep duration of all ids in the dataset.
The average was ~7 hours/night. */

SELECT AVG(sleep_duration) AS sleep_average FROM sleep_health;

/* Next, I view the average sleep duration in hours per night for males
and females. The averages are the same, ~7 hours/night. */

WITH ms AS (
	SELECT gender, AVG(sleep_duration) AS male_sleep_avg1
	FROM sleep_health
	GROUP BY gender)
SELECT gender, 
		ROUND(ms.male_sleep_avg1) as male_sleep_avg
	FROM ms
	WHERE gender = 'Male'
	GROUP BY gender, ms.male_sleep_avg1;
	
WITH fs AS (
	SELECT gender, AVG(sleep_duration) AS female_sleep_avg1
	FROM sleep_health
	GROUP BY gender)
SELECT gender, 
		ROUND(fs.female_sleep_avg1) as female_sleep_avg
	FROM fs
	WHERE gender = 'Female'
	GROUP BY gender, fs.female_sleep_avg1;

/* Below, we can see the age, the average sleep quality value, and the
average stress level of all ids. The age is displayed in ascending order. 
I did not see much of a correlation between age, sleep quality, and stress
levels.*/

WITH sleep AS (
	SELECT DISTINCT(age), AVG(sleep_quality) AS sleep_quality_avg1,
	AVG(stress_level) AS stress_level_avg1
	FROM sleep_health
	GROUP BY age, sleep_quality, stress_level)
SELECT DISTINCT(age),
		ROUND(sleep.sleep_quality_avg1) AS sleep_quality_avg,
		ROUND(sleep.stress_level_avg1) AS stress_level_avg
	FROM sleep
	GROUP BY age, sleep.sleep_quality_avg1, sleep.stress_level_avg1
	ORDER BY age;

/* Here, we can see the correlation between the amount of physical activity
and the sleep quality score. I've limited the output to 30 rows.The results show a
positive correlation. As physical activity values increase, sleep quality scores increase. */

SELECT sleep_quality, physical_activity 
FROM sleep_health
ORDER BY sleep_quality DESC, physical_activity DESC
LIMIT 30;
SELECT sleep_quality, physical_activity
FROM sleep_health
ORDER BY sleep_quality, physical_activity DESC
LIMIT 30;

/* Below, we can also see a correlation between the stress level score
and the duration of sleep. We see a negative correlation between them. 
As one increases, the other decreases. */

SELECT stress_level, sleep_duration
FROM sleep_health
ORDER BY stress_level, sleep_duration DESC;

/* The query below outputs occupation, the average sleep quality score, 
and average stress_level. The output reveals that the two sales categories
and the scientist occupation tend to score lower in sleep quality and
higher in stress levels, overall. Engineers scored the best overall for both averages.*/
	
WITH occupation AS (
	SELECT DISTINCT(occupation), AVG(sleep_quality) AS sleep_quality,
	AVG(stress_level) AS stress_level
	FROM sleep_health
	GROUP BY occupation)
SELECT DISTINCT occupation, ROUND(occupation.sleep_quality) AS avg_sleep_quality,
	ROUND(occupation.stress_level) AS avg_stress
	FROM occupation
	GROUP BY occupation, occupation.sleep_quality, occupation.stress_level;
	
/* Now, we can look at each gender to see the difference in sleep quality and stress levels.
Male sleep quality scores average at 7, while the average stress level is 6. */

WITH ss AS (
	SELECT gender, AVG(sleep_quality) AS male_sleep_qual,
	AVG(stress_level) AS male_stress
	FROM sleep_health
	GROUP BY gender)
SELECT gender, 
		ROUND(ss.male_sleep_qual) as male_sleep_avg,
		ROUND(ss.male_stress) AS male_stress_avg
	FROM ss
	WHERE gender = 'Male'
	GROUP BY gender, ss.male_sleep_qual, ss.male_stress;
	
/* Female average sleep quality is one point higher at 8. The average 
stress level for females is 5. This is one less than male averages. */

WITH ss AS (
	SELECT gender, AVG(sleep_quality) AS female_sleep_qual,
	AVG(stress_level) AS female_stress
	FROM sleep_health
	GROUP BY gender)
SELECT gender, 
		ROUND(ss.female_sleep_qual) as female_sleep_avg,
		ROUND(ss.female_stress) AS female_stress_avg
	FROM ss
	WHERE gender = 'Female'
	GROUP BY gender, ss.female_sleep_qual, ss.female_stress;
	
/* Below, I decided to take a look at physical factors. Limiting the output to the
top 20 physical activity scores, we can see the blood pressure, BMI, and sleep disorder,
or lack there of. In descending order, we can see that the BMI is normal for all ids.
We can also see this consistency in the blood pressure column. Only 3 of the 20
have a diagnosed sleep disorder, none with sleep apnea. This could show a positive correlation
between physical activity and health factors like weight, blood pressure, and sleep quality.*/
	
SELECT physical_activity, bmi, blood_pressure, sleep_disorder
FROM sleep_health
ORDER BY physical_activity DESC
LIMIT 20;

/* Just to further iterate the discovery above, we can see the opposite affect. The output
below shows the 40 lowest physical activity scores and the respective blood pressure, bmi, and sleep disorder.
As you can imagine, there are 3 obese BMI's listed. There is less consistency in blood pressure values, with some
higher values displayed. Lastly, there are three sleep apnea diagnosis listed in the sleep disorder column.
Where one factor affects the other would take further analysis, outside of this dataset. However, I do see a 
correlation between these physical health factors and sleep disorder prevalence, ableit small. */

SELECT physical_activity, bmi, blood_pressure, sleep_disorder
FROM sleep_health
ORDER BY physical_activity ASC
LIMIT 20;

/* Below, the number of ids (people) who have a diagnosed sleep disorder is displayed.*/

SELECT COUNT(id) AS number_of_ids, sleep_disorder
FROM sleep_health
GROUP BY sleep_disorder
HAVING sleep_disorder != 'None';

/* Now, we add in the gender column to see a comparison between male and female.
Females hold 67 of the 78 sleep apnea diagnoses in this dataset.
Males hold 41 of the 77 insomnia diagnoses.*/

SELECT COUNT(id) AS number_of_ids, gender, sleep_disorder
FROM sleep_health
GROUP BY gender, sleep_disorder
HAVING sleep_disorder != 'None'
ORDER BY number_of_ids DESC;

/* We should now compare the gender, sleep disorder, sleep duration, and stress level.
I've filtered the stress level to be greater than or equal to 7, as this is one point above the
highest average. We can see that the number of hours in sleep stays between 5.8 and 6.5.*/

SELECT gender, sleep_disorder, sleep_duration, stress_level
FROM sleep_health
WHERE sleep_disorder != 'None' 
AND stress_level >= 7;

/* I want to see how many ids, for each gender, does the stress level reach 7 and higher when
there is a diagnosis of a sleep disorder. To no surprise, females have a stress level of 7 or higher
more frequently than males when diagnosed with sleep apnea. Out of the 67 female with sleep apnea,
35 state a stress level of 7 or higher. Out of the 36 females with insomnia, only 9 state a stress
level of 7 or higher. Of the 11 men diagnosed with sleep apnea, 5 state a stress level of at least 7.
Of those males diagnosed with insomnia, 35 of the 41 state a stress level of at least 7.*/

SELECT COUNT(id) AS number_of_ids, gender, sleep_disorder
FROM sleep_health
WHERE sleep_disorder != 'None'
AND stress_level >= 7
GROUP BY gender, sleep_disorder;

/* Just for curiousity sake, I want to see how many males and females score a stress level of 7 or more
when not diagnosed with any sleep disorder. Out of all females who do not have a sleep disorder, only 2 report
a stress level above 7. 35 males without a sleep disorder score a stress level at 7 or more.*/

SELECT COUNT(id) AS number_of_ids, gender, sleep_disorder
FROM sleep_health
WHERE sleep_disorder = 'None'
AND stress_level >= 7
GROUP BY gender, sleep_disorder;

/* Finally, I'd like to get an idea of gender, age, and occupation in comparison to physical facotrs, sleep quality, 
and stress level. I've started with the lowest stress levels, limited to the first 20 outputs. We can see 
that females tend to score lower stress levels, as only 4 of the 20 ouputs are males. Another interesting
revelation is the median age for these females tends to fall near the 50s, with few exceptions. Following
our discoverey of the lowest stress scores following the Engineer occupation, we see that again here. The majority
of rows below display engineer. The heart rate mostly falls at or below 70, with one exception. Daily steps
fall fairly consistently around 5000, with some variation above and below. All sleep quality scores are at
a value of 9, while all stress levels are at 3.*/


SELECT gender, age, occupation, daily_steps, heart_rate, blood_pressure, 
bmi, sleep_quality, stress_level
FROM sleep_health
ORDER BY stress_level ASC
LIMIT 20;

/* When reverse, the highest stress level scores reveal the prevalance of young, adult males.
The primary occupation is Doctor, with very few variation. Daily steps fluctuate and trend upward in
comparison to the previous output. The heart rate tends to fall between 70 and 85. Sleep quality values
are much lower and stress levels are much higher. Occupation does seem to have a strong affect on sleep
quality and stress levels. These factors could potentially be the cause for the increase in heart rate, 
but further data would need to be analyzed.*/

SELECT gender, age, occupation, daily_steps, heart_rate, blood_pressure, 
bmi, sleep_quality, stress_level
FROM sleep_health
ORDER BY stress_level DESC
LIMIT 20;
