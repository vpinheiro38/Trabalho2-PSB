; ------------------ PUSH STRING ----------------------

%macro pushar 4

mov dword [j], 0

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

mov eax, %2
cmp edx, 1
jne %3

inc eax

%3:
    cmp dword [j], eax
    je %4
    
    mov ebx, dword [j]
    push word [%1+ebx]
    add word [j], 2
    jmp %3
    
%4:
    
%endmacro

; ------------------ POP STRING ----------------------

%macro popar 4

mov eax, %2
mov ebx, 2
mov edx, 0
mov dword [j], eax

div ebx

mov eax, %2
cmp edx, 1

jne %3

inc dword [j]
%3:
    cmp dword [j], 0
    je %4
    
    sub word [j], 2
    mov ebx, [j]
    pop word [%1+ebx]
    
    jmp %3
    
%4:
    
%endmacro

; ------------------ PRINT STRING ----------------------

%macro print 2
    mov dword [eaz], eax
    mov dword [ebz], ebx
    mov dword [ecz], ecx
    mov dword [edz], edx
    
    mov eax,4
    mov ebx,1
    mov ecx,%1
    mov edx,%2
    int 80h
    
    mov eax, [eaz]
    mov ebx, [ebz]
    mov ecx, [ecz]
    mov edx, [edz]
%endmacro

; ------------------ SCAN STRING ----------------------

%macro scan 2
    mov dword [eaz], eax
    mov dword [ebz], ebx
    mov dword [ecz], ecx
    mov dword [edz], edx

    mov eax,3
    mov ebx,0
    mov ecx,%1
    mov edx,%2
    int 80h
    
    mov eax, [eaz]
    mov ebx, [ebz]
    mov ecx, [ecz]
    mov edx, [edz]
%endmacro

; -----------------------------------------------------

%macro regGetValue 3 ; regGetValue eax, ebx (index)
    dec dword %2
    cmp dword [array+%2], '-'
    jne noNeg%3
    
    inc dword %2
    mov dword %1, 0
    sub %1, [array+%2]
    ;add dword %1, '0'
    jmp endGetValue%3
    
    noNeg%3:
        inc dword %2
        mov %1, [array+%2]
        ;sub dword %1, '0'
    
    endGetValue%3:
%endmacro

%macro memGetValue 3 ; memGetValue [pivot], eax (index)
    dec dword %2
    cmp dword [array+%2], '-'
    jne noNeg%3
    
    mov dword ebx, 0
    inc dword %2
    sub ebx, [array+%2]
    ;add dword ebx, '0'
    mov %1, ebx
    jmp endGetValue%3
    
    noNeg%3:
        inc dword %2
        mov ebx, [array+%2]
        ;sub dword ebx, '0'
        mov %1, ebx
    
    endGetValue%3:
%endmacro

%macro memCmpValue 3
    dec dword %2
    cmp dword [array+%2], '-'
    jne noNeg%3
    
    inc dword %2
    mov dword ebx, 0
    sub ebx, [array+%2]
    ;add dword ebx, '0'
    jmp endGetValue%3
    
    noNeg%3:
        inc dword %2
        mov ebx, [array+%2]
        ;sub dword ebx, '0'
    
    endGetValue%3:
    
    cmp ebx, %1
%endmacro

section .data
    len:       dd    100
    lenA:      dd    0
    neg:       dd    0
    began:     dd    0
    end:       dd    0
    i:         dd    0
    j:         dd    0
    pivot:     dd    0
    dois       dd    2
    eaz:       dd    0
    ebz:       dd    0
    ecz:       dd    0
    edz:       dd    0
    teste:     db    'Teste'
    testeA:    db    'A'
    testeB:    db    'B'
    testeC:    db    'C'
    newLine:   db    10
    str:       db    0

section .bss
    ent:      resb    100
    array:    resb    200
    arrayAux: resb    200
    
section .text
    global _start

_start:
    scan ent,len
    
    mov ecx, 0
    mov dword [lenA], 0
    
    formatArray:
        cmp ecx,[len]
        je endF
        
        cmp byte [ent+ecx], 10
        je endF
        
        cmp byte [ent+ecx], ' '
        je final
        
        cmp byte [ent+ecx], '-'
        jne cmpNumber
        
        mov dword [neg], 1
        jmp final
        
        cmpNumber:
            cmp dword [neg], 1
            je continue
            mov ebx, [lenA]
            mov eax, [ent+ecx]
            ;sub eax, 48
            mov [array+ebx], eax
            jmp finalCmpNumber
            
            continue:
            mov ebx, [lenA]
            mov eax, [ent+ecx]
            ;sub eax, 48
            mov dword [array+ebx], 0
            sub [array+ebx], eax
        
        finalCmpNumber:
            inc dword [lenA]
            mov dword [neg], 0
        
        final:
            inc ecx
            jmp formatArray
    endF:
    
    mov eax,[lenA]
    mov dword [began], 0
    mov dword [end], eax

    call quickSort
    
    jmp over

    quickSort:
        print teste, 5
        print newLine,1
        print array,[lenA]
        print newLine,1
        
        mov ecx, [began]
        mov [i], ecx
        
        mov dword eax, 0
        add eax, ecx
        
        mov ecx, [end]
        add eax, ecx
        
        sub dword ecx, 1
        mov [j], ecx
        
        div dword [dois]
        mov al, [array+eax] 
        mov [pivot], al
        
        whileIJ:
            mov ecx, [j]
            cmp [i], ecx
            jg endWhileIJ
            
            while1:
                mov eax, [i]
                
                mov bl, [pivot]
                cmp [array+eax], bl
                jge endWhile1
                
                cmp eax, [end]
                jge endWhile1
                
                inc dword [i]
                
                jmp while1
            endWhile1:
            
            while2:
                mov eax, [j]
                
                mov bl, [pivot]
                cmp [array+eax], bl
                jle endWhile2
                
                cmp eax, [began]
                jle endWhile2
                
                dec dword [j]
                
                jmp while2
            endWhile2:
            
            mov eax, [i]
            mov ebx, [j]
            cmp eax, ebx
            jg finalWhileIJ
            
            mov cl, [array+eax]
            mov ch, [array+ebx]
            mov [array+eax], ch
            mov [array+ebx], cl
            
            inc dword [i]
            dec dword [j]
            
            finalWhileIJ:
                jmp whileIJ
        endWhileIJ:
        
        mov eax, [j]
        cmp eax, [began]
        jle otherIf
        
        push dword [end]
        push dword [i]
                print testeB, 1
                print newLine,1
        
        inc eax
        mov [end], eax
        call quickSort
        
        pop dword [i]
        pop dword [end]
        
        otherIf:
        mov eax, [i]
        cmp eax, [end]
        jge endQuickSort
            
            print testeC, 1
            print newLine,1
        
        mov [began], eax
        call quickSort
        
        endQuickSort:
        ret
    
    over:
        print newLine,1
        print array,[lenA]
        print newLine,1
    
        mov     eax, 1
        int     0x80
