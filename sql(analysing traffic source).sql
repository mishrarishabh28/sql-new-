use mavenfuzzyfactory;
-- coversion rate of traffic
select website_sessions.utm_content,
count(distinct website_sessions.website_session_id) AS sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conversion_rate
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by  website_sessions.utm_content
order by 2 desc

-- -- finding top traffic source
select utm_source,utm_campaign,http_referer,count(*) as sessions
from website_sessions
where created_at < '2012-04-12'
group by utm_source,utm_campaign,http_referer
order by sessions desc

-- TRAFFIC CONVERSION RATES
select count(distinct(website_sessions.website_session_id)) as sessions,
count(distinct(orders.order_id)) as orders,
count(distinct(orders.order_id))/count(distinct(website_sessions.website_session_id)) *100.0 as scr
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-04-14'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'

-- traffic from particular source week wise analysis
select min(date(created_at)),count(*)
from website_sessions
where created_at < '2012-05-12' and 
utm_source = 'gsearch' and 
utm_campaign = 'nonbrand'
group by week(created_at),year(created_at)

-- traffic from different device and their conversion rate
select website_sessions.device_type,count(website_sessions.website_session_id) as visits,
count(orders.order_id) as converted,
count(orders.order_id)/count(website_sessions.website_session_id)*100.0 as cnvr
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-05-11' and
website_sessions.utm_source = 'gsearch' and 
website_sessions.utm_campaign = 'nonbrand'
group by website_sessions.device_type

-- traffic from particular segment and split on device type
select min(date(created_at)),
count(distinct case when device_type = 'mobile' then website_session_id else null end) as mtop,
count(distinct case when device_type = 'desktop' then website_session_id else null end) as dtop
from website_sessions
where created_at < '2012-06-09' and 
created_at > '2012-04-15' and
utm_source = 'gsearch' and
utm_campaign = 'nonbrand'
group by year(created_at), week(created_at)