<?php

namespace App\Http\Controllers;

use App\Models\Humeur;
use Illuminate\Http\Request;

class HumeurController extends Controller
{
    // Enregistre ou met à jour l'humeur du jour
    public function enregistrer(Request $request)
    {
        $request->validate([
            'humeur' => 'required|in:excellent,bien,neutre,fatigue,stresse',
        ]);

        $employe = $request->user()->employe;
        if (!$employe) {
            return response()->json(['message' => 'Aucune fiche employé associée'], 404);
        }

        $humeur = Humeur::updateOrCreate(
            ['employe_id' => $employe->id, 'date' => now()->toDateString()],
            ['humeur' => $request->humeur]
        );

        return response()->json($humeur);
    }

    // Récupère l'humeur du jour (ou null si pas encore renseignée)
    public function aujourdhui(Request $request)
    {
        $employe = $request->user()->employe;
        if (!$employe) {
            return response()->json(null);
        }

        $humeur = Humeur::where('employe_id', $employe->id)
            ->where('date', now()->toDateString())
            ->first();

        return response()->json($humeur);
    }
}