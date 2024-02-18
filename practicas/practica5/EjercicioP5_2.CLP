;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Practica 5_2
; Completar el ejemplo descrito en "Ejemplo de integracion de factores de certeza en clips", el cual se basa en,
; realizar un diagnostico sobre la averia de un coche que no arranca de acuerdo a una serie de reglas



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;          REPRESENTACION          ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (FactorCerteza ?h si|no ?f) representa que ?h se ha deducido con factor de certeza ?f
;    ?h podra ser:
;       - problema_starter
;       - problema_bujias
;       - problema_bateria
;       - motor_llega_gasolina
; (Evidencia ?e si|no) representa el hecho de si evidencia ?e se da
;    ?e podra ser:
;       - hace_intentos_arrancar
;       - hay_gasolina_en_deposito
;       - encienden_las_luces
;       - gira_motor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;         FUNCIONES        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Funcion para realizar una pregunta que tenga como respuesta 'si' o 'no'

(deffunction pregunta_si_o_no (?pregunta)
=>
   (printout t ?pregunta " (responda 'si' o 'no')" crlf)
   (bind ?respuesta (read))
   (while (and (neq ?respuesta si) (neq ?respuesta no))
      (printout t ?pregunta " (responda 'si' o 'no')" crlf)
      (bind ?respuesta (read))
   )
   ?respuesta
)

;;; Funcion encadenado

(deffunction encadenado (?fc_antecedente ?fc_regla)
   (if (> ?fc_antecedente 0) then
      (bind ?rv (* ?fc_antecedente ?fc_regla))
   else
      (bind ?rv 0) 
   )
   ?rv
)

;;; Funcion combinacion

(deffunction combinacion (?fc1 ?fc2)
   (if (and (> ?fc1 0) (> ?fc2 0) ) then
      (bind ?rv (- (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
   else
      (if (and (< ?fc1 0) (< ?fc2 0) ) then
         (bind ?rv (+ (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
      else
         (bind ?rv (/ (+ ?fc1 ?fc2) (- 1 (min (abs ?fc1) (abs ?fc2))) ))
      )
   ) 
   ?rv
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;          REGLAS          ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Convertimos cada evidencia en una afirmacion sobre su factor de certeza
;;; Tambien podriamos considerar evidencias con una cierta incertidumbre: al preguntar por la evidencia, pedir y recoger
;;; directamente el grado de certeza (por ello, implementaremos las reglas de forma mas general, usando la funcion
;;; encadenado, aunque para este ejemplo concreto las evidencias tengan certeza 1)

(defrule certeza_evidencias
   (Evidencia ?e ?r)
=>
   (assert (FactorCerteza ?e ?r 1))
)

;;; R1: SI el motor obtiene gasolina Y el motor gira ENTONCES problemas con las bujias con certeza 0.7

(defrule R1
   (declare (salience 10))
   (FactorCerteza motor_llega_gasolina si ?f1)
   (FactorCerteza gira_motor si ?f2)
   (test (and (> ?f1 0) (> ?f2 0)))
=>
   (assert (FactorCerteza problema_bujias si (encadenado (* ?f1 ?f2) 0.7)))
)

;;; R2: SI NO gira el motor ENTONCES problema con el starter con certeza 0.8

(defrule R2
   (declare (salience 10))
   (FactorCerteza gira_motor no ?f1)
   (test (> ?f1 0))
=>
   (assert (FactorCerteza problema_starter si (encadenado ?f1 0.8)))
)

;;; R3: SI NO encienden las luces ENTONCES problemas con la bateria con certeza 0.9

(defrule R3
   (declare (salience 10))
   (FactorCerteza encienden_las_luces no ?f1)
   (test (> ?f1 0))
=>
   (assert (FactorCerteza problema_bateria si (encadenado ?f1 0.9)))
)

;;; R4: SI hay gasolina en el deposito ENTONCES el motor obtiene gasolina con certeza 0.9

(defrule R4
   (declare (salience 10))
   (FactorCerteza hay_gasolina_en_deposito si ?f1)
   (test (> ?f1 0))
=>
   (assert (FactorCerteza motor_llega_gasolina si (encadenado ?f1 0.9)))
)

;;; R5: SI hace intentos de arrancar ENTONCES problema con el starter con certeza -0.6

(defrule R5
   (declare (salience 10))
   (FactorCerteza hace_intentos_arrancar si ?f1)
   (test (> ?f1 0))
=>
   (assert (FactorCerteza problema_starter si (encadenado ?f1 -0.6)))
)

;;; R6: SI hace intentos de arrancar ENTONCES problema con la bateria 0.5
(defrule R6
   (declare (salience 10))
   (FactorCerteza hace_intentos_arrancar si ?f1)
   (test (> ?f1 0))
=>
   (assert (FactorCerteza problema_bateria si (encadenado ?f1 0.5)))
)

;;; Combinar misma deduccion por distintos caminos

(defrule combinar
   (declare (salience 1))
   ?f <- (FactorCerteza ?h ?r ?fc1)
   ?g <- (FactorCerteza ?h ?r ?fc2)
   (test (neq ?fc1 ?fc2))
=>
   (retract ?f ?g)
   (assert (FactorCerteza ?h ?r (combinacion ?fc1 ?fc2)))
)

;;; Aunque en este ejemplo no se da, puede ocurrir que tengamos deducciones de hipotesis en positivo y negativo que hay que combinar para compararlas

(defrule combinar_signo
   (declare (salience 2))
   (FactorCerteza ?h si ?fc1)
   (FactorCerteza ?h no ?fc2)
=>
   (assert (Certeza ?h (- ?fc1 ?fc2)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;      PREGUNTAR POR EVIDENCIAS      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule pregunta_hace_intentos_arrancar
   (declare (salience 100))
=>
   (assert (Evidencia hace_intentos_arrancar (pregunta_si_o_no "Hace intentos de arrancar?")))
)

(defrule pregunta_hay_gasolina_en_deposito
   (declare (salience 100))
=>
   (assert (Evidencia hay_gasolina_en_deposito (pregunta_si_o_no "Hay gasolina en el deposito?")))
)

(defrule pregunta_encienden_las_luces
   (declare (salience 100))
=>
   (assert (Evidencia encienden_las_luces (pregunta_si_o_no "Encienden las luces?")))
)

(defrule pregunta_gira_motor
   (declare (salience 100))
=>
   (assert (Evidencia gira_motor (pregunta_si_o_no "Gira el motor?")))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;      QUEDARSE CON LA HIPOTESIS CON MAYOR CERTEZA     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule inicializar_hip_mayor_certeza
   (declare (salience 1))
=>
   (assert (hip_max problema_desconocido 0))
)

(defrule eliminar_evidencias
   (declare (salience -1))
   ?f <- (FactorCerteza ?h ?x ?fc)
   ?e <- (Evidencia ?h ?s)
=>
   (retract ?f ?e)
   (printout t crlf "Elimino la evidencia '" ?h "' (ya que si no, al tener una certeza del 100%, esta seria la hipotesis con mayor certeza)")
)

(defrule hipotesis_mayor_certeza
   (declare (salience -2))
   ?f <- (FactorCerteza ?h1 si ?fc1)
   ?g <- (hip_max ?h2 ?fc2)
   (test (or (eq ?h1 problema_starter) (or (eq ?h1 problema_bujias) (eq ?h1 problema_bateria))))
   (test (> ?fc1 ?fc2))
=>
   (retract ?f ?g)
   (assert (hip_max ?h1 ?fc1))
   (printout t crlf "Elijo la hipotesis '" ?h1 "' (" (* ?fc1 100) "% de certeza) en vez de '" ?h2 "' (" (* ?fc2 100) "% de certeza) por tener mayor certeza")
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     RESPUESTA     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule respuesta
   (declare (salience -3))
   (hip_max ?hip ?fc)
   (test (> ?fc 0))
=>
   (printout t crlf crlf "Diagnostico final: El problema es '" ?hip "' con un " (* ?fc 100) "% de certeza" crlf)
)