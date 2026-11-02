"""Genera las figuras vectoriales del informe académico de TurnoLang."""

from pathlib import Path

from reportlab.pdfgen import canvas
from reportlab.lib.colors import black, white
from reportlab.lib.units import mm


BASE = Path(__file__).resolve().parent


def caja(c, x, y, w, h, titulo, detalle=""):
    c.setStrokeColor(black)
    c.setFillColor(white)
    c.setLineWidth(0.8)
    c.roundRect(x, y, w, h, 2 * mm, stroke=1, fill=1)
    c.setFillColor(black)
    c.setFont("Helvetica-Bold", 8)
    c.drawCentredString(x + w / 2, y + h - 4.5 * mm, titulo)
    if detalle:
        c.setFont("Helvetica", 6.6)
        c.drawCentredString(x + w / 2, y + 3.2 * mm, detalle)


def flecha(c, x1, y1, x2, y2, etiqueta=""):
    c.setLineWidth(0.8)
    c.line(x1, y1, x2, y2)
    direccion = 1 if x2 >= x1 else -1
    c.line(x2, y2, x2 - direccion * 2.5 * mm, y2 + 1.3 * mm)
    c.line(x2, y2, x2 - direccion * 2.5 * mm, y2 - 1.3 * mm)
    if etiqueta:
        c.setFont("Helvetica", 6)
        c.drawCentredString((x1 + x2) / 2, y1 + 2 * mm, etiqueta)


def arquitectura():
    ancho, alto = 170 * mm, 52 * mm
    c = canvas.Canvas(str(BASE / "arquitectura.pdf"), pagesize=(ancho, alto))
    margen = 5 * mm
    y = 18 * mm
    h = 22 * mm
    w = 25 * mm
    sep = 3 * mm
    datos = [
        ("Programa .tl", "entrada"),
        ("Flex", "tokens y lineas"),
        ("Bison", "gramatica"),
        ("AST", "nodos tipados"),
        ("Semantica", "validar y aplicar"),
        ("Interprete", "stdout / stderr"),
    ]
    xs = []
    x = margen
    for titulo, detalle in datos:
        caja(c, x, y, w, h, titulo, detalle)
        xs.append(x)
        x += w + sep
    for i in range(len(xs) - 1):
        flecha(c, xs[i] + w, y + h / 2, xs[i + 1] - 0.7 * mm, y + h / 2)
    c.setFont("Helvetica-Bold", 7)
    c.drawString(margen, 45 * mm, "Flujo principal")
    c.setFont("Helvetica", 6.4)
    c.drawRightString(ancho - margen, 6 * mm, "El backend recorre cada nodo una sola vez.")
    c.showPage()
    c.save()


def ast_minimo():
    ancho, alto = 170 * mm, 62 * mm
    c = canvas.Canvas(str(BASE / "ast_minimo.pdf"), pagesize=(ancho, alto))
    caja(c, 6 * mm, 37 * mm, 38 * mm, 18 * mm, "Programa", "nombre + lista")
    caja(c, 59 * mm, 37 * mm, 42 * mm, 18 * mm, "Instruccion", "tipo + linea + datos")
    caja(c, 116 * mm, 37 * mm, 42 * mm, 18 * mm, "Instruccion", "tipo + linea + datos")
    flecha(c, 44 * mm, 46 * mm, 58 * mm, 46 * mm, "primera")
    flecha(c, 101 * mm, 46 * mm, 115 * mm, 46 * mm, "siguiente")

    tipos = ["RESERVA", "CANCELACION", "DISPONIBILIDAD", "LISTADO"]
    posiciones = [8, 49, 90, 131]
    for x, tipo in zip(posiciones, tipos):
        caja(c, x * mm, 10 * mm, 31 * mm, 14 * mm, tipo, "union de datos")
        c.line(80 * mm, 37 * mm, (x + 15.5) * mm, 24 * mm)
    c.setFont("Helvetica", 6.4)
    c.drawString(6 * mm, 4 * mm, "La lista conserva el orden fuente; cada variante almacena solo los campos necesarios.")
    c.showPage()
    c.save()


if __name__ == "__main__":
    arquitectura()
    ast_minimo()
