<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DemandeProjet extends Model
{

    protected $table = 'demandes_projets';  

    protected $fillable = ['client_id', 'nom_projet', 'type_projet', 'questions_reponses', 'description_generee', 'statut'];

    protected $casts = ['questions_reponses' => 'array'];

    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }
}

