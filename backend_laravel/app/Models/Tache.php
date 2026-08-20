<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Projet;
use App\Models\Employe;

class Tache extends Model
{
    protected $fillable = [
        'projet_id',
        'titre',
        'description',
        'employe_id',
        'statut',
        'echeance',
    ];

    // Une tâche appartient à un projet
    public function projet()
    {
        return $this->belongsTo(Projet::class);
    }

    // Une tâche appartient à un employé
    public function employe()
    {
        return $this->belongsTo(Employe::class);
    }
}