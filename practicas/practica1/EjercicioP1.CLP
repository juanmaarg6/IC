;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Practica 1
; Realizar un sistema en CLIPS que recoja el conocimiento sobre los miembros de una familia (por ejemplo la tuya, o una familia Real o una familia de ficcion)
; y que indique quienes son los miembros que estan relacionados por una relacion concreta R con un miembro concreto de la familia M. Por ejemplo, con la familia 
; del ejemplo el sistema tendria que responder cuestiones como: 
;    - ¿Quienes son los abuelos de Juanito? 
;    - ¿Quienes son los yernos de Mercedes? 
;    - ¿Quienes son los hijos de Lidia? 
; En el caso de que no haya ningun miembro de la familia relacionado mediante R con M, el sistema debe indicarlo.

;;;; HECHOS GENERALES DEL SISTEMA ;;;;;
;;;; (seran validos para todas las ejecuciones del sistema) ;;;;

; Listado de personas de la familia en cuestion introduccidas con la propiedad unaria de hombre o mujer

(deffacts personas
   (hombre Juan1) ; "Juan1 es un hombre"
   (hombre Juan2)
   (hombre Nono)
   (hombre JuanManuel)
   (hombre Luis)
   (hombre Javi)
   (hombre Miguel)
   (hombre Carlos)
   (hombre Juanma)
   (hombre Adan)
   (hombre Mario)
   (hombre Dani)
   (mujer Isabel)         ; "Isabel es una mujer"
   (mujer Maria)
   (mujer Chari)
   (mujer AnaMaria)
   (mujer Rosa)
   (mujer Isa)
   (mujer Inma)
   (mujer Mari)
   (mujer Esther) 
   (mujer Nereida)
   (mujer AnaBelen)
   (mujer Ana) )

;;;;; Plantilla t?pica de Relaciones binarias, ajustada a relaciones de parentesco restringiendo los valores de tipo de relacion a estas. Se usa para registrar "El <sujeto> es <tipo de relacion> de <objeto>", por ejemplo "Juan es TIO de Julia" 

(deftemplate Relacion 
  (slot tipo (type SYMBOL) (allowed-symbols HIJO PADRE ABUELO NIETO HERMANO ESPOSO PRIMO TIO SOBRINO  CUNIADO YERNO SUEGRO))
  (slot sujeto)
  (slot objeto))

;;;;; Datos de la relacion HIJO y ESPOSO en mi familia que es suficiente para el problema, pues el resto se deduce de estas

(deffacts relaciones
   (Relacion (tipo HIJO) (sujeto Nono)(objeto Juan1)) ; "Nono es HIJO de Juan1"
   (Relacion (tipo HIJO) (sujeto AnaMaria) (objeto Juan1))
   (Relacion (tipo HIJO) (sujeto Rosa) (objeto Juan1))
   (Relacion (tipo HIJO) (sujeto JuanManuel) (objeto Juan2))
   (Relacion (tipo HIJO) (sujeto Javi) (objeto Juan2))
   (Relacion (tipo HIJO) (sujeto Miguel) (objeto Juan2))
   (Relacion (tipo HIJO) (sujeto Inma) (objeto Juan2))
   (Relacion (tipo HIJO) (sujeto Mari) (objeto Juan2))
   (Relacion (tipo HIJO) (sujeto Esther) (objeto Nono))
   (Relacion (tipo HIJO) (sujeto Nereida) (objeto Nono))
   (Relacion (tipo HIJO) (sujeto AnaBelen) (objeto JuanManuel))
   (Relacion (tipo HIJO) (sujeto Juanma) (objeto JuanManuel))
   (Relacion (tipo HIJO) (sujeto Ana) (objeto Luis))
   (Relacion (tipo HIJO) (sujeto Adan) (objeto Luis))
   (Relacion (tipo HIJO) (sujeto Mario) (objeto Javi))
   (Relacion (tipo HIJO) (sujeto Dani) (objeto Javi))
   (Relacion (tipo ESPOSO) (sujeto Juan1) (objeto Isabel)) ; "Juan1 es ESPOSO de Isabel"
   (Relacion (tipo ESPOSO) (sujeto Juan2) (objeto Maria)) 
   (Relacion (tipo ESPOSO) (sujeto Nono) (objeto Chari))
   (Relacion (tipo ESPOSO) (sujeto JuanManuel) (objeto AnaMaria))
   (Relacion (tipo ESPOSO) (sujeto Luis) (objeto Rosa))
   (Relacion (tipo ESPOSO) (sujeto Javi) (objeto Isa))
   (Relacion (tipo ESPOSO) (sujeto Carlos) (objeto AnaBelen)) )

;;;;;;; Cada relacion tiene una relacion dual que se produce al cambiar entre si objeto y sujeto. Por ejejmplo, Si x es HIJO de y, y es PADRE de x". Para poder deducirlo con una sola regla metemos esa informacion como hechos con la etiqueta dual, "Dual de HIJO PADRE", y asi con todas las relaciones consideradas
 
(deffacts duales
(dual HIJO PADRE) (dual ABUELO NIETO) (dual HERMANO HERMANO) 
(dual ESPOSO ESPOSO) 
(dual PRIMO PRIMO) (dual TIO SOBRINO) 
(dual CUNIADO CUNIADO) 
(dual YERNO SUEGRO))

;;;;;; Para deducir las reglas que se aplican son de composicion, del tipo "el HERMANO del PADRE es un TIO". Por comodidad, en lugar de crear una regla por cada posible composici?n, metemos como hechos la relacion que se obtiene por composicion. Solo metemos unas cuantas composiciones que sean suficientes para deducir cualquier cosa

(deffacts compuestos
(comp HIJO HIJO NIETO) (comp PADRE PADRE ABUELO) (comp ESPOSO PADRE PADRE)(comp HERMANO PADRE TIO) (comp HERMANO ESPOSO CUNIADO) (comp ESPOSO HIJO YERNO) (comp ESPOSO HERMANO CUNIADO) (comp HIJO PADRE HERMANO) (comp ESPOSO CUNIADO CUNIADO) (comp ESPOSO TIO TIO)  (comp HIJO TIO PRIMO)  ) 


;;;;;; Para que cuando digamos por pantalla el parentesco lo espresemos correctamente, y puesto que el nombre que hemos puesto a cada relacion es el caso masculino, vamos a meter como hechos como se diaria esa relacion en femenino mediante la etiqueta femenino

(deffacts femenino
(femenino HIJO HIJA) (femenino PADRE MADRE) (femenino ABUELO ABUELA) (femenino NIETO NIETA) (femenino HERMANO HERMANA) (femenino ESPOSO ESPOSA) (femenino PRIMO PRIMA) (femenino TIO TIA) (femenino SOBRINO SOBRINA) (femenino CUNIADO CUNIADA) (femenino YERNO NUERA) (femenino SUEGRO SUEGRA)) 

;;;;;; Para que cuando digamos por pantalla la relacion en plural, lo expresemos correctamente, vamos a meter como hechos como se diria esa relacion en singular mediante la etiqueta plural
(deffacts plural
(plural HIJOS HIJO) (plural PADRES PADRE) (plural ABUELOS ABUELO) (plural NIETOS NIETO) (plural HERMANOS HERMANO) (plural ESPOSOS ESPOSO) (plural PRIMOS PRIMO) (plural TIOS TIO) (plural SOBRINOS SOBRINO) (plural CUNIADOS CUNIADO) (plural YERNOS YERNO) (plural SUEGROS SUEGRO))

;;;;; REGLAS DEL SISTEMA ;;;;;

;;;; La dualidad es simetrica: si r es dual de t, t es dual de r. Por eso solo metimos como hecho la dualidad en un sentidos, pues en el otro lo podiamos deducir con esta regla

(defrule autodualidad
      (dual ?r ?t)
=> 
   (assert (dual ?t ?r)))


;;;; Si  x es R de y, entonces y es dualdeR de x

(defrule dualidad
   (Relacion (tipo ?r) (sujeto ?x) (objeto ?y))
   (dual ?r ?t)
=> 
   (assert (Relacion (tipo ?t) (sujeto ?y) (objeto ?x))))


;;;; Si  y es R de x, y x es T de z entonces y es RoT de z
;;;; a?adimos que z e y sean distintos para evitar que uno resulte hermano de si mismo y cosas asi.

(defrule composicion
   (Relacion (tipo ?r) (sujeto ?y) (objeto ?x))
   (Relacion (tipo ?t) (sujeto ?x) (objeto ?z))
   (comp ?r ?t ?u)
   (test (neq ?y ?z))
=> 
   (assert (Relacion (tipo ?u) (sujeto ?y) (objeto ?z))))

;;;;; Como puede deducir que tu hermano es tu cu?ado al ser el esposo de tu cu?ada, eliminamos los cu?ados que sean hermanos

(defrule limpiacuniados
    (Relacion (tipo HERMANO) (sujeto ?x) (objeto ?y))
    ?f <- (Relacion (tipo CUNIADO) (sujeto ?x) (objeto ?y))
=>
	(retract ?f) )

;;;;; Solicitamos el nombre de la persona sobre la que se desea informacion y guardamos y aniadimos ese hecho 
 
(defrule preguntaPersona
   (declare (salience 1000)) 
=>
   (printout t crlf "Dime el nombre de la persona de la Familia Rodriguez sobre la que quieres informacion (escribe solo el nombre): " crlf)
   (assert (persona (read)))
)
   
;;;;; Solicitamos la relacion familiar de la cual se quieren saber los miembros de la familia relacionados con la persona introducida anteriormente
 
(defrule preguntaRelacion
   (declare (salience 100))
   (persona ?per)
=>
   (printout t crlf "Dime la relacion familiar concreta de la que quieres saber los miembros de dicha relacion con " ?per crlf "en la Familia Rodriguez(escribe la relacion en MAYUSCULAS, en MASCULINO y en PLURAL. Por ejemplo, 'HERMANOS'): " crlf)
   (assert (relacionPersona (read)))
)

;;;;; Hacemos que nos diga por pantalla las personas que tienen esa relacion introducida (ya sea en singular o en plural) con esa persona introducida por pantalla. Como la forma de expresarlo dependera del sexo, usamos dos reglas, una para cada sexo

(defrule relacionMasculino
   (declare (salience -1))
   (persona ?x)
   (relacionPersona ?r)
   (plural ?r ?t)
   (Relacion (tipo ?t) (sujeto ?y) (objeto ?x))
   (hombre ?y)
 =>
   (printout t crlf ?y " es " ?t " de " ?x crlf) 
)

(defrule relacionFemenino
   (declare (salience -1))
   (persona ?x)
   (relacionPersona ?r)
   (plural ?r ?t)
   (Relacion (tipo ?t) (sujeto ?y) (objeto ?x))
   (mujer ?y)
   (femenino ?t ?s)
 =>
   (printout t crlf ?y " es " ?s " de " ?x crlf) 
)

;;;;; Hacemos que nos diga por pantalla que no hay ninguna persona que tenga la relacion introducida con la persona introducida por pantalla.

(defrule ningunaRelacion
   (declare (salience -2))
   (persona ?x)
   (relacionPersona ?r)
   (plural ?r ?t)
   (not(Relacion (tipo ?t) (sujeto ?y) (objeto ?x))) ; No existe ningun hecho que empareje con los datos introducidos
 =>
   (printout t crlf ?x " no tiene ningun " ?t crlf) 
)
 