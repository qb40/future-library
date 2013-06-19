;#############################################################################
;
;                  Fontload routines made by Future Software
;                          for BASIC programming
;
;#############################################################################
.model medium
.386
.stack 10h

EXTRN FontSeg:word
EXTRN FontOff:word
EXTERN FontWidth:word
EXTERN Fontheight:word

PUBLIC UserFonts

.FARDATA?

UserFonts           db 4100 dup(0)

.code

;#############################################################################
;SVGAloadfont (filehandle)
;             
;    returns nothing            
;#############################################################################
PUBLIC SVGAloadfont
SVGAloadfont  proc    BASIC
        push bp
        mov bp,sp
        push ds
        push es


        push ds
        mov dx,Offset UserFonts
        mov ax,@FARDATA?
        mov ds,ax
        mov ax,3f00h
        mov bx,[bp+06]
        mov cx,4100
        int 21h
        pop ds


        mov ax,@FARDATA?
        mov es,ax
        mov si,Offset UserFonts
        mov ax,es:[si]
        mov FontWidth,ax
        add si,2
        mov ax,es:[si]
        mov Fontheight,ax
        add si,2

        mov FontSeg,es
        mov FontOff,si

        pop es
        pop ds
        pop bp
        retf 4
SVGAloadfont endp

END
