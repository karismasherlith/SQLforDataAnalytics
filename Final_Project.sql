--Q1
CREATE TABLE matches
(id int , city varchar , date date , player_of_match varchar , venue varchar , 
neutral_venue int , team1 varchar , team2 varchar , toss_winner varchar , toss_decision varchar , 
winner varchar , result varchar , result_margin int , eliminator varchar , method varchar , umpire1 varchar , umpire2 varchar);
--Q2
CREATE TABLE deliveries
(id int , inning int , over int , ball int , batsman varchar , non_striker varchar , bowler varchar , 
 batsman_runs int , extra_runs int , total_runs int , is_wicket int , dismissal_kind varchar , 
 player_dismissed varchar , fielder varchar , extras_type varchar , batting_team varchar , bowling_team varchar);
--Q3
copy matches from 'C:\Program Files\PostgreSQL\14\data\Data\IPLMatches+IPLBall\IPL_matches.csv' delimiter ',' csv header;
--Q4
copy deliveries from 'C:\Program Files\PostgreSQL\14\data\Data\IPLMatches+IPLBall\IPL_Ball.csv' delimiter ',' csv header;
--Q5
select * from deliveries order by id,inning,over,ball limit 20;
--Q6
select * from matches limit 20;
--Q7
select * from matches where date = '2013-05-02';
--Q8
select * from matches where result = 'runs' and result_margin > 100;
--Q9
select * from matches where result = 'tie' order by date desc;
--Q10
select count(distinct city) as city_count from matches;
--Q11
create table deliveries_v02 as select * , 
case when total_runs >=4 then 'boundary' 
when total_runs = 0 then 'dot' 
else 'other' end as ball_result from deliveries;
--Q12
select ball_result, count(*) from deliveries_v02 where ball_result in ('boundary','dot') group by ball_result;
--Q13
select batting_team as team,count(*) as boundary_count from deliveries_v02 where ball_result = 'boundary' group by team order by boundary_count desc;
--Q14
select bowling_team as team,count(*) as dot_count from deliveries_v02 where ball_result = 'dot' group by team order by dot_count desc;
--Q15
select dismissal_kind, count(*) as total_no_of_dismissal from deliveries where dismissal_kind not like 'NA' group by dismissal_kind order by total_no_of_dismissal desc;
--Q16
select bowler, sum(extra_runs) as total_extra_runs from deliveries group by bowler order by total_extra_runs desc limit 5;
--Q17
create table deliveries_v03 as select d.*,m.venue,m.date as match_date from deliveries_v02 as d left join matches as m on d.id = m.id;
--Q18
select venue, sum(total_runs) as total_runs_scored from deliveries_v03 group by venue order by total_runs_scored desc;
--Q19
select extract(year from match_date) as year , sum(total_runs) as total_runs_scored from deliveries_v03 where venue = 'Eden Gardens' group by year order by total_runs_scored desc;
--Q20
create table matches_corrected as select * , 
case when team1 = 'Rising Pune Supergiants' then 'Rising Pune Supergiant' else team1 end as team1_corr ,
case when team2 = 'Rising Pune Supergiants' then 'Rising Pune Supergiant' else team2 end as team2_corr from matches;
--Q21
create table deliveries_v04 as select id||'-'||inning||'-'||over||'-'||ball as ball_id , * from deliveries_v03;
--Q22
select count(*) as total_row_count , count(distinct ball_id) as total_distinct_ball_id_count from deliveries_v04;
--Q23
create table deliveries_v05 as select *, row_number() over (partition by ball_id order by ball_id) as r_num from deliveries_v04;
--Q24
select * from deliveries_v05 where r_num > 1;
--Q25
select * from deliveries_v05 where ball_id in (select ball_id from deliveries_v05 where r_num > 1);