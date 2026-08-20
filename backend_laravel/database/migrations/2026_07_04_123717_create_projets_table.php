<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('projets', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('client');
            $table->foreignId('chef_projet_id')->constrained('users')->onDelete('cascade');
            $table->date('date_debut');
            $table->date('date_fin');
            $table->enum('statut', ['en_attente', 'en_cours', 'termine', 'en_retard'])->default('en_attente');
            $table->enum('priorite', ['basse', 'normale', 'haute'])->default('normale');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projets');
    }
};
