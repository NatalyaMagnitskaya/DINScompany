#Total expenses for UID(pay for minute)

select payer, sum(time) as total_time, sum(expenses) as need_to_pay
 from ( (select call_logs.uid as payer,
 CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
 sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04) as expenses
 from call_logs
  left join call_forwarding
  on call_forwarding.from=call_logs.to
  where call_logs.to in (select call_forwarding.from from call_forwarding) and call_logs.call_dir='out'
  and call_forwarding.to not in (select phone_number from numbers) group by call_logs.uid )
  union all ( select call_logs.uid as payer, CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end,
  call_logs.timestamp_start))/60) as time,sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end,
  call_logs.timestamp_start))/60) *0.04) as expenses from call_logs where call_logs.to not in
  (select call_forwarding.from
      from call_forwarding)
  and call_logs.call_dir='out' and call_logs.to
not in (select phone_number from numbers) group by call_logs.uid)) as tmp group by payer ;

#Top 10: Most active users

select c.uid from call_logs c group by c.uid order by count(c.call_id) DESC limit 10;

#with the same number of calls (with ties)

select c.uid from call_logs c
where count(c.call_id) in (select count(b.call_id)
from call_logs c group by b.uid order by count(b.call_id) DESC limit 10)
group by c.uid order by count(c.call_id) DESC

#Top 10: Users with highest charges, and daily distribution for each of them

select call_logs.uid as payer, call_logs.timestamp_start as start, call_logs.timestamp_end as end,
date(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start)) as day,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04 as expenses
from call_logs left join call_forwarding on call_forwarding.from=call_logs.to
where call_logs.to in (select call_forwarding.from from call_forwarding) and call_logs.call_dir='out'
and call_forwarding.to not in (select phone_number from numbers)
and call_logs.uid in (select payer from ((select call_logs.uid as payer,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04) as expenses
from call_logs left join call_forwarding on call_forwarding.from=call_logs.to where call_logs.to
in (select call_forwarding.from from call_forwarding) and call_logs.call_dir='out' and call_forwarding.to
not in (select phone_number from numbers) group by call_logs.uid ) union all ( select call_logs.uid as payer,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04) as expenses
from call_logs where call_logs.to not in (select call_forwarding.from from call_forwarding)
and call_logs.call_dir='out' and call_logs.to not in (select phone_number from numbers)
group by call_logs.uid)) as tmp group by payer order by sum(expenses) limit 10) union all
select call_logs.uid as payer, call_logs.timestamp_start as start, call_logs.timestamp_end as end,
date(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start)) as day,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04 as expenses from call_logs
where call_logs.to not in (select call_forwarding.from from call_forwarding) and call_logs.call_dir='out'
and call_logs.uid in (select payer from ((select call_logs.uid as payer,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04) as expenses
from call_logs left join call_forwarding on call_forwarding.from=call_logs.to where call_logs.to in
(select call_forwarding.from from call_forwarding) and call_logs.call_dir='out' and
call_forwarding.to not in (select phone_number from numbers) group by call_logs.uid )
union all ( select call_logs.uid as payer,
CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) as time,
sum(CEIL(TIME_TO_SEC(TIMEDIFF(call_logs.timestamp_end, call_logs.timestamp_start))/60) *0.04) as expenses
from call_logs where call_logs.to not in (select call_forwarding.from from call_forwarding)
and call_logs.call_dir='out' and call_logs.to not in (select phone_number from numbers) group by call_logs.uid)) as tmp
group by payer order by sum(expenses) limit 10)