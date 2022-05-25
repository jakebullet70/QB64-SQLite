'======================================================================================
' QB64 SQLite routines - May of 2022
'
' (c)sadLogic 2022   (c)All of humankind    Written in occupied Kherson, Ukraine
'======================================================================================
$DEBUG
OPTION _EXPLICIT
$CONSOLE:ONLY
CONST FALSE = 0
CONST TRUE = -1
_CONSOLETITLE "SQLite Test"

'--- https://www.sqlite.org/index.html


'--- include me at the top ------
'$Include: 'sqlite.bi'
'--------------------------------

DIM sql$, row AS LONG, x AS LONG
CLS
PRINT "** SQLite testing **"


'--- set db name and open
dbOBJ.dbName = "NorthWind.db3"

DB_Open (NOT SQLITE_CREATE_IF_MISSING) '--- will fail id DB is missing
'DB_Open SQLITE_CREATE_IF_MISSING '--- this will create DB if needed

IF LEN(DB_GetErrMsg) <> 0 THEN
    PRINT DB_GetErrMsg
    END
END IF


'--- text scalar, return a single value
sql$ = "SELECT max(UnitPrice) FROM [Order Details];"
PRINT "(scalar) max price: ";
PRINT DB_ExecQuerySingleResult(sql$)
PRINT


'--- Run a Query that returns nothing - function style
sql$ = "CREATE TABLE persons (ID INTEGER PRIMARY KEY, FirstName TEXT, LastName TEXT, City TEXT);"
PRINT "Creating table - ";
IF DB_ExecNonQuery(sql$) THEN '--- returns TRUE / FALSE
    PRINT "Table created"
ELSE
    PRINT "Table creation failed: "; DB_GetErrMsg
END IF
PRINT


'--- Run a Query that returns nothing - sub style
sql$ = "INSERT INTO persons (FirstName,LastName,City) VALUES ('Jeff','Smith','Kherson');"
DB_ExecNonQuery sql$
IF NOT LEN(DB_GetErrMsg) THEN PRINT "Inserted record - PKey is: "; DB_LastInsertedRowID
PRINT


'--- Run a Query that returns nothing - Function style
sql$ = "INSERT INTO persons (FirstName,LastName,City) VALUES ('?#','?#','?#');"
IF DB_ExecNonQuery(DB_SqlParse(sql$, "Scott?#Smith?#Odesa")) THEN
    PRINT "Inserted record - PKey is: "; DB_LastInsertedRowID
END IF
PRINT


'--- create a recordset var
REDIM RS(1 TO 1, 1 TO 1) AS SQLITE_RESULTSET '--- a recordset var

'--- Get a recordset / resultset / cursor - sub style
sql$ = "SELECT * FROM customers ORDER BY CompanyName;"
DB_ExecQuery sql$, RS()

PRINT: PRINT "Printing fields"
row = 2: PRINT "Title: "; DB_GetField$(RS(), row, "ContactTitle")
row = 5: PRINT "Phone: "; DB_GetField$(RS(), row, "Phone")

ERASE RS '--- free resultset mem


'--- now lets get col names
sql$ = "SELECT FirstName,BirthDate,PostalCode,HireDate FROM Employees;"
DB_ExecQuery sql$, RS()

PRINT: PRINT "Printing Column names"
FOR x = 1 TO DB_ColCount(RS())
    PRINT RS(x, 1).columnName; " ";
NEXT
PRINT

ERASE RS '--- free resultset mem


'--- date testing
PRINT: PRINT "Testing dates - (BETWEEN '1993-01-01' AND '1993-12-25')"
sql$ = "SELECT LastName,FirstName,HireDate FROM Employees " +  _
              "WHERE HireDate BETWEEN '?#' AND '?#';"
DB_ExecQuery DB_SqlParse(sql$, "1993-01-01?#1993-12-25"), RS()
PRINT "Returned "; DB_RowCount(RS()); " records "


'--- Close the DB
PRINT: PRINT "Closing the DB!   ** Have a nice day **"
DB_Close

END


'=====================================================================
'=====================================================================


'--- include me at the bottom ----
'$include: 'sqlite.bas'
'---------------------------------
