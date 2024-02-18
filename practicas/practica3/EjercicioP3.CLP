;;; JUAN MANUEL RODRIGUEZ GOMEZ
;;; Practica 3
; El problema consiste en diseniar un sistema experto (Tengo un viaje para usted) para atender a un cliente de una agencia de viajes 
; que desea hacer un viaje y desea asesoramiento. Se supondra que el sistema recoge datos de los viajes que la agencia dispone para ofertar 
; y los carga como hechos mediante deffacts. Para el prototipo incluiremos a modo de ejemplo unos cuantos viajes.
; Asi, la practica consiste en crear un programa en CLIPS que:
;    1. Pregunte al usuario por una serie  de caracteristicas que se consideren adecuadas para poder ofrecerle un viaje que le interese.
;    2. Dado un viaje concreto,  decida de forma argumentada  si ese viaje es apropiado o no para  el usuario.
;    3. Elija un viaje a ofertar de acuerdo a unos criterios razonables, y le indique al usuario por que ese viaje le interesa
;    4. Si no se acepta el viaje ofertado,  actualice los puntos anteriores de acuerdo al motivo por el que no le convence ese viaje al usuario.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;         TEMPLATES Y FACTS        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Para la realizacion del sistema y poder recomendar un viaje a una persona, nos vamos a basar en 
;;; atributos valorados previamente mediante entrevistas a expertos, analisis de viabilidad
;;; y demas tecnicas utilizadas en la parte teorica de la asignatura.

;;; ---------------------------------------------------------------------------------------------------------------------

;;; El sistema considerara el tipo de viaje que le gustaria realizar al usuario
;;; Se representara por: (respuestaTipoViaje AVENTURA|RELAJANTE|CULTURAL|ROMANTICO|IGUAL|NS)
;;; IGUAL significa que no hay preferencia por el tipo de viaje
;;; Este hecho se deducira a partir de una respuesta del usuario a una pregunta del sistema

;;; ---------------------------------------------------------------------------------------------------------------------

;;; El sistema utilizara el presupuesto del usuario para recomendar un viaje
;;; Se representara por: (respuestaPresupuesto BAJO|MEDIO|ALTO|NS)
;;; Un presupuesto BAJO sera aquel menor a 1000€
;;; Un presupuesto MEDIO sera aquel entre 1000€ y 2000€ (ambos incluidos)
;;; Un presupuesto ALTO sera aquel mayor a 2000€
;;; IGUAL significa que le da igual el precio del viaje
;;; Este hecho se deducira a partir de una respuesta del usuario a una pregunta del sistema.

;;; ---------------------------------------------------------------------------------------------------------------------

;;; El sistema considerara la preferencia del usuario en cuanto al tipo de transporte que prefiere para el viaje
;;; Se representara por: (respuestaTransporte COCHE|TREN|AVION|CRUCERO|IGUAL|NS) 
;;; IGUAL significa que no hay preferencia por el tipo de transporte
;;; Este hecho se deducira a partir de una respuesta del usuario a una pregunta del sistema

;;; ---------------------------------------------------------------------------------------------------------------------

;;; El sistema considerara el numero maximo de dias que le gustaria viajar al usuario
;;; Se representara por: (respuestaDuracion CORTA|MEDIA|LARGA|IGUAL|NS)
;;; Una duracion CORTA sera aquella menor a 8 dias
;;; Una duracion MEDIA sera aquella entre 8 y 12 dias (ambos incluidos)
;;; Una duracion LARGA sera aquella mayor a 12 dias
;;; IGUAL significa que no tiene un numero maximo de dias
;;; Este hecho se deducira a partir de una respuesta del usuario a una pregunta del sistema

;;; ---------------------------------------------------------------------------------------------------------------------


;;; HECHOS PARA REPRESENTAR UN VIAJE

(defmodule MAIN 
   (export ?ALL)
)

(deftemplate Viaje
   (slot codigo)
   (slot destino)
   (slot dia_salida)
   (slot transporte)
   (slot duracion)
   (slot precio)
   (slot beneficio_agencia)
)

;;; Para representar que el sistema considera un viaje adecuado para el usuario

(deftemplate Adecuado
   (slot codigo)
   (slot motivo)
)

;;; Para representar que se va a ofertar un viaje concreto al usuario

(deftemplate Ofertar
   (slot codigo)
)

;;; Para representar que el usuario rechaza un viaje concreto

(deftemplate Rechazado
   (slot codigo)
   (slot motivo)
)

;;; Para representar que el usuario ha aceptado un viaje ofertado

(deftemplate Aceptado
   (slot codigo)
)

;;; LISTA DE DESTINOS DISPONIBLES EN LA AGENCIA: 
;;;    - Ibiza
;;;    - Cadiz
;;;    - Bali
;;;    - Cancun
;;;    - Miami
;;;    - Marrakech
;;;    - Bangkok
;;;    - Viena
;;;    - Kyoto
;;;    - Florencia
;;;    - Cusco
;;;    - Chamonix
;;;    - Arties

;;; LISTA DE VIAJES DISPONIBLES EN LA AGENCIA: 

(deffacts ViajesDisponibles
   (Viaje (codigo V1) (destino Ibiza) (dia_salida "2023-05-15") (transporte AVION) (duracion CORTA) (precio MEDIO) (beneficio_agencia 120))
   (Viaje (codigo V2) (destino Cadiz) (dia_salida "2023-06-10") (transporte COCHE) (duracion CORTA) (precio BAJO) (beneficio_agencia 50))
   (Viaje (codigo V3) (destino Bali) (dia_salida "2023-07-20") (transporte CRUCERO) (duracion MEDIA) (precio MEDIO) (beneficio_agencia 200))
   (Viaje (codigo V4) (destino Cancun) (dia_salida "2023-08-05") (transporte CRUCERO) (duracion CORTA) (precio MEDIO) (beneficio_agencia 150))
   (Viaje (codigo V5) (destino Miami) (dia_salida "2023-09-01") (transporte AVION) (duracion MEDIA) (precio MEDIO) (beneficio_agencia 180))
   (Viaje (codigo V6) (destino Marrakech) (dia_salida "2023-10-15") (transporte AVION) (duracion CORTA) (precio BAJO) (beneficio_agencia 90))
   (Viaje (codigo V7) (destino Bangkok) (dia_salida "2023-11-20") (transporte AVION) (duracion MEDIA) (precio BAJO) (beneficio_agencia 80))
   (Viaje (codigo V8) (destino Viena) (dia_salida "2023-12-10") (transporte AVION) (duracion CORTA) (precio MEDIO) (beneficio_agencia 100))
   (Viaje (codigo V9) (destino Kyoto) (dia_salida "2024-01-20") (transporte AVION) (duracion MEDIA) (precio ALTO) (beneficio_agencia 220))
   (Viaje (codigo V10) (destino Florencia) (dia_salida "2024-02-15") (transporte AVION) (duracion LARGA) (precio ALTO) (beneficio_agencia 300))
   (Viaje (codigo V11) (destino Cusco) (dia_salida "2024-02-18") (transporte AVION) (duracion MEDIA) (precio ALTO) (beneficio_agencia 250))
   (Viaje (codigo V12) (destino Chamonix) (dia_salida "2024-03-02") (transporte TREN) (duracion MEDIA) (precio MEDIO) (beneficio_agencia 100))
   (Viaje (codigo V13) (destino Arties) (dia_salida "2024-03-11") (transporte TREN) (duracion MEDIA) (precio BAJO) (beneficio_agencia 70))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MENSAJE DE BIENVENIDA AL SISTEMA ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; SEPARAREMOS EL PROGRAMA EN DISTINTOS MODULOS

;;; Mostrar mensaje de bienvenida

(defrule mensajeBienvenida
   (declare (salience 9999))
=>
   (printout t crlf "Bienvenido al sistema de asesoramiento de viajes." crlf)
   (printout t "Actualmente podemos aconsejarle acerca de viajes a los siguientes destinos:" crlf crlf)
   (printout t "     - Ibiza" crlf)
   (printout t "     - Cadiz" crlf)
   (printout t "     - Bali" crlf)
   (printout t "     - Cancun" crlf)
   (printout t "     - Miami" crlf)
   (printout t "     - Marrakech" crlf)
   (printout t "     - Bangkok" crlf)
   (printout t "     - Viena" crlf)
   (printout t "     - Kyoto" crlf)
   (printout t "     - Florencia" crlf)
   (printout t "     - Cusco" crlf)
   (printout t "     - Chamonix" crlf)
   (printout t "     - Arties" crlf crlf)
   (printout t "Vamos a realizarle una serie de preguntas con el fin de aconsejarle un viaje concreto." crlf)
   (printout t "Cada pregunta vendra con una serie de posibles respuestas y tendras que responder con una de ellas (da igual si usas mayusculas o minusculas)." crlf)
   (printout t "En cualquier pregunta puede responder NS (No se) si no sabe muy bien que responder (pero ten en cuenta que si no respondes una cantidad significativa de preguntas no tendre mucha informacion para poder ayudarte)." crlf)
   (printout t "Tambien puede responder FIN para obtener el destino que te aconsejo sin responder el resto de preguntas." crlf)
   (printout t "Espero que podamos ayudarte!" crlf crlf)
   (focus ModuloPreguntar)    ; Cambiamos de modulo
   (assert (ModuloActivo ModuloPreguntar))      ; Hecho que activa el modulo del sistema para realizarle las preguntas al usuario
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   PREGUNTAS DEL SISTEMA (CON CHECKEOS)   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule ModuloPreguntar 
   (export ?ALL)
   (import MAIN ?ALL)
)

(deffacts Preguntas
   (pregunta tipo_viaje)
   (pregunta presupuesto)
   (pregunta transporte)
   (pregunta duracion)
)

;;;;;;;;;;;;;;;;;;;; TIPO DE VIAJE ;;;;;;;;;;;;;;;;;;;;

;;; Preguntar para obtener informacion acerca del tipo de viaje que le gustaria realizar al usuario

(defrule preguntaTipoViaje
   (declare (salience 9))
   (ModuloActivo ModuloPreguntar)
   ?f <- (pregunta tipo_viaje)
=>
   (retract ?f)   ; Borramos la pregunta (para no leerla mas)
   (printout t "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Pregunta 1. Que tipo de viaje le gustaria realizar?" crlf)
   (printout t "Responda (AVENTURA|RELAJANTE|CULTURAL|ROMANTICO|IGUAL|NS|FIN): " crlf)
   (assert (respuestaTipoViaje (upcase(read))))
)

;;; Comprobar que la respuesta dada por el usuario es valida

(defrule comprobarRespuestaTipoViaje
   (declare (salience 999))
   (ModuloActivo ModuloPreguntar)
   ?f <- (respuestaTipoViaje ?r)
   (test (and (neq ?r AVENTURA) (neq ?r RELAJANTE) (neq ?r CULTURAL) (neq ?r ROMANTICO) (neq ?r IGUAL) (neq ?r NS) (neq ?r FIN)))   ; No se ha introducido una respuesta correcta
=>
   (retract ?f)   ; Quitamos la respuesta no valida dada por el usuario 
   (printout t crlf "Respuesta no valida. Responda de nuevo. " crlf crlf)
   (assert (pregunta tipo_viaje))   ; Preguntamos de nuevo
)

;;; Comprobar si la respuesta dada por el usuario ha sido FIN. En tal caso, parar de preguntar al usuario

(defrule comprobarFinTipoViaje
   (declare (salience 1000)) 
   ?f <-(ModuloActivo ModuloPreguntar)
   ?g <- (respuestaTipoViaje FIN)
=> 
   (focus ModuloElegirViaje)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloElegirViaje))    ; Hecho que activa el modulo del sistema para elegir los viajes mas adecuados para el usuario
   (retract ?f ?g)
)

;;;;;;;;;;;;;;;;;;;; PRESUPUESTO ;;;;;;;;;;;;;;;;;;;;

;;; Preguntar para obtener informacion acerca del presupuesto del que dispone el usuario para el viaje

(defrule preguntaPresupuesto
   (declare (salience 8))
   (ModuloActivo ModuloPreguntar)
   ?f <- (pregunta presupuesto)
=>
   (retract ?f)   ; Borramos la pregunta (para no leerla mas)
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Pregunta 2. Cual es el presupuesto del que dispone?" crlf)
   (printout t "Responda (BAJO|MEDIO|ALTO|NS|FIN) donde: " crlf)
   (printout t "     - BAJO seria un presupuesto menor a 1000 euros." crlf)
   (printout t "     - MEDIO seria un presupuesto entre 1000 euros y 2000 euros (ambos incluidos)." crlf)
   (printout t "     - ALTO seria un presupuesto mayor a 2000 euros." crlf)
   (assert (respuestaPresupuesto (upcase(read))))
)

;;; Comprobar que la respuesta dada por el usuario es valida

(defrule comprobarRespuestaPresupuesto
   (declare (salience 999))
   (ModuloActivo ModuloPreguntar)
   ?f <- (respuestaPresupuesto ?r)
   (test (and (neq ?r BAJO) (neq ?r MEDIO) (neq ?r ALTO) (neq ?r NS) (neq ?r FIN)))   ; No se ha introducido una respuesta correcta
=>
   (retract ?f)   ; Quitamos la respuesta no valida dada por el usuario 
   (printout t crlf "Respuesta no valida. Responda de nuevo. " crlf crlf)
   (assert (pregunta presupuesto))  ; Preguntamos de nuevo
)

;;; Comprobar si la respuesta dada por el usuario ha sido FIN. En tal caso, parar de preguntar al usuario

(defrule comprobarFinPresupuesto
   (declare (salience 1000)) 
   ?f <-(ModuloActivo ModuloPreguntar)
   ?g <- (respuestaPresupuesto FIN)
=>
   (focus ModuloElegirViaje)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloElegirViaje))    ; Hecho que activa el modulo del sistema para elegir los viajes mas adecuados para el usuario
   (retract ?f ?g)
)

;;;;;;;;;;;;;;;;;;;; TRANSPORTE ;;;;;;;;;;;;;;;;;;;;

;;; Preguntar para obtener informacion acerca del transporte en el que le gustaria viajar al usuario

(defrule preguntaTransporte
   (declare (salience 7))
   (ModuloActivo ModuloPreguntar)
   ?f <- (pregunta transporte)
=>
   (retract ?f)   ; Borramos la pregunta (para no leerla mas)
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Pregunta 3. En que transporte le gustaria viajar?" crlf)
   (printout t "Responda (COCHE|TREN|AVION|CRUCERO|IGUAL|NS|FIN): " crlf)
   (assert (respuestaTransporte (upcase(read))))
)

;;; Comprobar que la respuesta dada por el usuario es valida

(defrule ComprobarRespuestaTransporte
   (declare (salience 999))
   (ModuloActivo ModuloPreguntar)
   ?f <- (respuestaTransporte ?r)
   (test (and (neq ?r COCHE) (neq ?r TREN) (neq ?r AVION) (neq ?r CRUCERO) (neq ?r IGUAL) (neq ?r NS) (neq ?r FIN)))    ; No se ha introducido una respuesta correcta
=>
   (retract ?f)   ; Quitamos la respuesta no valida dada por el usuario 
   (printout t crlf "Respuesta no valida. Responda de nuevo. " crlf crlf)
   (assert (pregunta transporte))  ; Preguntamos de nuevo
)

;;; Comprobar si la respuesta dada por el usuario ha sido FIN. En tal caso, parar de preguntar al usuario

(defrule comprobarFinTransporte
   (declare (salience 1000)) 
   ?f <-(ModuloActivo ModuloPreguntar)
   ?g <- (respuestaTransporte FIN)
=>
   (focus ModuloElegirViaje)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloElegirViaje))    ; Hecho que activa el modulo del sistema para elegir los viajes mas adecuados para el usuario
   (retract ?f ?g)
)

;;;;;;;;;;;;;;;;;;;; DURACION DEL VIAJE ;;;;;;;;;;;;;;;;;;;;

;;; Preguntar para obtener informacion acerca de la duracion ideal del viaje para el usuario

(defrule preguntaDuracion
   (declare (salience 6))
   (ModuloActivo ModuloPreguntar)
   ?f <- (pregunta duracion)
=>
   (retract ?f)   ; Borramos la pregunta (para no leerla mas)
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Pregunta 4. Cual seria su duracion ideal del viaje?" crlf)
   (printout t "Responda (CORTA|MEDIA|LARGA|IGUAL|NS|FIN) donde: " crlf)
   (printout t "     - CORTA seria una duracion menor a 8 dias." crlf)
   (printout t "     - MEDIA seria una duracion entre 8 y 12 dias (ambos incluidos)." crlf)
   (printout t "     - LARGA seria una duracion mayor a 12 dias." crlf)
   (assert (respuestaDuracion (upcase(read))))
)

;;; Comprobar que la respuesta dada por el usuario es valida

(defrule ComprobarRespuestaDuracion
   (declare (salience 999))
   (ModuloActivo ModuloPreguntar)
   ?f <- (respuestaDuracion ?r)
   (test (and (neq ?r CORTA) (neq ?r MEDIA) (neq ?r LARGA) (neq ?r IGUAL) (neq ?r NS) (neq ?r FIN)))    ; No se ha introducido una respuesta correcta
=>
   (retract ?f)   ; Quitamos la respuesta no valida dada por el usuario 
   (printout t crlf "Respuesta no valida. Responda de nuevo. " crlf crlf)
   (assert (pregunta duracion))  ; Preguntamos de nuevo
)

;;; Comprobar si la respuesta dada por el usuario ha sido FIN. En tal caso, parar de preguntar al usuario

(defrule comprobarFinDuracion
   (declare (salience 1000)) 
   ?f <-(ModuloActivo ModuloPreguntar)
   ?g <- (respuestaDuracion FIN)
=>
   (focus ModuloElegirViaje)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloElegirViaje))    ; Hecho que activa el modulo del sistema para elegir los viajes mas adecuados para el usuario
   (retract ?f ?g)
)

;;;;;;;;;;;;;;;;;;;; FIN DE LAS PREGUNTAS ;;;;;;;;;;;;;;;;;;;;

;;; Comprobamos que no haya mas preguntas para realizarle al usuario

(defrule finPreguntas
   ?f <- (ModuloActivo ModuloPreguntar)
   (not (pregunta ?))
=>
   (focus ModuloElegirViaje)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloElegirViaje))    ; Hecho que activa el modulo del sistema para elegir los viajes mas adecuados para el usuario
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     VIAJES ADECUADOS     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule ModuloElegirViaje 
   (export ?ALL) 
   (import ModuloPreguntar ?ALL) 
   (import MAIN ?ALL)
)

;;; Si el usuario escribe FIN antes de responder todas las preguntas, entonces habra algunas preguntas sin respuesta
;;; En tal caso, consideramos que la respuesta a dichas preguntas sin contestar son NS

(defrule asignarRespuestaTipoViaje
   (not (respuestaTipoViaje ?r))
=>
   (assert (respuestaTipoViaje NS))
)

(defrule asignarRespuestaPresupuesto
   (not (respuestaPresupuesto ?r))
=>
   (assert (respuestaPresupuesto NS))
)

(defrule asignarRespuestaTransporte 
   (not (respuestaTransporte ?r))
=>
   (assert (respuestaTransporte NS))
)

(defrule asignarRespuestaDuracion
   (not (respuestaDuracion ?r))
=>
   (assert (respuestaDuracion NS))
)

;;; Introduccion de distintos hechos que sabemos por el conocimiento experto de los viajes que se ofertan

;;; Un destino puede ser de tipo AVENTURA, RELAJANTE, CULTURAL O ROMANTICO
(deftemplate TipoDestino
   (slot cod_destino)
	(slot tipo) 
)

(deffacts Destinos
    (TipoDestino (cod_destino V1) (tipo ROMANTICO))
    (TipoDestino (cod_destino V2) (tipo RELAJANTE))
    (TipoDestino (cod_destino V3) (tipo AVENTURA))
    (TipoDestino (cod_destino V4) (tipo ROMANTICO))
    (TipoDestino (cod_destino V5) (tipo RELAJANTE))
    (TipoDestino (cod_destino V6) (tipo AVENTURA))
    (TipoDestino (cod_destino V7) (tipo CULTURAL))
    (TipoDestino (cod_destino V8) (tipo ROMANTICO))
    (TipoDestino (cod_destino V9) (tipo CULTURAL))
    (TipoDestino (cod_destino V10) (tipo ROMANTICO))
    (TipoDestino (cod_destino V11) (tipo AVENTURA))
    (TipoDestino (cod_destino V12) (tipo CULTURAL))
    (TipoDestino (cod_destino V13) (tipo AVENTURA))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     VIAJES ADECUADOS     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Para recomendar un viaje a un usuario vamos a dar una respuesta u otra dependiendo de si disponemos de
;;; toda la informacion (es decir, el usuario ha respondido de forma concreta a todas las preguntas) o
;;; si hay falta de informacion (es decir, que no se hayan contestado esas preguntas o se haya contestado un "NS")

;;;;;;;;;;;;;;;;;;;;  DISPONEMOS DE TODA LA INFORMACION ;;;;;;;;;;;;;;;;;;;;

(defrule recomendarInformacionCompleta       ; Ofertamos los viajes que tengan las mismas caracteristicas que las respuestas dadas por el usuario a las preguntas
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Le recomendamos el viaje a " ?dest " debido a que se adapta exactamente a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;  HAY UNA RESPUESTA CON NS (FALTA DE INFORMACION)  ;;;;;;;;;;;;;;;;;;;;

;;; No sabemos la preferencia del usuario con respecto al tipo de viaje

(defrule recomendarSinInformacionDEST     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -1))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por el tipo de viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos el presupuesto del usuario

(defrule recomendarSinInformacionPRE     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -1))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto NS)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su presupuesto, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto al tipo de transporte

(defrule recomendarSinInformacionTRANSP     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -1))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte NS)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por el tipo de transporte, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto a la duracion del viaje

(defrule recomendarSinInformacionDUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -1))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por la duracion del viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;  HAY DOS RESPUESTAS CON NS (FALTA DE INFORMACION)  ;;;;;;;;;;;;;;;;;;;;

;;; No sabemos la preferencia del usuario con respecto al tipo de viaje ni su presupuesto

(defrule recomendarSinInformacionDEST_PRE     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto NS)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por el tipo de viaje ni su presupuesto, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto al tipo de viaje ni con respecto al tipo de transporte

(defrule recomendarSinInformacionDEST_TRANSP     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte NS)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por el tipo de viaje ni el tipo de transporte, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto al tipo de viaje ni con respecto a la duracion del viaje

(defrule recomendarSinInformacionDEST_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su preferencia por el tipo de viaje ni la duracion del viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos ni el presupuesto del usuario ni su preferencia con respecto al tipo de transporte

(defrule recomendarSinInformacionPRE_TRANSP     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto NS)
   (respuestaTransporte NS)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su presupuesto ni su preferencia con respecto al tipo de transporte, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos ni el presupuesto del usuario ni su preferencia con respecto a la duracion del viaje

(defrule recomendarSinInformacionPRE_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto NS)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su presupuesto ni su preferencia con respecto a la duracion del viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto al tipo de transporte ni con respecto a la duracion del viaje

(defrule recomendarSinInformacionTRANSP_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -2))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte NS)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
=>
   (bind ?mot (str-cat "Aunque no haya podido encajar informacion acerca de su presupuesto ni su preferencia con respecto a la duracion del viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;  HAY TRES RESPUESTAS CON NS (FALTA DE INFORMACION)  ;;;;;;;;;;;;;;;;;;;;

;;; No sabemos el presupuesto del usuario ni su preferencia con respecto al tipo de viaje ni con respecto al tipo de transporte

(defrule recomendarSinInformacionDEST_PRE_TRANSP     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -3))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto NS)
   (respuestaTransporte NS)
   (respuestaDuracion ?resp_duracion)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_duracion IGUAL) (or (eq ?resp_duracion ?dur) (and (eq ?resp_duracion MEDIA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur CORTA) (and (eq ?resp_duracion LARGA) (eq ?dur MEDIA)))))))
=>
   (bind ?mot (str-cat "Aunque solo se haya podido encajar informacion acerca de su preferencia con respecto a la duracion del viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos el presupuesto del usuario ni su preferencia con respecto al tipo de viaje ni con respecto a la duracion del viaje

(defrule recomendarSinInformacionDEST_PRE_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -3))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto NS)
   (respuestaTransporte ?resp_transporte)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_transporte ?transp) (eq ?resp_transporte IGUAL)))
=>
   (bind ?mot (str-cat "Aunque solo se haya podido encajar informacion acerca de su preferencia con respecto al tipo de transporte, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos la preferencia del usuario con respecto al tipo de viaje ni con respecto al tipo de transporte ni con respecto a la duracion del viaje

(defrule recomendarSinInformacionDEST_TRANSP_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -3))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje NS)
   (respuestaPresupuesto ?resp_presupuesto)
   (respuestaTransporte NS)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_presupuesto ?pre) (and (eq ?resp_presupuesto MEDIO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre BAJO) (and (eq ?resp_presupuesto ALTO) (eq ?pre MEDIO))))))
=>
   (bind ?mot (str-cat "Aunque solo se haya podido encajar informacion acerca de su presupuesto, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;; No sabemos el presupuesto del usuario ni su preferencia con respecto al tipo de transporte ni con respecto a la duracion del viaje

(defrule recomendarSinInformacionPRE_TRANSP_DUR     ; Ofertamos los viajes que mas se aproximen a las respuestas que si haya concretado el usuario en las preguntas
   (declare (salience -3))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (respuestaTipoViaje ?resp_tipo_viaje)
   (respuestaPresupuesto NS)
   (respuestaTransporte NS)
   (respuestaDuracion NS)
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
   (test (or (eq ?resp_tipo_viaje ?tipo_destino) (eq ?resp_tipo_viaje IGUAL)))
=>
   (bind ?mot (str-cat "Aunque solo se haya podido encajar informacion acerca de su preferencia con respecto al tipo de viaje, 
    Le recomendamos el viaje a " ?dest " debido a que se adapta bien a sus necesidades. 
    El destino es " ?tipo_destino ", tiene un precio " ?pre ", el transporte sera en " ?transp " y tendra una duracion " ?dur "."))
   (assert (Adecuado (codigo ?cod) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;  LAS CUATRO PREGUNTAS HAN SIDO RESPONDIDAS CON NS (NINGUNA INFORMACION)  ;;;;;;;;;;;;;;;;;;;;

;;; En tal caso, elegimos el viaje a Cadiz como viaje por defecto

(defrule recomendarSinNingunaInformacion
   (declare (salience -4))
   ?f <- (ModuloActivo ModuloElegirViaje)
   (not (Adecuado (codigo ?cod) (motivo ?mot)))
=>
   (bind ?mot "Lo sentimos, no hemos encontrado ningun viaje que le podamos recomendar en base a tus respuestas (quizas por falta de precision en tus respuestas o porque no disponemos actualmente de ningun viaje que se ajuste bien a tus necesidades)
    Le recomendamos repetir el proceso pero ahora siendo mas concreto en sus respuestas o intentando responder algo diferente a lo anterior en alguna de las preguntas.
    Sin embargo, le recomendamos el siguiente viaje, el cual le podria interesar por su gran popularidad.")
   (assert (Adecuado (codigo V2) (motivo ?mot)))
   (focus ModuloResultados)     ; Cambiamos de modulo
   (assert (ModuloActivo ModuloResultados))     ; Hecho que activa el modulo del sistema para mostrar finalmente los viajes mas adecuados para el usuario
   (retract ?f)

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;        RESULTADOS        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule ModuloResultados 
   (export ?ALL) 
   (import ModuloPreguntar ?ALL) 
   (import ModuloElegirViaje ?ALL)
   (import MAIN ?ALL) 
)

(defrule mostrarViajeRecomendado
   (ModuloActivo ModuloResultados)
   (Adecuado (codigo ?cod) (motivo ?mot))
   (Viaje (codigo ?cod) (destino ?dest) (transporte ?transp) (duracion ?dur) (precio ?pre))
   (TipoDestino (cod_destino ?cod) (tipo ?tipo_destino))
=>
   (assert (Ofertar (codigo ?cod)))     ; Se va a ofertar el viaje con codigo ?cod
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t ?mot crlf crlf)
   (printout t "Las caracteristicas del viaje recomendado son las siguientes: " crlf)
   (printout t "     - Nombre del destino: " ?dest crlf)
   (printout t "     - Tipo de destino: " ?tipo_destino crlf)
   (printout t "     - Precio: " ?pre crlf)
   (printout t "     - Transporte: " ?transp crlf)
   (printout t "     - Duracion del viaje: " ?dur crlf crlf)
   (printout t "Rechazas o aceptas? Si acepta, el proceso de recomendacion finalizara." crlf)
   (printout t "En caso de RECHAZAR, escriba la caracteristica del viaje por el cual lo rechaza (tipodestino|precio|transporte|duracion)." crlf )
   (printout t "En caso de ACEPTAR, escriba la letra (A)." crlf)          
   (assert (respuestaFinal (lowcase(read))))
)

(defrule aceptar
   (ModuloActivo ModuloResultados)
   (respuestaFinal ?respuesta)
   (Ofertar (codigo ?cod_destino))
   (test (eq ?respuesta a))
=>
   (assert (Aceptado (codigo ?cod_destino)))
	(printout t crlf "Recomendacion de viaje aceptada. Gracias por confiar en nosotros!" crlf crlf)
)

(defrule rechazarTipoViaje
   ?h <- (ModuloActivo ModuloResultados)
   ?r <- (respuestaFinal ?respuesta)
   ?o <- (Ofertar (codigo ?cod_destino))
   ?f <- (Viaje (codigo ?cod_destino))
   ?g <- (respuestaTipoViaje ?tipo_viaje)
   (test (eq ?respuesta tipodestino))
=>
   (assert(Rechazado (codigo ?cod_destino) (motivo tipodestino)))
   (printout t "Que tipo de destino le gustaria? (AVENTURA|RELAJANTE|CULTURAL|ROMANTICO|IGUAL|NS)" crlf)
   (assert (ModuloActivo ModuloElegirViaje))
   (retract ?f ?h ?r ?o ?g)     ; Borramos el viaje que no le ha gustado y pasamos al modulo para elegir otro viaje para recomendarselo al usuario
   (assert (respuestaTipoViaje (upcase(read))))
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Eligiendo otro viaje para recomendar..." crlf)
)

(defrule rechazarPresupuesto
   ?h <- (ModuloActivo ModuloResultados)
   ?r <- (respuestaFinal ?respuesta)
   ?o <- (Ofertar (codigo ?cod_destino))
   ?f <- (Viaje (codigo ?cod_destino))
   ?g <- (respuestaPresupuesto ?pre)
   (test (eq ?respuesta presupuesto))
=>
   (assert(Rechazado (codigo ?cod_destino) (motivo presupuesto)))
   (printout t "Que precio le gustaria que tuviera el viaje? (BAJO|MEDIO|ALTO|NS)" crlf)
   (assert (ModuloActivo ModuloElegirViaje))
   (retract ?f ?h ?r ?o ?g)     ; Borramos el viaje que no le ha gustado y pasamos al modulo para elegir otro viaje para recomendarselo al usuario
   (assert (respuestaPresupuesto (upcase(read))))
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Eligiendo otro viaje para recomendar..." crlf)
)

(defrule rechazarTransporte
   ?h <- (ModuloActivo ModuloResultados)
   ?r <- (respuestaFinal ?respuesta)
   ?o <- (Ofertar (codigo ?cod_destino))
   ?f <- (Viaje (codigo ?cod_destino))
   ?g <- (respuestaTransporte ?transp)
   (test (eq ?respuesta transporte))
=>
   (assert(Rechazado (codigo ?cod_destino) (motivo transporte)))
   (printout t "Que transporte le gustaria que tuviera el viaje? (COCHE|TREN|AVION|CRUCERO|IGUAL|NS)" crlf)
   (assert (ModuloActivo ModuloElegirViaje))
   (retract ?f ?h ?r ?o ?g)     ; Borramos el viaje que no le ha gustado y pasamos al modulo para elegir otro viaje para recomendarselo al usuario
   (assert (respuestaTransporte (upcase(read))))
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Eligiendo otro viaje para recomendar..." crlf)
)

(defrule rechazarDuracion
   ?h <- (ModuloActivo ModuloResultados)
   ?r <- (respuestaFinal ?respuesta)
   ?o <- (Ofertar (codigo ?cod_destino))
   ?f <- (Viaje (codigo ?cod_destino))
   ?g <- (respuestaDuracion ?dur)
   (test (eq ?respuesta duracion))
=>
   (assert(Rechazado (codigo ?cod_destino) (motivo duracion)))
   (printout t "Que duracion le gustaria que tuviera el viaje? (CORTA|MEDIA|LARGA|IGUAL|NS)" crlf)
   (assert (ModuloActivo ModuloElegirViaje))
   (retract ?f ?h ?r ?o ?g)     ; Borramos el viaje que no le ha gustado y pasamos al modulo para elegir otro viaje para recomendarselo al usuario
   (assert (respuestaDuracion (upcase(read))))
   (printout t crlf "-------------------------------------------------------------------------------------------------------------------------" crlf crlf)
   (printout t "Eligiendo otro viaje para recomendar..." crlf)
)