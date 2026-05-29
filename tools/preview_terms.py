import sys

from app.services import llm


def main():
    subject = " ".join(sys.argv[1:]).strip()
    if not subject:
        raise SystemExit("Usage: .venv/bin/python tools/preview_terms.py <video subject>")

    script = llm.generate_script(video_subject=subject, language="zh", paragraph_number=1)
    if "Error: " in script:
        raise SystemExit(script)

    terms = llm.generate_terms(video_subject=subject, video_script=script, amount=8)
    print("Script:")
    print(script)
    print("\nSearch terms:")
    for term in terms:
        print(f"- {term}")


if __name__ == "__main__":
    main()
