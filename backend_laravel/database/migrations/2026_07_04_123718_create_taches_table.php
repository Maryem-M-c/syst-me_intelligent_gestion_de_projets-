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
        Schema::create('taches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('projet_id')->constrained('projets')->onDelete('cascade');
            $table->string('titre');
            $table->text('description')->nullable();
            $table->foreignId('employe_id')->nullable()->constrained('employes')->onDelete('set null');
            $table->enum('statut', ['a_faire', 'en_cours', 'en_revision', 'terminee', 'en_retard'])->default('a_faire');
            $table->date('echeance');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('taches');
    }
};
