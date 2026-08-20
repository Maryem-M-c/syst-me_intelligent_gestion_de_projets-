<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Humeur extends Model
{
    protected $fillable = ['employe_id', 'date', 'humeur'];

public function employe()
{
    return $this->belongsTo(Employe::class);
}
}
