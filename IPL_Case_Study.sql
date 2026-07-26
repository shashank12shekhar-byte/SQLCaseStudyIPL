--Total spending on players for each team
Select team, SUM(price_in_cr) AS Total_Spending
FROM IPLPlayers
GROUP BY team
ORDER BY Total_Spending DESC;

--Find top 3 highest paid 'All Rounders' across all team
SELECT * FROM IPLPlayers
SELECT player, team, price_in_cr
FROM IPLPlayers
WHERE role= 'All-rounder'
ORDER BY price_in_cr DESC
LIMIT  3;

--Find highest priced player in each team
WITH CTE_MP AS(
	SELECT team, 
	MAX(price_in_cr) AS Max_Price
	FROM IPLPlayers
	GROUP BY team
)
SELECT i.player, i.team, i.price_in_cr
FROM IPLPlayers i
JOIN CTE_MP c ON i.team=c.team
WHERE i.price_in_cr= c.Max_Price

--Rank players by their price within each team and list the top 2 for every team

WITH RankedPlayers As(
	SELECT player, team, price_in_cr,
	ROW_NUMBER() OVER(PARTITION BY team
	ORDER BY price_in_cr DESC) AS Rank_Within_Team
	FROM IPLPlayers
)
SELECT player, team, price_in_cr, Rank_Within_Team
FROM RankedPlayers
WHERE Rank_Within_Team <= 2;

--Most expensive player in each team along with 2nd most expensive player's name and price:
WITH RankedPlayers As(
	SELECT player, team, price_in_cr,
	ROW_NUMBER() OVER(PARTITION BY team
	ORDER BY price_in_cr DESC) AS Rank_Within_Team
	FROM IPLPlayers
)
SELECT team, 
	MAX(CASE WHEN Rank_Within_Team=1 THEN player END)AS MostExpensivePlayer,
	MAX(CASE WHEN Rank_Within_Team=1 THEN price_in_cr END)AS HighestPrice, 
	MAX(CASE WHEN Rank_Within_Team=2 THEN player END)AS SecondMostExpensivePlayer,
	MAX(CASE WHEN Rank_Within_Team=2 THEN price_in_cr END)AS SecondHighestPrice
FROM RankedPlayers
GROUP BY team;

--Calculate the percentage contribution of each player's price to thier team's total spending
SELECT player, team, price_in_cr,
ROUND((price_in_cr/SUM(price_in_cr) OVER(PARTITION BY team))*100, 2) AS ContributionPercentage
FROM IPLPlayers;

--Classify players as 'High', 'Medium', or 'Low' priced based on following rules:
--High: Price> 15cr
--Medium: Price between 5cr and 15cr
--Low: Price< 5cr
--and find out the number of players in each bracket

WITH CTE_BR AS(
SELECT player, team, price_in_Cr,
	CASE
		WHEN price_in_cr > 15 THEN 'High'
		WHEN price_in_Cr BETWEEN 5 AND 15 THEN 'Medium'
		WHEN price_in_cr < 5 THEN 'Low'
	END AS PriceCategory
FROM IPLPlayers
) 
SELECT team, PriceCategory, COUNT(*) AS No_of_players
FROM CTE_BR
GROUP BY Team, PriceCategory
ORDER BY Team, PriceCategory;

--Find the average price of Indian players and compare it with Overseas players using a subquery;
SELECT 
	'Indian' AS PlayerType,
		(SELECT ROUND(AVG(price_in_cr), 2) 
		FROM IPLPlayers
		WHERE type LIKE 'Indian%') AS Average_Price
UNION ALL
SELECT 
	'Overseas' AS PlayerType,
		(SELECT ROUND(AVG(price_in_cr), 2)
		FROM IPLPlayers
		WHERE type LIKE 'Overseas%') AS Average_Price;

--Identify players who earn more than the average price of team;
SELECT player, team, price_in_cr
FROM IPLPLayers p
WHERE price_in_cr> (SELECT AVG(price_in_cr)
					FROM IPLPlayers
					WHERE team= p.team)

--for each role, find the most expensive player and their price using a correlated subquery
SELECT player, role, price_in_cr
FROM IPLPlayers p
WHERE price_in_cr= (SELECT MAX(price_in_cr)
					FROM IPLPlayers
					WHERE role= p.role);
