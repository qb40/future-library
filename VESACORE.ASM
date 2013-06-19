;#############################################################################
;
;                   SVGA routines made by Future Software
;                          for BASIC programming 
;
;#############################################################################

.model medium
.stack 20h
.586
.MMX
.K3D

EXTRN SVGAMouseOn:FAR
EXTRN CursorBuffer:byte
EXTRN TempCursorBufferX:word
EXTRN TempCursorBuffer:word

.data

PUBLIC XResolution,YResolution,BytesPerScanLine,ORIXRes,ORIYRes
PUBLIC BytesPSL
PUBLIC OffsetDATA,SegmentDATA,VideoSegment,ActivePageX,ActivePageY,BytesPP
PUBLIC MaskColor,XshiftFactor,ActivePage,ScrollLockInfo,ViewPageX,ViewPageY
PUBLIC NumberOfImagePages,VideoFrameSizeX,VideoFrameSizeY,ScrollX,ScrollY
PUBLIC Status,Mx,My,Mx1,My1,Mb,TMx,TMy,TMx1,TMY1,MColorMask,BitsPerPixel
PUBLIC X1VP,Y1VP,X2VP,Y2VP
PUBLIC MouseGonoff
PUBLIC textwrapOnOff
PUBLIC EMShandle,Curlogpage,EMSActiveBank,ActiveEMSBuffer
PUBLIC BMapStatus,BMapSEG,BMapOFF
PUBLIC FontSeg,FontOff,FontWidth,Fontheight
PUBLIC MMXStatus
PUBLIC Vmem64kBankpos
PUBLIC Globalbank

VESASignature       dd 'VESA'      ; 4 signature bytes
VESAVersion         dw 0200h       ; VESA version number
OEMStringPtr        dd 0           ; Pointer to OEM string
Capabilities        db 4 dup(0)    ; capabilities of the video environment
VideoModePtr        dd 0           ; pointer to supported Super VGA modes
TotalMemory         dw 0           ; Number of 64kb memory blocks on board
                                   ; VBE 2.0/3.0 specs.
OemSoftwareRev      dw 0           ; VBE implementation Software revision
OemVendorNamePtr    dd 0           ; Pointer to Vendor Name String
OemProductNamePtr   dd 0           ; Pointer to Product Name String
OemProductRevPtr    dd 0           ; Pointer to Product Revision String

AccelVbeVersion     dw 100h        ; VBE/AF Version
AccelVideoModePtr   dd 0           ; Pointer to Accelerated Mode List

Reserved1           db 214 dup (0) ; Reserved for VBE implementation
;OemData             db 256 dup (0) ; Data Area for OEM Strings


ALIGN 2
                                   ; mandatory information
ModeAttributes      dw  0          ; mode attributes
WinAAttributes      db  0          ; window A attributes
WinBAttributes      db  0          ; window B attributes
WinGranularity      dw  0          ; window granularity
WinSize             dw  0          ; window size
WinASegment         dw  0          ; window A start segment
WinBSegment         dw  0          ; window B start segment
WinFuncPtr          dd  0          ; pointer to windor function
BytesPerScanLine    dw  0          ; bytes per scan line

                                   ; formerly optional information (now mandatory)
XResolution         dw  0          ; horizontal resolution
YResolution         dw  0          ; vertical resolution
XCharSize           db  0          ; character cell width
YCharSize           db  0          ; character cell height
NumberOfPlanes      db  0          ; number of memory planes
BitsPerPixel        db  0          ; bits per pixel
NumberOfBanks       db  0          ; number of banks
MemoryModel         db  0          ; memory model type
BankSize            db  0          ; bank size in kb
NumberOfImagePages  db  0          ; number of images
Reserved2           db  1          ; reserved for page function

                                   ; new Direct Color fields
RedMaskSize         db  0          ; size of direct color red mask in bits
RedFieldPosition    db  0          ; bit position of LSB of red mask
GreenMaskSize       db  0          ; size of direct color green mask in bits
GreenFieldPosition  db  0          ; bit position of LSB of green mask
BlueMaskSize        db  0          ; size of direct color blue mask in bits
BlueFieldPosition   db  0          ; bit position of LSB of blue mask
RsvdMaskSize        db  0          ; size of direct color reserved mask in bits
DirectColorModeInfo db  0          ; Direct Color mode attributes
Reserved3           db  216 dup(0) ; remainder of ModeInfoBlock

ALIGN 2
Status              dw 0
Mx                  dw 0
My                  dw 0
Mb                  dw 0
Mx1                 dw 0
My1                 dw 0
TMx                 dw 0
TMy                 dw 0
TMx1                dw 0
TMY1                dw 0
MColorMask          dd 255
MouseGonoff         db 1

ALIGN 2
X1VP             dw  0
Y1VP             dw  0
X2VP             dw  0
Y2VP             dw  0

X1               dw  0
Y1               dw  0
X2               dw  0
Y2               dw  0
X3               dw  0
Y3               dw  0
X4               dw  0
Y4               dw  0
Color1           dw  0
Color2           dw  0
Color3           dw  0
ActiveBank       dw  0
BankShift        dw  0
FontSeg          dw  0
FontOff          dw  0
FontWidth        dw  0
Fontheight       dw  0
OneChar          dw  0
dinc1            dw  0
dinc2            dw  0
Xinc1            dw  0
Xinc2            dw  0
Yinc1            dw  0
Yinc2            dw  0
d                dw  0
ActiveDrawPage   dw  0
ActivePage       dw  0
ActivePageX      dw  0
ActivePageY      dw  0
ViewPageX        dw  0
ViewPageY        dw  0
Radius           dw  0
Bitscan          dw  0
SegmentDATA      dw  0
OffsetDATA       dw  0
SegmentDATA1     dw  0
OffsetDATA1      dw  0
ReadWindow       dw  0
WriteWindow      dw  0
MaskColor        dd  -1
ActiveScreenMode dw  0
ORIYRes          dw  0
ORIXRes          dw  0
ScrollX          dw  0
ScrollY          dw  0
dd1              dw  0
dd2              dw  0
temp1            dw  0
temp2            dw  0
temp3            dw  0
temp4            dw  0
temp5            dw  0
temp6            dw  0
Intpart1         dw  0
Decpart1         dw  0
Intpart2         dw  0
Decpart2         dw  0
Intpart3         dw  0
Decpart3         dw  0
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
textureX         dw  0
textureY         dw  0
VideoFrameSizeX  dw  0
VideoFrameSizeY  dw  0

VideoSegment     dw  0a000h  ;holds video segment or EMS segment

ActiveEMSBuffer  dw  -1       ;EMS handle

EMSActiveBank    dw  -1
ClearVmemflag    db  0
Xshiftfactor     db  0
Curlogpage       dw  -1
Xres             dw  0
MapSizeX         dw  0
EMShandle        dw  0
BytesPP          dw  1
BytesPSL         dw  0
Vmem64kBankpos   dw  -1
Globalbank       dw  -1

ud               dd  0
vd               dd  0
cd1              dd  0
cd2              dd  0
cd3              dd  0
ScrollLockInfo   dd  0   ;bit=1 locked,bit=0 unlocked (32 pages only)
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

textureXSize     dd  31
textureYSize     dd  31
textureBitSize   db  5

textwrapOnOff    db 0

UniColor         dd  0
UniColor1        dd  0
UniColor2        dd  0
UniColor3        dd  0
UniColor4        dd  0
UniColor5        dd  0

SegOff           dd  0

bytemem          db  0
bytemem1         db  0

BMapStatus       dw  0      ;0=off 
Tcolor           db  0
BMapSEG          dw  0
BMapOFF          dw  0

outreg           db  0
tempXval         dw  0

;mmx
tempQword        dq  0
MMXStatus        dw  0      ;0=off 1=on  MMX
MMXExtStatus     dw  0      ;0=off 1=on  MMX Extention

.code

;code by Alan to fix interruptX problem. (Called in SVGA module)
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
Public SvgaGetModeInfo
; mode
; blockseg
; blockoff
; bas far ptr 0-2
SvgaGetModeInfo proc
  mov ax,bp
  mov bp,sp
  push ax
  mov di, [bp+6]
  mov es, di
  mov di, [bp+4]  
  mov cx, [bp+8]
  mov ax, 04F01h
  int 10h
  pop bp
  ret 6
SvgaGetModeInfo endp
;----------------------------------------------------------------------------
; That's it =)
;----------------------------------------------------------------------------



;#############################################################################
;SvgaSizeOf (Xdim%, Ydim%)  
;                           
;  DX:AX returns total number of bytes needed for a bitmap image
;#############################################################################
PUBLIC SvgaSizeOf
SvgaSizeOf proc    BASIC
        push bp
        mov bp,sp
        push ebx
        push eax
        xor eax,eax

        mov ax,[bp+06]
        mov cl,XshiftFactor
        shl eax,cl

        cmp BitsPerPixel,24
        jnz @F
        xor ebx,ebx
        mov bx,[bp+06]
        add eax,ebx
@@:

        mul word ptr [bp+08]
        mov bx,ax
        mov cx,dx

        add bx,4         ;add 4 bytes for picture size info
        adc cx,0

        pop eax

        mov ax,bx
        mov dx,cx

        pop ebx
        pop bp
        retf 4
SvgaSizeOf endp


;#############################################################################
;Bitdepth
;
;  AX returns total number of bits per pixel
;#############################################################################
PUBLIC Bitdepth
Bitdepth proc    BASIC
        xor ah,ah
        mov al,BitsPerPixel
        retf
Bitdepth endp


;#############################################################################
;You must call IsVESA% before anything else
;
;  AX returns -1 if VESA is present and 0 if not
;#############################################################################
PUBLIC IsVESA
IsVESA proc    BASIC
        mov ax,@data
        mov es,ax
        mov di,offset VESASignature
        mov ax,4f00h
        int 10h
        xor ax,ax
        cmp dword ptr VESASignature,'VESA'
        jnc NoVESA
        mov ax,-1
NoVESA:
        retf
IsVESA endp


;#############################################################################
;VideoMemory&
;
;  DX:AX returns total number of video memory
;#############################################################################
PUBLIC VideoMemory
VideoMemory proc    BASIC
        xor ax,ax
        mov dx,TotalMemory  ;banks*10000h
        retf
VideoMemory endp

;#############################################################################
;GetActivePage%
;
;  
;#############################################################################
PUBLIC GetActivePage
GetActivePage proc    BASIC
        mov ax,ActiveDrawPage
        retf
GetActivePage endp

;#############################################################################
;Pages%
;
;  AX returns total number of video Pages
;#############################################################################
PUBLIC Pages
Pages proc    BASIC
        xor ax,ax           
        mov al,NumberOfImagePages
        retf
Pages endp

;#############################################################################
;Scanlenght%
;
;  AX returns total byte lenght of a scanline
;#############################################################################
PUBLIC Scanlenght
Scanlenght proc    BASIC
        mov ax,BytesPerScanLine  
        retf
Scanlenght endp

;#############################################################################
;pixellenght%
;
;  AX returns total pixel length of a scanline
;#############################################################################
PUBLIC pixellength
pixellength proc    BASIC
        mov ax,XResolution
        retf
pixellength endp

;#############################################################################
;Scanlines%  
;
;  AX returns total number of a scanlines for one page
;#############################################################################
PUBLIC Scanlines
Scanlines proc    BASIC
        mov ax,YResolution
        retf
Scanlines endp

;#############################################################################
;SetPage (Page)
;
;  Set the active page for drawing
;#############################################################################
PUBLIC SetPage
SetPage proc    BASIC
        push bp
        mov bp,sp

        mov ax,VideoFrameSizeX
        mov XResolution,ax

        mov ax,BytesPSL
        mov BytesPerScanLine,ax

        mov ax,VideoFrameSizeY
        mov YResolution,ax

        mov EMShandle,-1
        mov Curlogpage,-1
        mov EMSActiveBank,-1

        cmp VideoSegment, 0a000h
        jz @F
           mov X1VP,0
           mov Y1VP,0
           mov ax,VideoFrameSizeX
           mov X2VP,ax
           mov ax,VideoFrameSizeY
           mov Y2VP,ax
           mov VideoSegment,0a000h
@@:

        mov ax,[bp+6]                  ;Page

        xor ah,ah
        cmp al,NumberOfImagePages
        jg maxpage
        cmp al,0
        jl minpage

        jmp SetIt

maxpage:
        xor ax,ax
        mov al,NumberOfImagePages
        jmp SetIt
minpage:
        xor ax,ax
SetIt:
        mov ActiveDrawPage,ax

        mov bx,ax
        mul YResolution
        mov ActivePageY,ax
        mov ActivePageX,0
PageSet:
        pop bp
        retf 2
SetPage endp


;#############################################################################
;SetMaskColor (Color)
;
;  returns nothing
;#############################################################################
PUBLIC SetMaskColor
SetMaskColor proc    BASIC
        push bp
        mov bp,sp
        push eax

        mov eax,[bp+6]                  ;color

        .if BitsPerPixel == 15
          shl ax,3       
          shl eax,5      
          shl ax,3       
          shr eax,11     
        .elseif BitsPerPixel == 16
          shl ax,2       
          shl eax,6      
          shl ax,3       
          shr eax,11     
        .endif

        mov MaskColor,eax

        pop eax
        pop bp
        retf 4
SetMaskColor endp

;#############################################################################
;GetMaskColor (Color)
;
;  returns maskcolor
;#############################################################################
PUBLIC GetMaskColor
GetMaskColor proc    BASIC
       push ebx
        mov ebx,MaskColor

        .if BitsPerPixel == 15
          shl ebx,11  
          shr bx,3    
          shr ebx,5   
          shr bx,3    
        .elseif BitsPerPixel == 16
          shl ebx,11
          shr bx,3
          shr ebx,6
          shr bx,2
        .endif

          mov ax, bx
          shr ebx,16
          mov dx, bx

       pop ebx
        retf
GetMaskColor endp


;#############################################################################
;SetColorModeX (ColorMode)
;                                  0:16 colors
;                                  1:256 colors
;                                  2:32k colors (5:5:5)
;                                  3:64k colors (5:6:5)
;                                  4:16.8 mio. colors (8:8:8:8)
;  returns nothing                 5:16.8 mio. colors (8:8:8)
;#############################################################################
PUBLIC SetColorModeX
SetColorModeX proc    BASIC
        push bp
        mov bp,sp
        mov ax,[bp+6]                  ;color

        cmp al,0
        jnz @F
        mov Xshiftfactor,0
        mov BytesPP,1
@@:
        cmp al,1
        jnz @F
        mov Xshiftfactor,0
        mov BytesPP,1
@@:
        cmp al,2
        jnz @F
        mov Xshiftfactor,1
        mov BytesPP,2
@@:
        cmp al,3
        jnz @F
        mov Xshiftfactor,1
        mov BytesPP,2
@@:
        cmp al,4
        jnz @F
        mov Xshiftfactor,2
        mov BytesPP,4
@@:
        cmp al,5
        jnz @F
        mov Xshiftfactor,1
        mov BytesPP,3
@@:
        pop bp
        retf 2
SetColorModeX endp

;#############################################################################
;SetNoVClear (mode)
;
;  returns nothing             (1=No clear)
;#############################################################################
;PUBLIC SetNoVClear
SetNoVClear proc    BASIC
        push bp
        mov bp,sp
        mov ax,[bp+6]                  
        mov ClearVmemflag,al
        pop bp 
        retf 2
SetNoVClear endp


;#############################################################################
;SetVESAmode (mode)
;
;  returns nothing
;#############################################################################
PUBLIC SetVESAmode
SetVESAmode proc    BASIC
        push bp
        mov bp,sp

        mov MouseGonoff,1           ;turn mouse cursor generator on

        mov ActivePageX,0           ;reset
        mov ActivePageY,0
        mov ViewPageX,0
        mov ViewPageY,0
        mov ScrollX,0
        mov ScrollY,0

        mov cx,[bp+6]


        cmp cx,100h
        jae SetSVGAmode

      

;        cmp ClearVmemflag,1
;        jnz ClearVMem
;        or cl, 10000000b               ;set bit 7 (No screen clear)
;ClearVMem:

        mov ah,0fh                   ;Is the mode set?
        int 10h       
        cmp al,cl        
        jz ModeIsSet1

        mov ax,cx
        int 10h                        ;set VGA mode if requested (320x200)

ModeIsSet1:
       .if cx == 13h
           mov BytesPerScanLine,320
           mov XResolution,320
           mov YResolution,200
           mov BitsPerPixel,8
           mov BytesPSL,320
           mov NumberOfImagePages,0
           jmp Factorfound
       .elseif cx == 12h
           mov BytesPerScanLine,80
           mov XResolution,640
           mov YResolution,480
           mov BitsPerPixel,4
           mov BytesPSL,80
           mov NumberOfImagePages,0
           jmp Factorfound
       .elseif cx == 10h
           mov BytesPerScanLine,80
           mov XResolution,640
           mov YResolution,350
           mov BitsPerPixel,4
           mov BytesPSL,80
           mov NumberOfImagePages,0
           jmp Factorfound
       .elseif cx == 0Eh
           mov BytesPerScanLine,80
           mov XResolution,640
           mov YResolution,200
           mov BitsPerPixel,4
           mov BytesPSL,80
           mov NumberOfImagePages,0
           jmp Factorfound
       .elseif cx == 0Dh
           mov BytesPerScanLine,40
           mov XResolution,320
           mov YResolution,200
           mov BitsPerPixel,4
           mov BytesPSL,40
           mov NumberOfImagePages,0
           jmp Factorfound
       .endif

SetSVGAmode:
        mov ax,@data
        mov es,ax
        mov di,offset ModeAttributes
        mov ax,4f01h                   
        mov cx,[bp+6]                  ;mode number
        int 10h                        ;load the mode data
 

;*********
        mov ax,4f03h                   ;Is the mode set?
        int 10h       
        cmp bx,cx        
        jz ModeIsSet
;*********

;        cmp ClearVmemflag,1
;        jnz ClearVMem1
;        or cx,1000000000000000b       ;set bit 15 (No screen clear)
;ClearVMem1:

        mov bx,12h                     ;force the mouSE TO ACT RIGHT!!!
        mov ax,4f02h                   ;
        int 10h                        ;
                                       ;
        xor bx,bx                      ;
        mov ax,4f03h                   ;was the 640x480x16 mode set?
        int 10h                        ;
        cmp bx,12                      ;
        jz it_worked                   ;
                                       ;
        mov ax,12h                     ;if not then set it the old way.
        int 10h

it_worked:

;        or cx,0010000000000000b       ;set bit 13 (set accelerator mode)

        mov bx,cx
        mov ax,4f02h
        int 10h                        ;set mode

ModeIsSet:
        mov BankShift,0                ;now find the bank shift factor
        mov ax,64
Findfactor:                            
        cmp ax,WinGranularity
        je Factorfound
        shr ax,1
        inc BankShift
        jmp Findfactor
Factorfound:

        mov X1VP,0
        mov Y1VP,0

        mov ax,XResolution             ;save original resolution
        mov ORIXRes,ax
        mov X2VP,ax
        mov VideoFrameSizeX,ax

        mov ax,YResolution
        mov ORIYRes,ax
        mov Y2VP,ax
        mov VideoFrameSizeY,ax

        mov ax,BytesPerScanLine
        mov BytesPSL,ax


        mov ax,seg MouseInt           ;hook custom mouse routine
        mov es,ax
        mov dx,offset MouseInt
        mov ax,0Ch
        mov cx,7fh                    
        int 33h

        mov ax,7                      ;set new mouse range
        mov cx,0
        mov dx,XResolution
        int 33h

        mov ax,8
        mov cx,0
        mov dx,YResolution
        int 33h

        mov VideoSegment, 0a000h
        mov EMSActiveBank, -1



;;:::::::::::::::::: code originaly created by victor
                push    ds
                mov     ax, cs
                mov     dx, offset int3d
                mov     ds, ax
                mov     ax, 253Dh               ;; set int vector
                int     21h
                pop     ds
;:::::::::::::::::: code originaly created by victor

        pop bp
        retf 2
SetVESAmode endp

;;:::::::::::::::::: code originaly created by victor
;#############################################################################
;int3d
;
;  returns nothing             
;#############################################################################
int3d proc    BASIC
                push    bp
                mov     bp, sp
                push    ds

                lds     bp, [bp + 2]            ;; ds:bp -> return address                
                mov     word ptr ds:[bp-2],909Bh;; fix up with: fwait; nop

                pop     ds
                pop     bp
                iret
int3d endp
;;:::::::::::::::::: code originaly created by victor


;#############################################################################
;SVGApset (Xpos, Ypos, Color)
;       
;  returns nothing
;#############################################################################
PUBLIC SVGApset
SVGApset proc    BASIC
        push bp
        mov bp,sp
        push es
        push gs
        push eax

        mov ax,[bp+10]           ;Y
        mov bx,[bp+12]           ;X

        cmp bx,X1VP
        jl NoPixel
        cmp bx,X2VP
        jge NoPixel
        cmp ax,Y1VP
        jl NoPixel
        cmp ax,Y2VP        
        jge NoPixel

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov cl,Xshiftfactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,[bp+12]
        .elseif BitsPerPixel == 4
            shr bx,3
        .endif

        add ax,bx
        adc dx,0
        mov si,ax

        push dx
        .if VideoSegment == 0a000h
            Call SetVESABank
        .else
        cmp EMSActiveBank,dx
        je @F
            Call SetEMSBank
        @@:
        .endif
        pop dx


        mov ax,VideoSegment
        mov es,ax

        mov eax,[bp+06]

        .if BitsPerPixel == 4
            mov dx,3ceh
            xor al,al
            out dx,al
            inc dx
            mov al,[bp+06]  ;color
            out dx,al
            dec dx
            mov al,5
            out dx,al
            inc dx
            in al,dx
            mov ah,al
            or al,3
            out dx,al

            mov cl,[bp+12]
            and cl,7
            mov ch,7
            sub ch,cl
            mov cl,ch
            mov al,1
            shl al,cl

            mov bl, es:[si] ;load latches
            mov es:[si],al
            mov al,ah
            out dx,al

        .elseif BitsPerPixel == 8
          .if BMapStatus == 1
            mov bx,BmapSEG
            mov gs,bx
            mov bl,es:[si]
            mov bh,al
            add bx,BMapOFF
            mov al,gs:[bx]
          .endif
           mov es:[si],al
        .elseif BitsPerPixel == 15
           .if BMapStatus > 0
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
              
                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color
                      shl ebx,11  
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16
           .else
                      shl ax,3       
                      shl eax,5      
                      shl ax,3       
                      shr eax,11     
                      mov es:[si],ax
           .endif
        .elseif BitsPerPixel == 16
           .if BMapStatus > 0
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus

                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color

                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      mov ah,al
                      shr eax,8

                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16


           .else
              shl ax,2       
              shl eax,6      
              shl ax,3       
              shr eax,11     
              mov es:[si],ax
           .endif
        .elseif BitsPerPixel == 24
           .if BMapStatus == 1
            shr eax,1
            and eax,011111110111111101111111b

           mov ch,3
         .REPEAT
           mov bl,es:[si]
           shr bl,1
           add al,bl
           mov es:[si],al
           add si,1
         jnc @F
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
         @@:
           shr eax,8
           dec ch
         .UNTIL ch == 0   


           .else
              mov ch,3
              pixel_pset24:

              mov es:[si],al
              add si,1
              jnc nof
              inc dx
              push eax
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop eax
           nof:
              shr eax,8
              dec ch
              jnz pixel_pset24
           .endif
        .elseif BitsPerPixel == 32
           .if BMapStatus > 0
              shl edx,16
              shl ecx,16

              mov cx,BMapStatus

              mov ebx, es:[si];BGB              ;get background color
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
              ;mov es:[di],eax                   ;draw result colors

              shr ecx,16
              shr edx,16

              ;mov ebx,es:[si]
              ;shr eax,1
              ;shr ebx,1
              ;and eax,011111110111111101111111b
              ;and ebx,011111110111111101111111b
              ;add eax,ebx
           .endif
           mov es:[si],eax
        .endif

NoPixel:
        pop eax
        pop gs
        pop es
        pop bp
        retf 8
SVGApset endp

;#############################################################################
;SVGApoint& (X, Y)
;
;  returns a color or -1 if outside the frame
;#############################################################################
PUBLIC SVGApoint
SVGApoint proc    BASIC
        push bp
        mov bp,sp
        push es
        push ebx

        mov ax,VideoSegment
        mov es,ax
        mov ax,[bp+06]
        mov bx,[bp+08]

        cmp bx,X1VP
        jl NoPixel1
        cmp bx,X2VP
        jge NoPixel1
        cmp ax,Y1VP
        jl NoPixel1
        cmp ax,Y2VP        
        jge NoPixel1

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov cl,XshiftFactor
        shl bx,cl

        cmp BitsPerPixel,24
        jnz @F
        add bx,[bp+08]
@@:
        add ax,bx
        adc dx,0
        mov si,ax

        cmp VideoSegment,0a000h
        jnz EMSIsActive8
        Call SetVESABank
        jmp @F
EMSIsActive8:
        Call SetEMSBank
@@:

        .if BitsPerPixel == 8
          xor dx,dx
          xor ax,ax
          mov al,es:[si]
        .elseif BitsPerPixel == 15
          mov bx,es:[si]
          shl ebx,11     
          shr bx,3       
          shr ebx,5      
          shr bx,3       
          mov ax,bx
          shr ebx,16
          mov dx,bx
        .elseif BitsPerPixel == 16
          mov bx,es:[si]
          shl ebx,11     
          shr bx,3       
          shr ebx,6      
          shr bx,2       
          mov ax,bx
          shr ebx,16
          mov dx,bx
        .elseif BitsPerPixel == 24
          mov al,es:[si]
          add si,1
          jnc nof2
          inc dx
          push ax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop ax
        nof2:
           mov ah,es:[si]
           add si,1
           jnc nof3
           inc dx
           push ax
           .if VideoSegment == 0a000h
               Call SetVESABank
           .else
               Call SetEMSBank
           .endif
           pop ax
        nof3:
           xor dh,dh
           mov dl,es:[si]
        .elseif BitsPerPixel == 32
          mov ax,es:[si]
          mov dx,es:[si+02]
        .endif

        jmp Gotpixel
NoPixel1:
        mov ax,-1                
        cwd
Gotpixel:
        pop ebx
        pop es
        pop bp
        retf 4
SVGApoint endp



;#############################################################################
;SVGAcls (Color)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAcls
SVGAcls proc    BASIC
;        push bp
;        mov bp,sp
;        push eax
;
;        mov eax,[bp+06]
;        mov UniColor,eax
;        xor bp,bp
;
;clsloop1:
;        push bp
;        push 0
;        push XResolution
;        push UniColor    
;        call SVGAhline
;
;        inc bp
;        cmp bp,YResolution
;        jle clsloop1
;
;        pop eax
;        pop bp
;        retf 4
;***
        push bp
        mov bp,sp
        push eax

        mov ax,VideoSegment
        mov es,ax
        
        mov bx,X2VP
        sub bx,X1VP
        mov temp1,bx      ;delta_x

        mov bx,X1VP
        mov ax,Y1VP
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp6,bx

        Mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp6
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        mov bx,temp1
        mov temp4,bx
        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp1
        .endif

        mov temp1,bx

        mov cx,BytesPerScanLine
        sub cx,bx
        mov temp2,cx

        push dx
        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif
        pop dx

        mov eax,[bp+06]

        .if BitsPerPixel == 8     ;copy al into eax
          mov ah,al
          mov bx,ax
          shl eax,16
          mov ax,bx
        .elseif BitsPerPixel == 15 ;copy ax into eax
          shl ax,3       
          shl eax,5      
          shl ax,3       
          shr eax,11     
          mov bx,ax
          shl eax,16
          mov ax,bx
        .elseif BitsPerPixel == 16    ;copy ax into eax
          shl ax,2       
          shl eax,6      
          shl ax,3       
          shr eax,11     
          mov bx,ax
          shl eax,16
          mov ax,bx
        .endif

        mov UniColor, eax

.if MMXStatus == 1
        mov dword ptr [tempQword],eax
        mov dword ptr [tempQword+4],eax        
        movq MM0,tempQword
.endif

        mov bp,Y2VP
        sub bp,Y1VP
        inc bp
        mov eax,UniColor
clsloop:
        mov eax,UniColor

        mov bx,temp1                ;do we at any time cross a bank border?
        add bx,di
        jae DoclsBlit         ;if no, then blit

        mov cx,temp4
        mov bx,BytesPP

clspixelloop:
        .if bx == 1
           mov es:[di],al
        .elseif bx == 2
           mov es:[di],ax
        .elseif bx == 3
           .if di <= 1111111111111100b
              mov es:[di],ax
              rol eax,16
              mov es:[di+2],al
              rol eax,16
           .else
              mov bytemem,3
              pixel_cls24:

              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push cx
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop cx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_cls24
              rol eax,24

             mov bx,3
             jmp short @F
           .endif

        .elseif bx == 4
           mov es:[di],eax
        .endif

        add di,bx
        jae short @F
        inc dx
        push eax
        push bx
        push cx
        push dx

        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif

        pop dx
        pop cx
        pop bx
        pop eax
@@:
        dec cx
        jnz clspixelloop   ;if zero then done

        jmp @F

DoclsBlit:
        mov bx,temp1
        mov cx,bx

      .if BitsPerPixel == 24
        shr cx,2
          mov temp7,eax
          ror eax, 16
          mov ah,byte ptr [temp7]
          rol eax, 16
          shr temp7,8

        .if bx >= 4
         bitBLT_24: 
           stosd
           rol eax,16
           xchg word ptr [temp7],ax
          dec cx
          jnz bitBLT_24
          and bx,3
          jz @F
        .endif
        .if bx >= 2
          stosw
          shr eax,16
          and bx,1
          jz @F
        .endif
        .if bx >= 1
          stosb
        .endif
       jmp @F
      .endif


      .if MMXStatus != 0

        .if bx >= 8
          shr cx,3
ALIGN 2
          mmx1:
            movq es:[di],MM0
            add di,8
            dec cx
          jnz mmx1
          and bx,7
          jz @F
        .endif

        .if bx >= 4
          stosd
          and bx,3
          jz @F
        .endif

      .else

        .if bx >= 4
          shr cx,2
          rep stosd
          and bx,3
          jz @F
        .endif

      .endif

        .if bx >= 2
          stosw
          and bx,1
          jz @F
        .endif

        stosb
@@:

        add di,temp2
        jae @F
        inc dx
        push eax
        push dx
        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif
        pop dx
        pop eax
@@:
        dec bp
        jnz clsloop
Nocls:
.if MMXStatus == 1
        emms
.endif
        pop eax
        pop bp
        retf 4
SVGAcls endp

;#############################################################################
;SVGAfillbox (X1, Y1, X2, Y2, Color) 
;
;  returns nothing
;#############################################################################
PUBLIC SVGAfillbox
SVGAfillbox proc    BASIC
        push bp
        mov bp,sp
        push eax

        mov ax,[bp+10]
        mov Y2,ax
        mov ax,[bp+14]
        mov Y1,ax
        cmp ax,Y2
        JLE YlessOk100
        xchg ax,Y2
        xchg ax,Y1
YlessOk100:
        mov ax,[bp+12]
        mov X2,ax
        mov ax,[bp+16]
        mov X1,ax
        mov ax,X1
        cmp ax,X2
        JLE XlessOk100
        xchg ax,X2
        xchg ax,X1
XlessOk100:

        mov eax,[bp+06]
        mov bp,Y1
boxfill_loop:
        push bp
        push X1
        push X2
        push eax
        call SVGAhline
        inc bp
        cmp bp,Y2
        jle boxfill_loop

        pop eax
        pop bp
        retf 12
SVGAfillbox endp


;#############################################################################
;SVGAbox (X1, Y1, X2, Y2, Color)   
;
;  returns nothing
;#############################################################################
PUBLIC SVGAbox
SVGAbox proc    BASIC
        push bp
        mov bp,sp
        push gs
        push eax

        mov ax,VideoSegment
        mov es,ax

        mov ax,[bp+10]
        mov Y2,ax
        mov ax,[bp+14]
        mov Y1,ax
        cmp ax,Y2
        JLE YlessOk1
        xchg ax,Y2
        xchg ax,Y1
YlessOk1:
        mov ax,[bp+12]
        mov X2,ax
        mov ax,[bp+16]
        mov X1,ax
        cmp ax,X2
        JLE XlessOk1
        xchg ax,X2
        xchg ax,X1
XlessOk1:
        mov eax,[bp+6]
        mov UniColor1,eax

        push Y1
        push X1
        push X2
        push UniColor1
        call SVGAhline

        .if BitsPerPixel == 15    
           .if BMapStatus > 0
              mov UniColor3,eax
           .endif
          shl ax,3
          shl eax,5      
          shl ax,3       
          shr eax,11     
        .elseif BitsPerPixel == 16 
           .if BMapStatus > 0
              mov UniColor3,eax
           .endif
          shl ax,2
          shl eax,6      
          shl ax,3       
          shr eax,11     
        .endif

        mov UniColor,eax

        mov bx,BmapSEG
        mov gs,bx

        mov bp,Y1
        inc bp
        mov bx,X1

     cmp bp,Y2
     jge boxline_done

box_loop:
        cmp bx,X1VP
        jl SkipPixel
        cmp bx,X2VP
        jge SkipPixel
        cmp bp,Y1VP
        jl SkipPixel
        cmp bp,Y2VP        
        jge SkipPixel

        mov ax,bp
        push ebx
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp6,bx

        mov cl,Xshiftfactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp6
        .endif


        add ax,bx
        adc dx,0

        mov di, ax

        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif

        mov eax,UniColor

        .if BytesPP == 1
           .if BMapStatus == 1
              mov bl,es:[si]
              mov bh,al
              add bx,BMapOFF
              mov al,gs:[bx]
           .endif
           mov es:[di],al
        .elseif BytesPP == 2
           .if BMapStatus > 0
              .if BitsPerPixel == 16
                      
                      shl edx,16
                      shl ecx,16


                      mov cx,BMapStatus

                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color

                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
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
              
                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color
                      shl ebx,11  
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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
           .else
             mov es:[di],ax
           .endif
        .elseif BytesPP == 3
           .if di <= 1111111111111100b
              mov es:[di],ax
              rol eax,16
              mov es:[di+2],al
              rol eax,16
           .else
              mov bytemem,3
              pixel_box24:
         
              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push cx
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop cx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_box24
           .endif
        .elseif BytesPP == 4
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
           .else
             mov es:[di],eax
           .endif
        .endif

        pop ebx
SkipPixel:
        cmp bx,X2
        jz ButLineDone
        mov bx,X2
        jmp Nexline
ButLineDone:
        mov bx,X1
        inc bp
Nexline:
        cmp bp,Y2
        jl box_loop
boxline_done:

        mov ax,Y1
        .if ax != Y2
          push Y2
          push X1
          push X2
          push UniColor1
          call SVGAhline
        .endif

        pop eax
        pop gs
        pop bp
        retf 12
SVGAbox endp


;#############################################################################
;SVGAline (X1, Y1, X2, Y2, Color, Bitscan)   
;
;  returns nothing
;#############################################################################
PUBLIC SVGAline
SVGAline proc    BASIC
        push bp
        mov bp,sp
        push gs
        push eax
        push ebx

        mov eax,[bp+8]


        .if BitsPerPixel == 4
                mov dx,3ceh
                xor al,al
                out dx,al
                inc dx
                mov al,[bp+8] ;color
                out dx,al
                dec dx
                mov al,5
                out dx,al
                inc dx
                in al,dx
                mov outreg,al
                or al,3
                out dx,al
        .elseif BitsPerPixel == 15
           .if BMapStatus > 0
               mov UniColor3,eax
           .endif
          shl ax,3
          shl eax,5      
          shl ax,3       
          shr eax,11     
        .elseif BitsPerPixel == 16
           .if BMapStatus > 0
              mov UniColor3,eax
           .endif
          shl ax,2
          shl eax,6      
          shl ax,3       
          shr eax,11     
        .elseif (BitsPerPixel == 32) || (BitsPerPixel == 24)
        .endif

        mov UniColor,eax

        mov ax,[bp+6]
        mov Bitscan,ax
        
        mov bx,[bp+18]
        mov X1,bx
        mov bx,[bp+14]       
        mov X2,bx
        sub bx,X1
        jge Noneg
        neg bx     
Noneg:
        mov ax,[bp+16]
        mov Y1,ax
        mov ax,[bp+12]
        mov Y2,ax
        sub ax,Y1
        jge Noneg1
        neg ax
Noneg1:

        mov Xinc2,1
        mov Yinc2,1
        mov Xinc1,0
        mov Yinc1,0

        cmp ax,bx
        jge Xinc1Zero
        mov Xinc1,1
        jmp Yinc1Zero
Xinc1Zero:
        mov Yinc1,1
        xchg ax,bx
Yinc1Zero:

        mov cx,ax
        shl cx,1
        mov Dinc1,cx
        sub cx,bx
        mov D,cx
        mov bp,bx
        inc bp                ; bp=numberofpixels
        sub ax,bx
        mov bx,2
        imul bx
        mov Dinc2,ax

        mov ax,X1
        cmp ax,X2
        jle Noneg2
        neg Xinc1
        neg Xinc2
Noneg2:
        mov ax,Y1
        cmp ax,Y2
        jle Noneg3
        neg Yinc1
        neg Yinc2
Noneg3:
        mov ax,VideoSegment
        mov es,ax

        mov ax,Y1
        mov bx,X1
        mov di,D

lineloop:
        rol Bitscan,1
        jae skiplinepixel

        cmp bx,X1VP
        jl skiplinepixel
        cmp bx,X2VP
        jge skiplinepixel
        cmp ax,Y1VP
        jl skiplinepixel
        cmp ax,Y2VP        
        jge skiplinepixel

        push ax
        push bx

        add ax,ActivePageY
        add bx,ActivePageX

        mul BytesPerScanLine

        mov temp1,bx
        mov tempXval,bx

        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
          add bx,temp1
        .elseif BitsPerPixel == 4
            shr bx,3
        .endif

        add ax,bx
        adc dx,0

        mov si,ax

        cmp VideoSegment,0a000h
        jnz EMSIsActive3
        Call SetVESABank
        jmp @F
EMSIsActive3:
        Call SetEMSBank
@@:

        mov eax,UniColor

        .if BytesPP ==1
          .if BitsPerPixel == 4
                  xor al,al
                  mov cl,byte ptr [tempXval]
                  and cl,7
                  mov ah,10000000b
                  shr ah,cl
                  or al,ah
                  mov bl, es:[si] ;load latches
                  mov es:[si],al
          .elseif BitsPerPixel == 8
             .if BMapStatus == 1
                mov bx,BmapSEG
                mov gs,bx
                mov bl,es:[si]
                mov bh,al
                add bx,BMapOFF
                mov al,gs:[bx]
             .endif
             mov es:[si],al
          .endif

        .elseif BytesPP ==2
            .if BMapStatus > 0
              .if BitsPerPixel == 16
                      
                      shl edx,16
                      shl ecx,16


                      mov cx,BMapStatus

                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color

                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      mov ah,al
                      shr eax,8

                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16
                     
              .else
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
              
                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color
                      shl ebx,11  
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16

              .endif

              ;mov bx,es:[si]
              ;shr bx,1
              ;and bx,temp2
              ;add bx,ax
              ;mov es:[si],bx
              mov bx,2
            .else
              mov es:[si],ax
            .endif
        .elseif BytesPP ==3

           .if BMapStatus == 1
           mov ch,3
         .REPEAT
           mov bl,es:[si]
           shr bl,1
           add al,bl
           mov es:[si],al
           add si,1
         jnc @F
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
         @@:
           shr eax,8
           dec ch
         .UNTIL ch == 0   

           .else

           ;and eax,00ffffffh
           mov ch,3
           line_plot:

           mov es:[si],al
           add si,1
           jnc nof40
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
           nof40:
           shr eax,8

           ;cmp eax,0
           dec ch
           jnz line_plot
          .endif
        .elseif BytesPP ==4
            .if BMapStatus > 0
              shl edx,16
              shl ecx,16

              mov cx,BMapStatus

              mov ebx, es:[si];BGB              ;get background color
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
              mov es:[si],eax                   ;draw result colors

              shr ecx,16
              shr edx,16

              ;mov ebx,es:[si]
              ;shr ebx,1
              ;and ebx,011111110111111101111111b
              ;add ebx,eax
              ;mov es:[si],ebx
              mov ebx,4
            .else
              mov es:[si],eax
            .endif
        .endif

        pop bx
        pop ax
skiplinepixel:
        cmp di,0
        jge Disbelow
        add di,Dinc1
        add bx,Xinc1
        add ax,Yinc1
        jmp  Doneline9
Disbelow:
        add di,Dinc2
        add bx,Xinc2
        add ax,Yinc2
Doneline9:
        sub bp,1
        jnz lineloop

        .if BitsPerPixel == 4
                mov al,outreg
                mov dx,3cfh
                out dx,al
        .endif

        pop ebx
        pop eax
        pop gs
        pop bp
        retf 14
SVGAline endp

;#############################################################################
;Internal routine (draws one pixel)
;
; bx=X ax=Y Color1=Color
;#############################################################################
OnePixel proc NEAR 

        cmp bx,X1VP
        jl SkipOnePixel
        cmp bx,X2VP
        jge SkipOnePixel
        cmp ax,Y1VP
        jl SkipOnePixel
        cmp ax,Y2VP        
        jge SkipOnePixel

        add ax,ActivePageY
        add bx,ActivePageX

        mul BytesPerScanLine

        mov temp1,bx

        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
          add bx,temp1
        .endif

        add ax,bx
        adc dx,0

        mov si, ax

        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif

        mov eax,UniColor

        .if BitsPerPixel == 8
          .if BMapStatus == 1
            mov bx,BmapSEG
            mov gs,bx
            mov bl,es:[si]
            mov bh,al
            add bx,BMapOFF
            mov al,gs:[bx]
          .endif
          mov es:[si],al
        .elseif BitsPerPixel == 15
          .if BMapStatus > 0
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
              
                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color
                      mov eax,UniColor3
                      shl ebx,11
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16

          .else
                      mov es:[si],ax
            ;mov bx,es:[si]
            ;shr ax,1
            ;shr bx,1
            ;and ax,3DEFh  
            ;and bx,3DEFh  
            ;add ax,bx
          .endif

        .elseif BitsPerPixel == 16
          .if BMapStatus > 0
                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus

                      xor ebx,ebx
                      mov bx, es:[si];BGB              ;get background color
                      mov eax,UniColor3
                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      mov ah,al
                      shr eax,8

                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     

                      mov es:[si],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16

          .else
            mov es:[si],ax

           ;mov bx,es:[si]
           ; shr ax,1
           ; shr bx,1
           ; and ax,7BEFh  
           ; and bx,7BEFh  
           ; add ax,bx
          .endif
          
        .elseif BitsPerPixel == 24
          .if BMapStatus == 1
            shr eax,1
            and eax,011111110111111101111111b

           mov ch,3
         .REPEAT
           mov bl,es:[si]
           shr bl,1
           add al,bl
           mov es:[si],al
           add si,1
         jnc nof41
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
         nof41:
           shr eax,8
           dec ch
         .UNTIL ch == 0   

               .else

           mov ch,3
           pixel_plot:
           mov es:[si],al
           add si,1
           jnc nof4
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
           nof4:
           shr eax,8
           dec ch
           jnz pixel_plot
          .endif
        .elseif BitsPerPixel == 32
          .if BMapStatus > 0
              shl edx,16
              shl ecx,16

              mov cx,BMapStatus

              mov ebx, es:[si];BGB              ;get background color
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
              ;mov es:[di],eax                   ;draw result colors

              shr ecx,16
              shr edx,16

            ;mov ebx,es:[si]
            ;shr eax,1
            ;shr ebx,1
            ;and eax,011111110111111101111111b
            ;and ebx,011111110111111101111111b
            ;add eax,ebx
          .endif
          mov es:[si],eax
        .endif

SkipOnePixel:
        retn
OnePixel endp


;#############################################################################
;SVGAcircle (CX, CY, Radius, Color)   
;
;  returns nothing
;#############################################################################
;cut***********************************************************************cut
;                 Written for the PC-GPE by Mark Feldman
;            e-mail address : u914097@student.canberra.edu.au
;                             myndale@cairo.anu.edu.au
;
;旼컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Circle Algorithm �
;읕컴컴컴컴컴컴컴컴켸
;
;Circles have the property of being highly symetrical, which is handy
;when it comes to drawing them on a display screen.
;
;      |y          (This diagram is supposed to be a circle, try viewing
;      |           it in 50 line mode).
;  \ ..... /
;   .  |  .        We know that there are 360 degrees in a circle. First we
;  . \ | / .       see that a circle is symetrical about the x axis, so
;  .  \|/  .       only the first 180 degrees need to be calculated. Next
;--.---+---.--     we see that it's also symetrical about the y axis, so now
;  .  /|\  . x     we only need to calculate the first 90 degrees. Finally
;  . / | \ .       we see that the circle is also symetrical about the 45
;   .  |  .        degree diagonal axis, so we only need to calculate the
;  / ..... \       first 45 degrees.
;      |
;      |
;
;Bresenhams circle algorithm calculates the locations of the pixels in the
;first 45 degrees. It assumes that the circle is centered on the origin. So
;for every pixel (x,y) it calculates we draw a pixel in each of the 8 octants
;of the circle :
;
;PutPixel(CenterX + X, Center Y + Y)
;PutPixel(CenterX + X, Center Y - Y)
;PutPixel(CenterX - X, Center Y + Y)
;PutPixel(CenterX - X, Center Y - Y)
;PutPixel(CenterX + Y, Center Y + X)
;PutPixel(CenterX + Y, Center Y - X)
;PutPixel(CenterX - Y, Center Y + X)
;PutPixel(CenterX - Y, Center Y - X)
;
;So let's get into the actual algorithm. Given a radius for the circle
;we perform this initialisation:
;
;d := 3 - (2 * RADIUS)
;x := 0
;y := RADIUS
;
;Now for each pixel we do the following operations:
;Draw the 8 circle pixels
;            
;(x := x + 1)            
;if d < 0 then
;    d := d + (4 * x) + 6
;else
;  begin
;    d := d + 4 * (x - y) + 10
;    y := y - 1;
;  end;
;
;And we keep doing this until x = y. Note that the values added to the
;decision variable in this algorithm (x and y) are constantly changing, so
;we cannot precalculate them. The muliplications however are by 4, and we
;can accomplish this by shifting left twice.
;
;cut***********************************************************************cut
;
;The circle routine is repeated 4 times since only two of the 8 pixels per 
;loop are aligned on the same scanline, doing it this way will limit the 
;number of bank swithes in svga mode.
;
PUBLIC SVGAcircle
SVGAcircle proc    BASIC
        push bp
        mov bp,sp
        push gs
        push eax
        push ebx

        mov eax,[bp+06]

        mov UniColor3,eax

        cmp BitsPerPixel,15
        jnz @F
        shl ax,3       
        shl eax,5      
        shl ax,3       
        shr eax,11     
@@:
        cmp BitsPerPixel,16
        jnz @F
        shl ax,2       
        shl eax,6      
        shl ax,3       
        shr eax,11     
@@:
        mov UniColor,eax

        mov ax,VideoSegment
        mov es,ax

        mov ax,[bp+14]
        mov X1,ax
        mov ax,[bp+12]
        mov Y1,ax
        mov cx,[bp+10]
        mov Radius,cx
        mov bp,cx     

        cmp cx,0
        jle NoCircle  

        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di     ;X=0

        mov bx,X1       ;draw top pixel
        sub bx,di
        mov ax,Y1
        sub ax,bp
        call OnePixel

loop1:
        inc di        ;X
        mov bx,di

        cmp D,0
        jge D_is_positive
        sal bx,2
        add D,bx
        jmp  Adddone
D_is_positive:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp        ;Y
Adddone:
        mov bx,X1
        sub bx,di
        mov ax,Y1
        sub ax,bp
        mov Y2,ax        ;needed for pixel overlapping check
        call OnePixel
        mov bx,X1
        add bx,di
        mov ax,Y2
        call OnePixel
        
        cmp di,bp
        jl loop1

        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di

        mov bx,X1       ;draw left most and right most pixel
        sub bx,bp
        mov ax,Y1
        sub ax,di
        Call Onepixel
        mov bx,X1
        add bx,bp
        mov ax,Y1
        sub ax,di
        Call Onepixel

loop2:
        inc di
        mov bx,di

        cmp D,0
        jge  Dispositive1
        sal bx,2
        add D,bx
        jmp  Adddone1
Dispositive1:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Adddone1:

        mov bx,X1
        sub bx,bp
        mov ax,Y1
        sub ax,di

        cmp ax,Y2    ;pixel overlap check
        jle overlap

        Call Onepixel
        mov bx,X1
        add bx,bp
        mov ax,Y1
        sub ax,di
        Call Onepixel

        cmp di,bp
        jle  loop2

overlap:


        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di

        mov bx,X1
        add bx,di
        mov ax,Y1
        add ax,bp
        Call Onepixel
loop3:
        inc di
        mov bx,di

        cmp D,0
        jge  Dispositive2
        sal bx,2
        add D,bx
        jmp  Adddone2
Dispositive2:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Adddone2:
        mov bx,X1
        add bx,bp
        mov ax,Y1
        add ax,di
        mov Y2,ax        ;needed for pixel overlapping check
        mov X2,bx        ;
        Call Onepixel
        mov bx,X1
        sub bx,bp
        mov ax,Y1
        add ax,di
        Call Onepixel

        cmp di,bp
        jl  loop3


        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di
loop4:
        inc di
        mov bx,di

        cmp D,0
        jge  Dispositive3
        sal bx,2
        add D,bx
        jmp  Adddone3
Dispositive3:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Adddone3:
        mov bx,X1
        add bx,di
        mov ax,Y1
        add ax,bp
        .if (ax == Y2) && (bx == X2) ;pixel overlap check
          jmp overlap1
        .endif
        Call Onepixel
        mov bx,X1
        sub bx,di
        mov ax,Y1
        add ax,bp
        Call Onepixel

        cmp di,bp
        jl  loop4
overlap1:
NoCircle:
        pop ebx
        pop eax
        pop gs
        pop bp
        retf 10
SVGAcircle endp

;#############################################################################
;SVGAfillcircle (CX, CY, Radius, Color)   
;
;  returns nothing
;#############################################################################
PUBLIC SVGAfillcircle
SVGAfillcircle proc    BASIC
        push bp
        mov bp,sp
        push gs
        push eax
        push ebx

        mov eax,[bp+06]
;        cmp BitsPerPixel,15
;        jnz @F
;        shl ax,3       
;        shl eax,5      
;        shl ax,3       
;        shr eax,11     
;@@:
;        cmp BitsPerPixel,16
;        jnz @F
;        shl ax,2       
;        shl eax,6      
;        shl ax,3       
;        shr eax,11     
;@@:
        mov UniColor,eax

        mov ax,VideoSegment
        mov es,ax

        mov ax,[bp+14]
        mov X1,ax
        mov ax,[bp+12]
        mov Y1,ax
        mov cx,[bp+10]
        mov Radius,cx
        mov bp,cx     

        cmp cx,0
        jle NoCircle1  

        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di     ;X=0

fill_loop1:
        inc di        ;X

        cmp D,0
        jge D_is_positive1
        mov bx,di
        sal bx,2
        add D,bx
        jmp  Add_done
D_is_positive1:

        push di
         push Y2
         push X2
         push X3
         push UniColor
         call SVGAhline
        pop di

        mov bx,di
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp        ;Y
Add_done:
        mov bx,X1
        sub bx,di
        mov X2,bx

        mov ax,Y1
        sub ax,bp
        mov Y2,ax        ;also needed for pixel overlapping check
        mov bx,X1
        add bx,di
        mov X3,bx
        
        cmp di,bp
        jl fill_loop1

        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax

        xor di,di

        mov ax,Y1
        sub ax,di
        push ax
        mov bx,X1       
        sub bx,bp
        push bx
        mov bx,X1
        add bx,bp
        push bx
        push UniColor
        call SVGAhline

        xor di,di

fill_loop2:
        inc di
        mov bx,di

        cmp D,0
        jge  D_is_positive5
        sal bx,2
        add D,bx
        jmp  Add_done1
D_is_positive5:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Add_done1:

        push di
          mov ax,Y1
          sub ax,di
          push ax
          mov bx,X1
          sub bx,bp
          push bx
          mov bx,X1
          add bx,bp
          push bx
          push UniColor
          call SVGAhline
        pop di

        cmp ax,Y2    ;pixel overlap check
        jle overlap3

        cmp di,bp
        jle fill_loop2

overlap3:

        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di

;        mov bx,X1
;        add bx,di
;        mov ax,Y1
;        add ax,bp
;        Call Onepixel
fill_loop3:
        inc di
        mov bx,di

        cmp D,0
        jge  D_is_positive2
        sal bx,2
        add D,bx
        jmp  Add_done2
D_is_positive2:
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Add_done2:
        mov bx,X1
        add bx,bp
        mov ax,Y1
        add ax,di
        mov Y2,ax        ;needed for pixel overlapping check
        mov X2,bx        ;

        push di
          push ax
          push bx
          mov bx,X1
          sub bx,bp
          push bx
          push UniColor
          call SVGAhline
        pop di

        cmp di,bp
        jl fill_loop3

        mov cx,Radius
        mov bp,cx
        mov ax,cx
        sal ax,1
        neg ax
        mov D,ax
        xor di,di
fill_loop4:
        inc di

        cmp D,0
        jge  D_is_positive3
        mov bx,di
        sal bx,2
        add D,bx
        jmp  Add_done3
D_is_positive3:

        push di
         push Y3
         push X3
         push X4
         push UniColor
         call SVGAhline
        pop di

        mov bx,di
        sub bx,bp
        sal bx,2
        add D,bx
        dec bp
Add_done3:
        mov ax,Y1
        add ax,bp
        mov Y3,ax

        mov bx,X1
        sub bx,di
        mov X3,bx

        mov bx,X1
        add bx,di
        mov X4,bx

        .if (ax == Y2) && (bx == X2) ;pixel overlap check
          jmp overlap2
        .endif
;        Call Onepixel
;        mov bx,X1
;        sub bx,di
;        mov ax,Y1
;        add ax,bp
;        Call Onepixel

        cmp di,bp
        jl fill_loop4
overlap2:
NoCircle1:
        pop ebx
        pop eax
        pop gs
        pop bp
        retf 10
SVGAfillcircle endp


;#############################################################################
;SVGAput (X, Y, offset, segment)   
;                      
;  returns nothing                 
;#############################################################################
PUBLIC SVGAput
SVGAput proc    BASIC
        push bp
        mov bp,sp
        push fs
        push gs
        push eax
        push ds

        mov ax,[bp+06]    ;Segment
        mov fs,ax
        mov si,[bp+08]    ;offset
                
        mov ax,VideoSegment
        mov es,ax
        
        mov ax,[bp+12]    ;X
        mov X1,ax
        mov ax,fs:[si]
        mov dx,ax         ;dx=delta_x-1
        add ax,X1         
        mov X2,ax

        mov cl,XshiftFactor
        shl dx,cl

        cmp BitsPerPixel,24
        jnz @F
        add dx,fs:[si]
@@:
        add dx,BytesPP    ;dx=delta_x


        cmp ax,X1VP;0
        jl Noput
        
        add si, 2

        mov ax,[bp+10]    ;Y
        mov Y1,ax
        mov ax,fs:[si]
        add ax,Y1
        mov Y2,ax

        cmp ax,Y1VP
        jl Noput

        add si,2
     
        mov ax,X2
        cmp ax,X2VP
        jl short @F
        mov ax,X2VP
        dec ax
        mov X2,ax
@@:
        

        mov ax,X1
        cmp ax,X1VP
        jge short @F          ;clip left
          mov bx,X1VP
          sub ax,bx
          neg ax                
          mov bx,ax
          mov cl,XshiftFactor
          shl ax,cl
          .if BitsPerPixel == 24
             add dx,bx
          .endif
          add si,ax             
          mov ax,X1VP
          mov X1,ax
@@:

        mov ax,X2
        sub ax,X1
        inc ax
        mov temp1,ax
        mov temp4,ax

        mov ax,X1
        cmp ax,X2VP
        jge Noput
        mov ax,Y1
        cmp ax,Y2VP
        jge Noput

        mov bx,temp1
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,temp4
        .endif

        mov temp1,bx

        mov cx,dx
        sub cx,bx
        mov temp3,cx

        mov ax,Y1
        cmp ax,Y1VP
        jge short @F

        mov bx,Y1VP
        sub ax,bx
        neg ax
        mul dx
        add si,ax
        mov ax,Y1VP
        mov Y1,ax
@@:

        mov ax,Y2VP
        cmp ax,Y2
        jg short @F
        dec ax
        mov Y2,ax
@@:


        mov bx,X1
        mov ax,Y1
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        Mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,X1
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        mov bx,temp1
        mov cx,BytesPerScanLine
        sub cx,bx
        mov temp2,cx

        push dx
        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif
        pop dx

        mov bp,Y2
        sub bp,Y1
        inc bp


mov ax,ds
mov gs,ax
mov ax,fs
mov ds,ax
assume ds:gs
putloop:

        .if BMapStatus > 0
          jmp @F
        .endif

        cmp MaskColor,0            ;if filter is on, always use single pixel
        jge short @F               ;put

        mov bx,temp1               ;do we at any time cross a bank border?
        add bx,di
        jae DoBlit21               ;if no, then blit
@@:
        xor eax,eax
        mov cx,temp4               ;temp4= pixels
        mov bx,BytesPP
pixelloop21:
        .if bx == 1
           mov al,fs:[si]
        .elseif bx == 2
           mov ax,fs:[si]
        .elseif bx == 3
           mov eax,fs:[si]
           and eax,00ffffffh
        .elseif bx == 4
           mov eax,fs:[si]
        .endif

        cmp MaskColor,0
        jl short filterOff2111
        cmp MaskColor,eax
        jz FilerOut2111
FilterOff2111:

        .if bx == 1

          .if BMapStatus == 1
            ;push gs
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
              pixel_put24:
         
              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push cx
              push bx
              push ds
              mov ax,gs
              mov ds,ax

              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop ds
              pop bx
              pop cx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_put24
              add si,bx
              jmp NoInc21021
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

FilerOut2111:

        add si,bx
        add di,bx
        jae short NoInc21021
        inc dx
        push eax
        push bx
        push cx
        push dx
        push ds
        mov ax,gs
        mov ds,ax

        cmp VideoSegment,0a000h
        jnz short EMSIsActive7
        Call SetVESABank
        jmp short @F
EMSIsActive7:
        Call SetEMSBank
@@:
        pop ds
        pop dx
        pop cx
        pop bx
        pop eax
NoInc21021:
        dec cx
        jnz pixelloop21   ;if zero then done

        jmp nextline

DoBlit21:
        mov bx,temp1
        mov cx,bx

      .if MMXStatus == 1

        .if bx >= 8
          shr cx,3
          mmx5:
            movq MM0,fs:[si]
            movq es:[di],MM0
            add di,8
            add si,8
            dec cx
          jnz mmx5

          and bx,7
          jz @F
        .endif

        .if bx >= 4
          movsd
          and bx,3
          jz @F
        .endif

      .else

        .if bx >= 4
          shr cx,2
          rep movsd
          and bx,3
          jz @F
        .endif

      .endif

        .if bx >= 2
          movsw
          and bx,1
          jz @F
        .endif

        movsb
@@:
nextline:
        add di,temp2
        jae @F
        inc dx
        push ds
        mov ax,gs
        mov ds,ax

        cmp VideoSegment,0a000h
        jnz short EMSIsActive691
        push dx
        Call SetVESABank
        pop dx
        pop ds
        jmp short @F
EMSIsActive691:
        push dx
        Call SetEMSBank
        pop dx
        pop ds
@@:

        add si,temp3
        dec bp
        jnz putloop
Noput:
assume ds:DGROUP
        pop ds
        .if MMXStatus == 1
          emms
        .endif
        pop eax
        pop gs
        pop fs
        pop bp
        retf 8
SVGAput endp





;#############################################################################
;SVGAget (X1, Y1, X2, Y2, Offset, Segment)   
;                                  
;  graps data from screen and stores it at Segment:Offset
;#############################################################################
PUBLIC SVGAget
SVGAget proc    BASIC
        push bp
        mov bp,sp
        push es
        push fs
        push eax

        mov ax,[bp+10]
        mov Y2,ax
        mov ax,[bp+14]
        mov Y1,ax
        cmp ax,Y2
        JLE YlessOk2
        xchg ax,Y2
        xchg ax,Y1
YlessOk2:
        mov ax,[bp+12]
        mov X2,ax
        mov ax,[bp+16]
        mov X1,ax
        cmp ax,X2
        JLE XlessOk2
        xchg ax,X2
        xchg ax,X1
XlessOk2:

        mov ax,X2
        cmp ax,0
        jl NoGet
        mov ax,Y2
        cmp ax,0
        jl NoGet

        mov ax,VideoSegment
        mov fs,ax

        mov ax,[bp+06]
        mov es,ax
        mov di,[bp+08]

        mov ax,X2
        sub ax,X1
        stosw
        mov dx,ax         ;
        inc dx            ;dx=delta_x
        mov ax,Y2
        sub ax,Y1
        stosw

        mov ax,Y1
        mov bx,X1

        mov ax,X2
        cmp ax,XResolution
        jl  @F
        mov ax,XResolution
        dec ax
        mov X2,ax
@@:
        mov ax,X1
        cmp ax,0
        jge  @F
        neg ax                ;clip left 
        mov temp6,ax
        mov cl,XshiftFactor
        shl ax,cl
        .if BitsPerPixel == 24
             add ax,temp6
        .endif
        add si,ax
        add di,ax
        mov X1,0
@@:

        mov ax,X2
        sub ax,X1
        inc ax
        mov temp1,ax
        
        mov ax,X1
        cmp ax,XResolution
        jge NoGet
        mov ax,Y1
        cmp ax,YResolution
        jge NoGet

        mov temp6,dx
        mov cl,XshiftFactor
        shl dx,cl
        .if BitsPerPixel == 24
             add dx,temp6
        .endif
        mov bp,dx      ;bp=bytes to move per scanline


getloop:
        push ax
        push di

        mov bx,X1
                
        cmp ax,YResolution
        jae doneline2155

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp6,bx
        mov cl,Xshiftfactor
        shl bx,cl

        .if BitsPerPixel == 24
             add bx,temp6
        .endif

        add ax,bx
        adc dx,0

        mov si,ax

        cmp VideoSegment,0a000h
        jnz EMSIsActive9

        push dx
        Call SetVESABank
        pop dx
        jmp @F
EMSIsActive9:
        push dx
        Call SetEMSBank
        pop dx
@@:

        mov ax,bp                  ;do we at any time cross a bank border?
        add ax,si
        jae DoBlit2155             ;if no, then blit

        mov cx,temp1               ;# pixels to move
        xor eax,eax
        mov bx,BytesPP
pixelloop2155:
        
        cmp bx,1
        jnz @F
        mov al,fs:[si]
        mov es:[di],al
@@:
        cmp bx,2
        jnz @F
        mov ax,fs:[si]
        mov es:[di],ax
@@:
        cmp bx,3
        jnz @F
          .if si < 1111111111111100b
                mov eax,fs:[si]
          .endif
        mov es:[di],ax
        shr eax,16
        mov es:[di+2],al
@@:
        cmp bx,4
        jnz @F
        mov eax,fs:[si]
        mov es:[di],eax
@@:

        add di,bx
        add si,bx
        jae  NoInc2102155
        inc dx
        push eax
        push bx
        push cx
        push dx

        cmp VideoSegment,0a000h
        jnz EMSIsActive10
        Call SetVESABank
        jmp @F
EMSIsActive10:
        Call SetEMSBank
@@:
        pop dx
        pop cx
        pop bx
        pop eax
NoInc2102155:
        dec cx
        jnz pixelloop2155 ;if zero then done

        jmp doneline2155

DoBlit2155:
        
        mov bx,bp
        mov cx,bx

        push ds
        mov ax,fs
        mov ds,ax

        cmp bx, 4                   ;if less than 4 pixels use stosb else
        jl wordblit2155             ;use stosd and stosb for the remaining
                                    ;bytes
        shr cx,2
        rep movsd
        and bx,3
        jz @F
wordblit2155:
        cmp bx,2
        jl byteblit2155
        movsw
        and bx,1
        jz @F
byteblit2155:
        cmp bx,1
        jl @F
        movsb
@@:
        pop ds
        
doneline2155:

        pop di
        pop ax

        add di,bp
        inc ax
        cmp ax,Y2
        jle getloop
NoGet:
        pop eax
        pop fs
        pop es
        pop bp
        retf 12
SVGAget endp

;#############################################################################
;Internal MouseInterrupt      
;
;  Updates Mx,My,Mb
;#############################################################################
MouseInt proc    FAR
        cli
        mov ax,@data
        mov ds,ax
        mov Mx,cx
        mov My,dx
        mov Mb,bx
        sti
        retf
MouseInt endp


;#############################################################################
;ViewPage (P)
;
;  returns nothing
;#############################################################################
PUBLIC ViewPage
ViewPage proc    BASIC
        push bp
        mov bp,sp
        push ebx
        push eax

        mov ax,[bp+06]              ;page

        xor bh,bh
        mov bl,NumberOfImagePages

        cmp ax,bx
        jg PageNoFound

        cmp ActivePage,ax
        je PageNoFound

        mov ActivePage,ax

        cmp Status,1
        jnz TheMouseIsNotOn1
        push BMapStatus
        push MaskColor ;save them for later use if the mouse is on.
        push ViewPageX
        push ViewPageY
        push TMx
        push TMy
TheMouseIsNotOn1:

        mul YResolution
        mov ViewPageY,ax
        mov ViewPageX,0

PageisSet:

        cmp Status,1
        jnz MouseIsNotOn
        
        mov di,offset TempCursorBuffer
        mov si,offset CursorBuffer

        mov bx,256
        mov cl,XShiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,256
        .endif

        shr bx,2
        mov cx,bx
        mov ax,SEG TempCursorBuffer;@code
        mov es,ax
        mov ax,SEG CursorBuffer
        push ds
        mov ds,ax
        rep movsd                   ;move CursorBuffer into TempCursorBuffer
        pop ds

        mov Status,0
        call SVGAmouseOn            ;draw mouse on the page we are flipping to
MouseIsNotOn:

        mov cx,[bp+06]
        mov ebx,1
        shl ebx,cl

        mov cx,ViewPageX
        mov dx,ViewPageY

        mov eax,ebx
        and eax,ScrollLockInfo
        cmp ebx,eax                 ;is the page locked from scrolling
        jz @F
        add cx,ScrollX
        add dx,ScrollY
@@:

        mov ax,4f07h                ;now flip to the page
        xor bx,bx
        int 10h

        cmp Status,1
        jnz TheMouseIsNotOn

        mov dx,3dah             ; retrace wait
trace2:                         
        in al,dx                
        and al,8
        jnz trace2
trace3:
        in al,dx
        and al,8
        jz trace3

        pop ax          ;TMy
        pop bx          ;TMx
        pop cx          ;cx and dx points to the page that 
        pop dx          ;was flipped from. We need to erase the mouse on that page
        push ActivePageX
        push ActivePageY

        mov ActivePageX,dx
        mov ActivePageY,cx

        push bx         ;X1
        push ax         ;Y1
        push offset TempCursorBufferX
        push SEG TempCursorBufferX;@code

        mov MaskColor,-1
        mov BMapStatus,0
        call SVGAput

        pop ActivePageY
        pop ActivePageX
        pop MaskColor
        pop BMapStatus

TheMouseIsNotOn:
PageNoFound:
        pop eax
        pop ebx
        pop bp
        retf 2
ViewPage endp


;#############################################################################
;SVGAhline  (Y, X1, X1, Color)      
;
;   returns nothing        (draws a horizontal line)
;#############################################################################
PUBLIC SVGAhline
SVGAhline  proc    BASIC
        push bp
        mov bp,sp
        push eax
        push gs

        mov ax,VideoSegment
        mov es,ax

        mov ax,BMapSEG
        mov gs,ax

        mov ax,[bp+14]       ;Y
        mov bx,[bp+12]       ;X1
        mov cx,[bp+10]       ;X2

        cmp bx,cx
        jl @F
        xchg bx,cx
@@:
        cmp cx,X2VP
        jl @F
        mov cx,X2VP
        dec cx
@@:
        cmp bx,X1VP
        jge @F
        mov bx,X1VP
@@:
        cmp cx,X1VP
        jl doneline
        cmp bx,X2VP
        jge doneline
        cmp ax,Y1VP
        jl doneline
        cmp ax,Y2VP        
        jge doneline

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = number of pixels 

        mov cl,Xshiftfactor
        shl dx,cl

        .if BitsPerPixel == 24
            add dx,temp1
        .endif

        mov temp4,dx              ;temp4 = number of bytes

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp6,bx
        mov tempXval,bx
        mov cl,Xshiftfactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp6
        .elseif BitsPerPixel == 4
            shr bx,3
        .endif

        add ax,bx
        adc dx,0

        mov di,ax

        push dx
        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif
        pop dx

        mov eax,[bp+06]

        .if BitsPerPixel == 8     ;copy al into eax
           mov ah,al
           mov bx,ax
           shl eax,16
           mov ax,bx
           mov Tcolor,al
        .elseif BitsPerPixel == 4
           mov Tcolor,al
        .elseif BitsPerPixel == 15    ;copy ax into eax
           .if BMapStatus > 0
               and eax,00000000000111110001111100011111b
              mov UniColor3,eax
           .endif

           shl ax,3
           shl eax,5      
           shl ax,3       
           shr eax,11     
           mov bx,ax
           shl eax,16
           mov ax,bx
           mov UniColor5,eax
        .elseif BitsPerPixel == 16    ;copy ax into eax
           .if BMapStatus > 0
               and eax,00000000000111110011111100011111b
               mov UniColor3,eax
           .endif

           shl ax,2
           shl eax,6      
           shl ax,3       
           shr eax,11     
           mov bx,ax
           shl eax,16
           mov ax,bx
           mov UniColor5,eax
        .elseif BitsPerPixel == 32
           mov UniColor3,eax
        .endif


LineColorFound:

        .if MMXStatus == 1
           mov dword ptr [tempQword],eax
           mov dword ptr [tempQword+4],eax
           movq MM0,tempQword
            .if BMapStatus > 0
                      mov ax,BMapStatus
                      shr ax,1
                      shl eax,16
                      mov al,byte ptr [BMapStatus]
                      shr al,1
                      mov ah,byte ptr [BMapStatus]
                      shr ah,1
                      movd MM3,eax
                      ;movq MM5,MM3
                      pxor MM7, MM7
                      punpcklbw MM3,MM7
                      movd MM4,dword ptr [UniColor3]
                      punpcklbw MM4,MM7
                      xor eax,eax
            .endif
        .endif

        .if BitsPerPixel == 4
                push dx
                mov dx,3ceh
                xor al,al
                out dx,al
                inc dx
                mov al,Tcolor ;color
                out dx,al
                dec dx
                mov al,5
                out dx,al
                inc dx
                in al,dx
                mov outreg,al
                or al,3
                out dx,al
                pop dx
                jmp blend
        .endif

        cmp BMapStatus,0
        jne blend

        mov bx,temp4               ;do we at any time cross a bank border?
        add bx,di               
        jae DoBlit                 ;if no, then blit
blend:
        mov cx,temp1
        mov bx,BytesPP
pixelloop:

         .if bx == 1
           .if BitsPerPixel == 8
              .if BMapStatus > 0
                 mov bl,es:[di]
                 mov bh,Tcolor
                 mov al,gs:[bx]
                 mov bx,1
              .endif
              mov es:[di],al
           .elseif BitsPerPixel == 4
                  mov bx,cx
                  xor al,al
                  mov cl,byte ptr [tempXval]
                  and cl,7
                  jnz bitloop
                  .if bx >= 32
                    sub bx,32
                    mov eax,0ffffffffh
                    mov byte ptr [tempXval],cl
                    mov cx,bx
                    inc cx
                    mov es:[di],eax
                    mov bx,1
                    add di,4
                    jae NoInc102
                    jmp nolatch
                  .elseif bx >= 16
                    sub bx,16
                    mov ax,0ffffh
                    mov byte ptr [tempXval],cl
                    mov cx,bx
                    inc cx
                    mov es:[di],ax
                    mov bx,1
                    add di,2
                    jae NoInc102
                    jmp nolatch
                  .elseif bx >= 8
                    sub bx,8
                    mov al,255
                    mov byte ptr [tempXval],cl
                    mov cx,bx
                    inc cx
                    mov es:[di],al
                    jmp nolatch
                  .endif
             bitloop:
                  mov ah,10000000b
                  shr ah,cl
                  or al,ah
                  inc cl
                  dec bx
                 jz donepixels
                  .if cl == 8
                   jmp donebits
                  .endif
                 jmp bitloop
donepixels:
                  mov bx,0
donebits:
                  .if al != 255
                    mov ah, es:[di] ;load latches
                  .endif
                  mov byte ptr [tempXval],cl
                  mov cx,bx
                  inc cx

                  mov es:[di],al
nolatch:                  
                mov bx,1
           .endif
         .elseif bx == 2
            .if BMapStatus > 0
              .if BitsPerPixel == 16
                  .if MMXStatus == 1
                      movq MM1,MM4                     ;mov 32 bit Foreground color data to mm1
                      mov ax, es:[di]                  ;get background color
                      shl eax,11
                      shr ax,3
                      shr eax,6
                      shr ax,2
                      movd MM2, eax                     ;mov 32 bit Background color data to mm2
                      punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                      psubw MM1,MM2                     ;substract brackground from foreground
                      pmullw MM1,MM3                    ;multibly by the blend value
                      psraw MM1,7                       ;div (signed) by 128
                      paddw MM1,MM2                     ;Add Background 
                      packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                      movd eax,MM1                      ;draw the pixel
                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     
                      mov es:[di],ax                    ;draw pixel
                  .else


                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus

                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color

                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
                      mov ah,al
                      shr eax,8

                      shl ax,2
                      shl eax,6
                      shl ax,3
                      shr eax,11     

                      mov es:[di],ax                   ;draw result colors

                      shr ecx,16
                      shr edx,16
                      mov bx,2
                  .endif
              .else
                 .if MMXStatus == 1
                      movq MM1,MM4                     ;mov 32 bit Foreground color data to mm1
                      mov ax, es:[di];BGB              ;get background color
                      shl eax,11  
                      shr ax,3    
                      shr eax,5   
                      shr ax,3    
                      movd MM2, eax                     ;mov 32 bit Background color data to mm2
                      punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                      psubw MM1,MM2                     ;substract brackground from foreground
                      pmullw MM1,MM3                    ;multibly by the blend value
                      psraw MM1,7                       ;div (signed) by 128
                      paddw MM1,MM2                     ;Add Background 
                      packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                      movd eax,MM1                      
                      shl ax,3
                      shl eax,5      
                      shl ax,3       
                      shr eax,11     
                      mov es:[di],ax                    ;draw pixel
                 .else


                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
              
                      mov eax, UniColor3
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color
                      shl ebx,11  
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      and bl, 00011111b
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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
                      mov bx,2
                  .endif
              .endif

            .else
              mov es:[di],ax
            .endif
         .elseif bx == 3
           .if di <= 1111111111111100b
              mov es:[di],ax
              rol eax,16
              mov es:[di+2],al
              rol eax,16
           .else
              mov bytemem,3
              pixel_hline24:

              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push cx
              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif
              pop cx
              pop eax
           @@:
              ror eax,8
              dec bytemem
              jnz pixel_hline24
              rol eax,24

             mov bx,3
             jmp NoInc102
           .endif
         .elseif bx == 4
            .if BMapStatus > 0
                 .if MMXStatus == 1
                      movq MM1,MM4                      ;mov 32 bit Foreground color data to mm1
                      movd MM2, dword ptr es:[di]       ;mov 32 bit Background color data to mm1
                      punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                      psubw MM1,MM2                     ;substract brackground from foreground
                      pmullw MM1,MM3                    ;multibly by the blend value
                      psraw MM1,7                       ;div (signed) by 128
                      paddw MM1,MM2                     ;Add Background 
                      packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                      movd dword ptr es:[di],MM1        ;draw the pixel
                 .else

                      shl edx,16
                      shl ecx,16

                      mov cx,BMapStatus
                      mov eax,UniColor3
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

                      mov ebx,4
              .endif
            .else
              mov es:[di],eax
            .endif
         .endif

        add di,bx
        jae NoInc102
        inc dx
        push eax
        push bx
        push cx
        push dx
        push gs

        cmp VideoSegment,0a000h
        jnz EMSIsActive5
        Call SetVESABank
        jmp @F
EMSIsActive5:
        Call SetEMSBank
@@:
        pop gs
        pop dx
        pop cx
        pop bx
        pop eax

NoInc102:
        dec cx
        jnz pixelloop

        jmp doneline

DoBlit:
        mov bx,temp4
        mov cx,bx

      .if BitsPerPixel == 24
        shr cx,2
          mov edx,eax
          ror eax, 16
          mov ah,dl
          rol eax, 16
          shr edx,8

        .if bx >= 4
         bit_24: 
           stosd
           rol eax,16
           xchg dx,ax
          dec cx
          jnz bit_24
          and bx,3
          jz doneline
        .endif
        .if bx >= 2
          stosw
          shr eax,16
          and bx,1
          jz doneline
        .endif
        .if bx >= 1
          stosb
        .endif
       jmp doneline
      .endif


      .if MMXStatus == 1

        .if bx >= 8
          shr cx,3
          mmx6:
            movq es:[di],MM0
            add di,8
            dec cx
          jnz mmx6
          and bx,7
          jz doneline
        .endif

        .if bx >= 4
          stosd
          and bx,3
          jz doneline
        .endif

      .else

        .if bx >= 4
          shr cx,2
          rep stosd
          and bx,3
          jz doneline
        .endif

      .endif

        .if bx >= 2
          stosw
          and bx,1
          jz doneline
        .endif

        .if bx >= 1
          stosb
        .endif
doneline:
        .if MMXStatus == 1
          emms
        .endif
        .if BitsPerPixel == 4
                mov al,outreg
                mov dx,3cfh
                out dx,al
        .endif
        pop gs
        pop eax
        pop bp
        retf 10
SVGAhline endp


;#############################################################################
;SVGAhlinetext (Y, X1, X2, offset, segment) 
;
;    returns nothing             (draws a horizontal bitmap line)
;#############################################################################
PUBLIC SVGAhlinetext
SVGAhlinetext  proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx
        push ecx
        push edx

        mov ax,VideoSegment
        mov es,ax

        mov ax,[bp+06]       ;segment
        mov fs,ax
        mov si,[bp+08]       ;offset

        mov ax,[bp+14]       ;Y
        mov bx,[bp+12]       ;X1
        mov cx,[bp+10]       ;X2


        cmp bx,cx
        jl @F
        xchg bx,cx
@@:
        cmp cx,X2VP;XResolution
        jl @F
        mov cx,X2VP;XResolution
        dec cx
@@:
        cmp bx,X1VP
        jge @F
        sub bx,X1VP
        neg bx                ;clips left
        mov temp6,bx
        push cx
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp6
        .endif
        pop cx
        add si,bx             ;
        mov bx,X1VP
@@:

        cmp cx,X1VP
        jl doneline1

        cmp cx,X1VP
        jl doneline1
        cmp bx,X2VP
        jge doneline1

        cmp ax,Y1VP
        jl doneline1
        cmp ax,Y2VP        
        jge doneline1


        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = # of pixels 
        mov cl,XshiftFactor
        shl dx,cl
        .if BitsPerPixel == 24
            add dx,temp1
        .endif
        mov temp4,dx              ;temp4 = # of bytes

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine
        
        mov temp6,bx
        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp6
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        push dx
        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif
        pop dx      

        cmp BMapStatus,0
        jne @F           

        cmp MaskColor,0            ;if filter is on, always use single byte
        jge @F                     ;put

        mov bx,temp4               ;do we at any time cross a bank border?
        add bx,di               
        jae DoBlit1                ;if no, then blit

@@:
        .if MMXStatus == 1
            .if BMapStatus > 0     ;init mmx blending constants
                      xor eax,eax
                      mov ax,BMapStatus
                      shr ax,1
                      shl eax,16
                      mov al,byte ptr [BMapStatus]
                      shr al,1
                      mov ah,byte ptr [BMapStatus]
                      shr ah,1
                      movd MM3,eax
                      pxor MM7, MM7                     ;set mm7 to zero data
                      punpcklbw MM3,MM7
            .endif
        .endif

        mov cx,temp1
        mov bx,BytesPP
        xor eax,eax
pixelloop1:
        
        .if bx == 1
          mov al,fs:[si]
        .elseif bx == 2
          mov ax,fs:[si]
        .elseif bx == 3
           mov eax,fs:[si]
           and eax,00ffffffh
        .elseif bx == 4
          mov eax,fs:[si]
          and eax,00ffffffh
        .endif

        cmp MaskColor,0
        jl short FilterOff111
        cmp MaskColor,eax
        jz FilerOut111
FilterOff111:

        .if bx == 1
              .if BMapStatus > 0
                 mov bx,BmapSEG
                 mov gs,bx
                 mov bl,es:[di]
                 mov bh,al
                 mov al,gs:[bx]
                 mov bx,1
              .endif
          mov es:[di],al
        .elseif bx == 2
           .if BMapStatus > 0 
              .if BitsPerPixel == 16
                      .if MMXStatus == 1
                              mov bx,word ptr es:[di]       
                              shl eax,11
                              shl ebx,11
                              shr ax,3
                              shr bx,3
                              shr eax,6
                              shr ebx,6
                              shr ax,2
                              shr bx,2
                              and eax, 000111110011111100011111b                         
                              and ebx, 000111110011111100011111b
                              movd MM1,eax                      ;mov 32 bit Foreground color data to mm1
                              movd MM2,ebx                      ;mov 32 bit Background color data to mm1
                              punpcklbw MM1,MM7                 ;spread the 8bit data to 16bit data
                              punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                              psubw MM1,MM2                     ;substract brackground from foreground
                              pmullw MM1,MM3                    ;multibly by the blend value
                              psraw MM1,7                       ;div (signed) by 128
                              paddw MM1,MM2                     ;Add Background 
                              packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                              movd eax,MM1                     
                              shl ax,2
                              shl eax,6
                              shl ax,3
                              shr eax,11     
                              mov es:[di],ax                   ;draw result colors
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
                      .endif
              .else
                      .if MMXStatus == 1
                              and eax,0FFFFh
                              mov bx, es:[di]  
                              shl eax,11  
                              shl ebx,11
                              shr ax,3    
                              shr bx,3
                              shr eax,5   
                              shr ebx,5
                              shr ax,3    
                              shr bx,3
                              and eax, 000111110011111100011111b
                              and ebx, 000111110011111100011111b
                              movd MM1,eax                      ;mov 32 bit Foreground color data to mm1
                              movd MM2,ebx                      ;mov 32 bit Background color data to mm1
                              punpcklbw MM1,MM7                 ;spread the 8bit data to 16bit data
                              punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                              psubw MM1,MM2                     ;substract brackground from foreground
                              pmullw MM1,MM3                    ;multibly by the blend value
                              psraw MM1,7                       ;div (signed) by 128
                              paddw MM1,MM2                     ;Add Background 
                              packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                              movd eax,MM1   
                              shl ax,3
                              shl eax,5      
                              shl ax,3       
                              shr eax,11     
                              mov es:[di],ax                   ;draw result colors
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

              pixel_hlinetext24:
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
              jnz pixel_hlinetext24
              add si,bx
             jmp NoInc1021

           .endif
        .elseif bx == 4
           .if BMapStatus > 0 
              ;newblender
                      .if MMXStatus == 1
                              movd MM1,eax                      ;mov 32 bit Foreground color data to mm1
                              movd MM2, dword ptr es:[di]       ;mov 32 bit Background color data to mm2
                              punpcklbw MM1,MM7                 ;spread the 8bit data to 16bit data
                              punpcklbw MM2,MM7                 ;spread the 8bit data to 16bit data
                              psubw MM1,MM2                     ;substract brackground from foreground
                              pmullw MM1,MM3                    ;multibly by the blend value
                              psraw MM1,7                       ;div (signed) by 128
                              paddw MM1,MM2                     ;Add Background 
                              packuswb MM1,MM1                  ;pack 16 bit down to 8bit
                              movd dword ptr es:[di],MM1        ;draw the pixel
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
              
                              mov bx,4
                      .endif
           .else
              mov es:[di],eax
           .endif
        .endif
FilerOut111:

        add si,bx

        add di,bx
        jae short NoInc1021
        inc dx
        push eax
        push bx
        push cx
        push dx
        .if VideoSegment == 0a000h
                Call SetVESABank
        .else
                Call SetEMSBank
        .endif
        pop dx
        pop cx
        pop bx
        pop eax

NoInc1021:
        dec cx
        jnz pixelloop1

        jmp doneline1

DoBlit1:
        mov bx,temp4
        mov cx,bx

     .if MMXStatus == 1
        .if bx >= 8
          shr cx,3
          mmx3:
            movq MM0,fs:[si]
            movq es:[di],MM0
            add di,8
            add si,8
            dec cx
          jnz mmx3
          and bx,7
          jz doneline1
        .endif

        .if bx >= 4
          mov eax,fs:[si]
          mov es:[di],eax
          add di,4
          add si,4
          and bx,3
          jz doneline1
        .endif

        .if bx >= 2
          mov ax,fs:[si]
          mov es:[di],ax
          add di,2
          add si,2
          and bx,1
          jz doneline1
        .endif

        .if bx >= 1
          mov al,fs:[si]
          mov es:[di],al
        .endif

     .else
        push ds
        mov ax,fs
        mov ds,ax

        .if bx >= 4
          shr cx,2
          rep movsd
          and bx,3
          jz @F
        .endif

        .if bx >= 2
          movsw
          and bx,1
          jz @F
        .endif

        .if bx >= 1
          movsb
        .endif
@@:
        pop ds
     .endif
doneline1:
        .if MMXStatus == 1
          emms
        .endif

        pop edx
        pop ecx
        pop ebx
        pop eax
        pop bp
        retf 10
SVGAhlinetext endp


;#############################################################################
;SVGAhlinetextREAD (Y, X1, X2, offset, segment)  
;               
;  graps one scan line from screen and stores it at Segment:Offset        
;#############################################################################
PUBLIC SVGAhlinetextREAD
SVGAhlinetextREAD  proc    BASIC
        push bp
        mov bp,sp
        push eax

        mov ax,VideoSegment
        mov fs,ax

        mov ax,[bp+06]       ;segment
        mov es,ax
        mov di,[bp+08]       ;offset

        mov ax,[bp+14]       ;Y
        mov bx,[bp+12]       ;X1
        mov cx,[bp+10]       ;X2
        

        cmp bx,cx
        jl  @F
        xchg bx,cx
@@:
        cmp cx,XResolution
        jl  @F
        mov cx,XResolution
        dec cx
@@:
        cmp bx,0
        jge  @F
        neg bx                ;clips left
        mov temp6,bx
        push cx
        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
            add bx,temp6
        .endif

        pop cx
        add di,bx             ;
        mov bx,0
@@:

        cmp cx,0
        jl doneline133
        
        cmp bx,XResolution
        jge doneline133
        cmp ax,YResolution
        jae doneline133

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp = # of pixels 

        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp6,bx

        mov cl,XshiftFactor
        shl bx,cl

        .if BitsPerPixel == 24
           add bx,temp6
        .endif

        add ax,bx
        adc dx,0

        mov si,ax

        cmp VideoSegment,0a000h
        jnz EMSIsActive13
        push dx
        Call SetVESABank
        pop dx
        jmp @F
EMSIsActive13:
        push dx
        Call SetEMSBank
        pop dx
@@:


        mov bx,temp1               ;do we at any time cross a bank border?
        mov cl,Xshiftfactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp1
        .endif

        add bx,si
        jae DoBlit133               ;if no, then blit


        mov cx,temp1

pixelloop133:
        .if BytesPP == 1
          mov al,fs:[si]
          mov es:[di],al
        .endif

        .if BytesPP == 2
          mov ax,fs:[si]
          mov es:[di],ax
        .endif

        .if BytesPP == 3
          .if si <= 1111111111111100b
                mov eax,fs:[si]
          .else
              mov bytemem,3

              pixel_hlinetext24read:
              mov al,es:[si]
              add si,1
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
              jnz pixel_hlinetext24read
              ror eax,8
              add di,BytesPP
             jmp NoInc102133
          .endif


          mov es:[di],ax
          shr eax,16
          mov es:[di+2],al
        .endif

        .if BytesPP == 4
          mov eax,fs:[si]
          mov es:[di],eax
        .endif
        
        add di,BytesPP

        add si,BytesPP
        jae NoInc102133
        inc dx
        push ax
        push cx
        push dx

        cmp VideoSegment,0a000h
        jnz EMSIsActive14
        Call SetVESABank
        jmp @F
EMSIsActive14:
        Call SetEMSBank
@@:

        pop dx
        pop cx
        pop ax
NoInc102133:
        dec cx
        jnz pixelloop133

        ;loop pixelloop133
        jmp doneline133

DoBlit133:
        mov bx,temp1
        mov cl,Xshiftfactor
        shl bx,cl
        .if BitsPerPixel == 24
            add bx,temp1
        .endif
        mov cx,bx
        
        push ds
        mov ax,fs
        mov ds,ax

        cmp bx,4       
        jl wordblit331  
        shr cx,2
        rep movsd
        and bx,3
        jz @F
wordblit331:
        cmp bx,2
        jl byteblit331
        movsw
        and bx,1
        jz @F
byteblit331:
        cmp bx,1
        jl @F
        movsb
@@:
        pop ds
doneline133:
        pop eax
        pop bp
        retf 10
SVGAhlinetextREAD endp


;#############################################################################
;SVGAtext  (X, Y, textoff, textseg, Fcolor, Bcolor)
;             
;    returns nothing            
;#############################################################################
PUBLIC SVGAtext
SVGAtext  proc    BASIC
        push bp
        mov bp,sp
        push fs
        push gs
        push eax
        push ebx
        push ecx

        mov ax,VideoSegment
        mov es,ax

        mov eax,[bp+06]     ;background color

        .if eax != -1
             .if BitsPerPixel == 15
               .if BMapStatus > 0
                  mov UniColor3,eax
               .endif
                shl ax,3
                shl eax,5      
                shl ax,3       
                shr eax,11     
             .elseif BitsPerPixel == 16
               .if BMapStatus > 0
                  mov UniColor3,eax
               .endif
                shl ax,2
                shl eax,6      
                shl ax,3       
                shr eax,11     
             .elseif (BitsPerPixel == 32) || (BitsPerPixel == 24)
               ;.if BMapStatus == 1
               ;   shr eax,1
               ;   and eax,011111110111111101111111b
               ;.endif
             .endif
        .endif

        mov UniColor2,eax

        mov eax,[bp+10]     ;foreground color

        .if eax != -1
             .if BitsPerPixel == 15
               .if BMapStatus > 0
                  mov UniColor4,eax
               .endif
                shl ax,3
                shl eax,5      
                shl ax,3       
                shr eax,11     
             .elseif BitsPerPixel == 16
               .if BMapStatus > 0
                  mov UniColor4,eax
               .endif
                shl ax,2
                shl eax,6      
                shl ax,3       
                shr eax,11     
             .elseif (BitsPerPixel == 32) || (BitsPerPixel == 24)
               ;.if BMapStatus == 1
               ;   shr eax,1
               ;   and eax,011111110111111101111111b
               ;.endif
             .endif
        .endif

        mov UniColor1,eax

        mov ax,[bp+14]     ;text segment
        mov gs,ax
        mov ax,[bp+16]     ;text offset
        mov OffsetDATA,ax       

        mov ax,[bp+18]     ;Y
        mov Y1,ax
        add ax,Fontheight
        dec ax
        mov Y2,ax

        mov ax,[bp+20]     ;X
        mov X1,ax
        add ax,FontWidth
        dec ax
        mov X2,ax

        mov ax,[bp+18]     ;Y
        mov bx,[bp+20]     ;X

        mov fs,FontSeg

charloop:

        push ax
        mov si,OffsetDATA
        mov ax,[bp+14]     ;text segment
        mov gs,ax
        xor ax,ax
        mov al,gs:[si] ;get next char
        mov cl,al
        mul Fontheight
        mov si,FontOff
        add si,ax               ;si = start offset of charecter
        pop ax

        cmp cl,0
        jz endtext
        inc OffsetDATA           

        mov cx,BmapSEG
        mov gs,cx

heightloop:
        xor cx,cx
        mov ch,fs:[si]
        mov Bitscan,cx
        inc si
widhtloop:
        rol Bitscan,1
        jae Usebackground
        cmp UniColor1,0
        jl SkipPixel999
        mov ecx,UniColor1
        mov UniColor,ecx
               .if BMapStatus > 0
                  mov ecx,UniColor4
                  mov UniColor5,ecx
               .endif
        jmp Useforeground
Usebackground:
        cmp UniColor2,0
        jl SkipPixel999
        mov ecx,UniColor2
        mov UniColor,ecx
               .if BMapStatus > 0
                  mov ecx,UniColor3
                  mov UniColor5,ecx
               .endif
Useforeground:

       cmp bx,X1VP
       jl SkipPixel999
       cmp bx,X2VP
       jge SkipPixel999
       cmp ax,Y1VP
       jl SkipPixel999
       cmp ax,Y2VP        
       jge SkipPixel999


        push ax
        push bx
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp1,bx

        mov cl,XshiftFactor
        shl bx,cl

        cmp BitsPerPixel,24
        jnz @F
        add bx,temp1
@@:

        add ax,bx
        adc dx,0
        mov di,ax

        .if VideoSegment == 0a000h
           Call SetVESABank
        .else
           Call SetEMSBank
        .endif

        mov eax, UniColor

        .if BytesPP == 1
          .if BMapStatus == 1
            mov bl,es:[di]
            mov bh,al
            add bx,BMapOFF
            mov al,gs:[bx]
          .endif
          mov es:[di],al
        .elseif BytesPP == 2
            .if BMapStatus > 0
              .if BitsPerPixel == 16
                      
                      shl edx,16
                      shl ecx,16


                      mov cx,BMapStatus

                      mov eax, UniColor5
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color

                      shl ebx,11
                      shr bx,3
                      shr ebx,6
                      shr bx,2
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00111111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed)Subtract the Background Red value
                      mul cx                            ;Multiply it by the fixed alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed)Divide by 256
                      add ax, bx                        ;(Signed)Add the Background Red value
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
              
                      mov eax, UniColor5
                      xor ebx,ebx
                      mov bx, es:[di];BGB              ;get background color
                      shl ebx,11  
                      shr bx,3    
                      shr ebx,5   
                      shr bx,3    
              
                      rol eax,16      ;GB*R
                      rol ebx,16      ;GB*R
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Blue value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Blue value
                      mov ah,al

                      rol eax,8       ;Br*G
                      rol ebx,8       ;Br*G
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
                      sub ax, bx                        ;(Signed) Subtract the Background Green value
                      mul cx                            ;Multiply it by the alpha blend (0 to 255)
                      sar ax, 8                         ;(Signed) Divide by 256
                      add ax, bx                        ;(Signed) Add the Background Green value
                      mov ah,al

                      rol eax,8       ;rg*B
                      rol ebx,8       ;rg*B
                      xor ah, ah                        ;Clear ah
                      and al, 00011111b
                      xor bh, bh
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

              ;mov bx,es:[di]
              ;shr bx,1
              ;and bx,temp2
              ;add bx,ax
              ;mov es:[di],bx
            .else
              mov es:[di],ax
            .endif
        .elseif BytesPP == 3
            .if BMapStatus == 1

           mov ch,3
         .REPEAT
           mov bl,es:[di]
           shr bl,1
           add al,bl
           mov es:[di],al
           add di,1
         jnc @F
           inc dx
           push eax
           .if VideoSegment == 0a000h
              Call SetVESABank
           .else
              Call SetEMSBank
           .endif
           pop eax
         @@:
           shr eax,8
           dec ch
         .UNTIL ch == 0   


            .else

              mov ch,3

              pixel_text24:

              mov es:[di],al
              add di,1
              jnc nof_1
              inc dx
              push eax
              .if VideoSegment == 0a000h
                 Call SetVESABank
              .else
                 Call SetEMSBank
              .endif
              pop eax
              nof_1:
              shr eax,8

              dec ch
              jnz pixel_text24
            .endif
        .elseif BytesPP == 4
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

              ;mov ebx,es:[di]
              ;shr ebx,1
              ;and ebx,011111110111111101111111b
              ;add ebx,eax
              ;mov es:[di],ebx
              ;mov ebx,4
            .else
              mov es:[di],eax
            .endif
        .endif

        pop bx
        pop ax
SkipPixel999:

        inc bx
        cmp bx,X2
        jle widhtloop

        mov bx,X1
        inc ax
        cmp ax,Y2
        jle heightloop

        mov ax,FontWidth
        add X1,ax
        add X2,ax
        mov bx,X1
        mov ax,Y1

        jmp charloop

endtext:
        pop ecx
        pop ebx
        pop eax

        pop gs
        pop fs
        pop bp
        retf 16
SVGAtext endp

;#############################################################################
;SVGAsetfont (Mode)
;             
;    returns nothing            (sets the system font format)
;#############################################################################
PUBLIC SVGAsetfont
SVGAsetfont  proc    BASIC
        push bp
        mov bp,sp
        pushad

        mov ax,[bp+06]

        cmp ax,0
        jnz Not8x8
        mov ax,1130h
        mov bx,300h
        int 10h
        mov FontSeg,es
        mov FontOff,bp
        mov FontWidth,8
        mov Fontheight,8
Not8x8:
        cmp ax,1
        jnz Not8x16
        mov ax,1130h
        mov bx,600h
        int 10h
        mov FontSeg,es
        mov FontOff,bp
        mov FontWidth,8
        mov Fontheight,16
Not8x16:
        cmp ax,2
        jnz Not8x14
        mov ax,1130h
        mov bx,200h
        int 10h
        mov FontSeg,es
        mov FontOff,bp
        mov FontWidth,8
        mov Fontheight,14
Not8x14:

        popad
        pop bp
        retf 2
SVGAsetfont endp




;#############################################################################
;SetEMSBank
;             
;    returns nothing            
;#############################################################################
PUBLIC SetEMSBank
SetEMSBank  proc  FAR

        cmp EMSActiveBank,dx
        je @F
        mov EMSActiveBank,dx
        mov Globalbank,dx
        mov bx,dx
        mov dx,ActiveEMSBuffer ;holds ems handle
        mov EMShandle,dx       ;holds ems handle
        shl bx,2
        mov al,0
        mov ah,44h
        int 67h
        Inc bx
        mov al,1
        mov ah,44h
        int 67h
        Inc bx
        mov al,2
        mov ah,44h
        int 67h
        Inc bx
        mov al,3
        mov ah,44h
        int 67h
@@:
        retf
SetEMSBank endp


;#############################################################################
;SetVESABank
;             
;    returns nothing            
;#############################################################################
PUBLIC SetVESABank
SetVESABank  proc  FAR
        mov Vmem64kBankpos,dx
        mov Globalbank,dx
        mov cl,byte ptr BankShift
        shl dx,cl
        cmp ActiveBank,dx
        je @F
        mov ActiveBank,dx
        xor bx,bx
        mov ax,4f05h
        int 10h
        mov bx,1
        mov ax,4f05h
        int 10h
@@:
        retf
SetVESABank endp

;#############################################################################
;RealColor (R, G, B) 
;             
;    returns 24->15,24->16,24->24,24->32
;#############################################################################
PUBLIC RealColor
RealColor  proc  BASIC
        push bp
        mov bp,sp
        push ebx
        mov ebx,[bp+06]
        and ebx,00FFFFFFh

        .if BitsPerPixel == 8
           xor ah,ah
           mov al,[bp+06]
           xor dx,dx
        .elseif BitsPerPixel == 15 
           mov bh,[bp+10]
           shl ebx,8
           mov bh,[bp+08]
           mov bl,[bp+06]
           shr ebx,3
           and ebx,000111110001111100011111b
           shl bx,3
           shl ebx,5      
           shl bx,3       
           shr ebx,11     
           mov ax,bx
           xor dx,dx
        .elseif BitsPerPixel == 16
           mov bh,[bp+10]
           shl ebx,8
           mov bl,[bp+06]
           shr ebx,3
           mov bh,[bp+08]
           shr bh,2
           and ebx,000111110011111100011111b

           shl bx,2
           shl ebx,6      
           shl bx,3       
           shr ebx,11     
           mov ax,bx
           xor dx,dx
        .elseif (BitsPerPixel == 32) || (BitsPerPixel == 24)
        xor dh,dh
        mov dl,[bp+10]
        mov ah,[bp+08]
        mov al,[bp+06]
;           mov ax,bx
;           shr ebx,16
;           mov dx,bx
        .endif

        pop ebx
        pop bp
        retf 6
RealColor endp

;#############################################################################
;Real2Color (RealColor&) 
;             
;    returns 15->24,16->24,24->24,32->24
;#############################################################################
PUBLIC Real2Color
Real2Color  proc  BASIC
        push bp
        mov bp,sp
        push ebx
        mov ebx,[bp+06]
        and ebx,00FFFFFFh

        .if BitsPerPixel == 8
           xor ah,ah
           mov al,[bp+06]
           xor dx,dx
        .elseif BitsPerPixel == 15 ;0|11111|11111|11111->00000000|00011111|00011111|00011111|
           xor ebx,ebx
           mov bx,[bp+06];0000000000000000 011111 11111 11111b
           shl ebx,11  ;00000011111 11111 11111 00000000000b   
           shr bx,3    ;00000011111 11111 00011111 00000000b   
           shr ebx,5   ;00000000000 11111 11111 00011111000b   
           shr bx,3    ;00000000 00011111 00011111 00011111b
           mov ax,bx
           shr ebx,16
           mov dx,bx
        .elseif BitsPerPixel == 16
           xor ebx,ebx
           mov bx,[bp+06]
           shl ebx,11     
           shr bx,3
           shr ebx,6      
           shr bx,2
           mov ax,bx
           shr ebx,16
           mov dx,bx
        .elseif (BitsPerPixel == 32) || (BitsPerPixel == 24)
        xor dh,dh
        mov dl,[bp+08]
        mov ah,[bp+07]
        mov al,[bp+06]

;           mov ax,bx
;           shr ebx,16
;           mov dx,bx
        .endif

        pop ebx
        pop bp
        retf 4
Real2Color endp

;#############################################################################
;RGB2Color (R, G, B)
;             
;    returns Rbyte:Gbyte:Bbyte encoded color
;#############################################################################
PUBLIC RGB2Color
RGB2Color  proc  BASIC
        push bp
        mov bp,sp
        xor dh,dh
        mov dl,[bp+10]
        mov ah,[bp+08]
        mov al,[bp+06]

        .if BitsPerPixel == 15
          shr dl,3
          shr ah,3
          shr al,3
        .elseif BitsPerPixel == 16
          shr dl,3
          shr ah,2
          shr al,3
        .endif
        pop bp
        retf 6
RGB2Color endp


;#############################################################################
;Color2RGB (C&, R, G, B)
;           
;    returns encoded color
;#############################################################################
PUBLIC Color2RGB
Color2RGB  proc  BASIC
        push bp
        mov bp,sp

        mov bl,[bp+14]
        mov ah,[bp+13]
        mov al,[bp+12]

        .if BitsPerPixel == 8     ;return palette color
          ;mov dx,3C7h
          ;out dx,al
          ;mov dx,3C9h
          ;in al,dx
          ;mov bl,al
          ;in al,dx
          ;mov ah,al
          ;in al,dx
          ;shl bl,2
          ;shl ah,2
          ;shl al,2
        .elseif BitsPerPixel == 15
          shl bl,3
          shl ah,3
          shl al,3
        .elseif BitsPerPixel == 16
          shl bl,3
          shl ah,2
          shl al,3
        .endif

        mov si,[bp+06]
        mov [si],al
        mov byte ptr [si+1],0
        mov si,[bp+08]
        mov [si],ah
        mov byte ptr [si+1],0
        mov si,[bp+10]
        mov [si],bl
        mov byte ptr [si+1],0
        pop bp
        retf 10
Color2RGB endp

;#############################################################################
;SVGAViewPort (X1VP,Y1VP,X2VP,Y2VP)
;
;  
;#############################################################################
PUBLIC SVGAViewport
SVGAViewport proc    BASIC
        push bp
        mov bp,sp

        mov ax,[bp+06]
        .if ax < 0
          mov ax,0
        .endif
        .if ax > YResolution
          mov ax,YResolution
          dec ax
        .endif
        mov y2vp,ax

        mov cx,[bp+08]
        .if cx < 0
          mov cx,0
        .endif
        .if cx > XResolution
          mov cx,XResolution
        .endif
        mov x2vp,cx

        mov ax,[bp+10]
        .if ax < 0
          mov ax,0
        .endif
        .if ax > YResolution
          mov ax,YResolution
          dec ax
        .endif
        mov y1vp,ax

        mov cx,[bp+12]
        .if cx < 0
            mov cx,0
        .endif
        .if cx > XResolution
            mov cx,XResolution
        .endif
        mov x1vp,cx

        mov ax,y1vp
        .if y2vp < ax
         xchg ax,y2vp
         xchg ax,y1vp
        .endif

        mov ax,x1vp
        .if x2vp < ax
         xchg ax,x2vp
         xchg ax,x1vp
        .endif

        pop bp
        retf 8
SVGAViewport endp

;#############################################################################
;BitRotateL(val,count) 
;
;  
;#############################################################################
PUBLIC BitRotateL
BitRotateL proc    BASIC
        push bp
        mov bp,sp
        mov ax,[bp+08]
        mov cl,[bp+06]
        rol ax,cl
        pop bp
        retf 4
BitRotateL endp

;#############################################################################
;Conv24 (32bitseg%,32bitoff%,24bitseg%,24bitoff%,pixels)
;
;  
;#############################################################################
PUBLIC Conv24
Conv24 proc    BASIC
        push bp
        mov bp,sp
        push gs
        push eax

        mov cx,[bp+06]

        mov ax,[bp+08]
        mov si,ax
        mov ax,[bp+10]
        mov gs,ax
        mov ax,[bp+12]
        mov di,ax
        mov ax,[bp+14]
        mov es,ax

        .if BitsPerPixel == 32
           con24to32loop:
            mov eax,gs:[si]
            and eax,0ffffffh
            stosd
            add si,3 
            dec cx
          jnz con24to32loop
        .elseif BitsPerPixel == 24
           con24to24loop:
            mov eax,gs:[si]
            and eax,0ffffffh
            stosw
            shr eax,16
            stosb
            add si,3 
            dec cx
          jnz con24to24loop
        .elseif BitsPerPixel == 16
           con24to16loop:
            mov eax,gs:[si]
            ror eax,8
            shr ah,3
            rol eax,8
            shr ah,2
            shr al,3

            shl ax,2
            shl eax,6      
            shl ax,3       
            shr eax,11     
            
            stosw
            add si,3 
            dec cx
          jnz con24to16loop
        .elseif BitsPerPixel == 15
           con24to15loop:
            mov eax,gs:[si]
            ror eax,8
            shr ah,3
            rol eax,8
            shr ah,3
            shr al,3

            shl ax,3
            shl eax,5      
            shl ax,3       
            shr eax,11     
            
            stosw
            add si,3 
            dec cx
          jnz con24to15loop
        .endif

        pop eax
        pop gs
        pop bp
        retf 10
Conv24 endp


;#############################################################################
;Conv8 (CLUTseg%,CLUToff%,32bitseg%,32bitoff%,8bitseg%,8bitoff%,pixels)
;
;  
;#############################################################################
PUBLIC Conv8
Conv8 proc    BASIC
        push bp
        mov bp,sp
        push gs
        push fs
        push eax

        mov cx,[bp+06]

        mov ax,[bp+08]
        mov si,ax
        mov ax,[bp+10]
        mov gs,ax

        mov ax,[bp+12]
        mov di,ax
        mov ax,[bp+14]
        mov es,ax
        mov dx,[bp+16]
        mov ax,[bp+18]
        mov fs,ax

        
        .if BitsPerPixel == 32
           con8to32loop:
            xor bx,bx
            mov bl,gs:[si]
            shl bx,2
            add bx,dx
            mov eax,fs:[bx]
            stosd
            add si,1
            dec cx
           jnz con8to32loop
        .elseif BitsPerPixel == 24
           con8to24loop:
            xor bx,bx
            mov bl,gs:[si]
            shl bx,2
            add bx,dx
            mov eax,fs:[bx]
            stosw
            shr eax,16
            stosb
            add si,1
            dec cx
           jnz con8to24loop
        .elseif (BitsPerPixel == 16) || (BitsPerPixel == 15)
           con8to1516loop:
            xor bx,bx
            mov bl,gs:[si]
            shl bx,2
            add bx,dx
            mov ax,fs:[bx]
            stosw
            add si,1
            dec cx
           jnz con8to1516loop
         .endif

        pop eax
        pop fs
        pop gs
        pop bp
        retf 14
Conv8 endp


;#############################################################################
;Conv4 (CLUTseg%,CLUToff%,32bitseg%,32bitoff%,8bitseg%,8bitoff%,pixels)
;
;  
;#############################################################################
PUBLIC Conv4
Conv4 proc    BASIC
        push bp
        mov bp,sp
        push gs
        push fs
        push eax

        mov cx,[bp+06]

        mov ax,[bp+08]
        mov si,ax
        mov ax,[bp+10]
        mov gs,ax

        mov ax,[bp+12]
        mov di,ax
        mov ax,[bp+14]
        mov es,ax
        mov dx,[bp+16]
        mov ax,[bp+18]
        mov fs,ax

        
        .if BitsPerPixel == 32
           shr cx,1
           con4to32loop:
            xor bx,bx
            mov bl,gs:[si]
            shr bl,4
            shl bx,2
            add bx,dx
            mov eax,fs:[bx]
            stosd
            xor bx,bx
            mov bl,gs:[si]
            and bl,00001111b
            shl bx,2
            add bx,dx
            mov eax,fs:[bx]
            stosd
            add si,1
            dec cx
           jnz con4to32loop
        .elseif (BitsPerPixel == 16) || (BitsPerPixel == 15)
           shr cx,1
           con4to1516loop:
            xor bx,bx
            mov bl,gs:[si]
            shr bl,4
            shl bx,2
            add bx,dx
            mov ax,fs:[bx]
            stosw
            xor bx,bx
            mov bl,gs:[si]
            and bl,00001111b
            shl bx,2
            add bx,dx
            mov ax,fs:[bx]
            stosw
            add si,1
            dec cx
           jnz con4to1516loop
         .elseif BitsPerPixel == 8
           shr cx,1
           con4to8loop:
            mov al,gs:[si]
            shr al,4
            stosb
            mov al,gs:[si]
            and al,00001111b
            stosb
            add si,1
            dec cx
           jnz con4to8loop
         .endif

        pop eax
        pop fs
        pop gs
        pop bp
        retf 14
Conv4 endp


;#############################################################################
;MMX check
;
;  AX returns -1 if MMX is found and 0 if not
;#############################################################################
PUBLIC IsMMX
IsMMX proc    BASIC
.586
        push edx
        push ebx
        push ecx

        pushfd             ;CPUID check
        pop ecx            ;
        mov ebx,ecx        ;
        xor ecx,00200000h  ; flip flag bit 21
        push ecx           ;
        popfd              ;
        pushfd             ;
        pop ecx            ;
        mov ax,0           ;
        cmp ecx,ebx        ;
        jz NoMMX           ;

        push eax           ;MMX check
        mov eax,1          ;
        cpuid              ;
        pop eax            ;
        mov ax,0           ;
        test edx,00800000h ; test cpuid bit 23
        jz NoMMX           ;
        mov ax,-1          ;
NoMMX:
        pop ecx
        pop ebx
        pop edx
        retf
.386
IsMMX endp

;#############################################################################
;SetMMX (OnOff%)
;
;  
;#############################################################################
PUBLIC SetMMX
SetMMX proc    BASIC
        mov bx,sp
        mov ax,[bx+04]
        mov MMXStatus,ax
        retf 2
SetMMX endp

;#############################################################################
;SetBlender (onoff)
;
;  
;#############################################################################
PUBLIC SetBlender
SetBlender proc    BASIC
        push bp
        mov bp,sp
        xor ax,ax
        mov al,[bp+06]
        mov BMapStatus,ax

        pop bp
        retf 2
SetBlender endp



END

