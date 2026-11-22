@extends('review.layout')
@section('title', 'Fiches à vérifier')
@section('content')
@php
  $labels = ['ai_to_verify' => 'À vérifier (IA)', 'incomplete' => 'Incomplètes', 'complete' => 'Complètes (OFF)', 'validated' => 'Validées'];
@endphp
<div class="tabs">
  @foreach ($labels as $key => $label)
    <a href="{{ route('review.index', ['status' => $key]) }}" class="{{ $status === $key ? 'on' : '' }}">{{ $label }} ({{ number_format($counts[$key] ?? 0, 0, ',', ' ') }})</a>
  @endforeach
</div>

<form class="search" method="get">
  <input type="hidden" name="status" value="{{ $status }}">
  <input type="text" name="q" value="{{ request('q') }}" placeholder="Code-barres, nom ou marque">
  <button class="primary" type="submit">Chercher</button>
</form>

<div class="card">
@if ($products->isEmpty())
  <p class="muted">Aucune fiche dans cette liste.</p>
@else
  <table>
    <tr><th></th><th>Produit</th><th>Code-barres</th><th>Champs manquants</th><th></th></tr>
    @foreach ($products as $p)
      <tr>
        <td>@if ($p->image_url)<img class="thumb" src="{{ $p->image_url }}" alt="" loading="lazy">@endif</td>
        <td><strong>{{ $p->name ?? '(sans nom)' }}</strong><br><span class="muted">{{ $p->brand }}</span></td>
        <td>{{ $p->barcode }}</td>
        <td>{{ $p->missing_fields ?? '' }}</td>
        <td><a href="{{ route('review.show', $p->id) }}">Ouvrir</a></td>
      </tr>
    @endforeach
  </table>
  <p class="muted" style="margin-top:12px">
    Page {{ $products->currentPage() }} / {{ $products->lastPage() }}
    @if ($products->previousPageUrl()) · <a href="{{ $products->previousPageUrl() }}">← Précédente</a>@endif
    @if ($products->nextPageUrl()) · <a href="{{ $products->nextPageUrl() }}">Suivante →</a>@endif
  </p>
@endif
</div>
@endsection
