'======================================================================================
' QB64 SQLite helper routines - May of 2022
' Not sure where I found some of this code but thanks to all
'
' (c)sadLogic 2022   (c)All of humankind    Written in occupied Kherson, Ukraine
'======================================================================================

Function CreateCstrX$ (txt$)

    '--- create c style string

    If Right$(txt$, 1) <> Chr$(0) Then
        CreateCstrX$ = txt$ + Chr$(0)
    Else
        CreateCstrX$ = txt$
    End If

End Function

Function strReplaceOneX$ (myString$, find$, replaceWith$) 'noncase sensitive

    Dim a$, b$
    Dim As Long i

    a$ = myString$
    b$ = LCase$(find$)

    i = InStr(LCase$(a$), b$)
    Do While i
        a$ = Left$(a$, i - 1) + replaceWith$ + Right$(a$, Len(a$) - i - Len(b$) + 1)
        Exit Do '--- only replace the 1st one found
    Loop
    strReplaceOneX$ = a$
End Function



'This SUB will take a given N delimited string, and delimiter$ and creates
'an array of N+1 strings using the LBOUND of the given dynamic array to load.
'notes: the loadMeArray() needs to be dynamic string array and will
'not change the LBOUND of the array it is given.
Sub strSplitX (SplitMeString As String, delim As String, loadMeArray() As String)
    Dim curpos As Long, arrpos As Long, LD As Long, dpos As Long 'fix use the Lbound the array already has
    curpos = 1: arrpos = LBound(loadMeArray): LD = Len(delim)
    dpos = InStr(curpos, SplitMeString, delim)
    Do Until dpos = 0
        loadMeArray(arrpos) = Mid$(SplitMeString, curpos, dpos - curpos)
        arrpos = arrpos + 1
        If arrpos > UBound(loadMeArray) Then ReDim _Preserve loadMeArray(LBound(loadMeArray) To UBound(loadMeArray) + 1000) As String
        curpos = dpos + LD
        dpos = InStr(curpos, SplitMeString, delim)
    Loop
    loadMeArray(arrpos) = Mid$(SplitMeString, curpos)
    ReDim _Preserve loadMeArray(LBound(loadMeArray) To arrpos) As String 'get the ubound correct
End Sub



