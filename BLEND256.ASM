;#############################################################################
;
;                 Blender routines made by Future Software
;                          for BASIC programming
;
;#############################################################################
.model medium
.386
.stack 10h

EXTRN BMapStatus:word
EXTRN BMapSEG:word
EXTRN BMapOFF:word

PUBLIC BlenderMap

.FARDATA?

BlenderMap   db 65535 dup (1)              ;blender map 256*256 intries

.code

;#############################################################################
;SetBMapColor (ForegroundColor, BackroundColor, OutColor)
;
;  
;#############################################################################
PUBLIC SetBMapColor
SetBMapColor proc    BASIC
        push bp
        mov bp,sp

        mov ax,@FARDATA?;SEG BlenderMap
        mov BMapSEG,ax
        mov ax,offset BlenderMap
        mov BMapOFF,ax

        mov ax,@FARDATA?;SEG BlenderMap
        mov es,ax
        mov ax,offset BlenderMap
        mov di,ax

        mov al,[bp+06]
        mov bl,[bp+08]
        mov bh,[bp+10]

        mov es:[di+bx],al
        ;mov es:[bx],al

        pop bp
        retf 6
SetBMapColor endp

END
