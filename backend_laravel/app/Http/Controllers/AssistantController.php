<?php

namespace App\Http\Controllers;

use App\Models\Tache;
use App\Models\Projet;
use App\Models\Employe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AssistantController extends Controller
{
  public function demander(Request $request)
{
    $user = $request->user();

    $taches = Tache::with(['projet', 'employe.user'])->get()->map(function ($t) {
        return [
            'titre' => $t->titre,
            'statut' => $t->statut,
            'projet_id' => $t->projet_id,
            'employe_nom' => $t->employe?->user?->name,
        ];
    });

    $projets = Projet::all()->map(fn($p) => ['id' => $p->id, 'nom' => $p->nom]);

    $employes = Employe::with('user')->get()->map(function ($e) {
        return ['nom' => $e->user->name, 'charge_actuelle' => $e->charge_actuelle];
    });

    try {
        $response = Http::timeout(30)->post(config('services.python_ai.url') . '/assistant', [
            'question' => $request->question,
            'role' => $user->role,
            'nom_utilisateur' => $user->name,
            'taches' => $taches,
            'projets' => $projets,
            'employes' => $employes,
        ]);

        if (!$response->successful()) {
            return response()->json(['reponse' => "Le service IA n'a pas pu répondre pour le moment."]);
        }

        return response()->json($response->json());
    } catch (\Exception $e) {
        return response()->json(['reponse' => "L'assistant est momentanément indisponible."]);
    }
}
}