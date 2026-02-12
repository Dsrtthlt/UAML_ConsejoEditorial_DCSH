#!/usr/bin/env python3
import pandas as pd
import yaml
import os
from pathlib import Path

# === Configuración ===
EXCEL_FILE = "concentradoAn@litica5.xlsx"
OUTPUT_DIR = "metadatos_articulos"
DOI_PREFIX = "10.xxxx/analitica.v6n6"

# Crear carpeta de salida
Path(OUTPUT_DIR).mkdir(exist_ok=True)

# === Leer Excel ===
df = pd.read_excel(EXCEL_FILE)

# Limpiar nombres de columnas
df.columns = df.columns.str.strip()

# === Procesar cada artículo ===
for cod_art, group in df.groupby('COD_ART'):
    # Tomar la primera fila como referencia (título, resumen, etc.)
    first_row = group.iloc[0]
    
    # Construir lista de autores
    autores = []
    for _, row in group.iterrows():
        autor = {
            'name': str(row['NOMBRE_COMPLETO']).strip(),
            'affiliation': str(row['ADSCRIPCION']).strip() if pd.notna(row['ADSCRIPCION']) else '',
            'email': str(row['CORREO_ELECTRONICO']).strip() if pd.notna(row['CORREO_ELECTRONICO']) else '',
            'orcid': str(row['ORCID']).strip() if pd.notna(row['ORCID']) else '',
            'role': 'author'
        }
        autores.append(autor)
    
    # Mapear sección
    seccion_map = {
        'Artículo': 'Artículos',
        'Reseña': 'Reseñas',
        'Entrevista': 'Entrevistas'
    }
    seccion = seccion_map.get(first_row['SECCION'], 'Artículos')
    
    # Palabras clave
    palabras = []
    for i in range(1, 6):
        kw = first_row.get(f'PALABRA_CLAVE_{i}', '')
        if pd.notna(kw) and str(kw).strip():
            palabras.append(str(kw).strip())
    
    # Metadatos del artículo
    metadata = {
        'title': str(first_row['TITULO']).strip(),
        'doi': f"{DOI_PREFIX}.{cod_art}",
        'author': autores,
        'abstract': str(first_row['RESUMEN']).strip() if pd.notna(first_row['RESUMEN']) else '',
        'keywords': palabras,
        'journal-title': "An@lítica",
        'journal-abbreviation': "Anal",
        'issn': "1234-5678",
        'volume': "6",
        'issue': "6",
        'section': seccion,
        'language': "es",
        'copyright-year': "2026",
        'license-url': "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        'received': "2025-03-15",
        'accepted': "2025-11-11",
        'published': "2026-01-26",
        'bibliography': "analiticav6n6.bib"
    }
    
    # Guardar YAML
    output_file = os.path.join(OUTPUT_DIR, f"{cod_art}.yml")
    with open(output_file, 'w', encoding='utf-8') as f:
        yaml.dump(metadata, f, allow_unicode=True, default_flow_style=False, sort_keys=False)
    
    print(f"✅ Generado: {output_file}")

print(f"\n📝 Archivos guardados en la carpeta: {OUTPUT_DIR}")
