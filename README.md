Patient Data Analysis Project

📌 Project Overview

This project focuses on analyzing Hospital patient dataset to derive insights related to gender distribution, death rate trends, and city-wise mortality rates. The goal is to identify patterns in patient demographics and deaths over time, helping to understand key trends within the dataset.

🛠 Technologies Used

SQL for data extraction and analysis

DBMS (Database Management System) for querying the patient data

Data Visualization Tools: PowerBI 

📂 Dataset Description

The dataset consists of patient records with relevant fields, including:

patient_id – Unique identifier for each patient

gender – Male or Female

city – City where the patient resides

deathdate – Date of death (NULL if the patient is alive)

🔍 Key Analysis Performed

1️⃣ Patient Demographics

Counted the total number of male and female patients to understand the gender distribution.

2️⃣ Death Rate by Gender

Calculated the number of recorded deaths for both male and female patients.

3️⃣ City-wise Mortality Rate

Identified cities with the highest number of deaths.

Boston recorded the highest deaths, followed by Quincy, Cambridge, Revere, and Chelsea.

4️⃣ Death Rate Trends Over Time

Extracted death counts per year and city to determine if deaths were rising or falling in specific locations.

NULL values in the deathdate column indicate that some patients are still alive.

5️⃣ Data Cleaning & Formatting

Converted deathdate to a valid date format for better analysis.

Filtered out NULL values to focus on recorded deaths.


🔮 Future Improvements

Deeper Analysis: Explore correlations between gender, location, and mortality causes.

Predictive Modeling: Utilize machine learning to predict mortality risks based on historical data.

📄 Conclusion

This project provides a structured analysis of patient records to uncover key mortality trends. The findings can be valuable for healthcare professionals, policymakers, and researchers to enhance patient care and intervention strategies.