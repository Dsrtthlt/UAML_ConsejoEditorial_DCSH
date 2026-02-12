#!/usr/bin/env python3
import panflute as pf
import xml.etree.ElementTree as ET
from xml.dom import minidom
import os

def finalize(doc):
    """Se ejecuta al final del procesamiento de Pandoc"""
    meta = doc.get_metadata()
    
    # Ruta del archivo fuente (para guardar el XML junto al .qmd)
    source_file = pf.get_option('source', default='article')
    output_dir = os.path.dirname(source_file) if os.path.dirname(source_file) else '.'
    base_name = os.path.splitext(os.path.basename(source_file))[0]
    xml_path = os.path.join(output_dir, f"{base_name}.xml")

    try:
        # Crear raíz del XML
        article = ET.Element("article", {
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation": "http://pkp.sfu.ca native.xsd",
            "xmlns": "http://pkp.sfu.ca"
        })

        # Título
        title = meta.get('title', '')
        title_elem = ET.SubElement(article, "title")
        title_elem.text = str(title)

        # DOI
        if 'doi' in meta:
            doi_elem = ET.SubElement(article, "doi")
            doi_elem.text = str(meta['doi'])

        # Idioma
        lang = meta.get('language', 'es')
        lang_elem = ET.SubElement(article, "language")
        lang_elem.text = lang

        # Licencia
        if 'license-url' in meta:
            license_elem = ET.SubElement(article, "licenseUrl")
            license_elem.text = str(meta['license-url'])

        # Autores
        authors_elem = ET.SubElement(article, "authors")
        for auth in meta.get('author', []):
            author_elem = ET.SubElement(authors_elem, "author")
            if isinstance(auth, dict):
                if 'name' in auth:
                    firstname_elem = ET.SubElement(author_elem, "firstname")
                    lastname_elem = ET.SubElement(author_elem, "lastname")
                    name_parts = str(auth['name']).split()
                    if len(name_parts) > 1:
                        firstname_elem.text = " ".join(name_parts[:-1])
                        lastname_elem.text = name_parts[-1]
                    else:
                        firstname_elem.text = ""
                        lastname_elem.text = str(auth['name'])
                if 'affiliation' in auth:
                    affiliation_elem = ET.SubElement(author_elem, "affiliation", {"locale": lang})
                    affiliation_elem.text = str(auth['affiliation'])
                if 'email' in auth:
                    email_elem = ET.SubElement(author_elem, "email")
                    email_elem.text = str(auth['email'])
                if 'orcid' in auth:
                    orcid_elem = ET.SubElement(author_elem, "orcid")
                    orcid_elem.text = str(auth['orcid'])

        # Resumen
        if 'abstract' in meta:
            abstract_elem = ET.SubElement(article, "abstract", {"locale": lang})
            abstract_elem.text = str(meta['abstract'])

        # Palabras clave
        if 'keywords' in meta:
            keywords_elem = ET.SubElement(article, "keywords", {"locale": lang})
            for kw in meta['keywords']:
                keyword_elem = ET.SubElement(keywords_elem, "keyword")
                keyword_elem.text = str(kw)

        # Fechas
        dates_elem = ET.SubElement(article, "dates")
        if 'received' in meta:
            received_elem = ET.SubElement(dates_elem, "date", {"type": "received"})
            received_elem.text = str(meta['received'])
        if 'accepted' in meta:
            accepted_elem = ET.SubElement(dates_elem, "date", {"type": "accepted"})
            accepted_elem.text = str(meta['accepted'])
        if 'published' in meta:
            published_elem = ET.SubElement(dates_elem, "date", {"type": "published"})
            published_elem.text = str(meta['published'])

        # Metadatos de la revista
        journal_elem = ET.SubElement(article, "journal")
        if 'journal-title' in meta:
            journal_title_elem = ET.SubElement(journal_elem, "title")
            journal_title_elem.text = str(meta['journal-title'])
        if 'issn' in meta:
            issn_elem = ET.SubElement(journal_elem, "issn")
            issn_elem.text = str(meta['issn'])
        if 'volume' in meta:
            volume_elem = ET.SubElement(journal_elem, "volume")
            volume_elem.text = str(meta['volume'])
        if 'issue' in meta:
            issue_elem = ET.SubElement(journal_elem, "issue")
            issue_elem.text = str(meta['issue'])

        # Escribir XML formateado
        rough_string = ET.tostring(article, 'unicode')
        reparsed = minidom.parseString(rough_string)
        pretty_xml = reparsed.toprettyxml(indent="  ")

        # Guardar
        with open(xml_path, 'w', encoding='utf-8') as f:
            f.write(pretty_xml)

        pf.debug(f"✅ Archivo OJS generado: {xml_path}")

    except Exception as e:
        pf.debug(f"❌ Error al generar XML: {e}")

def main(doc=None):
    return pf.run_filter(lambda x: x, finalize=finalize, doc=doc)

if __name__ == "__main__":
    main()