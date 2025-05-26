import os
from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def chat_bot(comentarioTexto, promedio):
    if not comentarioTexto or not comentarioTexto.strip():
        return "neutral"

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Eres un analista de sentimientos. Analiza tanto el texto como el número de calificación "
                        "promedio del 1 al 5. Si el promedio es 1 o 2, tiende a ser negativo; si es 4 o 5, positivo. "
                        "El resultado debe ser 'positivo', 'negativo' o 'neutral'."
                    )
                },
                {
                    "role": "user",
                    "content": f"Comentario: {comentarioTexto}\nPromedio: {promedio}"
                }
            ],
            max_tokens=10,
            temperature=0.2
        )

        resultado = response.choices[0].message.content.strip().lower()
        return resultado if resultado in ["positivo", "negativo", "neutral"] else "neutral"

    except Exception as e:
        return "Comentario no analizado"