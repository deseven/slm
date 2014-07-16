; Sins Localization Merger
; by deseven, 2011

Global PrimaryPathSelected,SecondaryPathSelected,OutputPathSelected,Working,NewValue = #False

If OpenWindow(0,#PB_Ignore,#PB_Ignore,300,200,"SLM",#PB_Window_ScreenCentered|#PB_Window_BorderLess)
  ;regn.i$ = CreateRoundRectRgn_(0,0,300,200,20,20)
  ;SetWindowRgn_(WindowID(0),regn.i$,#True)
  SetActiveWindow(0)
  TextGadget(1,10,12,80,30,"Primary localization file:")
  StringGadget(2,90,20,200,20,"")
  TextGadget(3,10,42,80,30,"Secondary localization file:")
  StringGadget(4,90,50,200,20,"")
  TextGadget(5,10,72,80,30,"Output localization file:")
  StringGadget(6,90,80,200,20,"")
  ButtonGadget(10,250,110,40,20,"GO!",#PB_Button_Default)
  ButtonGadget(30,250,140,40,20,"?")
  ButtonGadget(31,250,170,40,20,"X")
  TextGadget(11,250,110,40,20,"...",#PB_Text_Center)
  HideGadget(11,1)
  EditorGadget(20,10,110,230,80,#PB_Editor_ReadOnly)
Else
  MessageRequester("Error!","Can't create window... [Code: 11]")
EndIf

Procedure PreCheck()
  If Len(GetGadgetText(2)) > 3 And Len(GetGadgetText(4)) > 3 And Len(GetGadgetText(6)) > 3
    If ReadFile(1,GetGadgetText(2)) And ReadFile(2,GetGadgetText(4))
      ProcedureReturn #True
    Else
      MessageRequester("Error!","Can't open files... [Code: 12]")
      ProcedureReturn #False
    EndIf
  Else
    MessageRequester("Error!","You must select all files...")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure DoWork(dummy)
  Working = #True
  
  ; Primary
  ReadString(1)
  PriNumOfStrings$ = ReplaceString(ReadString(1),"NumStrings","",#PB_String_NoCase)
  PriNumOfStrings$ = ReplaceString(PriNumOfStrings$," ","")
  If Val(PriNumOfStrings$) > 0
    NewList PrimaryIDs.s()
    NewList PrimaryValues.s()
    While Eof(1) = 0
      If FindString(ReadString(1),"StringInfo",1) = 1
        AddElement(PrimaryIDs())
        PrimaryIDs() = ReplaceString(ReadString(1),Chr(9) + "ID ","",#PB_String_NoCase)
        AddElement(PrimaryValues())
        PrimaryValues() = ReplaceString(ReadString(1),Chr(9) + "Value ","",#PB_String_NoCase)
      EndIf
    Wend
    AddGadgetItem(20,2,"Pri: " + Str(ListSize(PrimaryIDs())) + " IDs and " + Str(ListSize(PrimaryValues())) + " values done.")
  Else
    MessageRequester("Error!","Primary: unknown file format... [Code: 13]")
    CloseFile(1)
    CloseFile(2)
    CloseFile(3)
    ProcedureReturn #False
  EndIf
  
  ; Secondary
  ReadString(2)
  SecNumOfStrings$ = ReplaceString(ReadString(2),"NumStrings ","",#PB_String_NoCase)
  SecNumOfStrings$ = ReplaceString(SecNumOfStrings$," ","")
  If Val(PriNumOfStrings$) > 0
    NewList SecondaryIDs.s()
    NewList SecondaryValues.s()
    While Eof(2) = 0
      If FindString(ReadString(2),"StringInfo",1) = 1
        AddElement(SecondaryIDs())
        SecondaryIDs() = ReplaceString(ReadString(2),Chr(9) + "ID ","",#PB_String_NoCase)
        AddElement(SecondaryValues())
        SecondaryValues() = ReplaceString(ReadString(2),Chr(9) + "Value ","",#PB_String_NoCase)
      EndIf
    Wend
    AddGadgetItem(20,4,"Sec: " + Str(ListSize(SecondaryIDs())) + " IDs and " + Str(ListSize(SecondaryValues())) + " values done.")
  Else
    MessageRequester("Error!","Secondary: unknown file format... [Code: 14]")
    CloseFile(1)
    CloseFile(2)
    CloseFile(3)
    ProcedureReturn #False
  EndIf
  
  ; Output
  AddGadgetItem(20,5,"Out: starting merge process...")
  NumOfStrings = Val(PriNumOfStrings$)
  SelectElement(PrimaryValues(),0)
  NewList OutAll.s()
  ForEach PrimaryIDs()
    AddElement(OutAll())
    OutAll() = "StringInfo"
    AddElement(OutAll())
    OutAll() = Chr(9) + "ID " + PrimaryIDs()
    AddElement(OutAll())
    OutAll() = Chr(9) + "Value " + PrimaryValues()
    NextElement(PrimaryValues())
  Next
  ForEach SecondaryIDs()
    ForEach PrimaryIDs()
      If SecondaryIDs() = PrimaryIDs()
        NewValue = #False
        Break
      Else
        NewValue = #True
      EndIf
    Next
    If NewValue = #True
      NewValue = #False
      AddElement(OutAll())
      OutAll() = "StringInfo"
      AddElement(OutAll())
      OutAll() = Chr(9) + "ID " + SecondaryIDs()
      SelectElement(SecondaryValues(),ListIndex(SecondaryIDs()))
      AddElement(OutAll())
      OutAll() = Chr(9) + "Value " + SecondaryValues()
      NumOfStrings = NumOfStrings + 1
    EndIf
  Next
  CloseFile(1)
  CloseFile(2)
  If CreateFile(3,GetGadgetText(6))
    WriteStringN(3,"TXT")
    WriteStringN(3,"NumStrings " + Str(NumOfStrings))
    AddGadgetItem(20,6,"Out: " + Str(NumOfStrings) + " total strings.")
    ForEach OutAll()
      WriteStringN(3,OutAll())
    Next
    AddGadgetItem(20,7,"All operations done.")
  Else
    MessageRequester("Error!","Can't create output file... [Code: 15]")
  EndIf
  FreeList(PrimaryIDs())
  FreeList(PrimaryValues())
  FreeList(SecondaryIDs())
  FreeList(SecondaryValues())
  FreeList(OutAll())
  CloseFile(3)
EndProcedure

Repeat
  ev = WaitWindowEvent()
  If #PB_Event_Gadget And EventGadget()=2 And EventType()=#PB_EventType_Focus And PrimaryPathSelected=#False
    SetActiveGadget(1)
    PrimaryPathSelected=#True
    SetGadgetText(2,OpenFileRequester("Select primary localization file","","SoaSE loc file (*.str)|*.str|All files (*.*)|*.*",0))
    PrimaryPathSelected=#False
  EndIf
  If #PB_Event_Gadget And EventGadget()=4 And EventType()=#PB_EventType_Focus And SecondaryPathSelected=#False
    SetActiveGadget(3)
    SecondaryPathSelected=#True
    SetGadgetText(4,OpenFileRequester("Select secondary localization file","","SoaSE loc file (*.str)|*.str|All files (*.*)|*.*",0))
    SecondaryPathSelected=#False
  EndIf
  If #PB_Event_Gadget And EventGadget()=6 And EventType()=#PB_EventType_Focus And OutputPathSelected=#False
    SetActiveGadget(5)
    OutputPathSelected=#True
    OutFile$ = SaveFileRequester("Select output localization file","","SoaSE loc file (*.str)|*.str",0)
    If Right(OutFile$,4) = ".str" 
      SetGadgetText(6,OutFile$)
    Else
      SetGadgetText(6,OutFile$ + ".str")
    EndIf
    OutputPathSelected=#False
  EndIf
  If #PB_Event_Gadget And EventGadget()=10
    HideGadget(10,1)
    HideGadget(11,0)
    ClearGadgetItems(20)
    If PreCheck()=#True
      WorkThread = CreateThread(@DoWork(),dummy)
    Else
      HideGadget(11,1)
      HideGadget(10,0)
    EndIf
  EndIf
  If #PB_Event_Gadget And EventGadget()=30
    MessageRequester("About","Sins localization merger" + Chr(10) + "deseven, 2011")
  EndIf
  If #PB_Event_Gadget And EventGadget()=31
    ev = #PB_Event_CloseWindow
  EndIf
  ;If ev = #WM_LBUTTONDOWN
    ;SendMessage_(WindowID(0),#WM_NCLBUTTONDOWN,#HTCAPTION,0)
  ;EndIf
  If Working = #True
    If IsThread(WorkThread) = 0
      Working = #False
      HideGadget(11,1)
      HideGadget(10,0)
    EndIf
  EndIf
Until ev = #PB_Event_CloseWindow
; IDE Options = PureBasic 4.51 (MacOS X - x86)
; CursorPosition = 190
; FirstLine = 169
; Folding = -
; EnableXP