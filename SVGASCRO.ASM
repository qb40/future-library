;#############################################################################
;
;                SVGA/Scrolling routines made by Future Software
;                            for BASIC programming 
;
;#############################################################################

.model medium
.stack 10h
.386


.data
EXTRN XResolution:word
EXTRN YResolution:word
EXTRN BytesPerScanLine:word
EXTRN BytesPSL:word
EXTRN XshiftFactor:byte
EXTRN ScrollX:word
EXTRN ScrollY:word

EXTRN ActivePage:word
EXTRN ScrollLockInfo:dword    ;bit=1 locked,bit=0 unlocked (32 pages only)
EXTRN ViewPageX:word
EXTRN ViewPageY:word

EXTRN ORIXRes:word
EXTRN ORIYRes:word
EXTRN NumberOfImagePages:byte

EXTRN VideoFrameSizeX:word
EXTRN VideoFrameSizeY:word

EXTRN X1VP:word
EXTRN Y1VP:word
EXTRN X2VP:word
EXTRN Y2VP:word

X1               dw  0
Y1               dw  0

.code

;#############################################################################
;SVGAscroll (Xpixels, Ypixels)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAscroll
SVGAscroll proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx

        mov ax,[bp+08]
        mov ScrollX,ax
        cmp ScrollX,0
        jg @F
        mov ScrollX,0
@@:
        mov ax,[bp+06]
        mov ScrollY,ax
        cmp ScrollY,0
        jg @F
        mov ScrollY,0
@@:


        mov cx,ActivePage
        mov ebx,1
        shl ebx,cl

        mov eax,ebx
        and eax,ScrollLockInfo
        cmp ebx,eax                 ;is the page locked from scrolling
        jz @F

        mov ax,4f07h
        xor bx,bx
        mov cx,ScrollX
        add cx,ViewpageX 
        mov dx,ScrollY
        add dx,ViewpageY 
        int 10h

@@:
        pop ebx
        pop eax
        pop bp
        retf 4
SVGAscroll endp

;#############################################################################
;SVGAscrollLR (pixels)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAscrollLR
SVGAscrollLR proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx

        mov ax,[bp+06]
        add ScrollX,ax
        cmp ScrollX,0
        jg @F
        mov ScrollX,0
@@:

        mov cx,ActivePage
        mov ebx,1
        shl ebx,cl

        mov eax,ebx
        and eax,ScrollLockInfo
        cmp ebx,eax                 ;is the page locked from scrolling
        jz @F

        mov ax,4f07h
        xor bx,bx
        mov cx,ScrollX
        add cx,ViewpageX 
        mov dx,ScrollY
        add dx,ViewpageY 
        int 10h
@@:
        pop ebx
        pop eax
        pop bp
        retf 2
SVGAscrollLR endp


;#############################################################################
;SVGAscrollUD (pixels)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAscrollUD
SVGAscrollUD proc    BASIC
        push bp
        mov bp,sp
        push eax
        push ebx

        mov ax,[bp+06]
        add ScrollY,ax
        cmp ScrollY,0
        jg @F
        mov ScrollY,0
@@:

        mov cx,ActivePage
        mov ebx,1
        shl ebx,cl
        mov eax,ebx
        and eax,ScrollLockInfo
        cmp ebx,eax                 ;is the page locked from scrolling
        jz @F

        mov ax,4f07h
        xor bx,bx
        mov cx,ScrollX
        add cx,ViewpageX 
        mov dx,ScrollY
        add dx,ViewpageY 
        int 10h

@@:
        pop ebx
        pop eax
        pop bp
        retf 2
SVGAscrollUD endp

;#############################################################################
;SVGALockpage (page)
;
;  returns nothing
;#############################################################################
PUBLIC SVGALockpage
SVGALockpage proc    BASIC
        push bp
        mov bp,sp
        push eax

        mov cx,[bp+06]
        mov eax,1
        shl eax,cl
        or ScrollLockInfo,eax

        pop eax
        pop bp
        retf 2
SVGALockpage endp

;#############################################################################
;SVGAUnLockpage (page)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAUnLockpage
SVGAUnLockpage proc    BASIC
        push bp
        mov bp,sp
        push eax

        mov cx,[bp+06]
        mov eax,0fffffffeh
        rol eax,cl
        and ScrollLockInfo,eax

        pop eax
        pop bp
        retf 2
SVGAUnLockpage endp

;#############################################################################
;SVGAframesize (X, Y)
;
;  returns nothing
;#############################################################################
PUBLIC SVGAframesize
SVGAframesize proc    BASIC
        push bp
        mov bp,sp

        mov ax,[bp+06]
        mov Y1,ax
        mov ax,[bp+08]
        mov X1,ax

        mov ax,XResolution
        cmp X1,ax

        jz NoXchange
        mov ax,4f06h
        xor bx,bx
        mov cx,X1
        int 10h

        mov XResolution,cx
        mov bx,cx
        mov cl,XshiftFactor
        shl bx,cl
        mov BytesPSL,bx
        mov BytesPerScanLine,bx
NoXchange:

        mov ax,4f06h        ;now get max y res.
        mov bx,1
        int 10h

        mov ax,YResolution
        cmp Y1,ax
        jz NoYchange

        mov ax,Y1
        mov YResolution,ax

        cmp ax,oriYres
        jg @F
        mov bx,oriYres
        mov YResolution,bx
@@:
        cmp ax,dx           ;dx=max y res
        jle @F
        mov YResolution,dx
@@:
NoYchange:
                                 
        mov ax,dx             ;recal. number of pages.
        xor dx,dx
        div YResolution
        dec ax
        cmp ax,0
        jge PagesOk
        xor ax,ax
PagesOk:
        mov NumberOfImagePages,al

        mov ax,XResolution
        mov VideoFrameSizeX,ax
        mov X2VP,ax
        mov ax,YResolution
        mov VideoFrameSizeY,ax
        mov Y2VP,ax


        mov ax,7                      ;set new mouse range
        mov cx,0
        mov dx,XResolution
        int 33h

        mov ax,8
        mov cx,0
        mov dx,YResolution
        int 33h

skipframesize:
        pop bp
        retf 4
SVGAframesize endp


END
