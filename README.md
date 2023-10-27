# Power-BI-3-Wisabi-Bank
The PBIX. can be downloaded from
https://drive.google.com/file/d/1ILZ3vhr49hnW5roJd8G64LdXTdqOEI-O/view?usp=sharing

The dataset, project brief and materials can be found here:
https://drive.google.com/drive/folders/11h6RCsniJXMrfRhXnxSo_8-buBveWcgU

This is a log of the dashboard building steps including the measures created and their assiociated DAX formulas:

1. Read the project brief
2. Load & rename the 5 tables into Power BI
3. Clean the tables (Remove NaNs, changed column types)
4. Added a calculated column using DAX to find the transaction duration using: Duration.TotalMinutes
5. Added calculated column using DAX to find the age using the birth date: DateTime.LocalNow() - Challenges faced included regional settings, column type settings, learning the formula from scratch.
6. Created a new conditional column to seperate the ages into age groups of 10 
7. Make sure all column types are as they should (Integer,DateTime, etc.)
8. Create relationships from all table to the transactions table 
9. Hide the unneeded columns in the transactions table (aka the joined columns)
10. Create a new measures table using DAX: Measures Table = {BLANK()}
11. Question asks for average transaction amount by location and type, create new measure DAX: Average_Amount = AVERAGE(Transactions[TransactionAmount])
12. Question 2: Which ATM location has the highest number of transactions per day, and at what time of the day do the transactions occur most frequently?
- Create measure that counts number of transactions, DAX: Transaction_Count = COUNTROWS(Transactions)
13. Question 3: Which age group has the highest number of transactions, and which transaction type do they usually perform? 
- Use the age group column created in step 6 + measure created in step 12. 
14. Question 4: What is the trend of transaction volume and transaction amount over time, and are there any seasonal trends or patterns?
- Create a new measure for txn amount. DAX: Transaction_amount = SUM(Transactions[TransactionAmount]) 
- Challenges: data was not grouped by months, just grouped as blank. 
- Remedy: checked through the relationships, checked wether i was making any mistakes in the data visualisation part, checked the date column types for all tables and found the issue there. 
- Challenge: In the visualisation, months are not in chronological order, and they cant be sorted by alphebetical order. 
- Remedy: Visualisation panel: Month Name > Sort by Column > sort by Month column. month column contains the month number in calendar order. 
- Drag out and in the Month Name in the X-axis (to refresh data), visualisation is now chronologically sorted. 
15. Question 5: What is the most common transaction type, and how does it vary by location and customer type (Wisabi customer vs. non-Wisabi customer)?
- Donut chart; add txn count + name data. Filters for location + customer type. 
16. What is the average transaction amount and transaction frequency per customer by occupation and age group? 
- Create new measure number of customers DAX: Nu_Customers = DISTINCTCOUNT(Transactions[CardholderID]) 
- Create new measure transaction_freq DAX: Transaction_Freq = DIVIDE([Transaction_Count],[Nu_Customers]) | Change transaction_freq measure to Whole Number column type. 
17. Question 7: What is the percentage of transactions that are withdrawals, savings, balance enquiries, and transfers, and how does it vary by location and time of day?  
- Filter the donut chart.	
18. Question 8: Which ATM locations have the highest and lowest utilization rates, and what factors contribute to this utilization rate?
- Create new measure to find the rate (time used/time available 24/7 365) . Put state, util_rate into the map visual.
- Challenges: map not coming out. 
- Remedy: Changed the file region settings to nigeria but still did not work. Went in to table view and changed the column category to city/country/state and the map visual worked.  
19. Question 9: What is the average transaction time by location, transaction type, and time of day, and how does it vary by customer type and occupation? 
- Create new measures DAX: Average_Duration = AVERAGE(Transactions[Duration]) 
DAX:  % Transactions = DIVIDE([Transaction_Count], CALCULATE([Transaction_Count],ALLSELECTED(Transactions) )  
20. Added the background, arranged the dashboards, formated te visuals to fit in with the dashboards.
21. Created buttons for an interactive dashboard where you can select different pages by clicking on the dashboard itself.
