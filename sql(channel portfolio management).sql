use mavenfuzzyfactory;
-- traffic brand vs nonbrand
select year(created_at),month(created_at),
count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand,
count(distinct case when utm_campaign = 'brand' then website_session_id else null end) as brand,
count(distinct case when utm_campaign = 'brand' then website_session_id else null end)/
count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as brand_pct,
count(distinct case when utm_campaign is null and http_referer is null then website_session_id else null end) 
as direct,
count(distinct case when utm_campaign is null and http_referer is null then website_session_id else null end)/
count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as direct_pct,
count(distinct case when utm_campaign is null and http_referer is not null then website_session_id else null end) 
as organic,
count(distinct case when utm_campaign is null and http_referer is not null then website_session_id else null end) /
count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as organic_pct
from website_sessions
group by year(created_at),month(created_at)

-- organic traffic on website
select
case 
    when http_referer is NULL then 'noaction'
    when http_referer = 'https://www.gsearch.com' then 'gsearch_organic'
    when http_referer = 'https://www.bsearch.com' then 'bsearch_organic'
    else 'others'
end as category, count(distinct website_session_id)
from website_sessions
where utm_source is null and website_session_id between 100000 and 115000
group by 1

-- utm_content vs device_type
select min(date(created_at)),
count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) 
as g_dtop,
count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) 
as b_dtop,
count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/
count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) * 100.0 as b_pct_of_dtop,
count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) 
as g_mob,
count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) 
as b_mob,
count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) /
count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) *100.0 as b_pct_of_mob
from website_sessions
where created_at between '2012-11-04' and '2012-12-22'
group by yearweek(created_at)

-- cross chanelling bid optimization
select distinct website_sessions.device_type,website_sessions.utm_source,
count(distinct website_sessions.website_session_id) as sessions,count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id)*100.0 as conv_rate
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source in ('gsearch','bsearch') and 
website_sessions.created_at between '2012-08-22' and '2012-09-18' 
group by website_sessions.device_type,website_sessions.utm_source
order by website_sessions.device_type

-- percentage user by different device
select utm_source,count(distinct website_session_id),
count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_view,
count(distinct case when device_type = 'mobile' then website_session_id else null end)/count(distinct website_session_id)*100.0
as mcpt
from website_sessions
where utm_source in ('gsearch','bsearch') and created_at between '2012-08-22' and '2012-11-30' and
utm_campaign = 'nonbrand'
group by utm_source

-- search by different channel in given time period
select min(date(created_at)),
count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gsearch,
count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bsearch
from website_sessions
where created_at between '2012-08-22' and '2012-11-29'
and utm_campaign = 'nonbrand'
group by week(created_at),year(created_at)

-- session to order conversion
select website_sessions.utm_content,count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.website_session_id) as orders,
count(distinct orders.website_session_id)/count(distinct website_sessions.website_session_id)
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by website_sessions.utm_content
order by count(distinct website_sessions.website_session_id)  desc