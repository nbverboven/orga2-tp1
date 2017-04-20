#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "redcaminera.h"

int main (void)
{
	remove("PepeGuapo.txt");

	redCaminera* rc = rc_crear("kukamonga");

	rc_agregarCiudad(rc, "montebello", 12041);
	rc_agregarCiudad(rc, "north haverbrook", 1244);
	rc_agregarCiudad(rc, "cocula", 342);

	rc_agregarRuta(rc, "montebello", "north haverbrook", 232);
	rc_agregarRuta(rc, "montebello", "cocula", 233);
	rc_agregarRuta(rc, "north haverbrook", "cocula", 236);

	ciudad* c = ciudadMasPoblada(rc);
	ruta* r = rutaMasLarga(rc);

	FILE *pFile;
    pFile = fopen( "PepeGuapo.txt", "a" );

    fputs("Ciudad más poblada:\n", pFile);

    fprintf(pFile, "[%s,%li]\n", c->nombre, c->poblacion);

    fputs("Ruta más larga:\n", pFile);

    fprintf(pFile, "[%s,%s,%.1f]\n", r->ciudadA->nombre, r->ciudadB->nombre, r->distancia);

    fclose( pFile );

    rc_borrarTodo(rc);

    return 0;    
}
