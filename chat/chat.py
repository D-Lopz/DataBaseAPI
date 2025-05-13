import os
from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def chat_bot(comentarioTexto):
    if not comentarioTexto or not comentarioTexto.strip():
        return "Entrada vacía. Por favor, proporciona un comentario válido."

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "Eres un analista de sentimientos. Responde solo con 'positivo', 'negativo' o 'neutral'."},
                {"role": "user", "content": f"Analiza el sentimiento de esta frase: {comentarioTexto}"}
            ],
            max_tokens=10,
            temperature=0.2
        )

        resultado = response.choices[0].message.content.strip().lower()
        if resultado not in ["positivo", "negativo", "neutral"]:
            return "neutral"

        return resultado

    except Exception as e:
        return "neutral"  # o mejor: loggear el error pero no guardar el mensaje completo
