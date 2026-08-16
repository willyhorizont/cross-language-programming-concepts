Imports System
Imports System.Text
Imports System.Collections
Imports System.Collections.Generic
Imports System.Linq

Namespace WillyHorizont.Runtime.Xl
    Public Class Xl
        Public Delegate Function XlLambda(ByVal Va As Object) As Object
        Public Structure Lambda
            Private ReadOnly Value As XlLambda
            Public Sub New(ByVal C As XlLambda)
                Me.Value = C
            End Sub
            Public Shared Widening Operator CType(ByVal C As XlLambda) As Lambda
                Return New Lambda(C)
            End Operator
            Public Function Invoke(ParamArray Va As Object()) As Object
                If Va Is Nothing Then
                    Return Me.Value(New Object() {Nothing})
                End If
                Return Me.Value(Va)
            End Function
        End Structure
        Public Class List
            Inherits List(Of Object)
            Public Sub New()
                MyBase.New()
            End Sub
        End Class
        Public Class Dict
            Inherits Dictionary(Of String, Object)
            Public Sub New()
                MyBase.New()
            End Sub
        End Class
        Public Shared Function Iter(ByVal Va As Object) As Object
            Return CType(Va, Object()).GetEnumerator()
        End Function
        Public Shared Function NextItem(ByVal Itr As IEnumerator) As Object
            Itr.MoveNext()
            Return Itr.Current
        End Function
        Public Shared Function EscapeString(S As Object) As Object
            If S Is Nothing Then Return ""
            Dim R As String = Convert.ToString(S)
            R = R.Replace("\", "\\")
            R = R.Replace("""", "\""")
            R = R.Replace(vbLf, "\n")
            R = R.Replace(vbCr, "\r")
            R = R.Replace(vbTab, "\t")
            Return R
        End Function
        Public Shared Function JsonStringify(A As Object, Optional Pretty As Object = False) As Object
            Dim P As Boolean = Convert.ToBoolean(Pretty)
            Dim T As String = String.Concat(Enumerable.Repeat(" ", 4))
            Dim S As New Stack(Of Dictionary(Of String, Object))()
            S.Push(New Dictionary(Of String, Object) From {{"t", "v"}, {"v", A}, {"d", 0}})
            Dim R As String = ""
            While S.Count > 0
                Dim C As Dictionary(Of String, Object) = S.Pop()
                If Convert.ToString(C("t")) = "r" Then
                    R &= Convert.ToString(C("v"))
                    Continue While
                End If
                Dim V As Object = C("v")
                Dim CurD As Integer = Convert.ToInt32(C("d"))
                If V Is Nothing Then
                    R &= "null"
                    Continue While
                End If
                Dim Vt As Type = V.GetType()
                If Vt Is GetType(Boolean) Then
                    R &= If(Convert.ToBoolean(V), "true", "false")
                    Continue While
                End If
                If Vt Is GetType(String) Then
                    R &= """" & EscapeString(V) & """"
                    Continue While
                End If
                If Vt Is GetType(Integer) OrElse Vt Is GetType(Double) OrElse Vt Is GetType(Decimal) OrElse Vt Is GetType(Long) Then
                    R &= V.ToString()
                    Continue While
                End If
                If GetType(MulticastDelegate).IsAssignableFrom(Vt) OrElse Vt.BaseType Is GetType(MulticastDelegate) OrElse GetType(Lambda).IsAssignableFrom(Vt) OrElse Vt.BaseType Is GetType(Lambda) Then
                    R &= """[object Function]"""
                    Continue While
                End If
                If TypeOf V Is IList Then
                    Dim Vl As IList = CType(V, IList)
                    If Vl.Count = 0 Then
                        R &= "[]"
                        Continue While
                    End If
                    Dim ChildD As Integer = CurD + 1
                    S.Push(New Dictionary(Of String, Object) From {
                        {"t", "r"},
                        {"v", If(P, vbLf & String.Concat(Enumerable.Repeat(T, CurD)) & "]", "]")},
                        {"d", CurD}
                    })
                    For I As Integer = Vl.Count - 1 To 0 Step -1
                        S.Push(New Dictionary(Of String, Object) From {
                            {"t", "v"},
                            {"v", Vl(I)},
                            {"d", ChildD}
                        })
                        If I > 0 Then
                            S.Push(New Dictionary(Of String, Object) From {
                                {"t", "r"},
                                {"v", If(P, "," & vbLf & String.Concat(Enumerable.Repeat(T, ChildD)), ",")},
                                {"d", ChildD}
                            })
                        End If
                    Next
                    S.Push(New Dictionary(Of String, Object) From {
                        {"t", "r"},
                        {"v", If(P, "[" & vbLf & String.Concat(Enumerable.Repeat(T, ChildD)), "[")},
                        {"d", ChildD}
                    })
                    Continue While
                End If
                If TypeOf V Is IDictionary Then
                    Dim Vd As IDictionary = CType(V, IDictionary)
                    If Vd.Count = 0 Then
                        R &= "{}"
                        Continue While
                    End If
                    Dim ChildD As Integer = CurD + 1
                    S.Push(New Dictionary(Of String, Object) From {
                        {"t", "r"},
                        {"v", If(P, vbLf & String.Concat(Enumerable.Repeat(T, CurD)) & "}", "}")},
                        {"d", CurD}
                    })
                    Dim Pk As New List(Of Object)(Vd.Keys.Cast(Of Object)())
                    Dim Pv As New List(Of Object)(Vd.Values.Cast(Of Object)())
                    For I As Integer = Vd.Count - 1 To 0 Step -1
                        S.Push(New Dictionary(Of String, Object) From {
                            {"t", "v"},
                            {"v", Pv(I)},
                            {"d", ChildD}
                        })
                        S.Push(New Dictionary(Of String, Object) From {
                            {"t", "r"},
                            {"v", If(P, """" & Convert.ToString(Pk(I)) & """: ", """" & Convert.ToString(Pk(I)) & """:")},
                            {"d", ChildD}
                        })
                        If I > 0 Then
                            S.Push(New Dictionary(Of String, Object) From {
                                {"t", "r"},
                                {"v", If(P, "," & vbLf & String.Concat(Enumerable.Repeat(T, ChildD)), ",")},
                                {"d", ChildD}
                            })
                        End If
                    Next
                    S.Push(New Dictionary(Of String, Object) From {
                        {"t", "r"},
                        {"v", If(P, "{" & vbLf & String.Concat(Enumerable.Repeat(T, ChildD)), "{")},
                        {"d", ChildD}
                    })
                    Continue While
                End If
                R &= """" & Vt.Name & """"
            End While
            Return R
        End Function
    End Class
End Namespace
