<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class SetAdminPassword extends Command
{
    protected $signature = 'admin:password';

    protected $description = "Définit le mot de passe de l'admin (hash dans .env)";

    public function handle(): int
    {
        $pw = $this->secret('Nouveau mot de passe admin (12 caractères minimum)');
        if (strlen((string) $pw) < 12) {
            $this->error('Trop court.');

            return self::FAILURE;
        }
        if ($pw !== $this->secret('Confirme le mot de passe')) {
            $this->error('Les deux mots de passe sont différents.');

            return self::FAILURE;
        }
        $hash = Hash::make($pw);
        $path = base_path('.env');
        $env = file_get_contents($path);
        $line = 'ADMIN_PASSWORD_HASH="'.$hash.'"';
        $env = preg_match('/^ADMIN_PASSWORD_HASH=.*$/m', $env)
            ? preg_replace('/^ADMIN_PASSWORD_HASH=.*$/m', str_replace('$', '\$', $line), $env)
            : rtrim($env)."\n".$line."\n";
        file_put_contents($path, $env);
        $this->call('config:clear');
        $this->info('Mot de passe enregistré.');

        return self::SUCCESS;
    }
}
