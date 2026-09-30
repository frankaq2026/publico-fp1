## ⚠️ Windows SmartScreen

Al descargar el `.bat` desde internet, Windows le asigna una etiqueta de
seguridad ("Mark of the Web") que provoca que SmartScreen muestre un aviso
al ejecutarlo. **Esto es un falso positivo**: el script no contiene nada
malicioso, simplemente no tiene firma digital.

### Cómo ejecutarlo

**Opción A** (recomendada):
1. Haz clic derecho en el archivo → **Propiedades**
2. Marca la casilla **Desbloquear** (abajo) → Aceptar
3. Doble clic normal

**Opción B**:
1. Doble clic en el `.bat`
2. En el aviso de SmartScreen, pulsa **Más información** → **Ejecutar de todos modos**

> El aviso solo aparece la primera vez. Tras desbloquear, no volverá a salir.

### ¿Por qué pasa esto?

Windows no puede "leer" un `.bat` para verificar su contenido. Se limita a
ver que viene de internet y tiene una extensión ejecutable, y bloquea por
defecto. No es una señal de que el archivo sea peligroso.   

## Disclaimer

Este proyecto se proporciona **"tal cual" (as-is)**, sin garantía de ningún tipo.
El autor no se hace responsable de ningún daño directo, indirecto o consecuencia
que pueda derivarse de su uso. Al ejecutar este script asumes la total
responsabilidad de lo que ocurra en tu sistema.

El uso de este script es **bajo tu propio riesgo**.

## Contacto

¿Problemas o dudas? → Abre un [Issue](../../issues)
