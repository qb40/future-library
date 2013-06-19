.model medium
.386
.stack 10h

.data

kbonflag      db 0

OldIntSegment dw 0
OldIntOffset  dw 0

.code

Zkey          db 128*2 dup (0)

;#############################################################################
;GetKey (KeyCode)
;
;  
;#############################################################################
PUBLIC GetKey
GetKey proc    BASIC
        push bp
        mov bp,sp
        cmp [bp+06],127
        ja @F
        mov ax,@code
        mov es,ax
        xor ax,ax
        mov si,offset Zkey
        mov bx,[bp+06]
        shl bx,1
        mov al,es:[si+bx]
@@:
        pop bp
        retf 2
GetKey endp

;#############################################################################
;KBHon 
;
;  
;#############################################################################
PUBLIC KBHon 
KBHon proc    BASIC
        cmp kbonflag,1
        je @F

        mov ax,@code
        mov es,ax
        mov di,Offset Zkey
        mov cx,128*2
        mov ax,0
        rep stosb

        mov ax,3509h
        int 21h
        mov OldIntOffset,bx
        mov ax,es
        mov OldIntSegment,ax

        mov ax,@code
        mov bx,Offset KeyHandler
        push ds
        mov ds,ax
        mov dx,bx
        mov ax,2509h
        int 21h
        pop ds

        in al,21h  ;CLEAR BIT 2 (IRQ 1)
        and al,253
        out 21h,al

        mov kbonflag,1
@@:
        retf
KBHon endp

;#############################################################################
;KBHoff 
;
;  
;#############################################################################
PUBLIC KBHoff 
KBHoff proc    BASIC
        cmp kbonflag,0
        je @F
        mov ax,OldIntSegment
        mov bx,OldIntOffset
        push ds
        mov ds,ax
        mov dx,bx
        mov ax,2509h
        int 21h
        pop ds
        mov kbonflag,0
@@:
        retf
KBHoff endp

;#############################################################################
;KeyHandler
;
;  
;#############################################################################
KeyHandler proc    FAR
        push ax
        push bx
        push ds
        pushf
        sti
        mov ax,@code
        db 031h, 0dbh
        db 08eh, 0d8h
        db 0e4h, 060h
        db 0d0h,0d0h           ;???
        db 088h, 0c3h
        db 0fh,93h,0c0h        ;???
        add bx,offset Zkey
        db 088h, 007h
        db 0e4h, 061h
        db 80h, 0cch, 82h      ;???
        db 0e6h, 061h
        db 024h, 07fh
        db 0e6h, 061h
        db 0b0h, 020h
        db 0e6h, 020h
        cli
        popf
        pop ds
        pop bx
        pop ax
        iret
KeyHandler endp

END
