# ============================================
# SCRIPT PARA DUPLICAR ESTRUCTURA DE REVISTA
# ============================================

# Cargar paquetes
if (!require("fs")) install.packages("fs")
if (!require("stringr")) install.packages("stringr")
library(fs)
library(stringr)

# ============================================
# CONFIGURACIÓN (MODIFICAR ESTOS VALORES)
# ============================================

# Planta: carpeta base que usará como modelo
plantilla <- "AnaliticaV7N7_2026"

# Volumen y número de la plantilla
vol_plantilla <- "7"
num_plantilla <- "7"

# Volumen y número NUEVOS (el volumen se mantiene, solo cambia el número)
vol_nuevo <- "7"        # Se mantiene en 7
num_nuevo <- "8"        # Cambia: 7, 8, 9, 10 para 2026
año <- "2026"

# Directorio base donde se crearán las nuevas carpetas
# (relativo al directorio de trabajo o ruta absoluta)
directorio_destino <- "Analitica"

# ============================================
# NO MODIFICAR DE AQUÍ HACIA ABAJO
# ============================================

# Patrones a buscar (diferentes combinaciones de V7N7, v7n7, etc.)
patrones <- c(
  paste0("V", vol_plantilla, "N", num_plantilla),
  paste0("v", vol_plantilla, "n", num_plantilla),
  paste0("_v", vol_plantilla, "n", num_plantilla),
  paste0("V", vol_plantilla, "n", num_plantilla),
  paste0("v", vol_plantilla, "N", num_plantilla),
  paste0("V", vol_plantilla, "N", num_plantilla, "_")
)

# Patrones de reemplazo
patron_reemplazo <- paste0("V", vol_nuevo, "N", num_nuevo)

# Nombre de la nueva carpeta
nueva_carpeta <- paste0("AnaliticaV", vol_nuevo, "N", num_nuevo, "_", año)

# Ruta completa de destino
ruta_destino_completa <- path(directorio_destino, nueva_carpeta)

# Validaciones
if (!dir_exists(plantilla)) {
  stop("Error: La carpeta plantilla '", plantilla, "' no existe")
}

if (dir_exists(ruta_destino_completa)) {
  stop("Error: La carpeta '", ruta_destino_completa, "' ya existe")
}

# Crear directorio base si no existe
if (!dir_exists(directorio_destino)) {
  dir_create(directorio_destino)
  message("📁 Directorio base creado: ", directorio_destino)
}

# Copiar estructura
message("📁 Copiando estructura de '", plantilla, "' a '", ruta_destino_completa, "'...")
dir_copy(plantilla, ruta_destino_completa)

# Listar todos los elementos recursivamente
elementos <- dir_ls(ruta_destino_completa, recurse = TRUE, all = TRUE)

# Procesar de abajo hacia arriba para evitar problemas con rutas
elementos <- sort(elementos, decreasing = TRUE)

contador <- 0
for (ruta_antigua in elementos) {
  nombre <- path_file(ruta_antigua)
  nombre_nuevo <- nombre
  
  # Aplicar todos los patrones de reemplazo
  for (patron in patrones) {
    if (str_detect(nombre, patron)) {
      nombre_nuevo <- str_replace_all(nombre_nuevo, patron, patron_reemplazo)
    }
  }
  
  # Renombrar si hubo cambios
  if (nombre != nombre_nuevo) {
    ruta_nueva <- path(path_dir(ruta_antigua), nombre_nuevo)
    file_move(ruta_antigua, ruta_nueva)
    message("  ✏️  ", nombre, " → ", nombre_nuevo)
    contador <- contador + 1
  }
}

message("\n✅ Proceso completado")
message("📊 Archivos/carpetas renombrados: ", contador)
message("📂 Nueva carpeta creada en: ", path_abs(ruta_destino_completa))