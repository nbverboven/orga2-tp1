#include "redcaminera.h"

void rc_imprimirTodo(redCaminera* rc, FILE *pFile)
{
	fputs("Nombre:\n", pFile);

	fprintf(pFile, "%s\n", rc->nombre);

	fputs("Ciudades:\n", pFile);

	nodo* actual = (rc->ciudades)->primero;

	while ( actual )
	{
		ciudad* c = (ciudad*) actual->dato;
		fprintf(pFile, "[%s,%li]\n", c->nombre, c->poblacion);
		actual = actual->siguiente;
	}

	fputs("Rutas:\n", pFile);

	nodo* actual2 = (rc->rutas)->primero;

	while ( actual2 )
	{
		ruta* r = (ruta*) actual2->dato;
		fprintf(pFile, "[%s,%s,%.1f]\n", r->ciudadA->nombre, r->ciudadB->nombre, r->distancia);
		actual2 = actual2->siguiente;
	}
}


redCaminera* rc_combinarRedes(char* nombre, redCaminera* rc1, redCaminera* rc2)
{
	redCaminera* nueva_red = rc_crear(nombre);

	nodo* n1 = rc1->ciudades->primero;
	nodo* n2 = rc2->ciudades->primero;

	while ( n1 )
	{
		ciudad* c1 = (ciudad*) n1->dato;
		rc_agregarCiudad(nueva_red, c1->nombre, c1->poblacion);
		n1 = n1->siguiente;
	}

	while ( n2 )
	{
		ciudad* c2 = (ciudad*) n2->dato;
		ciudad* c2_aux = obtenerCiudad(rc1, c2->nombre);

		if ( !c2_aux )
		{
			rc_agregarCiudad(nueva_red, c2->nombre, c2->poblacion);
		}

		n2 = n2->siguiente;
	}

	nodo* n3 = rc1->rutas->primero;
	nodo* n4 = rc2->rutas->primero;

	while ( n3 )
	{
		ruta* r1 = (ruta*) n3->dato;
		rc_agregarRuta(nueva_red, r1->ciudadA->nombre, r1->ciudadB->nombre, r1->distancia);
		n3 = n3->siguiente;
	}

	while ( n4 )
	{
		ruta* r2 = (ruta*) n4->dato;
		ruta* r2_aux = obtenerRuta(rc1, r2->ciudadA->nombre, r2->ciudadB->nombre);

		if ( !r2_aux )
		{
			rc_agregarRuta(nueva_red, r2->ciudadA->nombre, r2->ciudadB->nombre, r2->distancia);
		}

		n4 = n4->siguiente;
	}

    return nueva_red;
}

redCaminera* rc_obtenerSubRed(char* nombre, redCaminera* rc, lista* ciudades)
{
	redCaminera* nueva_red = rc_crear(nombre);

	nodo* ciudad_actual = ciudades->primero;

	while ( ciudad_actual )
	{
		ciudad* c = (ciudad*) ciudad_actual->dato;
		ciudad* c_en_red_caminera_vieja = obtenerCiudad(rc, c->nombre);

		if ( c_en_red_caminera_vieja )
		{
			rc_agregarCiudad(nueva_red, c->nombre, c->poblacion);
		}

		ciudad_actual = ciudad_actual->siguiente;
	}
	
	nodo* ruta_actual = (rc->rutas)->primero;

	while ( ruta_actual )
	{
		ruta* r = (ruta*) ruta_actual->dato;
		rc_agregarRuta(nueva_red, r->ciudadA->nombre, r->ciudadB->nombre, r->distancia);
		ruta_actual = ruta_actual->siguiente;
	}

    return nueva_red;
}
