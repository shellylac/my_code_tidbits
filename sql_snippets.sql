/*-----------------
padding remove test */
set autocommit on;
set role ukb_read;

DECLARE GLOBAL TEMPORARY TABLE event_small_temp
		AS
		SELECT eve_guid_k, pat_guid_k, eve_type_k, evecode_codesys_i, evecode_displayname_i, evecode_code_i,
               trans_codesys_i, trans_displayname_i, trans_code_i, disp_term_i,
               organisation_i, obs_numvalue_i, obs_numunit_i
		FROM emis_event_77
        WHERE eve_type_k not in ('MED', 'ISS') AND obs_numvalue_i NOT IN ('')  
        ON COMMIT PRESERVE ROWS
        WITH NORECOVERY;
\p\g

COPY TABLE event_small_temp
(eve_guid_k= text(0)csv, pat_guid_k= text(0)csv, 
 eve_type_k = text(0)csv, evecode_codesys_i = text(0)csv, evecode_displayname_i = text(0)csv, 
 evecode_code_i = text(0)csv, trans_codesys_i = text(0)csv, trans_displayname_i = text(0)csv,
 trans_code_i = text(0)csv, disp_term_i = text(0)csv, organisation_i = text(0)csv, 
 obs_numvalue_i = text(0)csv, obs_numunit_i = c0nl
)
         INTO 'test.csv';
\p\g


/*-----------------
case when example */
DECLARE GLOBAL TEMPORARY TABLE event_clinical_codes
		AS
		select codesystem_combined, code_combined, name_combined, obs_numvalue_i
        from (select 
            case when trans_code_i <> '' then trans_codesys_i else evecode_codesys_i end as codesystem_combined,
            case when trans_code_i <> '' then trans_code_i else evecode_code_i end as code_combined, 
            case when trans_code_i <> '' then trans_displayname_i else evecode_displayname_i end as name_combined,
            obs_numvalue_i
            from emis_event_clinical) b 
            where code_combined <> '' 
        ON COMMIT PRESERVE ROWS
        WITH NORECOVERY;
\p\g

COPY TABLE event_clinical_codes
(codesystem_combined =  text(0)tab, 
 code_combined =  text(0)tab,
 name_combined =  text(0)tab,
 obs_numvalue_i = text(0)nl 
)
         INTO 'clinical_codes_withvalues.tsv';
\p\g

/*-----------------
unique pids with 2 other values */
select * from emis_patient
where pseudo_id_i in 
(select pseudo_id_i from emis_patient group by pseudo_id_i having count(*) >1);

/*-----------------
create temp table from file */
DECLARE GLOBAL TEMPORARY TABLE c19res
(
id	INTEGER8	NOT NULL,
sex	VARCHAR(2)	NOT NULL,
dob	ANSIDATE	NOT NULL WITH DEFAULT,
inpat	INTEGER		NOT NULL WITH DEFAULT
)
ON COMMIT PRESERVE ROWS WITH NORECOVERY;

/*---- Load data, accept as strings initially and check types later */

COPY TABLE c19res
(
id	= text(0)comma,
sex	= text(0)comma,
dob	= text(0)comma,
inpat	= text(0)nl
)
FROM 'testres.csv';
\p\g

/*---- Delete where data types are not correct */
DELETE FROM c19res WHERE
	( sex <> 'M' AND sex <> 'F' )
	OR dob IS NOT DATE
	OR inpat IS NOT INTEGER
	
UPDATE c19res SET
	is_male = CASE
		WHEN sex = 'M' THEN 1
		WHEN sex = 'F' THEN 0
		END,
	dob = DATE(sdob),
	inpat = INTEGER(sinpat);
\p\g

/*------------------ 
Remove withdrawals -----*/
	/* IS_MALE SET TO -1 ON WITHDRAWAL */
DELETE FROM c19res r WHERE EXISTS
	( SELECT 1 FROM covid19_map m
		WHERE r.id = m.ext_id
		AND m.is_male NOT IN (0,1));
\p\g

/*------------------ 
Non ascii select -----*/
select atom, pid, unit from table where unit containing U&'\03bc';
select atom, pid, unit from table where length(unit) > 0 and not unit similar to '[[:ASCII:]]+';


/*------------------ 
strings containing characters  -----*/
string_1 LIKE '%ABC%@|%123%@|%xyz%' ESCAPE '@'
meaning CONTAINING '%COVID%@|%CORONAVIRUS%@|%nCoV%' ESCAPE '@' WITHOUT CASE

select count(distinct pid) from all_emis_gp_clinical 
where trans_displayname_i code CONTAINING '%COVID%@|%CORONAVIRUS%@|%nCoV%' ESCAPE '@' WITHOUT CASE;

/*------------------ 
Select most common value over group by -----*/

declare global temporary table stuff(
    code_type integer2,
    code char(6),
    meaning varchar(40)
);

insert into stuff values (3, 'X12545', 'Blood Test'),
(3, '545x12', 'Adverse reaction to 123'),
(3, '545x12', 'Adverse reaction to 123_extra'),
(3, '545x12', 'Adverse reaction to 123'),
(3, 'OLTR_23', 'TestRequest_12345'),
(3, 'OLTR_23', 'TestRequest_12346');

declare global temporary table extra_stuff as
    select code_type, code, meaning, count(1) as n 
    from stuff
    group by code_type, code, meaning
    order by code_type, code, meaning, n;

declare global temporary table stuff_with_rnum as
    select code_type, code, meaning, n,
        row_number() over (partition by code_type, code order by n desc) as rNum
    from extra_stuff
    order by code_type, code, meaning, n, rnum;

    select code_type, code, meaning
    from stuff_with_rnum
    where rnum = 1
    order by code_type, code, meaning;

/*------------------ 
Select minimum date for minimum levels -----*/

CREATE TABLE gtt (
    pid INT NOT NULL,
    event_date ANSIDATE NOT NULL,
    level INT NOT NULL)
\p\g

INSERT INTO gtt VALUES
('101', '03/01/2016', '1'),
('101', '02/07/2004', '1'),
('101', '02/09/2014', '1'),
('101', '02/09/2002', '2'),
('102', '02/07/2014', '1'),
('102', '02/07/2004', '2'),
('103', '02/05/2002', '2'),
('103', '02/05/2001', '2')
\p\g

DECLARE GLOBAL TEMPORARY TABLE min_dates_gtt AS
    SELECT x.pid, MIN(x.event_date) AS event_date, 
        level FROM (SELECT * FROM gtt) x
    GROUP BY x.pid, level
    ORDER BY x.pid
\p\g

/* Add row numbers to set row 1 equal to the row in which the level 1 appears */
DECLARE GLOBAL TEMPORARY TABLE rownums AS
SELECT pid, event_date, level,
    row_number() OVER (PARTITION BY pid ORDER BY level ASC) AS rnum
FROM min_dates_gtt
ORDER BY pid, event_date, level, rnum
ON COMMIT PRESERVE ROWS WITH NORECOVERY;
\p\g

/* select only those rows where rnum = 1 (i.e. level = 1 if exists and level=2 if not) */
select * from rownums where rnum = 1;
\p\g
