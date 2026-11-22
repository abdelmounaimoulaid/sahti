<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>@yield('title', 'Sahti admin')</title>
<style>
  :root { --bg:#f6f7f5; --card:#fff; --text:#1d2420; --muted:#5f6b64; --line:#dfe3df; --green:#1f7a4d; --green-bg:#e6f3ec; --amber:#8a5a00; --amber-bg:#fdf3dc; --red:#a3302a; --red-bg:#fbe9e7; }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--text); font:15px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; }
  header { background:var(--card); border-bottom:1px solid var(--line); padding:12px 20px; display:flex; gap:16px; align-items:center; }
  header a.brand { font-weight:700; color:var(--green); text-decoration:none; font-size:18px; }
  main { max-width:1100px; margin:0 auto; padding:20px 16px 60px; }
  a { color:var(--green); }
  .card { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:16px; margin-bottom:16px; }
  .tabs { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:16px; }
  .tabs a { padding:6px 12px; border-radius:999px; border:1px solid var(--line); background:var(--card); text-decoration:none; color:var(--text); }
  .tabs a.on { background:var(--green); border-color:var(--green); color:#fff; }
  table { width:100%; border-collapse:collapse; }
  th, td { text-align:left; padding:8px; border-bottom:1px solid var(--line); vertical-align:top; }
  th { font-size:13px; color:var(--muted); font-weight:600; }
  img.thumb { width:48px; height:48px; object-fit:contain; background:#fff; border:1px solid var(--line); border-radius:6px; }
  .ok { background:var(--green-bg); color:var(--green); padding:10px 14px; border-radius:8px; margin-bottom:16px; }
  .pill { display:inline-block; padding:1px 8px; border-radius:999px; font-size:12px; font-weight:600; }
  .pill.high { background:var(--green-bg); color:var(--green); }
  .pill.medium { background:var(--amber-bg); color:var(--amber); }
  .pill.low { background:var(--red-bg); color:var(--red); }
  .warn { background:var(--amber-bg); color:var(--amber); padding:8px 12px; border-radius:8px; }
  label { display:block; font-weight:600; margin:12px 0 4px; }
  input[type=text], textarea { width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:8px; font:inherit; background:#fff; }
  textarea { min-height:110px; }
  .row { display:grid; grid-template-columns: 220px 1fr; gap:20px; }
  @media (max-width: 760px) { .row { grid-template-columns: 1fr; } }
  .btns { display:flex; gap:10px; flex-wrap:wrap; margin-top:16px; }
  button { font:inherit; padding:9px 16px; border-radius:8px; border:1px solid transparent; cursor:pointer; }
  button.primary { background:var(--green); color:#fff; }
  button.danger { background:var(--card); color:var(--red); border-color:var(--red); }
  .muted { color:var(--muted); font-size:13px; }
  .src { border-top:1px solid var(--line); padding:10px 0; }
  .src:first-child { border-top:0; }
  .search { display:flex; gap:8px; margin-bottom:12px; }
  .search input { max-width:320px; }
</style>
</head>
<body>
<header><a class="brand" href="{{ route('review.index') }}">Sahti · validation</a><span class="muted">Admin local</span></header>
<main>
  @if (session('ok'))<div class="ok">{{ session('ok') }}</div>@endif
  @yield('content')
</main>
</body>
</html>
