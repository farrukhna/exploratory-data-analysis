/* 1) How have host countries performed in World Cups over time? Did Qatar follow a similar path? */
 
-- a) Checked the total list of world cup winners

SELECT wcwinners.wcyear AS WCYear, hteam.tname AS Host_Team, wteam.tname AS Winning_Team, rteam.tname AS Runnersup_Team, tteam.tname AS Third_Team, 
fteam.tname AS Fourth_Team, wcwinners.gscored AS Goals_Scored, wcwinners.qteams AS Qualified_Teams, wcwinners.mplayed AS Matches_Played
FROM wcwinners
INNER JOIN intlteams AS hteam ON wcwinners.hcountryid = hteam.teamid
INNER JOIN intlteams AS wteam ON wcwinners.winnerid = wteam.teamid
INNER JOIN intlteams AS rteam ON wcwinners.runnersupid = rteam.teamid
INNER JOIN intlteams AS tteam ON wcwinners.teamid = tteam.teamid
INNER JOIN intlteams AS fteam ON wcwinners.fteamid = fteam.teamid

-- b) Filtered the list teams which won their world cups as hosts

SELECT wcwinners.wcyear AS WCYear, hteam.tname AS Host_Team, wteam.tname AS Winning_Team, rteam.tname AS RunnersupT_eam, tteam.tname AS Third_Team, 
fteam.tname AS Fourth_Team, wcwinners.gscored AS Goals_Scored, wcwinners.qteams AS Qualified_Teams, wcwinners.mplayed AS Matches_Played
FROM wcwinners
INNER JOIN intlteams AS hteam ON wcwinners.hcountryid = hteam.teamid
INNER JOIN intlteams AS wteam ON wcwinners.winnerid = wteam.teamid
INNER JOIN intlteams AS rteam ON wcwinners.runnersupid = rteam.teamid
INNER JOIN intlteams AS tteam ON wcwinners.teamid = tteam.teamid
INNER JOIN intlteams AS fteam ON wcwinners.fteamid = fteam.teamid
WHERE hteam.tname = wteam.tname OR hteam.tname = rteam.tname

-- c) How many times Host countries have won the world cup?

SELECT wteams.tname AS Host_Country, count(wcwinners.winnerid) AS Times_Won_As_Host
FROM wcwinners
INNER JOIN intlteams AS wteams ON wcwinners.winnerid = wteams.teamid
WHERE wcwinners.hcountryid = wcwinners.winnerid
GROUP BY wcwinners.winnerid, wteams.tname
ORDER BY Host_Country ASC

-- d) To simplify things, how many times Host countries have won the world cup?
SELECT wteams.tname AS Host_Country, count(wcwinners.winnerid) AS Times_Won_As_Host
FROM wcwinners
INNER JOIN intlteams AS wteams ON wcwinners.winnerid = wteams.teamid
WHERE wcwinners.hcountryid = wcwinners.winnerid
GROUP BY wcwinners.winnerid, wteams.tname
ORDER BY Host_Country ASC

/* 2) Based on recent form and historical dominance, which countries underperformed in 2022 tournament? Which countries overachieved? */

SELECT intlteams.tranking AS Team_Rank, intlteams.tname AS Team_Name, wcstages.stype AS WC_Stage_Achieved,
CASE
WHEN intlteams.tranking BETWEEN 1 AND 20 AND wcstages.stype = 'Final' THEN 'Expected Performance'
WHEN intlteams.tranking BETWEEN 1 AND 20 AND wcstages.stype = 'Semi finals' THEN 'Expected Performance'
WHEN intlteams.tranking BETWEEN 1 AND 20 AND wcstages.stype = 'Third place' THEN 'Expected Performance'
WHEN intlteams.tranking BETWEEN 1 AND 20 AND wcstages.stype = 'Quarter-finals' THEN 'Expected Performance'
WHEN intlteams.tranking BETWEEN 1 AND 20 AND wcstages.stype = 'Round of 16' THEN 'Expected Performance'

WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Final' THEN 'Over Achieved'
WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Semi finals' THEN 'Over Achieved'
WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Third place' THEN 'Over Achieved'
WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Quarter-finals' THEN 'Over Achieved'
WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Round of 16' THEN 'Over Achieved'
WHEN intlteams.tranking BETWEEN 21 AND 100 AND wcstages.stype = 'Group stage' THEN 'Over Achieved'
ELSE 'Under Achieved'
END AS Team_Overall_Performance

FROM wcmatches
INNER JOIN intlteams ON wcmatches.hteamid = intlteams.teamid OR wcmatches.ateamid = intlteams.teamid
INNER JOIN wcstages ON wcmatches.stageid = wcstages.stageid
WHERE wcmatches.date BETWEEN '2022-11-20' AND '2022-12-18' 
AND wcmatches.matchid = (select max(wcmatches.matchid) from wcmatches WHERE wcmatches.hteamid = intlteams.teamid OR wcmatches.ateamid = intlteams.teamid)
ORDER BY Team_Overall_Performance, intlteams.tranking 

/* 3) Which clubs had the most players who participated in the world cup? */

SELECT TOP 10 worldleagues.cname ,worldleagues.lname AS Club_Name, count(worldleagues.lname) AS Num_of_Players
FROM wcsquads
INNER JOIN intlteams ON wcsquads.teamid = intlteams.teamid
INNER JOIN wcpositions ON wcsquads.positionid = wcpositions.positionid 
INNER JOIN worldleagues ON wcsquads.leagueid = worldleagues.leagueid
GROUP BY worldleagues.cname, worldleagues.lname
ORDER BY Num_of_Players DESC

/* 4) How has been World Cup Performance of Pakistan ?*/

SELECT wcmatches.date, wcstages.stype, hteam.tname, wcmatches.hgoals, wcmatches.agoals, ateam.tname, wconditions.wconditiontype, wteam.tname,
CASE 
WHEN wcmatches.hteam = 0 THEN 'No'
WHEN wcmatches.hteam = 1 THEN 'Yes'
END AS HostTeamMatch
FROM wcmatches
INNER JOIN wcstages ON wcmatches.stageid = wcstages.stageid
INNER JOIN intlteams AS hteam ON wcmatches.hteamid = hteam.teamid
INNER JOIN intlteams AS ateam ON wcmatches.ateamid = ateam.teamid
INNER JOIN wconditions ON wcmatches.wconditionid = wconditions.wconditionid
INNER JOIN intlteams AS wteam ON wcmatches.wteamid = wteam.teamid
WHERE ateam.tname = 'Pakistan' OR hteam.tname = 'Pakistan'

-- 5) How has been Performances of Pakistan since it's independence?

EXEC matcheshistory @teamselect = 'Pakistan'

-- 6) Which teams have won the most world cups ?

SELECT wteams.tname AS TeamName, count(wcwinners.winnerid) AS TimesWon
FROM wcwinners
INNER JOIN intlteams AS wteams ON wcwinners.winnerid = wteams.teamid
GROUP BY wcwinners.winnerid, wteams.tname
ORDER BY TimesWon desc

-- 7) Which WorldCups had the top 5 number of goals scored ?

SELECT TOP 10 wcwinners.wcyear AS WC_Year, wcwinners.gscored AS Goals_Scored
FROM wcwinners
ORDER BY wcwinners.gscored DESC

-- 8) All the hosting teams which have came in the first or second place in the world cup ?

SELECT wcwinners.wcyear AS WCYear, hteam.tname AS Host_Team, wteam.tname AS Winning_Team, rteam.tname AS RunnersupT_eam, tteam.tname AS Third_Team, 
fteam.tname AS Fourth_Team, wcwinners.gscored AS Goals_Scored, wcwinners.qteams AS Qualified_Teams, wcwinners.mplayed AS Matches_Played
FROM wcwinners
INNER JOIN intlteams AS hteam ON wcwinners.hcountryid = hteam.teamid
INNER JOIN intlteams AS wteam ON wcwinners.winnerid = wteam.teamid
INNER JOIN intlteams AS rteam ON wcwinners.runnersupid = rteam.teamid
INNER JOIN intlteams AS tteam ON wcwinners.teamid = tteam.teamid
INNER JOIN intlteams AS fteam ON wcwinners.fteamid = fteam.teamid
WHERE hteam.tname = wteam.tname OR hteam.tname = rteam.tname

-- 9) What has been journey of World Cup matches of Qatar ??
SELECT wcstages.stype, hteam.tname, wcmatches.hgoals, wcmatches.agoals, ateam.tname, wconditions.wconditiontype, wteam.tname,
CASE 
WHEN wcmatches.hteam = 0 THEN 'No'
WHEN wcmatches.hteam = 1 THEN 'Yes'
END AS HostTeamMatch
FROM wcmatches
INNER JOIN wcstages ON wcmatches.stageid = wcstages.stageid
INNER JOIN intlteams AS hteam ON wcmatches.hteamid = hteam.teamid
INNER JOIN intlteams AS ateam ON wcmatches.ateamid = ateam.teamid
INNER JOIN wconditions ON wcmatches.wconditionid = wconditions.wconditionid
INNER JOIN intlteams AS wteam ON wcmatches.wteamid = wteam.teamid
WHERE wcmatches.hteam = 1 AND hteam.tname = 'Qatar'

-- 10) Which Teams had the most Wins and percentage of wins in matches other than world cups?

WITH CTE_TEST(MatchID,Tournament, Date, Team_1, Team_1_Goals, Team_2_Goals, Team_2, Winning_Team) AS
(

SELECT intlmatches.matchid AS MatchID, intltournaments.tname AS Tournament, intlmatches.date AS Date, hteam.tname AS Team_1, intlmatches.hgoals AS Team_1_Goals , 
intlmatches.agoals AS Team_2_Goals, ateam.tname AS Team_2,
CASE
WHEN intlmatches.hgoals > intlmatches.agoals THEN hteam.tname
WHEN intlmatches.hgoals < intlmatches.agoals THEN ateam.tname
ELSE 'DRAW'
END AS Winning_Team
FROM intlmatches
INNER JOIN intltournaments ON intlmatches.tournamentid = intltournaments.tournamentid
INNER JOIN intlteams AS hteam ON intlmatches.hteamid = hteam.teamid
INNER JOIN intlteams AS ateam ON intlmatches.ateamid = ateam.teamid

)

SELECT TOP 15 Winning_Team, Count(Winning_Team) AS No_of_Wins, (SELECT (CAST(COUNT(Winning_Team) AS float)/CAST(COUNT(MatchID) AS float)*100) FROM intlmatches) 
AS Ptg_Of_Wins
FROM CTE_TEST
WHERE Team_1 = Winning_Team OR Team_2 = Winning_Team
GROUP BY Winning_Team
ORDER BY No_of_Wins DESC

