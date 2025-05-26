from sklearn.metrics import classification_report

# Ejemplo de datos
reales = ["positivo", "negativo", "neutral", "positivo", "negativo"]
predichos = ["positivo", "negativo", "negativo", "positivo", "neutral"]

# Mostrar reporte
print(classification_report(reales, predichos, digits=2))
