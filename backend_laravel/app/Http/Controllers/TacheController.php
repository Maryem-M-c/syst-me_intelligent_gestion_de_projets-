<?php

namespace App\Http\Controllers;

use App\Models\Tache;
use App\Models\Employe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

use Illuminate\Support\Facades\Http;

class TacheController extends Controller
{
    public function index(Request $request)
{
    $user = $request->user();

    if ($user->role === 'employe') {
        $employe = $user->employe;
        if (!$employe) return response()->json([]);
        $taches = Tache::with(['projet', 'employe.user'])->where('employe_id', $employe->id)->get();
    } elseif ($user->role === 'client') {
        $taches = Tache::with(['projet', 'employe.user'])
            ->whereHas('projet', fn($q) => $q->where('client', $user->name))
            ->get();
    } else {
        $taches = Tache::with(['projet', 'employe.user'])->get();
    }

    return response()->json($taches);
}



    public function store(Request $request)
    {
    $validator = Validator::make($request->all(), [
        'projet_id' => 'required|exists:projets,id',
        'titre' => 'required|string|max:255',
        'description' => 'nullable|string',
        'employe_id' => 'nullable|exists:employes,id',
        'competences_requises' => 'nullable|array',
        'echeance' => 'required|date',
    ]);

    if ($validator->fails()) {
        return response()->json($validator->errors(), 422);
    }

    $employeId = $request->employe_id;
    $suggestionIA = null;

    // Si aucun employé n'est assigné manuellement, on demande à l'IA
    if (!$employeId) {
        $employes = Employe::with('user')->get()->map(function ($e) {
            return [
                'id' => $e->id,
                'nom' => $e->user->name,
                'competences' => explode(',', $e->competences),
                'niveau' => $e->niveau,
                'charge_actuelle' => $e->charge_actuelle,
            ];
        });

        try {
            $response = Http::timeout(5)->post(config('services.python_ai.url') . '/recommander', [
                'titre' => $request->titre,
                'competences_requises' => $request->competences_requises ?? [],
                'employes_disponibles' => $employes,
            ]);

            if ($response->successful()) {
                $suggestionIA = $response->json();
            }
        } catch (\Exception $e) {
            // Le service IA est indisponible : on continue sans bloquer la création
            $suggestionIA = ['message' => 'Service IA indisponible'];
        }
    }

    $tache = Tache::create([
        'projet_id' => $request->projet_id,
        'titre' => $request->titre,
        'description' => $request->description,
        'employe_id' => $employeId, // reste null si pas assigné manuellement
        'statut' => 'a_faire',
        'echeance' => $request->echeance,
    ]);

    if ($employeId) {
        Employe::where('id', $employeId)->increment('charge_actuelle');
    }

    return response()->json([
        'tache' => $tache->load(['projet', 'employe.user']),
        'suggestion_ia' => $suggestionIA,
    ], 201);
}


    
    public function show($id)
    {
        $tache = Tache::with(['projet', 'employe.user'])->find($id);

        if (!$tache) {
            return response()->json(['message' => 'Tâche introuvable'], 404);
        }

        return response()->json($tache);
    }

    public function update(Request $request, $id)
    {
        //dd($request->all());
        $tache = Tache::find($id);

        if (!$tache) {
            return response()->json(['message' => 'Tâche introuvable'], 404);
        }

        $ancienEmploye = $tache->employe_id;

        $tache->update($request->only([
            'titre', 'description', 'employe_id', 'statut', 'echeance'
        ]));

        // Gestion de la charge de travail si l'employé assigné change
        if ($request->has('employe_id') && $request->employe_id != $ancienEmploye) {
            if ($ancienEmploye) {
                Employe::where('id', $ancienEmploye)->decrement('charge_actuelle');
            }
            if ($request->employe_id) {
                Employe::where('id', $request->employe_id)->increment('charge_actuelle');
            }
        }

        // Si la tâche est terminée, on libère de la charge
        if ($request->statut === 'terminee' && $tache->employe_id) {
            Employe::where('id', $tache->employe_id)->decrement('charge_actuelle');
        }

        return response()->json($tache);
    }

    public function destroy($id)
    {
        $tache = Tache::find($id);

        if (!$tache) {
            return response()->json(['message' => 'Tâche introuvable'], 404);
        }

        if ($tache->employe_id) {
            Employe::where('id', $tache->employe_id)->decrement('charge_actuelle');
        }

        $tache->delete();

        return response()->json(['message' => 'Tâche supprimée']);
    }
}