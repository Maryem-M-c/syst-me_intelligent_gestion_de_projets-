<?php

namespace App\Http\Controllers;

use App\Models\Projet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class PredictionController extends Controller
{
    public function predireDepassement($projetId)
    {
        $projet = Projet::with('taches.employe')->find($projetId);

        if (!$projet) {
            return response()->json(['message' => 'Projet introuvable'], 404);
        }

        $taches = $projet->taches;
        $totalTaches = $taches->count();
        $tachesEnRetard = $taches->where('statut', 'en_retard')->count();
        $tauxRetard = $totalTaches > 0 ? $tachesEnRetard / $totalTaches : 0;

        $employesIds = $taches->pluck('employe_id')->filter()->unique();
        $employes = \App\Models\Employe::whereIn('id', $employesIds)->get();
        $chargeMoyenne = $employes->count() > 0 ? $employes->avg('charge_actuelle') : 0;

        $dureePrevue = Carbon::parse($projet->date_debut)->diffInDays(Carbon::parse($projet->date_fin));

        try {
            $response = Http::timeout(5)->post(config('services.python_ai.url') . '/predire-depassement', [
                'duree_prevue_jours' => max($dureePrevue, 1),
                'nombre_taches' => max($totalTaches, 1),
                'nombre_employes' => max($employes->count(), 1),
                'priorite' => $projet->priorite,
                'charge_moyenne_employes' => round($chargeMoyenne, 2),
                'taux_taches_en_retard' => round($tauxRetard, 2),
            ]);

            if (!$response->successful()) {
                return response()->json(['message' => 'Erreur du service IA'], 500);
            }

            return response()->json($response->json());
        } catch (\Exception $e) {
            return response()->json(['message' => 'Service IA indisponible'], 503);
        }
    }
}