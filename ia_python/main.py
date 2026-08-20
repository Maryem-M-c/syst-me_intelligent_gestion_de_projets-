from urllib import response

from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
import pandas as pd
import joblib

from datetime import date

from google import genai
import os
import time
from dotenv import load_dotenv



app = FastAPI(title="Service IA - Project Manager AI")
modele_projet = joblib.load("modele_projet.pkl")

load_dotenv()
client = genai.Client(
    api_key=os.environ.get("GEMINI_API_KEY")
)

class Employe(BaseModel):
    id: int
    nom: str
    competences: List[str]
    niveau: int          # 1 à 5
    charge_actuelle: int # nombre de tâches en cours


class TacheRequest(BaseModel):
    titre: str
    competences_requises: List[str]
    employes_disponibles: List[Employe]


class RecommandationResponse(BaseModel):
    employe_id: Optional[int]
    nom: Optional[str]
    score: Optional[float]
    message: str


class TacheStat(BaseModel):
    titre: str
    statut: str
    employe_nom: Optional[str] = None


class EmployeCharge(BaseModel):
    nom: str
    charge_actuelle: int

class RapportRequest(BaseModel):
    nom_projet: str
    client: str
    date_debut: str
    date_fin: str
    statut_projet: str
    taches: List[TacheStat]
    employes: List[EmployeCharge]

class RapportResponse(BaseModel):
    contenu: str



class PredictionProjetRequest(BaseModel):
    duree_prevue_jours: int
    nombre_taches: int
    nombre_employes: int
    priorite: str  # "basse", "normale", "haute"
    charge_moyenne_employes: float
    taux_taches_en_retard: float  # entre 0 et 1

class PredictionProjetResponse(BaseModel):
    depassement_pct: float
    jours_estimes_supplementaires: int
    niveau_risque: str
    message: str


class AssistantRequest(BaseModel):
    question: str
    role: str
    nom_utilisateur: str
    taches: List[dict] = []
    projets: List[dict] = []
    employes: List[dict] = []


class AssistantResponse(BaseModel):
    reponse: str

class AmeliorerConseilRequest(BaseModel):
    nom_utilisateur: str
    humeur: str
    nombre_taches: int
    charge_actuelle: int
    conseil_base: str


class AmeliorerConseilResponse(BaseModel):
    conseil_ameliore: str


def calculer_score(employe: Employe, competences_requises: List[str]) -> float:
    # 1. Score de correspondance des compétences (0 à 1)
    competences_emp = set(c.strip().lower() for c in employe.competences)
    competences_req = set(c.strip().lower() for c in competences_requises)

    if not competences_req:
        match_competences = 0.5
    else:
        intersection = competences_emp & competences_req
        match_competences = len(intersection) / len(competences_req)

    # 2. Score du niveau d'expertise (0 à 1)
    score_niveau = employe.niveau / 5

    # 3. Score de disponibilité — moins de charge = meilleur score (0 à 1)
    score_disponibilite = 1 / (1 + employe.charge_actuelle)

    # Pondération globale
    score_final = (match_competences * 0.5) + (score_niveau * 0.3) + (score_disponibilite * 0.2)

    return round(score_final, 3)


def repondre_assistant(question: str, data: AssistantRequest) -> str:
    q = question.lower()

    if any(mot in q for mot in ["retard", "en retard"]):
        en_retard = [t for t in data.taches if t.get("statut") == "en_retard"]
        if not en_retard:
            return "Bonne nouvelle, aucune tâche n'est actuellement en retard."
        titres = ", ".join([t["titre"] for t in en_retard])
        return f"Il y a {len(en_retard)} tâche(s) en retard : {titres}."
    
    if any(mot in q for mot in ["charge", "surcharg", "disponib"]):
        if not data.employes:
            return "Aucune donnée d'employé disponible."
        plus_charge = max(data.employes, key=lambda e: e.get("charge_actuelle", 0))
        return (f"{plus_charge['nom']} est actuellement le plus chargé avec "
                f"{plus_charge['charge_actuelle']} tâche(s) en cours.")

    if "avancement" in q or "état" in q or "progress" in q:
        for p in data.projets:
            if p["nom"].lower() in q:
                taches_projet = [t for t in data.taches if t.get("projet_id") == p["id"]]
                terminees = len([t for t in taches_projet if t.get("statut") == "terminee"])
                total = len(taches_projet)
                pct = round((terminees / total) * 100, 1) if total > 0 else 0
                return f"Le projet '{p['nom']}' est avancé à {pct}% ({terminees}/{total} tâches terminées)."
        if data.projets:
            noms = ", ".join([p["nom"] for p in data.projets])
            return f"Je n'ai pas trouvé ce projet précis. Vos projets sont : {noms}."
        return "Aucun projet trouvé."
    
    if "mes tâches" in q or "mes taches" in q:
        mes_taches = [t for t in data.taches if t.get("employe_nom") == data.nom_utilisateur]
        if not mes_taches:
            return "Vous n'avez aucune tâche assignée pour le moment."
        titres = ", ".join([f"{t['titre']} ({t['statut']})" for t in mes_taches])
        return f"Vos tâches : {titres}."

    if "combien" in q and "projet" in q:
        return f"Il y a {len(data.projets)} projet(s) au total."

    if any(mot in q for mot in ["bonjour", "salut", "hello"]):
        return f"Bonjour {data.nom_utilisateur} ! Je peux vous renseigner sur les retards, la charge de travail, ou l'avancement des projets."

    return ("Je n'ai pas bien compris votre question. Vous pouvez me demander : "
            "les tâches en retard, la charge de travail des employés, "
            "ou l'avancement d'un projet.")


@app.get("/")
def home():
    return {"message": "Service IA Project Manager AI - opérationnel"}


@app.post("/recommander", response_model=RecommandationResponse)
def recommander_employe(request: TacheRequest):
    if not request.employes_disponibles:
        return RecommandationResponse(
            employe_id=None,
            nom=None,
            score=None,
            message="Aucun employé disponible"
        )

    scores = [
        (employe, calculer_score(employe, request.competences_requises))
        for employe in request.employes_disponibles
    ]

    meilleur_employe, meilleur_score = max(scores, key=lambda x: x[1])

    return RecommandationResponse(
        employe_id=meilleur_employe.id,
        nom=meilleur_employe.nom,
        score=meilleur_score,
        message=f"{meilleur_employe.nom} est recommandé pour cette tâche"
    )


@app.post("/generer-rapport", response_model=RapportResponse)
def generer_rapport(request: RapportRequest):
    total = len(request.taches)
    terminees = len([t for t in request.taches if t.statut == "terminee"])
    en_cours = len([t for t in request.taches if t.statut == "en_cours"])
    en_retard = len([t for t in request.taches if t.statut == "en_retard"])
    a_faire = len([t for t in request.taches if t.statut == "a_faire"])

    taux_avancement = round((terminees / total) * 100, 1) if total > 0 else 0

    lignes = []
    lignes.append(f"RAPPORT D'ACTIVITÉ — {request.nom_projet}")
    lignes.append(f"Client : {request.client}")
    lignes.append(f"Période : {request.date_debut} → {request.date_fin}")
    lignes.append(f"Statut du projet : {request.statut_projet}")
    lignes.append("")
    lignes.append(f"Avancement global : {taux_avancement}% ({terminees}/{total} tâches terminées)")
    lignes.append(f"- Terminées : {terminees}")
    lignes.append(f"- En cours : {en_cours}")
    lignes.append(f"- À faire : {a_faire}")
    lignes.append(f"- En retard : {en_retard}")
    lignes.append("")

    if en_retard > 0:
        taches_retard = [t.titre for t in request.taches if t.statut == "en_retard"]
        lignes.append(f"⚠️ Attention : {en_retard} tâche(s) en retard : {', '.join(taches_retard)}")
        lignes.append("")

    if request.employes:
        lignes.append("Charge de travail par employé :")
        for e in sorted(request.employes, key=lambda x: x.charge_actuelle, reverse=True):
            alerte = " ⚠️ surchargé" if e.charge_actuelle >= 4 else ""
            lignes.append(f"- {e.nom} : {e.charge_actuelle} tâche(s) en cours{alerte}")
        lignes.append("")

    if taux_avancement >= 80:
        lignes.append("Conclusion : le projet est en très bonne voie.")
    elif en_retard > 0:
        lignes.append("Conclusion : le projet nécessite une attention particulière à cause des retards.")
    else:
        lignes.append("Conclusion : le projet avance normalement.")

    contenu = "\n".join(lignes)
    return RapportResponse(contenu=contenu)


@app.post("/predire-depassement", response_model=PredictionProjetResponse)
def predire_depassement(request: PredictionProjetRequest):
    priorite_map = {"basse": 1, "normale": 2, "haute": 3}

    features = pd.DataFrame([{
        "duree_prevue_jours": request.duree_prevue_jours,
        "nombre_taches": request.nombre_taches,
        "nombre_employes": request.nombre_employes,
        "priorite": priorite_map.get(request.priorite, 2),
        "charge_moyenne_employes": request.charge_moyenne_employes,
        "taux_taches_en_retard": request.taux_taches_en_retard,
    }])
    depassement = float(modele_projet.predict(features)[0])
    depassement = round(depassement, 1)

    jours_sup = round(request.duree_prevue_jours * (depassement / 100))

    if depassement >= 40:
        niveau = "Élevé"
        message = "Le projet risque un dépassement important. Une réorganisation des ressources est recommandée."
    elif depassement >= 15:
        niveau = "Modéré"
        message = "Un léger dépassement est probable, à surveiller de près."
    elif depassement > 0:
        niveau = "Faible"
        message = "Le projet devrait se terminer proche du délai prévu."
    else:
        niveau = "Aucun"
        message = "Le projet est en bonne voie pour finir dans les temps, voire en avance."

    return PredictionProjetResponse(
        depassement_pct=depassement,
        jours_estimes_supplementaires=max(jours_sup, 0),
        niveau_risque=niveau,
        message=message,
    )




def construire_contexte(data: AssistantRequest) -> str:
    """Transforme les données de l'app en texte compréhensible pour le LLM."""
    lignes = []

    lignes.append(f"Utilisateur connecté : {data.nom_utilisateur} (rôle : {data.role})")
    lignes.append("")

    lignes.append(f"PROJETS ({len(data.projets)}) :")
    for p in data.projets:
        lignes.append(f"- {p['nom']} (id: {p['id']})")
    
    lignes.append("")
    lignes.append(f"TÂCHES ({len(data.taches)}) :")
    for t in data.taches:
        employe = t.get('employe_nom') or "non assigné"
        lignes.append(f"- \"{t['titre']}\" | statut: {t['statut']} | employé: {employe} | projet_id: {t.get('projet_id')}")

    lignes.append("")
    lignes.append(f"EMPLOYÉS ({len(data.employes)}) :")
    for e in data.employes:
        lignes.append(f"- {e['nom']} : {e['charge_actuelle']} tâche(s) en cours")

    return "\n".join(lignes)


''''''

# ---------- Fonction partagée pour appeler Gemini avec fallback de modèles ----------

MODELES_A_ESSAYER = ["gemini-2.5-flash-lite", "gemini-3.1-flash-lite", "gemini-3.5-flash-lite"]


def appeler_gemini(prompt: str) -> Optional[str]:
    for modele in MODELES_A_ESSAYER:
        for tentative in range(2):
            try:
                response = client.models.generate_content(model=modele, contents=prompt)
                return response.text.strip()
            except Exception as e:
                print(f"{modele} — tentative {tentative + 1} échouée : {repr(e)}")
                time.sleep(2)
    return None


@app.post("/assistant", response_model=AssistantResponse)
def assistant(request: AssistantRequest):
    contexte = construire_contexte(request)

    prompt = f"""Tu es l'assistant IA intégré dans une plateforme de gestion de projets pour une agence web.
Réponds UNIQUEMENT en te basant sur les données ci-dessous. Ne mentionne jamais que tu es une IA générative,
comporte-toi comme l'assistant natif de l'application. Réponds en français, de façon concise (2-4 phrases maximum),
claire et directement utile. Si l'information demandée n'existe pas dans les données, dis-le simplement.

DONNÉES DE L'APPLICATION :
{contexte}
QUESTION DE L'UTILISATEUR :
{request.question}

RÉPONSE :"""

    texte = appeler_gemini(prompt)

    if texte is None:
        texte = "Le service IA est momentanément surchargé. Merci de réessayer dans quelques instants."

    return AssistantResponse(reponse=texte)


@app.post("/ameliorer-conseil", response_model=AmeliorerConseilResponse)
def ameliorer_conseil(request: AmeliorerConseilRequest):
    prompt = f"""Tu es un assistant bien-être au travail intégré dans une application de gestion de projets.
Un employé nommé {request.nom_utilisateur} a l'humeur suivante aujourd'hui : {request.humeur}.
Il a {request.nombre_taches} tâche(s) en attente et une charge de travail actuelle de {request.charge_actuelle} tâche(s) en cours.

Voici un conseil basique déjà généré par des règles simples :
"{request.conseil_base}"

Reformule et enrichis ce conseil de façon plus chaleureuse, personnalisée et motivante, en 2-3 phrases maximum,
en français, sans mentionner que tu es une IA générative. Reste concret et bienveillant."""

    texte = appeler_gemini(prompt)

    if texte is None:
        texte = request.conseil_base  # fallback : on garde le conseil de base

    return AmeliorerConseilResponse(conseil_ameliore=texte)



'''

@app.post("/assistant", response_model=AssistantResponse)
def assistant(request: AssistantRequest):
    contexte = construire_contexte(request)

    prompt = f"""Tu es l'assistant IA intégré dans une plateforme de gestion de projets pour une agence web.
Réponds UNIQUEMENT en te basant sur les données ci-dessous. Ne mentionne jamais que tu es une IA générative,
comporte-toi comme l'assistant natif de l'application. Réponds en français, de façon concise (2-4 phrases maximum),
claire et directement utile. Si l'information demandée n'existe pas dans les données, dis-le simplement.

DONNÉES DE L'APPLICATION :
{contexte}
QUESTION DE L'UTILISATEUR :
{request.question}

RÉPONSE :"""
    
    max_tentatives = 4
    delai_secondes = 3
    modeles_a_essayer = ["gemini-flash-latest", "gemini-flash-latest", "gemini-2.5-flash-lite", "gemini-2.5-flash-lite"]
    texte = None

    for tentative in range(max_tentatives):
        try:
            response = client.models.generate_content(
                model=modeles_a_essayer[tentative],
                contents=prompt
            )
            texte = response.text.strip()
            break
        except Exception as e:
            print(f"Tentative {tentative + 1} échouée : {repr(e)}")
            if tentative < max_tentatives - 1:
                time.sleep(delai_secondes)

    if texte is None:
        texte = "Le service IA est momentanément surchargé. Merci de réessayer dans quelques instants."


    return AssistantResponse(reponse=texte)



@app.post("/ameliorer-conseil", response_model=AmeliorerConseilResponse)
def ameliorer_conseil(request: AmeliorerConseilRequest):
    prompt = f"""Tu es un assistant bien-être au travail intégré dans une application de gestion de projets.
Un employé nommé {request.nom_utilisateur} a l'humeur suivante aujourd'hui : {request.humeur}.
Il a {request.nombre_taches} tâche(s) en attente et une charge de travail actuelle de {request.charge_actuelle} tâche(s) en cours.

Voici un conseil basique déjà généré par des règles simples :
"{request.conseil_base}"

Reformule et enrichis ce conseil de façon plus chaleureuse, personnalisée et motivante, en 2-3 phrases maximum,
en français, sans mentionner que tu es une IA générative. Reste concret et bienveillant."""

    max_tentatives = 3
    texte = None

    for tentative in range(max_tentatives):
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash-lite",
                contents=prompt
            )
            texte = response.text.strip()
            break
        except Exception as e:
            print(f"Tentative {tentative + 1} échouée : {repr(e)}")
            if tentative < max_tentatives - 1:
                time.sleep(3)

    if texte is None:
        texte = request.conseil_base  # fallback : on garde le conseil de base

    return AmeliorerConseilResponse(conseil_ameliore=texte)
 
    '''


#client

QUESTIONS_PAR_DEFAUT = {
    "application mobile": [
        "Quel est l'objectif principal de l'application ?",
        "Qui sont les utilisateurs cibles ?",
        "L'application doit-elle fonctionner sur Android, iOS, ou les deux ?",
        "Avez-vous besoin d'un compte utilisateur / connexion ?",
        "Quelles fonctionnalités clés imaginez-vous (ex: notifications, paiement, chat) ?",
    ],
    "e-commerce": [
        "Quels types de produits ou services allez-vous vendre ?",
        "Combien de produits environ prévoyez-vous au catalogue ?",
        "Souhaitez-vous intégrer un moyen de paiement en ligne ?",
        "Avez-vous besoin d'une gestion de stock ?",
        "Prévoyez-vous une livraison, un retrait en magasin, ou les deux ?",
    ],
    "pharmacie": [
        "Souhaitez-vous permettre la réservation de médicaments en ligne ?",
        "Avez-vous besoin d'un système d'ordonnance électronique ?",
        "Voulez-vous afficher les stocks disponibles en temps réel ?",
        "Prévoyez-vous un service de livraison ?",
        "Avez-vous des contraintes réglementaires spécifiques à respecter ?",
    ],
    "restaurant": [
        "Souhaitez-vous un système de réservation de table en ligne ?",
        "Voulez-vous proposer la commande et le paiement en ligne ?",
        "Avez-vous besoin d'afficher un menu avec photos et prix ?",
        "Prévoyez-vous la livraison à domicile ?",
        "Souhaitez-vous un programme de fidélité pour vos clients ?",
    ],
    "site vitrine": [
        "Quel est l'objectif principal du site (présentation, génération de contacts, etc.) ?",
        "Combien de pages envisagez-vous approximativement ?",
        "Avez-vous déjà une charte graphique (logo, couleurs) ?",
        "Souhaitez-vous un formulaire de contact ou de devis ?",
        "Le site doit-il être disponible en plusieurs langues ?",
    ],
}

QUESTIONS_GENERIQUES = [
    "Quel est l'objectif principal de ce projet ?",
    "Qui sont les utilisateurs ou clients visés ?",
    "Quel budget approximatif envisagez-vous ?",
    "Quel délai souhaitez-vous pour la livraison ?",
    "Avez-vous des exemples ou références qui vous inspirent ?",
]


class QuestionsRequest(BaseModel):
    nom_projet: str
    type_projet: str


class QuestionsResponse(BaseModel):
    questions: List[str]


@app.post("/generer-questions", response_model=QuestionsResponse)
def generer_questions(request: QuestionsRequest):
    prompt = f"""Tu es un consultant en analyse de besoins pour une agence web.
Un client souhaite démarrer un projet nommé "{request.nom_projet}", de type "{request.type_projet}".

Génère exactement 5 questions pertinentes et précises à poser à ce client pour bien cerner son besoin
avant de rédiger un cahier des charges. Adapte les questions spécifiquement au type de projet indiqué.
Réponds UNIQUEMENT avec les 5 questions, une par ligne, sans numérotation, sans introduction ni conclusion."""

    texte = appeler_gemini(prompt)

    if texte:
        lignes = [l.strip("-•0123456789. ").strip() for l in texte.split("\n") if l.strip()]
        questions = [l for l in lignes if len(l) > 5][:5]
        if len(questions) >= 3:
            return QuestionsResponse(questions=questions)

    # Fallback règles si l'IA échoue ou renvoie un résultat inexploitable
    type_normalise = request.type_projet.strip().lower()
    questions_fallback = QUESTIONS_PAR_DEFAUT.get(type_normalise, QUESTIONS_GENERIQUES)
    return QuestionsResponse(questions=questions_fallback)


class ReponseItem(BaseModel):
    question: str
    reponse: str


class DescriptionRequest(BaseModel):
    nom_projet: str
    type_projet: str
    reponses: List[ReponseItem]


class DescriptionResponse(BaseModel):
    description: str


@app.post("/generer-description", response_model=DescriptionResponse)
def generer_description(request: DescriptionRequest):
    qr_texte = "\n".join([f"- {r.question} → {r.reponse}" for r in request.reponses])

    prompt = f"""Tu es un consultant en analyse de besoins pour une agence web.
Rédige une description professionnelle et structurée du projet suivant, destinée à un chef de projet
pour préparer un cahier des charges. Ton clair et professionnel, en français.

Nom du projet : {request.nom_projet}
Type de projet : {request.type_projet}

Réponses du client aux questions posées :
{qr_texte}

Structure ta réponse en 3-4 paragraphes courts : objectif du projet, public cible, fonctionnalités attendues,
contraintes ou précisions particulières. Ne mentionne jamais que tu es une IA générative."""

    texte = appeler_gemini(prompt)

    if not texte:
        lignes = [f"{request.nom_projet} — Projet de type {request.type_projet}.", ""]
        for r in request.reponses:
            lignes.append(f"{r.question} {r.reponse}")
        texte = "\n".join(lignes)

    return DescriptionResponse(description=texte)