#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#define TOTAL_EQUIPOS 48
#define EQUIPO_GRUPO 4
typedef struct {
    char nombre[40];
    char confederacion[15];
    int puntos;
    int partidos_jugados;
    int victorias;
    int empates;
    int derrotas;
    int goles_favor;
    int goles_contra;
    int diferencia_goles;
} Equipo;
typedef struct {
    Equipo* equipos[EQUIPO_GRUPO];
} GrupoUsuario;
Equipo banco_mundial[TOTAL_EQUIPOS] = {
    {"Canada", "CONCACAF"}, {"Mexico", "CONCACAF"}, {"Estados Unidos", "CONCACAF"}, {"Australia", "AFC"}, {"RI de Iran", "AFC"}, {"Japon", "AFC"},
    {"Jordania", "AFC"}, {"Republica de Corea", "AFC"}, {"Catar", "AFC"}, {"Arabia Saudi", "AFC"}, {"Uzbekistan", "AFC"}, {"Irak", "AFC"},
    {"Argelia", "CAF"}, {"Cabo Verde", "CAF"}, {"Costa de Marfil", "CAF"}, {"Egipto", "CAF"}, {"Ghana", "CAF"}, {"Marruecos", "CAF"},
    {"Senegal", "CAF"}, {"Sudafrica", "CAF"}, {"Tunez", "CAF"}, {"RD Congo", "CAF"}, {"Curazao", "CONCACAF"}, {"Haiti", "CONCACAF"}, {"Panama", "CONCACAF"},
    {"Argentina", "CSF"}, {"Brasil", "CSF"}, {"Colombia", "CSF"}, {"Ecuador", "CSF"}, {"Paraguay", "CSF"}, {"Uruguay", "CSF"}, {"Nueva Zelanda", "OFC"},
    {"Austria", "UEFA"}, {"Belgica", "UEFA"}, {"Bosnia y Herzegovina", "UEFA"}, {"Croacia", "UEFA"}, {"Republica Checa", "UEFA"}, {"Inglaterra", "UEFA"},
    {"Francia", "UEFA"}, {"Alemania", "UEFA"}, {"Paises Bajos", "UEFA"},
    {"Noruega", "UEFA"}, {"Portugal", "UEFA"}, {"Escocia", "UEFA"}, {"Espana", "UEFA"}, {"Suecia", "UEFA"}, {"Suiza", "UEFA"}, {"Turquia", "UEFA"}
};
// Declarar nuestras funciones
void mostrarPaisesDisponibles();
int buscarEquipo(char* nombre_ingresado);
int yaSeleccionado(GrupoUsuario* g, int num_actual, int indice_banco);
void solicitarPaisesUsuario(GrupoUsuario* g);
void reiniciarEstadisticas(GrupoUsuario* g);
void simularPartido(Equipo* e1, Equipo* e2);
void jugarFaseDeGrupos(GrupoUsuario* g);
void mostrarTablaPosiciones(GrupoUsuario* g, char* titulo);
void ordenarPorBubbleSort(GrupoUsuario* g);
void mostrarClasificados(GrupoUsuario* g);

int main() {
    srand(time(NULL));
    GrupoUsuario mi_grupo;
    printf("Simulador de Fase de Grupos \n");
    mostrarPaisesDisponibles();
    solicitarPaisesUsuario(&mi_grupo);
    reiniciarEstadisticas(&mi_grupo);
    
    mostrarTablaPosiciones(&mi_grupo, "Tabla de posiciones al iniciar el mundial");
    jugarFaseDeGrupos(&mi_grupo);
    
    mostrarTablaPosiciones(&mi_grupo, "Tabla de posiciones al jugar todos los partidos sin orden");
    ordenarPorBubbleSort(&mi_grupo);
    mostrarTablaPosiciones(&mi_grupo, "Tabla de posiciones al jugar todos los partidos en orden");
    mostrarClasificados(&mi_grupo);
    return 0;
}

void mostrarPaisesDisponibles() {
    printf("Lista de paises disponibles para armar tu grupo:\n");
    for (int i = 0; i < TOTAL_EQUIPOS; i++) {
        char item[50];
        sprintf(item, "%d. %s", i + 1, banco_mundial[i].nombre);
        printf("%-26s", item);
        if ((i + 1) % 3 == 0) printf("\n");
    }
    printf("\n---------------------------------------------------------------------------------\n");
}
int buscarEquipo(char *nombre_ingresado) {
    for (int i = 0; i < TOTAL_EQUIPOS; i++) {
        int j = 0;
        while (nombre_ingresado[j] != '\0' && banco_mundial[i].nombre[j] != '\0') {
            if (tolower(nombre_ingresado[j]) != tolower(banco_mundial[i].nombre[j])) {
                break;
            }
            j++;
        }
        if (nombre_ingresado[j] == '\0' && banco_mundial[i].nombre[j] == '\0') return i;
    }
    return -1;
}
int yaSeleccionado(GrupoUsuario* g, int num_actual, int indice_banco) {
    for (int i = 0; i < num_actual; i++) {
        if (g->equipos[i] == &banco_mundial[indice_banco]) return 1; 
    }
    return 0;
}
void solicitarPaisesUsuario(GrupoUsuario* g) {
    char entrada[40];
    int cont = 0;
    printf("Ingrese los %d paises que conformaran tu grupo por favor:\n", EQUIPO_GRUPO);
    while (cont < EQUIPO_GRUPO) {
        printf("Ingrese el pais #%d: ", cont + 1);
        fgets(entrada, sizeof(entrada), stdin);
        entrada[strcspn(entrada, "\n")] = 0; 

        int idx = buscarEquipo(entrada);
        if (idx == -1) {
            printf("El pais '%s' no existe o esta mal escrito.\n", entrada);
        } else if (yaSeleccionado(g, cont, idx)) {
            printf("El pais '%s' ya fue ingresado en este grupo.\n", entrada);
        } else {
            g->equipos[cont] = &banco_mundial[idx];
            cont++;
        }
    }
    printf("\nGrupo guardado.\n");
}
// Esta función me sirve para cuando quiera usar de nuevo el programa y use los mismos países, y así no usar los datos del programa anterior ejecutado.
void reiniciarEstadisticas(GrupoUsuario* g) {
    for (int i = 0; i < EQUIPO_GRUPO; i++) {
        g->equipos[i]->puntos = 0;
        g->equipos[i]->partidos_jugados = 0;
        g->equipos[i]->victorias = 0;
        g->equipos[i]->empates = 0;
        g->equipos[i]->derrotas = 0;
        g->equipos[i]->goles_favor = 0;
        g->equipos[i]->goles_contra = 0;
        g->equipos[i]->diferencia_goles = 0;
    }
}
void simularPartido(Equipo* e1, Equipo* e2) {
    int goles1 = rand() % 6; 
    int goles2 = rand() % 6;
    printf("   %-18s  %d - %d  %-18s\n", e1->nombre, goles1, goles2, e2->nombre);
    e1->partidos_jugados++;
    e2->partidos_jugados++;

    e1->goles_favor += goles1;
    e1->goles_contra += goles2;
    e1->diferencia_goles = e1->goles_favor - e1->goles_contra;

    e2->goles_favor += goles2;
    e2->goles_contra += goles1;
    e2->diferencia_goles = e2->goles_favor - e2->goles_contra;
    if (goles1 > goles2) {
        e1->puntos += 3;
        e1->victorias++;
        e2->derrotas++;
    } else if (goles2 > goles1) {
        e2->puntos += 3;
        e2->victorias++;
        e1->derrotas++;
    } else {
        e1->puntos += 1;
        e2->puntos += 1;
        e1->empates++;
        e2->empates++;
    }
}
void jugarFaseDeGrupos(GrupoUsuario* g) {
    printf("Partidos Jugados \n");
    printf("Jornada 1\n");
    simularPartido(g->equipos[0], g->equipos[1]);
    simularPartido(g->equipos[2], g->equipos[3]);

    printf("Jornada 2\n");
    simularPartido(g->equipos[0], g->equipos[2]);
    simularPartido(g->equipos[1], g->equipos[3]);

    printf("Jornada 3\n");
    simularPartido(g->equipos[0], g->equipos[3]);
    simularPartido(g->equipos[1], g->equipos[2]);
    printf("\n Fase de grupos completa.\n");
}
void mostrarTablaPosiciones(GrupoUsuario* g, char* titulo) {
    printf("\n %s \n", titulo);
    printf("------------------------------------------------------------------------\n");
    printf("%-3s %-20s %-10s %-4s %-4s %-4s %-4s %-4s %-4s %-4s %-4s\n", "Pos", "Pais", "Conf.", "PTS", "PJ", "V", "E", "D", "GF", "GC", "DG");
    for (int i = 0; i < EQUIPO_GRUPO; i++) {
        Equipo* e = g->equipos[i];
        printf("%-3d %-20s %-10s  %2d  %2d  %3d  %3d  %3d  %3d  %3d  %5d\n", i + 1, e->nombre, e->confederacion, e->puntos, e->partidos_jugados, 
        e->victorias, e->empates, e->derrotas, e->goles_favor, e->goles_contra, e->diferencia_goles);
    }
    printf("------------------------------------------------------------------------\n");
}
void ordenarPorBubbleSort(GrupoUsuario* g) {
    int i, j;
    Equipo* temp;
    for (i = 0; i < EQUIPO_GRUPO - 1; i++) {
        for (j = 0; j < EQUIPO_GRUPO - i - 1; j++) {
            int intercambiar = 0;
            if (g->equipos[j]->puntos < g->equipos[j+1]->puntos) {
                intercambiar = 1;
            } else if (g->equipos[j]->puntos == g->equipos[j+1]->puntos) {
                if (g->equipos[j]->diferencia_goles < g->equipos[j+1]->diferencia_goles) {
                    intercambiar = 1;
                } else if (g->equipos[j]->diferencia_goles == g->equipos[j+1]->diferencia_goles) {
                    if (g->equipos[j]->goles_favor < g->equipos[j+1]->goles_favor) {
                        intercambiar = 1;
                    }
                }
            }
            if (intercambiar) {
                temp = g->equipos[j];
                g->equipos[j] = g->equipos[j+1];
                g->equipos[j+1] = temp;
            }
        }
    }
}
void mostrarClasificados(GrupoUsuario* g) {
    printf("Equipos Clasificados\n");
    printf("1er Lugar (Clasificado): %s (%s) con %d puntos\n", g->equipos[0]->nombre, g->equipos[0]->confederacion, g->equipos[0]->puntos);
    printf("2do Lugar (Clasificado): %s (%s) con %d puntos\n", g->equipos[1]->nombre, g->equipos[1]->confederacion, g->equipos[1]->puntos);
    printf("Eliminados: %s y %s.\n", g->equipos[2]->nombre, g->equipos[3]->nombre);
}