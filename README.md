# QB64 SQLite
## - Wrapper and example code for using SQLite with QB64 -
Written in / for QB64

### Subs / Functions ✨

- Open a sqlite DB  
DB_Open  CreateIfMissing  
DB_Open%%(CreateIfMissing AS _BYTE)  

- Close a database  
DB_Close  

- Return primary key of last inserted record  
DB_LastInsertedRowID&()  

- Return number of rows the last query affected  
DB_AffectedRows&()  

- Return the last error message (if any)   
DB_GetErrMsg$()  

- Return total of rows in a recordset   
DB_RowCount&(RS() AS SQLITE_RESULTSET)  

- Return number of columns in a recordset   
DB_ColCount&(RS() AS SQLITE_RESULTSET)  

- Gets the value of a field   
DB_GetField$(RS() AS SQLITE_RESULTSET, Row AS LONG, FieldName AS STRING)  

- Use for Scalar functions, returning a single value   
DB_ExecQuerySingleResult$(sql_command AS STRING)  

- Execute a SQL query and return a recordset  
DB_ExecQuery sql_command AS STRING, RS() AS SQLITE_RESULTSET  
DB_ExecQuery&(sql_command AS STRING, RS() AS SQLITE_RESULTSET)   

- Execute a SQL query with no return value   
DB_ExecNonQuery sql_command AS STRING   
DB_ExecNonQuery&(sql_command AS STRING)   

- Helper function to build SQL statements   
DB_SqlParse$(sql_str AS STRING, values_str AS STRING)   

**See test.bas for example code**  

#### Thanks to
- Guys and gals at [SQLite](https://www.sqlite.org/index.html/) 
- The QB64 boys doing the [Phoenix Edition](https://qb64phoenix.com/) 
- Butt head #1, you know who you are... 


Have a nice day! 
