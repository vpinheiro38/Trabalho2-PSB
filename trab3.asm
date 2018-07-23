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
    pivo:      dd    0
    dois       dd    2
    eaz:       dd    0
    ebz:       dd    0
    ecz:       dd    0
    edz:       dd    0
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
    scan ent,len ; LENDO STRING
    
    mov ecx, 0
    mov dword [lenA], 0
    
    ; CONSTROI NOVO ARRAY ONDE CADA NUMERO ENCONTRADO EM ent VAI PARA array, FAZENDO TRATAMENTO
    formatArray:
        cmp ecx,[len] ; VERIFICA SE ecx == len = TAMANHO MÁXIMO DA STRING
        je endF
        
        cmp byte [ent+ecx], 10 ; VERIFICA SE ent[ecx] == '\n'
        je endF
        
        cmp byte [ent+ecx], ' ' ; VERIFICA SE ent[ecx] == ' '
        je final
        
        cmp byte [ent+ecx], '-' ; VERIFICA SE ent[ecx] == '-'
        jne cmpNumber
        
        ; SE FOR, FAZ neg = 1 E PULA PARA PROXIMA ITERAÇÃO DO LOOP
        mov dword [neg], 1
        jmp final
        
        ; SE NÃO FOR, VERIFICA SE neg == 1
        cmpNumber:
            cmp dword [neg], 1
            je continue
            
            ; SE NÃO FOR, COLOCA-SE O VALOR POSITIVO DO NUMERO NO ARRAY
            mov ebx, [lenA]
            mov eax, [ent+ecx]
            mov [array+ebx], eax
            jmp finalCmpNumber
            
            ; SE FOR, COLOCA-SE O VALOR NEGATIVO DO NUMERO NO ARRAY
            continue:
            mov ebx, [lenA]
            mov eax, [ent+ecx]
            mov dword [array+ebx], 0
            sub [array+ebx], eax
        
        finalCmpNumber: ; INCREMENTA lenA E FAZ neg = 0
            inc dword [lenA]
            mov dword [neg], 0
        
        final: ; INCREMENTA ecx E VAI PARA A PRÓXIMA ITERAÇÃO DO LOOP
            inc ecx
            jmp formatArray
            
    endF:
    
    ; FAZ began = 0 E end = lenA
    mov eax,[lenA]
    mov dword [began], 0
    mov dword [end], eax
    
    ; CHAMA A RECURSÃO PARA ORDENAR array
    call quickSort
    
    ; APÓS VOLTAR DA RECURSÃO, PULA PARA O FINAL DO PROGRAMA
    jmp over

    quickSort:
        
        ; FAZ i = began, j = end-1 e pivo = array[j]
        mov ecx, [began]
        mov [i], ecx

        mov dword eax, 0
        add eax, ecx

        mov ecx, [end]
        add eax, ecx
        
        sub dword ecx, 1
        mov [j], ecx
       
        mov al, [array+ecx] 
        mov [pivo], al
        
        
        whileIJ: ; ENQUANTO i <= j
            mov ecx, [j]
            cmp [i], ecx
            jg endWhileIJ
            
            ; ENQUANTO array[i] < pivo E i < end, FAZ i = i+1
            while1:
                mov eax, [i]
                
                mov bl, [pivo]
                cmp [array+eax], bl
                jge endWhile1
                
                cmp eax, [end]
                jge endWhile1
                
                inc dword [i]
                
                jmp while1
            endWhile1:
            
            ;ENQUANTO array[j] > pivo E j > began, FAZ j = j-1
            while2:
                mov eax, [j]
                
                mov bl, [pivo]
                cmp [array+eax], bl
                jle endWhile2
                
                cmp eax, [began]
                jle endWhile2
                
                dec dword [j]
                
                jmp while2
            endWhile2:
            
            ; VERIFICA SE i <= j
            mov eax, [i]
            mov ebx, [j]
            cmp eax, ebx
            jg finalWhileIJ
            
            ; SE FOR, FAZ swap(array[i], array[j]), i = i+1 e j = j-1
            mov cl, [array+eax]
            mov ch, [array+ebx]
            mov [array+eax], ch
            mov [array+ebx], cl
            
            inc dword [i]
            dec dword [j]
            
            finalWhileIJ:
                jmp whileIJ
                
        endWhileIJ:
        
        ; VERIFICA SE j > began
        mov eax, [j]
        cmp eax, [began]
        jle otherIf
        
        ; SE FOR, COLOCA end E i NA PILHA, FAZ end = j+1 e CHAMA A RECURSÃO PARA SUBARRAY [began, j+1]
        push dword [end]
        push dword [i]
        
        inc eax
        mov [end], eax
        call quickSort
        
        ; APÓS VOLTAR DA RECURSÃO, RETIRA i E end DA PILHA E VERIFICA SE i < end
        
        pop dword [i]
        pop dword [end]
        
        otherIf:
        mov eax, [i]
        cmp eax, [end]
        jge endQuickSort
            
        ; SE FOR, FAZ began = j E CHAMA A RECURSÃO PARA SUBARRAY [i, end]
        mov [began], eax
        call quickSort
        
        ; APÓS RETORNAR DA RECURSÃO, VOLTA PARA A ULTIMA CHAMADA
        endQuickSort:
        ret
    
    over:
        ; APÓS A ORDENAÇÃO, EFETUA O PRINT DO ARRAY NA TELA
        print array,[lenA],3
        
        ; ENCERRA O PROGRAMA
        mov eax, 1
        mov ebx, 0
        int 0x80
