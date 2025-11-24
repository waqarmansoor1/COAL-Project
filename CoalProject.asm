INCLUDE irvine32.inc

.data

marks dword 20 dup(?)
roll byte 20*4 dup(?)  
buffer byte 50 dup(?) 
studentAvg DWORD 20 DUP(?)
buffer1 BYTE 10 DUP(?)

engMarks DWORD 20 DUP(?)
mathMarks DWORD 20 DUP(?)      
phyMarks DWORD 20 DUP(?)

count dword 0 
studentIndex DWORD 0

msgStatsHeader BYTE "----- CLASS STATISTICS -----",0
msgHighestAvg BYTE "Highest Percentage: ",0
msgLowestAvg BYTE "Lowest Percentage : ",0
msgClassAvg BYTE "Class Average     : ",0

msgAllHeader   BYTE "----- ALL STUDENTS -----",0
msgRollDisp    BYTE "Roll: ",0

englishMsg BYTE "English:   ", 0
mathMsg BYTE    "Maths:      ", 0
phyMsg BYTE     "Physics:   ", 0
avgMsg BYTE     "Average:   ",0
gradeMsg BYTE   "Grade:      ", 0

adminPassword BYTE "2724",0
enterPass BYTE "Enter admin password: ",0
invalidPassMsg BYTE "Incorrect password! Try again.",0

noEditMsg BYTE "No Students to edit.", 0
noDeleteMsg BYTE "No students to delete.", 0
noViewStudents BYTE "No student data.", 0


enterRollMsg BYTE "Enter 4-character Roll Number: ",0
enterEngMsg BYTE "Enter English Marks (0-100): ",0
enterMathMsg BYTE "Enter Math Marks (0-100): ",0
enterPhyMsg BYTE "Enter Physics Marks (0-100): ",0

editMsg BYTE "Student edited successfully.", 0
invalidRollMsg BYTE "Invalid roll number! Try again.",0
invalidMarksMsg BYTE "Invalid marks! Enter value between 0 and 100.",0
addedMsg BYTE "Student added successfully!",0
fullMsg BYTE "Can't add more students. Maximum reached.",0
swapMsg BYTE "Students sorted successfully.", 0
enterChoice BYTE "Enter your choice: ", 0
deleteMsg BYTE "Student deleted successfully.", 0

mainMenu BYTE "1. Admin Panel", 0Dh, 0Ah, \
               "2. Student Panel", 0Dh, 0Ah, \
               "3. Exit", 0

adminMenu BYTE "1. Add student",0Dh,0Ah,\
               "2. Edit Marks",0Dh,0Ah,\
               "3. Delete Student",0Dh,0Ah,\
               "4. View Students",0Dh,0Ah,\
               "5. Search Student",0Dh,0Ah,\
               "6. Sort Students by Percentage",0Dh,0Ah,\
               "7. Class Statistics",0Dh,0Ah,\
               "8. Go to Student Panel",0Dh,0Ah,\
               "9. Back to Main Menu",0

studentMenu BYTE "1. View my marks",0Dh,0Ah,\
                 "2. Go to Admin Panel",0Dh,0Ah,\
                 "3. Back to Main Menu", 0

menuError BYTE "Incorrect choice. Please pick a number between 1-3.", 0
adminError BYTE "Incorrect choice. Please pick a number between 1-9.", 0
studentError BYTE "Incorrect choice. Please pick a number between 1-3.", 0

gradeA BYTE " A ", 0
gradeB BYTE " B ", 0
gradeC BYTE " C ", 0
gradeD BYTE " D ", 0
gradeE BYTE " E ", 0
gradeF BYTE " F ", 0


.code

checkPassword PROC
RetryPass:
    call CrLf
    mov edx, OFFSET enterPass
    call WriteString
    call CrLf

    mov edx, OFFSET buffer1
    mov ecx, 10
    call ReadString           

    mov esi, OFFSET buffer1       
    mov edi, OFFSET adminPassword 

CheckLoop:
    lodsb                        
    mov bl, [edi]                
    cmp al, bl
    jne invalidPass              
    cmp al, 0                    
    je PasswordOK                
    inc edi                       
    jmp CheckLoop

invalidPass:
    mov edx, OFFSET invalidPassMsg
    call WriteString
    call CrLf
    jmp RetryPass

PasswordOK:
    ret
checkPassword ENDP


classStatistics PROC

    mov eax, count
    cmp eax, 0
    je NoStudentsStats

    mov esi, OFFSET studentAvg
    mov ecx, count

    mov eax, [esi]      
    mov ebx, eax        
    mov edi, eax        
    mov ebp, eax        

    add esi, 4
    dec ecx

StatLoop:
    cmp ecx, 0
    je StatsDone

    mov eax, [esi]

    cmp eax, ebx
    jle SkipHigh
    mov ebx, eax
SkipHigh:

    cmp eax, edi
    jge SkipLow
    mov edi, eax
SkipLow:

    add ebp, eax     

    add esi, 4
    dec ecx
    jmp StatLoop

StatsDone:

    call CrLf
    mov edx, OFFSET msgStatsHeader
    call WriteString
    call CrLf

    mov edx, OFFSET msgHighestAvg
    call WriteString
    mov eax, ebx
    call WriteDec
    call CrLf

    mov edx, OFFSET msgLowestAvg
    call WriteString
    mov eax, edi
    call WriteDec
    call CrLf

    mov eax, ebp       
    mov ebx, count
    cdq
    div ebx            

    mov edx, OFFSET msgClassAvg
    call WriteString
    call WriteDec
    call CrLf
    jmp quitcs

NoStudentsStats:
    mov edx, OFFSET noViewStudents
    call WriteString
    call CrLf

quitcs:
    ret
classStatistics ENDP

viewAllStudents PROC

    cmp count, 0
    je NoStudentsAll

    call CrLf
    mov edx, OFFSET msgAllHeader
    call WriteString
    call CrLf
    call CrLf

    mov ecx, count
    mov ebx, 0          

AllLoop:
    cmp ecx, 0
    je DoneAll

    mov edx, OFFSET msgRollDisp
    call WriteString

    mov al, roll[ebx]
    call WriteChar
    mov al, roll[ebx+1]
    call WriteChar
    mov al, roll[ebx+2]
    call WriteChar
    mov al, roll[ebx+3]
    call WriteChar

    call CrLf

    mov edx, OFFSET englishMsg
    call WriteString
    
    mov eax, engMarks[ebx]
    call WriteDec
    call crlf

    mov edx, OFFSET mathMsg
    call WriteString
    mov eax, mathMarks[ebx]
    call WriteDec
    call crlf
    
    mov edx, OFFSET phyMsg
    call WriteString
    mov eax, phyMarks[ebx]
    call WriteDec
    call CrLf
    call crlf

    mov eax, ebx
    shr eax, 2
    mov studentIndex, eax
    call calcAverage

    mov edx, OFFSET avgMsg
    call WriteString
    mov eax, studentAvg[ebx]
    call WriteDec
    call crlf

    mov eax, ebx
    shr eax, 2
    mov studentIndex, eax
    mov edx, OFFSET gradeMsg
    call WriteString
    call calcGrade
    call crlf
    call crlf

    add ebx, 4
    dec ecx
    jmp AllLoop

DoneAll:
    jmp quitvs

NoStudentsAll:
    mov edx, OFFSET noViewStudents
    call WriteString
    call CrLf

    quitvs:
    ret
viewAllStudents ENDP



adminPanel PROC

choice1:
call crlf
mov edx, OFFSET adminMenu
call WriteString
call crlf

mov edx, OFFSET enterChoice
call WriteString

call readInt

cmp eax, 1
je addS


cmp eax, 2
je editS


cmp eax, 3
je deleteS

cmp eax, 4
je viewS

cmp eax, 5
je searchS

cmp eax, 6
je sortS

cmp eax, 7
je classS

cmp eax, 8
je student

cmp eax, 9
je quitAdmin

cmp eax, 10
je incorrect1

incorrect1:
call crlf
mov edx, OFFSET adminError
call WriteString
call crlf
jmp choice1


addS:
call crlf
call addStudent

jmp choice1


editS:
call crlf
call editStudent

jmp choice1


deleteS:
call crlf
call deleteStudent
jmp choice1


viewS:
call crlf
call viewAllStudents
jmp choice1


searchS:
call crlf
call viewMarks
jmp choice1


sortS:
call crlf
call sortStudents
jmp choice1


classS:
call crlf
call classStatistics
jmp choice1

quitAdmin:
ret
adminPanel ENDP


studentPanel PROC

choice2:
call crlf
mov edx, OFFSET studentMenu
call WriteString
call crlf

mov edx, OFFSET enterChoice
call WriteString

call readInt

cmp eax, 1
je viewM

cmp eax, 2
je admin


cmp eax, 3
je quitStudent


cmp eax, 4
je incorrect2


incorrect2:
call crlf
mov edx, OFFSET studentError
call WriteString
call crlf
jmp choice2


viewM:
call crlf
call ViewMarks
jmp choice2


quitStudent:
ret
studentPanel ENDP


GetnCheck Proc uses ecx

mov edx,offset buffer     
mov ecx , 50        
call readstring      

mov ebx , 0
mov edi , offset buffer
length1 : 
mov al , [edi+ebx] 
cmp al , 0 
je v_l
inc ebx
jmp length1

v_l: 
cmp ebx , 4
jne invalid 

mov edi , offset buffer     
mov ecx , 4       

Check:

mov al,[edi]        
cmp al, '0'  
jb invalid          
cmp al, '9'
ja invalid

inc edi
loop Check
valid:
mov eax , 1
jmp quitgc
invalid:
mov eax , 0

quitgc:
ret 
GetnCheck ENDP


addStudent PROC
    mov eax, count
    cmp eax, 20             
    je full

InputRoll:
    mov edx, OFFSET enterRollMsg
    call WriteString
    call CrLf

    call GetnCheck
    cmp eax, 1
    jne InputRoll

    mov esi, OFFSET buffer       
    xor ecx, ecx
CheckDup:
    cmp ecx, count
    je RollUnique                

    mov edi, OFFSET roll
    mov ebx, ecx
    shl ebx, 2                   
    add edi, ebx

    mov al, [esi]
    cmp al, [edi]
    jne NextCheck
    mov al, [esi+1]
    cmp al, [edi+1]
    jne NextCheck
    mov al, [esi+2]
    cmp al, [edi+2]
    jne NextCheck
    mov al, [esi+3]
    cmp al, [edi+3]
    jne NextCheck

    mov edx, OFFSET invalidRollMsg
    call WriteString
    call CrLf
    jmp InputRoll

NextCheck:
    inc ecx
    jmp CheckDup

RollUnique:
    mov esi, OFFSET roll
    mov eax, count
    mov ebx, 4
    mul ebx
    add esi, eax
    mov edi, OFFSET buffer
    mov ecx, 4
CopyRollLoop:
    mov al, [edi]
    mov [esi], al
    inc edi
    inc esi
    loop CopyRollLoop

InputEng:
    mov edx, OFFSET enterEngMsg
    call WriteString
    call CrLf
    call ReadInt
    cmp eax,0
    jl InputEng
    cmp eax,100
    jg InputEng
    mov ebx, count
    mov engMarks[ebx*4], eax

InputMath:
    mov edx, OFFSET enterMathMsg
    call WriteString
    call CrLf
    call ReadInt
    cmp eax,0
    jl InputMath
    cmp eax,100
    jg InputMath
    mov ebx, count
    mov mathMarks[ebx*4], eax

InputPhy:
    mov edx, OFFSET enterPhyMsg
    call WriteString
    call CrLf
    call ReadInt
    cmp eax,0
    jl InputPhy
    cmp eax,100
    jg InputPhy
    mov ebx, count
    mov phyMarks[ebx*4], eax

    mov eax, count
    mov studentIndex, eax
    call calcAverage

    inc count
    mov edx, OFFSET addedMsg
    call WriteString
    call CrLf
    jmp quitas

full:
    mov edx, OFFSET fullMsg
    call WriteString
    call CrLf

quitas:
    ret
addStudent ENDP



ViewMarks PROC
    cmp count, 0
    je noView
    call CrLf
    mov edx, OFFSET enterRollMsg
    call WriteString
    call CrLf

    call GetnCheck
    cmp eax, 1
    jne ViewMarks

    mov esi, OFFSET roll       
    xor ebx, ebx               
    mov ecx, count             

FindRoll:
    mov al, buffer[0]
    mov dl, roll[ebx]
    cmp dl, al
    jne NextStudent

    mov al, buffer[1]
    mov dl, roll[ebx+1]
    cmp dl, al
    jne NextStudent

    mov al, buffer[2]
    mov dl, roll[ebx+2]
    cmp dl, al
    jne NextStudent

    mov al, buffer[3]
    mov dl, roll[ebx+3]
    cmp dl, al
    jne NextStudent

    mov edx, OFFSET englishMsg
    call WriteString
    mov eax, engMarks[ebx]
    call WriteDec
    call CrLf

    mov edx, OFFSET mathMsg
    call WriteString
    mov eax, mathMarks[ebx]
    call WriteDec
    call CrLf

    mov edx, OFFSET phyMsg
    call WriteString
    mov eax, phyMarks[ebx]
    call WriteDec
    call CrLf

    call CrLf

    mov eax, studentAvg[ebx]
    mov edx, OFFSET avgMsg
    call WriteString
    call WriteDec
    call CrLf

    mov eax, ebx
    shr eax, 2
    mov studentIndex, eax       
    mov edx, OFFSET gradeMsg
    call WriteString
    call calcGrade
    call CrLf
    jmp quitvm

NextStudent:
    add ebx, 4                  
    dec ecx
    jnz FindRoll

    mov edx, OFFSET invalidRollMsg
    call WriteString
    call CrLf
    jmp ViewMarks

    noView:
    mov edx, OFFSET noViewStudents
    call WriteString
    call Crlf

    quitvm:
    ret
ViewMarks ENDP



calcAverage PROC
    pushad                
    mov eax, studentIndex    
    mov ebx, 4
    mul ebx                  
    mov esi, eax             

    mov eax, engMarks[esi]
    add eax, mathMarks[esi]
    add eax, phyMarks[esi]

    mov ecx, 3
    cdq
    idiv ecx                 

    mov studentAvg[esi], eax
    popad
    ret
calcAverage ENDP





calcGrade PROC
    pushad
    mov eax, studentIndex
    mov ebx, 4
    mul ebx
    mov eax, studentAvg[eax]

    cmp eax, 90
    jb gB
    mov edx, OFFSET gradeA
    call WriteString
    jmp Done

gB:
    cmp eax, 80
    jb gC
    mov edx, OFFSET gradeB
    call WriteString
    jmp Done

gC:
    cmp eax, 70
    jb gD
    mov edx, OFFSET gradeC
    call WriteString
    jmp Done

gD:
    cmp eax, 60
    jb gE1
    mov edx, OFFSET gradeD
    call WriteString
    jmp Done

gE1:
    cmp eax, 50
    jb gF
    mov edx, OFFSET gradeE
    call WriteString
    jmp Done

gF:
    mov edx, OFFSET gradeF
    call WriteString

Done:
    popad
    ret
calcGrade ENDP

editStudent PROC
    cmp count, 0
    je NoStudentsEdit

    call CrLf
    mov edx, OFFSET enterRollMsg
    call WriteString
    call CrLf

    call GetnCheck
    cmp eax, 1
    jne editStudent

    mov esi, OFFSET roll
    xor ebx, ebx
    mov ecx, count

FindEdit:
    mov al, buffer[0]
    cmp roll[ebx], al
    jne NextEdit
    mov al, buffer[1]
    cmp roll[ebx+1], al
    jne NextEdit
    mov al, buffer[2]
    cmp roll[ebx+2], al
    jne NextEdit
    mov al, buffer[3]
    cmp roll[ebx+3], al
    jne NextEdit

EditEng:
    mov edx, OFFSET enterEngMsg
    call WriteString
    call ReadInt
    cmp eax, 0
    jl EditEng
    cmp eax, 100
    jg EditEng
    mov engMarks[ebx], eax

EditMath:
    mov edx, OFFSET enterMathMsg
    call WriteString
    call ReadInt
    cmp eax, 0
    jl EditMath
    cmp eax, 100
    jg EditMath
    mov mathMarks[ebx], eax

EditPhy:
    mov edx, OFFSET enterPhyMsg
    call WriteString
    call ReadInt
    cmp eax, 0
    jl EditPhy
    cmp eax, 100
    jg EditPhy
    mov phyMarks[ebx], eax

    mov eax, ebx
    shr eax, 2
    mov studentIndex, eax
    call calcAverage

    mov edx, OFFSET editMsg
    call WriteString
    call CrLf
    jmp quites

NextEdit:
    add ebx, 4
    dec ecx
    jnz FindEdit

    mov edx, OFFSET invalidRollMsg
    call WriteString
    call CrLf
    jmp editStudent

NoStudentsEdit:
    mov edx, OFFSET noEditMsg
    call WriteString
    call CrLf

quites:
    ret
editStudent ENDP



deleteStudent PROC
    cmp count, 0
    je NoStudentsDelete

    call CrLf
    mov edx, OFFSET enterRollMsg
    call WriteString
    call CrLf

    call GetnCheck
    cmp eax,1
    jne deleteStudent

    mov esi, OFFSET roll
    xor ebx, ebx          
    mov ecx, count        

FindDel:
    mov al, buffer[0]
    cmp roll[ebx], al
    jne NextDel

    mov al, buffer[1]
    cmp roll[ebx+1], al
    jne NextDel

    mov al, buffer[2]
    cmp roll[ebx+2], al
    jne NextDel

    mov al, buffer[3]
    cmp roll[ebx+3], al
    jne NextDel

    mov edx, count
    dec edx             
    mov eax, ebx
    shr eax, 2
    sub edx, eax
      
    jz LastRemove        

ShiftLoop:
    mov edi, 0
RollShift:
    mov al, roll[ebx + 4 + edi]
    mov roll[ebx + edi], al
    inc edi
    cmp edi,4
    jl RollShift

    mov eax, engMarks[ebx + 4]
    mov engMarks[ebx], eax

    mov eax, mathMarks[ebx + 4]
    mov mathMarks[ebx], eax

    mov eax, phyMarks[ebx + 4]
    mov phyMarks[ebx], eax

    mov eax, studentAvg[ebx + 4]
    mov studentAvg[ebx], eax

    add ebx,4
    dec edx
    jnz ShiftLoop

LastRemove:
    dec count
    mov edx, OFFSET deleteMsg
    call WriteString
    call CrLf
    jmp quitds

NextDel:
    add ebx,4
    dec ecx
    jnz FindDel

    mov edx, OFFSET invalidRollMsg
    call WriteString
    call CrLf
    jmp deleteStudent

NoStudentsDelete:
mov edx, OFFSET noDeleteMsg
    call WriteString
    call CrLf

    quitds:
    ret
deleteStudent ENDP



sortStudents PROC

cmp count, 0
je noSort

mov ecx, count
dec ecx
jle DoneSort

Outer:
    mov ebx, 0
    mov edx, ecx

Inner:
    mov eax, studentAvg[ebx]        
    mov esi, studentAvg[ebx+4]      
    cmp eax, esi
    jge NoSwap

    mov studentAvg[ebx], esi
    mov studentAvg[ebx+4], eax

    mov eax, engMarks[ebx]
    mov esi, engMarks[ebx+4]
    mov engMarks[ebx], esi
    mov engMarks[ebx+4], eax

    mov eax, mathMarks[ebx]
    mov esi, mathMarks[ebx+4]
    mov mathMarks[ebx], esi
    mov mathMarks[ebx+4], eax

    mov eax, phyMarks[ebx]
    mov esi, phyMarks[ebx+4]
    mov phyMarks[ebx], esi
    mov phyMarks[ebx+4], eax

    mov edi,0
SwapRollLoop:
    mov al, roll[ebx+edi]
    mov ah, roll[ebx+4+edi]
    mov roll[ebx+edi], ah
    mov roll[ebx+4+edi], al
    inc edi
    cmp edi,4
    jl SwapRollLoop

NoSwap:
    add ebx,4
    dec edx
    jnz Inner

    dec ecx
    jnz Outer

DoneSort:
    mov edx, OFFSET swapMsg
    call WriteString
    call CrLf
    jmp quitss

    noSort:
    mov edx, OFFSET noViewStudents
    call WriteString
    call crlf

    quitss:
    ret
sortStudents ENDP

main PROC

mainPanel::
call crlf
mov edx, OFFSET mainMenu
call WriteString
call crlf

mov edx, OFFSET enterChoice
call WriteString

call readInt

cmp eax, 1
je admin


cmp eax, 2
je student


cmp eax, 3
je quit

cmp eax, 4
je incorrect

incorrect:
call crlf
mov edx, OFFSET menuError
call WriteString
call crlf
jmp mainPanel

admin::
call crlf
call checkPassword
call adminPanel
jmp mainPanel


student::
call crlf
call studentPanel
jmp mainPanel

quit:
exit
main ENDP
end main
