'======================================================================================
' QB64 SQLite routines - May of 2022  
'
' (c)sadLogic 2022   (c)All of humankind    Written in occupied Kherson, Ukraine
'======================================================================================

'$Include: 'sqlite_helpers.bas'

DECLARE DYNAMIC LIBRARY "sqlite3"
    FUNCTION sqlite3_errmsg$ (BYVAL DbhANLDE AS _OFFSET)
    FUNCTION sqlite3_open& (filename AS STRING, BYVAL ppDb AS _OFFSET)
    SUB sqlite3_open (filename AS STRING, BYVAL ppDb AS _OFFSET)
    FUNCTION sqlite3_prepare& (BYVAL DbhANLDE AS _OFFSET, zSql AS STRING, BYVAL nByte AS LONG, BYVAL ppStmt AS _OFFSET, BYVAL pzTail AS _OFFSET)
    FUNCTION sqlite3_step& (BYVAL sqlite3_stmt AS _OFFSET)
    FUNCTION sqlite3_changes& (BYVAL sqlite3_stmt AS _OFFSET)
    FUNCTION sqlite3_column_count& (BYVAL sqlite3_stmt AS _OFFSET)
    FUNCTION sqlite3_column_type& (BYVAL sqlite3_stmt AS _OFFSET, BYVAL iCol AS LONG)
    FUNCTION sqlite3_column_name$ (BYVAL sqlite3_stmt AS _OFFSET, BYVAL N AS LONG)
    FUNCTION sqlite3_column_text$ (BYVAL sqlite3_stmt AS _OFFSET, BYVAL iCol AS LONG)
    FUNCTION sqlite3_column_bytes& (BYVAL sqlite3_stmt AS _OFFSET, BYVAL iCol AS LONG)
    SUB sqlite3_finalize (BYVAL sqlite3_stmt AS _OFFSET)
    SUB sqlite3_close (BYVAL DbhANLDE AS _OFFSET)
    FUNCTION sqlite3_last_insert_rowid& (BYVAL DbhANLDE AS _OFFSET)
END DECLARE


SUB DB_Open (CreateIfMissing AS _BYTE)

    '--- just call the function and dump the return value
    '--- db.ErrMsg will be set if there is an error

    DIM junk AS _BYTE
    junk = DB_Open(CreateIfMissing)

END SUB


FUNCTION DB_Open%% (CreateIfMissing AS _BYTE)

    dbOBJ.ErrMsg = "" '--- clear err message

    IF NOT _FILEEXISTS(dbOBJ.dbName) AND CreateIfMissing = 0 THEN
        dbOBJ.ErrMsg = "SQLite DB file not found"
        DB_Open = 0 '--- return FALSE
        EXIT FUNCTION
    END IF

    '--- try and open db file,if missing it will be created
    DIM ret AS INTEGER
    ret = sqlite3_open(dbOBJ.dbName, _OFFSET(dbOBJ.hSqliteDB))
    IF ret = SQLITE_OK THEN
        DB_Open = -1
    ELSE
        DB_Open = 0 '--- failed, get an error code
        dbOBJ.ErrMsg = "Error opening DB, code: " + STR$(ret)
    END IF

END FUNCTION

FUNCTION DB_LastInsertedRowID& ()
    dbOBJ.ErrMsg = "" '--- clear last error message
    DB_LastInsertedRowID = sqlite3_last_insert_rowid(dbOBJ.hSqliteDB)
END FUNCTION

FUNCTION DB_AffectedRows& ()
    dbOBJ.ErrMsg = "" '--- clear last error message
    DB_AffectedRows = sqlite3_changes(dbOBJ.hSqliteDB)
END FUNCTION

FUNCTION DB_GetDataType$ (dataType AS LONG)
    SELECT CASE dataType
        CASE SQLITE_INTEGER
            DB_GetDataType = "INTEGER"
        CASE SQLITE_FLOAT
            DB_GetDataType = "FLOAT"
        CASE SQLITE_BLOB
            DB_GetDataType = "BLOB"
        CASE SQLITE_NULL
            DB_GetDataType = "NULL"
        CASE SQLITE_TEXT
            DB_GetDataType = "TEXT"
    END SELECT
END FUNCTION

SUB DB_Close ()
    sqlite3_close dbOBJ.hSqliteDB
END SUB

FUNCTION DB_GetErrMsg$ ()

    DIM em$: em$ = dbOBJ.ErrMsg

    '--- if there is no error then
    '--- ErrMsg can contain "not an error"
    IF INSTR(em$, "not an e") OR em$ = "" THEN
        DB_GetErrMsg = ""
    ELSE
        DB_GetErrMsg = em$
    END IF

END FUNCTION

FUNCTION DB_RowCount& (RS() AS SQLITE_RESULTSET)
    DB_RowCount& = UBOUND(RS, 2)
END FUNCTION

FUNCTION DB_ColCount& (RS() AS SQLITE_RESULTSET)
    DB_ColCount& = UBOUND(RS, 1)
END FUNCTION


FUNCTION DB_GetField$ (RS() AS SQLITE_RESULTSET, Row AS LONG, FieldName AS STRING)

    '--- get a field value from a row
    DIM ndx AS LONG
    DIM tmpFName$: tmpFName$ = LCASE$(FieldName)
    FOR ndx = 1 TO UBOUND(RS, 1)
        IF LCASE$(RS(ndx, Row).columnName) = tmpFName$ THEN
            DB_GetField$ = RS(ndx, Row).value
            EXIT FUNCTION
        END IF
    NEXT

    '--- blow up!
    dbOBJ.ErrMsg = "Field not found"
    PRINT dbOBJ.ErrMsg
    ERROR 100

END FUNCTION


FUNCTION DB_ExecQuerySingleResult$ (sql_command AS STRING)

    REDIM RS(1 TO 1, 1 TO 1) AS SQLITE_RESULTSET

    IF DB_ExecQuery(sql_command, RS()) THEN
        DB_ExecQuerySingleResult$ = RS(1, 1).value
        EXIT FUNCTION
    END IF

    PRINT dbOBJ.ErrMsg
    ERROR 100

END FUNCTION


SUB DB_ExecQuery (sql_command AS STRING, RS() AS SQLITE_RESULTSET)

    '--- just call the function and dump the return value
    '--- db.ErrMsg will be set if there is an error

    DIM junk AS LONG
    junk = DB_ExecQuery(sql_command, RS())

END SUB


FUNCTION DB_ExecQuery& (sql_command AS STRING, RS() AS SQLITE_RESULTSET)

    dbOBJ.ErrMsg = "" '--- clear last error message

    DIM retVal AS INTEGER
    retVal = sqlite3_prepare(dbOBJ.hSqliteDB, sql_command, LEN(sql_command), _OFFSET(dbOBJ.hSqliteStmt), 0)

    IF retVal = SQLITE_OK THEN

        DIM AS LONG colCount: colCount = sqlite3_column_count(dbOBJ.hSqliteStmt)
        DIM AS LONG column, row, ret, tmpCol

        ret = sqlite3_step(dbOBJ.hSqliteStmt)

        IF ret = SQLITE_ROW THEN

            DB_ExecQuery = -1 '--- return TRUE, we are good

            '---build cursor / resultset
            DO

                row = row + 1
                FOR column = 0 TO colCount - 1
                    REDIM _PRESERVE RS(colCount, row) AS SQLITE_RESULTSET
                    tmpCol = column + 1
                    RS(tmpCol, row).ColumnTYPE = sqlite3_column_type(dbOBJ.hSqliteStmt, column)
                    RS(tmpCol, row).columnName = sqlite3_column_name(dbOBJ.hSqliteStmt, column)
                    RS(tmpCol, row).value = sqlite3_column_text(dbOBJ.hSqliteStmt, column)
                NEXT
                ret = sqlite3_step(dbOBJ.hSqliteStmt)

            LOOP WHILE ret = SQLITE_ROW

        ELSE

            '--- return FALSE
            DB_ExecQuery = 0

            '--- do some error catching
            dbOBJ.ErrMsg = sqlite3_errmsg$(dbOBJ.hSqliteDB)

        END IF

    ELSE
        '--- return FALSE
        DB_ExecQuery = 0

        '--- do some error catching
        dbOBJ.ErrMsg = sqlite3_errmsg$(dbOBJ.hSqliteDB)


    END IF

    sqlite3_finalize dbOBJ.hSqliteStmt

END FUNCTION


SUB DB_ExecNonQuery (sql_command AS STRING)

    '--- just call the function and dump the return value
    '--- db.ErrMsg will be set if there is an error

    DIM junk AS _BYTE
    junk = DB_ExecNonQuery(sql_command)

END SUB


FUNCTION DB_ExecNonQuery& (sql_command AS STRING)

    dbOBJ.ErrMsg = "" '--- clear last error message
    DB_ExecNonQuery = 0 '--- assume bad things - set return to FALSE

    DIM retOK AS LONG
    retOK = sqlite3_prepare(dbOBJ.hSqliteDB, sql_command, _
                    LEN(sql_command), _OFFSET(dbOBJ.hSqliteStmt), 0)

    IF retOK = SQLITE_OK THEN

        DIM AS LONG ret: ret = sqlite3_step(dbOBJ.hSqliteStmt)

        IF ret = SQLITE_DONE THEN

            DIM AffectedRows AS LONG: AffectedRows = DB_AffectedRows
            IF AffectedRows = 0 THEN
                '--- return TRUE,  all is good
                DB_ExecNonQuery = -1
            ELSE
                '--- return number of rows affected, this will be a TRUE
                DB_ExecNonQuery = AffectedRows
            END IF


        ELSE

            '--- populate the err message var
            dbOBJ.ErrMsg = sqlite3_errmsg$(dbOBJ.hSqliteDB)

        END IF

    ELSE retOK = SQLITE_ERROR

        '---populate the err message var
        dbOBJ.ErrMsg = sqlite3_errmsg$(dbOBJ.hSqliteDB)

    END IF


    '--- cleanup mem in the statement
    sqlite3_finalize dbOBJ.hSqliteStmt


END FUNCTION

FUNCTION DB_SqlParse$ (sql_str$, values_str$)

    CONST ParseChar = "?#"
    DIM ndx%: ndx% = 0
    DIM tmp$: tmp$ = sql_str$
    REDIM arrValues$(0)

    strSplitX values_str$, ParseChar, arrValues$()

    DO WHILE INSTR(tmp$, ParseChar)
        tmp$ = strReplaceOneX$(tmp$, ParseChar, arrValues$(ndx%))
        ndx% = ndx% + 1
    LOOP

    DB_SqlParse = tmp$

END FUNCTION


