# ============================================
# SCRIPT PARA DUPLICAR ESTRUCTURA DE REVISTA
# Versión corregida: Sin subcarpeta Analitica
# ============================================

# Cargar paquetes
if (!require("fs")) install.packages("fs")
if (!require("stringr")) install.packages("stringr")
library(fs)
library(stringr)

# ============================================
# CONFIGURACIÓN (MODIFICAR ESTOS VALORES)
# ============================================

# Carpeta plantilla (la que quiere duplicar)
plantilla <- "Analitica_v1n2"

# Número actual (volumen y número de la plantilla)
vol_actual <- "1"
num_actual <- "2"

# Nuevo número (lo que quiere crear)
vol_nuevo <- "1"      # Se mantiene en 1
num_nuevo <- "6"      # CAMBIE ESTO: 3, 4, 5, etc.

# Directorio donde se crearán las nuevas carpetas
# "." significa "directorio actual"
directorio_destino <- "."

# ============================================
# NO MODIFICAR DE AQUÍ HACIA ABAJO
# ============================================

# Crear el patrón de búsqueda
patron_viejo <- paste0("v", vol_actual, "n", num_actual)
patron_nuevo <- paste0("v", vol_nuevo, "n", num_nuevo)

# Patrones específicos a buscar
patrones <- c(
  paste0("_v", vol_actual, "n", num_actual),
  paste0("v", vol_actual, "n", num_actual, "_"),
  paste0("v", vol_actual, "n", num_actual),
  paste0("V", vol_actual, "N", num_actual),
  paste0("_V", vol_actual, "N", num_actual),
  paste0("V", vol_actual, "N", num_actual, "_")
)

# Nombre de la nueva carpeta
nueva_carpeta <- paste0("Analitica_", patron_nuevo)

# Ruta completa de destino
ruta_destino_completa <- path(directorio_destino, nueva_carpeta)

# Validaciones
if (!dir_exists(plantilla)) {
  stop("❌ Error: La carpeta plantilla '", plantilla, "' no existe.\n",
       "   Directorio actual: ", getwd())
}

if (dir_exists(ruta_destino_completa)) {
  stop("❌ Error: La carpeta '", ruta_destino_completa, "' ya existe.")
}

# Copiar estructura
message("📁 Copiando estructura de '", plantilla, "'...")
message("   Destino: ", ruta_destino_completa)
dir_copy(plantilla, ruta_destino_completa)

# Listar y renombrar
elementos <- dir_ls(ruta_destino_completa, recurse = TRUE, all = TRUE)
elementos <- sort(elementos, decreasing = TRUE)

contador <- 0
for (ruta_antigua in elementos) {
  nombre <- path_file(ruta_antigua)
  nombre_nuevo <- nombre
  
  for (patron in patrones) {
    if (str_detect(nombre, patron)) {
      reemplazo <- str_replace(patron, patron_viejo, patron_nuevo)
      nombre_nuevo <- str_replace_all(nombre_nuevo, patron, reemplazo)
    }
  }
  
  if (nombre != nombre_nuevo) {
    ruta_nueva <- path(path_dir(ruta_antigua), nombre_nuevo)
    file_move(ruta_antigua, ruta_nueva)
    contador <- contador + 1
  }
}

message("\n✅ PROCESO COMPLETADO")
message("📊 Elementos renombrados: ", contador)
message("📂 Nueva carpeta: ", path_abs(ruta_destino_completa))