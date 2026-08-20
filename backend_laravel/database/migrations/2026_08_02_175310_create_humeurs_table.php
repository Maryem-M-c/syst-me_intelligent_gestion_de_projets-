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
    Schema::create('humeurs', function (Blueprint $table) {
        $table->id();
        $table->foreignId('employe_id')->constrained('employes')->onDelete('cascade');
        $table->date('date');
        $table->string('humeur'); // excellent, bien, neutre, fatigue, stresse
        $table->timestamps();
        $table->unique(['employe_id', 'date']); // une humeur par jour
    });
}

public function down(): void
{
    Schema::dropIfExists('humeurs');
}
};
