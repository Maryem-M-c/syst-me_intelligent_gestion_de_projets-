<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Tache;

class Employe extends Model
{
    protected $fillable = [
        'user_id',
        'competences',
        'niveau',
        'charge_actuelle',
    ];

    // Un employé appartient à un utilisateur
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Un employé peut avoir plusieurs tâches
    public function taches()
    {
        return $this->hasMany(Tache::class);
    }
}