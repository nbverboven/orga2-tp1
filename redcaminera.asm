extern free
extern malloc

%define    NULL 0

%define    tam_lista 20
%define    lista_offset_longitud 0
%define    lista_offset_primero 4
%define    lista_offset_ultimo 12

%define    tam_nodo 32
%define    nodo_offset_func_borrar 0
%define    nodo_offset_dato 8
%define    nodo_offset_siguiente 16
%define    nodo_offset_anterior 24

%define    tam_ciudad 16
%define    ciudad_offset_nombre 0
%define    ciudad_offset_poblacion 8

%define    tam_ruta 24
%define    ruta_offset_ciudad_A 0
%define    ruta_offset_distancia 8
%define    ruta_offset_ciudad_B 16

%define    tam_red_caminera 24
%define    red_caminera_offset_ciudades 0
%define    red_caminera_offset_rutas 8
%define    red_caminera_offset_nombre 16


; LISTA 

global l_crear
l_crear:
	push    rbp
	mov     rbp, rsp

	mov     rdi, tam_lista
	call    malloc
	cmp     rax, NULL
	je      fin_l_crear
	
	mov     dword[rax + lista_offset_longitud], 0      ; Inicializo el tamaño en 0
	mov     qword[rax + lista_offset_primero], NULL    ; Inicializo los punteros en NULL
	mov     qword[rax + lista_offset_ultimo], NULL

	fin_l_crear:
		pop     rbp
		ret


global l_agregarAdelante
l_agregarAdelante:
; RDI := lista** l, RSI := void* dato, RDX := void (*func_borrar) (void*)
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14                                            ; Armo la pila y la alineo

	cmp     rdi, NULL
	je      fin_l_agregarAdelante

	mov     r12, [rdi]                                     ; Guardo el puntero a la lista en r12
	cmp     r12, NULL
	je      fin_l_agregarAdelante

	mov     r14, rsi                                       ; Guardo el puntero al dato en r14
	mov     rbx, rdx                                       ; Guardo el puntero a func_borrar en rbx
	mov     rdi, tam_nodo
	call    malloc                                         ; Reservo memoria del tamaño del nodo
	cmp     rax, NULL
	je      fin_l_agregarAdelante

	mov     r13, [r12 + lista_offset_primero]              ; Guardo en r13 la dirección del primer nodo de la lista
	mov     [rax + nodo_offset_func_borrar], rbx           ; Inicializo la función de borrado
	mov     [rax + nodo_offset_dato], r14                  ; Inicializo el puntero al dato
	mov     [rax + nodo_offset_siguiente], r13             ; Actualizo el siguiente del nuevo nodo
	mov     qword[rax + nodo_offset_anterior], NULL        ; Inicializo el nodo anterior en NULL

	mov     ecx, [r12 + lista_offset_longitud]
	add     ecx, 1
	mov     [r12 + lista_offset_longitud], ecx             ; Actualizo el tamaño de la lista
	mov     [r12 + lista_offset_primero], rax              ; Actualizo el primero de la lista
	mov     r8, [r12 + lista_offset_ultimo]
	cmp     r8, NULL                                       ; Veo si la lista ya tenía algún elemento
	je      caso_lista_vacia_agregarAdelante
	mov     [r13 + nodo_offset_anterior], rax              ; El anterior del que era primero es el nuevo nodo (si la lista no era vacía)
	jmp     fin_l_agregarAdelante

	caso_lista_vacia_agregarAdelante:
		mov     [r12 + lista_offset_ultimo], rax           ; El último es el primero si la lista estaba vacía

	fin_l_agregarAdelante:
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp                                        ; Restauro la pila
		ret


global l_agregarAtras
l_agregarAtras:
; RDI := lista** l, RSI := void* dato, RDX := void (*func_borrar) (void*)
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14                                             ; Armo la pila y la alineo

	cmp     rdi, NULL
	je      fin_l_agregarAtras

	mov     r12, [rdi]                                      ; Guardo el puntero a la lista en r12
	cmp     r12, NULL
	je      fin_l_agregarAtras

	mov     r14, rsi                                        ; Guardo el puntero al dato en r14
	mov     rbx, rdx                                        ; Guardo el puntero a func_borrar en rbx
	mov     rdi, tam_nodo
	call    malloc                                          ; Reservo memoria del tamaño del nodo
	cmp     rax, NULL
	je      fin_l_agregarAtras

	mov     r13, [r12 + lista_offset_ultimo]                ; Guardo en r13 la dirección del último nodo de la lista
	mov     [rax + nodo_offset_func_borrar], rbx            ; Inicializo la función de borrado
	mov     [rax + nodo_offset_dato], r14                   ; Inicializo el puntero al dato
	mov     qword[rax + nodo_offset_siguiente], NULL        ; Inicializo el nodo siguiente en NULL
	mov     [rax + nodo_offset_anterior], r13               ; Actualizo el anterior del nuevo nodo

	mov     ecx, [r12 + lista_offset_longitud]
	add     ecx, 1
	mov     [r12 + lista_offset_longitud], ecx              ; Actualizo el tamaño de la lista
	mov     [r12 + lista_offset_ultimo], rax                ; Actualizo el último de la lista
	mov     r8, [r12 + lista_offset_primero]
	cmp     r8, NULL                                        ; Veo si la lista ya tenía algún elemento
	je      caso_lista_vacia_agregarAtras
	mov     [r13 + nodo_offset_siguiente], rax              ; El siguiente del que era último es el nuevo nodo (si la lista no era vacía)
	jmp     fin_l_agregarAtras

	caso_lista_vacia_agregarAtras:
		mov     [r12 + lista_offset_primero], rax           ; El último es el primero si la lista estaba vacía 

	fin_l_agregarAtras:
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp                                         ; Restauro la pila
		ret


global l_agregarOrdenado
l_agregarOrdenado:
; RDI := lista** l, RSI := void* dato, RDX := void (*func_borrar) (void*), RCX := int (*func_cmp)(void*,void*))
	push    rbp
	mov     rbp, rsp
	sub     rsp, 8
	push    rbx
	push    r12
	push    r13
	push    r14
	push    r15

	cmp     rdi, NULL
	je      fin_l_agregarOrdenado
	cmp     rcx, NULL
	je      fin_l_agregarOrdenado

	mov     r12, rdi
	mov     r8, [r12]                                         ; Guardo el puntero a la lista en r8                                  
	mov     r13, rsi                                          ; Guardo el puntero al dato en r13
	mov     r14, rdx                                          ; Guardo el puntero a func_borrar en r14
	mov     rbx, rcx

	mov     r15, [r8 + lista_offset_primero]                  ; actual = l->primero

	ciclo_busco_donde_insertar_agregarOrdenado:
		cmp     r15, NULL
		je      mayor_que_todos_agregarOrdenado
		mov     rdi, r13
		mov     rsi, [r15 + nodo_offset_dato]
		call    rbx                                            ; Comparo el dato con el del nodo actual
		cmp     eax, 1
		je      agrego_adelante_del_actual_agregarOrdenado     ; Si el dato es igual o menor, agrego en ese lugar
		cmp     eax, 0
		je      agrego_adelante_del_actual_agregarOrdenado
		mov     r15, [r15 + nodo_offset_siguiente]             ; actual = actual->siguiente
		jmp     ciclo_busco_donde_insertar_agregarOrdenado

	agrego_adelante_del_actual_agregarOrdenado:
		mov     rbx, [r15 + nodo_offset_anterior]
		cmp     rbx, NULL
		je      agrego_al_principio_agregarOrdenado            ; Si tengo que agregar antes del primero, llamo a l_agregarAdelante

		mov     rdi, tam_nodo
		call    malloc
		cmp     rax, NULL                                      ; Reservo memoria para un nodo
		je      fin_l_agregarOrdenado

		mov     [rax + nodo_offset_dato], r13
		mov     [rax + nodo_offset_func_borrar], r14
		mov     [rax + nodo_offset_anterior], rbx
		mov     [rax + nodo_offset_siguiente], r15             ; Inicializo los campos del nodo

		mov     [rbx + nodo_offset_siguiente], rax
		mov     [r15 + nodo_offset_anterior], rax              ; Actualizo el anterior y el siguiente del nuevo nodo

		mov     r8, [r12]
		mov     ecx, [r8 + lista_offset_longitud]
		inc     ecx
		mov     [r8 + lista_offset_longitud], ecx              ; Actualizo la longitud de la lista

		jmp     fin_l_agregarOrdenado

	agrego_al_principio_agregarOrdenado:
		mov     rdi, r12
		mov     rsi, r13
		mov     rdx, r14
		call    l_agregarAdelante
		jmp     fin_l_agregarOrdenado

	mayor_que_todos_agregarOrdenado:
		mov     rdi, r12
		mov     rsi, r13
		mov     rdx, r14
		call    l_agregarAtras

	fin_l_agregarOrdenado:
		pop     r15
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		add     rsp, 8
		pop     rbp
		ret


global l_borrarTodo
l_borrarTodo:
; RDI := lista* l
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	sub     rsp, 8

	cmp     rdi , NULL
	je      fin_l_borrarTodo

	mov     r12, rdi                                          ; Libero rdi porque lo voy a usar después
	mov     r13, [r12 + lista_offset_primero]                 ; (r13 == actual) = l->primero

	ciclo_l_borrarTodo:
		cmp     r13, NULL
		je      fin_l_borrarTodo
		cmp     qword[r13 + nodo_offset_func_borrar], NULL    ; Veo si está definida la función borrar para el nodo
		jne     borrar_nodo
		mov     r13, [r13 + nodo_offset_siguiente]            ; proximo = actual->siguiente
		jmp     ciclo_l_borrarTodo

	borrar_nodo:
		mov     rdi, [r13 + nodo_offset_dato]
		call    [r13 + nodo_offset_func_borrar]               ; Borro el dato del nodo actual
		mov     rbx, [r13 + nodo_offset_siguiente]            ; proximo = actual->siguiente
		mov     rdi, r13
		mov     r13, rbx                                      ; actual = proximo
		call    free                                          ; Libero la memoria ocupada por el nodo
		jmp     ciclo_l_borrarTodo

	fin_l_borrarTodo:
		mov     rdi, r12                                      ; Traigo a rdi el puntero a la lista que me pasaron como parámetro
		call    free

		add     rsp, 8
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


; CIUDAD

global c_crear
c_crear:
; RDI := char* nombre, RSI := uint64_t poblacion
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	sub     rsp, 8

	mov     rbx, rdi                                ; Libero rdi para poder usarlo. Guardo el nombre en rbx
	mov     r12, rsi                                ; Porque, aparentemente, malloc me pisa rsi

	mov     rdi, tam_ciudad
	call    malloc
	cmp     rax, NULL
	je      fin_c_crear

	mov     r13, rax                                ; Guardo el puntero a la ciudad en r13

	mov     rdi, rbx
	call    str_copy                                ; Hago una copia del nombre
	cmp     rax, NULL
	je      fin_c_crear

	mov     [r13 + ciudad_offset_nombre], rax       ; Completo el nombre
	mov     [r13 + ciudad_offset_poblacion], r12    ; Completo la población
	mov     rax, r13

	fin_c_crear:
		add     rsp, 8
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


global c_cmp
c_cmp:
; RDI := ciudad* c1, RSI := ciudad* c2
	push    rbp
	mov     rbp, rsp

	mov     rdi, [rdi + ciudad_offset_nombre]
	mov     rsi, [rsi + ciudad_offset_nombre]
	call    str_cmp

	pop     rbp
	ret


global c_borrar
c_borrar:
; RDI := ciudad* c
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12

	mov     rbx, rdi                             ; Guardo el puntero a la ciudad
	mov     rdi, [rbx + ciudad_offset_nombre]
	call    free                                 ; Borro el nombre
	mov     rdi, rbx
	call    free                                 ; Borro la ciudad

	pop     r12
	pop     rbx
	pop     rbp
	ret


; RUTA

global r_crear
r_crear:
; RDI := ciudad* c1, RSI := ciudad* c2, XMM0 := double distancia
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13

	cmp     rdi, NULL
	je      fin_r_crear
	cmp     rsi, NULL
	je      fin_r_crear

	mov     r12, rdi                                  ; Guardo c1 en r12
	mov     r13, rsi                                  ; Guardo c2 en r13

	call    c_cmp
	cmp     rax, 0
	je      fin_r_crear                               ; Si las dos ciudades son iguales, no creo la ruta
	cmp     rax, 1
	je      primero_c1_r_crear                        ; Veo en qué orden agrego las ciudades

	mov     rdi, tam_ruta
	call    malloc                                    ; Reservo memoria para la ruta
	cmp     rax, NULL
	je      fin_r_crear

	movq    [rax + ruta_offset_distancia], xmm0        ; Inicializo la distancia
	mov     [rax + ruta_offset_ciudad_A], r13
	mov     [rax + ruta_offset_ciudad_B], r12
	jmp     fin_r_crear

	primero_c1_r_crear:
		mov     rdi, tam_ruta
		call    malloc                                ; Reservo memoria para la ruta
		cmp     rax, NULL
		je      fin_r_crear

		movq    [rax + ruta_offset_distancia], xmm0    ; Inicializo la distancia
		mov     [rax + ruta_offset_ciudad_A], r12
		mov     [rax + ruta_offset_ciudad_B], r13

	fin_r_crear:
		pop     r13
		pop     r12
		pop     rbp
		ret


global r_cmp
r_cmp:
; RDI := ruta* r1, RSI := ruta* r2
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13

	cmp     rdi, NULL
	je      fin_r_cmp
	cmp     rsi, NULL
	je      fin_r_cmp

	mov     r12, rdi                                 ; Muevo la ruta 1 a r12
	mov     r13, rsi                                 ; Muevo la ruta 2 a r13
	mov     rdi, [r12 + ruta_offset_ciudad_A]
	mov     rsi, [r13 + ruta_offset_ciudad_A]
	call    c_cmp                                    ; Comparo la primera ciudad de ambas rutas
	cmp     rax, 0
	je      primera_ciudad_igual
	jmp     fin_r_cmp

	primera_ciudad_igual:
		mov     rdi, [r12 + ruta_offset_ciudad_B]    
		mov     rsi, [r13 + ruta_offset_ciudad_B]
		call    c_cmp                                ; Comparo la segunda ciudad de ambas rutas 

	fin_r_cmp:
		pop     r13
		pop     r12
		pop     rbp
		ret


global r_borrar
r_borrar:
; RDI := ruta* r
	push    rbp
	mov     rbp, rsp

	call    free

	pop     rbp
	ret


; RED CAMINERA

global rc_crear
rc_crear:
; RDI := char* nombre
	push    rbp
	mov     rbp, rsp
	sub     rsp, 8
	push    r12
	push    r13
	push    r14

	mov     r12, rdi

	mov     rdi, tam_red_caminera
	call    malloc
	cmp     rax, NULL
	je      fin_rc_crear                                 ; Reservo memoria para la red caminera
	mov     r13, rax

	mov     rdi, r12
	call    str_copy                                     ; Copio el nombre
	mov     r12, rax

	mov     rdi, tam_lista
	call    l_crear                                      ; Creo una lista para las ciudades
	cmp     rax, NULL
	je      fin_rc_crear
	mov     r14, rax

	mov     rdi, tam_lista
	call    l_crear                                      ; Creo una lista para las rutas
	cmp     rax, NULL
	je      fin_rc_crear

	mov     [r13 + red_caminera_offset_ciudades], r14
	mov     [r13 + red_caminera_offset_rutas], rax
	mov     [r13 + red_caminera_offset_nombre], r12      ; Inicializo los parámetros de la red
	mov     rax, r13                                     ; Devuelvo el puntero a la nueva red

	fin_rc_crear:
		pop     r14
		pop     r13
		pop     r12
		add     rsp, 8
		pop     rbp
		ret


global rc_agregarCiudad
rc_agregarCiudad:
; RDI := redCaminera* rc, RSI := char* nombre, RDX := uint64_t poblacion
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13
	push    r14
	push    r15

	cmp     rdi, NULL
	je      fin_rc_agregarCiudad

	mov     r12, rdi                                         ; Guardo el puntero a la red en r12
	mov     r13, rsi                                         ; Guardo el nombre en r13
	mov     r14, rdx                                         ; Guardo la población en r14

	mov     r15, [r12 + red_caminera_offset_ciudades]        ; Primero tengo que ver que la ciudad no exista
	mov     r15, [r15 + lista_offset_primero]                ; actual = rc->ciudades->primero

	ciclo_rc_agregarCiudad:
		cmp     r15, NULL                                    ; Si llego al final de la lista es porque no encontré coincidencias
		je      agrego_ciudad_rc_agregarCiudad
		mov     rdi, [r15 + nodo_offset_dato]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r13
		call    str_cmp                                      ; Comparo el nombre nuevo con el de la ciudad contenida en el nodo actual
		cmp     rax, 0
		je      fin_rc_agregarCiudad
		mov     r15, [r15 + nodo_offset_siguiente]           ; actual = actual->siguiente
		jmp     ciclo_rc_agregarCiudad

	agrego_ciudad_rc_agregarCiudad:
		mov     rdi, r13
		mov     rsi, r14
		call    c_crear                                      ; Creo una ciudad con el nombre y la población que se pasaron como parámetros
		cmp     rax, NULL
		je      fin_rc_agregarCiudad

		lea     rdi, [r12 + red_caminera_offset_ciudades]
		mov     rsi, rax
		mov     rdx, c_borrar
		mov     rcx, c_cmp
		call    l_agregarOrdenado                            ; Agrego la nueva ciudad, de forma ordenada, a la lista de ciudades de la red

	fin_rc_agregarCiudad:
		pop     r15
		pop     r14
		pop     r13
		pop     r12
		pop     rbp
		ret


global rc_agregarRuta
rc_agregarRuta:
; RDI := redCaminera* rc, RSI := char* ciudad1, RDX := char* ciudad2, XMM0 := double distancia
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14

	cmp     rdi, NULL
	je      fin_rc_agregarRuta

	mov     r12, rdi
	mov     r13, rsi
	mov     r14, rdx

	mov     rdi, r13
	mov     rsi, r14
	call    str_cmp
	cmp     eax, 0
	je      fin_rc_agregarRuta

	mov     rdi, r12
	mov     rsi, r13
	mov     rdx, r14
	call    obtenerRuta
	cmp     rax, NULL
	jne     fin_rc_agregarRuta                            ; No puedo agregar una ruta que ya exista

	agrego_ruta_rc_agregarRuta:
		mov     rdi, r12
		mov     rsi, r13
		call    obtenerCiudad
		cmp     rax, NULL
		je      fin_rc_agregarRuta
		mov     r13, rax                                  ; Reemplazo el nombre de la ciudad A por un puntero a la misma

		mov     rdi, r12
		mov     rsi, r14
		call    obtenerCiudad
		cmp     rax, NULL
		je      fin_rc_agregarRuta
		mov     r14, rax                                  ; Reemplazo el nombre de la ciudad B por un puntero a la misma

		mov     rdi, r13
		mov     rsi, r14
		call    r_crear
		cmp     rax, NULL
		je      fin_rc_agregarRuta

		lea     rdi, [r12 + red_caminera_offset_rutas]
		mov     rsi, rax
		mov     rdx, r_borrar
		mov     rcx, r_cmp
		call    l_agregarOrdenado                          ; Agrego la nueva ruta a las rutas de la red caminera

	fin_rc_agregarRuta:
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


global rc_borrarTodo
rc_borrarTodo:
; RDI := redCaminera* rc
	push    rbp
	mov     rbp, rsp
	push    r13
	sub     rsp, 8

	cmp     rdi, NULL
	je      fin_rc_borrarTodo

	mov     r13, rdi

	mov     rdi, [r13 + red_caminera_offset_rutas]
	call    l_borrarTodo                                ; Borro las rutas

	mov     rdi, [r13 + red_caminera_offset_ciudades]
	call    l_borrarTodo                                ; Borro las ciudades

	mov     rdi, [r13 + red_caminera_offset_nombre]
	call    free                                        ; Borro el nombre

	mov     rdi, r13
	call    free                                        ; Borro la red caminera

	fin_rc_borrarTodo:
		add     rsp, 8
		pop     r13
		pop     rbp
		ret


; OTRAS DE RED CAMINERA

global obtenerCiudad
obtenerCiudad:
; RDI := redCaminera* rc, RSI := char* c
	push    rbp
	mov     rbp, rsp
	sub     rsp, 8
	push    r12
	push    r13
	push    r14

	cmp     rdi, NULL
	je      fin_rc_obtenerCiudad

	mov     r12, [rdi + red_caminera_offset_ciudades]    ; Guardo las ciudades de la red en r12
	mov     r13, rsi                                     ; Guardo el nombre de la ciudad que quiero buscar en r13

	mov     r14, [r12 + lista_offset_primero]            ; actual = rc->ciudades->primero

	ciclo_obtenerCiudad:
		cmp     r14, NULL
		je      no_existe_obtenerCiudad
		mov     rdi, [r14 + nodo_offset_dato]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r13
		call    str_cmp
		cmp     rax, 0
		je      la_encontre_obtenerCiudad
		mov     r14, [r14 + nodo_offset_siguiente]
		jmp     ciclo_obtenerCiudad

	no_existe_obtenerCiudad:
		mov     rax, NULL
		jmp     fin_rc_obtenerCiudad

	la_encontre_obtenerCiudad:
		mov     rax, [r14 + nodo_offset_dato]

	fin_rc_obtenerCiudad:
		pop     r14
		pop     r13
		pop     r12
		add     rsp, 8
		pop     rbp
		ret


global obtenerRuta
obtenerRuta:
; RDI := redCaminera* rc, RSI := char* c1, RDX := char* c2
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14

	cmp     rdi, NULL
	je      fin_obtenerRuta

	mov     r12, rdi
	mov     r13, rsi
	mov     r14, rdx

	mov     rdi, r12
	mov     rsi, r13
	call    obtenerCiudad
	cmp     rax, NULL
	je      fin_obtenerRuta                                      ; Una ruta no puede contener una ciudad que no esté en la lista de ciudades

	mov     rdi, r12
	mov     rsi, r14
	call    obtenerCiudad
	cmp     rax, NULL
	je      fin_obtenerRuta

	mov     rdi, r13
	mov     rsi, r14
	call    str_cmp                                              ; Una ruta no puede contener dos ciudades iguales

	cmp     eax, 0
	je      fin_obtenerRuta
	cmp     eax, 1
	je      no_cambio_el_orden_de_las_ciudades_rc_obtenerRuta
	mov     r8, r13
	mov     r13, r14
	mov     r14, r8                                              ; Hago esto para no tener que fijarme cuándo esté haciendo la comparación

	no_cambio_el_orden_de_las_ciudades_rc_obtenerRuta:
		mov     rbx, [r12 + red_caminera_offset_rutas]
		mov     rbx, [rbx + lista_offset_primero]

	ciclo_obtenerRuta:
		cmp     rbx, NULL
		je      no_existe_rc_obtenerRuta
		mov     rdi, [rbx + nodo_offset_dato]
		mov     rdi, [rdi + ruta_offset_ciudad_A]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r13
		call    str_cmp
		cmp     eax, 0
		jne     sigo_el_ciclo_rc_obtenerRuta
		mov     rdi, [rbx + nodo_offset_dato]
		mov     rdi, [rdi + ruta_offset_ciudad_B]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r14
		call    str_cmp
		cmp     eax, 0
		je      la_encontre_rc_obtenerRuta

	sigo_el_ciclo_rc_obtenerRuta:
		mov     rbx, [rbx + nodo_offset_siguiente]
		jmp     ciclo_obtenerRuta

	no_existe_rc_obtenerRuta:
		mov     rax, NULL
		jmp     fin_obtenerRuta

	la_encontre_rc_obtenerRuta:
		mov     rax, [rbx + nodo_offset_dato]

	fin_obtenerRuta:
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


global ciudadMasPoblada
ciudadMasPoblada:
; RDI := redCaminera* rc
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13
	push    r14
	push    r15

	cmp     rdi, NULL
	je      fin_ciudadMasPoblada

	mov     r12, [rdi + red_caminera_offset_ciudades]
	mov     r13, NULL                                    ; Acá voy a guardar el resultado (res)

	mov     r14, [r12 + lista_offset_primero]
	cmp     r14, NULL
	je      fin_ciudadMasPoblada

	mov     r13, [r14 + nodo_offset_dato]
	mov     r14, [r14 + nodo_offset_siguiente]

	ciclo_ciudadMasPoblada:
		cmp     r14, NULL
		je      fin_ciudadMasPoblada
		mov     rsi, [r13 + ciudad_offset_poblacion]
		mov     r15, [r14 + nodo_offset_dato]
		cmp     rsi, [r15 + ciudad_offset_poblacion]
		je      igual_poblacion_que_res_ciudadMasPoblada
		jl      mas_poblacion_que_res_ciudadMasPoblada

	fin_ciclo_ciudadMasPoblada:
		mov     r14, [r14 + nodo_offset_siguiente]
		jmp     ciclo_ciudadMasPoblada

	igual_poblacion_que_res_ciudadMasPoblada:
		mov     rdi, r13
		mov     rsi, r14
		call    c_cmp
		cmp     rax, 1
		je     fin_ciclo_ciudadMasPoblada

	mas_poblacion_que_res_ciudadMasPoblada:
		mov     r13, [r14 + nodo_offset_dato]
		jmp     fin_ciclo_ciudadMasPoblada

	fin_ciudadMasPoblada:
		mov     rax, r13	

		pop     r15
		pop     r14
		pop     r13
		pop     r12
		pop     rbp
		ret


global rutaMasLarga
rutaMasLarga:
; RDI := redCaminera* rc
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13
	push    r14
	push    r15

	cmp     rdi, NULL
	je      fin_rutaMasLarga

	mov     r12, [rdi + red_caminera_offset_rutas]
	mov     r13, NULL                                    ; Acá voy a guardar el resultado (res)

	mov     r14, [r12 + lista_offset_primero]
	cmp     r14, NULL
	je      fin_rutaMasLarga

	mov     r13, [r14 + nodo_offset_dato]
	mov     r14, [r14 + nodo_offset_siguiente]

	ciclo_rutaMasLarga:
		cmp     r14, NULL
		je      fin_rutaMasLarga

		mov     r15, [r14 + nodo_offset_dato]

		movq    xmm1, [r13 + ruta_offset_distancia]
		cmpsd   xmm1, [r15 + ruta_offset_distancia], 0   ; CMPEQSD: Veo si lo que hay en el primer operando es igual que lo qu hay en el segundo
		movq    rcx, xmm1
		cmp     rcx, 0
		jne      igual_distancia_que_res_rutaMasLarga

		movq    xmm1, [r13 + ruta_offset_distancia]
		cmpsd   xmm1, [r15 + ruta_offset_distancia], 1   ; CMPLTSD: Veo si lo que hay en el primer operando es menor que lo qu hay en el segundo
		movq    rcx, xmm1
		cmp     rcx, 0
		jne      mas_distancia_que_res_rutaMasLarga

	fin_ciclo_rutaMasLarga:
		mov     r14, [r14 + nodo_offset_siguiente]
		jmp     ciclo_rutaMasLarga

	igual_distancia_que_res_rutaMasLarga:
		mov     rdi, r13
		mov     rsi, r15
		call    r_cmp
		cmp     rax, 1
		je      fin_ciclo_rutaMasLarga

	mas_distancia_que_res_rutaMasLarga:
		mov     r13, [r14 + nodo_offset_dato]
		jmp     fin_ciclo_rutaMasLarga

	fin_rutaMasLarga:
		mov     rax, r13	

		pop     r15
		pop     r14
		pop     r13
		pop     r12
		pop     rbp
		ret


global ciudadesMasLejanas
ciudadesMasLejanas:
; RDI := redCaminera* rc, RSI := ciudad** c1, RDX := ciudad** c2
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13

	cmp     rdi, NULL
	je      fin_ciudadesMasLejanas

	mov     r12, rsi
	mov     r13, rdx

	call    rutaMasLarga
	cmp     rax, NULL
	je      fin_ciudadesMasLejanas

	mov     r8, [rax + ruta_offset_ciudad_A]
	mov     r9, [rax + ruta_offset_ciudad_B]

	mov     [r12], r8
	mov     [r13], r9

	fin_ciudadesMasLejanas:
		pop     r13
		pop     r12
		pop     rbp
		ret


global totalDeDistancia
totalDeDistancia:
; RDI := redCaminera* rc
	pxor   xmm0, xmm0                                    ; Lo voy a usar como acumulador
	mov    rdx, [rdi + red_caminera_offset_rutas]
	mov    rcx, [rdx + lista_offset_primero]

	ciclo_totalDeDistancia:
		cmp    rcx, NULL
		je     fin_totalDeDistancia
		mov    r8, [rcx + nodo_offset_dato]
		;mov    r8, [r8 + ruta_offset_distancia]
		addsd    xmm0, [r8 + ruta_offset_distancia]
		mov    rcx, [rcx + nodo_offset_siguiente]
		jmp    ciclo_totalDeDistancia

	fin_totalDeDistancia:
		ret


global totalDePoblacion
totalDePoblacion:
; RDI := redCaminera* rc
	mov    rax, 0
	mov    rdx, [rdi + red_caminera_offset_ciudades]
	mov    rcx, [rdx + lista_offset_primero]

	ciclo_totalDePoblacion:
		cmp    rcx, NULL
		je     fin_totalDePoblacion
		mov    r8, [rcx + nodo_offset_dato]
		mov    r8, [r8 + ciudad_offset_poblacion]
		add    rax, r8
		mov    rcx, [rcx + nodo_offset_siguiente]
		jmp    ciclo_totalDePoblacion

	fin_totalDePoblacion:
		ret


global cantidadDeCaminos
cantidadDeCaminos:
; RDI := redCaminera* rc, RSI := char* ci
	push    rbp
	mov     rbp, rsp
	push    r12
	push    r13
	push    r14
	sub     rsp, 8

	xor     r12d, r12d
	mov     r13, rsi
	mov     r14, [rdi + red_caminera_offset_rutas]
	mov     r14, [r14 + lista_offset_primero]

	ciclo_cantidadDeCaminos:
		cmp     r14, NULL
		je      fin_cantidadDeCaminos
		mov     rdi, [r14 + nodo_offset_dato]
		mov     rdi, [rdi + ruta_offset_ciudad_A]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r13
		call    str_cmp

		cmp     eax, 0
		je      una_coincidencia_cantidadDeCaminos

		mov     rdi, [r14 + nodo_offset_dato]
		mov     rdi, [rdi + ruta_offset_ciudad_B]
		mov     rdi, [rdi + ciudad_offset_nombre]
		mov     rsi, r13
		call    str_cmp

		cmp     eax, 0
		jne     fin_ciclo_cantidadDeCaminos

	una_coincidencia_cantidadDeCaminos:
		inc     r12d

	fin_ciclo_cantidadDeCaminos:
		mov     r14, [r14 + nodo_offset_siguiente]
		jmp     ciclo_cantidadDeCaminos

	fin_cantidadDeCaminos:
		mov     eax, r12d

		add     rsp, 8
		pop     r14
		pop     r13
		pop     r12
		pop     rbp
		ret


global ciudadMasComunicada
ciudadMasComunicada:
; RDI := redCaminera* rc
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14
	push    r15
	sub     rsp, 8

	cmp     rdi, NULL
	je      fin_ciudadMasComunicada

	mov     rbx, rdi
	mov     r12, [rdi + red_caminera_offset_ciudades]
	mov     r13, NULL                                    ; Acá voy a guardar el resultado (res)

	mov     r14, [r12 + lista_offset_primero]
	cmp     r14, NULL
	je      fin_ciudadMasComunicada

	mov     r13, [r14 + nodo_offset_dato]
	mov     r14, [r14 + nodo_offset_siguiente]

	ciclo_ciudadMasComunicada:
		cmp     r14, NULL
		je      fin_ciudadMasComunicada

		mov     rdi, rbx
		mov     rsi, [r13 + ciudad_offset_nombre]
		call    cantidadDeCaminos
		mov     r15, rax

		mov     rdi, rbx
		mov     rsi, [r14 + nodo_offset_dato]
		mov     rsi, [rsi + ciudad_offset_nombre]
		call    cantidadDeCaminos

		cmp     r15, rax

		je      igual_cantidad_de_caminos_que_res_ciudadMasComunicada
		jl      mas_cantidad_de_caminos_que_res_ciudadMasComunicada

	fin_ciclo_ciudadMasComunicada:
		mov     r14, [r14 + nodo_offset_siguiente]
		jmp     ciclo_ciudadMasComunicada

	igual_cantidad_de_caminos_que_res_ciudadMasComunicada:
		mov     rdi, r13
		mov     rsi, r14
		call    c_cmp
		cmp     rax, 1
		je     fin_ciclo_ciudadMasComunicada

	mas_cantidad_de_caminos_que_res_ciudadMasComunicada:
		mov     r13, [r14 + nodo_offset_dato]
		jmp     fin_ciclo_ciudadMasComunicada

	fin_ciudadMasComunicada:
		mov     rax, r13	

		add     rsp, 8
		pop     r15
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


; AUXILIARES

global str_copy
str_copy:
; RDI := char* a
	push    rbp
	mov     rbp, rsp
	push    rbx
	push    r12
	push    r13
	push    r14

	mov     r12, 0                                   ; Inicializo este registro en 0. Acá voy a guardar la longitud del string
	mov     rbx, 0
	mov     r13, rdi                                 ; Guardo el comienzo del string en r13. Este registro lo voy a modificar

	ciclo_averiguar_longitud_str_copy:
		mov     bl, [r13]
		cmp     bl, 0
		je      reservar_memoria_string_str_copy     ; Si llegué al final del string, salgo del ciclo
		inc     r13                                  ; Si no, incremento en 1 byte la dirección de memoria
		inc     r12                                  ; Incremento en 1 la longitud
		jmp     ciclo_averiguar_longitud_str_copy    

	reservar_memoria_string_str_copy:
		inc     r12                                  ; Hago esto para incluir el caso del string vacío
		mov     rdi, r12
		call    malloc
		cmp     rax, NULL
		je      fin_str_copy

	ciclo_copiar_string_str_copy:
		cmp     r12, 0
		je      fin_str_copy
		mov     bl, [r13]
		mov     [rax + r12 - 1], bl
		dec     r13                                  ; Avanzo al siguiente caracter del string original
		dec     r12
		jmp     ciclo_copiar_string_str_copy

	fin_str_copy:
		pop     r14
		pop     r13
		pop     r12
		pop     rbx
		pop     rbp
		ret


global str_cmp
str_cmp:
; RDI := char* a, RSI:= char* b
	mov     rax, 0
	mov     rcx, 0
	mov     rdx, 0

	ciclo_str_cmp:
		mov     cl, [rdi]                 ; Traigo a cl el caracter apuntado por rdi
		mov     dl, [rsi]                 ; Traigo a dl el caracter apuntado por rsi
		cmp     cl, dl
		je      dos_caracteres_iguales_str_cmp
		jl      a_menor_que_b_str_cmp
		jg      a_mayor_que_b_str_cmp

	dos_caracteres_iguales_str_cmp:
		cmp     cl, 0                     ; Si ambos caracteres son 0, los strings son iguales
		je      strings_iguales_str_cmp
		inc     rdi                       ; Avanzo una posición en los dos strings
		inc     rsi
		jmp     ciclo_str_cmp

	a_menor_que_b_str_cmp:
		mov     rax, 1
		jmp     fin_str_cmp

	a_mayor_que_b_str_cmp:
		mov     rax, -1
		jmp     fin_str_cmp

	strings_iguales_str_cmp:
		mov     rax, 0
		jmp     fin_str_cmp

	fin_str_cmp:
		ret


