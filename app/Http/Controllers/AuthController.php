<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required',
            'role' => 'required|in:guru,siswa,orangtua',
        ]);

        $user = User::where('username', $request->username)
            ->where('role', $request->role)
            ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'username' => ['Kredensial yang diberikan tidak sesuai.'],
            ]);
        }

        Auth::login($user, $request->boolean('remember'));

        return redirect()->intended($this->getRedirectPath($user));
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }

    protected function getRedirectPath($user)
    {
        return match($user->role) {
            'guru' => '/guru/dashboard',
            'siswa' => '/siswa/dashboard',
            'orangtua' => '/orangtua/dashboard',
            default => '/',
        };
    }
} 