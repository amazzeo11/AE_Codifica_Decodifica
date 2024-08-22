
.data
myplaintext: .string "A$$eMblY 21-22"    #parola da cifrare
mycypher: .string "ABCDE"      #ordine dei metodi di cifratura
k:.word -11       #costante cifrario di Cesare
chiave: .string "ALE"  
                
stringa_errore: .string "la stringa e' errata"
separatore: .string "\n"
messaggio_fine: .string "Programma concluso"

.text
    la s0 mycypher
    la s1 myplaintext
    la s4 chiave
    li s5 0x1000057c  #indirizzo stringa aggiuntiva per il metodo c

Stampa_stringa_da_cifrare:
    add a0 s1 zero
    li a7 4
    ecall
    la a0 separatore 
    li a7 4
    ecall

Decisione_metodo:
  
    add s2,s3,s0              #scorro la stringa mycypher per decidere  (s2,s3 perche' non voglio modificre nei metodi il contatore)
    lb t2,0(s2)               #quale metodo di cifratura utilizzare
    beq t2 zero Decrittografia            
    addi s3,s3,1
    li t3 65                  #prima di controllare il carattere della stringa carico in t3
    beq t2 t3 Metodo_A        #il codice ascii delle lettere corrispondenti ai metodi, faccio il confronto e rimando al metodo richiesto
    li t3 66
    beq t2 t3 Metodo_B
    li t3 67
    beq t2 t3 Metodo_C
    li t3 68
    beq t2 t3 Metodo_D
    li t3 69
    beq t2 t3 Metodo_E
    j errore

Decrittografia:
#scelta del metodo di decodifica 
    addi s3,s3,-1
    add s2,s3,s0              #scorro la stringa mycypher al contrario per decidere 
    lb t2,0(s2)               #quale metodo di cifratura utilizzare
    blt s3 zero fine               
   
    li t3 65                  #prima di controllare il carattere della stringa carico in t3
    beq t2 t3 Decrittografia_A        #il codice ascii delle lettere corrispondenti ai metodi di decodifica e rimando a quello richiesto
     li t3 66
    beq t2 t3 Decrittografia_B
    li t3 67
    beq t2 t3 Decrittografia_C
    li t3 68
    beq t2 t3 Decrittografia_D
    li t3 69
    beq t2 t3 Decrittografia_E
 
    
#--------------------  
#METODI DI CIFRATURA:
#--------------------  
    
Metodo_A:
lw a0 k #carico su a0 la costante
add t1,t0,s1    #s1 e' l'indirizzo della stringa da cifrare 
lb t2,0(t1) 
beq t2 zero stampa_cifrato 
addi t0,t0,1
li t3 65
blt t2 t3 Metodo_A  #Se e'un simbolo rimane invariato
#se proseguo il codice ascii del carattere e' maggiore di 65, quindi potrei avere una maiuscola

maiuscola_a:
li t3 90
bgt t2 t3 minuscola_a # se e' maggiore di 90 potrei avere una minuscola, se non salta invece e' una maiuscola

addi t2 t2 -65             #crittografo secondo la regola:65+[(codice_carattere - 65 + k)%26];
add a2 t2 a0
jal modulo_26
addi a2 a2 65
#devo ancora salvare il valore sulla stringa
sb a2 0(t1)
j Metodo_A #passo al carattere successivo della stringa

minuscola_a:
li t3 97
blt t2 t3 Metodo_A    #controllo se si tratta effettivamente di una minuscola o di un numero
li t3 122              #valutando l'intervallo in cui è compreso il codice del c arattere 
bgt t2 t3 Metodo_A    

addi t2 t2 -97 #crittografo secondo la regola:97+[(codice_carattere - 97 + k)%26];
add a2 t2 a0
jal modulo_26
addi a2 a2 97
#devo ancora salvare il valore sulla stringa
sb a2 0(t1)
j Metodo_A #passo al carattere successivo della stringa



Metodo_B:
add t1,t0,s1                #scorro myplaintext
lb t2,0(t1) 
beq t2 zero stampa_cifrato 
addi t0,t0,1 
#scorro la chiave
loop_chiave:  
add t5,t6,s4  
lb a3,0(t5) 
beq a3 zero riazzera_chiave 
addi t6,t6,1

#crittografo secondo la regola codice cifrato= 32 + (codice_carattere + codice_chiave) %96

add a2 t2 a3
jal modulo_96
addi a2 a2 32
 
# salvo il valore cifrato in memoria
sb a2 0(t1)
j Metodo_B
  
 
 
Metodo_C:

add t1,t0,s1                #scorro myplaintext
lb a2,0(t1) 
beq a2 zero stampa_C 
addi t0,t0,1
#visto che la dimensione della stringa varia, al contrario degli altri metodi
#e devo anche marcare i caratteri gia' esaminati, quindi apportando modifiche sulla stringa che comprometterebbero il funzionamento del resto del metodo
#creo un'altra stringa in una zona di memoria in cui anche allungando la stringa non ho problemi di sovrapposizione.  


add t1,t4,s5                #creo e scorro la nuova stringa



li t3 2      #marco il carattere gia' analizzato 
beq a2 t3 Metodo_C   #controllo se e' gia' marcato     
sb a2 0(t1)     #scrivo il carattere sulla nuova stringa che verra' seguito dalle sue occorrenze
addi t4,t4,1

loop:
    add a3,a1,s1                #scorro myplaintext
    lb t2,0(a3) 
    beq t2 zero spazio 
    addi a1,a1,1
    beq t2 a2 salva_posizione
    j loop

salva_posizione:
li t3 2        
sb t3 0(a3)    #marco il carattere sulla stringa iniziale
 li t3 45    #memorizzo ascii di "-"
 add t1 t4 s5    #aggiorno la posizione del puntatore alla stringa
 sb t3 0(t1)    #inserisco il trattino
 addi t4 t4 1    #aggiorno il contatore stringa
 add t1 t4 s5     #ricalcolo il puntatore
 li t3 9
 add a6 a1 zero        #copio il valore di a1 per non sovrascrivere il contatore
 bgt a6 t3 numero_a_piu'_cifre
 addi a5 a1 48
 sb a5 0(t1)    #memorizzo la posizione in cui ho trovato il carattere
 addi t4 t4 1
 j loop
 
 
 numero_a_piu'_cifre:
    beq a6 zero memorizzazione
    jal modulo_10
    addi a5 a5 48    #trasformo la cifra in ascii
    addi sp sp -1
    sb a5 0(sp)     #salvo le cifre del numero in una pila
    li t3 10
    div a6 a6 t3        #dividendo per 10 scorro le varie cifre del numero
    j  numero_a_piu'_cifre

memorizzazione:
   
    lb a6 0(sp)        #avendo già trasformato la cifra in ascii, se trovo uno 0 la pila è finita
    addi sp sp 1
    beq a6 zero loop
    sb a6 0(t1)        #memorizzo le cifre della posizione
    addi t4 t4 1
    add t1 t4 s5

    j memorizzazione
    
    

spazio:
    add t1 t4 s5
    addi t4 t4 1
    li t3 32
    sb t3 0(t1)   #metto uno spazio per separare i caratteri
    li a1 0        #riazero il contatore
    j Metodo_C 
 
 
 
 
Metodo_D:
    
add t1,t0,s1
lb t2,0(t1) 
beq t2 zero stampa_cifrato 
addi t0,t0,1

#eseguo i controlli per capire il tipo del carattere che sto esaminando

maiuscola_d:
    li t3 65
    blt t2 t3 numero_d        #se il carattere ha codice minore di 65 potrebbe essere un numero, quindi lo mando al controllo
    li t3 90
    bgt t2 t3 minuscola_d   #se il codice e' maggiore di 90 potrei avere una minuscola 
#codifica maiuscole
    li t3 65
    sub t4 t2 t3     #calcolo la "distanza" tra la A maiuscola e il carattere in esame
    li t3 122
    sub a2 t3 t4      #applico la distanza sopra calcolata partendo dalla fine delle lettere minuscole
    sb a2 0(t1)        #salvo l'elemento cifrato in memoria
    j Metodo_D


minuscola_d:
    li t3 97
    blt t2 t3 Metodo_D   #se e' minore di 97 e' un simbolo e non faccio nulla, quindi scorro al carattere successivo
    li t3 122
    bgt t2 t3 Metodo_D   #se e' maggiore di 122 e' un simbolo, passo al carattere successivo
#codifica minuscole
    li t3 97
    sub t4 t2 t3    #calcolo la "distanza" tra la a minuscola e il carattere in esame
    li t3 90
    sub a2 t3 t4    #applico la distanza sopra calcolata partendo dalla fine delle lettere maiuscole
   
    sb a2 0(t1)    #salvo l'elemento cifrato in memoria
    j Metodo_D


numero_d:
    li t3 57
    bgt t2 t3 Metodo_D #se e' compreso tra 57 e 65 (esclusi) ho un simbolo e non devo fare niente, quindi passo al carattere successivo
    li t3 48
    blt t2 t3 Metodo_D   #se e' minore di 48 e' un simbolo, altrimenti e' un numero e procedo con la crittografia
 
 #codifica dei numeri
    li t3 57
    sub a2 t3 t2        #Calcolo la differenza tra 9 e il mio numero
    addi a2 a2 48       #Ci riaggiungo 48 per riottenere il codice ascii del numero cifrato
    sb a2 0(t1)        #salvo il numero cifrato
    j Metodo_D

 

Metodo_E: 
    
    jal calcolo_lunghezza_stringa        #calcolo la lunghezza della stringa
     srli t5 a4 1
    add a4 a4 s1                       #calcolo l'indirizzo dell'ultimo carattere della stringa
   
Corpo_metodo_E:
    add t1,t0,s1                          #scorro myplaintext
    lb t2,0(t1)               
    beq t0 t5  stampa_cifrato            
    addi t0,t0,1
    lb t4 0(a4)                #carico in t4 l'ultimo carattere non ancora esaminato
    sb t4 0(t1)                 #salvo nella prima posizione non ancora esaminata il carattere in t4 
    sb t2 0(a4)                #salvo nell'ultima posizione non ancora esaminata il valore in t2
    addi a4 a4 -1            #decremento il puntatore a fine stringa
    j Corpo_metodo_E



#----------------------  
#METODI DI DECIFRATURA:
#---------------------- 

Decrittografia_A: 
 
    add t1,t0,s1        #s1 perche' e' l'indirizzo della stringa da cifrare              
    lb t2,0(t1)               
    beq t2 zero  stampa_decifrato            
    addi t0,t0,1
    li t3 65
    blt t2 t3  Decrittografia_A    #perche' e' un simbolo rimane uguale
                          #se proseguo e' maggiore di 65 quindi potrei avere una maiuscola
   
Decrittografia_maiuscola_a:
    li t3 90
    bgt t2 t3  Decrittografia_minuscola_a     # se e' maggiore di 90 potrei avere una minuscola, se non salta ? una maiuscola
    lw a0 k
    addi t2 t2 65            #decrittografo secondo la regola:65+[(codice_carattere + 65 - k)%26];
    sub a2 t2 a0
    jal modulo_26
    addi a2 a2 65
    #salvo il valore sulla stringa
    sb a2 0(t1)
    j  Decrittografia_A                #passo al carattere successivo della stringa
  
        
    Decrittografia_minuscola_a:
    li t3 97
    blt t2 t3  Decrittografia_A
    li t3 122
    bgt t2 t3  Decrittografia_A
    lw a0 k
    addi t2 t2 -97             #decrittografo secondo la regola:97+[(codice_carattere -97 - k)%26];
    sub a2 t2 a0 
    addi a2 a2 26
    jal modulo_26
    addi a2 a2 97
    #salvo il valore sulla stringa
    sb a2 0(t1)
    j  Decrittografia_A        #passo al carattere successivo della stringa
    


Decrittografia_B:
    add t1,t0,s1                #scorro myplaintext
    lb t2,0(t1) 
    beq t2 zero stampa_decifrato 
    addi t0,t0,1 
    #scorro la chiave
    loop_chiave_decrittografia:  
    add t5,t6,s4  
    lb a3,0(t5) 
    beq a3 zero riazzera_chiave_decri #se arrivo al termine della stringa chiave, riazzero i contatori e riparto
    addi t6,t6,1

    addi a2 t2 -32
    sub a2 a2 a3            #codice decifrato= {[(codice_cifrato-32)-chiave]+96}%96
    addi a2 a2 96
    jal modulo_96
    li t3 32                
    bge a2 t3 fine_decri_B    #se e' un carattere qualsiasi, vado al metodo per il salvataggio
    addi a2 a2 96             #questa addizione viene utilizzata per la gestione delle minuscole
                              #che avendo valore superiore a 96 portano ad eccezioni

fine_decri_B:
    sb a2 0(t1)            #salvo il valore e lo rimando all'inizio del metodo
    j Decrittografia_B




Decrittografia_C:

    add t1,t0,s1        #scorro myplaintext
    lb t2,0(t1) 
    beq t2 zero stampa_decri_C
    addi t0,t0,2        #salto di 2 per oltrepassare il primo "-" 

    add a1 t2 zero      #salvo il primo carattere su cui mi trovo
    loop_cifre:
    add t1,t0,s1           
    lb t2,0(t1)         #mi trovo sulla prima cifra della posizione
    li t3 45
    beq t2 t3 trattino_trovato
    li t3 32
    beq t2 t3 spazio_trovato
    addi t0,t0,1
    addi t2 t2 -48      #lo riporto da ascii a decimale
    li t3 10
    mul t4 t4 t3        #alla prima cifra rimane 0, andando avanti moltiplica per 10
    add t4 t4 t2        #salvo la cifra più a sinistra

    j loop_cifre

trattino_trovato:
    add t5 t4 s5       #calcolo la posizione di memoria del carattere esaminato
    addi t5 t5 -1      #decremento t5 perchè partivo dalla posizione 1
    sb a1 0(t5)        #salvo il carattere nella posizione calcolata
    li t4 0            #riazzero t4
    addi t0 t0 1       #scorro il puntatore della stringa
    j loop_cifre       #lo rimando al loop cifre perchè se trovo un trattino, devo avere un'altra posizione


spazio_trovato:
    add t5 t4 s5      #calcolo la posizione di memoria del carattere esaminato
    addi t5 t5 -1     #decremento t5 perchè partivo dalla posizione 1
    sb a1 0(t5)       #salvo il carattere nella posizione calcolata
    li t4 0           #riazzero t4
    addi t0 t0 1      #aggiorno il puntatore
    j Decrittografia_C #lo rimando all'inizio del metodo per esaminare un nuovo carattere


Decrittografia_D:
#applico lo stesso procedimento della codifica   
     
    add t1,t0,s1
    lb t2,0(t1) 
    beq t2 zero stampa_decifrato 
    addi t0,t0,1

#eseguo i controlli per capire il tipo del carattere che sto esaminando

decri_maiuscola_d:
    li t3 65
    blt t2 t3 decri_numero_d       #se il carattere ha codice minore di 65 potrebbe essere un numero, quindi lo mando al controllo
    li t3 90
    bgt t2 t3 decri_minuscola_d    #se il codice e' maggiore di 90 potrei avere una minuscola 
#decodifica maiuscole
    li t3 65
    sub t4 t2 t3          #calcolo la "distanza" tra la A maiuscola e il carattere in esame
    li t3 122
    sub a2 t3 t4          #applico la distanza sopra calcolata partendo dalla fine delle lettere minuscole
    sb a2 0(t1)           #salvo l'elemento cifrato in memoria
    j Decrittografia_D


decri_minuscola_d:
    li t3 97
    blt t2 t3 Decrittografia_D   #se e' minore di 97 e' un simbolo e non faccio nulla, quindi scorro al carattere successivo
    li t3 122
    bgt t2 t3 Decrittografia_D   #se e' maggiore di 122 e' un simbolo, passo al carattere successivo
#decodifica minuscole
    li t3 97
    sub t4 t2 t3          #calcolo la "distanza" tra la a minuscola e il carattere in esame
    li t3 90
    sub a2 t3 t4          #applico la distanza sopra calcolata partendo dalla fine delle lettere maiuscole
   
    sb a2 0(t1)           #salvo l'elemento cifrato in memoria
    j Decrittografia_D


decri_numero_d:
    li t3 57
    bgt t2 t3 Decrittografia_D   #se e' compreso tra 57 e 65 (esclusi) ho un simbolo e non devo fare niente, quindi passo al carattere successivo
    li t3 48
    blt t2 t3 Decrittografia_D   #se e' minore di 48 e' un simbolo, altrimenti e' un numero e procedo con la crittografia
 
 #decodifica dei numeri
    li t3 57
    sub a2 t3 t2
    addi a2 a2 48     
    sb a2 0(t1)        
    j Decrittografia_D

    


Decrittografia_E:
 #applico lo stesso procedimento della codifica
    jal calcolo_lunghezza_stringa
    srli t5 a4 1
    add a4 a4 s1 
 Corpo_decrittografia_E:
   add t1,t0,s1                      
    lb t2,0(t1)               
    beq t0 t5  stampa_decifrato            
    addi t0,t0,1
    lb t4 0(a4)
    sb t4 0(t1)
    sb t2 0(a4)
    addi a4 a4 -1
    j Corpo_decrittografia_E
 


#-------------------  
#METODI DI SERVIZIO:
#-------------------  
    
modulo_26: 
 li t3 26
 div t4 a2 t3
 mul t4 t4 t3
 sub a2 a2 t4
 bge a2 zero fine_modulo26 
 addi a2 a2 26
 fine_modulo26:
 jr ra
 
modulo_96: 
 li t3 96
 div t4 a2 t3
 mul t4 t4 t3
 sub a2 a2 t4
 bge a2 zero fine_modulo96 
 addi a2 a2 96
 fine_modulo96:
 jr ra
 
modulo_10: 
 li t3 10
 div t5 a6 t3
 mul t5 t5 t3
 sub a5 a6 t5
 bge a5 zero fine_modulo10 
 addi a5 a5 10
 fine_modulo10:
 jr ra
  
 
 
 
riazzera_chiave:
li t6 0
j loop_chiave

riazzera_chiave_decri:
li t6 0
j loop_chiave_decrittografia



 calcolo_lunghezza_stringa:

    add t1,a4,s1                      
    lb t2,0(t1)               
    beq t2 zero  fine_conteggio           
    addi a4,a4,1
    j calcolo_lunghezza_stringa
    fine_conteggio:
    addi a4 a4 -1 
    jr ra


errore:
    la a0 stringa_errore
    li a7 4
    ecall
    la a0 separatore
    li a7 4
    ecall
    j fine
  

#------- 
#STAMPE:
#-------  
    
stampa_cifrato: 
add a0 s1 zero
li a7 4
ecall
la a0 separatore
li a7 4
ecall
li t1 0       #riazzero registri alla fine del metodo per evitare interferenze nell'applicazione dei metodi successivi
li t0 0
li t2 0
li t4 0
li t5 0
li t6 0
li a4 0
j Decisione_metodo
 
 
stampa_decifrato: 
add a0 s1 zero
li a7 4
ecall
la a0 separatore
li a7 4
ecall
li t1 0       #riazzero registri alla fine del metodo per evitare interferenze nell'applicazione dei metodi successivi
li t0 0
li t2 0
li t4 0
li t5 0
li t6 0
li a4 0
j Decrittografia
 
 
 
stampa_C:
add a0 s5 zero
li a7 4
ecall
la a0 separatore
li a7 4
ecall
li t1 0       #riazzero registri alla fine del metodo per evitare interferenze nell'applicazione dei metodi successivi
li t0 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a1 0
li a2 0
li a3 0
li a4 0
add s1 s5 zero        #aggiorno s1 per far riferiento negli altri metodi alla nuova stringa
addi s5 s5 1000        #incremento il valore dell'indirizzo della stringa per evitare sovrapposizioni
j Decisione_metodo
 
 
 
  
stampa_decri_C:
add a0 s5 zero
li a7 4
ecall
la a0 separatore
li a7 4
ecall
li t1 0       #riazzero registri alla fine del metodo per evitare interferenze nell'applicazione dei metodi successivi
li t0 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a1 0
li a2 0
li a3 0
li a4 0
add s1 s5 zero        #aggiorno s1 per far riferiento negli altri metodi alla nuova stringa
addi s5 s5 1000        #incremento il valore dell'indirizzo della stringa per evitare sovrapposizioni
j Decrittografia
 
 fine:
     la a0 messaggio_fine
     li a7 4
     ecall

    
