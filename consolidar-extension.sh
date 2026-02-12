#!/bin/bash

# Directorio raíz del número
RAIZ="."

# Rutas
EXTENSION_ANIDADA="$RAIZ/_extensions/mikemahoney218/tandf"
EXTENSION_CORRECTA="$RAIZ/_extensions/tandf"

# Paso 1: Verificar que exista la extensión anidada
if [ ! -d "$EXTENSION_ANIDADA" ]; then
  echo "❌ Error: No se encontró la extensión en:"
  echo "   $EXTENSION_ANIDADA"
  exit 1
fi

# Paso 2: Crear la carpeta correcta
mkdir -p "$EXTENSION_CORRECTA"

# Paso 3: Copiar todo el contenido (preservando tus cambios)
echo "🔄 Copiando la extensión personalizada a la ubicación estándar..."
rsync -av --delete "$EXTENSION_ANIDADA/" "$EXTENSION_CORRECTA/"

# Paso 4: Eliminar la carpeta anidada
echo "🗑️ Eliminando la carpeta redundante..."
rm -rf "$RAIZ/_extensions/mikemahoney218"

# Paso 5: Confirmar éxito
if [ $? -eq 0 ]; then
  echo "✅ Extensión consolidada en:"
  echo "   $EXTENSION_CORRECTA"
  echo "   Ahora puedes usar 'format: tandf-pdf' en tu YAML."
else
  echo "❌ Error durante la consolidación."
  exit 1
fi
