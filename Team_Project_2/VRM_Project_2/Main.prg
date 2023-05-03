Global Integer odber_1, odber_2, odber_3 '2 bytes
Global Integer pr_1, pr_2, pr_3, celkem, vaha '2 bytes
Global Real cas_1, cas_2, cas_3 '4 bytes


Function main
	
	'Init 
	Reset
	celkem = 12
	vaha = 3
	
	'Memory I/O bits deklarace
	MemOff r1_ok; MemOff r2_ok; MemOff r3_ok
	MemOff start_cyklu
	
	'Init simulatoru - napozicovani dilu na pas
	Call viditelnost(0)
	Call sim_dily_1(1)
	Call sim_dily_2(1)
	Call sim_dily_3(1)
	Call viditelnost(1)
	
	'Definice multitaskingu
	Xqt R1
	Xqt R2
	Xqt R3
	
	Wait 1
	MemOn start_cyklu
	
	'Vypis do RUN window
	Print "Robot:                 GX8-A652S                             LS6-B602S                                   T6-B602S"
    Print "Zatížení:                 ", vaha, "kg                                  ", vaha, "kg                                       ", vaha, "kg"
	
	'Synchronizace robotu
	Wait MemSw(r1_ok) = 1 And MemSw(r2_ok) = 1 And MemSw(r3_ok)
	
	'Vypis do RUN window
	Print "Èas cyklu celkový:      ", FmtStr$(cas_1, "0.0"), "s                                 ", FmtStr$(cas_2, "0.0"), "s                                      ", FmtStr$(cas_3, "0.0"), "s"
	Print "Prùmìr na 1 díl:         ", FmtStr$(cas_1 / 12, "0.0"), "s                                  ", FmtStr$(cas_2 / 12, "0.0"), "s                                       ", FmtStr$(cas_3 / 12, "0.0"), "s"
	pr_1 = (cas_1 * 100) / cas_3
	pr_2 = (cas_2 * 100) / cas_3
	pr_3 = 100
	Print "Porovnání cyklu:          ", FmtStr$(pr_1, "0"), "%                                   ", FmtStr$(pr_2, "0"), "%                                       ", FmtStr$(pr_3, "0"), "%"
	Print
	
	Wait 3
	
	'Druha iterace s dvojnasobnym zatizenim
	vaha = 6
	
	MemOff r1_ok; MemOff r2_ok; MemOff r3_ok
	MemOff start_cyklu
		
	Call viditelnost(0)
	Call sim_dily_1(1)
	Call sim_dily_2(1)
	Call sim_dily_3(1)
	Call viditelnost(1)
	
	Xqt R1
	Xqt R2
	Xqt R3
	
	
	Wait 1
	MemOn start_cyklu
	Print "Zatížení:                 ", vaha, "kg                                  ", vaha, "kg                                       ", vaha, "kg"
	
	Wait MemSw(r1_ok) = 1 And MemSw(r2_ok) = 1 And MemSw(r3_ok)
    	Print "Èas cyklu celkový:      ", FmtStr$(cas_1, "0.0"), "s                                 ", FmtStr$(cas_2, "0.0"), "s                                      ", FmtStr$(cas_3, "0.0"), "s"
	Print "Prùmìr na 1 díl:         ", FmtStr$(cas_1 / 12, "0.0"), "s                                  ", FmtStr$(cas_2 / 12, "0.0"), "s                                       ", FmtStr$(cas_3 / 12, "0.0"), "s"
	pr_1 = (cas_1 * 100) / cas_3
	pr_2 = (cas_2 * 100) / cas_3
	pr_3 = 100
	Print "Porovnání cyklu:          ", FmtStr$(pr_1, "0"), "%                                   ", FmtStr$(pr_2, "0"), "%                                       ", FmtStr$(pr_3, "0"), "%"
	Print
	
	
Fend
Function R1
	
	'Init GX8
	Robot 1
	Motor On
	Power High
	Speed 100
	Accel 100, 100
	Weight vaha
	Pallet 1, P11, P12, P13, 4, 3
	Arch 0, 20, 20
	
	'V pozici home cekej na ostatni roboty
	Jump P0
	Wait MemSw(start_cyklu) = 1
	TmReset (1)
	
	'Odber dilu z pasu na paletu
	For odber_1 = 1 To celkem
		Jump P1 C0
		Call CH1(2) 'Zavri gripper
		Jump Pallet(1, odber_1) C0
		Call CH1(1) 'Otevri gripper
	Next
	
	'Home pozice
	Jump P0 C0
	cas_1 = Tmr(1)
	
	'Flip I/O bitu pro synchro s ostatnimy roboty
	MemOn r1_ok
Fend
Function CH1(stav As Integer)
	String jmeno$
	
	'Open/Close
	Select stav
		Case 1
			MemOff g1
			Wait 0.1
			jmeno$ = "dil_1_" + Str$(odber_1)
			SimSet GX_A652S.Place, jmeno$
		Case 2
			MemOn g1
			Wait 0.1
			jmeno$ = "dil_1_" + Str$(odber_1)
			SimSet GX_A652S.Pick, jmeno$
			Xqt sim_dily_1(2)
	Send
Fend
Function sim_dily_1(stav As Integer)
	Integer i, typ
	String jmeno$
	Real pos
	
	Select stav
		Case 1	'inicializace dilu
			For i = 1 To 12
				jmeno$ = "dil_1_" + Str$(i)
				SimGet jmeno$.Type, typ
				If typ = 1 Then
					SimSet GX_A652S.Place, jmeno$
				EndIf
				
				SimSet jmeno$.PositionX, (-450)
				SimSet jmeno$.PositionY, (40 - ((i - 1) * 70))
				SimSet jmeno$.PositionZ, 80
			Next
		Case 2	'posun dilu na dopravniku
			Wait 0.5
			For i = odber_1 + 1 To 12
				jmeno$ = "dil_1_" + Str$(i)
				SimGet jmeno$.PositionY, pos
				SimSet jmeno$.PositionY, (pos + 70)
			Next
	Send
Fend
Function R2
	Robot 2 ' LS6
	
	Motor On
	Power High
	Speed 100
	Accel 100, 100
	Weight vaha
	Pallet 1, P11, P12, P13, 4, 3
	Arch 0, 20, 20

	Jump P0
	Wait MemSw(start_cyklu) = 1
	
	TmReset (2)
	For odber_2 = 1 To celkem
		Jump P1 C0
		Call CH2(2)
		Jump Pallet(1, odber_2) C0
		Call CH2(1)
	Next
	
	Jump P0 C0
	cas_2 = Tmr(2)
	MemOn r2_ok
Fend
Function CH2(stav As Integer)
	String jmeno$
	Select stav
		Case 1
			MemOff g2
			Wait 0.1
			jmeno$ = "dil_2_" + Str$(odber_2)
			SimSet LS6_B602S.Place, jmeno$
		Case 2
			MemOn g2
			Wait 0.1
			jmeno$ = "dil_2_" + Str$(odber_2)
			SimSet LS6_B602S.Pick, jmeno$
			Xqt sim_dily_2(2)
	Send
Fend
Function sim_dily_2(stav As Integer)
	Integer i, typ
	String jmeno$
	Real pos
	
	Select stav
		Case 1	'inicializace
			For i = 1 To 12
				jmeno$ = "dil_2_" + Str$(i)
				SimGet jmeno$.Type, typ
				If typ = 1 Then
					SimSet LS6_B602S.Place, jmeno$
				EndIf
				
				SimSet jmeno$.PositionX, (-450 - 1060)
				SimSet jmeno$.PositionY, (40 - ((i - 1) * 70))
				SimSet jmeno$.PositionZ, 80
			Next
		Case 2	'posun na dopravniku
			Wait 0.5
			For i = odber_2 + 1 To 12
				jmeno$ = "dil_2_" + Str$(i)
				SimGet jmeno$.PositionY, pos
				SimSet jmeno$.PositionY, (pos + 70)
			Next
	Send
Fend
Function R3
	Robot 3 'T6
	
	Motor On
	Power High
	Speed 100
	Accel 100, 100
	Weight vaha
	Pallet 1, P11, P12, P13, 4, 3
	Arch 0, 20, 20

	Jump P0
	Wait MemSw(start_cyklu) = 1
	
	TmReset (3)
	For odber_3 = 1 To celkem
		Jump P1 C0
		Call CH3(2)
		Jump Pallet(1, odber_3) C0
		Call CH3(1)
	Next
	
	Jump P0 C0
	cas_3 = Tmr(3)
	MemOn r3_ok
Fend
Function CH3(stav As Integer)
	String jmeno$
	Select stav
		Case 1
			MemOff g3
			Wait 0.1
			jmeno$ = "dil_3_" + Str$(odber_3)
			SimSet T6_B602S.Place, jmeno$
		Case 2
			MemOn g3
			Wait 0.1
			jmeno$ = "dil_3_" + Str$(odber_3)
			SimSet T6_B602S.Pick, jmeno$
			Xqt sim_dily_3(2)
	Send
Fend
Function sim_dily_3(stav As Integer)
	Integer i, typ
	String jmeno$
	Real pos
	
	Select stav
		Case 1	'inicializace
			For i = 1 To 12
				jmeno$ = "dil_3_" + Str$(i)
				SimGet jmeno$.Type, typ
				If typ = 1 Then
					SimSet T6_B602S.Place, jmeno$
				EndIf
				
				SimSet jmeno$.PositionX, (-450 - 2120)
				SimSet jmeno$.PositionY, (40 - ((i - 1) * 70))
				SimSet jmeno$.PositionZ, 80
			Next
		Case 2	'posun na dopravniku
			Wait 0.5
			For i = odber_3 + 1 To 12
				jmeno$ = "dil_3_" + Str$(i)
				SimGet jmeno$.PositionY, pos
				SimSet jmeno$.PositionY, (pos + 70)
			Next
	Send
Fend
Function viditelnost(stav As Integer)
	
	Integer i, j
	String jmeno$
	
	Select stav
		Case 0 'dily neviditelne
			For j = 1 To 3
				For i = 1 To 12
					jmeno$ = "dil_" + Str$(j) + "_" + Str$(i)
					
					SimSet jmeno$.Visible, False
					Wait 0.01
				Next i
			Next j
			
		Case 1 'dily viditelne
			For j = 1 To 3
				For i = 1 To 12
					jmeno$ = "dil_" + Str$(j) + "_" + Str$(i)
					
					SimSet jmeno$.Visible, True
					Wait 0.01
				Next i
			Next j
			
			
	Send
		
Fend

