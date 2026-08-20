<?php

namespace App\Http\Controllers;

use App\Models\DemandeProjet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class DemandeProjetController extends Controller
{
    public function genererQuestions(Request $request)
    {
        $request->validate([
            'nom_projet' => 'required|string',
            'type_projet' => 'required|string',
        ]);

        try {
            $response = Http::timeout(30)->post(config('services.python_ai.url') . '/generer-questions', [
                'nom_projet' => $request->nom_projet,
                'type_projet' => $request->type_projet,
            ]);

            if (!$response->successful()) {
                return response()->json(['message' => 'Service IA indisponible'], 503);
            }

            return response()->json($response->json());
        } catch (\Exception $e) {
            return response()->json(['message' => 'Service IA indisponible'], 503);
        }
    }

    public function genererDescriptionEtEnvoyer(Request $request)
    {
        $request->validate([
            'nom_projet' => 'required|string',
            'type_projet' => 'required|string',
            'reponses' => 'required|array|min:1',
        ]);

        try {
            $response = Http::timeout(30)->post(config('services.python_ai.url') . '/generer-description', [
                'nom_projet' => $request->nom_projet,
                'type_projet' => $request->type_projet,
                'reponses' => $request->reponses,
            ]);

            $description = $response->successful()
                ? $response->json()['description']
                : "Description générée indisponible. Voici les réponses brutes du client.";

        } catch (\Exception $e) {
            $description = "Description générée indisponible. Voici les réponses brutes du client.";
        }

        $demande = DemandeProjet::create([
            'client_id' => $request->user()->id,
            'nom_projet' => $request->nom_projet,
            'type_projet' => $request->type_projet,
            'questions_reponses' => $request->reponses,
            'description_generee' => $description,
            'statut' => 'envoyee',
        ]);

        return response()->json($demande, 201);
    }

    // Liste des demandes : chef_projet/admin voient tout, client voit les siennes
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'client') {
            $demandes = DemandeProjet::where('client_id', $user->id)->orderBy('created_at', 'desc')->get();
        } else {
            $demandes = DemandeProjet::with('client')->orderBy('created_at', 'desc')->get();
        }

        return response()->json($demandes);
    }

    public function marquerTraitee($id)
    {
        $demande = DemandeProjet::find($id);
        if (!$demande) {
            return response()->json(['message' => 'Demande introuvable'], 404);
        }
        $demande->update(['statut' => 'traitee']);
        return response()->json($demande);
    }
}