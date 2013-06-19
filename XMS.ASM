;#############################################################################
;
;                   XMS routines made by Future Software
;                          for BASIC programming 
;
;#############################################################################

.model medium
.stack 10h
.386



.data
PUBLIC XMSControl

XMSControl       dd  0

ByteLength       dd  0   ; 32-bit number of bytes to transfer
SourceHandle     dw  0   ; Handle of source block
SourceOffset     dd  0   ; 32-bit offset into source 
DestHandle       dw  0   ; Handle of destination block
DestOffset       dd  0   ; 32-bit offset into destination block


.code

;#############################################################################
;IsXMSinstalled% 
;
;  AX returns -1 if a XMS driver is present and 0 if not
;#############################################################################
PUBLIC IsXMSinstalled
IsXMSinstalled proc    BASIC
        mov ax,4300h
        int 2Fh
        mov bl,al
        xor ax,ax
        cmp bl,80h
        jne NoXMSDriver
        mov ax,4310h
        int 2Fh
        mov word ptr [XMSControl],bx        
        mov word ptr [XMSControl+2],es
        mov ax,-1
NoXMSDriver:
        retf
IsXMSinstalled endp

;#############################################################################
;AllocateXMS (bytes&)
;
;
;#############################################################################
PUBLIC AllocateXMS
AllocateXMS proc    BASIC
        push bp
        mov bp,sp

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        push edx
        mov edx,[bp+06]
        shr edx,10
        inc edx
        mov ah,09h
        call [XMSControl]
        mov ax,dx
        pop edx

        pop bp
        retf 4
AllocateXMS endp


;#############################################################################
;DeallocateXMS (handle%)
;
;
;#############################################################################
PUBLIC DeallocateXMS
DeallocateXMS proc    BASIC
        push bp
        mov bp,sp

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:
        mov dx,[bp+06]
        mov ah,0Ah
        call [XMSControl]
        pop bp
        retf 2
DeallocateXMS endp

;#############################################################################
;FreeXMSmemory&
;
;
;#############################################################################
PUBLIC FreeXMSmemory
FreeXMSmemory proc    BASIC

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        mov ah,08h
        call [XMSControl]
        xor ax,ax
        shrd dx,ax,6
        retf 
FreeXMSmemory endp


;#############################################################################
;MoveToXMS (handle%, Segment%, Offset%, Bytes&, XMSOffset&)
;           
;
;#############################################################################
PUBLIC MoveToXMS
MoveToXMS proc    BASIC
        push bp
        mov bp,sp
        pushad

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        mov eax,[bp+10]
        mov ByteLength,eax

        mov ax,[bp+18]
        mov DestHandle,ax
        mov eax,[bp+06]
        mov DestOffset,eax

        mov SourceHandle,0000h
        mov eax,[bp+14]
        mov SourceOffset,eax

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        popad
        pop bp
        retf 14
MoveToXMS endp

;#############################################################################
;MoveFromXMS (handle%, Segment%, Offset%, Bytes&, XMSOffset&)
;             
;
;#############################################################################
PUBLIC MoveFromXMS
MoveFromXMS proc    BASIC
        push bp
        mov bp,sp
        pushad

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        mov eax,[bp+10]
        mov ByteLength,eax

        mov DestHandle,0000h
        mov eax,[bp+14]
        mov DestOffset,eax

        mov ax,[bp+18]
        mov SourceHandle,ax
        mov eax,[bp+06]
        mov SourceOffset,eax

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        popad
        pop bp
        retf 14
MoveFromXMS endp

;#############################################################################
;MoveXMS (SourceHandle%, SourceXMSOffset&, DestHandle%, DestXMSOffset&, Bytes&)
;                   
;
;#############################################################################
PUBLIC MoveXMS
MoveXMS proc    BASIC
        push bp
        mov bp,sp
        pushad

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        mov eax,[bp+06]
        mov ByteLength,eax

        mov eax,[bp+10]
        mov DestOffset,eax
        mov ax,[bp+14]
        mov DestHandle,ax

        mov eax,[bp+16]
        mov SourceOffset,eax
        mov ax,[bp+20]
        mov SourceHandle,ax

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        popad
        pop bp
        retf 16
MoveXMS endp

END
