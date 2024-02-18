;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Practica 5_1
; Completar el ejemplo descrito en "Ejemplo de integracion de logica por defecto", el cual se basa en,
; dado un animal, deducir si vuela o no dependiendo de si es mamifero o es ave



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;          REPRESENTACION          ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (ave ?x) representa “?x es un ave ”
; (animal ?x) representa “?x es un animal”
; (vuela ?x si|no seguro|por_defecto) representa “?x vuela si|no con esa certeza”


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;              HECHOS              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Las aves y los mamiferos son animales
; Los gorriones, las palomas, las aguilas y los pingüinos son aves
; La vaca, los perros y los caballos son mamiferos
; Los pingüinos no vuelan

(deffacts datos
   (ave gorrion)
   (ave paloma)
   (ave aguila)
   (ave pinguino)
   (mamifero vaca)
   (mamifero perro)
   (mamifero caballo)
   (vuela pinguino no seguro)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;          REGLAS SEGURAS          ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Las aves son animales

(defrule aves_son_animales
   (ave ?x)
=>
   (assert (animal ?x))
   (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque las aves son un tipo de animal"))
   (assert (explicacion animal ?x ?expl))                                                                ; aniadimos un hecho que contiene la explicacion de la deduccion
)

;;; Los mamiferos son animales

(defrule mamiferos_son_animales
   (mamifero ?x)
=>
   (assert (animal ?x))
   (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque los mamiferos son un tipo de animal"))
   (assert (explicacion animal ?x ?expl))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     REGLA POR DEFECTO: ANIADE    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Casi todos las aves vuela --> Puedo asumir por defecto que las aves vuelan
;;; Asumimos por defecto

(defrule ave_vuela_por_defecto
   (declare (salience -1))                                                                               ; para disminuir probabilidad de aniadir erroneamente
   (ave ?x)
=>
   (assert (vuela ?x si por_defecto))
   (bind ?expl (str-cat "asumo que un " ?x " vuela, porque casi todas las aves vuelan"))
   (assert (explicacion vuela ?x ?expl))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;    REGLA POR DEFECTO: RETRACTA   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Retractamos cuando hay algo en contra
;;; COMENTARIO: esta regla tambien elimina los por defecto cuando ya esta seguro

(defrule retracta_vuela_por_defecto
   (declare (salience 1))                                                                                ; para retractar antes de inferir cosas erroneamente
   ?f <- (vuela ?x ?r por_defecto)
   (vuela ?x ?s seguro)
=>
   (retract ?f)
   (bind ?expl (str-cat "retractamos que un " ?x " " ?r " vuela por defecto, porque sabemos seguro que " ?x " " ?s " vuela"))
   (assert (explicacion vuela ?x ?expl))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   REGLA POR DEFECTO: RAZONAR CON INFORMACION INCOMPLETA   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; La mayor parte de los animales no vuelan --> Puede interesarme asumir por defecto que un animal no va a volar

(defrule mayor_parte_animales_no_vuelan
   (declare (salience -2))                                                                               ; es mas arriesgado, mejor despues de otros razonamientos
   (animal ?x)
   (not (vuela ?x ? ?))
=>
   (assert (vuela ?x no por_defecto))
   (bind ?expl (str-cat "asumo que " ?x " no vuela, porque la mayor parte de los animales no vuelan"))
   (assert (explicacion vuela ?x ?expl))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   PREGUNTAR POR EL ANIMAL   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Pregunta el nombre del animal

(defrule preguntar_nombre_animal
=>
   (printout t "Como se llama el animal del cual estas interesado en saber si vuela o no?" crlf)
   (assert (pregunta (read)))
)

;;; Si el animal no esta recogido en el conocimiento, pregunta si es un ave o un mamifero

(defrule preguntar_ave_o_mamifero
   (declare (salience -3))
   ?f <- (pregunta ?x)
   (not (or (mamifero ?x) (ave ?x)))
=>
   (printout t "No tengo conocimiento acerca de dicho animal, es un ave o un mamifero?" crlf)
   (assert (respuesta ?x (read)))
   (retract ?f)
)

;;; Si responde que el animal es un ave, guardamos la respuesta

(defrule guardar_respuesta_ave
   (declare (salience -3))
   ?f <- (respuesta ?x ave)
=>
   (assert (ave ?x) (pregunta ?x))
   (retract ?f)
)

;;; Si responde que el animal es un mamifero, guardamos la respuesta

(defrule guardar_respuesta_mamifero
   (declare (salience -3))
   ?f <- (respuesta ?x mamifero)
=>
   (assert (mamifero ?x) (pregunta ?x))
   (retract ?f)
)

;;; No sabe si el animal es un ave o un mamifero

(defrule desconocimiento_ave_o_mamifero
   (declare (salience -3))
   ?f <- (respuesta ?x ?r)
   (not (eq ?r mamifero))
   (not (eq ?r ave))
=>
   (assert (animal ?x) (pregunta ?x))
   (retract ?f)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   RESPUESTA SOBRE SI EL ANIMAL VUELA O NO   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; El animal introducido no esta recogido en el conocimiento pero el usuario sabe que es un ave

(defrule sabe_animal_es_ave
   (declare (salience -3))
   ?f <- (pregunta ?x)
   (ave ?x)
   (explicacion vuela ?x ?expl)
=>
   (printout t ?x " es un ave y " ?expl crlf)
   (retract ?f)
)

;;; El animal introducido no esta recogido en el conocimiento pero el usuario sabe que es un mamifero

(defrule sabe_animal_es_mamifero
   (declare (salience -3))
   ?f <- (pregunta ?x)
   (mamifero ?x)
   (explicacion vuela ?x ?expl)
=>
   (printout t ?x " es un mamifero y " ?expl crlf)
   (retract ?f)
)

;;; El animal introducido no esta recogido en el conocimiento y el usuario no sabe si es un ave o un mamifero
;;; En este caso se responde segun el razonamiento por defecto indicado

(defrule no_sabe_animal_es_mamifero_o_ave
   (declare (salience -3))
   ?f <- (pregunta ?x)
   (animal ?x)
   (not (ave ?x))
   (not (mamifero ?x))
   (explicacion vuela ?x ?expl)
=>
   (printout t ?x " es un animal y " ?expl crlf)
   (retract ?f)
)
