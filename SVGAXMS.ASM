;#############################################################################
;
;                   XMS/SVGA routines made by Future Software
;                            for BASIC programming 
;
;#############################################################################

.model medium
.stack 10h
.386
EXTRN MoveToXMS:FAR
EXTRN MoveFromXMS:FAR

EXTRN XResolution:word
EXTRN YResolution:word
EXTRN BytesPerScanLine:word
EXTRN OffsetDATA:word
EXTRN SegmentDATA:word
EXTRN VideoSegment:word
EXTRN ActivePageX:word
EXTRN ActivePageY:word
EXTRN BytesPP:word
EXTRN XshiftFactor:byte
EXTRN MaskColor:dword
EXTRN BitsPerPixel:byte

EXTRN BMapStatus:word
EXTRN BMapSEG:word
EXTRN BMapOFF:word

EXTRN SetVESABank:FAR
EXTRN SetEMSBank:FAR
EXTRN IsXMSinstalled:FAR

.data
EXTRN X1VP:word
EXTRN Y1VP:word
EXTRN X2VP:word
EXTRN Y2VP:word

EXTRN XMSControl:dword

ByteLength       dd  0   ; 32-bit number of bytes to transfer
SourceHandle     dw  0   ; Handle of source block
SourceOffset     dd  0   ; 32-bit offset into source 
DestHandle       dw  0   ; Handle of destination block
DestOffset       dd  0   ; 32-bit offset into destination block

D1               dd 0
D2               dd 0
X1               dw 0
Y1               dw 0
X2               dw 0
Y2               dw 0
temp1            dw 0
temp2            dw 0
temp3            dw 0
temp4            dd 0
temp             dd 0
xmsxdim          dw 0
xmsydim          dw 0


bytemem          db 0
.code

;#############################################################################
;SetXMSsize (Xsize, Ysize, handle%)
;             
;    returns nothing     (moves x/y data into the 4 four bytes of the handle)
;#############################################################################
PUBLIC SetXMSsize
SetXMSsize  proc    BASIC
        mov bx,sp

        mov ax,[bx+06]
        mov cx,[bx+08]
        mov xmsydim,ax
        mov xmsxdim,cx

        mov ax,[bx+04]
        push ax             
        mov ax,@data
        push ax
        mov ax,offset xmsxdim
        push ax
        mov eax,4
        push eax               
        mov eax,0
        push eax
        call MoveToXMS

        retf 6
SetXMSsize endp


;#############################################################################
;SVGAxmsput (XMSoffset, tempbuffersegment, tempbufferoffset, X, Y, xmshandle, DimX, DimY)   
;
;  returns nothing                 
;#############################################################################
PUBLIC SVGAxmsput
SVGAxmsput proc    BASIC
        push bp
        mov bp,sp
        push fs
        push eax
        push ebx
        push ecx
        push edx

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:

        mov ax,[bp+10]    ;handle         ;get xms picture dimenstion
        push ax                           ;
        mov ax,@data                      ;
        push ax                           ;
        mov ax,offset xmsxdim             ;
        push ax                           ;
        mov eax,4                         ;
        push eax                          ;
        mov eax,0                         ;start offset (0)  
        push eax                          ;
        call MoveFromXMS                  ;

        mov eax,[bp+20]  ;now index
        mov temp4,eax

        xor eax,eax
        mov ax,xmsxdim
        inc eax
        mov temp,eax

        xor eax,eax
        mov ax,xmsydim
        inc eax
        mul temp
        mul temp4
        mov temp4,eax

        mov cl,XshiftFactor

        mov ax,[bp+16]
        mov OffsetDATA,ax
        mov ax,[bp+18]
        mov fs,ax
        mov SegmentDATA,ax

        mov ax,[bp+10]
        mov SourceHandle,ax

        mov eax,temp4        ;picture start offset in pixels
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp4
        .endif

        mov SourceOffset,eax
        add SourceOffset,4

        mov DestHandle,0

        mov ax,VideoSegment
        mov es,ax
        mov word ptr [DestOffset+2],ax 

        mov ax,[bp+14]    ;X
        mov X1,ax
        mov ax,xmsxdim    ;[bp+08]    ;DIMX
        mov dx,ax         ;dx=delta_x-1
        add ax,X1         
        mov X2,ax

        inc dx            ;dx=delta_x
        mov temp3,dx
        shl dx,cl
        .if BitsPerPixel == 24
            add dx,temp3
        .endif

        cmp ax,X1VP;0
        jl XmsNoput
        
        mov ax,[bp+12]    ;Y
        mov Y1,ax
        mov ax,xmsydim    ;[bp+06]    ;DIMY
        add ax,Y1
        mov Y2,ax

        cmp ax,Y1VP;0
        jl XmsNoput
    
        mov ax,X2
        cmp ax,X2VP;XResolution
        jl  @F
        mov ax,X2VP;XResolution
        dec ax
        mov X2,ax
@@:
       

        mov ax,X1
        cmp ax,X1VP;0
        jge  @F
        sub ax,X1VP

        neg ax                ;clip left
        mov temp3,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp3
        .endif

        add OffsetDATA,ax
        cwde                  ;ax->eax
        add SourceOffset,eax  
        mov ax,X1VP
        mov X1,ax;0
@@:

        mov ax,X2
        sub ax,X1
        inc ax
        mov temp1,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp1
        .endif
        cwde
        mov ByteLength,eax
        
        mov ax,X1
        cmp ax,X2VP;XResolution
        jge XmsNoput
        mov ax,Y1
        cmp ax,Y2VP;YResolution
        jge XmsNoput

        mov ax,xmsxdim;[bp+08]
        inc ax
        mov temp3,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp3
        .endif
        cwde
        mov d1,eax             ;SourceOffset increasement per scanline

        mov ax,Y2VP;YResolution
        cmp ax,Y2
        jg @F
        dec ax
        mov Y2,ax
@@:

        mov ax,Y1
        cmp ax,Y1VP;0
        jge @F
        sub ax,Y1VP
        neg ax
        cwde                  ;ax->eax
        xor ebx,ebx
        mov bx,dx
        mul ebx
        add SourceOffset,eax          
        mov ax,Y1VP
        mov Y1,ax;0
@@:

        mov bx,X1
        mov ax,Y1
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine
        
        mov temp3,bx
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp3
        .endif

        add ax,bx
        adc dx,0

        mov di,ax
        mov word ptr [DestOffset],di   

        mov bp,Y1

        mov ax,BytesPerScanLine
        mov bx,temp1
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp1
        .endif
        sub ax,bx
        mov temp2,ax

        mov ax, OffsetDATA
        mov word ptr [D2],ax   
        mov bx, SegmentDATA
        mov word ptr [D2+2],bx   


Xmsputloop:      ;all clipping have been done outside the main loop

        cmp VideoSegment,0a000h
        jnz EMSIsActive69
        push dx
        Call SetVESABank
        pop dx
        jmp @F
EMSIsActive69:
        push dx
        Call SetEMSBank
        pop dx
@@:

        .if BMapStatus > 0
          jmp @F
        .endif
        
        cmp MaskColor,0            ;if filter is on, always use single byte
        jge @F                     ;put

        mov bx,temp1
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp1
        .endif
        add bx,di                  ;do we at any time cross a bank border?
        jae DoXmsBlit              ;if no, then blit

@@:
        mov cx,temp1
        push DestOffset

        mov eax,D2
        mov DestOffset,eax

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        mov ax, OffsetDATA
        mov si,ax
        xor eax,eax
        mov bx,BytesPP

Xmspixelloop:
        .if bx == 1
          mov al,fs:[si]
        .elseif bx == 2
          mov ax,fs:[si]
        .elseif bx == 3
          mov eax,fs:[si]
          and eax,00ffffffh
        .elseif bx == 4
          and eax, 0ffffffh
          mov eax,fs:[si]
        .endif

        cmp MaskColor,0
        jl XmsfilterOff
        cmp MaskColor,eax
        jz XmsFilerOut
XmsFilterOff:

        .if bx == 1
              .if BMapStatus == 1
                mov bx,BmapSEG
                mov gs,bx
                mov bl,es:[di]
                mov bh,al
                add bx,BMapOFF
                mov al,gs:[bx]
                mov bx,1
              .endif
          mov es:[di],al
        .elseif bx == 2
           .if BMapStatus > 0 
              .if BitsPerPixel == 16
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus

                      xor ebx,ebx
                      and eax,0FFFFh
                      mov bx, es:[di];BGB              ;get background color

                      shl eax,11
                      shl ebx,11
                      shr ax,3
                      shr bx,3
                      shr eax,6
                      shr ebx,6
                      shr ax,2
                      shr bx,2
                                                       
                      and ebx, 000111110011111100011111b

                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00011111b
                      and bl, 00011111b
                      ;shl al,3
                      ;shl bl,3
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      ;shr al,3
                      ;shr bl,3
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00111111b
                      and bl, 00111111b
                      ;shl al,2
                      ;shl bl,2
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      ;shr al,2
                      ;shr bl,2
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00011111b
                      and bl, 00011111b
                      ;shl al,3
                      ;shl bl,3
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      ;shr al,3
                      ;shr bl,3
                      mov ah,al
                      shr eax,8

                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     

                      mov es:[di],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16
              .else
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
              

                      xor ebx,ebx
                      and eax,0FFFFh
                      mov bx, es:[di];BGB              ;get background color
                      shl eax,11  
                      shl ebx,11
                      shr ax,3    
                      shr bx,3
                      shr eax,5   
                      shr ebx,5
                      shr ax,3    
                      shr bx,3

                      and ebx, 000111110001111100011111b

                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00011111b
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00011111b
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      xor bh, bh
                      and al, 00011111b
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      mov ah,al
                      shr eax,8

                      shl ax,3
                      shl eax,5      
                      shl ax,3       
                      shr eax,11     

                      mov es:[di],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16

              .endif
              mov bx,2
           .else
              mov es:[di],ax
           .endif
        .elseif bx == 3
           .if di <= 1111111111111100b
              mov es:[di],ax
              shr eax,16
              mov es:[di+2],al
           .else
              mov bytemem,3

              pixel_xmsput24:
              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push dx
              push bx
              push cx
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop cx
              pop bx
              pop dx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_xmsput24
              add si,bx
             jmp NoInc210219

           .endif
        .elseif bx == 4
           .if BMapStatus > 0 

              shl edx,16
              shl ecx,16

              mov cx,BMapStatus

              mov ebx, es:[di];BGB              ;get background color
              rol eax,16      ;GB*R
              rol ebx,16      ;GB*R
              xor ah, ah                        ;Clear ah
              xor bh, bh
              sub ax, bx                        ;(Signed) Subtract the Background Blue value
              mul cx                            ;Multiply it by the alpha blend (0 to 255)
              sar ax, 8                         ;(Signed) Divide by 256
              add ax, bx                        ;(Signed) Add the Background Blue value
              mov ah,al

              rol eax,8       ;Br*G
              rol ebx,8       ;Br*G
              xor ah, ah                        ;Clear ah
              xor bh, bh
              sub ax, bx                        ;(Signed) Subtract the Background Green value
              mul cx                            ;Multiply it by the alpha blend (0 to 255)
              sar ax, 8                         ;(Signed) Divide by 256
              add ax, bx                        ;(Signed) Add the Background Green value
              mov ah,al

              rol eax,8       ;rg*B
              rol ebx,8       ;rg*B
              xor ah, ah                        ;Clear ah
              xor bh, bh
              sub ax, bx                        ;(Signed)Subtract the Background Red value
              mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
              sar ax, 8                         ;(Signed)Divide by 256
              add ax, bx                        ;(Signed)Add the Background Red value
              mov ah,al
              shr eax,8
              mov es:[di],eax                   ;draw result colors

              shr ecx,16
              shr edx,16

              mov bx,4
           .endif
           mov es:[di],eax

        .endif

XmsFilerOut:

        add si,bx
        add di,bx
        jae NoInc210219
        inc dx
        push eax
        push cx
        push dx
        push bx
        cmp VideoSegment,0a000h
        jnz EMSIsActive79
        Call SetVESABank
        jmp @F
EMSIsActive79:
        Call SetEMSBank
@@:
        pop bx
        pop dx
        pop cx
        pop eax
NoInc210219:
        dec cx
        jnz Xmspixelloop   ;if zero then done
        pop DestOffset

        jmp XmsDoneline
DoXmsBlit:

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]
        
        add di,word ptr ByteLength
XmsDoneline:

        add di,temp2
        adc dx,0

        mov word ptr [DestOffset],di

        mov eax,d1
        add SourceOffset,eax

        inc bp
        cmp bp,Y2
        jle Xmsputloop
XmsNoput:

        pop edx
        pop ecx
        pop ebx
        pop eax
        pop fs
        pop bp
        retf 18
SVGAxmsput endp


;#############################################################################
;SVGAxmsget (XMSoffset, tempbuffersegment, tempbufferoffset, X, Y, xmshandle, DimX, DimY)   
;
;  returns nothing                 
;#############################################################################
PUBLIC SVGAxmsget
SVGAxmsget proc    BASIC

        push bp
        mov bp,sp
        push fs
        push eax
        push edx

        cmp XMSControl,0
        jnz @F
        call IsXMSinstalled
@@:
        mov eax,[bp+20]  ;now index
     .if eax == 0                ;if index?
        mov ax,[bp+06]           ;save xdim and ydim in xms
        mov xmsydim,ax           ;
        mov ax,[bp+08]           ;
        mov xmsxdim,ax           ;

        mov ax,[bp+10]
        push ax             
        mov ax,@data
        push ax
        mov ax,offset xmsxdim
        push ax
        mov eax,4
        push eax               
        mov eax,0
        push eax
        call MoveToXMS
      .else
        mov ax,[bp+10]    ;handle         ;get xms picture dimenstion
        push ax                           ;
        mov ax,@data                      ;
        push ax                           ;
        mov ax,offset xmsxdim             ;
        push ax                           ;
        mov eax,4                         ;
        push eax                          ;
        mov eax,0                         ;start offset (0)  
        push eax                          ;
        call MoveFromXMS                  ;
      .endif

        mov eax,[bp+20]  ;now index
        mov temp4,eax

        xor eax,eax
        mov ax,xmsxdim
        inc eax
        mov temp,eax

        xor eax,eax
        mov ax,xmsydim
        inc eax
        mul temp
        mul temp4
        mov temp4,eax


        mov cl,XshiftFactor

        mov ax,[bp+16]
        mov OffsetDATA,ax
        mov ax,[bp+18]
        mov fs,ax
        mov SegmentDATA,ax

        mov ax,[bp+10]
        mov DestHandle,ax

        mov SourceHandle,0

        mov eax,temp4
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp4
        .endif
        mov DestOffset,eax
        add DestOffset,4

        mov ax,VideoSegment
        mov es,ax
        mov word ptr [SourceOffset+2],ax ;update segment

        mov ax,[bp+14]    ;X
        mov X1,ax
        mov ax,[bp+08]
        mov dx,ax         ;dx=delta_x-1
        add ax,X1         
        mov X2,ax

        inc dx            ;dx=delta_x
        mov temp3,dx
        shl dx,cl
        .if BitsPerPixel == 24
            add dx,temp3
        .endif

        cmp ax,0
        jl XmsNoget
        
        mov ax,[bp+12]    ;Y
        mov Y1,ax
        mov ax,[bp+06]
        add ax,Y1
        mov Y2,ax

        cmp ax,0
        jl XmsNoget
    
        mov ax,XResolution
        cmp ax,X2
        jg  @F
        dec ax
        mov X2,ax
@@:
        

        mov ax,X1
        cmp ax,0
        jge  @F
        neg ax                ;clip left 
        mov temp3,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp3
        .endif

        add OffsetDATA,ax
        cwde                  ;ax->eax
        add DestOffset,eax  
        mov X1,0
@@:

        mov ax,X2
        sub ax,X1
        inc ax
        mov temp1,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp1
        .endif

        cwde
        mov ByteLength,eax
        
        mov ax,X1
        cmp ax,XResolution
        jge XmsNoget
        mov ax,Y1
        cmp ax,YResolution
        jge XmsNoget

        mov ax,[bp+08]
        inc ax
        mov temp3,ax
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp3
        .endif
        cwde
        mov d1,eax            ;DestOffset increasement per scanline

        mov ax,Y1
        cmp ax,0
        jge @F
        neg ax
        cwde                  ;ax->eax
        mov temp,0
        mov word ptr [temp],dx
        mul temp
        add DestOffset,eax          
        mov Y1,0
@@:

        mov ax,YResolution
        cmp ax,Y2
        jg @F
        dec ax
        mov Y2,ax
@@:

        mov bx,X1
        mov ax,Y1
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine
        
        mov temp3,bx
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp3
        .endif

        add ax,bx
        adc dx,0

        mov di,ax
        mov word ptr [SourceOffset],di   

        mov bp,Y1

        mov ax,BytesPerScanLine
        mov bx,temp1
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp1
        .endif

        sub ax,bx
        mov temp2,ax

        mov ax, OffsetDATA
        mov word ptr [D2],ax   
        mov bx, SegmentDATA
        mov word ptr [D2+2],bx   


Xmsgetloop:      ;all clipping have been done outside the main loop

        cmp VideoSegment,0a000h
        jnz EMSIsActive699
        push dx
        Call SetVESABank
        pop dx
        jmp @F
EMSIsActive699:
        push dx
        Call SetEMSBank
        pop dx
@@:

        mov ax,temp1
        mov cl,XshiftFactor
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp1
        .endif

        add ax,di                  ;do we at any time cross a bank border?
        jae DoXmsgetBlit           ;if no, then blit

        mov cx,temp1
        push SourceOffset

        mov eax,D2
        mov SourceOffset,eax

        mov ax,OffsetDATA
        mov si,ax
        mov bx,BytesPP
Xmspixelgetloop:

        .if bx == 1
          mov al,es:[di]
          mov fs:[si],al
        .elseif bx == 2
          mov ax,es:[di]
          mov fs:[si],ax
        .elseif bx == 3
           .if di <= 1111111111111100b
             mov eax,es:[di]
             mov fs:[si],ax
             shr eax,16
             mov fs:[si+2],al
           .else
              mov bytemem,3

              pixel_xmsget24:
              mov al,es:[di]
              add di,1
              jnc @F
              inc dx
              push eax
              push dx
              push bx
              push cx
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop cx
              pop bx
              pop dx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_xmsget24
              ror eax,8
              mov fs:[si],ax
              shr eax,16
              mov fs:[si+2],al
              add si,bx
              jmp NoInc2102199
           .endif

        .elseif bx == 4
          mov eax,es:[di]
          mov fs:[si],eax
        .endif

        add si,bx
        add di,bx
        jae NoInc2102199
        inc dx
        push ax
        push cx
        push dx
        push bx
        cmp VideoSegment,0a000h
        jnz EMSIsActive799
        Call SetVESABank
        jmp @F
EMSIsActive799:
        Call SetEMSBank
@@:
        pop bx
        pop dx
        pop cx
        pop ax
NoInc2102199:
        dec cx
        jnz Xmspixelgetloop   ;if zero then done

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        pop SourceOffset

        jmp XmsDonegetline
DoXmsgetBlit:

        mov si,offset ByteLength
        mov ah,0bh
        call [XMSControl]

        add di,word ptr ByteLength
XmsDonegetline:

        add di,temp2
        adc dx,0

        mov word ptr [SourceOffset],di

        mov eax,d1
        add DestOffset,eax
            
        inc bp
        cmp bp,Y2
        jle Xmsgetloop
XmsNoget:

        pop edx
        pop eax
        pop fs
        pop bp
        retf 18
SVGAxmsget endp

END
