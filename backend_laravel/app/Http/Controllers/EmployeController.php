<?php

namespace App\Http\Controllers;

use App\Models\Employe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class EmployeController extends Controller
{
    public function index()
    {
        return response()->json(Employe::with('user')->get());
    }

    
    public function store(Request $request)
{
    $validator = Validator::make($request->all(), [
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|min:6',
        'competences' => 'required|string',
        'niveau' => 'required|integer|min:1|max:5',
    ]);

    if ($validator->fails()) {
        return response()->json($validator->errors(), 422);
    }

    // Création du compte utilisateur
    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'role' => 'employe',
    ]);

    // Création de la fiche employé
    $employe = Employe::create([
        'user_id' => $user->id,
        'competences' => $request->competences,
        'niveau' => $request->niveau,
        'charge_actuelle' => 0,
    ]);

    return response()->json(
        $employe->load('user'),
        201
    );
}
/*
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id|unique:employes,user_id',
            'competences' => 'required|string',
            'niveau' => 'required|integer|min:1|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $employe = Employe::create([
            'user_id' => $request->user_id,
            'competences' => $request->competences,
            'niveau' => $request->niveau,
            'charge_actuelle' => 0,
        ]);

        return response()->json($employe->load('user'), 201);
    }
*/
    public function show($id)
    {
        $employe = Employe::with(['user', 'taches'])->find($id);

        if (!$employe) {
            return response()->json(['message' => 'Employé introuvable'], 404);
        }

        return response()->json($employe);
    }

    public function update(Request $request, $id)
    {
        $employe = Employe::find($id);

        if (!$employe) {
            return response()->json(['message' => 'Employé introuvable'], 404);
        }

        $employe->update($request->only(['competences', 'niveau']));

        return response()->json($employe);
    }

    public function destroy($id)
    {
        $employe = Employe::find($id);

        if (!$employe) {
            return response()->json(['message' => 'Employé introuvable'], 404);
        }

        $employe->delete();

        return response()->json(['message' => 'Employé supprimé']);
    }
}