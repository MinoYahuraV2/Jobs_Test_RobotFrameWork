"""Small helpers for the Apply form tests: make throw-away files to upload.

The files go to the system temp folder (not into the repo). Names and sizes are fixed so the
tests can look for them on the page (for example "cv.pdf" and "2 KB").
"""
import tempfile
from pathlib import Path

_DIR = Path(tempfile.gettempdir()) / "jobs_test_upload"

# kind -> (file name, size in bytes)
_FILES = {
    "pdf": ("cv.pdf", 2048),
    "pdf2": ("cv2.pdf", 3072),
    "docx": ("cv.docx", 4096),
    "txt": ("cv.txt", 1024),
    "big_pdf": ("big.pdf", 6 * 1024 * 1024),
    "zip": ("portfolio.zip", 2048),
    "png": ("photo.png", 2048),
}


def make_test_file(kind):
    """Create (or reuse) a dummy file and return its absolute path."""
    if kind not in _FILES:
        raise ValueError(f"unknown test file kind '{kind}', use one of {sorted(_FILES)}")
    name, size = _FILES[kind]
    _DIR.mkdir(parents=True, exist_ok=True)
    path = _DIR / name
    if not path.exists() or path.stat().st_size != size:
        header = b"%PDF-1.4\n" if name.endswith(".pdf") else b""
        path.write_bytes(header + b"0" * (size - len(header)))
    return str(path)


def test_file_name(kind):
    return _FILES[kind][0]
