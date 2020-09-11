include \masm32\include\masm32rt.inc
comment * -----------------------------------------------------
          FIX Tool -> Find and Replace New
          ^   ^       ^        ^       ^
          Name : FTFRN
          Data : 2013-04-20
           Ver : 2.0
            By : Dragon
           Mem : Advantage of fast Find
                 Does not support batch modify
                 build environment requirements masm32v11
                 makeit.bat   compile
                 run_this.bat execute the tool
        ----------------------------------------------------- *
    .data
        fname    db "libvlccore.dll",0          ;<-- Input the file name
        fbakname db "libvlccore.dll.bak",0      ;<-- Input the backup file name
        
		;<-- Input Find bytes content
        findData db "vlc-record-%Y-%m-%d-%Hh%Mm%Ss-$ N-$ p",0        
        findLen  dd 37                   ;<-- Input length
        
		;<-- Input replacement bytes content
		;------------         1         2         3       ----
		;------------1234567890123456789012345678901234567----
        fixData  db "%Y%m%d-%H%M%S",
		            0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0
        fixLen   dd 37                   ;<-- Input length
        findPOS  dd 0
    .code

start:
        call main
        exit

main proc
        call openGPCore
        ret
main endp

openGPCore proc
        LOCAL hFile     :DWORD
        LOCAL hBakFile  :DWORD
        LOCAL dSize     :DWORD
        LOCAL hMem      :DWORD
        .if rv(exist,offset fname) != 0
                mov hFile, fopen(offset fname)
        .else
                print "not find "
                print offset fname
                ret
        .endif
        mov dSize, fseek(hFile,0,FILE_END)
        mov hMem, alloc(dSize)

        mov eax , fseek(hFile,0,FILE_BEGIN)
        mov eax , fread(hFile,hMem,dSize)
        mov     dword ptr [findPOS] , 0

        ;----find----
        mov     ecx, dSize
        push    ecx
        mov     edx, hMem
        push    edx 
        mov     eax, dword ptr [findLen] 
        push    eax
        mov     ecx, offset findData
        push    ecx
        ;pat patlen textt texttlen
        call qs
        ;printf  ("%d",dword ptr [findPOS])
        
        .if dword ptr [findPOS] == 0
                print "Not find "
                print offset findData,13,10
        .else
                ;----backup file----
                mov hBakFile, fcreate( offset fbakname )
                mov eax , fwrite( hBakFile, hMem, dSize)
                fclose hBakFile

                ;----fix----
                mov eax , fseek(hFile,dword ptr [findPOS],FILE_BEGIN)
                mov eax , fwrite( hFile, offset fixData, dword ptr [fixLen])
                print "Fix "
                print offset fname
                print " success.",13,10
        .endif

        fclose hFile
        free hMem
        ret
openGPCore endp

OUTPUT proc
        mov     eax,dword ptr [esp+4]
        mov     dword ptr [findPOS] , eax
        ret
OUTPUT endp

preQsBc proc
        push    ebp
        mov     ebp,dword ptr [esp+10h]
        push    esi
        mov     esi,dword ptr [esp+10h]
        push    edi
        mov     ecx,100h
        lea     eax,[esi+1]
        mov     edi,ebp
        rep stos dword ptr es:[edi]
        xor     eax,eax
        test    esi,esi
        jle     preQsBc1

        mov     edi,dword ptr [esp+10h]
        mov     ecx,esi
preQsBc2:
        xor     edx,edx
        mov     dl,byte ptr [eax+edi]
        inc     eax
        mov     dword ptr [ebp+edx*4],ecx
        dec     ecx
        cmp     eax,esi
        jl      preQsBc2
preQsBc1:
        pop     edi
        pop     esi
        pop     ebp
        ret

preQsBc endp

qs proc
        sub     esp,404h
        mov     ecx,dword ptr [esp+408h]
        push    ebx
        push    ebp
        mov     ebp,dword ptr [esp+414h]
        lea     eax,[esp+0Ch]
        push    eax
        push    ebp
        push    ecx
        call    preQsBc
        mov     eax,dword ptr [esp+428h]
        add     esp,0Ch
        xor     ebx,ebx
        sub     eax,ebp
        mov     dword ptr [esp+8],eax
        js      qs1

        mov     edx,dword ptr [esp+418h]
        push    esi
        push    edi
qs3:
        mov     esi,dword ptr [esp+418h]
        mov     ecx,ebp
        lea     edi,[ebx+edx]
        xor     eax,eax
        repe cmps byte ptr [esi],byte ptr es:[edi]
        jne     qs2

        push    ebx
        call    OUTPUT
        mov     edx,dword ptr [esp+424h]
        add     esp,4
qs2:
        lea     eax,[edx+ebp]
        xor     ecx,ecx
        mov     cl,byte ptr [eax+ebx]
        mov     eax,dword ptr [esp+10h]
        add     ebx,dword ptr [esp+ecx*4+14h]
        cmp     ebx,eax
        jle     qs3

        pop     edi
        pop     esi
qs1:
        pop     ebp
        pop     ebx
        add     esp,404h
        ret
qs endp
end start