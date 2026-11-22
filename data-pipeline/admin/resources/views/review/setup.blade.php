@extends('review.layout')
@section('title', 'Choisir le mot de passe')
@section('content')
<div class="card" style="max-width:420px;margin:40px auto">
  <h2 style="margin-top:0">Choisis ton mot de passe admin</h2>
  <p class="muted">Ce lien ne marche qu'une fois.</p>
  <form method="post" action="{{ route('setup.store', $token) }}">
    @csrf
    <label for="password">Nouveau mot de passe (12 caractères minimum)</label>
    <input type="password" id="password" name="password" required minlength="12" autocomplete="new-password" style="width:100%;padding:8px 10px;border:1px solid var(--line);border-radius:8px;font:inherit">
    <label for="password_confirmation">Confirme le mot de passe</label>
    <input type="password" id="password_confirmation" name="password_confirmation" required autocomplete="new-password" style="width:100%;padding:8px 10px;border:1px solid var(--line);border-radius:8px;font:inherit">
    @error('password')<p class="warn" style="margin-top:10px">{{ $message }}</p>@enderror
    <div class="btns"><button class="primary" type="submit">Enregistrer</button></div>
  </form>
</div>
@endsection
