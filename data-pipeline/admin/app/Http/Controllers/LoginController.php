<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;

class LoginController extends Controller
{
    public function show()
    {
        return view('review.login');
    }

    public function login(Request $request)
    {
        $key = 'sahti-login:'.$request->ip();
        if (RateLimiter::tooManyAttempts($key, 5)) {
            return back()->withErrors(['password' => 'Trop d\'essais. Réessaie dans '.RateLimiter::availableIn($key).' secondes.']);
        }

        $file = storage_path(SetupPasswordController::HASH_FILE);
        $hash = is_file($file) ? trim((string) file_get_contents($file)) : (string) config('app.admin_password_hash');
        $password = (string) $request->input('password', '');

        if ($hash === '' || ! Hash::check($password, $hash)) {
            RateLimiter::hit($key, 300);

            return back()->withErrors(['password' => 'Mot de passe incorrect.']);
        }

        RateLimiter::clear($key);
        $request->session()->regenerate();
        $request->session()->put('sahti_admin', true);

        return redirect()->intended(route('review.index'));
    }

    public function logout(Request $request)
    {
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
