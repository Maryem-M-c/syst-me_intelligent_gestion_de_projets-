<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Tache;
use App\Models\Rapport;

class Projet extends Model
{
    protected $fillable = [
        'nom',
        'description',
        'client',
        'client_id',
        'chef_projet_id',
        'date_debut',
        'date_fin',
        'statut',
        'priorite',
    ];

    // Un projet appartient à un chef de projet (User)
    public function chefProjet()
    {
        return $this->belongsTo(User::class, 'chef_projet_id');
    }
        public function client()
{
    return $this->belongsTo(User::class, 'client_id');
}

    // Un projet possède plusieurs tâches
    public function taches()
    {
        return $this->hasMany(Tache::class);
    }

    // Un projet possède plusieurs rapports
    public function rapports()
    {
        return $this->hasMany(Rapport::class);
    }


}