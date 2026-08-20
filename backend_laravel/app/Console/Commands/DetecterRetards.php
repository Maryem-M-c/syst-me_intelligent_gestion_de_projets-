<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Tache;
use App\Models\Projet;
use Carbon\Carbon;

class DetecterRetards extends Command
{
    protected $signature = 'detecter:retards';
    protected $description = 'Détecte les tâches et projets en retard et met à jour leur statut';

    public function handle()
    {
        $aujourdhui = Carbon::today();

        // 1. Détection des tâches en retard
        $tachesEnRetard = Tache::where('echeance', '<', $aujourdhui)
            ->whereNotIn('statut', ['terminee', 'en_retard'])
            ->get();

        foreach ($tachesEnRetard as $tache) {
            $tache->update(['statut' => 'en_retard']);
            $this->info("Tâche en retard : {$tache->titre}");
        }

        // 2. Détection des projets en retard
        // Un projet est en retard si sa date_fin est dépassée et qu'il n'est pas terminé
        $projetsEnRetard = Projet::where('date_fin', '<', $aujourdhui)
            ->whereNotIn('statut', ['termine', 'en_retard'])
            ->get();

        foreach ($projetsEnRetard as $projet) {
            $projet->update(['statut' => 'en_retard']);
            $this->info("Projet en retard : {$projet->nom}");
        }

        $this->info("Vérification terminée : "
            . $tachesEnRetard->count() . " tâche(s) et "
            . $projetsEnRetard->count() . " projet(s) mis à jour.");

        return Command::SUCCESS;
    }
}