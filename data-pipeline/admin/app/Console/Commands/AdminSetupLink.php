<?php

namespace App\Console\Commands;

use App\Http\Controllers\SetupPasswordController;
use Illuminate\Console\Command;

class AdminSetupLink extends Command
{
    protected $signature = 'admin:setup-link';

    protected $description = "Crée un lien à usage unique (30 min) pour choisir le mot de passe admin";

    public function handle(): int
    {
        $token = bin2hex(random_bytes(24));
        file_put_contents(storage_path(SetupPasswordController::TOKEN_FILE), json_encode([
            'hash' => hash('sha256', $token),
            'expires' => time() + 1800,
        ]));
        @chmod(storage_path(SetupPasswordController::TOKEN_FILE), 0600);
        $this->line(rtrim(config('app.url'), '/').'/setup-password/'.$token);

        return self::SUCCESS;
    }
}
