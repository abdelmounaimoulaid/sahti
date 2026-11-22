@extends('review.layout')
@section('title', 'Connexion')
@section('content')
<div class="card" style="max-width:380px;margin:40px auto">
  <h2 style="margin-top:0">Connexion</h2>
  <form method="post" action="{{ route('login.post') }}">
    @csrf
    <label for="password">Mot de passe admin</label>
    <input type="password" id="password" name="password" autofocus required style="width:100%;padding:8px 10px;border:1px solid var(--line);border-radius:8px;font:inherit">
    @error('password')<p class="warn" style="margin-top:10px">{{ $message }}</p>@enderror
    <div class="btns"><button class="primary" type="submit">Se connecter</button></div>
  </form>
</div>
@endsection
