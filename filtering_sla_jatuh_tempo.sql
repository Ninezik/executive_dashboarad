WHERE DATE(n.custom_field__final_swp_date_new) 
      BETWEEN '2026-05-19' AND '2026-05-19'

    AND n.connote__connote_state NOT IN (
        'CANCEL',
        'PENDING'
    )

    AND n.connote__location_name != 'AGP TESTING LOCATION'

    AND n.connote__connote_service != 'LNINCOMING'

    AND n.connote__connote_service IN (
        'Q9',
        'PE',
        'PKH',
        'EC3'
    )

    AND n.customer_code NOT IN (
        'ASRPRUDEN04120A',
        'LNBAPENDA05651D',
        'BANKMANDIRI02110C',
        'BANKMANDIRI02110D',
        'INDHMS07603B',
        'KESGLOALKES02130A'
    )

    AND n.connote__connote_service NOT IN (
        '010',
        '3PE',
        '312',
        '311',
        '3LX',
        '331',
        '332',
        '3LP'
    )

    AND n.custom_field__deskripsi NOT IN (
        'Container',
        'Truck'
    )
