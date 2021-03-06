VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "OnObject"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
'
' OnObject
' ========
'
'
' Copywrite (C) 2014 Philip Wales
' This file (OnObject.cls) is distributed under the MIT license
' Obtain a copy of the MIT license <http://opensource.org/licenses/MIT>
'
' _.method(args)
'
Implements IApplicable
Implements IShowable
'
' Private Members
' ---------------
'
Private pMethod As String
Private pCallType As VbCallType
Private pArgs() As Variant
'
' Constructors
' ------------
'
Public Function Make(ByVal method As String, ByVal callT As VbCallType, _
        ParamArray args() As Variant) As OnObject

    Dim result As New OnObject
    
    With result
        .MethodName = method
        .CallType = callT
        .Arguments = cast.CArray(args)
    End With
    
    Set Make = result

End Function
'
' ### Friend Methods
'
Friend Property Let MethodName(ByVal method As String)
    
    pMethod = method
    
End Property
Friend Property Let CallType(ByVal callT As String)
    
    pCallType = callT
    
End Property
Friend Property Let Arguments(ByRef args() As Variant)

    pArgs = args

End Property
'
' Errors
' ------
'
Private Sub InvalidArguementsError(ByRef params() As Variant)

    Dim failArray As String
    failArray = defShow.Show(params)
    
    Dim msg As String
    msg = "Invalid Arguements, Expecting one object " & failArray
    
    Exceptions.ValueError Me, "IApplicable_ApplyOnArray", msg
    
End Sub
'
' IApplicable
' -----------
'
Public Function Apply(ParamArray args() As Variant) As Variant
Attribute Apply.VB_UserMemId = 0

    Assign Apply, IApplicable_ApplyOnArray(cast.CArray(args))

End Function
Private Function IApplicable_Apply(ParamArray args() As Variant) As Variant

    Assign IApplicable_Apply, IApplicable_ApplyOnArray(cast.CArray(args))

End Function
Private Function IApplicable_ApplyOnArray(ByRef params() As Variant) As Variant

    Dim Callee As Object
    If UBound(params) = LBound(params) Then
        Set Callee = params(UBound(params))
    Else
        InvalidArguementsError params
    End If
    
    Assign IApplicable_ApplyOnArray, defApply.CallByNameOnArray(Callee, pMethod, pCallType, pArgs)

End Function
Public Function Compose(ByVal f As IApplicable) As IApplicable

    Set Compose = defApply.Compose(Me, f)

End Function
Public Function AndThen(ByVal g As IApplicable) As IApplicable

    Set AndThen = defApply.AndThen(Me, g)

End Function
Private Function IApplicable_Compose(ByVal f As IApplicable) As IApplicable

    Set IApplicable_Compose = Compose(f)

End Function
Private Function IApplicable_AndThen(ByVal g As IApplicable) As IApplicable

    Set IApplicable_AndThen = AndThen(g)

End Function
'
' IShowable
' ---------
'
Public Function Show() As String
            
    Dim sArgs As String
    sArgs = defShow.Show(pArgs)
    
    Dim repr As String
    repr = "." & pMethod & "(" & sArgs & ")"
            
    Show = defShow.ParamShowableObject(Me, repr)
    
End Function
Private Function IShowable_Show() As String

    IShowable_Show = Show

End Function
