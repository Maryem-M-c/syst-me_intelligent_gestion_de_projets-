<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('demandes_projets', function (Blueprint $table) {
        $table->id();
        $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
        $table->string('nom_projet');
        $table->string('type_projet');
        $table->json('questions_reponses')->nullable();
        $table->longText('description_generee')->nullable();
        $table->enum('statut', ['envoyee', 'traitee'])->default('envoyee');
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('demandes_projets');
}
};
