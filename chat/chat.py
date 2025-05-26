import os
from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def convertir_promedio_a_etiqueta(promedio):
    if promedio <= 2:
        return "negativo"
    elif promedio == 3:
        return "neutral"
    else:
        return "positivo"

def chat_bot(comentarioTexto, promedio):
    if not comentarioTexto or not comentarioTexto.strip():
        return "Entrada vacía. Por favor, proporciona un comentario válido."

    # Convertimos el promedio a una etiqueta para darle contexto al modelo
    etiqueta_promedio = convertir_promedio_a_etiqueta(promedio)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Eres un analista de sentimientos. Analiza tanto la frase del comentario como la categoría del promedio "
                        "relacionado (positivo, negativo o neutral). El resultado debe ser una única palabra: "
                        "'positivo', 'negativo' o 'neutral'. Considera que el promedio afecta el análisis solo en un 48%."
                    )
                },
                {
                    "role": "user",
                    "content": (
                        f"Comentario: \"{comentarioTexto}\"\n"
                        f"Promedio categorizado como: {etiqueta_promedio}\n"
                        "Indica el sentimiento resultante:"
                    )
                }
            ],
            max_tokens=10,
            temperature=0.2
        )

        resultado = response.choices[0].message.content.strip().lower()
        return resultado

    except Exception as e:
        return "Comentario no analizado"