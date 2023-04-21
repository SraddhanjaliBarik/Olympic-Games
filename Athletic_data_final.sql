/*1.How many olympic games have been held?*/
select count(distinct games) from olympics_history

/*2.List down all olympic games held so far?*/
select distinct year , season, city from olympics_history order by year

/*3. Mention the total no of nations who participated in each olympics game?*/
select games,count(distinct(noc)) as total_countries 
from olympics_history
group by games
order by total_countries
/*Which year saw the highest and lowest no of countries participating in olympics?*/

select A.games as Highest_games_Year, A.Highest,B.games as lowest_game_Year, B.lowest From
(Select games,count(distinct olympics_history_noc_regions.region) as Highest
from olympics_history
join olympics_history_noc_regions 
on olympics_history.noc=olympics_history_noc_regions.noc
group by games
order by Highest Asc Limit 1) as A
cross join 
(select games, count(distinct olympics_history_noc_regions.region) as lowest
from olympics_history
join olympics_history_noc_regions 
on olympics_history.noc=olympics_history_noc_regions.noc
group by games
order by lowest desc Limit 1) As B

/*5.Which nation has participated in all of the olympic games?*/
select region_game.region, count(distinct region_game.games) as Game_count from (select olympics_history_noc_regions.noc, olympics_history_noc_regions.region, olympics_history.games
from olympics_history
join olympics_history_noc_regions on olympics_history_noc_regions.noc=olympics_history.noc)as region_game
 group by region_game.region
order by 2 desc limit 4
 /*6. Identify the sport which was played in all summer olympics.*/
 With a1 as (select count(distinct games) as total_game from olympics_history
 where season='Summer' ),
 b1 as (select distinct sport, games from olympics_history
 where season='Summer'order by games),
 c1 as ( select sport,count(games) as no_of_games from b1 group by sport)
 select* from c1
 join a1 on a1.total_game=c1.no_of_games;
 /*7. Which Sports were just played only once in the olympics.?*/
 
 select sport, count(distinct(games)) as total_games from olympics_history
 group by sport 
 having count(distinct(games)) = 1
 order by total_games 

/*8. Fetch the total no of sports played in each olympic games?*/
select games,count(distinct(sport)) as no_of_sports from olympics_history
group by games
order by no_of_sports desc

/*9. Fetch oldest athletes to win a gold medal*/
with t1 as(select name,sex,age,team,sport,medal,year from olympics_history
where medal = 'Gold'and age <>'NA'
order by age desc),
t2 as (select *, dense_rank() over(order by age desc)as age_rank from t1)
select * from t2 where age_rank=1;

/*10. Find the Ratio of male and female athletes participated in all olympic games.*/
with male_count as 
(select count(sex) as male_count,games from olympics_history
where sex='M'
group by games),
female_count as 
(select count(sex) as female_count,games from olympics_history
where sex='F'
group by games)
select sum(male_count) as total_male, sum(female_count) as total_female   from male_count
join female_count on male_count.games=female_count.games

11. Fetch the top 5 athletes who have won the most gold medals.
with t1 as
(select name , team , count(medal) as medal from olympics_history
 where medal ='Gold' group by name,team 
 order by medal desc),
 t2 as (select * , dense_rank() over(order by medal desc ) as rank
    from t1)
select * from t2
where rank <=5;

/*12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)?*/

with q1 as 
(select name , team , count(medal) as Total_medal from olympics_history
 where medal in ('Gold','Silver','Bronze')
group by name,team
order by Total_medal desc),

q2 as (
    select * , dense_rank() over(order by total_medal desc ) as rank
    from q1)
select * from q2
where rank <=5;


/*13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won?*/

with q1 as(
    select olympics_history_noc_regions.region,count(medal) as total_medal
    from olympics_history
    join olympics_history_noc_regions on olympics_history_noc_regions.noc=olympics_history.noc
    where medal in ('Gold','Silver','Bronze')
    group by olympics_history_noc_regions.region
    order by total_medal desc),

q2 as (
    select * , dense_rank() over(order by total_medal desc)
    from q1)
select * from q2
where dense_rank <=5;

14. List down total gold, silver and bronze medals won by each country.

with gold as 
(select olympics_history_noc_regions.region,count(medal) as gold from olympics_history
join olympics_history_noc_regions on olympics_history_noc_regions.noc=olympics_history.noc
where medal ='Gold'
group by olympics_history_noc_regions.region
order by gold desc),

silver as (
    select olympics_history_noc_regions.region,count(medal) as silver from olympics_history
    join olympics_history_noc_regions on olympics_history_noc_regions.noc=olympics_history.noc
    where medal ='Silver'
    group by olympics_history_noc_regions.region
    order by silver desc
),
bronze as (
    select olympics_history_noc_regions.region,count(medal) as bronze from olympics_history
    join olympics_history_noc_regions on olympics_history_noc_regions.noc=olympics_history.noc
    where medal ='Bronze'
    group by olympics_history_noc_regions.region
    order by bronze desc
)

select * from ((gold
left join silver on gold.region=silver.region)
left join bronze on gold.region=bronze.region)
order by gold desc

2nd methode:
//create extension tablefunc: for crossfunction
select nr.region as country , medal, count(1) as total_medal from olympics_history oh
join olympics_history_noc_regions nr on oh.noc=nr.noc
where medal<>'NA'
group by nr.region, medal
order by nr.region, medal

select * from crosstab
      ('select nr.region as country , medal, count(1) as total_medal from olympics_history oh
      join olympics_history_noc_regions nr on oh.noc=nr.noc
      where medal<>''NA''
      group by nr.region, medal
      order by nr.region, medal')
   as result(country varchar, gold bigint, silver bigint, bronze bigint)
   order by gold desc, silver desc, bronze desc