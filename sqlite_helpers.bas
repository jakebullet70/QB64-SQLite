'======================================================================================
' QB64 SQLite helper routines - May of 2022  
' Not sure where I found some of this code but thanks to all
'
' (c)sadLogic 2022   (c)All of humankind    Written in occupied Kherson, Ukraine
'======================================================================================



FUNCTION strReplaceOneX$ (myString$, find$, replaceWith$) 'noncase sensitive

    DIM a$, b$
    DIM AS LONG i

    a$ = myString$
    b$ = LCASE$(find$)

    i = INSTR(LCASE$(a$), b$)
    DO WHILE i
        a$ = LEFT$(a$, i - 1) + replaceWith$ + RIGHT$(a$, LEN(a$) - i - LEN(b$) + 1)
        EXIT DO '--- only replace the 1st one found
    LOOP
    strReplaceOneX$ = a$
END FUNCTION



'This SUB will take a given N delimited string, and delimiter$ and creates
'an array of N+1 strings using the LBOUND of the given dynamic array to load.
'notes: the loadMeArray() needs to be dynamic string array and will
'not change the LBOUND of the array it is given.
SUB strSplitX (SplitMeString AS STRING, delim AS STRING, loadMeArray() AS STRING)
    DIM curpos AS LONG, arrpos AS LONG, LD AS LONG, dpos AS LONG 'fix use the Lbound the array already has
    curpos = 1: arrpos = LBOUND(loadMeArray): LD = LEN(delim)
    dpos = INSTR(curpos, SplitMeString, delim)
    DO UNTIL dpos = 0
        loadMeArray(arrpos) = MID$(SplitMeString, curpos, dpos - curpos)
        arrpos = arrpos + 1
        IF arrpos > UBOUND(loadMeArray) THEN REDIM _PRESERVE loadMeArray(LBOUND(loadMeArray) TO UBOUND(loadMeArray) + 1000) AS STRING
        curpos = dpos + LD
        dpos = INSTR(curpos, SplitMeString, delim)
    LOOP
    loadMeArray(arrpos) = MID$(SplitMeString, curpos)
    REDIM _PRESERVE loadMeArray(LBOUND(loadMeArray) TO arrpos) AS STRING 'get the ubound correct
END SUB



