;#############################################################################
;
;                SVGA/mouse routines made by Future Software
;                          for BASIC programming 
;
;#############################################################################

.model medium
.stack 10h
.386

EXTRN SVGAput:FAR
EXTRN SVGAget:FAR

.data
MouseBitCursorMask  dw 0011111111111111b
                    dw 0001111111111111b
                    dw 0000111111111111b
                    dw 0000011111111111b
                    dw 0000001111111111b
                    dw 0000000111111111b
                    dw 0000000011111111b
                    dw 0000000001111111b
                    dw 0000000000111111b
                    dw 0000000000111111b
                    dw 0000000111111111b
                    dw 0001000011111111b
                    dw 0011000011111111b
                    dw 1111100001111111b
                    dw 1111100001111111b
                    dw 1111110001111111b

MouseBitCursor      dw 0000000000000000b
                    dw 0100000000000000b
                    dw 0110000000000000b
                    dw 0111000000000000b
                    dw 0111100000000000b
                    dw 0111110000000000b
                    dw 0111111000000000b
                    dw 0111111100000000b
                    dw 0111111110000000b
                    dw 0111100000000000b
                    dw 0110110000000000b
                    dw 0100011000000000b
                    dw 0000011000000000b
                    dw 0000001100000000b
                    dw 0000001100000000b
                    dw 0000000000000000b

EXTRN MouseGonoff:Byte

EXTRN Status:word
EXTRN Mx:word     
EXTRN My:word     
EXTRN Mx1:word    
EXTRN My1:word    
EXTRN Mb:word     
EXTRN TMx:word    
EXTRN TMy:word    
EXTRN TMx1:word   
EXTRN TMY1:word   
EXTRN MColorMask:dword

EXTRN XshiftFactor:byte
EXTRN BitsPerPixel:byte

EXTRN ActivePageX:word
EXTRN ActivePageY:word

EXTRN ViewPageX:word
EXTRN ViewPageY:word
EXTRN MaskColor:dword
EXTRN BytesPP:word

EXTRN BMapStatus:word

PUBLIC CursorBuffer
PUBLIC TempCursorBuffer
PUBLIC TempCursorBufferX

.FARDATA?
CursorX             dw 15
CursorY             dw 15
Cursor              db 1024 dup(0)
CursorBufferX       dw 15
CursorBufferY       dw 15
CursorBuffer        db 1024 dup(0)
TempCursorBufferX   dw 15
TempCursorBufferY   dw 15
TempCursorBuffer    db 1024 dup(0)

.code 

;#############################################################################
;Mouse Cursor Generator
;
;  
;#############################################################################
PUBLIC MouseCursorGenerator
MouseCursorGenerator proc    BASIC

        xor bx,bx
        cmp Status,0
        jz @F
        call SVGAmouseOff
        mov bx,1
@@:

        mov ax,@fardata?;@code
        mov es,ax

        mov es:[CursorX],15
        mov es:[CursorY],15
        mov es:[CursorBufferX],15
        mov es:[CursorBufferY],15
        mov es:[TempCursorBufferX],15
        mov es:[TempCursorBufferY],15

        mov MColorMask,255

        mov bx,offset MouseBitCursor
        mov ax,offset MouseBitCursorMask
        mov si,ax
        mov ax,offset Cursor
        mov di,ax
        mov cl,16
Mouseloop:
        mov ch,16

MaskScan:

        .if BitsPerPixel == 8
          rol word ptr [si],1
          jae @F
            mov byte ptr es:[di],255
            rol word ptr [bx],1
            jmp Donepixel
          @@:
          rol word ptr [bx],1
          jae @F
            mov byte ptr es:[di],15
            jmp Donepixel
          @@:
          mov byte ptr es:[di],0

        .elseif BitsPerPixel == 15 || BitsPerPixel == 16
          rol word ptr [si],1
          jae @F
            mov word ptr es:[di],255
            rol word ptr [bx],1
          jmp Donepixel
          @@:
          rol word ptr [bx],1
          jae @F
            mov word ptr es:[di],0ffffh
            jmp Donepixel
          @@:
          mov word ptr es:[di],0

        .elseif BitsPerPixel == 24 || BitsPerPixel == 32
          rol word ptr [si],1
          jae @F
            mov word ptr es:[di],255
            mov byte ptr es:[di+2],0
            rol word ptr [bx],1
            jmp Donepixel
          @@:
          rol word ptr [bx],1
          jae @F
            mov word ptr es:[di],0ffffh
            mov byte ptr es:[di+2],0ffh
            jmp Donepixel
          @@:
          mov word ptr es:[di],0
          mov byte ptr es:[di+2],0
       .endif

Donepixel:

        add di,BytesPP
        dec ch
        jnz MaskScan

        add bx,2
        add si,2
        dec cl
        jnz Mouseloop

        mov MouseGonoff,0           ;turn mouse cursor generator off

        cmp bx,0
        jz @F
        call SVGAmouseOn
@@:

        retf
MouseCursorGenerator endp

;#############################################################################
;SVGAmouseX
;
;  returns mouse x pos
;#############################################################################
PUBLIC SVGAmouseX
SVGAmouseX proc    BASIC
         mov ax,Mx
         retf
SVGAmouseX endp

;#############################################################################
;SVGAmouseY
;
;  returns mouse y pos
;#############################################################################
PUBLIC SVGAmouseY
SVGAmouseY proc    BASIC
         mov ax,My
         retf
SVGAmouseY endp

;#############################################################################
;SVGAmouseB
;
;  returns mouse Button status
;#############################################################################
PUBLIC SVGAmouseB
SVGAmouseB proc    BASIC
         mov ax,Mb
         retf
SVGAmouseB endp

;#############################################################################
;SetLocation (X, Y)
;
;  
;#############################################################################
PUBLIC SetLocation
SetLocation proc    BASIC
        push bp
        mov bp,sp

        xor bx,bx
        cmp Status,0
        jz @F
        call SVGAmouseOff
        mov bx,1
@@:
        mov ax,4
        mov cx,[bp+08]
        mov dx,[bp+06]
        mov Mx,cx
        mov My,dx
        int 33h

        cmp bx,0
        jz @F
        call SVGAmouseOn
@@:
        pop bp
        retf 4
SetLocation endp



;#############################################################################
;SVGAmouseOff
;
;  returns nothing
;#############################################################################
PUBLIC SVGAmouseOff
SVGAmouseOff proc    BASIC

         cmp Status,0
         jz MouseIsOff

         mov Status,0

         push BMapStatus
         mov BMapStatus,0

         push ActivePageX
         push ActivePageY
         mov ax,ViewPageX
         mov ActivePageX,ax
         mov ax,ViewPageY
         mov ActivePageY,ax

         push MaskColor
         mov MaskColor,-1

         push TMx
         push TMy
         push offset CursorBufferX
         push @fardata?;@code
         call SVGAput

         pop MaskColor

         pop ActivePageY
         pop ActivePageX
         pop BMapStatus

MouseIsOff:
         retf
SVGAmouseOff endp


;#############################################################################
;SVGAmouseOn
;
;  returns nothing
;#############################################################################
PUBLIC SVGAmouseOn
SVGAmouseOn proc    BASIC
         push eax
         mov ax,03
         int 33h
         mov Mx,cx
         mov My,dx

         cmp MouseGonoff,0
         jz @F
         call MouseCursorGenerator
@@:

         cmp Status,1
         jz MouseIsOn

         mov Status,1

         push ActivePageX
         push ActivePageY
         mov ax,ViewPageX
         mov ActivePageX,ax
         mov ax,ViewPageY
         mov ActivePageY,ax

         mov ax,Mx
         mov bx,My

         push ax       ;save Mx and My 
         push bx

         mov TMx,ax
         mov TMy,bx

         add ax,15;CursorBufferX
         add bx,15;CursorBufferY
         push ax       ;save X2 and Y2 
         push bx

         mov TMx1,ax
         mov TMy1,bx

         push offset CursorBufferX
         push @fardata?;@code

         call SVGAget

         push MaskColor
         mov eax,MColorMask
         mov MaskColor,eax

         push TMx                 ;save Y1
         push TMy                 ;save X1
         push offset CursorX      ;save offset 
         push @fardata?;@code               ;save segment 
         call SVGAput

         pop MaskColor
     

         pop ActivePageY 
         pop ActivePageX

MouseIsOn:
         pop eax
         retf
SVGAmouseOn endp


;#############################################################################
;SVGAupdatemouse
;
;  returns nothing
;#############################################################################
PUBLIC SVGAupdatemouse
SVGAupdatemouse proc    BASIC
;         push eax

         cmp Status,0
         jz MouseIsOff1

         mov ax,Mx
         cmp TMx,ax
         jnz updatemouse

         mov ax,My
         cmp TMy,ax
         jnz updatemouse

         jmp Noupdate

updatemouse:
          call Svgamouseoff
          call Svgamouseon

;         jmp Noupdate

;         push ActivePageX
;         push ActivePageY
;         mov ax,ViewPageX
;         mov ActivePageX,ax
;         mov ax,ViewPageY
;         mov ActivePageY,ax

;         push MaskColor
;         mov MaskColor,-1

;         push BMapStatus
;         mov BMapStatus,0

;         push TMx
;         push TMy
;         push offset CursorBufferX
;         push @fardata?;@code
;         call SVGAput

;         pop BMapStatus
;         pop MaskColor


;         mov ax,Mx
;         mov bx,My
;         push ax
;         push bx

;         mov TMx,ax
;         mov TMy,bx
;         add ax,15;CursorBufferX
;         add bx,15;CursorBufferY
;         push ax
;         push bx
;         mov TMx1,ax
;         mov TMy1,bx
;         push offset CursorBufferX
;         push @fardata?;@code
;         call SVGAget

;         push MaskColor
;         mov eax,MColorMask
;         mov MaskColor,eax

;         push TMx
;         push TMy
;         push offset CursorX
;         push @fardata?;@code
;         call SVGAput

;         pop MaskColor

;         pop ActivePageY
;         pop ActivePageX

MouseIsOff1:
Noupdate:
;         pop eax
         retf
SVGAupdatemouse endp


;#############################################################################
;SVGAmousemask (C)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAmousemask
SVGAmousemask proc    BASIC
        ;push bp
        mov bx,sp
        push eax
        mov eax,[bx+6]                  ;maskcolor
        mov MColorMask,eax
        pop eax
        ;pop bp
        retf 4
SVGAmousemask endp

;#############################################################################
;SVGAMouseShape (ShapeOffset, ShapeSegment)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAMouseShape
SVGAMouseShape proc    BASIC

        call SVGAmouseOff

        push bp
        mov bp,sp
        push es
        push eax

        mov si,[bp+08]
        mov ax,@fardata?;@code
        mov es,ax
        mov di,offset Cursor

        mov es:[CursorX],15
        mov es:[CursorY],15
        mov es:[CursorBufferX],15
        mov es:[CursorBufferY],15
        mov es:[TempCursorBufferX],15
        mov es:[TempCursorBufferY],15

        mov ax,256
        mov cl,XShiftFactor
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,256
        .endif

        shr ax,2
        mov cx,ax

        push ds
        mov dx,[bp+06]
        mov ds,dx
        rep movsd                   ;move new mouse shape into Cursor
        pop ds

        mov MouseGonoff,0           ;turn mouse cursor generator off
        pop eax
        pop es
        
        pop bp

        call SVGAmouseOn

        retf 4
SVGAMouseShape endp


;#############################################################################
;SetMouseRange (X1%,Y1%,X2%,Y2%)
;
;  returns nothing
;#############################################################################
PUBLIC SetMouseRange
SetMouseRange proc    BASIC
        push bp
        mov bp,sp

        mov ax,[bp+12]
        cmp ax,[bp+08]
        jl @F
        xchg ax,[bp+08]
        xchg ax,[bp+12]
@@:
        mov ax,[bp+10]
        cmp ax,[bp+06]
        jl @F
        xchg ax,[bp+06]
        xchg ax,[bp+10]
@@:
        mov ax,7
        mov cx,[bp+12]
        mov dx,[bp+08]
        int 33h

        mov ax,8
        mov cx,[bp+10]
        mov dx,[bp+06]
        int 33h

        pop bp
        retf 8
SetMouseRange endp

;#############################################################################
;SetMouseSensitivity (H%,V%)
;
;  returns nothing
;#############################################################################
PUBLIC SetMouseSensitivity
SetMouseSensitivity proc    BASIC
        push bp
        mov bp,sp
        mov ax,1Ah
        mov bx,[bp+08]
        mov cx,[bp+06]
        mov dx,64
        int 33h
        pop bp
        retf 4
SetMouseSensitivity endp


END
