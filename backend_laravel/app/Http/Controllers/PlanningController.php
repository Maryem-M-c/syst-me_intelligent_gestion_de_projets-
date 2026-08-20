<?php

namespace App\Http\Controllers;

use App\Models\Humeur;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class PlanningController extends Controller
{
    // Génère un planning de la journée basé sur des règles (aucun appel IA externe)
    public function genererPlanning(Request $request)
    {
        $user = $request->user();
        $employe = $user->employe;

        if (!$employe) {
            return response()->json(['message' => 'Aucune fiche employé associée'], 404);
        }

        // Tâches non terminées de l'employé, triées par urgence (échéance la plus proche)
        $taches = $employe->taches()
            ->where('statut', '!=', 'terminee')
            ->orderBy('echeance', 'asc')
            ->get();

        $humeurJour = Humeur::where('employe_id', $employe->id)
            ->where('date', now()->toDateString())
            ->first();

        $humeur = $humeurJour->humeur ?? 'neutre';

        // ----- Règles de fréquence des pauses -----
        $etatDifficile = in_array($humeur, ['fatigue', 'stresse']) || $employe->charge_actuelle >= 4;

        $dureeBlocMinutes = $etatDifficile ? 45 : 90;   // blocs de travail plus courts si fatigué/chargé
        $dureePauseMinutes = $etatDifficile ? 15 : 10;  // pauses plus longues si fatigué/chargé

        // ----- Construction de l'horaire -----
        $heureActuelle = Carbon::today()->setTime(9, 0);
        $horaire = [];

        if ($taches->isEmpty()) {
            $conseil = "Aucune tâche en attente aujourd'hui. Profitez-en pour avancer sur vos formations ou aider un collègue.";
        } else {
            foreach ($taches as $index => $tache) {
                $debut = $heureActuelle->copy();
                $fin = $heureActuelle->copy()->addMinutes($dureeBlocMinutes);

                $horaire[] = [
                    'type' => 'tache',
                    'titre' => $tache->titre,
                    'debut' => $debut->format('H:i'),
                    'fin' => $fin->format('H:i'),
                ];

                $heureActuelle = $fin;

                // Ajoute une pause après chaque bloc (sauf après la toute dernière tâche)
                if ($index < $taches->count() - 1) {
                    $debutPause = $heureActuelle->copy();
                    $finPause = $heureActuelle->copy()->addMinutes($dureePauseMinutes);

                    $horaire[] = [
                        'type' => 'pause',
                        'titre' => $etatDifficile ? 'Pause recommandée (recharge)' : 'Pause',
                        'debut' => $debutPause->format('H:i'),
                        'fin' => $finPause->format('H:i'),
                    ];

                    $heureActuelle = $finPause;
                }

                // Pause déjeuner automatique si on dépasse midi
                if ($heureActuelle->hour >= 12 && $heureActuelle->hour < 13) {
                    $debutDej = $heureActuelle->copy();
                    $finDej = $debutDej->copy()->addMinutes(60);
                    $horaire[] = [
                        'type' => 'pause',
                        'titre' => 'Pause déjeuner',
                        'debut' => $debutDej->format('H:i'),
                        'fin' => $finDej->format('H:i'),
                    ];
                    $heureActuelle = $finDej;
                }
            }

            // ----- Conseil textuel basé sur des règles -----
            if ($humeur === 'stresse') {
                $conseil = "Vous semblez stressé(e) aujourd'hui. Le planning prévoit des pauses plus fréquentes (toutes les 45 min). Essayez de commencer par la tâche la plus urgente pour réduire la pression.";
            } elseif ($humeur === 'fatigue') {
                $conseil = "Vous semblez fatigué(e). Des pauses plus longues sont prévues. Privilégiez les tâches simples le matin et gardez les tâches complexes pour après une bonne pause.";
            } elseif ($employe->charge_actuelle >= 4) {
                $conseil = "Votre charge de travail est élevée. Le planning inclut des pauses régulières pour éviter la surcharge. Pensez à signaler à votre chef de projet si cela devient difficile à tenir.";
            } else {
                $conseil = "Votre planning du jour est équilibré. Gardez ce rythme, avec une pause toutes les 90 minutes pour rester concentré(e).";
            }
        }

        return response()->json([
            'humeur' => $humeur,
            'charge_actuelle' => $employe->charge_actuelle,
            'nombre_taches' => $taches->count(),
            'horaire' => $horaire,
            'conseil' => $conseil,
        ]);
    }

    // Améliore le conseil avec Gemini (appel optionnel, déclenché par bouton)
    public function ameliorerConseil(Request $request)
    {
        $request->validate([
            'conseil_base' => 'required|string',
            'humeur' => 'required|string',
            'nombre_taches' => 'required|integer',
            'charge_actuelle' => 'required|integer',
        ]);

        $user = $request->user();

        try {
            $response = Http::timeout(30)->post(config('services.python_ai.url') . '/ameliorer-conseil', [
                'nom_utilisateur' => $user->name,
                'humeur' => $request->humeur,
                'nombre_taches' => $request->nombre_taches,
                'charge_actuelle' => $request->charge_actuelle,
                'conseil_base' => $request->conseil_base,
            ]);

            if (!$response->successful()) {
                return response()->json(['conseil_ameliore' => null, 'message' => 'Service IA indisponible']);
            }

            return response()->json($response->json());
        } catch (\Exception $e) {
            return response()->json(['conseil_ameliore' => null, 'message' => 'Service IA indisponible']);
        }
    }
}