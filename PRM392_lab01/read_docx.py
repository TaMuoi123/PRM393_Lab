import zipfile
import xml.etree.ElementTree as ET

def read_docx(path):
    try:
        with zipfile.ZipFile(path) as docx:
            tree = ET.XML(docx.read('word/document.xml'))
            texts = []
            for elem in tree.iter():
                if elem.tag.endswith('}t'):
                    if elem.text:
                        texts.append(elem.text)
            return '\n'.join(texts)
    except Exception as e:
        return str(e)

print(read_docx(r"D:\PRM392_lab01\Lab 1_Setting Up Flutter and Running Your First App.docx"))
