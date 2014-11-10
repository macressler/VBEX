VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PySet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'
' PySet
' ===========
'
' Maintains a list of sorted unique items.
' It is meant to be synonymous with Python's `set` but that is
' a reserved keyword in VBA.  Instead of using an advanced data
' structure, `PySet` keeps a sorted `List` and an external
' binary search function to preserve unique elements.  This allows
' _mutability_ and limits recursion (as VB is not tail recursive.)
'
' Copywrite (C) 2014 Philip Wales
' This file (PySet.cls) is distributed under the MIT license
' Obtain a copy of the MIT license <http://opensource.org/licenses/MIT>
'
Option Explicit
'
' Public Members
' --------------
' None
'
' Private Memebers
' ----------------
'
Private pList As List
'
' Private Methods
' ---------------
'
''
' IndexOf: Finds where an item is or where it should be
Private Function IndexOf(ByVal element As Variant) As Long
    IndexOf = srch.BinarySearch(element, pList, 1, pList.Count, nearest:=True)
End Function
''
' Destructor, might be unnecessary
Private Sub Class_Terminate()
    Set pList = Nothing
End Sub
'
' Public Methods
' --------------
'
''
' Enumerator: How we all would love to create our own...
Public Property Get NewEnum() As IUnknown
    
    Set NewEnum = pList.NewEnum
    
End Property
'
' Constructors
' ------------
'
Private Sub Class_Initialize()
    Set pList = New List
End Sub
'
' ### Initializers
'
Public Function Copy(ByVal sequence As Variant) As PySet
    
    Dim result As New PySet
    result.Extend sequence
    Set Copy = result
    
End Function
Public Function Create(ParamArray args() As Variant) As PySet
    
    Set Create = Copy(args)
    
End Function
'
' Immutable Constructors
' ----------------------
'
Public Function Union(ByVal other As PySet) As PySet

    Set Union = New PySet
    Union.Extend other
    Union.Extend Me
    
End Function
Public Function Intersect(ByVal other As PySet) As PySet
    
    Dim result As New PySet
    
    Dim element As Variant
    For Each element In pList
        If other.Exists(element) Then result.Add element
    Next element
    
    Set Intersect = result
    
End Function
Public Function Difference(ByVal other As PySet) As PySet
    
    Dim result As New PySet
    
    Dim element As Variant
    For Each element In pList
        If Not other.Exists(element) Then result.Add element
    Next element
    
    Set Difference = result
    
End Function
Public Function SymmetricDifference(ByVal other As PySet) As PySet
    Set SymmetricDifference = Difference(other).Union(other.Difference(Me))
End Function
'
'
' Comparision
' -----------
'
''
' Exists: Use Binary Search for faster results.
Public Function Exists(ByVal sought As Variant) As Boolean
    Exists = (pList(IndexOf(sought)) = sought)
End Function
Public Function IsDisJoint(ByVal other As PySet) As Boolean
    IsDisJoint = (Intersect(other).Count = 0)
End Function
Public Function IsSubSetOf(ByVal other As PySet) As Boolean
    
    Dim element As Variant
    For Each element In pList
        If Not other.Exists(element) Then
            IsSubSetOf = False
            Exit Function
        End If
    Next element
    
    IsSubSetOf = True
    
End Function
Public Function IsProperSubSetOf(ByVal other As PySet) As Boolean
    IsProperSubSetOf = (IsSubSetOf(other) And (Count < other.Count))
End Function
Public Function IsSuperSetOf(ByVal other As PySet)
    IsSuperSetOf = other.IsSubSetOf(Me)
End Function
Public Function IsProperSuperSetOf(ByVal other As PySet) As Boolean
    IsProperSuperSetOf = other.IsProperSubSetOf(Me)
End Function
'
' ### Default Methods Implemented
'
' #### Access
'
Public Property Get Item(ByVal index As Long) As Variant
Attribute Item.VB_UserMemId = 0
    
    seq.Assign Item, pList.Item(index)
    
End Property
Public Property Get Slice(ByVal a As Long, ByVal b As Long) As PySet
    Set Slice = pList.Slice(a, b)
End Property
'
' Mutability
' ----------
'
' ### Overridden Methods
'
' #### Extension
''
' Add: Instead of Insert, Emplace, or Append
Public Sub Add(ByVal element As Variant)
    
    If pList.Count = 0 Then
        pList.Append element
        Exit Sub
    End If
    
    Dim index As Long
    index = IndexOf(element)
    
    If pList(index) = element Then Exit Sub
    
    If pList(index) < element Then ' ONLY HAPPENS AT END?
        pList.Append (element)
    Else
        pList.Emplace index, element
    End If
    
End Sub
''
' Extend: routed through our `Add`
Public Sub Extend(ByVal sequence As Variant)
    
    Dim element As Variant
    For Each element In sequence
        Add element
    Next element
    
End Sub
'
' #### Removal
'
''
' Removal is by element not by index
Public Sub Remove(ByVal element As Variant)
    
    Dim index As Long
    index = IndexOf(element)
    
    If pList(index) = element Then
        pList.Remove (index)
    Else
        Err.Raise 9, TypeName(Me) & ".Remove", "Element does not exist."
    End If
    
End Sub
'
' #### Misc
'
Public Function Count() As Long
    Count = pList.Count
End Function
Public Function ToString() As String
    ToString = pList.ToString
End Function
'
' ### Unimplemented
'
' #### Replacement
' #### Insertion
'