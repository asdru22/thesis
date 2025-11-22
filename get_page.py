from PyPDF2 import PdfReader, PdfWriter

def extract_page(input_pdf, output_pdf, page_number):
    reader = PdfReader(input_pdf)
    writer = PdfWriter()

    # page_number è 1-based: pagina 1 = indice 0
    index = page_number - 1

    if index < 0 or index >= len(reader.pages):
        raise ValueError("Page number out of range.")

    writer.add_page(reader.pages[index])

    with open(output_pdf, "wb") as f:
        writer.write(f)

    print(f"Saved page {page_number} to {output_pdf}")

# Esempio d’uso
extract_page("tesi.pdf", "p16.pdf", 18)
