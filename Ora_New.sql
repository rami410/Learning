Bulk Processing In Oracle
The bulk processing features of PL/SQL are designed specifically to reduce the number of context switches required to communicate from the PL/SQL engine to the SQL engine.
Use the BULK COLLECT clause to fetch multiple rows into one or more collections with a single context switch.

•	BULK COLLECT: SELECT statements that retrieve multiple rows with a single fetch, improving the speed of data retrieval
•	FORALL: INSERTs, UPDATEs, and DELETEs that use collections to change multiple rows of data very quickly
The FORALL statement is not a loop; it is a declarative statement to the PL/SQL engine: “Generate all the DML statements that would have been executed one row at a time, and send them all across to the SQL engine with one context switch.”
Each FORALL statement may contain just a single DML statement. If your loop contains two updates and a delete, then you will need to write three FORALL statements
When using the IN low_value . . . high_value syntax in the FORALL header, the collections referenced inside the FORALL statement must be densely filled. That is, every index value between the low_value and high_value must be defined.
If your collection is not densely filled, you should use the INDICES OF or VALUES OF syntax in your FORALL header.

FORALL and DML Errors
Suppose that I’ve written a program that is supposed to insert 10,000 rows into a table. After inserting 9,000 of those rows, the 9,001st insert fails with a DUP_VAL_ON_INDEX error (a unique index violation). The SQL engine passes that error back to the PL/SQL engine, and if the FORALL statement is written like the one in Listing 4, PL/SQL will terminate the FORALL statement. The remaining 999 rows will not be inserted.
If you want the PL/SQL engine to execute as many of the DML statements as possible, even if errors are raised along the way, add the SAVE EXCEPTIONS clause to the FORALL header. Then, if the SQL engine raises an error, the PL/SQL engine will save that information in a pseudocollection named SQL%BULK_EXCEPTIONS, and continue executing statements. When all statements have been attempted, PL/SQL then raises the ORA-24381 error.
You can—and should—trap that error in the exception section and then iterate through the contents of SQL%BULK_EXCEPTIONS to find out which errors have occurred. You can then write error information to a log table and/or attempt recovery of the DML statement.
Listing 7 contains an example of using SAVE EXCEPTIONS in a FORALL statement; in this case, I simply display on the screen the index in the l_eligible_ids collection on which the error occurred, and the error code that was raised by the SQL engine.
Code Listing 7: Using SAVE EXCEPTIONS with FORALL
BEGIN
   FORALL indx IN 1 .. l_eligible_ids.COUNT SAVE EXCEPTIONS
      UPDATE employees emp
         SET emp.salary =
                emp.salary + emp.salary * increase_pct_in
       WHERE emp.employee_id = l_eligible_ids (indx);
EXCEPTION
   WHEN OTHERS
   THEN
      IF SQLCODE = -24381
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            DBMS_OUTPUT.put_line (
                  SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
               || ‘: ‘
               || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
      ELSE
         RAISE;
      END IF;
END increase_salary;

FORALL with Sparse Collections
If you try to use the IN low_value .. high_value syntax with FORALL and there is an undefined index value within that range, Oracle Database will raise the “ORA-22160: element at index [N] does not exist” error.
To avoid this error, you can use the INDICES OF or VALUES OF clauses. To see how these clauses can be used, let’s go back to the code in Listing 4. In this version of increase_salary, I declare a second collection, l_eligible_ids, to hold the IDs of those employees who are eligible for a raise.
Instead of doing that, I can simply remove all ineligible IDs from the l_employee_ids collection, as follows:
   FOR indx IN 1 .. l_employee_ids.COUNT
   LOOP
      check_eligibility (l_employee_ids (indx),
                         increase_pct_in,
                         l_eligible);

      IF NOT l_eligible
      THEN
         l_employee_ids.delete (indx);
      END IF;
   END LOOP;
But now my l_employee_ids collection may have gaps in it: index values that are undefined between 1 and the highest index value populated by the BULK COLLECT.
No worries. I will simply change my FORALL statement to the following:
FORALL indx IN INDICES OF l_employee_ids
   UPDATE employees emp
      SET emp.salary =
               emp.salary
             + emp.salary * 
                increase_salary.increase_pct_in
    WHERE emp.employee_id = 
      l_employee_ids (indx);
Now I am telling the PL/SQL engine to use only those index values that are defined in l_employee_ids, rather than specifying a fixed range of values. Oracle Database will simply skip any undefined index values, and the ORA-22160 error will not be raised.
Records
A record is a composite datatype, which means that it can hold more than one piece of information, as compared to a scalar datatype, such as a number or string. It’s rare, in fact, that the data with which you are working is just a single value, so records and other composite datatypes are likely to figure prominently in your PL/SQL programs.
INSERT
     INTO omag_employees 
   VALUES l_employee; -- it is record
UPDATE omag_employees
     SET ROW = l_employee  -- it is record
   WHERE employee_id = 100;



Collecetions
These are one dimensional arrays (which stores similar type of data)
Associative array. The first type of collection available in PL/SQL, this was originally called a “PL/SQL table” and can be used only in PL/SQL blocks. Associative arrays can be sparse or dense and can be indexed by integer or string
Nested table. Added in Oracle8 Database, the nested table can be used in PL/SQL blocks, in SQL statements, and as the datatype of columns in tables. Nested tables can be sparse but are almost always dense. They can be indexed only by integer. You can use the MULTISET operator to perform set operations and to perform equality comparisons on nested tables.
Varray. Added in Oracle8 Database, the varray (variable-size array) can be used in PL/SQL blocks, in SQL statements, and as the datatype of columns in tables. Varrays are always dense and indexed by integer. When a varray type is defined, you must specify the maximum number of elements allowed in a collection declared with that type.
You will rarely encounter a need for a varray (How many times do you know in advance the maximum number of elements you will define in your collection?). The associative array is the most commonly used collection type, but nested tables have some powerful, unique features (such as MULTISET operators) that can simplify the code you need to write to use your collection

•	If the TYPE statement contains an INDEX BY clause, the collection type is an associative array.
•	If the TYPE statement contains the VARRAY keyword, the collection type is a varray.
•	If the TYPE statement does not contain an INDEX BY clause or a VARRAY keyword, the collection type is a nested table.
•	Only the associative array offers a choice of indexing datatypes. Nested tables as well as varrays are always indexed by integer.
•	When you define a varray type, you specify the maximum number of elements that can be defined in a collection of that type.
•	Here is an example of initializing a nested table of numbers with three elements (1, 2, and 3):
•	DECLARE
•	   TYPE numbers_nt IS TABLE OF NUMBER; 
•	   l_numbers numbers_nt;
•	BEGIN
•	   l_numbers := numbers_nt (1, 2, 3);
•	END;
•	If you neglect to initialize your collection, Oracle Database will raise an error when you try to use that collection:
•	SQL> DECLARE
•	  2    TYPE numbers_nt IS TABLE OF NUMBER;
•	  3    l_numbers numbers_nt;
•	  4  BEGIN
•	  5    l_numbers.EXTEND;
•	  6    l_numbers(1) := 1;
•	  7  END;
•	  8  /
•	DECLARE
•	*
•	ERROR at line 1:
•	ORA-06531: Reference to uninitialized collection
•	ORA-06512: at line 5
Populating Collections
You can assign values to elements in a collection in a variety of ways:
•	Call a constructor function (for nested tables and varrays).
•	Use the assignment operator, for single elements as well as entire collections.
•	Pass the collection to a subprogram as an OUT or IN OUT parameter, and then assign the value inside the subprogram.
•	Use a BULK COLLECT query.
Deleting Collection Elements
PL/SQL offers a DELETE method, which you can use to remove all, one, or some elements from a collection. Here are some examples:
1.	Remove all elements from a collection; use the DELETE method without any arguments. This form of DELETE works with all three kinds of collections.
l_names.DELETE;
2.	Remove the first element in a collection; to remove one element, pass the index value to DELETE. This form of DELETE can be used only with an associative array or a nested table.
l_names.DELETE (l_names.FIRST);
3.	Remove all the elements between the specified low and high index values. This form of DELETE can be used only with an associative array or a nested table.
l_names.DELETE (100, 200);
If you specify an undefined index value, Oracle Database will not raise an error.


You can also use the TRIM method with varrays and nested tables to remove elements from the end of the collection. You can trim one or many elements:
l_names.TRIM;
l_names.TRIM (3);


Data Dictionary
Most data dictionary views come in three versions:
1.	The USER view: information about database objects owned by the schema to which you are connected
2.	The ALL view: information about database objects to which the currently connected schema has access
3.	The DBA view: unrestricted information about all the database objects in a database instance (non-DBA schemas usually have no authority to query DBA views)


The following query returns all the objects defined in my schema:
SELECT * FROM user_objects
This query returns all the objects that are defined in my schema or for which I have been granted the privilege to use those objects in some way:
SELECT * FROM all_objects
Finally, the following query returns a list of all the objects defined in the database instance—if I have the authority to select from the view:
SELECT * FROM dba_objects
Usually the only difference between the USER view and the ALL view is that the latter contains one extra column, OWNER, that shows which schema owns the object.

Display and Search Source Code
All the program unit source code you’ve compiled into the database is accessible through the USER_SOURCE view, whose columns are
•	NAME: Name of the object
•	TYPE: Type of the object (ranging from PL/SQL program units to Java source and trigger source)
•	LINE: Number of the line of the source code
•	TEXT: Text of the source code

USER_ARGUMENTS
USER_DEPENDENCIES
USER_IDENTIFIERS
Export and Import utilities
CONN / AS SYSDBA
ALTER USER scott IDENTIFIED BY tiger ACCOUNT UNLOCK;

CREATE OR REPLACE DIRECTORY test_dir AS '/u01/app/oracle/oradata/';
GRANT READ, WRITE ON DIRECTORY test_dir TO scott;



expdp scott/tiger@db10g tables=EMP,DEPT directory=TEST_DIR dumpfile=EMP_DEPT.dmp logfile=expdpEMP_DEPT.log

impdp scott/tiger@db10g tables=EMP,DEPT directory=TEST_DIR dumpfile=EMP_DEPT.dmp logfile=impdpEMP_DEPT.log
Schema Exports/Imports
The OWNER parameter of exp has been replaced by the SCHEMAS parameter which is used to specify the schemas to be exported. The following is an example of the schema export and import syntax.
expdp scott/tiger@db10g schemas=SCOTT directory=TEST_DIR dumpfile=SCOTT.dmp logfile=expdpSCOTT.log

impdp scott/tiger@db10g schemas=SCOTT directory=TEST_DIR dumpfile=SCOTT.dmp logfile=impdpSCOTT.log
Database Exports/Imports
The FULL parameter indicates that a complete database export is required. The following is an example of the full database export and import syntax.
expdp system/password@db10g full=Y directory=TEST_DIR dumpfile=DB10G.dmp logfile=expdpDB10G.log

impdp system/password@db10g full=Y directory=TEST_DIR dumpfile=DB10G.dmp logfile=impdpDB10G.log
INCLUDE and EXCLUDE
The INCLUDE and EXCLUDE parameters can be used to limit the export/import to specific objects. When the INCLUDE parameter is used, only those objects specified by it will be included in the export/import. When the EXCLUDE parameter is used, all objects except those specified by it will be included in the export/import. The two parameters are mutually exclusive, so use the parameter that requires the least entries to give you the result you require. The basic syntax for both parameters is the same.
INCLUDE=object_type[:name_clause] [, ...]
EXCLUDE=object_type[:name_clause] [, ...]
The following code shows how they can be used as command line parameters.
expdp scott/tiger@db10g schemas=SCOTT include=TABLE:"IN ('EMP', 'DEPT')" directory=TEST_DIR dumpfile=SCOTT.dmp logfile=expdpSCOTT.log

expdp scott/tiger@db10g schemas=SCOTT exclude=TABLE:"= 'BONUS'" directory=TEST_DIR dumpfile=SCOTT.dmp logfile=expdpSCOTT.log
CONTENT and QUERY
The CONTENT parameter allows you to alter the contents of the export. The following command uses the METADATA_ONLY parameter value to export the contents of the schema without the data.
expdp system/password@db10g schemas=SCOTT directory=TEST_DIR dumpfile=scott_meta.dmp logfile=expdp.log content=METADATA_ONLY
To capture the data without the metadata use the DATA_ONLY parameter value.
expdp system/password@db10g schemas=SCOTT directory=TEST_DIR dumpfile=scott_data.dmp logfile=expdp.log content=DATA_ONLY
The QUERY parameter allows you to alter the rows exported from one or more tables. The following example does a full database export, but doesn't include the data for the EMP and DEPT tables.
expdp system/password@db10g full=Y directory=TEST_DIR dumpfile=full.dmp logfile=expdp_full.log query='SCOTT.EMP:"WHERE deptno=0",SCOTT.DEPT:"WHERE deptno=0"'

Parent – Child ;RI
When deleting large volumes of data from parent.. for each row it checks in child for RI(full scan ) .
If we create indexes on FK of child it will be faster
Basic Hierarchical Query
In its simplest form a hierarchical query needs a definition of how each child relates to its parent. This is defined using the CONNECT BY .. PRIOR clause, which defines how the current row (child) relates to a prior row (parent). In addition, the START WITH clause can be used to define the root node(s) of the hierarchy. Hierarchical queries come with operators, pseudocolumns and functions to help make sense of the hierarchy.
•	LEVEL : The position in the hierarchy of the current row in relation to the root node.
•	CONNECT_BY_ROOT : Returns the root node(s) associated with the current row.
•	SYS_CONNECT_BY_PATH : Returns a delimited breadcrumb from root to the current row.
•	CONNECT_BY_ISLEAF : Indicates if the current row is a leaf node.
•	ORDER SIBLINGS BY : Applies an order to siblings, without altering the basic hierarchical structure of the data returned by the query.
The ORDER SIBLINGS BY clause is valid only in a hierarchical query. The optional SIBLINGS keyword specifies an order that first sorts the parent rows, and then sorts the child rows of each parent for every level within the hierarchy.
Rows that have duplicate lists of values in the columns specified after the SIBLINGS BY keywords are arbitrarily ordered among the rows with the same list of values and the same parent. If a hierarchical query includes the ORDER BY clause without the SIBLINGS keyword, rows are ordered according to the sort specifications that follow the ORDER BY keywords. Neither the ORDER BY clause nor the ORDER SIBLINGS BY option to the ORDER BY clause is required in hierarchical queries.
The hierarchical query in the following example returns the subset of rows in the hierarchical data set whose root is Goyal, as listed in the topic Hierarchical Clause. This query includes the ORDER SIBLINGS BY clause to sort by name the employees who report to the same manager:
SELECT empid, name, mgrid, LEVEL
   FROM employee
      START WITH name = 'Goyal'
      CONNECT BY PRIOR empid = mgrid
   ORDER SIBLINGS BY name; 
The rows returned by this query are sorted in the following order:
         empid name             mgrid       level 

         16 Goyal               17           1
         12 Henry               16           2
          7 O'Neil              12           3
          9 Shoeman             12           3
          8 Smith               12           3
         14 Scott               16           2
         11 Zander              16           2
          6 Barnes              11           3
          5 McKeough            11           3

9 row(s) retrieved. 
Here the START WITH clause returned the Goyal row at the root of this hierarchy. Two subsequent CONNECT BY steps (marked as 2 and 3 in the levelpseudocolumn) returned three sets of sibling rows:
•	Henry, Scott, and Zander are siblings whose parent is Goyal;
•	O'Neil, Shoeman, and Smith are siblings whose parent is Henry;
•	Barnes and McKeough are siblings whose parent is Zander.
The next CONNECT BY step returned no rows, because the rows for which level = 3 are leaf nodes within this hierarchy. At this point in the execution of the query, the ORDER SIBLINGS BY clause was applied to the result set, sorting the rows in the order shown above.

Question:  I want to know how to find the session that is holding an Oracle table lock and how to remove the lock.  Is there a script to identify the session that is holding an Oracle table row lock?
Answer:  Yes, you can query the dba_dml_locks view with the name of the Oracle table to get the system ID.  Also see these notes on row level contention and locks.
STEP 1:  To identify the SID for the table with the lock, you will use this system ID in a later query to get the serial number for the table row lock:
select 
   session_id
from 
   dba_dml_locks
where 
   name = 'EMP';

Output :
SID
___
607

STEP 2:  The next step is a script to find the Serial# for the table row lock :
select 
   sid,
   serial#
from 
   v$session
where 
   sid in (
   select 
      session_id
   from 
      dba_dml_locks
   where 
      name = 'EMP');
Output :
SID SERIAL#
---- -------
607 1402

SELECT object_id FROM dba_objects WHERE object_name='EMP';
 OBJECT_ID
----------
   7401242

 SELECT sid FROM v$lock WHERE id1=7401242
SID
----------
   3434

STEP 3:  Finally, we can use the "alter system" command to kill the session that is holding the table lock:
alter system kill session 'SID,SERIALl#';
alter system kill session '607,1402';
select a.username us, a.osuser os, a.sid, a.serial# 
from v$session a, v$locked_object b, dba_objects c 
where upper(c.object_name) = upper('&tbl_name') 
and b.object_id = c.object_id 
and a.sid = b.session_id;






Performance Tips:
ACTIVITY 
Question:  What is the idea of an automous transaction in PL/SQL?  I understand that there is the pragma automous transaction but I am unclear about when to use automous transactions. 
Answer:  Autonomous transactions are used when you wan to roll-back some code while continuing to process an error logging procedure.
The term "automous transaction" refers to the ability of PL/SQL temporarily suspend the current transaction and begin another, fully independent transaction (which will not be rolled-back if the outer code aborts).  The second transaction is known as an autonomous transaction. The autonomous transaction functions independently from the parent code.
An autonomous transaction has the following characteristics:
 
There are many times when you might want to use an autonomous transaction to commit or roll back some changes to a table independently of a primary transaction's final outcome.
We use a compiler directive in PL/SQL (called a pragma) to tell Oracle that our transaction is autonomous. An autonomous transaction executes within an autonomous scope. The PL/SQL compiler is instructed to mark a routine as autonomous (i.e. independent) by the AUTONMOUS_TRANSACTIONS pragma from the calling code.
As an example of autonomous transactions, let's assume that you need to log errors into a Oracle database log table. You need to roll back the core transaction because of the resulting error, but you don't want the error log code to rollback.  Here is an example of a PL/SQL error log table used as an automous transaction:
 
 
 
As we can see, the error is logged in the autonomous transaction, but the main transaction is rolled 


Partitions
1.	Range Partition
Key Points:
•	PARTITION BY RANGE
The keyword that defines that a table is partitioned is PARTITION BY which follows the normal table column definitions. The clause BY RANGE nominates the type of partitioning scheme that the table will use.
•	Exclusive Upper Bound
Range partitions are not given lower and upper bounds, only an upper bound. The lower bound is implicitly defined as the upper bound of the previous partition. A partition can contain values up to but not including the value nominated in the VALUES LESS THAN clause.
•	At Least 1 Partition
After the PARTITION BY clause, at least one partition must always be defined.
•	USER_TAB_PARTITIONS
The data dictionary tracks all of the defined partitions for a table. USER_TAB_PARTITIONS displays one row per defined partition for each partitioned table in your schema.
•	Partition Pruning
If the optimizer can eliminate partitions from consideration, query performance can be dramatically improved. In later videos, you will see how you can interpret the optimizer execution plan output to determine if partition elimination will occur for a given SQL query.
•	Index Reduction
In some circumstances, partitioning a table allows for existing indexes to be consolidated or dropped, which can reduce overall database size, and improve insert, update and delete performance.
	Incase of Multi column it works like tie breaker i.e when first column alone not able to decide which partition it should go then next column come to risk
2.	Hash Partitioning
Key Points:
•	Power of 2
For equi-sized partitions, the number of partitions must be a power of 2.
•	ORA_HASH
The hashing algorithm is not documented but the ORA_HASH function is observed to return results consistent with the data segmentation that occurs with hash partitioning.
•	Splitting
A partition can be split using the ALTER TABLE SPLIT PARTITION command, which is a task normally done by the Database Administrator. Spliting a partition is a resource heavy activity as potentially an entire partition's worth of data will be moved.
 
3.	List Partitioning
Range partitioning, as the name suggests, is about carving up data that is analog in nature, that is, a continuous range of values. This is why dates are a natural candidate for a range-based partitioning scheme.
Key Points:
•	One or more values
A single partition can contain one or more discrete values.
•	DEFAULT
A "catch all" partition can be defined using the DEFAULT clause in the VALUES statement. Nulls also go into this partition.
•	Partition Query Syntax
A DML statement can explictly nominate a partition in a table to act upon using the PARTITION clause following the table name.

Partitions of Partitions

Interval Partitions
For incoming data, a partition must already exist that the incoming partitioning key would map to. If a partition does not exist, transactions will fail with ORA-14400. In earlier versions of Oracle Database, this meant that administrators had to take extreme care to ensure that partitions for future data were defined or risk application outages. Interval partitioning (introduced in Oracle Database 11g) removes this risk by automatically creating new partitions on a partitioned table as required when new data arrives.
We can query from partition name only. 
Select * from table partition for (DATE ‘2012-01-01’)

Key Points:
•	Automatic names
As partitions are dynamically created, system generated names are assigned to the new partitions. They can be renamed to meet existing business standards.
•	Gaps allowed
Partitions are fixed in partitition key range size, namely the size of the interval. Unlike range partitions, the upper and lower bounds are defined by the interval, not the adjoining partitions.
•	FOR syntax
If the name of an interval partition is not known, it can be referenced using the FOR ( key-value ) syntax.
Converting to Interval Partitions
Key Points:
•	Conversion
Simply specifying the desired interval via ALTER TABLE ... SET INTERVAL converts a range partitioned table to an interval partitioned one.
•	Hybrid partitions
On a converted table, the INTERVAL column on USER_TAB_PARTITIONS indicates whether each partition is a range or interval partition.
•	Minimum Range Boundary
At least one range partition must remain in the table. Before Oracle Database 12c Release 2, re-running the SET INTERVAL command will mark existing interval partitions as range 



Pivot
Select * from table
Pivot  (sum(calories) for  day_col in (‘SUN’,’MON’,’TUE’….));
Without Pivot
Select week,
Sum(case when day_col=’sun’ then calories end) sunday_cal,
Sum(case when day_col=’sun’ then calories end) sunday_cal,
…
From table group by week.
Unpivot
Select * from table
unPivot  ( calories for  day_col  in (‘SUN’,’MON’,’TUE’….));

Without Unpivot
Select col1 
Union
Select co2;
	
Hierachal Queries
Archiving using Partitions will be better

Example 9-9 EXPLAIN PLAN example_plan4
EXPLAIN PLAN SET statement_id = 'example_plan4' FOR
SELECT h.order_number, l.revenue_amount, l.ordered_quantity
  FROM so_headers_all h, so_lines_all l
 WHERE h.customer_id = :b1
   AND h.date_ordered > SYSDATE-30
   AND l.header_id = h.header_id ;

Plan
--------------------------------------------------
SELECT STATEMENT
 NESTED LOOPS
  TABLE ACCESS BY INDEX ROWID SO_HEADERS_ALL
   INDEX RANGE SCAN SO_HEADERS_N1
  TABLE ACCESS BY INDEX ROWID SO_LINES_ALL
   INDEX RANGE SCAN SO_LINES_N1

This plan shows execution of a SELECT statement.
•	Index so_headers_n1 is used in a range scan operation. This is an index on customer_id. The range scan happens using the following condition:
•	customer_id = :b1
•	
•	The table so_headers_all is accessed through ROWIDs obtained from the index in the previous step. When the table is accessed, any additional WHERE clause conditions that could not be evaluated during the range scan (because the column is present in the table and not in the index) are also evaluated. Therefore, the following condition is evaluated at this stage:
•	h.date_ordered > sysdate-30
•	
•	For every row from so_headers_all satisfying the WHERE clause conditions, a range scan is run on so_lines_n1 using the following condition:
•	l.header_id = h.header_id
•	
•	The table so_lines_all is accessed through ROWIDs obtained from the index in the previous step. When the table is accessed, any additional WHERE clause conditions that could not be evaluated during the range scan (because the column is present in the table and not in the index) are also evaluated. There are no additional conditions to evaluate here.
•	The SELECT statement returns rows satisfying the WHERE clause conditions (evaluated in previous steps).
Viewing Partitioned Objects with EXPLAIN PLAN
Use EXPLAIN PLAN to see how Oracle accesses partitioned objects for specific queries.
Partitions accessed after pruning are shown in the PARTITION START and PARTITION STOP columns. The row source name for the range partition is PARTITION RANGE. For hash partitions, the row source name is PARTITION HASH.
A join is implemented using partial partition-wise join if the DISTRIBUTION column of the plan table of one of the joined tables contains PARTITION(KEY). Partial partition-wise join is possible if one of the joined tables is partitioned on its join column and the table is parallelized.
A join is implemented using full partition-wise join if the partition row source appears before the join row source in the EXPLAIN PLAN output. Full partition-wise joins are possible only if both joined tables are equi-partitioned on their respective join columns. Examples of execution plans for several types of partitioning follow.
Examples of Displaying Range and Hash Partitioning with EXPLAIN PLAN
Consider the following table, emp_range, partitioned by range on hire_date to illustrate how pruning is displayed. Assume that the tables emp and dept from a standard Oracle schema exist.
CREATE TABLE emp_range 
PARTITION BY RANGE(hire_date) 
( 
PARTITION emp_p1 VALUES LESS THAN (TO_DATE('1-JAN-1991','DD-MON-YYYY')),
PARTITION emp_p2 VALUES LESS THAN (TO_DATE('1-JAN-1993','DD-MON-YYYY')),
PARTITION emp_p3 VALUES LESS THAN (TO_DATE('1-JAN-1995','DD-MON-YYYY')),
PARTITION emp_p4 VALUES LESS THAN (TO_DATE('1-JAN-1997','DD-MON-YYYY')),
PARTITION emp_p5 VALUES LESS THAN (TO_DATE('1-JAN-1999','DD-MON-YYYY')) 
) AS SELECT * FROM employees;
For the first example, consider the following statement:
EXPLAIN PLAN FOR SELECT * FROM emp_range; 

Enter the following to display the EXPLAIN PLAN output:
@?/RDBMS/ADMIN/UTLXPLS 

Oracle displays something similar to the following:
Plan Table 
-------------------------------------------------------------------------------
| Operation               |  Name    |  Rows | Bytes|  Cost  | Pstart |  Pstop|
-------------------------------------------------------------------------------
| SELECT STATEMENT        |          |   105 |    8K|      1 |        |       |
|  PARTITION RANGE ALL    |          |       |      |        |     1  |     5 |
|   TABLE ACCESS FULL     |EMP_RANGE |   105 |    8K|      1 |     1  |     5 |
-------------------------------------------------------------------------------
6 rows selected. 
A partition row source is created on top of the table access row source. It iterates over the set of partitions to be accessed. In this example, the partition iterator covers all partitions (option ALL), because a predicate was not used for pruning. The PARTITION_START and PARTITION_STOP columns of the PLAN_TABLE show access to all partitions from 1 to 5.
For the next example, consider the following statement:
EXPLAIN PLAN FOR SELECT * FROM emp_range 
WHERE hire_date >= TO_DATE('1-JAN-1995','DD-MON-YYYY'); 

Plan Table 
--------------------------------------------------------------------------------
| Operation                 | Name    |  Rows  | Bytes|  Cost  | Pstart| Pstop |
--------------------------------------------------------------------------------
| SELECT STATEMENT          |          |     3 |   54 |      1 |       |       |
|  PARTITION RANGE ITERATOR |          |       |      |        |     4 |     5 |
|   TABLE ACCESS FULL       |EMP_RANGE |     3 |   54 |      1 |     4 |     5 |
--------------------------------------------------------------------------------
6 rows selected. 

In the previous example, the partition row source iterates from partition 4 to 5, because we prune the other partitions using a predicate on hire_date.
Finally, consider the following statement:
EXPLAIN PLAN FOR SELECT * FROM emp_range 
WHERE hire_date < TO_DATE('1-JAN-1991','DD-MON-YYYY'); 

Plan Table 
--------------------------------------------------------------------------------
| Operation                 |  Name    |  Rows | Bytes|  Cost  | Pstart| Pstop |
--------------------------------------------------------------------------------
| SELECT STATEMENT          |          |     2 |   36 |      1 |       |       |
|  TABLE ACCESS FULL        |EMP_RANGE |     2 |   36 |      1 |     1 |     1 |
--------------------------------------------------------------------------------
5 rows selected. 

In the previous example, only partition 1 is accessed and known at compile time; thus, there is no need for a partition row source.
Examples of Full Partition-wise Joins
In the following example, emp_comp and dept_hash are joined on their hash partitioning columns. This enables use of full partition-wise join. The PARTITION HASH row source appears on top of the join row source in the plan table output.
To create the table dept_hash, enter:
CREATE TABLE dept_hash 
PARTITION BY HASH(deptno) 
PARTITIONS 3 
PARALLEL 
AS SELECT * FROM dept; 
To show the plan for the query, enter:
EXPLAIN PLAN FOR SELECT /*+ ORDERED USE_HASH(D) */ ename, dname 
FROM emp_comp e, dept_hash d 
WHERE e.deptno = d.deptno 
AND e.hiredate > TO_DATE('29-JUN-1996','DD-MON-YYYY'); 
Plan Table 
------------------------------------------------------------------------------------------------------------ 
| Operation                   |  Name    |  Rows | Bytes|  Cost  |  TQ |IN-OUT| PQ Distrib | Pstart| Pstop | 
------------------------------------------------------------------------------------------------------------ 
| SELECT STATEMENT            |          |     2 |   102|      2 |     |      |            |       |       |
|  PARTITION HASH ALL         |          |       |      |        | 4,00| PCWP |            |     1 |     3 | 
|   HASH JOIN                 |          |     2 |  102 |      2 | 4,00| P->S | QC (RANDOM)|       |       | 
|    PARTITION RANGE ITERATOR |          |       |      |        | 4,00| PCWP |            |     4 |     5 | 
|     TABLE ACCESS FULL       |EMP_COMP  |     3 |   87 |      1 | 4,00| PCWP |            |    10 |    15 | 
|    TABLE ACCESS FULL        |DEPT_HASH |    63 |    1K|      1 | 4,00| PCWP |            |     1 |     3 | 
------------------------------------------------------------------------------------------------------------ 
9 rows selected. 

PL SQL TABLE Functions
	Always return collections
	Select column_name as col from table(tblfn(5));
	Collections and table functions  should be known to SQL( defined at schema level).. colelctions defined in local pl sql ,pkgs are not unidentified by table functions
1.	Return multiple columns
We need to crate an object type and create collection of that object type
We can use attributes of object type in column list
We can do select * from table(table_fn());
2.	Streamlines table functions
3.	Pipelined table functions


Indexes
 
he figure highlights a branch node and the leaf nodes it refers to. Each branch node entry corresponds to the biggest value in the respective leaf node. Take the first leaf node as an example: the biggest value in this node is 46, which is thus stored in the corresponding branch node entry. The same is true for the other leaf nodes so that in the end the branch node has the values 46, 53, 57 and 83. According to this scheme, a branch layer is built up until all the leaf nodes are covered by a branch node.
 
Figure 1.3 shows an index fragment to illustrate a search for the key “57”. The tree traversal starts at the root node on the left-hand side. Each entry is processed in ascending order until a value is greater than or equal to (>=) the search term (57). In the figure it is the entry 83. The database follows the reference to the corresponding branch node and repeats the procedure until the tree traversal reaches a leaf node.
Even though the database creates the index for the primary key automatically, there is still room for manual refinements if the key consists of multiple columns. In that case the database creates an index on all primary key columns—a so-called concatenated index (also known as multi-column, composite or combined index). Note that the column order of a concatenated index has great impact on its usability so it must be chosen carefully.





Kill My Session:
create or replace
procedure kill_my_session ( sid_v in number, serial in number ) as
run_by varchar2(32);
sess_user varchar2(32);
inst  number;
my_machine varchar2(32);
sess_machine varchar2(32);
begin
SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER') , SYS_CONTEXT ('USERENV', 'HOST')
   into run_by , my_machine FROM DUAL;
   begin
   select username ,inst_id,machine into sess_user,inst,sess_machine from gv$session where sid=sid_v and serial#= serial;
   exception when no_data_found then
   dbms_output.put_line('no session like that in db');
   end;
  dbms_output.put_line('the procedure got executed by '||run_by||'-'||my_machine||' and sid,serial is from '||sess_user||'-'||sess_machine||' instance '||inst);
   if (run_by=sess_user) and (my_machine=sess_machine) then
     dbms_output.put_line('they are the same user');
     begin
     execute immediate 'alter system kill session '''||sid_v||','||serial||',@'||inst||'''';
     dbms_output.put_line(' successful in executing alter system kill session '''||sid_v||','||serial||',@'||inst||''';');
     exception when others then
     dbms_output.put_line(' error executing alter system kill session '''||sid_v||','||serial||',@'||inst||'''');
     dbms_output.put_line(SUBSTR(SQLERRM(SQLCODE), 1, 250));
     end;
   else
     dbms_output.put_line('cannot kill another user''s session');
  end if;
end; 

CREATE OR REPLACE PUBLIC SYNONYM "KILL_MY_SESSION" FOR "<DBA_OWNER>"."KILL_MY_SESSION";

grant execute on KILL_MY_SESSION to PUBLIC;


Deleting based on another table
delete from A where id in (select a1.id from A a1, B where a1.id = B.id and B.id IS NULL);  --better performance
delete from a where not exists (select 'x' from b@DB_LINK b where b.id = A.id);
