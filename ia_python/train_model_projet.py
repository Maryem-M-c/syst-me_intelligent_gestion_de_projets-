import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error
import joblib

np.random.seed(42)
n = 600

# Données synthétiques représentant des projets passés
data = pd.DataFrame({
    "duree_prevue_jours": np.random.randint(15, 180, n),
    "nombre_taches": np.random.randint(3, 40, n),
    "nombre_employes": np.random.randint(1, 8, n),
    "priorite": np.random.choice([1, 2, 3], n),  # 1=basse, 2=normale, 3=haute
    "charge_moyenne_employes": np.random.uniform(0, 6, n),
    "taux_taches_en_retard": np.random.uniform(0, 1, n),  # 0 à 1 (proportion)
})

# Génère le % de dépassement réel (target), selon une logique réaliste
depassement_base = (
    data["taux_taches_en_retard"] * 60
    + (data["charge_moyenne_employes"] > 3).astype(int) * 15
    + (data["nombre_taches"] / data["nombre_employes"] > 6).astype(int) * 20
    - (data["priorite"] == 3).astype(int) * 5  # les projets prioritaires sont mieux suivis
    + np.random.normal(0, 8, n)  # bruit aléatoire
)
data["depassement_pct"] = np.clip(depassement_base, -15, 120)  # entre -15% (avance) et 120% (grand retard)

X = data.drop("depassement_pct", axis=1)
y = data["depassement_pct"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = RandomForestRegressor(n_estimators=200, max_depth=7, random_state=42)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
print(f"Erreur moyenne absolue : {mean_absolute_error(y_test, y_pred):.2f} points de %")

joblib.dump(model, "modele_projet.pkl")
print("Modèle sauvegardé dans modele_projet.pkl")