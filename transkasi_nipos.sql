select
DATE(connote__created_at) as connote__created_at,
UPPER(customer_code) as customer_code,
location_data_created__custom_field__nokprk,
UPPER(transform__channel)transform__channel,
UPPER(connote__connote_service) as connote__connote_service,
COUNT(connote__connote_code)connote__connote_code,
SUM(coalesce(connote__connote_service_price,0) + coalesce(connote__connote_surcharge_amount,0))pendapatan,
SUM(
    CASE 
        WHEN UPPER(customer_code) = 'DAGSHOPEE04120A'
         AND UPPER(custom_field__cod) != 'NONCOD'
        THEN COALESCE(t2.good_value, 0) * 0.005
        ELSE COALESCE(np.custom_field__fee_value, 0)
    END
) AS fee_cod
from
nipos.nipos np
left join
(
select
distinct resi,
good_value
from
nipos.webhook_marketplace wm
where
wm.member_id = 'DAGSHOPEE04120A')t2
on
np.connote__connote_booking_code = t2.resi
where
UPPER(connote__location_name) != 'AGP TESTING LOCATION'
and connote__connote_amount >= 0
and np.connote__connote_service != 'LNINCOMING'
and UPPER(connote__connote_state) not in ('CANCEL', 'PENDING')
and np.connote__created_at >'20260531'
and np.connote__created_at <'20260602'
group by
1,
2,
3,
4,
5
