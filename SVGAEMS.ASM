;#############################################################################
;
;                SVGA/EMS routines made by Future Software
;                          for BASIC programming 
;
;#############################################################################

.model medium
.stack 20h
.386
.mmx

EXTRN XResolution:word
EXTRN YResolution:word
EXTRN BytesPerScanLine:word
EXTRN VideoSegment:word
EXTRN ActivePageX:word
EXTRN ActivePageY:word
EXTRN BytesPP:word
EXTRN XshiftFactor:byte
EXTRN MaskColor:dword
EXTRN BitsPerPixel:byte
EXTRN textwrapOnOff:byte

EXTRN BMapStatus:word
EXTRN BMapSEG:word
EXTRN BMapOFF:word

EXTRN X1VP:word
EXTRN Y1VP:word
EXTRN X2VP:word
EXTRN Y2VP:word

EXTRN ActiveEMSBuffer:word    ;EMS handle
EXTRN EMShandle:word
EXTRN Curlogpage:word
EXTRN EMSActiveBank:word

EXTERN Vmem64kBankpos:Word
EXTERN Globalbank:Word

EXTRN SetVESABank:FAR
EXTRN SetEMSBank:FAR
EXTRN SVGAhlinetext:FAR
EXTRN SVGAhlinetextREAD:FAR
EXTRN SVGAput:FAR

EXTRN MMXStatus:word

.data

ALIGN 2
X1               dw  0
Y1               dw  0
X2               dw  0
Y2               dw  0
X3               dw  0
Y3               dw  0

U1               dw  0
V1               dw  0
U2               dw  0
V2               dw  0
U3               dw  0
V3               dw  0
Lu               dw  0
Ru               dw  0
Lv               dw  0
Rv               dw  0

temp1            dw  0
temp2            dw  0
temp3            dw  0

Xres             dw  0
MapSizeX         dw  0

SegmentDATA      dw  0
OffsetDATA       dw  0
SegmentDATA1     dw  0
OffsetDATA1      dw  0

temp6            dw  0

ud               dd  0
vd               dd  0
cd1              dd  0
cd2              dd  0
cd3              dd  0
temp             dd  0
temp7            dd  0
d1               dd  0
d2               dd  0
d3               dd  0
ud1              dd  0
ud2              dd  0
ud3              dd  0
vd1              dd  0
vd2              dd  0
vd3              dd  0

d                dw  0
dd1              dw  0

textureX         dw  0
textureY         dw  0
textureXSize     dd  255
textureYSize     dd  255
textureBitSize   db  8

UniColor         dd  0
UniColor1        dd  0
UniColor2        dd  0


tempEMSxdim      dw 0
tempEMSydim      dw 0

Pageframe        dw 0

handle1          dw 0
handle2          dw 0
bank1            dw 0
bank2            dw 0

RegionLength     dd 4000h
SMemeType        db 1    ;1=Expanded memory
Shandle          dw 0
Soffset          dw 0    ;offset from logical page
Ssegment         dw 0    ;logical pagenumber
DMemeType        db 0    ;0=Conventional memory
Dhandle          dw 0
DOffset          dw 0    ;Conventional buffer offset
DSegment         dw 0    ;Conventional buffer segment
;this data structure is use to move data from EMS memory to 
;conventional memory. Data from the buffer can then be copied back  
;into another ems page, allowing drawing of EMS data over EMS data
GetRegionLength     dd 4000h
GetSMemeType        db 0    ;0=Conventional memory
GetShandle          dw 0
GetSoffset          dw 0    ;Conventional buffer offset
GetSsegment         dw 0    ;Conventional buffer segment
GetDMemeType        db 1    ;1=Expanded memory
GetDhandle          dw 0
GetDOffset          dw 0    ;offset from logical page  
GetDSegment         dw 0    ;logical pagenumber     


.code

emsEMShandles    dw 255 dup(0)  ;Used to look up emshandles assosiated with a page.
                                ;The page number is used as the index to look up the ems handle.

emsDIMxyArray    dw 512 dup(-1) ;Used to look up the size of an ems map.
                                ;the emshandle is used as an index.

                                ;Index at handle*4bytes.

                                ;Also used to determine if a handle have been
                                ;allocated by the library,
                                ;(X=-1 and Y=-1) = not allocated
                                ;(X>=0 and Y>=0) = allocated.
svgabuffer       db 4000h dup(0);buffer for ems data

;#############################################################################
;ResetEMS 
;             
;    returns nothing            
;#############################################################################
PUBLIC ResetEMS
ResetEMS  proc    BASIC
        mov EMShandle,-1
        mov Curlogpage,-1
        mov EMSActiveBank,-1
        mov Vmem64kBankpos,-1
        mov Globalbank,-1
ResetEMS endp

;#############################################################################
;GetEMSX (handle%)
;             
;    returns ems x size         
;#############################################################################
PUBLIC GetEMSX
GetEMSX  proc    BASIC
        mov bx,sp

        mov cx,[bx+04]
        shl cx,2
        mov bx,offset emsDIMxyArray
        add bx,cx
        mov ax,cs:[bx]
        
        retf 2
GetEMSX endp

;#############################################################################
;GetEMSY (handle%)
;             
;    returns ems y size
;#############################################################################
PUBLIC GetEMSY
GetEMSY  proc    BASIC
        mov bx,sp

        mov cx,[bx+04]
        shl cx,2
        mov bx,offset emsDIMxyArray
        add bx,cx
        mov ax,cs:[bx+2]

        retf 2
GetEMSY endp

;#############################################################################
;SetEMS (X%,Y%, handle%)
;             
;    returns nothing            
;#############################################################################
PUBLIC SetEMS
SetEMS  proc    BASIC
        mov bx,sp

        mov cx,[bx+04];handle
        shl cx,2
        mov dx,[bx+06];y
        mov ax,[bx+08];x

        mov bx,offset emsDIMxyArray
        add bx,cx
        mov cs:[bx],ax
        mov cs:[bx+2],dx

        retf 6
SetEMS endp



;#############################################################################
;SetEMSpage (page%)
;             
;    returns nothing            
;#############################################################################
PUBLIC SetEMSpage
SetEMSpage  proc    BASIC
        push bp
        mov bp,sp

        mov bx,offset emsEMShandles
        mov ax,[bp+06]
        shl ax,1
        add bx,ax
        mov cx,cs:[bx]  ;get the ems handle
        push cx

        mov bx,offset emsDIMxyArray
        shl cx,2
        add bx,cx
        mov cx,cs:[bx]  ;get x 
        inc cx
        push cx

        mov cx,cs:[bx+2] ;get y
        inc cx
        push cx

        call SetActiveEMSBuffer

        pop bp
        retf 2
SetEMSpage endp


;#############################################################################
;SetActiveEMSBuffer (handle, X%, Y%)
;             
;    returns nothing            
;#############################################################################
PUBLIC SetActiveEMSBuffer
SetActiveEMSBuffer  proc    BASIC
        push bp
        mov bp,sp

        mov ax,4100h            ;get page frame address
        int 67h
        or ah,ah
        jnz @F
        mov VideoSegment,bx     

        mov ax,[bp+10]
        mov ActiveEMSBuffer,ax
        mov Globalbank,-1
        mov EMSActiveBank,-1      ;forces an EMS bank switch next time
                                  ;it is used
        mov ActivePageX,0
        mov ActivePageY,0

        mov ax,[bp+08]
        mov XResolution,ax
;        cmp X2VP,ax
;        jle Xnotgreater
        mov X2VP,ax
;Xnotgreater:
        mov cl,XshiftFactor
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,X2VP
        .endif

        mov BytesPerScanLine,ax

        mov ax,[bp+06]
        mov YResolution,ax
;        cmp Y2VP,ax
;        jle Ynotgreater
        mov Y2VP,ax
;Ynotgreater:

@@:
        pop bp
        retf 6
SetActiveEMSBuffer endp


;#############################################################################
;DefineEMSbufferSize (EMShandle%, Xsize%, Ysize%, pagenumber%)
;             
;    returns nothing            
;#############################################################################
PUBLIC DefineEMSbufferSize
DefineEMSbufferSize  proc    BASIC
        push bp
        mov bp,sp

;        push Y2VP
;        push X2VP

        mov ax,@code
        mov es,ax
        mov bx,offset emsEMShandles
        mov ax,[bp+06]
        shl ax,1
        add bx,ax
        mov ax,[bp+12]   ;ems handle
        mov es:[bx],ax   ;save handle into page table
        push ax

        mov bx,offset emsDIMxyArray
        mov ax,[bp+12]
        shl ax,2
        add bx,ax

        mov ax,[bp+10]
        mov es:[bx],ax         ;X
        inc ax
        push ax

        mov ax,[bp+08]
        mov es:[bx+2],ax       ;Y
        inc ax
        push ax

        call SetActiveEMSbuffer 

;        pop X2VP
;        pop Y2VP

        pop bp
        retf 8
DefineEMSbufferSize endp


;#############################################################################
;SVGAemsxcopy  (datatype, BufferSeg%, bufferOff%, EMSoffset&, Tx%, Ty%, Handle%, Sx%, Sy%, Sx1%, Sy1%, Xsize%, Ysize%)
;               32        30          28          24          22   20   18       16   14   12    10    8       6
;    returns nothing       datatype = 1 is array type data, this means emsarrayput was called
;#############################################################################
PUBLIC SVGAemsxcopy
SVGAemsxcopy proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx
        push edx


        mov ax,@code
        mov es,ax
        mov bx,offset emsDIMxyArray
        mov ax,[bp+18]
        shl ax,2
        add bx,ax

        mov ax,es:[bx]         ;X
        mov tempEMSxdim,ax
        mov ax,es:[bx+2]       ;Y
        mov tempEMSydim,ax

        mov ax,[bp+10]         ;Y2
        mov Y2,ax
        mov ax,[bp+14]         ;Y1
        mov Y1,ax
        cmp ax,Y2
        JLE @F
        xchg ax,Y2
        xchg ax,Y1
@@:
;        .if ax == Y2
;           xor eax,eax
;           mov ax,tempEMSxdim
;           inc ax
;           mov temp6,ax
;           mov cl,XshiftFactor
;           shl ax,cl
;            .if BitsPerPixel == 24
;                add ax,temp6
;            .endif
;              mov RegionLength,eax
;            .if RegionLength > 4000h
;              mov RegionLength,4000h
;            .endif
;        .else
;            mov RegionLength,4000h
;        .endif


        mov ax,[bp+12]         ;X2
        mov X2,ax
        mov ax,[bp+16]         ;X1
        mov X1,ax
        cmp ax,X2
        JLE @F
        xchg ax,X2
        xchg ax,X1
@@:
        mov ax,[bp+22]
        mov X3,ax
        mov ax,[bp+20]
        mov Y3,ax

        mov ax,tempEMSxdim
        inc ax
        mov temp6,ax
        mov cl,XshiftFactor
        shl ax,cl
        .if BitsPerPixel == 24
            add ax,temp6
        .endif

        mov MapSizeX,ax

        mov ax,X1
        cmp ax,0
        jge @F
        neg ax
        add X3,ax
        mov X1,0
@@:
        mov ax,Y1
        cmp ax,0
        jge @F
        neg ax
        add Y3,ax
        mov Y1,0
@@:
        mov ax,tempEMSxdim;X2VP
        cmp X2,ax
        jle @F
        mov X2,ax
@@:
        mov ax,tempEMSydim;Y2VP
        cmp Y2,ax
        jle @F
        mov Y2,ax
@@:
        mov ax,tempEMSydim
        cmp Y1,ax
        jg NoEmsCopy

        mov ax,Y2VP
        cmp Y1,ax
        jg NoEmsCopy

        mov ax,tempEMSxdim
        cmp X1,ax
        jg NoEmsCopy

        mov ax,X2VP
        cmp X1,ax
        jg NoEmsCopy

        mov ax,Y1VP
        cmp Y2,0
        jl NoEmsCopy
     
        mov ax,X1VP
        cmp X2,0
        jl NoEmsCopy

        ;mov ax,Y1VP       ;gives problems when combined with ViewPort
        ;cmp Y2,ax         ;
        ;jl NoEmsCopy      ;
     
        ;mov ax,X1VP       ;
        ;cmp X2,ax         ;
        ;jl NoEmsCopy      ;

        mov ax,[bp+18]      ;emshandle

        .if Shandle != ax   ;different handle
          mov Ssegment,-1   ;then force a buffer flush/fill
        .endif

        mov Shandle,ax    

        mov ax,X2
        sub ax,X1
        mov Xres,ax
        inc Xres
        mov bx,X3 
        add bx,ax
        mov dd1,bx        ;left X

        xor ebx,ebx
        mov bx,tempEMSxdim
        inc bx

        xor eax,eax
        mov ax,Y1
        mul ebx

        xor ebx,ebx
        mov bx,X1
        add eax,ebx
        mov temp7,eax
        mov cl,Xshiftfactor
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif
        mov temp,eax      ;temp=start addr. in ems memory


        mov eax,[bp+24]   ;add EMSoffset
        mov temp7,eax
        mov cl,Xshiftfactor
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif
        add temp,eax


        mov ax,offset svgabuffer  ;dest buffer offset
        mov DOffset,ax
        mov ax,@code          ;dest buffer segment
        mov DSegment,ax

        mov ax,[bp+32]
        .if ax == 1   ;datatype  (1=array type)
         lessthen16k:
           xor eax,eax
           xor ebx,ebx
           mov ax,tempEMSydim
           inc ax
           mov bx,MapSizeX
           mul ebx
           .if eax <= (4000h-4h)

              mov RegionLength,eax

              mov ax,tempEMSxdim
              mov bx,tempEMSydim
              mov es,DSegment
              mov di,DOffset
              mov es:[di],ax
              mov es:[di+2],bx
              add DOffset,4

              mov eax,temp
              mov bx,ax
              and bx,3fffh
              mov OffsetDATA1,bx
              shr eax,14
              mov Ssegment,ax
              mov ax,OffsetDATA1
              mov Soffset,ax
              mov si,offset RegionLength
              mov ax,5700h
              int 67h

              mov ax,[bp+22]   ;screen Y
              push ax
              mov cx,[bp+20]   ;screen X
              push cx
              push offset svgabuffer  
              push @code
              call SVGAput
              mov Shandle,-1   ;force emshandle reset next time the routineis called.
             jmp NoemsCopy     
           .endif
          mov Soffset,0
          mov RegionLength,4000h
        .else
              mov Soffset,0

              xor eax,eax
              xor ebx,ebx
              mov ax,tempEMSydim
              inc ax
              mov bx,MapSizeX
              mul ebx
             .if eax > (4000h-4h)
                 mov RegionLength,4000h
             .else
                jmp lessthen16k
             .endif
        .endif

        mov bp,Y1
              mov RegionLength,4000h
Emscopyloop:

        mov eax,temp
        mov bx,ax
        and bx,3fffh
        mov OffsetDATA1,bx
        shr eax,14

        ;cmp Curlogpage,ax
        cmp Ssegment,ax
        jz @F

        mov Ssegment,ax
        mov si,offset RegionLength
        mov ax,5700h
        int 67h

        ;mov bx,ax
        ;mov ax,4400h
        ;mov dx,EMShandle
        ;int 67h
@@:

        mov ax,OffsetDATA1
        mov bx,Xres
        mov cl,XShiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,Xres
        .endif
        add ax,bx

        cmp ax,4000h
        jg @F
        push Y3
        push X3
        push dd1
        mov cx,OffsetDATA1
        add cx,offset svgabuffer
        push cx
        push DSegment ;PageFrame
        call SVGAhlinetext 
        jmp nope
@@:

        mov d,ax

        and ax,3fffh

        .if BitsPerPixel == 24
            mov cx,3
            cwd
            div cx
        .else
          mov cl,Xshiftfactor
          shr ax,cl
        .endif
        
        mov dx,Xres
        sub dx,ax
        add dx,X3

        mov temp2,dx
                
        dec dx

        push Y3
        push X3
        push dx
        mov cx,OffsetDATA1
        add cx,offset svgabuffer
        push cx
        push DSegment;PageFrame
        call SVGAhlinetext 

        ;inc Curlogpage
        inc Ssegment

        ;mov ax,Curlogpage
        ;mov Ssegment,ax
        mov si,offset RegionLength
        mov ax,5700h
        int 67h

        ;mov ax,4400h
        ;mov bx,Curlogpage
        ;mov dx,EMShandle
        ;int 67h
        
        cmp d,4000h
        jz nope

        push Y3
        push temp2
        push dd1
        push offset svgabuffer
        push DSegment ;PageFrame
        call SVGAhlinetext 
nope:
        xor eax,eax
        mov ax,MapSizeX

@@:
        inc bp
        inc Y3
        add temp,eax
        cmp Y3,0
        jl @B

        mov ax,YResolution;Y2VP
        cmp Y3,ax
        jg NoemsCopy
        
        cmp bp,Y2
        jle Emscopyloop
EMSerror:
NoemsCopy:
.586
.mmx
        .if MMXStatus == 1
           emms
        .endif
.386
.mmx
        pop edx
        pop ebx
        pop eax
        pop bp
        retf 28
SVGAemsxcopy endp


;#############################################################################
;SVGAemsget  (EMSoffset&, Tx%, Ty%, Handle%, Sx%, Sy%, Sx1%, Sy1%, Xsize%, Ysize%)
;       
;    returns nothing            
;#############################################################################
PUBLIC SVGAemsget
SVGAemsget proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx
        push edx

        .if PageFrame == 0 
        mov ax,4100h                  ;get page frame address
        int 67h
        or ah,ah
        jnz @F
        mov PageFrame,bx
        @@:
        .endif

        mov ax,@code
        mov es,ax
        mov bx,offset emsDIMxyArray
        mov ax,[bp+18]
        shl ax,2
        add bx,ax

        mov ax,[bp+08]
        mov es:[bx],ax         ;X
        mov tempEMSxdim,ax

        mov ax,[bp+06]
        mov es:[bx+2],ax       ;Y
        mov tempEMSydim,ax

        mov ax,[bp+10]
        mov Y2,ax
        mov ax,[bp+14]
        mov Y1,ax
        cmp ax,Y2
        JLE @F
        xchg ax,Y2
        xchg ax,Y1
@@:
        mov ax,[bp+12]
        mov X2,ax
        mov ax,[bp+16]
        mov X1,ax
        cmp ax,X2
        JLE @F
        xchg ax,X2
        xchg ax,X1
@@:
        mov ax,[bp+22]
        mov X3,ax
        mov ax,[bp+20]
        mov Y3,ax

        cmp X1,0
        jge @F
        mov ax,X1
        neg ax
        add X3,ax
        mov X1,0
@@:
        cmp Y1,0
        jge @F
        mov ax,Y1
        neg ax
        add Y3,ax
        mov Y1,0
@@:
        mov ax,tempEMSxdim
        cmp X2,ax
        jle @F
        mov X2,ax
@@:
        mov ax,tempEMSydim
        cmp Y2,ax
        jle @F
        mov Y2,ax
@@:

        mov ax,[bp+18]    ;emshandle

        mov GetDhandle,ax

        cmp EMShandle,ax
        jz @F
        mov Curlogpage,-1
        mov EMShandle,ax
@@:

        mov ax,X2
        sub ax,X1
        mov Xres,ax
        inc Xres
        mov bx,X3 
        add bx,ax
        mov dd1,bx        ;left X

        xor ebx,ebx
        mov bx,tempEMSxdim
        inc bx
        xor eax,eax
        mov ax,Y1
                
        mul ebx

        xor ebx,ebx
        mov bx,X1
        add eax,ebx
        mov temp7,eax
        mov cl,XshiftFactor
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif
        mov temp,eax      ;temp=start addr. in ems memory

        mov eax,[bp+24]  ;add EMSoffset
        mov temp7,eax
        mov cl,Xshiftfactor
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif
        add temp,eax

        mov GetDSegment,-1

        mov ax,[bp+28]    ;source buffer offset
        mov GetSoffset,ax
        mov ax,[bp+30]    ;source buffer segment
        mov GetSSegment,ax

        mov cx,Y1

EmsGetloop:
        push cx

        mov eax,temp
        mov bx,ax
        and bx,3fffh
        mov OffsetDATA1,bx
        shr eax,14

        ;cmp GetDSegment,ax
        ;jz @F
        ;mov GetDSegment,ax
        ;mov si,offset GetRegionLength
        ;mov ax,5700h
        ;int 67h

        cmp Curlogpage,ax
        jz @F
        mov Curlogpage,ax
        mov bx,ax
        mov ax,4400h
        mov dx,EMShandle
        int 67h
@@:

        mov ax,OffsetDATA1
        mov bx,Xres
        mov cl,XShiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,Xres
        .endif

        add ax,bx


        cmp ax,4000h
        jg @F
        push Y3
        push X3
        push dd1
        push OffsetDATA1
        push PageFrame
        call SVGAhlinetextREAD 
        jmp nope1
@@:

        mov d,ax
        mov cl,Xshiftfactor
        and ax,3fffh
;        mov temp6,ax
;        shr ax,cl
;        .if BitsPerPixel == 24
;            shr ax,cl
;            ;add ax,temp6
;        .endif
        .if BitsPerPixel == 24
            ;mov cx,3
            mov ax,3
            ;div 3
            ;sub ax, 12
;          mov cl,Xshiftfactor
;          shr ax,cl
;          shr ax,cl
        .else
          mov cl,Xshiftfactor
          shr ax,cl
        .endif

        mov dx,Xres
        sub dx,ax
        add dx,X3
        mov temp2,dx
        dec dx

        push Y3
        push X3
        push dx
        push OffsetDATA1
        push PageFrame
        call SVGAhlinetextREAD 

        inc Curlogpage
         
        mov ax,4400h
        mov bx,Curlogpage
        mov dx,EMShandle
        int 67h

        cmp d,4000h
        jz nope1

        push Y3
        push temp2
        push dd1
        push 0
        push PageFrame
        call SVGAhlinetextREAD
nope1:
        xor eax,eax
        mov ax,tempEMSxdim
        inc ax
        mov temp7,eax
        mov cl,XshiftFactor
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif

        pop cx

@@:
        inc cx
        add temp,eax
        inc Y3
        cmp Y3,0
        jl @B

        cmp cx,Y2
        jle EmsGetloop
EMSerror1:
mov EMSActiveBank,-1
mov Curlogpage,-1
        pop edx
        pop ebx
        pop eax
        pop bp
        retf 26
SVGAemsget endp

;#############################################################################
;CopyEMSpage  (Tpage%, Spage%)
; 
;    returns nothing            
;#############################################################################
PUBLIC CopyEMSpage
CopyEMSpage proc    BASIC
        push bp
        mov bp,sp

        mov EMShandle,-1
        mov Curlogpage,-1
        mov EMSActiveBank,-1
        mov Vmem64kBankpos,-1
        mov Globalbank,-1
 
        mov ax,@code
        mov es,ax
        mov di,offset emsEMShandles
        mov bx,[bp+06]
        shl bx,1
        mov cx,es:[di+bx] 
        mov handle1,cx
        mov bx,[bp+08]
        shl bx,1
        mov cx,es:[di+bx] 
        mov handle2,cx
;h1
        mov di,offset emsDIMxyArray
        mov bx,handle1
        shl bx,2
        mov ax,es:[di+bx]      ;X1
        inc ax
        mov X1,ax
        mov ax,es:[di+bx+2]    ;Y1
        inc ax
        mov Y1,ax
        xor ebx,ebx
        mov bx,X1
        xor eax,eax
        mov ax,Y1
        mul ebx
        mov cl,Xshiftfactor

        mov temp7,eax
        shl eax,cl

        .if BitsPerPixel == 24
            add eax,temp7
        .endif

        mov temp,eax
        shr temp,14
        mov eax,temp
        mov temp1,ax
;h2
        mov di,offset emsDIMxyArray
        mov bx,handle2
        shl bx,2
        mov ax,es:[di+bx]      ;X1
        inc ax
        mov X1,ax
        mov ax,es:[di+bx+2]    ;Y1
        inc ax
        mov Y1,ax
        xor ebx,ebx
        mov bx,X1
        xor eax,eax
        mov ax,Y1
        mul ebx
        mov cl,Xshiftfactor
        mov temp7,eax
        shl eax,cl
        .if BitsPerPixel == 24
            add eax,temp7
        .endif

        mov temp,eax
        shr temp,14
        mov eax,temp
        mov temp2,ax

        mov ax,4100h            ;get page frame address
        int 67h
        mov es,bx

        mov bank1,0
        mov bank2,0

EMS_move_loop:
       mov ax,bank1
       .if ax <= temp1
          mov dx,handle1
          mov bx,bank1
          mov al,0
          mov ah,44h
          int 67h
          inc bank1
       .else
          jmp done_EMS_mode
       .endif

       mov ax,bank2
       .if ax <= temp2
          mov dx,handle2
          mov bx,bank2
          mov al,1
          mov ah,44h
          int 67h
          inc bank2
       .else
          jmp done_EMS_mode
       .endif

       mov cx,16384
       xor di,di
       mov si,16384
      .if MMXStatus == 1
          shr cx,3
          mmx_move:
            movq MM0,es:[di]
            movq es:[si],MM0
            add di,8
            add si,8
            dec cx
          jnz mmx_move
      .else
          shr cx,2
          eax_move:
            mov eax,es:[di]
            mov es:[si],eax
            add di,4
            add si,4
            dec cx
          jnz eax_move
      .endif

       jmp EMS_move_loop

done_EMS_mode:
        .if MMXStatus == 1
            emms
        .endif
        pop bp
        retf 4
CopyEMSpage endp



;#############################################################################
;EMSSVGAtritext (X1, Y1, X2, Y2, X3, Y3, U1, V1, U2, V2, U3, V3, handle)
;
;    returns nothing                     
;#############################################################################
PUBLIC EMSSVGAtritext
EMSSVGAtritext  proc    BASIC
        push bp

        mov bp,sp

        pushad
        
        mov ax,[bp+06]

        .if Shandle != ax
          mov Ssegment,-1
          mov Shandle,ax
        .endif

        mov ax,[bp+18] ;U1
        mov U1,ax
        mov bx,[bp+16] ;V1
        mov V1,bx
        mov ax,[bp+14] ;U2
        mov U2,ax
        mov bx,[bp+12] ;V2
        mov V2,bx
        mov ax,[bp+10] ;U3
        mov U3,ax
        mov bx,[bp+08] ;V3
        mov V3,bx
                        
        mov ax,[bp+30] ;X1
        mov bx,[bp+28] ;Y1
        mov cx,[bp+26] ;X2
        mov dx,[bp+24] ;Y2
        mov si,[bp+22] ;X3
        mov di,[bp+20] ;Y3

        cmp bx,dx
        jle @F
        xchg bx,dx    
        xchg ax,cx    
        mov bp,u1
        xchg bp,u2
        mov u1,bp
        mov bp,v1
        xchg bp,v2
        mov v1,bp
@@:
        cmp bx,di
        jle @F
        xchg bx,di    
        xchg ax,si
        mov bp,u1
        xchg bp,u3
        mov u1,bp
        mov bp,v1
        xchg bp,v3
        mov v1,bp
@@:
        cmp dx,di
        jle @F
        xchg dx,di    
        xchg cx,si
        mov bp,u2
        xchg bp,u3
        mov u2,bp
        mov bp,v2
        xchg bp,v3
        mov v2,bp
@@:
        mov X1,ax
        mov Y1,bx
        mov X2,cx
        mov Y2,dx
        mov X3,si
        mov Y3,di

        mov d1,0
        mov ud1,0
        mov vd1,0

        mov ax,Y2
        sub ax,Y1       ;ax=Y2 - Y1
        jz @F           ;avoid divide by zero
        cwde            ;ax->eax 
        mov ecx,eax     ;ecx=deltaY1

        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov d1,eax

        mov ax,U2
        sub ax,U1       ;ax=U2 - U1
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov ud1,eax

        mov ax,V2
        sub ax,V1       ;ax=V2 - V1
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov vd1,eax
@@:
        
        mov d2,0
        mov ud2,0
        mov vd2,0

        mov ax,Y3
        sub ax,Y2       ;ax=Y3 - Y2
        jz @F           ;avoid divide by zero
        cwde            ;ax->eax 
        mov ecx,eax     ;ecx=deltaY1

        mov ax,X3
        sub ax,X2       ;ax=X3 - X2
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov d2,eax

        mov ax,U3
        sub ax,U2       ;ax=U3 - U2
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov ud2,eax

        mov ax,V3
        sub ax,V2       ;ax=V3 - V2
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov vd2,eax
@@:

        mov d3,0
        mov ud3,0
        mov vd3,0

        mov ax,Y1
        sub ax,Y3       ;ax=Y1 - Y3
        jz @F           ;avoid divide by zero
        cwde            ;ax->eax 
        mov ecx,eax     ;ecx=deltaY1

        mov ax,X1
        sub ax,X3       ;ax=X1 - X3
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov d3,eax

        mov ax,U1
        sub ax,U3       ;ax=U1 - U3
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov ud3,eax

        mov ax,V1
        sub ax,V3       ;ax=V1 - V3
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov vd3,eax
@@:


        push X2        ;save it for later use

        mov bx,X1
        shl ebx,16     ;   ebx = X1 * 10000h
        mov edx,ebx    ;   edx = X1 * 10000h

        mov ax,U1
        shl eax,16     ;   eax = U1 * 10000h
        mov ecx,eax    ;   ecx = U1 * 10000h

        mov di,V1
        shl edi,16     ;   edi = V1 * 10000h
        mov ebp,edi    ;   ebp = V1 * 10000h

        mov si,Y1

        cmp si,Y2
        jge EMSskipfistTloop1

EMSTextureloop1:
        pushad

        sar edi,16
        sar ebp,16
        sar ebx,16
        sar edx,16
        sar eax,16
        sar ecx,16

        push si        ;Y
        push bx        ;LX
        push dx        ;RX
        push ax        ;LU
        push cx        ;RU
        push di        ;LV
        push bp        ;RV
        push Shandle
        call EMSSVGAhlinetexture
        
        popad

        add ebx,d1
        add edx,d3
        add eax,ud1
        add ecx,ud3
        add edi,vd1
        add ebp,vd3

        inc si
        cmp si,Y2
        jl EMSTextureloop1

EMSskipfistTloop1:

        pop bx         ;bx=X2

        shl ebx,16     ;ebx = X2 * 10000h
        mov ax,U2
        shl eax,16     ;eax = U2 * 10000h
        mov di,V2
        shl edi,16     ;edi = V2 * 10000h

        cmp si,Y3
        jg EMSskipSecTloop1


EMSTextureloop2:

        pushad

        sar edi,16
        sar ebp,16
        sar ebx,16
        sar edx,16
        sar eax,16
        sar ecx,16

        push si        ;Y
        push bx        ;LX
        push dx        ;RX
        push ax        ;LU
        push cx        ;RU
        push di        ;LV
        push bp        ;RV
        push Shandle
        call EMSSVGAhlinetexture

        popad

        add ebx,d2
        add edx,d3
        add eax,ud2
        add ecx,ud3
        add edi,vd2
        add ebp,vd3

        inc si
        cmp si,Y3
        jle EMSTextureloop2

EMSskipSecTloop1:
        popad
        pop bp
        retf 26
EMSSVGAtritext endp


;#############################################################################
;EMSSVGAhlinetexture  (Y, X1, X2, LU, RU, LV, RV, handle)
;                      20 18  16  14  12  10  08  06
;    returns nothing                     (draws a horizontal textured line)
;#############################################################################
EMSSVGAhlinetexture  proc    BASIC
        push bp
        mov bp,sp

        mov ax,offset svgabuffer  ;dest buffer offset
        mov DOffset,ax
        mov ax,@code          ;dest buffer segment
        mov DSegment,ax

        mov ax,[bp+06]
        mov Shandle,ax

        mov ax,DSegment
        mov fs,ax

        mov ax,@code
        mov es,ax
        mov bx,offset emsDIMxyArray
        mov ax,[bp+06]   ;handle
        shl ax,2
        add bx,ax

        mov ax,es:[bx+2]       ;Y
        mov TextureY,ax

        mov ax,es:[bx]         ;X
        mov TextureX,ax

        mov textureBitSize,0
        mov cl,16
@@:
        shr ax,1
        adc textureBitSize,0
        dec cl
        jnz @B


        mov ax,VideoSegment
        mov es,ax


        mov bx,[bp+14]  ;Lu
        mov cx,[bp+12]  ;Ru
        mov Lu,bx
        mov Ru,cx
        mov bx,[bp+10]  ;Lv
        mov cx,[bp+08]  ;Rv
        mov Lv,bx
        mov Rv,cx
        mov bx,[bp+18]  ;X1
        mov cx,[bp+16]  ;X2
        mov X1,bx
        mov X2,cx

        cmp bx,cx
        jl @F 
        xchg bx,cx
        mov ax,X1
        xchg ax,X2
        mov X1,ax 
        mov ax,Lu
        xchg ax,Ru
        mov Lu,ax 
        mov ax,Lv
        xchg ax,Rv
        mov Lv,ax 
@@:
        cmp cx,X2VP
        jl @F
        mov cx,X2VP
        dec cx
@@:
        mov temp2,0
        cmp bx,X1VP
        jge @F
        sub bx,X1VP
        neg bx          ;
        mov temp2,bx    ;clip left X 
        mov bx,X1VP
@@:
        cmp cx,X1VP
        jl EMStextdoneline

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = # of pixels 

        mov ud,0
        mov vd,0
        push ecx
        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        jz @F           ;avoid divide by zero
        cwde            ;ax->eax 
        mov ecx,eax     ;ecx=deltaX

        mov ax,Ru
        sub ax,Lu       ;ax=Ru - Lu
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov ud,eax

        mov ax,Rv
        sub ax,Lv       ;ax=Rv - Lv
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov vd,eax
@@:
        pop ecx


        mov ax,[bp+20]       ;Y

        cmp bx,X2VP
        jge EMStextdoneline
        cmp ax,Y1VP
        jl EMStextdoneline
        cmp ax,Y2VP
        jge EMStextdoneline

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov cl,XshiftFactor
        shl bx,cl

        add ax,bx
        adc dx,0
        mov di,ax

        push eax
        push ecx
        push edx
        push ebx
        push si
        push fs
        push di
        push es

        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif

        pop es
        pop di
        pop fs
        pop si
        pop ebx
        pop edx
        pop ecx
        pop eax
        
               
        mov ax,Lv
        shl eax,16
        mov bx,Lu
        shl ebx,16

EMStextclip:
        cmp temp2,0
        jz NoEMStextclip         
        add eax,vd
        add ebx,ud
        dec temp2
        jmp EMStextclip
NoEMStextclip:

        mov bp,temp1

EMStextpixelloop:
        push eax
        push ebx
        shr eax,16
        shr ebx,16

        .if textwrapOnOff == 0 
          cmp bx,textureX
          jae NoEMSdraw
          cmp ax,textureY
          jae NoEMSdraw
        .endif

        and bx,textureX
        and ax,textureY

        mov cl,textureBitSize
        shl eax,cl
        or eax,ebx

        mov cl,XshiftFactor
        shl eax,cl
        mov si,ax

        mov ebx,eax
        shr ebx,14
        and si,3fffh
        add si,offset svgabuffer

        .if Ssegment != bx
          push si
          push dx
          mov Ssegment,bx
          mov Soffset,0
          mov si,offset RegionLength
          mov ax,5700h
          int 67h
          pop dx
          pop si
        .endif

        xor eax,eax

        mov cx,BytesPP

        cmp cx,1
        jnz @F
        mov al,fs:[si]
        jmp EMStypeskip
@@:
        cmp cx,4
        jnz @F
        db 66h
@@:
        mov ax,fs:[si]
EMStypeskip:

        cmp MaskColor,0
        jl  EMSfilterOff
        cmp MaskColor,eax
        jz  EMSFilerOut
EMSFilterOff:

        .if cx == 1
           mov es:[di],al
        .elseif cx == 2
           .if BMapStatus == 1
                   mov bx,es:[di]
                   shr bx,1
                   shr ax,1
                   .if BitsPerPixel == 15
                      and ax,3DEFh  
                      and bx,3DEFh  
                   .elseif BitsPerPixel == 16
                      and ax,7BEFh  
                      and bx,7BEFh  
                   .endif
                   add ax,bx
           .endif
           mov es:[di],ax
        .elseif cx == 4
           .if BMapStatus > 0 
                      .if MMXStatus == 1
                              ;movd MM1,eax                      ;mov 32 bit Foreground color data to mm1
                              ;movd MM2, dword ptr es:[di]       ;mov 32 bit Background color data to mm2
                              ;punpcklbw MM1,MM7                 ;spread the 8bit data to 16bit data
                              ;punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                              ;psubw MM1,MM2                     ;substract brackground from foreground
                              ;pmullw MM1,MM3                    ;multibly by the blend value
                              ;psraw MM1,7                       ;div (signed) by 128
                              ;paddw MM1,MM2                     ;Add Background 
                              ;packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                              ;movd dword ptr es:[di],MM1        ;draw the pixel
                      .else
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
                      .endif
           .else
              mov es:[di],eax
           .endif
        .endif
EMStypeskip1:
EMSFilerOut:
NoEMSdraw:
        pop ebx
        pop eax

        add eax,vd
        add ebx,ud

        add di,BytesPP
        jae EMStextNoInc
        inc dx
        push eax           ;alot of pushes but somehow univbe was messing with 
        push ecx           ;some of the registers during baking.
        push edx           ;or maybe theres a bug somewhere???
        push ebx
        push si
        push fs
        push di
        push es

        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif

        pop es
        pop di
        pop fs
        pop si
        pop ebx
        pop edx
        pop ecx
        pop eax
EMStextNoInc:

        dec bp
        jnz EMStextpixelloop

EMStextdoneline:
        pop bp
        retf 16
EMSSVGAhlinetexture endp


END
