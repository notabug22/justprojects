use project_db;
/* 3093 distinct owners, 520 models from 51 brands*/
select count(distinct (owner_id)) as investors,
count(distinct(vehiclemake)) as brands, 
count(distinct(VehicleModel)) as models, 
count(distinct(state)) as states from carrental;

/*total buisness*/
select SUM(TripsTaken*DailyFare) as revenue from carrental;
#####################################################################
/*owner's/ investor's perspective*/
/*OWNER WHO HAS THE MOST AND THE LEAST NUMBER OF CARS INVESTED*/
/*(929 owners has more than 1 car invested)*/
select owner_id,count(owner_id) as count from carrental
group by owner_id 
having count>1
order by count desc limit 5;

select owner_id,count(owner_id) as count from carrental
group by owner_id 
having count=1
order by count asc limit 5;


/*owner who earned the most and the least (top 5 and bottom 5)*/
select Owner_Id,sum(DailyFare*TripsTaken) as total_earnings 
from carrental
group by owner_id 
order by total_earnings desc limit 5;

select Owner_Id, sum(DailyFare*TripsTaken) as total_earnings 
from carrental
group by owner_id 
having total_earnings>0
order by total_earnings ASC LIMIT 5;
###################################
/*car specific queries:*/
/*highest and lowest dailyfare*/
SELECT MAX(DailyFare),VehicleMake,VehicleModel 
FROM CARRENTAL
WHERE DAILYFARE IN (SELECT MAX(DAILYFARE) FROM CARRENTAL);

SELECT MAX(DailyFare) AS HIGHEST,VehicleMake,VehicleModel,TRIPSTAKEN 
FROM CARRENTAL
GROUP BY VEHICLEMODEL
ORDER BY HIGHEST;

SELECT MIN(DailyFare) AS LOWEST,VehicleMake,VehicleModel 
FROM CARRENTAL
GROUP BY VEHICLEMODEL
ORDER BY LOWEST;

/*A.most and least favoured car brand*/
select VehicleMake, sum(TripsTaken) as total_trips  
from carrental 
group by vehiclemake
order by total_trips desc limit 10;

select VehicleMake, sum(TripsTaken) as total_trips  
from carrental 
where TripsTaken>0
group by vehiclemake
order by total_trips asc limit 10;

/*B.most and least cost effective car brand */
select vehiclemake,sum((dailyfare)*(TripsTaken)) as total_fare 
from carrental
group by vehiclemake
order by total_fare desc limit 10;

select vehiclemake,sum((dailyfare)*(TripsTaken)) as total_fare 
from carrental
group by vehiclemake
order by total_fare asc limit 10;

/*C.which fueltype is earning most revenue?*/
select fueltype,count(fueltype) as count,sum(DailyFare*TripsTaken) as revenue
from carrental group by fueltype
order by  count desc; 

/*D. how 'SUPER LUXARY" sports car brands are doing*/
SELECT distinct VEHICLEMAKE AS BRANDS  FROM CARRENTAL;

SELECT VehicleMake,VehicleModel,SUM(TRIPSTAKEN) AS TRIP 
FROM CARRENTAL
WHERE VEHICLEMAKE IN ('FERRARI',
'ASTON MARTIN','McLAREN','MASERATI','LAMBORGHINI','PORSCHE','ALFA ROMEO')
GROUP BY VEHICLEMAKE
ORDER BY 1,3;

/*E. categorize the car on the basis of rating*/
with ct as ( SELECT concat_ws(" ",vehiclemake,vehiclemodel) as vehicle,rating,
                     Case
						WHEN rating=5.00 then "Best"
                        WHEN rating between 4.00 and 5.00 then "Good"
                        WHEN rating=0 then "not-available"
                        else "bad"
                        End as category
                       FROM carrental
		order by rating desc)
        select category,count(category) as count
        from ct
        group by category;

/* F.wheather or not the ratings are reliable*/
 with tt as (with ct as (SELECT concat_ws(" ",vehiclemake,vehiclemodel) as vehicle,
rating,
(TripsTaken-ReviewCount) as difference from carrental where rating>0)
select vehicle,rating,difference,case
                                 when difference>30 then "unreliable" 
                                 when difference between 20 and 30 then "not sure"
                                 else "authentic"
                                 end as authenticity
from ct
order by rating,authenticity)
select authenticity, count(authenticity) as count
from tt
group by authenticity ;

        
/*G. no. of unused cars*/
with ct as (select concat_ws("",vehiclemake,vehiclemodel) as vehicle,vehicleyear 
from carrental 
where tripstaken=0)
select vehicleyear,count(vehicle) as count
from ct
group by VehicleYear with rollup
order by VehicleYear ;
########################################################################
/*business question:*/

/*A.most and least frequent city*/
select state,LocationCity,(sum(tripstaken)) as frequency
from carrental
group by locationcity 
order by frequency desc, state asc;

/*B.most and least productive city */
select state,LocationCity,sum(tripstaken*dailyfare) as fare 
from carrental
group by locationcity
order by fare desc limit 5; 

with ct as (select state,LocationCity,sum(tripstaken*dailyfare) as fare 
from carrental
group by locationcity
order by fare asc)
select state,locationcity,fare
from ct where fare>0
order by fare asc limit 5;

/*C.state wise car rental TOP 5(CA,FL,TX,CO,NV)*/
select state,sum(tripstaken)as total_trips from carrental 
group by state
order by total_trips desc,state
limit 5;
/*bottom 5*/
select state,sum(tripstaken)as total_trips from carrental 
group by state
order by total_trips asc,state
limit 5;

/*D which brand is preferred in which state*/
with ct as
(select state,vehiclemake,sum(tripstaken)as total_trips 
from carrental 
group by vehiclemake,state 
order by state asc,total_trips desc)
 select state,vehiclemake,max(total_trips) as max from ct
 group by state;

/*E.which cartype is preferred in which state*/

WITH ct as (
select state,
sum( case when vehicletype = "suv" then tripstaken else null end) as suv,
sum( case when vehicletype = "car" then tripstaken else null end) as car,
sum( case when vehicletype = "truck" then tripstaken else null end) as truck,
sum( case when vehicletype = "minivan" then tripstaken else null end) as minivan,
sum( case when vehicletype = "van" then tripstaken else null end) as van,
sum(tripstaken) as total
from carrental
group by state
order by state asc)

select r.REGION,c.state ,suv/total , car/total , truck/total , minivan/total,van/total
from ct C INNER JOIN region r
on c.state= r.`State code`;

/*F.the cartype that is available*/
select state,
count( case when vehicletype = "suv" then tripstaken else null end) as suv,
count( case when vehicletype = "car" then tripstaken else null end) as car,
count( case when vehicletype = "truck" then tripstaken else null end) as truck,
count( case when vehicletype = "minivan" then tripstaken else null end) as minivan,
count( case when vehicletype = "van" then tripstaken else null end) as van
from carrental
group by state
order by state desc;


/*G. wheather the city overlaps with nearest airport city
(growth opportunities in airport cities.) */
  select state,count(owner_id) as count
  from carrental 
  where LocationCity<>AirportCity
  group by state
  order by count desc limit 10;


/*H. region and division wise market share*/
select r.region,sum(cr.tripstaken*cr.dailyfare) as revenue 
from carrental cr inner join region r
on cr.state=r.`State Code`
group by region 
order by revenue desc; 

select r.region,r.division,sum(cr.tripstaken*cr.dailyfare) as revenue 
from carrental cr inner join region r
on cr.state=r.`State Code`
group by division 
order by revenue desc; 
