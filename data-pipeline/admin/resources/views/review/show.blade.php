@extends('review.layout')
@section('title', $product->name ?? $product->barcode)
@section('content')
@php
  $statusLabels = ['ai_to_verify' => 'Trouvée par IA, à vérifier', 'incomplete' => 'Incomplète', 'complete' => 'Complète (Open Food Facts)', 'validated' => 'Validée'];
  $typeLabels = ['manufacturer' => 'Site du fabricant', 'moroccan_retailer' => 'Supermarché marocain', 'foreign_retailer' => 'Site étranger', 'packaging_photo' => 'Photo d\'emballage', 'open_food_facts' => 'Open Food Facts', 'other' => 'Autre'];
  $foreign = $sources->contains(fn ($s) => $s->source_country && $s->source_country !== 'MA');
@endphp
<p><a href="{{ route('review.index', ['status' => $product->status]) }}">← Retour à la liste</a>
  @if ($next) · <a href="{{ route('review.show', $next) }}">Fiche suivante →</a>@endif</p>

<div class="card row">
  <div>
    @if ($product->image_url)<img src="{{ $product->image_url }}" alt="" style="width:100%;max-height:260px;object-fit:contain;background:#fff;border-radius:8px">@endif
    <p class="muted" style="margin-top:8px">
      Code-barres : <strong>{{ $product->barcode }}</strong><br>
      Statut : {{ $statusLabels[$product->status] ?? $product->status }}<br>
      @if ($product->quantity)Quantité : {{ $product->quantity }}<br>@endif
      @if ($product->nutriscore_grade)Nutri-Score : {{ strtoupper($product->nutriscore_grade) }}<br>@endif
      @if ($product->nova_group)NOVA : {{ $product->nova_group }}<br>@endif
      <a href="https://world.openfoodfacts.org/product/{{ $product->barcode }}" target="_blank" rel="noopener">Voir sur Open Food Facts</a>
    </p>
  </div>

  <div>
    @if ($foreign)
      <p class="warn">Attention : au moins une source n'est pas marocaine. Vérifie que la recette correspond bien au produit vendu au Maroc.</p>
    @endif
    <form method="post" action="{{ route('review.validate', $product->id) }}">
      @csrf
      <label for="name">Nom</label>
      <input type="text" id="name" name="name" value="{{ old('name', $product->name) }}">
      <label for="brand">Marque</label>
      <input type="text" id="brand" name="brand" value="{{ old('brand', $product->brand) }}">
      <label for="ingredients_text">Ingrédients</label>
      <textarea id="ingredients_text" name="ingredients_text">{{ old('ingredients_text', $product->ingredients_text) }}</textarea>
      <label for="additives">Additifs <span class="muted">(ex. en:e330,en:e211, vide si aucun)</span></label>
      <input type="text" id="additives" name="additives" value="{{ old('additives', $product->additives) }}">
      <label for="allergens">Allergènes <span class="muted">(ex. en:milk,en:gluten)</span></label>
      <input type="text" id="allergens" name="allergens" value="{{ old('allergens', $product->allergens) }}">
      <label for="review_note">Note de revue <span class="muted">(facultatif, pour le bilan)</span></label>
      <input type="text" id="review_note" name="review_note" value="">
      <div class="btns">
        <button class="primary" type="submit">Valider (avec mes corrections)</button>
        <button class="danger" type="submit" formaction="{{ route('review.reject', $product->id) }}">Rejeter</button>
      </div>
    </form>
  </div>
</div>

<div class="card">
  <h3 style="margin-top:0">Sources trouvées</h3>
  @forelse ($sources as $s)
    <div class="src">
      <strong>{{ $s->field }}</strong>
      <span class="pill {{ $s->confidence }}">confiance {{ $s->confidence }}</span>
      <span class="muted">· {{ $typeLabels[$s->source_type] ?? $s->source_type }} · pays : {{ $s->source_country ?? '?' }}</span><br>
      <a href="{{ $s->source_url }}" target="_blank" rel="noopener">{{ \Illuminate\Support\Str::limit($s->source_url, 90) }}</a>
      <div style="white-space:pre-wrap;margin-top:4px">{{ $s->value }}</div>
      @if ($s->notes)<div class="muted">{{ $s->notes }}</div>@endif
    </div>
  @empty
    <p class="muted">Aucune source enregistrée pour cette fiche.</p>
  @endforelse
  @if ($run)
    <p class="muted">Recherche : {{ $run->outcome }} en {{ $run->duration_sec ?? '?' }} s{{ $run->review_result ? ' · revue : '.$run->review_result : '' }}</p>
  @endif
</div>
@endsection
