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

%macro print 3
    mov dword [eaz], eax
    mov dword [ebz], ebx
    mov dword [ecz], ecx
    mov dword [edz], edx
    
    mov dword [k], 0
    
    forPrint%3:
        mov ecx, [k]
        cmp ecx, %2
        je endPrint%3
        
        cmp byte [%1+ecx], 0
        jge greaterZero%3
        
        mov byte [printV], '-'
        mov eax, 4
        mov ebx, 1
        mov ecx, printV
        mov edx, 1
        int 80h
        
        mov ecx, [k]
        
        mov byte al, 0
        sub al, [%1+ecx]
        mov [%1+ecx], al
        
        greaterZero%3:
            mov al, [%1+ecx]
            mov [printV], al
        
        mov eax, 4
        mov ebx, 1
        mov ecx, printV
        mov edx, 1
        int 80h
        
        mov byte [printV], ' '
        
        mov eax, 4
        mov ebx, 1
        mov ecx, printV
        mov edx, 1
        int 80h
    
        inc dword [k]
        jmp forPrint%3
    endPrint%3:
    
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
    printV:    db    0
    k:         dd    0

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
        ;print teste, 5
        ;print newLine,1
        ;print array,[lenA],1
        ;print newLine,1
        
        
        mov ecx, [began]
        mov [i], ecx
        ;i é a primeira posição
        
        mov dword eax, 0
        add eax, ecx
        
        
        mov ecx, [end]
        add eax, ecx
        
        sub dword ecx, 1
        mov [j], ecx
        ;j = end -1
        
        ;div dword [dois]
        ;pivo agora é a última posição
        mov al, [array+ecx] 
        mov [pivot], al
        ;print pivot, 1
        
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
        
        inc eax
        mov [end], eax
        call quickSort
        
        pop dword [i]
        pop dword [end]
        
        otherIf:
        mov eax, [i]
        cmp eax, [end]
        jge endQuickSort
            
        
        mov [began], eax
        call quickSort
        
        endQuickSort:
        ret
    
    over:
        ;print newLine,1
        print array,[lenA],3
        ;print newLine,1
    
        mov     eax, 1
        int     0x80
