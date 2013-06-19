;#############################################################################
;
;                   SVGA/3d routines made by Future Software
;                            for BASIC programming 
;
;#############################################################################

.model medium,BASIC
.stack 10h
.386
.mmx

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
EXTRN BitsPerPixel:byte
EXTRN MaskColor:dword

EXTRN textwrapOnOff:byte

EXTRN BMapStatus:word

EXTRN SetVESABank:FAR
EXTRN SetEMSBank:FAR
EXTRN svgahline:FAR

EXTRN X1VP:word
EXTRN Y1VP:word
EXTRN X2VP:word
EXTRN Y2VP:word

EXTRN MMXStatus:word

EXTERN Vmem64kBankpos:Word
EXTERN EMSActiveBank:Word
EXTERN Globalbank:Word

.data

ALIGN 2
X1               dw  0
Y1               dw  0
X2               dw  0
Y2               dw  0
X3               dw  0
Y3               dw  0
Color1           dd  0
Color2           dd  0
Color3           dd  0

LR               dw  0
RR               dw  0
LG               dw  0
RG               dw  0
LB               dw  0
RB               dw  0

U1               dw  0
V1               dw  0
I1               dw  0
U2               dw  0
V2               dw  0
I2               dw  0
U3               dw  0
V3               dw  0
I3               dw  0
Lu               dw  0
Ru               dw  0
Lv               dw  0
Rv               dw  0
Li               dw  0
Ri               dw  0

textureX         dw  0
textureY         dw  0

temp1            dw  0
temp2            dw  0
temp3            dw  0
temp4            dw  0

Intpart1         db  0
Decpart1         dd  0
Intpart2         db  0
Decpart2         dd  0
Intpart3         db  0
Decpart3         dd  0

ALIGN 2
SegOff           dd  0
id               dd  0
ud               dd  0
vd               dd  0
cd1              dd  0
cd2              dd  0
cd3              dd  0
d1               dd  0
d2               dd  0
d3               dd  0
ud1              dd  0
ud2              dd  0
ud3              dd  0
vd1              dd  0
vd2              dd  0
vd3              dd  0
id1              dd  0
id2              dd  0
id3              dd  0

rd1              dd  0
gd1              dd  0
bd1              dd  0

rd2              dd  0
gd2              dd  0
bd2              dd  0

rd3              dd  0
gd3              dd  0
bd3              dd  0

R                dd  0
G                dd  0
B                dd  0
V                dd  0
U                dd  0
I                dd  0

CalLr            dd  0
CalRr            dd  0
CalLg            dd  0
CalRg            dd  0
CalLb            dd  0
CalRb            dd  0

bytemem          db 0

bankhold         db -1

Fix16LX          dd  0
Fix16RX          dd  0
Fix16LU          dd  0
Fix16RU          dd  0
Fix16LV          dd  0
Fix16RV          dd  0
Fix16LI          dd  0
Fix16RI          dd  0

align 2
tempQword        dq  0 ;mmx
tempQword1       dq  0 ;mmx



textureBitSize   db  5

.code
;#############################################################################
;SVGAtrifill (X1, Y1, X2, Y2, X3, Y3, C) 
;    
;     returns nothing                     (draws a filled triangle)
;#############################################################################
PUBLIC SVGAtrifill
SVGAtrifill  proc    BASIC
        push bp
        mov bp,sp
        push edx
        push ebx
        push eax

        mov eax,[bp+06]
        mov Color1,eax

        mov ax,[bp+20] ;X1
        mov bx,[bp+18] ;Y1
        mov cx,[bp+16] ;X2
        mov dx,[bp+14] ;Y2
        mov si,[bp+12] ;X3
        mov di,[bp+10] ;Y3
        
        cmp bx,dx
        jle NoSwap1
        xchg bx,dx
        xchg ax,cx
NoSwap1:
        cmp bx,di
        jle NoSwap2
        xchg bx,di
        xchg ax,si
NoSwap2:
        cmp dx,di
        jle NoSwap3
        xchg dx,di
        xchg cx,si
NoSwap3:

        mov X1,ax
        mov Y1,bx
        mov X2,cx
        mov Y2,dx
        mov X3,si
        mov Y3,di

        xor eax,eax
        mov ax,Y2
        sub ax,Y1   ;ax=Y2 - Y1
        jz yzero1   ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax
        mov ax,X2
        sub ax,X1   ;ax=X2 - X1
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx 
yzero1:
        mov d1,eax

        xor eax,eax
        mov ax,Y3
        sub ax,Y2   ;ax=Y3 - Y2
        jz yzero2   ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax
        mov ax,X3
        sub ax,X2   ;ax=X3 - X2
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx
yzero2:
        mov d2,eax

        xor eax,eax
        mov ax,Y1
        sub ax,Y3   ;ax=Y1 - Y3
        jz yzero3   ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax
        mov ax,X1
        sub ax,X3   ;ax=X1 - X3
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx 
yzero3:
        mov d3,eax                


.if MMXStatus == 1
        mov bx,X1
        shl ebx,16     ;   ebx = X1 * 10000h
        mov dword ptr [tempQword],ebx
        mov dword ptr [tempQword+4],ebx
        movq MM5,tempQword

        mov ebx,d1
        mov eax,d3
        mov dword ptr [tempQword1],ebx
        mov dword ptr [tempQword1+4],eax
        movq MM6,tempQword1

        mov bp,Y1
        cmp bp,Y2
        jge  skipfistloop
        mov eax,Color1
     Triloop1_mmx:
        movq tempQword,MM5
        mov bx,word ptr [tempQword+2]
        mov cx,word ptr [tempQword+6]
        push bp        ;Y
        push bx        ;LX
        push cx        ;RX
        push eax       ;color
        call SVGAhline
        paddd MM5,MM6
        inc bp
        cmp bp,Y2
        jl short Triloop1_mmx
.else
        mov bp,Y1
        mov bx,X1      
        shl ebx,16     ;   ebx = X1 * 10000h
        mov eax,ebx    ;   edx = X1 * 10000h
        cmp bp,Y2
        jge  skipfistloop
        Triloop1:
        push ebx
        sar ebx,16
        rol eax,16
        push bp        ;Y
        push bx        ;LX
        push ax        ;RX
        push Color1    ;color
        call SVGAhline
        rol eax,16
        pop ebx
        add ebx,d1
        add eax,d3
        inc bp
        cmp bp,Y2
        jl short Triloop1
.endif

skipfistloop:

.if MMXStatus == 1
        cmp bp,Y3
        jg  tridone

        mov bx,X2
        shl ebx,16     ;   ebx = X2 * 10000h
        mov dword ptr [tempQword],ebx
        movq MM5,tempQword

        mov ebx,d2
        mov dword ptr [tempQword1],ebx
        movq MM6, tempQword1

        mov eax,Color1
    Triloop2_mmx:
        movq tempQword,MM5 ;cx**bx**
        mov bx,word ptr [tempQword+2]
        mov cx,word ptr [tempQword+6]
        push bp        ;Y
        push bx        ;LX
        push cx        ;RX
        push eax       ;color
        call SVGAhline
        paddd MM5,MM6
        inc bp
        cmp bp,Y3
        jle short Triloop2_mmx
.else
        cmp bp,Y3
        jg  tridone
        mov bx,X2
        shl ebx,16     ;   ebx = X2 * 10000h
        Triloop2:
        push ebx
        sar ebx,16
        rol eax,16
        push bp        ;Y
        push bx        ;LX
        push ax        ;RX
        push Color1    ;color
        call SVGAhline
        rol eax,16
        pop ebx
        add ebx,d2
        add eax,d3
        inc bp
        cmp bp,Y3
        jle short Triloop2
.endif


tridone:

        .if MMXStatus == 1
          emms
        .endif
        pop eax
        pop ebx
        pop edx
        pop bp
        retf 16
SVGAtrifill endp


;#############################################################################
;SVGAhlineGouraud  (Y, X1, X2 ,LR ,RR ,LG ,RG ,LB ,RB) 
;    
;    returns nothing                   (draws a horizontal Gouraud line)
;#############################################################################
;PUBLIC SVGAhlineGouraud
align 2
SVGAhlineGouraud  proc    BASIC
        push bp
        mov bp,sp
        push esi
        push ecx

        mov ax,VideoSegment
        mov es,ax

        xor ah,ah
        mov al,[bp+06]
        mov RB,ax
        mov al,[bp+08]
        mov LB,ax
        mov al,[bp+10]
        mov RG,ax
        mov al,[bp+12]
        mov LG,ax
        mov al,[bp+14]
        mov RR,ax
        mov al,[bp+16]
        mov LR,ax

        mov bx,[bp+20]       ;X1
        mov cx,[bp+18]       ;X2
        mov X1,bx
        mov X2,cx

        cmp bx,cx
        jl @F
        xchg bx,cx
        mov X1,bx
        mov X2,cx 
        mov ax,LB
        xchg ax,RB
        mov LB,ax 
        mov ax,LG
        xchg ax,RG
        mov LG,ax 
        mov ax,LR
        xchg ax,RR
        mov LR,ax 
@@:
        cmp cx,X2VP
        jl @F
        mov cx,X2VP
        dec cx
@@:
        mov temp2,0     
        cmp bx,X1VP
        jge lessok3314
        sub bx,X1VP
        neg bx          ;
        mov temp2,bx    ;clip left X 
        mov bx,X1VP
lessok3314:
        cmp cx,X1VP
        jl doneline33

        sub cx,bx
        inc cx
        mov temp1,cx              ;temp = # of pixels 

        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        jz @F           ;avoid divide by zero
        cwde            ;ax->eax 
        mov ecx,eax     ;save deltaX 

        mov ax,RR
        sub ax,LR       ;ax=RR - LR
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        rol eax,16
        mov IntPart1,al
        xor ax,ax
        mov DecPart1,eax

        mov ax,RG
        sub ax,LG       ;ax=RG - LG
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        rol eax,16
        mov IntPart2,al
        xor ax,ax
        mov DecPart2,eax

        mov ax,RB
        sub ax,LB       ;ax=RB - LB
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        rol eax,16
        mov IntPart3,al
        xor ax,ax
        mov DecPart3,eax
        jmp nzero
@@:
        mov IntPart1,0
        mov DecPart1,0
        mov IntPart2,0
        mov DecPart2,0
        mov IntPart3,0
        mov DecPart3,0
nzero:

        mov ax,[bp+22]       ;Y

        cmp bx,X2VP
        jge doneline33
        cmp ax,Y1VP
        jl doneline33
        cmp ax,Y2VP
        jge doneline33
       
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp3,bx
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,temp3
        .endif


        add ax,bx
        adc dx,0
        mov di,ax

        .if Globalbank != dx
           push dx
           .if VideoSegment == 0a000h
               Call SetVESABank
           .else
               Call SetEMSBank
           .endif
           pop dx
        .endif

        mov bp,temp1
    
        xor ecx,ecx
        xor ebx,ebx
        xor esi,esi

        mov ax,LB
        mov cl,al

        mov ax,LG
        mov bl,al

        mov ax,LR
        mov bh,al

Gouraudclip:
        cmp temp2,0        ;a lame and slow way to clip but it works
        jz NoGclip         

        add ebx,DecPart3
        adc cl,IntPart3
        add esi,DecPart2
        adc bl,IntPart2  
        add ecx,DecPart1
        adc bh,IntPart1  

        dec temp2
        jmp Gouraudclip
NoGclip:


align 2
pixelloop33: 

        .if BitsPerPixel == 4

        .elseif BitsPerPixel == 8
          mov es:[di],cl
          jmp ByteGpix
        .elseif BitsPerPixel == 15  
          mov ah,bh
          shr ah,3
          shl eax,8
          mov ah,bl
          shr ah,3
          mov al,cl
          shr al,3
          shl ax,3
          shl eax,5      
          shl ax,3       
          shr eax,11     
          mov es:[di],ax
        .elseif BitsPerPixel == 16  
          xor al,al
          mov ah,bh
          shr ah,3
          shl eax,8
          mov ah,bl
          shr ah,2
          mov al,cl
          shr al,3
          shl ax,2
          shl eax,6      
          shl ax,3       
          shr eax,11     
          mov es:[di],ax
        .elseif BitsPerPixel == 24
           .if di <= 1111111111111100b
              mov es:[di],cl
              mov es:[di+1],bx
           .else
              push eax

              mov ax,bx
              shl eax,8
              mov al,cl

              mov bytemem,3
              gour_put24:
         
              mov es:[di],al
              add di,1
              jnc @F
              inc dx
              push eax
              push ecx
              push edx
              push ebx

              .if VideoSegment == 0a000h
                Call SetVESABank
              .else
                Call SetEMSBank
              .endif

              pop ebx
              pop edx
              pop ecx
              pop eax
              @@:
              ror eax,8
              dec bytemem
              jnz gour_put24

              pop eax

                add ecx,DecPart1       ;r
                adc bh,IntPart1  
                add esi,DecPart2       ;g
                adc bl,IntPart2  
                add ebx,DecPart3       ;b
                adc cl,IntPart3        
                jmp NoInc33102
           .endif

        .elseif BitsPerPixel == 32
          mov es:[di],cl
          mov es:[di+1],bx
        .endif
NoGPixel:

        add ecx,DecPart1       
        adc bh,IntPart1        ;r
        add esi,DecPart2       
        adc bl,IntPart2        ;g
ByteGpix:
        add ebx,DecPart3       
        adc cl,IntPart3        ;b

        add di,BytesPP
        jae NoInc33102
        inc dx
        push eax
        push ecx
        push edx
        push ebx
        cmp VideoSegment,0a000h
        jnz EMSIsActive16
        Call SetVESABank
        jmp @F
EMSIsActive16:
        Call SetEMSBank
@@:
        pop ebx
        pop edx
        pop ecx
        pop eax
NoInc33102:
        dec bp
        jnz pixelloop33

doneline33:
        pop ecx
        pop esi
        pop bp
        retf 18
SVGAhlineGouraud endp


;#############################################################################
;SVGAtriGour (X1, Y1, X2, Y2, X3, Y3, C1&, C2&, C3&) 
;    
;     returns nothing                     (draws a gourauded triangle)
;#############################################################################
PUBLIC SVGAtriGour
SVGAtriGour  proc    BASIC
        push bp
        mov bp,sp
        pushad

        mov eax,[bp+06]

        .if BitsPerPixel == 15
          shl eax,3
        .elseif BitsPerPixel == 16
          mov bh,ah
          shl bh,2
          shl eax,3
          mov ah,bh
        .endif

        mov color3,eax
        mov eax,[bp+10]

        .if BitsPerPixel == 15
          shl eax,3
        .elseif BitsPerPixel == 16
          mov bh,ah
          shl bh,2
          shl eax,3
          mov ah,bh
        .endif

        mov color2,eax

        mov eax,[bp+14]

        .if BitsPerPixel == 15
          shl eax,3
        .elseif BitsPerPixel == 16
          mov bh,ah
          shl bh,2
          shl eax,3
          mov ah,bh
        .endif

        mov color1,eax

        mov ax,[bp+28] ;X1
        mov bx,[bp+26] ;Y1
        mov cx,[bp+24] ;X2
        mov dx,[bp+22] ;Y2
        mov si,[bp+20] ;X3
        mov di,[bp+18] ;Y3

        cmp bx,dx
        jle NoSwap11
        xchg bx,dx
        xchg ax,cx
        mov ebp,Color1
        xchg ebp,Color2
        mov Color1,ebp
NoSwap11:
        cmp bx,di
        jle NoSwap12
        xchg bx,di
        xchg ax,si
        mov ebp,Color1
        xchg ebp,Color3
        mov Color1,ebp
NoSwap12:
        cmp dx,di
        jle NoSwap13
        xchg dx,di
        xchg cx,si
        mov ebp,Color3
        xchg ebp,Color2
        mov Color3,ebp
NoSwap13:


        mov X1,ax
        mov Y1,bx
        mov X2,cx
        mov Y2,dx
        mov X3,si
        mov Y3,di

        mov rd1,0
        mov gd1,0
        mov bd1,0
        mov d1,0

        mov ax,Y2
        sub ax,Y1   ;ax=Y2 - Y1
        jz yzero11  ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax
        mov ax,X2
        sub ax,X1   ;ax=X2 - X1
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx 
        mov d1,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color2+2]
        mov dl,byte ptr [Color1+2]       
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov rd1,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color2+1]
        mov dl,byte ptr [Color1+1]       
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov gd1,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color2]
        mov dl,byte ptr [Color1]  
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov bd1,eax
yzero11:


        mov rd2,0
        mov gd2,0
        mov bd2,0
        mov d2,0

        mov ax,Y3
        sub ax,Y2   ;ax=Y3 - Y2
        jz yzero12  ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax
        mov ax,X3
        sub ax,X2   ;ax=X3 - X2
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx
        mov d2,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color3+2]
        mov dl,byte ptr [Color2+2] 
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov rd2,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color3+1]
        mov dl,byte ptr [Color2+1]  
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov gd2,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color3]
        mov dl,byte ptr [Color2]    
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov bd2,eax
yzero12:
        

        mov cd3,0
        mov d3,0
        mov ax,Y1
        sub ax,Y3   ;ax=Y1 - Y3
        jz yzero13  ;avoid divide by zero
        cwde        ;ax->eax (signed)
        mov ebx,eax

        mov ax,X1
        sub ax,X3   ;ax=X1 - X3
        shl eax,16  ;eax=eax*10000h
        cdq         ;eax->edx:eax (signed)
        idiv ebx    ;edx:eax \ ebx 
        mov d3,eax                

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color1+2]
        mov dl,byte ptr [Color3+2]  
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov rd3,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color1+1]
        mov dl,byte ptr [Color3+1]  
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov gd3,eax

        xor ah,ah
        xor dh,dh
        mov al,byte ptr [Color1]
        mov dl,byte ptr [Color3]   
        sub ax,dx
        shl eax,16    ;eax=eax*10000h
        cdq           ;eax->edx:eax (signed)
        idiv ebx      ;edx:eax \ ebx 
        mov bd3,eax
yzero13:
        

        mov di,Y1
        
        push X2        ;save X2 for later use

        mov bx,X1
        shl ebx,16     ;   ebx = X1 * 10000h
        mov edx,ebx    ;   edx = X1 * 10000h

        mov al,byte ptr [Color1+2]
        shl eax,16     
        mov CalLr,eax
        mov CalRr,eax

        mov al,byte ptr [Color1+1]
        shl eax,16     
        mov CalLg,eax
        mov CalRg,eax

        mov al,byte ptr [Color1]
        shl eax,16     
        mov CalLb,eax
        mov CalRb,eax

        cmp di,Y2
        jge  skipfistloop1


Gourloop1:
        push edx
        push ebx

        sar ebx,16
        sar edx,16

        push Y1        ;Y
        push bx        ;LX
        push dx        ;RX

        mov ax,word ptr [CalLr+2]
        push ax        ;LR
        mov cx,word ptr [CalRr+2]
        push cx        ;RR
        mov ax,word ptr [CalLg+2]
        push ax        ;LG
        mov cx,word ptr [CalRg+2]
        push cx        ;RG
        mov ax,word ptr [CalLb+2]
        push ax        ;LB
        mov cx,word ptr [CalRb+2]
        push cx        ;RB
        call SVGAhlineGouraud
        
        pop ebx
        pop edx

        add ebx,d1
        add edx,d3

        mov eax,rd1
        add CalLr,eax
        mov eax,rd3
        add CalRr,eax
        mov eax,gd1
        add CalLg,eax
        mov eax,gd3
        add CalRg,eax
        mov eax,bd1
        add CalLb,eax
        mov eax,bd3
        add CalRb,eax

        inc Y1
        mov ax,Y1
        cmp ax,Y2
        jl  Gourloop1

skipfistloop1:

        pop bx         ;bx=X2
        shl ebx,16     ;ebx = X2 * 10000h

        mov al,byte ptr [Color2+2]
        shl eax,16     
        mov CalLr,eax

        mov al,byte ptr [Color2+1]
        shl eax,16     
        mov CalLg,eax

        mov al,byte ptr [Color2]
        shl eax,16     
        mov CalLb,eax

Gourloop2:
        push edx
        push ebx

        sar ebx,16
        sar edx,16

        push Y1        ;Y
        push bx        ;LX
        push dx        ;RX

        mov ax,word ptr [CalLr+2]
        push ax        ;LR
        mov cx,word ptr [CalRr+2]
        push cx        ;RR
        mov ax,word ptr [CalLg+2]
        push ax        ;LG
        mov cx,word ptr [CalRg+2]
        push cx        ;RG
        mov ax,word ptr [CalLb+2]
        push ax        ;LB
        mov cx,word ptr [CalRb+2]
        push cx        ;RB
        call SVGAhlineGouraud
        
        pop ebx
        pop edx

        add ebx,d2
        add edx,d3

        mov eax,rd2
        add CalLr,eax
        mov eax,rd3
        add CalRr,eax
        mov eax,gd2
        add CalLg,eax
        mov eax,gd3
        add CalRg,eax
        mov eax,bd2
        add CalLb,eax
        mov eax,bd3
        add CalRb,eax

        inc Y1
        mov ax,Y1
        cmp ax,Y3
        jle  Gourloop2

Gourdone:
        popad
        pop bp
        retf 24
SVGAtriGour endp


;#############################################################################
;SVGAhlinetexture  (Y)  (can't be used independently)
;
;    returns nothing                     (draws a horizontal textured line)
;#############################################################################
SVGAhlinetexture  proc   NEAR ;BASIC
        push bp
        mov bp,sp

        lfs si,segoff

        mov bx,word ptr [Fix16LU+2] ;[bp+12]  ;Lu
        mov cx,word ptr [Fix16RU+2] ;[bp+10]  ;Ru
        mov Lu,bx
        mov Ru,cx
        mov bx,word ptr [Fix16LV+2] ;[bp+08]  ;Lv
        mov cx,word ptr [Fix16RV+2] ;[bp+06]  ;Rv
        mov Lv,bx
        mov Rv,cx
        mov bx,word ptr [Fix16LX+2] ;[bp+16]  ;X1
        mov cx,word ptr [Fix16RX+2] ;[bp+14]  ;X2
        mov X1,bx
        mov X2,cx

        cmp bx,cx
        jl textlessok3312
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
textlessok3312:

        cmp cx,X2VP     ;clip right X
        jl @F
        mov cx,X2VP     ;cut off point
        dec cx
@@:

        mov temp2,0     ;

        cmp bx,X1VP
        jge @F
        sub bx,X1VP
        neg bx          ;
        mov temp2,bx    ;clip left X (temp2=pixels to clip)
        mov bx,X1VP
@@:

        cmp cx,X1VP
        jl textdoneline33

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = # of pixels 

        mov ud,0
        mov vd,0

        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        jz textxzero1   ;avoid divide by zero
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
textxzero1:

        mov ax,[bp+06]       ;Y

        cmp bx,X2VP;XResolution
        jge textdoneline33
        cmp ax,Y1VP;YResolution
        jl textdoneline33
        cmp ax,Y2VP;YResolution
        jge textdoneline33
        
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp3,bx
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,temp3
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        .if Globalbank != dx
            push ecx
            push edx
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
            pop edx
            pop ecx
        .endif 

               
        mov ax,Lv
        shl eax,16
        mov bx,Lu
        shl ebx,16

textclip:
        cmp temp2,0        
        jz Notextclip         
        add eax,vd
        add ebx,ud
        dec temp2
        jmp textclip
Notextclip:

        mov bp,temp1
        .if BitsPerPixel == 8
           mov cx,bp
           shl cx,2
           add cx,di
           jnc bit8_text_pixel_loop_nobankchange1
        .endif

text_pixel_loop:
        push eax
        push ebx
        sar eax,16
        sar ebx,16

        .if textwrapOnOff == 0
          cmp bx,TextureX
          ja Nodraw
          cmp ax,TextureY
          ja Nodraw
        .else
          and bx,textureX
          and ax,textureY
        .endif

        mov cl,textureBitSize
        shl ax,cl
        or ax,bx

        mov si,OffsetDATA

        .if BitsPerPixel != 8
          mov temp3,ax
          mov cl,XshiftFactor
          shl ax,cl
        .endif

        .if BitsPerPixel == 24
           add ax,temp3
        .endif
        add si,ax
        xor eax,eax

        mov cx,BytesPP

        .if cx == 1
          mov al,fs:[si]
        .elseif cx == 2
          mov ax,fs:[si]
        .elseif cx == 3
          mov eax,fs:[si]
        .elseif cx == 4
          mov eax,fs:[si]
        .endif

typeskip:

        cmp MaskColor,0
        jl  filterOff21111
        cmp MaskColor,eax
        jz  FilerOut21111
FilterOff21111:

        .if cx == 1
           mov es:[di],al
        .elseif cx == 2
           .if BMapStatus > 0 
              .if BitsPerPixel == 16
                      shl edx,16

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

                      shr edx,16
              .else
                      shl edx,16

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

                      shr edx,16

              .endif
           .endif
           mov es:[di],ax                   ;draw result colors
        .elseif cx == 3
           .if di <= 1111111111111100b
              mov es:[di],eax
           .else
              mov bytemem,3
              text_put24:
         
              mov es:[di],al
              add di,1
              jnc @F
              inc dx
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
              @@:
              ror eax,8
              dec bytemem
              jnz text_put24
                pop ebx
                pop eax
                add eax,vd
                add ebx,ud
                jmp textNoInc33102
           .endif

        .elseif cx == 4
           .if BMapStatus > 0 

              shl edx,16

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
              shr edx,16

              mov cx,4
           .endif

           mov es:[di],eax
        .endif
typeskip1:
FilerOut21111:
Nodraw:
        pop ebx
        pop eax

        add ebx,ud ;X
        add eax,vd ;Y
 

        add di,BytesPP
        jae  textNoInc33102   
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
textNoInc33102:
        dec bp
        jnz text_pixel_loop

textdoneline33:
        pop bp
        retn 2

bit8_text_pixel_loop_nobankchange1:
        mov cl,textureBitSize
        xor esi,esi
        xor edx,edx
        mov dx,OffsetDATA
bit8_text_pixel_loop_nobankchange:
        push eax
        push ebx
        sar eax,16
        sar ebx,16
        .if textwrapOnOff == 0
          cmp bx,TextureX
         ja bit8_Nodraw
          cmp ax,TextureY
         ja bit8_Nodraw
        .else
          and bx,textureX
          and ax,textureY
        .endif

        shl ax,cl
        or ax,bx

        lea esi,[eax+edx]
        xor eax,eax

          mov al,fs:[si]
;bit8_typeskip:
;        cmp MaskColor,0
;        jl  bit8_filterOff21111
;        cmp MaskColor,eax
;        jz  bit8_FilerOut21111
bit8_FilterOff21111:
           mov es:[di],al
bit8_typeskip1:
bit8_FilerOut21111:
bit8_Nodraw:
        pop ebx
        pop eax
        add ebx,ud ;X
        add eax,vd ;Y

        inc di
        dec bp
        jnz bit8_text_pixel_loop_nobankchange

        pop bp
        retn 2
SVGAhlinetexture endp


;#############################################################################
;SVGAtritext (X1, Y1, X2, Y2, X3, Y3, U1, V1, U2, V2, U3, V3, Offset, Segment)
;
;    returns nothing                     (draws a textured triangle)
;#############################################################################
PUBLIC SVGAtritext
SVGAtritext  proc    BASIC
        push bp

        mov bp,sp

        pushad

        mov ax,VideoSegment
        mov es,ax
        
        mov eax,[bp+06]
        ror eax,16
        mov SegOff,eax

        lfs si,segoff

        mov ax,fs:[si+2]
        mov TextureY,ax
        mov ax,fs:[si]
        mov TextureX,ax
        add si,4
        mov OffsetDATA,si

        mov textureBitSize,0
        mov cl,8
@@:
        shr ax,1
        adc textureBitSize,0
        dec cl
        jnz @B

        mov ax,[bp+20] ;U1
        mov U1,ax
        mov bx,[bp+18] ;V1
        mov V1,bx
        mov ax,[bp+16] ;U2
        mov U2,ax
        mov bx,[bp+14] ;V2
        mov V2,bx
        mov ax,[bp+12] ;U3
        mov U3,ax
        mov bx,[bp+10] ;V3
        mov V3,bx
                        
        mov ax,[bp+32] ;X1
        mov bx,[bp+30] ;Y1
        mov cx,[bp+28] ;X2
        mov dx,[bp+26] ;Y2
        mov si,[bp+24] ;X3
        mov di,[bp+22] ;Y3

        cmp bx,dx
        jle NoSwap119
        xchg bx,dx    
        xchg ax,cx    
        mov bp,u1
        xchg bp,u2
        mov u1,bp
        mov bp,v1
        xchg bp,v2
        mov v1,bp
NoSwap119:
        cmp bx,di
        jle NoSwap129
        xchg bx,di    
        xchg ax,si
        mov bp,u1
        xchg bp,u3
        mov u1,bp
        mov bp,v1
        xchg bp,v3
        mov v1,bp
NoSwap129:
        cmp dx,di
        jle NoSwap139
        xchg dx,di    
        xchg cx,si
        mov bp,u2
        xchg bp,u3
        mov u2,bp
        mov bp,v2
        xchg bp,v3
        mov v2,bp
NoSwap139:
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
        jz textxzero19  ;avoid divide by zero
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
textxzero19:
        
        mov d2,0
        mov ud2,0
        mov vd2,0

        mov ax,Y3
        sub ax,Y2       ;ax=Y3 - Y2
        jz textxzero29  ;avoid divide by zero
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
textxzero29:

        mov d3,0
        mov ud3,0
        mov vd3,0

        mov ax,Y1
        sub ax,Y3       ;ax=Y1 - Y3
        jz textxzero39  ;avoid divide by zero
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
textxzero39:


        mov bx,X2
        mov temp4,bx

        mov bx,X1
        shl ebx,16     ;   ebx = X1 * 10000h
        mov edx,ebx    ;   edx = X1 * 10000h
        mov Fix16LX,ebx
        mov Fix16RX,ebx

        mov ax,U1
        shl eax,16     ;   eax = U1 * 10000h
        mov ecx,eax    ;   ecx = U1 * 10000h
        mov Fix16LU,eax
        mov Fix16RU,eax

        mov di,V1
        shl edi,16     ;   edi = V1 * 10000h
        mov ebp,edi    ;   ebp = V1 * 10000h
        mov Fix16LV,edi
        mov Fix16RV,edi

;        mov GlobalBank, -1

        mov si,Y1

        cmp si,Y2
        jge  skipfistTloop1

Textureloop1:
        push si        ;*

        push si        ;Y
        call SVGAhlinetexture
        pop si

        mov eax,d1
        mov ecx,d3
        add Fix16LX,eax
        add Fix16RX,ecx
        mov eax,ud1
        mov ecx,ud3
        add Fix16LU,eax
        add Fix16RU,ecx
        mov eax,vd1
        mov ecx,vd3
        add Fix16LV,eax
        add Fix16RV,ecx

        inc si
        cmp si,Y2
        jl Textureloop1

skipfistTloop1:

        cmp si,Y3
        jg skipSecTloop1

      cmp si, Y3  ;*
      jge @F
        push ebx
        mov ebx,d2
        mov d1,ebx
        mov ebx,ud2
        mov ud1,ebx
        mov ebx,vd2
        mov vd1,ebx

        mov bx,Y3
        mov Y2,bx
        pop ebx

        mov bx,temp4   ;bx=X2
        shl ebx,16     ;ebx = X2 * 10000h
        mov Fix16LX,ebx

        mov ax,U2
        shl eax,16     ;eax = U2 * 10000h
        mov Fix16LU,eax

        mov di,V2
        shl edi,16     ;edi = V2 * 10000h
        mov Fix16LV,edi

        jmp Textureloop1  ;reenter the loop and draw the lower part of the 
                          ;triangle
@@:

skipSecTloop1:
        popad
        pop bp
        retf 28
SVGAtritext endp


;#############################################################################
;SetTextureWrap (OnOff) 
;    
;     returns nothing    
;#############################################################################
PUBLIC SetTextureWrap   
SetTextureWrap  proc    BASIC
        mov bx,sp
        mov ax,[bx+04]
        mov textwrapOnOff,al
        retf 2
SetTextureWrap endp


;#############################################################################
;SVGAhlinetextureL  (Y, X1, X2, LU, RU, LV, RV, LR, RR, LG, RG, LB, RB, Offset, Segment)
;                   34  32  30  28  26  24  22  20  18  16  14  12  10   08       06
;    returns nothing                     (draws a horizontal textured line)
;#############################################################################
PUBLIC SVGAhlinetextureL
SVGAhlinetextureL  proc    BASIC
        push bp
        mov bp,sp
        pushad

        mov ax,VideoSegment
        mov es,ax

        mov ax,[bp+06]  ;segment
        mov fs,ax
        mov ax,[bp+08]
        mov si,ax       ;offset

        xor eax,eax

        mov ax,fs:[si+2]
        mov TextureY,ax
        mov ax,fs:[si]
        mov TextureX,ax
        add si,4

        mov textureBitSize,0
        mov cl,8
@@:
        shr ax,1
        adc textureBitSize,0
        dec cl
        jnz @B

        mov OffsetDATA,si

        mov ax,[bp+20]  ;Lr
        mov cx,[bp+18]  ;Rr
        mov Lr,ax
        mov Rr,cx
        mov ax,[bp+16]  ;Lg
        mov cx,[bp+14]  ;Rg
        mov Lg,ax
        mov Rg,cx
        mov ax,[bp+12]  ;Lb
        mov cx,[bp+10]  ;Rb
        mov Lb,ax
        mov Rb,cx

        mov ax,[bp+28]  ;Lu
        mov cx,[bp+26]  ;Ru
        mov Lu,ax
        mov Ru,cx
        mov ax,[bp+24]  ;Lv
        mov cx,[bp+22]  ;Rv
        mov Lv,ax
        mov Rv,cx
        mov bx,[bp+32]  ;X1
        mov cx,[bp+30]  ;X2
        mov X1,bx
        mov X2,cx

        cmp bx,cx
        jl textlessok3312
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

        mov ax,Lr
        xchg ax,Rr
        mov Lr,ax 

        mov ax,Lg
        xchg ax,Rg
        mov Lg,ax 

        mov ax,Lb
        xchg ax,Rb
        mov Lb,ax 
textlessok3312:

        cmp cx,X2VP     ;clip right X 
        jl @F
        mov cx,X2VP
        dec cx
@@:

        mov temp2,0     ;

        cmp bx,X1VP
        jge @F
        sub bx,X1VP
        neg bx          ;
        mov temp2,bx    ;clip left X 
        mov bx,X1VP
@@:

        cmp cx,X1VP
        jl textdoneline331

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = # of pixels 


        mov ud,0
        mov vd,0
        mov rd1,0
        mov gd1,0
        mov bd1,0

        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        jz textLxzero1   ;avoid divide by zero
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

        mov ax,Rr
        sub ax,Lr       ;ax=Rr - Lr
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov rd1,eax

        mov ax,Rg
        sub ax,Lg       ;ax=Rg - Lg
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov gd1,eax

        mov ax,Rb
        sub ax,Lb       ;ax=Rb - Lb
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov bd1,eax
textLxzero1:

        mov ax,[bp+34]       ;Y

        cmp bx,X2VP;XResolution
        jge textdoneline331
        cmp ax,Y1VP;YResolution
        jl textdoneline331
        cmp ax,Y2VP;YResolution
        jge textdoneline331
        
        add ax,ActivePageY
        add bx,ActivePageX
        mul BytesPerScanLine

        mov temp3,bx
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,temp3
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        push ecx
        push edx
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
        pop edx
        pop ecx
        
              
        mov ax,Lv
        shl eax,16
        mov V,eax

        mov cx,Lu
        shl ecx,16
        mov U,ecx

        mov ax,Lr
        shl eax,16
        mov R,eax

        mov cx,Lg
        shl ecx,16
        mov G,ecx

        mov ax,Lb
        shl eax,16
        mov B,eax

textclip1:       ;clip left
        cmp temp2,0        
        jz Notextclip1
        mov eax,vd
        add V,eax
        mov ebx,ud
        add U,ebx
        mov eax,rd1
        add R,eax
        mov ebx,gd1
        add G,ebx
        mov eax,bd1
        add B,eax
        dec temp2
        jmp textclip1
Notextclip1:

        mov bp,temp1

textL_pixel_loop:
        mov bx,word ptr [U+02] ;texture X
        mov ax,word ptr [V+02] ;texture Y

        .if textwrapOnOff == 0
          cmp bx,TextureX
          ja Nodraw
          cmp ax,TextureY
          ja Nodraw
        .else
          and bx,textureX
          and ax,textureY
        .endif

        mov cl,textureBitSize
        shl ax,cl
        or ax,bx

        mov si,OffsetDATA

        .if BitsPerPixel != 8
          mov temp3,ax
          mov cl,XshiftFactor
          shl ax,cl
        .endif

        .if BitsPerPixel == 24
           add ax,temp3
        .endif
        add si,ax
        xor eax,eax

        mov cl,BitsPerPixel

        .if cl == 8
          mov al,fs:[si]
        .elseif (cl == 15) || (cl == 16)
          mov ax,fs:[si]
        .elseif (cl == 24) || (cl == 32)
          mov eax,fs:[si]
          and eax,0ffffffh
        .endif

        cmp MaskColor,0
        jl  filterOff211111
        cmp MaskColor,eax
        jz  FilerOut211111
FilterOff211111:

        .if cl == 8
        .elseif cl == 16
        .elseif cl == 24
        .elseif cl == 32
           xor cx,cx
           mov ch,byte ptr [B+2]
           add ch,al
           jnc @F
             mov ch,255
           @@:
           mov al,ch

           mov ch,byte ptr [G+2]
           add ch,ah
           jnc @F
             mov ch,255
           @@:
           mov ah,ch
           ror eax,8
           mov ch,byte ptr [R+2]
           add ch,ah
           jnc @F
             mov ch,255
           @@:
           mov ah,ch
           rol eax,8
           mov es:[di],eax
        .endif

FilerOut211111:
Nodraw:

        mov eax,vd
        mov ecx,ud
        add V,eax
        add U,ecx
        mov eax,rd1
        mov ecx,gd1
        add R,eax
        add G,ecx
        mov eax,bd1
        add B,eax


        add di,BytesPP
        jae @F
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
@@:
        dec bp
        jnz textL_pixel_loop

textdoneline331:

        popad
        pop bp
        retf 30
SVGAhlinetextureL endp


;#############################################################################
;SVGAhlinetextureNL  (Y)                 32 bit only
;                     06
;    returns nothing                     (draws a horizontal textured line)
;#############################################################################
;PUBLIC SVGAhlinetextureNL
SVGAhlinetextureNL  proc    NEAR;BASIC
        push bp
        mov bp,sp

        lfs si,segoff

        mov bx,word ptr [Fix16LU+2] ;[bp+12]  ;Lu
        mov cx,word ptr [Fix16RU+2] ;[bp+10]  ;Ru
        mov Lu,bx
        mov Ru,cx
        mov bx,word ptr [Fix16LV+2] ;[bp+08]  ;Lv
        mov cx,word ptr [Fix16RV+2] ;[bp+06]  ;Rv
        mov Lv,bx
        mov Rv,cx
        mov bx,word ptr [Fix16LI+2] ;[bp+16]  ;X1
        mov cx,word ptr [Fix16RI+2] ;[bp+14]  ;X2
        mov Li,bx
        mov Ri,cx
        mov bx,word ptr [Fix16LX+2] ;[bp+16]  ;X1
        mov cx,word ptr [Fix16RX+2] ;[bp+14]  ;X2
        mov X1,bx
        mov X2,cx

        cmp bx,cx
        jl textNLlessok3312
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

        mov ax,Li
        xchg ax,Ri
        mov Li,ax 

textNLlessok3312:

        cmp cx,X2VP     ;clip right X 
        jl @F
        mov cx,X2VP
        dec cx
@@:

        mov temp2,0     ;

        cmp bx,X1VP
        jge @F
        sub bx,X1VP
        neg bx          ;
        mov temp2,bx    ;clip left X 
        mov bx,X1VP
@@:

        cmp cx,X1VP
        jl textNLdoneline331

        mov dx,cx
        sub dx,bx
        inc dx
        mov temp1,dx              ;temp1 = # of pixels 


        mov ud,0
        mov vd,0
        mov id,0

        mov ax,X2
        sub ax,X1       ;ax=X2 - X1
        jz textNLxzero1   ;avoid divide by zero
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

        mov ax,Ri
        sub ax,Li       ;ax=Ri - Li
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov id,eax
textNLxzero1:

        mov ax,[bp+06]       ;Y

        cmp bx,X2VP;XResolution
        jge textNLdoneline331
        cmp ax,Y1VP;YResolution
        jl textNLdoneline331
        cmp ax,Y2VP;YResolution
        jge textNLdoneline331
        
        add ax,ActivePageY
        ;add bx,ActivePageX
        mul BytesPerScanLine

        
        mov temp3,bx
        mov cl,XshiftFactor
        shl bx,cl
        .if BitsPerPixel == 24
             add bx,temp3
        .endif

        add ax,bx
        adc dx,0
        mov di,ax

        ;.if Globalbank != dx
           push ecx
           push edx
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
           pop edx
           pop ecx
        ;.endif
              
        mov ax,Lv
        shl eax,16
        mov V,eax

        mov cx,Lu
        shl ecx,16
        mov U,ecx

        mov ax,Li
        shl eax,16
        mov I,eax

textNLclip1:       ;clip left
        cmp temp2,0        
        jz Notextclip1NL
        mov eax,vd
        add V,eax
        mov ebx,ud
        add U,ebx
        mov eax,id
        add I,eax
        dec temp2
        jmp textNLclip1
Notextclip1NL:


        mov bp,temp1

        mov cx,bp
        shl cx,2
        add cx,di
        jnc textNL_pixel_loop_nobankchange1

textNL_pixel_loop:
        mov bx,word ptr [U+02] ;texture X
        mov ax,word ptr [V+02] ;texture Y

        .if textwrapOnOff == 0
          cmp bx,TextureX
          ja NLNodraw
          cmp ax,TextureY
          ja NLNodraw
        .else
          and bx,textureX
          and ax,textureY
        .endif

        mov cl,textureBitSize
        shl ax,cl
        or ax,bx

        mov si,OffsetDATA

        ;.if BitsPerPixel != 8
        ;  mov temp3,ax
        ;  mov cl,XshiftFactor
        ;  shl ax,cl
        ;.endif

          shl ax,2

        ;.if BitsPerPixel == 24
        ;   add ax,temp3
        ;.endif
        add si,ax
        xor eax,eax

        ;mov cl,BitsPerPixel

        ;.if cl == 8
        ;  mov al,fs:[si]
        ;.elseif (cl == 15) || (cl == 16)
        ;  mov ax,fs:[si]
        ;.elseif (cl == 24) || (cl == 32)
          mov eax,fs:[si]
          and eax,0ffffffh
        ;.endif

        cmp MaskColor,0
        jl  NLfilterOff211111
        cmp MaskColor,eax
        jz  NLFilerOut211111
NLFilterOff211111:

        ;.if cl == 8
        ;.elseif cl == 16
        ;.elseif cl == 24
        ;.elseif cl == 32
           mov cl,byte ptr [I+2]
           mov ch,al
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov al,ch

           mov ch,ah
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov ah,ch

           ror eax,8
           mov ch,ah
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov ah,ch
           rol eax,8
           mov es:[di],eax
        ;.endif

NLFilerOut211111:
NLNodraw:

        mov eax,vd
        mov ecx,ud
        add V,eax
        add U,ecx
        mov eax,id
        add I,eax

        add di,BytesPP
        jae @F
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
@@:
        dec bp
        jnz textNL_pixel_loop

textNLdoneline331:
        pop bp
        retn 2

;****************************************32bit (no bank)
textNL_pixel_loop_nobankchange1:
        xor edx,edx
        mov dx,OffsetDATA
textNL_pixel_loop_nobankchange:
        xor eax,eax
        mov bx,word ptr [U+02] ;texture X
        mov ax,word ptr [V+02] ;texture Y

;        .if textwrapOnOff == 0
;          cmp bx,TextureX
;          ja NLNodraw_nobankchange
;          cmp ax,TextureY
;          ja NLNodraw_nobankchange
;        .else
;          and bx,textureX
;          and ax,textureY
;        .endif

        mov cl,textureBitSize
        shl ax,cl
        or ax,bx

        lea esi,[eax*4+edx]

        mov eax,fs:[si]
;        and eax,0ffffffh

;        cmp MaskColor,0
;        jl  NLfilterOff211111_nobankchange
;        cmp MaskColor,eax
;        jz  NLFilerOut211111_nobankchange
;NLFilterOff211111_nobankchange:

           ;mov cl,byte ptr [I+2]
           ;mov ch,cl
           ;shl ecx,8
           ;mov cl,ch
           ;movd MM0,eax
           ;movd MM1,ecx
           ;psubusb MM0,MM1
           ;movd es:[di],MM0
           mov cl,byte ptr [I+2]
           mov ch,al
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov al,ch

           mov ch,ah
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov ah,ch

           ror eax,8
           mov ch,ah
           sub ch,cl
           jnc @F
             mov ch,0
           @@:
           mov ah,ch
           rol eax,8

           mov es:[di],eax

NLFilerOut211111_nobankchange:
NLNodraw_nobankchange:

        mov eax,vd
        mov ecx,ud
        add V,eax
        add U,ecx
        mov eax,id
        add I,eax

        add di,4
        dec bp
        jnz textNL_pixel_loop_nobankchange
;        emms

        pop bp
        retn 2
SVGAhlinetextureNL endp

;#############################################################################
;SVGAtritextNL (X1, Y1, X2, Y2, X3, Y3, U1, V1, U2, V2, U3, V3, I1, I2, I3, Offset, Segment)
;               38  36  34  32  30  28  26  24  22  20  18  16  14  12  10  08      06
;    returns nothing                     (draws a shadowed textured triangle)
;#############################################################################
PUBLIC SVGAtritextNL
SVGAtritextNL  proc    BASIC
        push bp
        mov bp,sp
        pushad

        mov ax,VideoSegment
        mov es,ax
        
        mov eax,[bp+06]
        ror eax,16
        mov SegOff,eax

        lfs si,segoff

        mov ax,fs:[si+2]
        mov TextureY,ax
        mov ax,fs:[si]
        mov TextureX,ax
        add si,4
        mov OffsetDATA,si

        mov textureBitSize,0
        mov cl,8
@@:
        shr ax,1
        adc textureBitSize,0
        dec cl
        jnz @B

        mov ax,[bp+26] ;U1
        mov U1,ax
        mov bx,[bp+24] ;V1
        mov V1,bx
        mov ax,[bp+14] ;I1
        mov I1,ax

        mov bx,[bp+22] ;U2
        mov U2,bx
        mov ax,[bp+20] ;V2
        mov V2,ax
        mov bx,[bp+12] ;I2
        mov I2,bx

        mov ax,[bp+18] ;U3
        mov U3,ax
        mov bx,[bp+16] ;V3
        mov V3,bx
        mov ax,[bp+10] ;I3
        mov I3,ax


        mov ax,[bp+38] ;X1
        mov bx,[bp+36] ;Y1
        mov cx,[bp+34] ;X2
        mov dx,[bp+32] ;Y2
        mov si,[bp+30] ;X3
        mov di,[bp+28] ;Y3

        cmp bx,dx
        jle NoSwap119nl
        xchg bx,dx    
        xchg ax,cx    
        mov bp,u1
        xchg bp,u2
        mov u1,bp
        mov bp,v1
        xchg bp,v2
        mov v1,bp
        mov bp,I1
        xchg bp,I2
        mov I1,bp
NoSwap119nl:
        cmp bx,di
        jle NoSwap129nl
        xchg bx,di    
        xchg ax,si
        mov bp,u1
        xchg bp,u3
        mov u1,bp
        mov bp,v1
        xchg bp,v3
        mov v1,bp
        mov bp,I1
        xchg bp,I3
        mov I1,bp
NoSwap129nl:
        cmp dx,di
        jle NoSwap139nl
        xchg dx,di    
        xchg cx,si
        mov bp,u2
        xchg bp,u3
        mov u2,bp
        mov bp,v2
        xchg bp,v3
        mov v2,bp
        mov bp,I2
        xchg bp,I3
        mov I2,bp
NoSwap139nl:
        mov X1,ax
        mov Y1,bx
        mov X2,cx
        mov Y2,dx
        mov X3,si
        mov Y3,di


        mov d1,0
        mov ud1,0
        mov vd1,0
        mov id1,0

        mov ax,Y2
        sub ax,Y1       ;ax=Y2 - Y1
        jz textxzero19nl  ;avoid divide by zero
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

        mov ax,I2
        sub ax,I1       ;ax=I2 - I1
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov id1,eax
textxzero19nl:
        
        mov d2,0
        mov ud2,0
        mov vd2,0
        mov id2,0

        mov ax,Y3
        sub ax,Y2       ;ax=Y3 - Y2
        jz textxzero29nl  ;avoid divide by zero
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

        mov ax,I3
        sub ax,I2       ;ax=V3 - V2
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov id2,eax
textxzero29nl:

        mov d3,0
        mov ud3,0
        mov vd3,0
        mov id3,0

        mov ax,Y1
        sub ax,Y3       ;ax=Y1 - Y3
        jz textxzero39nl  ;avoid divide by zero
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

        mov ax,I1
        sub ax,I3       ;ax=V1 - V3
        shl eax,16      ;eax=eax*10000h
        cdq             ;eax->edx:eax 
        idiv ecx        ;edx:eax \ ecx 
        mov id3,eax
textxzero39nl:


        mov bx,X2
        mov temp4,bx

        mov bx,X1
        shl ebx,16     ;   ebx = X1 * 10000h
        mov edx,ebx    ;   edx = X1 * 10000h
        mov Fix16LX,ebx
        mov Fix16RX,ebx

        mov ax,U1
        shl eax,16     ;   eax = U1 * 10000h
        mov ecx,eax    ;   ecx = U1 * 10000h
        mov Fix16LU,eax
        mov Fix16RU,eax

        mov di,V1
        shl edi,16     ;   edi = V1 * 10000h
        mov ebp,edi    ;   ebp = V1 * 10000h
        mov Fix16LV,edi
        mov Fix16RV,edi

        mov ax,I1
        shl eax,16     
        mov Fix16LI,eax   ;  LI= I1 * 10000h
        mov Fix16RI,eax   ;  RI= I1 * 10000h

        mov si,Y1

        cmp si,Y2
        jge  skipfistTloop1nl

Textureloop1nl:
        push si        ;*

        push si        ;Y
        call SVGAhlinetextureNL
        pop si

        mov eax,d1
        mov ecx,d3
        add Fix16LX,eax
        add Fix16RX,ecx
        mov eax,ud1
        mov ecx,ud3
        add Fix16LU,eax
        add Fix16RU,ecx
        mov eax,vd1
        mov ecx,vd3
        add Fix16LV,eax
        add Fix16RV,ecx
        mov eax,id1
        mov ecx,id3
        add Fix16LI,eax
        add Fix16RI,ecx

        inc si
        cmp si,Y2
        jl Textureloop1nl

skipfistTloop1nl:

        cmp si,Y3
        jg skipSecTloop1nl

      cmp si, Y3  ;*
      jge @F
        push ebx
        mov ebx,d2
        mov d1,ebx
        mov ebx,ud2
        mov ud1,ebx
        mov ebx,vd2
        mov vd1,ebx
        mov ebx,id2
        mov id1,ebx

        mov bx,Y3
        mov Y2,bx
        pop ebx

        mov bx,temp4   ;bx=X2
        shl ebx,16     ;ebx = X2 * 10000h
        mov Fix16LX,ebx

        mov ax,U2
        shl eax,16     ;eax = U2 * 10000h
        mov Fix16LU,eax

        mov di,V2
        shl edi,16     ;edi = V2 * 10000h
        mov Fix16LV,edi

        mov ax,I2
        shl eax,16     ;LI = I2 * 10000h
        mov Fix16LI,eax

        jmp Textureloop1nl  ;reenter the loop and draw the lower part of the 
                          ;triangle
@@:

skipSecTloop1nl:
        popad
        pop bp
        retf 34
SVGAtritextNL endp


END

