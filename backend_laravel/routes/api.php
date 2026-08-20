<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;
use App\Http\Controllers\AuthController;

use App\Http\Controllers\EmployeController;
use App\Http\Controllers\ProjetController;
use App\Http\Controllers\TacheController;

use App\Http\Controllers\RapportController;
use App\Http\Controllers\UserController;

use App\Http\Controllers\PredictionController;

use App\Http\Controllers\AssistantController;

use App\Http\Controllers\HumeurController;
use App\Http\Controllers\PlanningController;

use App\Http\Controllers\DemandeProjetController;

// Routes publiques
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);



// Routes protégées (nécessitent un token)
    Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::apiResource('employes', EmployeController::class);
    Route::apiResource('projets', ProjetController::class);
    Route::apiResource('taches', TacheController::class);
   
    Route::post('/verifier-retards', function () {
        Artisan::call('detecter:retards');
        return response()->json([
            'message' => 'Vérification des retards effectuée',
            'output' => Artisan::output(),
        ]);
    });

    Route::post('/projets/{projetId}/generer-rapport', [RapportController::class, 'generer']);
    Route::get('/projets/{projetId}/rapports', [RapportController::class, 'index']);
    Route::get('/rapports/{id}', [RapportController::class, 'show']);

    Route::get('/users/employes-disponibles', [UserController::class, 'employesDisponibles']);
    
    Route::get('/users/clients', [UserController::class, 'clients']);
    Route::get('/users/chefs-projet', [UserController::class, 'chefsProjet']);
    Route::get('/projets/{id}/predire-depassement', [PredictionController::class, 'predireDepassement']);
    Route::post('/assistant', [AssistantController::class, 'demander']);

    Route::post('/mon-humeur', [HumeurController::class, 'enregistrer']);
    Route::get('/mon-humeur/aujourdhui', [HumeurController::class, 'aujourdhui']);
    Route::get('/mon-planning', [PlanningController::class, 'genererPlanning']);
    Route::post('/ameliorer-conseil', [PlanningController::class, 'ameliorerConseil']);

    Route::post('/demandes-projets/generer-questions', [DemandeProjetController::class, 'genererQuestions']);
    Route::post('/demandes-projets/envoyer', [DemandeProjetController::class, 'genererDescriptionEtEnvoyer']);
    Route::get('/demandes-projets', [DemandeProjetController::class, 'index']);
    Route::put('/demandes-projets/{id}/traiter', [DemandeProjetController::class, 'marquerTraitee']);



});