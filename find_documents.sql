--Function: Queries all filenames from CM/ECF 
--RAW SQL query copied for reference
select document.dm_doi
   from  case,dktentry,document
      where "case".cs_caseid=dktentry.de_caseid
      and dktentry.de_doc_id=document.dm_id
      and "case".cs_year="13"
      and "case".cs_number="26132"
   UNION
   select porder.po_filename
    from  case,porder
    where porder.po_case_id="case".cs_caseid
    and "case".cs_year="13"
    and "case".cs_number="26132";

