<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // Liste les utilisateurs ayant le rôle "employe" et n'ayant pas encore de fiche Employe
    public function employesDisponibles()
    {
        $users = User::where('role', 'employe')
            ->whereDoesntHave('employe')
            ->get(['id', 'name', 'email']);

        return response()->json($users);
    }
  public function clients()
{
    $clients = \App\Models\User::where('role', 'client')
        ->get(['id', 'name', 'email']);

    return response()->json($clients);
}

public function chefsProjet()
{
    $chefs = \App\Models\User::where('role', 'chef_projet')
        ->get(['id', 'name', 'email']);

    return response()->json($chefs);
}

}