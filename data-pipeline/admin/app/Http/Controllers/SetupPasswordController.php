<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

/**
 * One-time link to let the owner choose the admin password from any device.
 * Token created with `php artisan admin:setup-link` (stored hashed, 30 min, single use).
 * The chosen password hash is stored in storage/app/admin_password_hash.
 */
class SetupPasswordController extends Controller
{
    public const TOKEN_FILE = 'app/admin_setup_token.json';

    public const HASH_FILE = 'app/admin_password_hash';

    private function validToken(string $token): bool
    {
        $path = storage_path(self::TOKEN_FILE);
        if (! is_file($path)) {
            return false;
        }
        $data = json_decode((string) file_get_contents($path), true) ?: [];

        return isset($data['hash'], $data['expires'])
            && $data['expires'] > time()
            && hash_equals($data['hash'], hash('sha256', $token));
    }

    public function show(string $token)
    {
        abort_unless($this->validToken($token), 404);

        return view('review.setup', ['token' => $token]);
    }

    public function store(Request $request, string $token)
    {
        abort_unless($this->validToken($token), 404);
        $request->validate(['password' => 'required|string|min:12|confirmed'], [
            'password.min' => '12 caractères minimum.',
            'password.confirmed' => 'Les deux mots de passe sont différents.',
        ]);
        file_put_contents(storage_path(self::HASH_FILE), Hash::make($request->input('password')));
        @chmod(storage_path(self::HASH_FILE), 0600);
        @unlink(storage_path(self::TOKEN_FILE));

        return redirect()->route('login')->with('ok', 'Mot de passe enregistré. Connecte-toi.');
    }
}
