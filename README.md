#  Système intelligent de gestion de projets et d'affectation des tâches

## Présentation

Ce projet consiste en la conception et le développement d'une ** Système intelligent de gestion de projets et d'affectation des tâches**, intégrant des fonctionnalités basées sur l'**Intelligence Artificielle (IA)** afin d'améliorer l'organisation, le suivi et la gestion des projets.

L'application permet aux différents utilisateurs de gérer leurs activités selon leur rôle : **administrateur, chef de projet, employé et client**.

L'architecture globale repose sur trois composants principaux :

*  **Application mobile Flutter** : interface utilisateur et interaction avec le système.
*  **Backend Laravel** : gestion des utilisateurs, projets, tâches, rapports et API.
*  **Service IA Python / FastAPI** : recommandations, prédictions, génération de rapports, assistant conversationnel et planification intelligente.

---

##  Architecture du projet

```text
PFA/
│
├── backend_laravel/
│   ├── app/
│   ├── database/
│   ├── routes/
│   ├── resources/
│   └── composer.json
│
├── ia_python/
│   ├── main.py
│   ├── train_model_projet.py
│   ├── modele_projet.pkl
│   └── list_models.py
│
├── project_flutter/
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── windows/
│   └── pubspec.yaml
│
└── README.md
```

---

#  Application Flutter

L'application mobile a été développée avec **Flutter**, en adoptant une organisation modulaire permettant de séparer les modèles de données, les services de communication avec l'API Laravel et les différentes interfaces utilisateur.

Un service centralisé permet de gérer les requêtes HTTP, l'authentification ainsi que la transmission du jeton d'accès aux endpoints sécurisés.

##  Authentification

L'utilisateur commence par accéder à la page d'accueil puis à l'écran d'authentification.

Après une authentification réussie, il est automatiquement redirigé vers le tableau de bord correspondant à son rôle.

###  Écran d'accueil
<img width="281" height="476" alt="Capture d&#39;écran 2026-08-09 194337" src="https://github.com/user-attachments/assets/da088e0f-f662-40df-baf1-b29fbf398fb9" />


###  Écran d'authentification

<img width="272" height="478" alt="Capture d&#39;écran 2026-08-09 194404" src="https://github.com/user-attachments/assets/8193b2eb-d0f1-4c5a-a903-d601b7a519c1" />
<img width="293" height="479" alt="Capture d&#39;écran 2026-08-09 194432" src="https://github.com/user-attachments/assets/5bd3c69f-74d0-4b30-8f4b-a87508c71691" />


---

#  Tableau de bord de l'administrateur

Le tableau de bord de l'administrateur offre une **vision globale du système**.

Il permet notamment de :

* gérer les projets ;
* gérer les tâches ;
* gérer les employés ;
* consulter les demandes de projets envoyées par les clients ;
* consulter et gérer son profil.

### Tableau de bord administrateur
<img width="264" height="472" alt="Capture d&#39;écran 2026-08-17 230808" src="https://github.com/user-attachments/assets/9c72981b-3d62-406f-9c42-544036016ff6" />
<img width="264" height="472" alt="Capture d&#39;écran 2026-08-17 231039" src="https://github.com/user-attachments/assets/573ac536-bb7e-40ce-9fb9-a0b1e6aac183" />
<img width="264" height="476" alt="Capture d&#39;écran 2026-08-09 195537" src="https://github.com/user-attachments/assets/2fe6bf67-8526-4ca0-8255-7a75e2279e06" />
<img width="264" height="472" alt="Capture d&#39;écran 2026-08-09 195637" src="https://github.com/user-attachments/assets/aa47c98e-1332-4c2a-abca-394091701575" />
<img width="264" height="479" alt="Capture d&#39;écran 2026-08-18 161541" src="https://github.com/user-attachments/assets/edd68b4a-c62f-4b5c-b53b-d3e451ac718d" />
<img width="264" height="473" alt="Capture d&#39;écran 2026-08-09 195701" src="https://github.com/user-attachments/assets/18fe4d2c-f4da-428c-bbbf-0bbf21dbed85" />


---

#  Tableau de bord du chef de projet

Le tableau de bord du chef de projet constitue l'un des principaux espaces fonctionnels de l'application.

Il permet de :

* créer et suivre les projets ;
* gérer les tâches ;
* consulter les demandes des clients ;
* bénéficier de suggestions intelligentes d'affectation ;
* consulter les rapports générés automatiquement ;
* utiliser la prédiction du risque de dépassement ;
* interagir avec l'assistant conversationnel IA.

###  Tableau de bord du chef de projet

<img width="264" height="468" alt="Capture d&#39;écran 2026-08-09 195215" src="https://github.com/user-attachments/assets/111bb0b4-eac0-4894-8711-1870d64b3ac0" />
<img width="264" height="475" alt="Capture d&#39;écran 2026-08-09 195244" src="https://github.com/user-attachments/assets/f887402a-cbd4-46d6-b7f1-facf1e99723c" />
<img width="264" height="488" alt="Capture d&#39;écran 2026-08-17 192924" src="https://github.com/user-attachments/assets/d32645b9-c590-4201-a330-fd21e2c190f5" />


###  Demandes clients avec assistance IA

<img width="299" height="474" alt="Capture d&#39;écran 2026-08-09 200611" src="https://github.com/user-attachments/assets/4a7970f4-83e2-4e2c-bc13-dce3439cd1e6" />


###  Assistant IA

<img width="259" height="479" alt="Capture d&#39;écran 2026-08-17 210950" src="https://github.com/user-attachments/assets/d885fbad-0259-4982-a15b-5ba4ac53ea64" />


###  Profil chef de projet

<img width="310" height="478" alt="Capture d&#39;écran 2026-08-09 200833" src="https://github.com/user-attachments/assets/d64d14ab-bb34-401b-b781-a1b345f3fa98" />

---

#  Tableau de bord de l'employé

Le tableau de bord de l'employé est centré sur la gestion de son activité quotidienne.

L'employé peut :

* consulter les tâches qui lui sont attribuées ;
* mettre à jour le statut de ses tâches ;
* consulter son planning personnel ;
* bénéficier d'une planification assistée par l'IA.

###  Mes tâches
<img width="287" height="473" alt="Capture d&#39;écran 2026-08-09 195839" src="https://github.com/user-attachments/assets/acee29ce-64d6-45da-b51e-73f013fc9cd5" />


###  Planning IA

Le module de planification personnelle assistée prend en compte l'état d'esprit de l'employé et sa charge de travail afin de proposer une organisation adaptée de sa journée.

<img width="288" height="474" alt="Capture d&#39;écran 2026-08-09 195908" src="https://github.com/user-attachments/assets/fee3cc9a-1da3-424f-a53f-1eced00cfd84" />
<img width="299" height="479" alt="Capture d&#39;écran 2026-08-09 195947" src="https://github.com/user-attachments/assets/f3c697c6-3c79-47e4-8185-466fca6fc49d" />


---

#  Tableau de bord du client

Le tableau de bord du client permet de consulter l'avancement de ses propres projets, sans accès aux informations des autres clients.

Le client dispose également d'une fonctionnalité d'**assistance à la formulation des demandes de projet**.

Grâce à l'IA, il peut répondre à quelques questions ciblées afin de transformer son besoin initial en une description structurée pouvant ensuite être traitée par le chef de projet.

### Tableau de bord client

<img width="287" height="476" alt="Capture d&#39;écran 2026-08-09 200041" src="https://github.com/user-attachments/assets/45028e52-c6aa-4a48-b19d-a4ea4400e547" />

###  Création d'une demande de projet

<img width="264" height="479" alt="Capture d&#39;écran 2026-08-09 200053" src="https://github.com/user-attachments/assets/82b2bbad-1c21-47fd-966d-f4832469c243" />
<img width="264" height="466" alt="Capture d&#39;écran 2026-08-09 200244" src="https://github.com/user-attachments/assets/e08ecf1c-e74c-421c-8240-6179c3fb0c95" />
<img width="264" height="468" alt="Capture d&#39;écran 2026-08-09 200329" src="https://github.com/user-attachments/assets/9cacba4c-f48d-4b95-a3d6-b771b4da9e92" />
<img width="287" height="473" alt="Capture d&#39;écran 2026-08-09 200341" src="https://github.com/user-attachments/assets/6ad7bfbc-6dcd-4d41-a7cf-6dde730d079e" />

---

#  Fonctionnalités intelligentes

Le système intègre plusieurs fonctionnalités basées sur l'Intelligence Artificielle :

| Fonctionnalité               | Description                                         |
| ---------------------------- | --------------------------------------------------- |
|  Assistant IA              | Interaction conversationnelle avec l'utilisateur    |
|  Recommandation            | Suggestion intelligente pour la gestion des projets |
|  Affectation intelligente  | Aide à l'affectation des tâches aux employés        |
|  Prédiction                | Prédiction du risque de dépassement                 |
|  Génération de rapports    | Génération automatique de rapports                  |
|  Demandes clients IA       | Structuration intelligente des besoins clients      |
|  Planning IA               | Organisation personnalisée de la journée            |
|  Amélioration des conseils | Amélioration automatique des recommandations        |

---

#  Technologies utilisées

##  Frontend

* Flutter
* Dart
* Material Design

##  Backend

* Laravel
* PHP
* API REST
* MySQL

##  Intelligence Artificielle

* Python
* FastAPI
* Modèles de Machine Learning
* Gemini

##  Outils

* Git
* GitHub
* Visual Studio Code
* Android Studio
* Postman

---

#  Installation et exécution

## 1. Backend Laravel

```bash
cd backend_laravel
composer install
php artisan migrate
php artisan serve
```

Le backend est accessible par défaut à :

```text
http://127.0.0.1:8000
```

---

## 2. Service IA Python

```bash
cd ia_python
pip install -r requirements.txt
python -m uvicorn main:app --reload --port 8001
```

Le service IA est accessible par défaut à :

```text
http://127.0.0.1:8001
```

La documentation interactive FastAPI est disponible à :

```text
http://127.0.0.1:8001/docs
```

---

## 3. Application Flutter

```bash
cd project_flutter
flutter pub get
flutter run
```

Pour exécuter l'application sur Windows :

```bash
flutter run -d windows
```

---

#  Configuration

Les informations sensibles ne sont pas incluses dans le dépôt GitHub.

Avant l'exécution du projet, il faut configurer les fichiers `.env` nécessaires pour Laravel et le service IA.

Les fichiers `.env` sont volontairement exclus du dépôt grâce au `.gitignore`.

Des fichiers `.env.example` peuvent être utilisés comme modèle de configuration.

---


#  Auteure

**Maryem Mafrouz**

Projet de fin d'études  — **Système intelligent de gestion de projets et d'affectation des tâches**

---


