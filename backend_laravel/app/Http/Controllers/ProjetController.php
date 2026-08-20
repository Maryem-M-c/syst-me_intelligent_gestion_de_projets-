<?php

namespace App\Http\Controllers;

use App\Models\Projet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
class ProjetController extends Controller
{
    public function index(Request $request)
{
    $user = $request->user();

    if ($user->role === 'client') {
        $projets = Projet::with('chefProjet')->where('client', $user->name)->get();
    } elseif ($user->role === 'employe') {
        $employe = $user->employe;
        $projetIds = $employe ? $employe->taches()->pluck('projet_id')->unique() : [];
        $projets = Projet::with('chefProjet')->whereIn('id', $projetIds)->get();
    } else {
        // admin et chef_projet voient tout
        $projets = Projet::with('chefProjet')->get();
    }

    return response()->json($projets);
}
public function store(Request $request)
{
    $user = $request->user();

    $validator = Validator::make($request->all(), [
        'nom' => 'required|string|max:255',
        'description' => 'nullable|string',
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut',
        'priorite' => 'nullable|in:basse,normale,haute',
        'client' => 'nullable|string|max:255',
        'chef_projet_id' => 'nullable|exists:users,id',
    ]);

    if ($validator->fails()) {
        return response()->json($validator->errors(), 422);
    }

    // Cas 1 : le client crée son projet
    if ($user->role == 'client') {

        $chefProjet = User::where('role', 'chef_projet')->first();

        if (!$chefProjet) {
            return response()->json([
                'message' => 'Chef de projet introuvable'
            ], 404);
        }

        $projet = Projet::create([
            'nom' => $request->nom,
            'description' => $request->description,
            'client' => $user->name,
            'chef_projet_id' => $chefProjet->id,
            'date_debut' => $request->date_debut,
            'date_fin' => $request->date_fin,
            'statut' => 'en_attente',
            'priorite' => $request->priorite ?? 'normale',
        ]);

    } else {

        // Cas 2 : Admin ou Chef de projet crée un projet

        $projet = Projet::create([
            'nom' => $request->nom,
            'description' => $request->description,
            'client' => $request->client,
            'chef_projet_id' => $request->chef_projet_id,
            'date_debut' => $request->date_debut,
            'date_fin' => $request->date_fin,
            'statut' => 'en_attente',
            'priorite' => $request->priorite ?? 'normale',
        ]);
    }

    return response()->json(
        $projet->load('chefProjet'),
        201
    );
}
/*
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'client' => 'required|string|max:255',
            'chef_projet_id' => 'required|exists:users,id',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'priorite' => 'nullable|in:basse,normale,haute',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $projet = Projet::create([
            'nom' => $request->nom,
            'client' => $request->client,
            'chef_projet_id' => $request->chef_projet_id,
            'date_debut' => $request->date_debut,
            'date_fin' => $request->date_fin,
            'statut' => 'en_attente',
            'priorite' => $request->priorite ?? 'normale',
        ]);

        return response()->json($projet->load('chefProjet'), 201);
    }
*/
    public function show($id)
    {
        $projet = Projet::with(['chefProjet', 'taches.employe.user'])->find($id);

        if (!$projet) {
            return response()->json(['message' => 'Projet introuvable'], 404);
        }

        return response()->json($projet);
    }

    public function update(Request $request, $id)
    {
        $projet = Projet::find($id);

        if (!$projet) {
            return response()->json(['message' => 'Projet introuvable'], 404);
        }

        $projet->update($request->only([
            'nom', 'client', 'date_debut', 'date_fin', 'statut', 'priorite'
        ]));

        return response()->json($projet);
    }

    public function destroy($id)
    {
        $projet = Projet::find($id);

        if (!$projet) {
            return response()->json(['message' => 'Projet introuvable'], 404);
        }

        $projet->delete();

        return response()->json(['message' => 'Projet supprimé']);
    }
}