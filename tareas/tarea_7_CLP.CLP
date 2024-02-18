;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Tarea 7
; Diseñar un sistema difuso que calcule el riego de infarto a partir de la edad y peso de una persona de acuerdo a las siguientes 3 reglas:
;    - Si la edad es alta, el riesgo de infarto es medio.
;    - Si el peso es alto, el riesgo de infarto es alto.
;    - Si el peso es muy alto, el riesgo de infarto es muy alto.
; Comprobar el funcionamiento del sistema con al menos 8 casos distintos, de los cuales 3 deben ser casos extremos. Comentar el resultado de los casos de prueba.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;   Modulo ejecutar sistema difuso con varias variables de entrada   ;;;;;;;
;;;;;       MODULO CALCULO FUZZY (modulo calculo_fuzzy)      ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;  Copywright Juan Luis Castro  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCIONES NECESARIAS  ;;;;;;;;;;;;;;;;;;;;;;;

; Membership es una funcion que calcula el grado de pertenencia de value al conjunto difuso 
;trapezoidal (a b c d). 
(deffunction membership (?value ?a ?b ?c ?d)
(if  (< ?value ?a) then (bind ?rv 0)
	else 
	   (if (< ?value ?b) then (bind ?rv (/ (- ?value ?a) (- ?b ?a)))
           else
             (if  (< ?value ?c) then (bind ?rv 1)
                 else
                   (if (< ?value ?d) then (bind ?rv (/ (- ?d ?value) (- ?d ?c)))
                        else (bind ?rv 0)
                   )				   
             )			  
       )
)
?rv
)

; center_of_gravity es una función que calcula el centro de gravedad del conjunto difuso
;trapezoidal (a b c d).
(deffunction center_of_gravity (?a ?b ?c ?d)
   (bind ?ati (/ (- ?b ?a) 2))
   (bind ?atd (/ (- ?d ?c) 2))
   (bind ?rv (/ (+ (+ ?b ?c) (- ?atd ?ati)) 2))
   ?rv
)

(deffunction conjuncion (?x ?y)
   (bind ?rv (* ?x ?y))
   ?rv
)

 
;;;;;;;;;;;;;;;;;;;;;;;;;; CONOCIMIENTO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Entradas: Peso y Edad de una persona (dato ?variable ?valor)
; Salidas: Riesgo de infarto (fuzzy inference ?variable ?valor)
;;;;;;;;;;;;Conocimiento ;;;;;;;;;;;;;;;;; 
;; Si la edad es alta, el riesgo de infarto es medio.
;; Si el peso es alto, el riesgo de infarto es alto.
;; Si el peso es muy alto, el riesgo de infarto es muy alto.

;; Definimos de las variables del sistema

(deffacts variables_difusas
   (variable peso)
   (variable edad)
   (variable riesgo_de_infarto)
)

;;  Definimos los conjuntos difusos que usará el sistema

(deffacts conjuntos_difusos
   (cd peso bajo 0 0 60 70)           ; aproximadamente menos de 60
   (cd peso medio 63 70 80 85)        ; aproximadamente entre 70 y 80
   (cd peso alto 85 95 105 110)       ; aproximadamente entre 95 y 105
   (cd peso muy_alto 105 115 300 300) ; aproximadamente mas de 115
   (cd edad baja 0 0 20 25)		         ; aproximadamente menos de 20
   (cd edad media 25 30 60 65)	         ; aproximadamente entre 30 y 60
   (cd edad alta 70 80 200 200)           ; aproximadamente mas de 70
   (cd riesgo_de_infarto bajo 0 0.05 0.05 0.08)     ; aproximadamente 0.05
   (cd riesgo_de_infarto medio 0.1 0.2 0.2 0.25)    ; aproximadamente 0.2
   (cd riesgo_de_infarto alto 0.3 0.5 0.5 0.55)     ; aproximadamente 0.5
   (cd riesgo_de_infarto muy_alto 0.5 0.6 1 1)      ; aproximadamente mas de 0.6
)

;; Definimos las reglas y las explicaciones asociadas

(deffacts reglas
   (regla 1 antecedente edad alta)
   (regla 1 consecuente riesgo_de_infarto medio)
   (regla 1 explicacion "Si la edad es alta, el riesgo de infarto es medio")
   (regla 2 antecedente peso alto)
   (regla 2 consecuente riesgo_de_infarto alto)
   (regla 2 explicacion "Si el peso es alto, el riesgo de infarto es alto")
   (regla 3 antecedente peso muy_alto)
   (regla 3 consecuente riesgo_de_infarto muy_alto)
   (regla 3 explicacion "Si el peso es muy alto, el riesgo de infarto es muy alto")
)


; Obtenemos el cumplimiento de cada conjunto difuso

(defrule cumplimiento_predicado_difuso
   (declare (salience 3))
   (modulo calculo_fuzzy)
   (cd ?v ?l ?a ?b ?c ?d)
   (dato ?v ?x)
=>
   (bind ?g (membership ?x ?a ?b ?c ?d))
   (assert (fuzzy cumplimiento ?v ?l ?g))
   (if (> ?g 0) then (printout t ?v " es " ?l " en grado " ?g crlf))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obtenemos el matching de cada antecedente de cada regla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule matching_antecedente_simple
   (declare (salience 2))
   (modulo calculo_fuzzy)
   (regla ?r antecedente ?v ?l)
   (fuzzy cumplimiento ?v ?l ?g)
=>
   (assert (fuzzy matching ?r ?g ?v))
)

(defrule matching_antecedente_1
   (declare (salience 2))
   (modulo calculo_fuzzy)
   ?f <- (fuzzy matching ?r ?g ?v)
   (not (fuzzy matching_antecedente_regla ?r ?))
=>
   (assert (fuzzy matching_antecedente_regla ?r ?g))
   (retract ?f)
)

(defrule matching_antecedente
   (declare (salience 2))
   (modulo calculo_fuzzy)
   ?f <- (fuzzy matching ?r ?g ?v)
   ?h<- (fuzzy matching_antecedente_regla ?r ?g1)
=>
   (retract ?f ?h)
   (assert (fuzzy matching_antecedente_regla ?r (conjuncion ?g1 ?g)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inferimos con su correspondiente grado los consecuentes de las reglas que hacen algun matching
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule inferencia_difusa
   (declare (salience 1))
   (modulo calculo_fuzzy)
   (fuzzy matching_antecedente_regla ?r ?g1)
   (test (> ?g1 0))
   (regla ?r consecuente ?v ?l)
   (regla ?r explicacion ?text)
=>
   (assert (fuzzy inferido ?v ?l ?g1))
   (printout t "Se va a aplicar la regla " ?text  crlf)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Obtenemos el valor deducido como la media ponderada (por los grados de cada consecuente) 
;;;  de los centros de gravedad de los consecuentes inferidos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule concrecion_individual
   (modulo calculo_fuzzy)
   (fuzzy inferido ?v ?l ?g1)
   (cd ?v ?l ?a ?b ?c ?d)
=>
   (assert (fuzzy sumando_numerador ?v (* ?g1 (center_of_gravity ?a ?b ?c ?d))))
   (assert (fuzzy sumando_denominador ?v ?g1))
)

(defrule concrecion_numerador
   (modulo calculo_fuzzy)
   ?g<- (fuzzy numerador ?v ?x)
   ?f <- (fuzzy sumando_numerador ?v ?y)
=>
   (assert (fuzzy numerador ?v (+ ?x ?y)))
   (retract ?f ?g)
)

(defrule concrecion_denominador
   (modulo calculo_fuzzy)
   ?g<- (fuzzy denominador ?v ?x)
   ?f <- (fuzzy sumando_denominador ?v ?y)
=>
   (assert (fuzzy denominador ?v (+ ?x ?y)))
   (retract ?f ?g)
)

(defrule respuesta
   (declare (salience -1))
   (modulo calculo_fuzzy)
   (fuzzy numerador ?v ?n)
   (fuzzy denominador ?v ?d)
   (test (> ?d 0))
=>
   (assert (fuzzy valor_inferido ?v (/ ?n ?d)))
   (printout t "Aplicando esta(s) regla(s) el valor de " ?v " es " (/ ?n ?d)  crlf)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;  Una vez inferido el valor salimos del modulo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule salir
   (declare (salience -2))
   ?f <- (modulo calculo_fuzzy)
=>
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;; INICIALIZACION DE LOS VALORES CUANDO SE ENTRA AL MODULO  ;;;;;;;;;;

(defrule iniciar_proceso
   (declare (salience 5))
   (modulo calculo_fuzzy)
=>
   (assert (borrar_datos_ejecucion_anterior))
)

(defrule borrar_datos_ejecucion_anterior
   (declare (salience 5))
   (modulo calculo_fuzzy)
   (borrar_datos_ejecucion_anterior)
   ?f <- (fuzzy $?)
=>
   (retract ?f)
)

(defrule borrar_borrar_datos
   (declare (salience 5))
   (modulo calculo_fuzzy)
   ?f<- (borrar_datos_ejecucion_anterior)
   (not (fuzzy $?))
=>
   (retract ?f)
)

(defrule inicializar_fuzzy_inference
   (declare (salience 4))
   (modulo calculo_fuzzy)
   (regla ? consecuente ?v ?)
=>
   (assert (fuzzy numerador ?v 0))
   (assert (fuzzy denominador ?v 0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;  PARA COMPROBARLO   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;  Reglas para pedir los datos y entrar en el modulo ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule pregunta1
   (declare (salience 1)) 
=>
   (printout t "Peso: ")
   (assert (dato peso (read)))
)

(defrule pregunta2
   (declare (salience 1)) 
=>
   (printout t "Edad: ")
   (assert (dato edad (read)))
)

(defrule pregunta3
=>
   (assert (modulo calculo_fuzzy))
)