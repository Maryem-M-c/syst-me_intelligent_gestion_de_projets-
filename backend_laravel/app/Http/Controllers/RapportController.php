<?php

namespace App\Http\Controllers;

use App\Models\Projet;
use App\Models\Rapport;
use App\Models\Employe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class RapportController extends Controller
{
    // Génère un nouveau rapport pour un projet donné
    public function generer(Request $request, $projetId)
    {
        $projet = Projet::with('taches.employe.user')->find($projetId);

        if (!$projet) {
            return response()->json(['message' => 'Projet introuvable'], 404);
        }

        $taches = $projet->taches->map(function ($t) {
            return [
                'titre' => $t->titre,
                'statut' => $t->statut,
                'employe_nom' => $t->employe?->user?->name,
            ];
        });

        // Charge de travail des employés impliqués dans ce projet
        $employesIds = $projet->taches->pluck('employe_id')->filter()->unique();
        $employes = Employe::with('user')->whereIn('id', $employesIds)->get()->map(function ($e) {
            return [
                'nom' => $e->user->name,
                'charge_actuelle' => $e->charge_actuelle,
            ];
        });

        try {
            $response = Http::timeout(5)->post(config('services.python_ai.url') . '/generer-rapport', [
                'nom_projet' => $projet->nom,
                'client' => $projet->client,
                'date_debut' => $projet->date_debut,
                'date_fin' => $projet->date_fin,
                'statut_projet' => $projet->statut,
                'taches' => $taches,
                'employes' => $employes,
            ]);

            if (!$response->successful()) {
                return response()->json(['message' => 'Erreur du service IA'], 500);
            }

            $contenu = $response->json()['contenu'];
        } catch (\Exception $e) {
            return response()->json(['message' => 'Service IA indisponible'], 503);
        }

        $rapport = Rapport::create([
            'projet_id' => $projet->id,
            'periode' => now()->format('Y-m'),
            'contenu_genere' => $contenu,
        ]);

        return response()->json($rapport, 201);
    }

    // Liste des rapports d'un projet
    public function index($projetId)
    {
        $rapports = Rapport::where('projet_id', $projetId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($rapports);
    }

    // Voir un rapport précis
    public function show($id)
    {
        $rapport = Rapport::find($id);

        if (!$rapport) {
            return response()->json(['message' => 'Rapport introuvable'], 404);
        }

        return response()->json($rapport);
    }
}