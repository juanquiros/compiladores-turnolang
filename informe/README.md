# Informe académico LNCS

Este directorio contiene el manuscrito de TurnoLang preparado con la clase
oficial `llncs.cls` y el estilo `splncs04.bst` de Springer Nature. Ambos
archivos provienen del paquete **LaTeX2e Proceedings Template** enlazado en la
página oficial de [información para autores y
editores](https://link.springer.com/series/558/information-for-authors-and-editors),
consultada el 2 de noviembre de 2026.

## Estado editorial

El contenido técnico, la bibliografía, las figuras y la compilación están
preparados y verificados. El manuscrito **no es definitivo** porque faltan los
nombres de autores, institución, correos y, si corresponde, ORCID. Los campos
se mantienen como marcadores explícitos en `main.tex`; no deben sustituirse por
datos inventados.

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

La versión incluida se compiló el 2 de noviembre de 2026 con el compilador
integrado y se reprodujo con Tectonic 0.17.0. Las ocho páginas y ambas figuras
se renderizaron para revisión visual. SHA-256 del PDF:
`319a170cc9adf55db088540739d993a29a25f222e741703185799f6c6b702740`.

## Antes de entregar

1. Reemplazar todos los marcadores de autoría con información confirmada.
2. Identificar un único autor de correspondencia y validar su correo.
3. Recompilar y revisar el PDF completo.
4. Confirmar con la cátedra los requisitos finales de extensión y entrega.
