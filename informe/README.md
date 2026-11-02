# Informe académico LNCS

Este directorio contiene el manuscrito de TurnoLang preparado con la clase
oficial `llncs.cls` y el estilo `splncs04.bst` de Springer Nature. Ambos
archivos provienen del paquete **LaTeX2e Proceedings Template** enlazado en la
página oficial de [información para autores y
editores](https://link.springer.com/series/558/information-for-authors-and-editors),
consultada el 2 de noviembre de 2026.

## Estado editorial

El informe académico definitivo identifica a Emanuel Andruszyszyn y Juan Quiros
como autores, con afiliación a la Universidad Gastón Dachary. El contenido
técnico, la bibliografía, las figuras y la compilación están verificados. La
corrección editorial eliminó del artículo los marcadores y las indicaciones
internas del proceso de preparación.

## Estructura

- `main.tex`: manuscrito principal.
- `referencias.bib`: referencias citadas y verificables.
- `main.bbl`: bibliografía resuelta por BibTeX para la entrega LNCS.
- `figuras/arquitectura.pdf`: flujo técnico del procesador.
- `figuras/ast_minimo.pdf`: estructura mínima del AST.
- `figuras/generar_figuras.py`: fuente reproducible de las figuras vectoriales.
- `llncs.cls` y `splncs04.bst`: archivos oficiales de la plantilla LNCS.
- `TurnoLang_LNCS.pdf`: salida compilada y revisada de ocho páginas.

## Compilación local

Desde este directorio, con una distribución LaTeX que incluya BibTeX:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

La salida de `main.pdf` puede renombrarse como `TurnoLang_LNCS.pdf` solo después
de comprobar que no hay referencias sin resolver y de revisar visualmente todas
las páginas.

La versión incluida fue corregida, recompilada y revisada visualmente el 2 de
noviembre de 2026 con el compilador integrado y Tectonic 0.17.0. La cantidad de
páginas y el hash SHA-256 registrados abajo corresponden al PDF publicado:

- Páginas: 8.
- SHA-256: `09b5bd4ec0ac932b0203a375c5d92e1bcceaa132ddc133f13e8f2254c2d0d556`.
