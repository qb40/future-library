;#############################################################################
;
;                   TIMER routines made by Future Software
;                          for BASIC programming 
;
;#############################################################################

.model medium
.stack 10h
.386


.data

VectorFlag        db 0

.code

GlobalTicks       dd 0
TimerTicks        dd 10000h    ;10000h=18.2 ticks/sec  
Tcounter          dd 0
Old_8_Vector      dd 0

SubGlobalTicks    dd 8 dup(0)
SubTIMERticks     dd 8 dup(10000h)
SubTcounter       dd 8 dup(0)
SubTIMERflag      db 0

;#############################################################################
;StartTimer 
;
;  returns nothing
;#############################################################################
PUBLIC StartTimer
StartTimer proc    BASIC

      .if VectorFlag == 0
        mov VectorFlag,1
        push ds

        mov ah,35h
        mov al,1ch
        mov al,8
        INT 21h
        mov word ptr cs:[Old_8_Vector],bx
        mov word ptr cs:[Old_8_Vector+2],es

        mov ah,25h
        mov al,8

        mov bx,SEG TimerUserRoutine
        mov cx,OFFSET TimerUserRoutine
        mov ds,bx
        mov dx,cx
        INT 21h

        pop ds
      .endif

        mov al,34h
        out 43h,al
        mov ax,word ptr cs:[TimerTicks]
        out 40h,al
        mov al,ah
        out 40h,al

        mov cs:[Tcounter],0

        mov cs:[SubTIMERflag],0

        mov cs:[SubTcounter],0
        mov cs:[SubTcounter+4],0
        mov cs:[SubTcounter+8],0
        mov cs:[SubTcounter+12],0
        mov cs:[SubTcounter+16],0
        mov cs:[SubTcounter+20],0
        mov cs:[SubTcounter+24],0
        mov cs:[SubTcounter+28],0

        mov cs:[SubGlobalTicks],0
        mov cs:[SubGlobalTicks+4],0
        mov cs:[SubGlobalTicks+8],0
        mov cs:[SubGlobalTicks+12],0
        mov cs:[SubGlobalTicks+16],0
        mov cs:[SubGlobalTicks+20],0
        mov cs:[SubGlobalTicks+24],0
        mov cs:[SubGlobalTicks+28],0

        retf
StartTimer endp

;#############################################################################
;SetTimerSpeed (Frequncy%)
;
;  returns Nothing
;#############################################################################
PUBLIC SetTimerSpeed
SetTimerSpeed proc    BASIC
        mov bx,sp
        push eax
        push edx
        push ecx

        xor ecx,ecx
        mov cx,[bx+04]

        .if ecx == 0
          mov eax,10000h
        .else
          mov eax, 1234deh
          cdq
          div ecx
        .endif

        mov cs:[TimerTicks],eax

        mov al,34h
        out 43h,al
        mov ax,word ptr cs:[TimerTicks]
        out 40h,al
        mov al,ah
        out 40h,al

        pop ecx
        pop edx
        pop eax
        retf 2
SetTimerSpeed endp

;#############################################################################
;StartSubTimer (TimerNR%)
;
;  returns nothing
;#############################################################################
PUBLIC StartSubTimer 
StartSubTimer  proc    BASIC
        mov bx,sp
        mov cl,[bx+04]
        dec cl
        .if (cl >= 0) && (cl <= 7)
              mov bl,1
              shl bl,cl
              or cs:[SubTIMERflag],bl
        .endif
        retf 2
StartSubTimer  endp

;#############################################################################
;StopSubTimer (TimerNR%)
;
;  returns nothing
;#############################################################################
PUBLIC StopSubTimer 
StopSubTimer   proc    BASIC
        mov bx,sp
        mov cl,[bx+04]
        dec cl
        .if (cl >= 0) && (cl <= 7)
            mov cl,bl
            mov bl,254
            rol bl,cl
            and cs:[SubTIMERflag],bl
        .endif
        retf 2
StopSubTimer   endp

;#############################################################################
;SetSubTimerSpeed (Frequncy%, TimerNR%)
;
;  returns Nothing
;#############################################################################
PUBLIC SetSubTimerSpeed
SetSubTimerSpeed proc    BASIC
        mov bx,sp
        push eax
        push edx
        push ecx

        xor ecx,ecx
        mov cx,[bx+06]

        .if ecx == 0
          mov eax,10000h
        .else
          mov eax, 1234deh
          cdq
          div ecx
        .endif

        xor cx,cx
        mov cl,[bx+04]
        dec cl
        .if (cl >= 0) && (cl <= 7)
          shl cx,2
          mov bx,cx
          mov cs:[SubTIMERticks+bx],eax
        .endif

        pop ecx
        pop edx
        pop eax
        retf 4
SetSubTimerSpeed endp

;#############################################################################
;ReadSubCounter (TimerNR%)
;
;  returns SubTcounter
;#############################################################################
PUBLIC ReadSubCounter
ReadSubCounter proc    BASIC
        mov bx,sp
        xor cx,cx
        mov cl,[bx+04]
        dec cl
        .if (cl >= 0) && (cl <= 7)
          shl cx,2
          mov bx,cx
          mov ax,word ptr cs:[SubTcounter+bx]
          mov dx,word ptr cs:[SubTcounter+bx+2]
        .endif
        retf 2
ReadSubCounter endp

;#############################################################################
;ResetSubCounter (TimerNR%)
;
;  returns SubTcounter
;#############################################################################
PUBLIC ResetSubCounter
ResetSubCounter proc    BASIC
        mov bx,sp
        xor cx,cx
        mov cl,[bx+04]
        dec cl
        .if (cl >= 0) && (cl <= 7)
          shl cx,2
          mov bx,cx
          mov word ptr cs:[SubTcounter+bx],0
          mov word ptr cs:[SubTcounter+bx+2],0
        .endif
        retf 2
ResetSubCounter endp

;#############################################################################
;TimerUserRoutine
;
;  returns nothing
;#############################################################################
TimerUserRoutine proc   
        push eax
        push bx
        push cx
        mov eax,cs:[TimerTicks]
        add cs:[GlobalTicks],eax
        
        mov bx,28
        mov cl,128
Tloop:
        mov ch,cs:[SubTIMERflag]
        and ch,cl
        .if ch == cl
            mov eax,cs:[TimerTicks]
            add cs:[SubGlobalTicks+bx],eax
            mov eax,cs:[SubTIMERticks+bx]
            .if cs:[SubGlobalTicks+bx] >= eax
                sub cs:[SubGlobalTicks+bx],eax
                inc cs:[SubTcounter+bx]
            .endif
        .endif
        shr cl,1
        sub bx,4
        test cl,cl
        jnz Tloop

        .if cs:[GlobalTicks] >= 10000h
            sub cs:[GlobalTicks],10000h
            pushf
            call cs:[Old_8_Vector]
        .else    
            mov al,20h
            out 20h,al
        .endif

        inc cs:[Tcounter]

        pop cx
        pop bx
        pop eax
        iret
TimerUserRoutine endp

;#############################################################################
;ReadCounter
;
;  returns Tcounter
;#############################################################################
PUBLIC ReadCounter
ReadCounter proc    BASIC
        mov ax,word ptr cs:[Tcounter]
        mov dx,word ptr cs:[Tcounter+2]
        retf
ReadCounter endp

;#############################################################################
;ResetCounter
;
;  returns nothing
;#############################################################################
PUBLIC ResetCounter
ResetCounter proc    BASIC
        mov cs:[Tcounter],0
        retf
ResetCounter endp

;#############################################################################
;StopTimer 
;
;  returns nothing
;#############################################################################
PUBLIC StopTimer
StopTimer proc    BASIC
    .if VectorFlag == 1 
        mov VectorFlag,0
        push ds
        mov al,34h
        out 43h,al
        mov al,0
        out 40h,al
        out 40h,al

        mov ah,25h
        mov al,8
        mov cx,word ptr cs:[Old_8_Vector]
        mov bx,word ptr cs:[Old_8_Vector+2]
        mov dx,cx
        mov ds,bx
        INT 21h
        pop ds
    .endif
        retf
StopTimer endp

END
