<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Projet;

class Rapport extends Model
{
    protected $fillable = [
        'projet_id',
        'periode',
        'contenu_genere',
    ];

    // Un rapport appartient à un projet
    public function projet()
    {
        return $this->belongsTo(Projet::class);
    }
}