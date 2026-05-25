<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>EatAlive</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #F7F7F4; font-family: 'Hiragino Sans', sans-serif; color: #222; min-height: 100vh; }
  .container { max-width: 480px; margin: 0 auto; padding: 24px 20px 80px; }
  h1 { font-size: 28px; font-weight: bold; margin-bottom: 4px; }
  .subtitle { color: #777; font-size: 13px; margin-bottom: 24px; }
  .hero { background: #FFF9D9; border-radius: 16px; padding: 18px; margin-bottom: 20px; border: 1px solid #E6E3DA; box-shadow: 0 3px 0 #EAE4DB; font-size: 14px; line-height: 1.6; }
  .card { background: white; border-radius: 16px; padding: 20px; margin-bottom: 14px; border: 1px solid #E6E3DA; box-shadow: 0 3px 0 #EAE4DB; }
  .card-label { font-size: 12px; color: #777; font-weight: bold; margin-bottom: 6px; }
  .card-title { font-size: 17px; font-weight: bold; margin-bottom: 12px; }
  label { display: block; font-size: 15px; font-weight: bold; margin-bottom: 4px; }
  .hint { font-size: 12px; color: #777; margin-bottom: 8px; }
  textarea, select { width: 100%; padding: 12px; border: 1px solid #E6E3DA; border-radius: 12px; font-size: 15px; font-family: inherit; background: white; resize: none; outline: none; }
  textarea:focus, select:focus { border-color: #E7D16A; }
  .slider-wrap { margin-bottom: 20px; }
  .slider-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
  .slider-name { font-size: 14px; font-weight: bold; }
  .slider-val { font-size: 16px; font-weight: bold; }
  input[type=range] { width: 100%; accent-color: #E7D16A; }
  .btn { width: 100%; padding: 16px; background: #E7D16A; border: none; border-radius: 16px; font-size: 18px; font-weight: bold; cursor: pointer; margin-top: 8px; }
  .btn:hover { background: #d4be55; }
  .btn-back { background: white; border: 1px solid #E6E3DA; font-size: 15px; padding: 10px; margin-bottom: 16px; width: auto; padding: 10px 20px; }
  .btn-green { background: #8CCFBC; }
  .emotion-bar { margin-bottom: 14px; }
  .bar-row { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
  .bar-label { width: 60px; font-size: 13px; font-weight: bold; }
  .bar-bg { flex: 1; height: 12px; background: #ECECEC; border-radius: 6px; overflow: hidden; }
  .bar-fill { height: 100%; border-radius: 6px; transition: width 0.3s; }
  .bar-num { width: 30px; font-size: 13px; font-weight: bold; text-align: right; }
  .nav { position: fixed; bottom: 0; left: 0; right: 0; background: white; border-top: 1px solid #E6E3DA; display: flex; max-width: 480px; margin: 0 auto; }
  .nav-btn { flex: 1; padding: 14px 0; border: none; background: none; font-size: 13px; font-weight: bold; color: #777; cursor: pointer; }
  .nav-btn.active { color: #222; background: #F2EEE7; }
  .result-item { margin-bottom: 14px; }
  .result-item .card-label { margin-bottom: 4px; }
  .result-item .text { font-size: 15px; line-height: 1.6; }
  .actions-list { font-size: 15px; line-height: 2; }
  .empty { color: #777; font-size: 14px; line-height: 1.8; }
  .record-item { border-bottom: 1px solid #F0EDE6; padding: 12px 0; }
  .record-item:last-child { border-bottom: none; }
  .record-date { font-size: 12px; color: #777; margin-bottom: 4px; }
  .record-emotions { font-size: 13px; color: #555; }
  .screen { display: none; }
  .screen.active { display: block; }
  .tag-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
  .tag { padding: 8px 14px; border-radius: 20px; border: 1px solid #E6E3DA; background: white; font-size: 13px; cursor: pointer; }
  .tag.selected { background: #E7D16A; border-color: #E7D16A; font-weight: bold; }
</style>
</head>
<body>

<!-- APIキー設定 -->
<div id="screen-apikey" class="screen active" style="display:flex;align-items:center;justify-content:center;min-height:100vh;">
<div class="container" style="padding-top:60px;">
  <h1>🌱 EatAlive</h1>
  <p class="subtitle" style="margin-bottom:24px;">まずOpenAI APIキーを入力してください</p>
  <div class="card">
    <label>APIキー</label>
    <p class="hint">sk- から始まるキーを入力してください。このデバイスにのみ保存されます。</p>
    <input type="password" id="apikey-input" placeholder="sk-..." style="width:100%;padding:12px;border:1px solid #E6E3DA;border-radius:12px;font-size:15px;margin-top:8px;">
  </div>
  <button class="btn" onclick="saveApiKey()" style="margin-top:8px;">保存してはじめる</button>
</div>
</div>


<div style="max-width:480px;margin:0 auto;">
<nav class="nav" style="position:fixed;bottom:0;left:50%;transform:translateX(-50%);width:100%;max-width:480px;">
  <button class="nav-btn active" onclick="showTab('home')" id="nav-home">ホーム</button>
  <button class="nav-btn" onclick="showTab('record')" id="nav-record">記録</button>
  <button class="nav-btn" onclick="showTab('community')" id="nav-community">コミュ</button>
  <button class="nav-btn" onclick="showTab('consult')" id="nav-consult">相談</button>
</nav>
</div>

<!-- ホーム -->
<div id="screen-home" class="screen active">
<div class="container">
  <h1>🌱 EatAlive</h1>
  <p class="subtitle">記録の流れと要因の関係を見える化</p>
  <div class="hero" id="home-insight">まだ記録がありません。まずは1件、気持ちの流れを残してみましょう。</div>

  <div class="card">
    <div class="card-title">最近の記録</div>
    <div id="home-records"><p class="empty">「記録」タブから最初の1件を入力してください。</p></div>
  </div>

  <button class="btn" onclick="showTab('record')">新しく記録する</button>
</div>
</div>

<!-- 記録入力 -->
<div id="screen-record" class="screen">
<div class="container">
  <div id="record-form">
    <h1>📝 記録する</h1>
    <p class="subtitle">今の出来事・気持ち・考えを見つめてみよう</p>

    <div class="card">
      <label>いま、どんな出来事がありましたか？</label>
      <p class="hint">短く具体的に書いてください。</p>
      <textarea id="situation" rows="3" placeholder="例：夕食後に食べすぎた気がした"></textarea>
    </div>

    <div class="card">
      <label>その瞬間、頭に浮かんだ言葉は？</label>
      <p class="hint">「また太る」「私はダメ」など、そのままの言葉で。</p>
      <textarea id="thought" rows="3" placeholder="例：また食べすぎた、最低だ"></textarea>
    </div>

    <div class="card">
      <label>そのあと、どう行動しましたか？</label>
      <p class="hint">食べた / SNSを見た / 寝た など。</p>
      <textarea id="behavior" rows="3" placeholder="例：そのままお菓子をさらに食べた"></textarea>
    </div>

    <div class="card">
      <label>何が引き金に近かったですか？</label>
      <div class="tag-row" id="trigger-tags">
        <div class="tag selected" onclick="selectTag(this)">食事</div>
        <div class="tag" onclick="selectTag(this)">体重</div>
        <div class="tag" onclick="selectTag(this)">SNS</div>
        <div class="tag" onclick="selectTag(this)">人間関係</div>
        <div class="tag" onclick="selectTag(this)">孤独</div>
        <div class="tag" onclick="selectTag(this)">疲れ</div>
      </div>
    </div>

    <div class="card">
      <label>感情の強さを教えてください</label>
      <div class="slider-wrap">
        <div class="slider-header">
          <span class="slider-name" style="color:#F1A7C4;">罪悪感</span>
          <span class="slider-val" id="guilt-val" style="color:#F1A7C4;">70</span>
        </div>
        <input type="range" min="0" max="100" value="70" id="guilt" oninput="document.getElementById('guilt-val').textContent=this.value">
      </div>
      <div class="slider-wrap">
        <div class="slider-header">
          <span class="slider-name" style="color:#C7B8F3;">不安</span>
          <span class="slider-val" id="anxiety-val" style="color:#C7B8F3;">55</span>
        </div>
        <input type="range" min="0" max="100" value="55" id="anxiety" oninput="document.getElementById('anxiety-val').textContent=this.value">
      </div>
      <div class="slider-wrap">
        <div class="slider-header">
          <span class="slider-name" style="color:#8CCFBC;">安心</span>
          <span class="slider-val" id="calm-val" style="color:#8CCFBC;">10</span>
        </div>
        <input type="range" min="0" max="100" value="10" id="calm" oninput="document.getElementById('calm-val').textContent=this.value">
      </div>
    </div>

    <button class="btn" onclick="runAnalysis()">AIで振り返る</button>
    <p style="text-align:center;font-size:12px;color:#777;margin-top:12px;">※ 現在はルールベースの試作版です。</p>
  </div>

  <!-- 結果 -->
  <div id="record-result" style="display:none;">
    <button class="btn btn-back" onclick="showForm()">← 新しく記録する</button>
    <h1>💡 AIサポート結果</h1>
    <p class="subtitle">記録 → 分析 → 気づき → 次の一歩</p>

    <div class="hero" id="result-summary"></div>

    <div class="card">
      <div class="card-label">感情スコア</div>
      <div class="emotion-bar">
        <div class="bar-row">
          <span class="bar-label" style="color:#F1A7C4;">罪悪感</span>
          <div class="bar-bg"><div class="bar-fill" id="bar-guilt" style="background:#F1A7C4;"></div></div>
          <span class="bar-num" id="num-guilt"></span>
        </div>
        <div class="bar-row">
          <span class="bar-label" style="color:#C7B8F3;">不安</span>
          <div class="bar-bg"><div class="bar-fill" id="bar-anxiety" style="background:#C7B8F3;"></div></div>
          <span class="bar-num" id="num-anxiety"></span>
        </div>
        <div class="bar-row">
          <span class="bar-label" style="color:#8CCFBC;">安心</span>
          <div class="bar-bg"><div class="bar-fill" id="bar-calm" style="background:#8CCFBC;"></div></div>
          <span class="bar-num" id="num-calm"></span>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="result-item"><div class="card-label">状況</div><div class="text" id="res-situation"></div></div>
      <div class="result-item"><div class="card-label">自動思考</div><div class="text" id="res-thought"></div></div>
      <div class="result-item"><div class="card-label">実際の行動</div><div class="text" id="res-behavior"></div></div>
    </div>

    <div class="card">
      <div class="result-item"><div class="card-label">思考のパターン</div><div class="text" id="res-pattern"></div></div>
      <div class="result-item"><div class="card-label">別の考え方</div><div class="text" id="res-reframe"></div></div>
    </div>

    <div class="card">
      <div class="card-label">今できる行動</div>
      <div class="actions-list" id="res-actions"></div>
    </div>
  </div>
</div>
</div>

<!-- コミュニティ -->
<div id="screen-community" class="screen">
<div class="container">
  <h1>💬 コミュニティ</h1>
  <p class="subtitle">同じ悩みを持つ人の声に、安心して触れられる場所</p>
  <div class="hero">UIデモです。匿名で気持ちを共有し、同じテーマの部屋に参加できる想定です。</div>
  <div class="card"><div class="card-title">夜の過食衝動</div><p style="color:#777;font-size:13px;">夜に衝動が強くなる人向け / 128人</p></div>
  <div class="card"><div class="card-title">食後の罪悪感</div><p style="color:#777;font-size:13px;">食べた後の気持ちを共有 / 94人</p></div>
  <div class="card"><div class="card-title">SNS比較に疲れた</div><p style="color:#777;font-size:13px;">比較で苦しくなる人向け / 76人</p></div>
  <div class="card"><div class="card-title">ひとりで抱えない練習</div><p style="color:#777;font-size:13px;">孤独感が強い時の避難所 / 61人</p></div>
</div>
</div>

<!-- 相談 -->
<div id="screen-consult" class="screen">
<div class="container">
  <h1>🤝 心理士に相談</h1>
  <p class="subtitle">話すハードルを下げる相談導線のUIデモ</p>
  <div class="hero" style="background:#EEF6FF;">UIデモです。匿名チャット → 予約相談 → 継続支援へ進める想定です。</div>
  <div class="card"><div class="card-title">山田 心理士</div><p style="color:#777;font-size:13px;">摂食行動・自己批判・不安</p><p style="font-size:13px;margin-top:6px;">最短 今日 19:30</p></div>
  <div class="card"><div class="card-title">佐藤 心理士</div><p style="color:#777;font-size:13px;">家族支援・孤独感・比較ストレス</p><p style="font-size:13px;margin-top:6px;">最短 明日 11:00</p></div>
  <div class="card" style="background:#FFF4F4;"><p style="font-size:13px;line-height:1.8;">緊急時はこのアプリ内ではなく、地域の医療機関・公的相談窓口の利用を優先してください。</p></div>
</div>
</div>

<script>
let records = JSON.parse(localStorage.getItem('eatAliveRecords') || '[]');

function showTab(tab) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('screen-' + tab).classList.add('active');
  document.getElementById('nav-' + tab).classList.add('active');
  if (tab === 'home') updateHome();
}

function selectTag(el) {
  document.querySelectorAll('#trigger-tags .tag').forEach(t => t.classList.remove('selected'));
  el.classList.add('selected');
}

function getSelectedTrigger() {
  const sel = document.querySelector('#trigger-tags .tag.selected');
  return sel ? sel.textContent : '食事';
}

function detectPattern(thought) {
  if (!thought) return '思考の偏りの可能性';
  if (thought.includes('ダメ') || thought.includes('価値がない')) return '自己批判が強い状態';
  if (thought.includes('また太る') || thought.includes('終わり') || thought.includes('絶対')) return '全か無か思考';
  if (thought.includes('きっと') || thought.includes('どうせ')) return '先読みしすぎ';
  return '思考の偏りの可能性';
}

function reframe(thought, trigger) {
  if (!thought) return '今の考えは事実そのものではなく、その瞬間の解釈かもしれません。';
  if (thought.includes('太る')) return '1回の食事で体型や価値は決まりません。';
  if (thought.includes('ダメ') || thought.includes('価値がない')) return '今つらいだけで、あなたの価値そのものは下がりません。';
  if (trigger === 'SNS') return 'SNSは比較を強めやすいので、見た内容と現実を分けて考えましょう。';
  if (trigger === '孤独') return '孤独が強いときは、食べること以外の安心行動も選べます。';
  return '今の考えは事実そのものではなく、その瞬間の解釈かもしれません。';
}

function aiSummary(entry) {
  if (entry.guilt >= 70 && entry.anxiety >= 60)
    return `自分を責める気持ちと不安が強い状態です。特に「${entry.trigger}」が引き金になっている可能性があります。`;
  if (entry.guilt >= 70) return 'いまは罪悪感が強く、自分を厳しく裁いてしまいやすい状態です。';
  if (entry.anxiety >= 70) return 'いまは不安が強く、先のことを悪い方向に考えやすい状態です。';
  if (entry.calm >= 50) return '比較的落ち着いて振り返れている状態です。';
  return '感情が揺れているタイミングです。出来事と思考を切り分けることが役立ちます。';
}

function actionsFor(entry) {
  const acts = [];
  if (entry.trigger === 'SNS') acts.push('SNSを10分閉じる');
  if (entry.anxiety >= 50) acts.push('3分だけ深呼吸する');
  if (entry.guilt >= 60) acts.push('責める言葉を1つやわらかく言い換える');
  if (entry.calm <= 20) acts.push('温かい飲み物を飲む');
  if (acts.length === 0) { acts.push('今の気持ちを1行だけ書く'); acts.push('5分休む'); }
  return acts.slice(0, 3);
}

function runAnalysis() {
  const entry = {
    date: new Date().toLocaleString('ja-JP'),
    situation: document.getElementById('situation').value,
    thought: document.getElementById('thought').value,
    behavior: document.getElementById('behavior').value,
    trigger: getSelectedTrigger(),
    guilt: parseInt(document.getElementById('guilt').value),
    anxiety: parseInt(document.getElementById('anxiety').value),
    calm: parseInt(document.getElementById('calm').value),
  };

  records.unshift(entry);
  localStorage.setItem('eatAliveRecords', JSON.stringify(records));

  document.getElementById('result-summary').textContent = aiSummary(entry);
  document.getElementById('bar-guilt').style.width = entry.guilt + '%';
  document.getElementById('bar-anxiety').style.width = entry.anxiety + '%';
  document.getElementById('bar-calm').style.width = entry.calm + '%';
  document.getElementById('num-guilt').textContent = entry.guilt;
  document.getElementById('num-anxiety').textContent = entry.anxiety;
  document.getElementById('num-calm').textContent = entry.calm;
  document.getElementById('res-situation').textContent = entry.situation || '未入力';
  document.getElementById('res-thought').textContent = entry.thought || '未入力';
  document.getElementById('res-behavior').textContent = entry.behavior || '未入力';
  document.getElementById('res-pattern').textContent = detectPattern(entry.thought);
  document.getElementById('res-reframe').textContent = reframe(entry.thought, entry.trigger);
  document.getElementById('res-actions').innerHTML = actionsFor(entry).map(a => `・${a}<br>`).join('');

  document.getElementById('record-form').style.display = 'none';
  document.getElementById('record-result').style.display = 'block';
}

function showForm() {
  document.getElementById('record-form').style.display = 'block';
  document.getElementById('record-result').style.display = 'none';
}

function updateHome() {
  if (records.length === 0) return;
  const counts = {};
  records.forEach(r => counts[r.trigger] = (counts[r.trigger] || 0) + 1);
  const top = Object.entries(counts).sort((a,b) => b[1]-a[1])[0][0];
  const latest = records[0];
  document.getElementById('home-insight').textContent =
    `直近の傾向では「${top}」が引き金として多め。最新は 罪悪感${latest.guilt} / 不安${latest.anxiety} / 安心${latest.calm}。`;

  const html = records.slice(0,3).map(r => `
    <div class="record-item">
      <div class="record-date">${r.date} / ${r.trigger}</div>
      <div class="record-emotions">罪悪感 ${r.guilt} ・ 不安 ${r.anxiety} ・ 安心 ${r.calm}</div>
    </div>
  `).join('');
  document.getElementById('home-records').innerHTML = html;
}

updateHome();

function saveApiKey() {
  const key = document.getElementById('apikey-input').value.trim();
  if (!key.startsWith('sk-')) {
    alert('正しいAPIキーを入力してください（sk-で始まります）');
    return;
  }
  localStorage.setItem('eatAliveApiKey', key);
  document.getElementById('screen-apikey').style.display = 'none';
  showTab('home');
}

// APIキーが既に保存されていればスキップ
window.addEventListener('load', function() {
  if (localStorage.getItem('eatAliveApiKey')) {
    document.getElementById('screen-apikey').style.display = 'none';
    showTab('home');
  }
});

</script>
</body>
</html>
