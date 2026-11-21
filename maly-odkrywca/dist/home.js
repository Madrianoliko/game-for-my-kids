(() => {
  'use strict';

  const worlds = [
    { title: ['Dolina', 'Hobbitów'], icon: 'leaf', art: 'valley', card: 'hillhouse', story: 'Pomóż Leo naprawić most i odnaleźć gwiazdki ukryte w dolinie.' },
    { title: ['Hot', 'Wheels'], icon: 'flag', art: 'race', card: 'race', story: 'W przygotowaniu: wyprawa po pomarańczowym torze.' },
    { title: ['Harry', 'Potter'], icon: 'star', art: 'magic', card: 'magic', story: 'W przygotowaniu: tajemnica zamku i magiczne zagadki.' }
  ];
  const get = id => document.getElementById(id);
  const svg = (name, extra = '') => '<svg class="icon ' + extra + '" aria-hidden="true"><use href="#i-' + name + '"/></svg>';
  const label = i => 'Świat 0' + (i + 1);
  const name = i => worlds[i].title.join(' ');
  const key = 'maly-odkrywca.v1';
  let scores = [0, 0, 0];
  let sound = true;
  let chosen = 0;
  let audio = null;
  let voice = null;
  let mode = null;
  let returnFocus = null;
  const read = () => {
    try {
      const v = JSON.parse(localStorage.getItem(key));
      if (!v) return;
      if (Array.isArray(v.scores)) scores = scores.map((value, i) => Math.max(0, Math.min(3, parseInt(v.scores[i], 10) || 0)));
      if (typeof v.sound === 'boolean') sound = v.sound;
    } catch {}
  };
  const save = () => {
    try { localStorage.setItem(key, JSON.stringify({scores, sound})); } catch {}
  };

  function primeAudio() {
    if (!sound) return;
    try {
      const Context = window.AudioContext || window.webkitAudioContext;
      if (!Context) return;
      if (!audio) audio = new Context();
      if (audio.state === 'suspended') audio.resume().catch(() => {});
    } catch {}
  }
  window.isAdventureSoundEnabled = () => sound;
  window.adventureSound = type => {
    if (!sound) return;
    primeAudio();
    if (!audio || audio.state !== 'running') return;
    const notes = type === 'complete' ? [523.25,659.25,783.99,1046.50] : type === 'correct' ? [659.25,880] : [523.25];
    const start = audio.currentTime;
    notes.forEach((freq, i) => {
      const osc = audio.createOscillator();
      const gain = audio.createGain();
      const at = start + i * .11;
      osc.type = 'sine';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(.0001, at);
      gain.gain.exponentialRampToValueAtTime(.075, at + .009);
      gain.gain.exponentialRampToValueAtTime(.0001, at + .19);
      osc.connect(gain); gain.connect(audio.destination);
      osc.start(at); osc.stop(at + .2);
      osc.onended = () => { osc.disconnect(); gain.disconnect(); };
    });
  };
  const speech = 'speechSynthesis' in window ? window.speechSynthesis : null;
  const findVoice = () => {
    if (!speech) return;
    voice = speech.getVoices().find(v => /^pl([_-]|$)/i.test(v.lang)) || null;
  };
  findVoice();
  speech?.addEventListener?.('voiceschanged', findVoice);
  window.adventureVoice = text => {
    if (!speech || !sound || !text) return;
    try {
      speech.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'pl-PL';
      if (voice) utterance.voice = voice;
      utterance.rate = .86;
      speech.speak(utterance);
    } catch {}
  };
  function setSound(enabled) {
    sound = enabled;
    if (!sound) speech?.cancel();
    save();
    get('sound').innerHTML = svg(sound ? 'sound' : 'mute');
    get('sound').setAttribute('aria-pressed', String(sound));
    get('sound').setAttribute('aria-label', sound ? 'Wyłącz dźwięk' : 'Włącz dźwięk');
    if (sound) window.adventureSound('tap');
  }
  window.toggleAdventureSound = () => setSound(!sound);
  window.adventureScores = () => [...scores];
  window.adventureCheckpoint = (i, collected) => {
    if (!Number.isInteger(i) || i < 0 || i >= worlds.length || !Number.isInteger(collected)) return;
    scores[i] = Math.max(scores[i], Math.min(3, collected));
    save();
    updateProgress();
  };
  window.adventureCompleted = i => window.adventureCheckpoint(i, 3);

  function starRow(i) {
    if(i) return '<span class="card-stars upcoming">Wkrótce</span>';
    return '<span class="card-stars" aria-hidden="true">' + [1,2,3].map(n => svg('star', n <= scores[i] ? 'earned' : '')).join('') + '</span>';
  }
  function updateProgress() {
    const total = scores.reduce((sum, n) => sum + n, 0);
    get('total').textContent = total;
    get('open-stars').setAttribute('aria-label', 'Twoje gwiazdki, ' + total + ' z 3');
    [...get('world-grid').children].forEach((button, i) => {
      button.querySelector('.card-stars').outerHTML = starRow(i);
      button.setAttribute('aria-label', name(i) + ', gwiazdki ' + scores[i] + ' z 3. Wybierz świat.');
    });
    if (mode === 'stars') renderStars();
  }
  function selectWorld(i, respond = true) {
    chosen = i;
    get('play').disabled = i !== 0;
    get('play').querySelector('span').textContent = i ? 'W przygotowaniu' : 'Rozpocznij przygodę';
    const w = worlds[i];
    get('hero').dataset.world = i;
    get('hero-art').src = 'assets/' + w.art + '.webp';
    get('title-one').textContent = w.title[0];
    get('title-two').textContent = w.title[1];
    get('hero-kicker').textContent = label(i);
    get('hero-symbol').setAttribute('href', '#i-' + w.icon);
    get('world-story').textContent = w.story;
    [...get('world-grid').children].forEach((b, n) => b.setAttribute('aria-pressed', String(n === i)));
    [...get('hero-pages').children].forEach((b, n) => {
      b.classList.toggle('is-active', i === n);
      b.setAttribute('aria-pressed', String(n === i));
    });
    if (respond) window.adventureVoice(name(i) + '. ' + w.story);
  }

  read();
  get('world-grid').innerHTML = worlds.map((w, i) =>
    '<button class="world-card" type="button" aria-controls="hero"><span class="card-image"><img src="assets/' + w.card + '.webp" alt=""><span class="card-index">' + label(i) + '</span><span class="card-check">' + svg('check') + '</span></span><span class="card-text"><span class="card-title">' + name(i) + '</span>' + starRow(i) + '</span></button>'
  ).join('');
  [...get('world-grid').children].forEach((button, i) => button.addEventListener('click', () => {
    selectWorld(i);
    if (window.matchMedia('(max-width:600px)').matches) get('hero').scrollIntoView({behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth', block:'start'});
  }));
  worlds.forEach((w, i) => {
    const b = document.createElement('button');
    b.className = 'page-dot'; b.type = 'button';
    b.setAttribute('aria-label', 'Pokaż świat ' + name(i));
    b.addEventListener('click', () => selectWorld(i));
    get('hero-pages').append(b);
  });
  const dialog = get('menu-dialog');
  function renderStars() {
    get('modal-body').innerHTML = worlds.map((w, i) => '<div class="progress-row"><span>' + name(i) + '</span>' + starRow(i) + '<span class="sr-only">' + scores[i] + ' z 3</span></div>').join('');
  }
  function showDialog(type) {
    mode = type;
    returnFocus = document.activeElement;
    get('modal-title').textContent = type === 'help' ? 'Jak grać?' : 'Twoje gwiazdki';
    get('modal-done').textContent = type === 'help' ? 'Rozumiem' : 'Wróć do mapy';
    if (type === 'stars') renderStars();
    else get('modal-body').innerHTML =
      '<div class="help-step">' + svg('map') + '<span>Wybierz świat i rozpocznij przygodę z Leo.</span></div>' +
      '<div class="help-step">' + svg('hand') + '<span>Prowadź Leo jedną gałką. W zadaniach dotknij jednej z czterech liczb.</span></div>' +
      '<div class="help-step">' + svg('prize') + '<span>Za każdą pokonaną przeszkodę zdobędziesz gwiazdkę.</span></div>';
    dialog.showModal();
    window.adventureVoice(type === 'help' ? 'Wybierz świat i rozpocznij przygodę z Leo. Prowadź Leo jedną gałką. W zadaniach dotknij jednej z czterech liczb. Za każdą pokonaną przeszkodę zdobędziesz gwiazdkę.' : 'Masz ' + scores.reduce((a,b)=>a+b,0) + ' z trzech gwiazdek.');
  }
  get('open-stars').addEventListener('click', () => showDialog('stars'));
  get('help').addEventListener('click', () => showDialog('help'));
  get('modal-done').addEventListener('click', () => dialog.close());
  get('modal-close').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', e => { if (e.target === dialog && (e.clientX < dialog.getBoundingClientRect().left || e.clientX > dialog.getBoundingClientRect().right || e.clientY < dialog.getBoundingClientRect().top || e.clientY > dialog.getBoundingClientRect().bottom)) dialog.close(); });
  dialog.addEventListener('close', () => { mode = null; speech?.cancel(); returnFocus?.focus(); });
  get('sound').innerHTML = svg(sound ? 'sound' : 'mute');
  get('sound').setAttribute('aria-pressed', String(sound));
  get('sound').setAttribute('aria-label', sound ? 'Wyłącz dźwięk' : 'Włącz dźwięk');
  get('sound').addEventListener('click', window.toggleAdventureSound);
  get('play').addEventListener('click', () => {
    primeAudio();
    if (!chosen) window.startHobbitAdventure();
  });
  updateProgress();
  selectWorld(0, false);
})();
