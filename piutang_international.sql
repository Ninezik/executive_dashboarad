SELECT 
	n.gl_account_number ,
	n.gl_account_text  ,
    n.customer_account, 
    UPPER(n.customer_account_name)customer_account_name,
    SUM(n.amount)  
FROM sap.sap_piutang n
where left(customer_account ,2)='13'
and id_pk!='bd49a1aa09a85d356a7a815e64476f36'
GROUP BY 1, 2,3,4
