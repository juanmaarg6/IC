;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Practica 2
; Considerar el juego del 4 en raya o conecta 4 (https://www.ludoteka.com/clasika/4-enraya.html).  En Prado se puede encontrar un CLP con un sistema basado en 
; reglas de CLIPS que juega al cuatro en raya contra un humano. En este fichero se encuentran reglas para que el sistema juegue en una columna aleatoria. Esta 
; actividad consiste en aniadir hechos y reglas para que el sistema razone y juegue como lo hariamos nosotros, de forma que pueda ser utilizado por un ninio para 
; aprender a jugar, razonando las jugadas. 

;;;;;;; JUGADOR DE 4 en RAYA ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;; Version de 4 en raya clasico: Tablero de 6x7, donde se introducen fichas por arriba
;;;;;;;;;;;;;;;;;;;;;;; y caen hasta la posicion libre mas abajo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Hechos para representar un estado del juego

;;;;;;; (Turno M|J)   representa a quien corresponde el turno (M maquina, J jugador)
;;;;;;; (Tablero Juego ?i ?j _|M|J) representa que la posicion i,j del tablero esta vacia (_), o tiene una ficha propia (M) o tiene una ficha del jugador humano (J)

;;;;;;;;;;;;;;;; Hechos para representar estado del analisis
;;;;;;; (Tablero Analisis Posicion ?i ?j _|M|J) representa que en el analisis actual la posicion i,j del tablero esta vacia (_), o tiene una ficha propia (M) o tiene una ficha del jugador humano (J)
;;;;;;; (Sondeando ?n ?i ?c M|J)  ; representa que estamos analizando suponiendo que la ?n jugada h sido ?i ?c M|J
;;;

;;;;;;;;;;;;; Hechos para representar una jugadas

;;;;;;; (Juega M|J ?columna) representa que la jugada consiste en introducir la ficha en la columna ?columna 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INICIALIZAR ESTADO


(deffacts Estado_inicial
(Tablero Juego 1 1 _) (Tablero Juego 1 2 _) (Tablero Juego 1 3 _) (Tablero Juego  1 4 _) (Tablero Juego  1 5 _) (Tablero Juego  1 6 _) (Tablero Juego  1 7 _)
(Tablero Juego 2 1 _) (Tablero Juego 2 2 _) (Tablero Juego 2 3 _) (Tablero Juego 2 4 _) (Tablero Juego 2 5 _) (Tablero Juego 2 6 _) (Tablero Juego 2 7 _)
(Tablero Juego 3 1 _) (Tablero Juego 3 2 _) (Tablero Juego 3 3 _) (Tablero Juego 3 4 _) (Tablero Juego 3 5 _) (Tablero Juego 3 6 _) (Tablero Juego 3 7 _)
(Tablero Juego 4 1 _) (Tablero Juego 4 2 _) (Tablero Juego 4 3 _) (Tablero Juego 4 4 _) (Tablero Juego 4 5 _) (Tablero Juego 4 6 _) (Tablero Juego 4 7 _)
(Tablero Juego 5 1 _) (Tablero Juego 5 2 _) (Tablero Juego 5 3 _) (Tablero Juego 5 4 _) (Tablero Juego 5 5 _) (Tablero Juego 5 6 _) (Tablero Juego 5 7 _)
(Tablero Juego 6 1 _) (Tablero Juego 6 2 _) (Tablero Juego 6 3 _) (Tablero Juego 6 4 _) (Tablero Juego 6 5 _) (Tablero Juego 6 6 _) (Tablero Juego 6 7 _)
(Jugada 0)
)

(defrule Elige_quien_comienza
=>
(printout t "Quien quieres que empieze: (escribre M para la maquina o J para empezar tu) ")
(assert (Turno (read)))
)

;;;;;;;;;;;;;;;;;;;;;;; MUESTRA POSICION ;;;;;;;;;;;;;;;;;;;;;;;
(defrule muestra_posicion
(declare (salience 30))
(muestra_posicion)
(Tablero Juego 1 1 ?p11) (Tablero Juego 1 2 ?p12) (Tablero Juego 1 3 ?p13) (Tablero Juego 1 4 ?p14) (Tablero Juego 1 5 ?p15) (Tablero Juego 1 6 ?p16) (Tablero Juego 1 7 ?p17)
(Tablero Juego 2 1 ?p21) (Tablero Juego 2 2 ?p22) (Tablero Juego 2 3 ?p23) (Tablero Juego 2 4 ?p24) (Tablero Juego 2 5 ?p25) (Tablero Juego 2 6 ?p26) (Tablero Juego 2 7 ?p27)
(Tablero Juego 3 1 ?p31) (Tablero Juego 3 2 ?p32) (Tablero Juego 3 3 ?p33) (Tablero Juego 3 4 ?p34) (Tablero Juego 3 5 ?p35) (Tablero Juego 3 6 ?p36) (Tablero Juego 3 7 ?p37)
(Tablero Juego 4 1 ?p41) (Tablero Juego 4 2 ?p42) (Tablero Juego 4 3 ?p43) (Tablero Juego 4 4 ?p44) (Tablero Juego 4 5 ?p45) (Tablero Juego 4 6 ?p46) (Tablero Juego 4 7 ?p47)
(Tablero Juego 5 1 ?p51) (Tablero Juego 5 2 ?p52) (Tablero Juego 5 3 ?p53) (Tablero Juego 5 4 ?p54) (Tablero Juego 5 5 ?p55) (Tablero Juego 5 6 ?p56) (Tablero Juego 5 7 ?p57)
(Tablero Juego 6 1 ?p61) (Tablero Juego 6 2 ?p62) (Tablero Juego 6 3 ?p63) (Tablero Juego 6 4 ?p64) (Tablero Juego 6 5 ?p65) (Tablero Juego 6 6 ?p66) (Tablero Juego 6 7 ?p67)
=>
(printout t crlf)
(printout t ?p11 " " ?p12 " " ?p13 " " ?p14 " " ?p15 " " ?p16 " " ?p17 crlf)
(printout t ?p21 " " ?p22 " " ?p23 " " ?p24 " " ?p25 " " ?p26 " " ?p27 crlf)
(printout t ?p31 " " ?p32 " " ?p33 " " ?p34 " " ?p35 " " ?p36 " " ?p37 crlf)
(printout t ?p41 " " ?p42 " " ?p43 " " ?p44 " " ?p45 " " ?p46 " " ?p47 crlf)
(printout t ?p51 " " ?p52 " " ?p53 " " ?p54 " " ?p55 " " ?p56 " " ?p57 crlf)
(printout t ?p61 " " ?p62 " " ?p63 " " ?p64 " " ?p65 " " ?p66 " " ?p67 crlf)
(printout t  crlf)
)


;;;;;;;;;;;;;;;;;;;;;;; RECOGER JUGADA DEL CONTRARIO ;;;;;;;;;;;;;;;;;;;;;;;
(defrule mostrar_posicion
(declare (salience 9999))
(Turno J)
=>
(assert (muestra_posicion))
)

(defrule jugada_contrario
?f <- (Turno J)
=>
(printout t "en que columna introduces la siguiente ficha? ")
(assert (Juega J (read)))
(retract ?f)
)

(defrule juega_contrario_check_entrada_correcta
(declare (salience 1))
?f <- (Juega J ?c)
(test (and (neq ?c 1) (and (neq ?c 2) (and (neq ?c 3) (and (neq ?c 4) (and (neq ?c 5) (and (neq ?c 6) (neq ?c 7))))))))
=>
(printout t "Tienes que indicar un numero de columna: 1,2,3,4,5,6 o 7" crlf)
(retract ?f)
(assert (Turno J))
)

(defrule juega_contrario_check_columna_libre
(declare (salience 1))
?f <- (Juega J ?c)
(Tablero Juego 1 ?c ?X) 
(test (neq ?X _))
=>
(printout t "Esa columna ya esta completa, tienes que jugar en otra" crlf)
(retract ?f)
(assert (Turno J))
)

(defrule juega_contrario_actualiza_estado
?f <- (Juega J ?c)
?g <- (Tablero Juego ?i ?c _)
(Tablero Juego ?j ?c ?X) 
(test (= (+ ?i 1) ?j))
(test (neq ?X _))
=>
(retract ?f ?g)
(assert (Turno M) (Tablero Juego ?i ?c J))
)

(defrule juega_contrario_actualiza_estado_columna_vacia
?f <- (Juega J ?c)
?g <- (Tablero Juego 6 ?c _)
=>
(retract ?f ?g)
(assert (Turno M) (Tablero Juego 6 ?c J))
)


;;;;;;;;;;; ACTUALIZAR  ESTADO TRAS JUGADA DE CLISP ;;;;;;;;;;;;;;;;;;

(defrule juega_clisp_actualiza_estado
?f <- (Juega M ?c)
?g <- (Tablero Juego ?i ?c _)
(Tablero Juego ?j ?c ?X) 
(test (= (+ ?i 1) ?j))
(test (neq ?X _))
=>
(retract ?f ?g)
(assert (Turno J) (Tablero Juego ?i ?c M))
)

(defrule juega_clisp_actualiza_estado_columna_vacia
?f <- (Juega M ?c)
?g <- (Tablero Juego 6 ?c _)
=>
(retract ?f ?g)
(assert (Turno J) (Tablero Juego 6 ?c M))
)

;;;;;;;;;;; CLISP JUEGA SIN CRITERIO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule elegir_jugada_aleatoria
(declare (salience -9998))
?f <- (Turno M)
=>
(assert (Jugar (random 1 7)))
(retract ?f)
)

(defrule comprobar_posible_jugada_aleatoria
?f <- (Jugar ?c)
(Tablero Juego 1 ?c M|J)
=>
(retract ?f)
(assert (Turno M))
)

(defrule clisp_juega_sin_criterio
(declare (salience -9999))
?f<- (Jugar ?c)
=>
(printout t "JUEGO en la columna (sin criterio) " ?c crlf)
(retract ?f)
(assert (Juega M ?c))
(printout t "Juego sin razonar, que mal"  crlf) 
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;  Comprobar si hay 4 en linea ;;;;;;;;;;;;;;;;;;;;;

(defrule cuatro_en_linea_horizontal
(declare (salience 9999))
(Tablero ?t ?i ?c1 ?jugador)
(Tablero ?t ?i ?c2 ?jugador) 
(test (= (+ ?c1 1) ?c2))
(Tablero ?t ?i ?c3 ?jugador)
(test (= (+ ?c1 2) ?c3))
(Tablero ?t ?i ?c4 ?jugador)
(test (= (+ ?c1 3) ?c4))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador horizontal ?i ?c1))
)

(defrule cuatro_en_linea_vertical
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i1 ?c ?jugador)
(Tablero ?t ?i2 ?c ?jugador)
(test (= (+ ?i1 1) ?i2))
(Tablero ?t ?i3 ?c  ?jugador)
(test (= (+ ?i1 2) ?i3))
(Tablero ?t ?i4 ?c  ?jugador)
(test (= (+ ?i1 3) ?i4))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador vertical ?i1 ?c))
)

(defrule cuatro_en_linea_diagonal_directa
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i ?c ?jugador)
(Tablero ?t ?i1 ?c1 ?jugador)
(test (= (+ ?i 1) ?i1))
(test (= (+ ?c 1) ?c1))
(Tablero ?t ?i2 ?c2  ?jugador)
(test (= (+ ?i 2) ?i2))
(test (= (+ ?c 2) ?c2))
(Tablero ?t ?i3 ?c3  ?jugador)
(test (= (+ ?i 3) ?i3))
(test (= (+ ?c 3) ?c3))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador diagonal_directa ?i ?c))
)

(defrule cuatro_en_linea_diagonal_inversa
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i ?c ?jugador)
(Tablero ?t ?i1 ?c1 ?jugador)
(test (= (+ ?i 1) ?i1))
(test (= (- ?c 1) ?c1))
(Tablero ?t ?i2 ?c2  ?jugador)
(test (= (+ ?i 2) ?i2))
(test (= (- ?c 2) ?c2))
(Tablero ?t ?i3 ?c3  ?jugador)
(test (= (+ ?i 3) ?i3))
(test (= (- ?c 3) ?c3))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador diagonal_inversa ?i ?c))
)

;;;;;;;;;;;;;;;;;;;; DESCUBRE GANADOR
(defrule gana_fila
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador horizontal ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la fila " ?i crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_columna
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador vertical ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la columna " ?c crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_diagonal_directa
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador diagonal_directa ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la diagonal que empieza la posicion " ?i " " ?c   crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_diagonal_inversa
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador diagonal_inversa ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la diagonal hacia arriba que empieza la posicin " ?i " " ?c   crlf)
(retract ?f)
(assert (muestra_posicion))
) 


;;;;;;;;;;;;;;;;;;;;;;;  DETECTAR EMPATE

(defrule empate
(declare (salience -9999))
(Turno ?X)
(Tablero Juego 1 1 M|J)
(Tablero Juego 1 2 M|J)
(Tablero Juego 1 3 M|J)
(Tablero Juego 1 4 M|J)
(Tablero Juego 1 5 M|J)
(Tablero Juego 1 6 M|J)
(Tablero Juego 1 7 M|J)
=>
(printout t "EMPATE! Se ha llegado al final del juego sin que nadie gane" crlf)
)

;;;;;;;;;;;;;;;;;;;;;; CONOCIMIENTO EXPERTO ;;;;;;;;;;
;;;;; ¡¡¡¡¡¡¡¡¡¡ Aniadir conocimiento para que juege como vosotros jugariais !!!!!!!!!!!!

;;; REGLAS PARA DEDUCIR LA POSICION SIGUIENTE Y ANTERIOR A UNA POSICION

; POSICION SIGUIENTE VERTICAL
(defrule sig_pos_v
   (Tablero ?t ?f ?c ?j)
   (test(> ?f 1))
=>
   (assert(siguiente ?f ?c v (- ?f 1) ?c))
)

; POSICION SIGUIENTE HORIZONTAL
(defrule sig_pos_h
   (Tablero ?t ?f ?c ?j)
   (test(< ?c 7))
=>
   (assert(siguiente ?f ?c h ?f (+ ?c 1)))
)

; POSICION SIGUIENTE DIAGONAL DERECHA ARRIBA
(defrule sig_pos_d1
   (Tablero ?t ?f ?c ?j)
   (test(< ?c 7))
   (test(> ?f 1))
=>
   (assert(siguiente ?f ?c d1 (- ?f 1) (+ ?c 1)))
)

; POSICION SIGUIENTE DIAGONAL DERECHA ABAJO
(defrule sig_pos_d2
   (Tablero ?t ?f ?c ?j)
   (test(< ?c 7))
   (test(< ?f 6))
=>
   (assert(siguiente ?f ?c d2 (+ ?f 1) (+ ?c 1)))
)

; POSICION ANTERIOR VERTICAL
(defrule ant_pos_v
   (Tablero ?t ?f ?c ?j)
   (test(< ?f 6))
=>
   (assert(anterior ?f ?c v (+ ?f 1) ?c))
)

; POSICION ANTERIOR HORIZONTAL
(defrule ant_pos_h
   (Tablero ?t ?f ?c ?j)
   (test(> ?c 1))
=>
   (assert(anterior ?f ?c h ?f (- ?c 1)))
)

; POSICION ANTERIOR DIAGONAL DERECHA ARRIBA
(defrule ant_pos_d1
   (Tablero ?t ?f ?c ?j)
   (test(> ?c 1))
   (test(< ?f 6))
=>
   (assert(anterior ?f ?c d1 (+ ?f 1) (- ?c 1)))
)

; POSICION ANTERIOR DIAGONAL DERECHA ABAJO
(defrule ant_pos_d2
   (Tablero ?t ?f ?c ?j)
   (test(> ?c 1))
   (test(> ?f 1))
=>
   (assert(anterior ?f ?c d1 (- ?f 1) (- ?c 1)))
)

;;; REGLAS PARA DEDUCIR (Y MANTENER) DONDE CAERIA UNA FICHA SI SE JUEGA EN UNA COLUMNA CONCRETA

; FICHAS QUE CAERIAN DIRECTAMENTE EN LA ULTIMA FILA
(defrule caeria_ficha_ult_fila
   (Tablero ?t 6 ?c _)
=>
   (assert (caeria 6 ?c))
)

; ACTUALIZAMOS DONDE PUEDE CAER UNA FICHA EN UNA COLUMNA CONCRETA QUE NO ESTE LLENA (ES DECIR, SI POR EJEMPLO UNA FICHA PODIA CAER EN LA FILA 3 DE LA COLUMNA 4 PERO DICHA POSICION SE RELLENA, ENTONCES AHORA UNA NUEVA FICHA PODRA CAER EN LA FILA 2 DE DICHA COLUMNA 4)
(defrule caeria_ficha
   (declare (salience 100))
   ?hecho_caeria <- (caeria ?f ?c)
   (Tablero ?t ?f ?c ?j)
   (test(neq ?j _))
   (test (> ?f 1))
=>
   (retract ?hecho_caeria)
   (assert (caeria (- ?f 1) ?c))
)

; SI UNA COLUMNA ESTA LLENA, NO PODRAN CAER MAS FICHAS EN DICHA COLUMNA
(defrule eliminar_caeria
   (declare (salience 100))
   ?hecho_caeria <- (caeria ?f ?c)
   (Tablero ?t ?f ?c ?j)
   (test(eq ?f 1))
=>
   (retract ?hecho_caeria)
)

;;; REGLA PARA DEDUCIR QUE HAY 2 FICHAS DE UN MISMO JUGADOR EN LINEA EN UNA DIRECCION Y UNAS POSICIONES CONCRETAS
(defrule 2_en_linea
   (declare (salience 100))
   (Tablero ?t ?f1 ?c1 ?j)
   (Tablero ?t ?f2 ?c2 ?j)
   (test(neq ?j _))
   (siguiente ?f1 ?c1 ?d ?f2 ?c2)
=>
   (assert (conectado ?t ?d ?f1 ?c1 ?f2 ?c2 ?j))
)

;;; REGLA PARA DEDUCIR QUE UN JUGADOR TIENE 3 EN LINEA EN UNA DIRECCION Y UNAS POSICIONES CONCRETAS
(defrule 3_en_linea
   (declare (salience 100))
   (conectado ?t ?d ?f1 ?c1 ?f2 ?c2 ?j) ; Comprueba que hay 2 en linea
   (siguiente ?f2 ?c2 ?d ?f3 ?c3)       ; Deduce la tercera posicion para hacer 3 en linea
   (Tablero ?t ?f3 ?c3 ?j)
=>
   (assert (3_en_linea ?t ?d ?f1 ?c1 ?f3 ?c3 ?j))
)

;;; REGLAS PARA DEDUCIR (Y MANTENER) QUE UN JUGADOR GANARIA (ES DECIR, HACE 4 EN LINEA) SI JUGASE EN UNA COLUMNA
(defrule 4_en_linea
   (declare (salience 100))
   (3_en_linea ?t ?d ?f1 ?c1 ?f3 ?c3 ?j) ; Comprueba que hay 3 en linea
   (siguiente ?f3 ?c3 ?d ?f4 ?c4)        ; Deduce la cuarta posicion para hacer 4 en linea
   (caeria ?f4 ?c4)
=>
   (assert (ganaria ?t ?j ?c4))
)

(defrule 4_en_linea_borrar
   (declare (salience 100))
   (3_en_linea ?t ?d ?f1 ?c1 ?f3 ?c3 ?j) ; Comprueba que hay 3 en linea
   (siguiente ?f3 ?c3 ?d ?f4 ?c4)        ; Deduce la cuarta posicion para hacer 4 en linea
   (not (caeria ?f4 ?c4))	
   ?g <-(ganaria ?t ?j ?c4) 
=>
   (retract ?g)	
)

;;; REGLAS PARA QUE LA M QUINA JUEGUE BASANDOSE EN LOS HECHOS DEDUCIDOS POR LAS REGLAS ANTERIORES

; PRIMERA TIRADA

(defrule elegir_jugada_inicial
   (declare (salience 12))
   ?f <- (Turno M)
=>
   (assert (Jugar (random 1 7)))
   (retract ?f)
)

(defrule jugada_inicial
   (declare (salience 11))
   ?f<- (Jugar ?c)
=>
   (retract ?f)
   (assert (Juega M ?c))
   (printout t "JUEGO aleatoriamente en la columna " ?c " para hacer mi primera tirada" crlf)
)

; JUEGA PARA CONSEGUIR 2 EN LINEA
(defrule elegir_jugada_2_en_linea
   (declare (salience 14))
   ?v <- (Turno M)      		
   (Tablero ?t ?f ?c M)   
   (siguiente ?f ?c ?d ?f2 ?c2)
=>
   (assert (Jugar ?c2))
   (assert (jugada_2_en_linea))
   (retract ?v)
)

(defrule hacer_jugada_2_en_linea
   (declare (salience 13))
   ?f<- (Jugar ?c)
   ?g <- (jugada_2_en_linea)
=>
   (retract ?f)
   (retract ?g)
   (assert (Juega M ?c))   
   (printout t "JUEGO en la columna " ?c " para hacer 2 en linea " crlf)
)


; JUEGA PARA CONSEGUIR 3 EN LINEA
(defrule elegir_jugada_3_en_linea
   (declare (salience 16))
   ?v <- (Turno M) 
   (conectado ?t ?d ?f1 ?c1 ?f2 ?c2 ?jugador)      		
   (Tablero ?t ?f2 ?c2 M)
   (siguiente ?f2 ?c2 ?d ?f3 ?c3)
=>
   (assert (Jugar ?c3))
   (assert (jugada_3_en_linea))
   (retract ?v)
)

(defrule hacer_jugada_3_en_linea
   (declare (salience 15))
   ?f<- (Jugar ?c)
   ?g <- (jugada_3_en_linea)  		
=>
   (retract ?f)
   (retract ?g)
   (assert (Juega M ?c))
   (printout t "JUEGO en la columna " ?c " para hacer 3 en linea " crlf)
)

; JUEGA PARA GANAR (CONSEGUIR 4 EN LINEA) CONTRA EL JUGADOR
(defrule comprobar_jugada_ganadora
   (declare (salience 18))
   ?v <- (Turno M)
   (ganaria ?t M ?c)
=>
   (assert (Jugar ?c))
   (assert (puedo_ganar))
   (retract ?v)
)

(defrule hacer_jugada_ganadora
   (declare (salience 17))
   ?f<- (Jugar ?c)
   ?g <- (puedo_ganar)  
=>
   (retract ?f)
   (retract ?g)
   (assert (Juega M ?c))
   (printout t "JUEGO en la columna " ?c " para ganar" crlf)
)
; JUEGA PARA EVITAR PERDER CONTRA EL JUGADOR
(defrule comprobar_jugada_perderora
   (declare (salience 20))
   ?v <- (Turno M)
   (ganaria ?t J ?c)
=>
   (assert (Jugar ?c))
   (assert (voy_a_perder))
   (retract ?v)
)

(defrule hacer_jugada_evitar_perder
   (declare (salience 19))
   ?f<- (Jugar ?c)
   ?g <- (voy_a_perder)  		
=>
   (retract ?f)
   (retract ?g)
   (assert (Juega M ?c))
   (printout t "JUEGO en la columna " ?c " para no perder" crlf)
)

