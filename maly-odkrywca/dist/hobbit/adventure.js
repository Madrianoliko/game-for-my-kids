(() => {
  'use strict';

  const valleyName = 'Dolina Hobbitów';
  const trail = [
    {
      place: 'Most nad potokiem', question: 'Ilu desek potrzeba na most?',
      intro: 'Bóbr narysował plan mostu. Policz deski na jego rysunku.',
      instruction: 'Wybierz liczbę desek z planu.',
      token: 'plank', object: 'Deska', done: 'Most gotowy!', story: 'Leo przechodzi na drugi brzeg. Iskierka jedzie w jego plecaku.'
    },
    {
      place: 'Kamienna ścieżka', question: 'Połącz kamienie',
      intro: 'Za mostem jest błoto! Z dwóch kupek kamieni zbudujesz dla Leo suchą ścieżkę.',
      instruction: 'Dotknij obu kupek kamieni.',
      token: 'stone', object: 'Kamień', done: 'Ścieżka gotowa!', story: 'Leo skacze po kamieniach aż do bramy wioski.'
    },
    {
      place: 'Brama wioski', question: 'Ile jest razem latarenek?',
      intro: 'Leo wyjmuje z plecaka iskierkę. Policz latarenki po obu stronach bramy.',
      instruction: 'Dodaj obie grupy i dotknij wyniku.',
      token: 'lamp', object: 'Latarenka', done: 'Wioska rozświetlona!', story: 'Pod wzgórzem otwierają się okrągłe drzwi. Hobbici machają do Leo!'
    }
  ];
  const icons = {
    star: '<path d="m24 4 5.5 12.1 13.1 1.6-9.8 9 2.6 13.2L24 33.3l-11.4 6.6 2.6-13.2-9.8-9 13.1-1.6z" fill="currentColor" stroke="currentColor" stroke-width="2.4" stroke-linejoin="round"/>',
    plank: '<g transform="rotate(-21 24 24)" stroke-linejoin="round"><path d="M3 18 10 13h35v16l-7 6H3z" fill="#99532d"/><path d="M3 18h35v17H3z" fill="#d58a48"/><path d="m3 18 7-5h35l-7 5z" fill="#f6bd71"/><path d="M8 23h15m2 6h9M7 28h7" fill="none" stroke="#ac622f" stroke-width="2.2" stroke-linecap="round"/><circle cx="33" cy="22" r="1.5" fill="#6b462d"/></g>',
    stone: '<path d="m4 28 6-14 15-7 15 6 5 18-10 9-21 1-10-7z" fill="#7f9aac"/><path d="m4 28 13-6 8-15-15 7z" fill="#b7d1d4"/><path d="m17 22 18-5 5-4-15-6z" fill="#d7e3df"/><path d="m17 22 18-5 10 14-10 9z" fill="#94aab7"/><path d="m4 28 13-6 18 18-21 1-10-7z" fill="#71899d"/>',
    lamp: '<path d="M17 12V9a7 7 0 0 1 14 0v3" fill="none" stroke="#a5bbbc" stroke-width="3"/><path d="m10 16 7-6h14l7 6-2 3H12z" fill="#69a995"/><path d="m13 18 2 17 8 6 10-6 2-17z" fill="#ffba45" stroke="#6b7366" stroke-width="3"/><path d="m23 22-4 7 4 5 5-6z" fill="#fff8a9"/><path d="m11 37 5-3 15 1 5 2-1 3-12 4-11-4z" fill="#5f927e"/>',
    speaker: '<path d="M8 18h8l9-7v26l-9-7H8z" fill="currentColor"/><g fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><path d="M31 18a9 9 0 0 1 0 12m6-18a17 17 0 0 1 0 24"/></g>',
    pause: '<rect x="11" y="8" width="10" height="32" rx="3" fill="currentColor"/><rect x="27" y="8" width="10" height="32" rx="3" fill="currentColor"/>',
    play: '<path d="M14 9c0-2 2-3 4-2l23 15c2 1 2 3 0 4L18 41c-2 1-4 0-4-2z" fill="currentColor"/>',
    compass: '<circle cx="24" cy="24" r="17" fill="none" stroke="currentColor" stroke-width="3"/><path d="m33 14-5 15-13 6 6-16z" fill="currentColor"/><circle cx="24" cy="24" r="2" fill="#211b33"/>',
    retry: '<path d="M12 18a15 15 0 1 1-1 14m1-23v10h10" fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>',
    plus: '<path d="M11 24h26M24 11v26" stroke="currentColor" fill="none" stroke-width="5" stroke-linecap="round"/>',
    hand: '<path d="M15 24V10a3 3 0 0 1 6 0v11-4a3 3 0 0 1 6 0v4-2a3 3 0 1 1 6 0v3a3 3 0 0 1 6 0v6c0 8-5 14-12 14h-2c-6 0-8-3-12-8l-5-7a3 3 0 0 1 5-3l2 2z" fill="none" stroke="currentColor" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>'
  };
  const svg = (name) => '<svg aria-hidden="true" viewBox="0 0 48 48" focusable="false">' + icons[name] + '</svg>';
  const random = (min, max) => min + Math.floor(Math.random() * (max - min + 1));

  function answerChoices(total) {
    const nearby=Array.from({length:15},(_,i)=>i+1).filter(n=>n!==total).sort((a,b)=>Math.abs(a-total)-Math.abs(b-total));
    const choices=[total,...nearby.slice(0,3)];
    for (let i = choices.length - 1; i > 0; i--) {
      const j = random(0, i);
      [choices[i], choices[j]] = [choices[j], choices[i]];
    }
    return choices;
  }

  function buildStages(best) {
    const sets = [
      [best===3?15:random(3+best,6+best)],
      [3,3],
      [random(1,3+best),random(1,4+best)]
    ];
    return trail.map((stage, index) => {
      const total = sets[index].reduce((sum, n) => sum + n, 0);
      return { ...stage, sets: sets[index], total, choices: answerChoices(total) };
    });
  }

  let session;
  window.startHobbitAdventure = function startHobbitAdventure() {
    if (session) session.close(false);
    const score = window.adventureScores?.()[0] || 0;
    const stages = buildStages(Math.min(3, Math.max(0, Math.trunc(Number(score)) || 0)));
    const previouslyFocused = document.activeElement;
    const previousScroll = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    const root = document.createElement('dialog');
    root.className = 'adv-game';
    root.setAttribute('aria-label', 'Przygoda Leo — ' + valleyName);
    root.innerHTML = `<div class="adv-viewport">
      <div class="adv-scenery"><canvas class="adv-canvas" aria-label="Leo na trasie przygody"></canvas></div>
      <header class="adv-hud">
        <div class="adv-world-label"><span class="adv-compass">${svg('compass')}</span><strong>${valleyName}</strong></div>
        <div class="adv-hud-actions"><div class="adv-meter" aria-label="Zebrane gwiazdki"></div>
        <button type="button" class="adv-icon-button adv-pause" aria-label="Pauza">${svg('pause')}</button></div>
      </header>
      <div class="walk-stick"></div><div class="walk-hint" role="status"></div><div class="adv-dock"></div><div class="adv-shade" hidden></div>
    </div>`;
    document.body.append(root);
    if (typeof root.showModal === 'function') root.showModal();
    else root.setAttribute('open', '');
    const canvas = root.querySelector('canvas');
    const dock = root.querySelector('.adv-dock');
    const shade = root.querySelector('.adv-shade');
    const meter = root.querySelector('.adv-meter');
    const pauseButton = root.querySelector('.adv-pause');
    let renderer = null;
    let stageIndex = 0;
    let collected = 0;
    let phase = 'question';
    let paused = false;
    let dismissed = false;
    let timer;
    let queuedAction = null;
    let focusBeforePause;
    const sound = name => window.adventureSound?.(name);
    const voice = message => window.adventureVoice?.(message);
    const quiet = () => window.speechSynthesis?.cancel();
    const present = () => !dismissed && root.isConnected;
    try {
      renderer = new window.AdventureScene(canvas, 0, stages.map(stage => stage.sets));
    } catch {
      root.classList.add('adv-illustrated');
    }
    const stickHost=root.querySelector('.walk-stick');
    const hint=root.querySelector('.walk-hint');
    const stick=new window.AdventureStick(stickHost,(x,y)=>renderer?.setInput(x,y));
    function walk(text,method,callback) {
      phase='travel';root.dataset.phase='travel';dock.innerHTML='';
      stickHost.hidden=false;hint.hidden=false;hint.textContent=text;stick.setEnabled(true);
      voice(text);
      method(()=>{
        stick.setEnabled(false);stickHost.hidden=true;hint.hidden=true;callback();
      });
    }
    function close(restoreFocus = true) {
      if (dismissed) return;
      dismissed = true;
      window.clearTimeout(timer);
      quiet();
      document.removeEventListener('visibilitychange', visibilityChanged);
      stick.destroy();renderer?.destroy();
      if (root.open && typeof root.close === 'function') root.close();
      root.remove();
      document.body.style.overflow = previousScroll;
      if (restoreFocus && previouslyFocused?.isConnected) previouslyFocused.focus({ preventScroll: true });
      if (session?.close === close) session = null;
    }
    session = { close };

    function safeAction(action) {
      if (!present()) return;
      if (paused) queuedAction = action;
      else action();
    }
    function later(action, ms) {
      window.clearTimeout(timer);
      timer = window.setTimeout(() => safeAction(action), ms);
    }
    function updateMeter() {
      meter.innerHTML = [1, 2, 3, 4].map(n => '<span class="' + (n <= collected ? 'adv-lit' : '') + '">' + svg('star') + '</span>').join('');
      meter.setAttribute('aria-label', 'Gwiazdki: ' + collected + ' z 4');
    }
    function readQuestion(full = true) {
      const stage = stages[stageIndex];
      const hint = dock.querySelector('.adv-instruction span')?.textContent || stage.instruction;
      const equation = dock.querySelector('.adv-equation') && !dock.querySelector('[data-pile]') ? stage.sets[0] + ' plus ' + stage.sets[1] + '. ' : '';
      voice((full ? stage.intro + ' ' : '') + equation + hint);
    }
    function wrapBunches(items) {
      const bunches = [];
      for (let i = 0; i < items.length; i += 5) {
        bunches.push('<span class="adv-bunch">' + items.slice(i, i + 5).join('') + '</span>');
      }
      return bunches.join('');
    }
    function buildPieces(n, stage) {
      const items = Array.from({ length: n }, () =>
        `<span class="adv-token" role="img" aria-label="${stage.object}">${svg(stage.token)}</span>`);
      return `<div class="adv-set">${wrapBunches(items)}</div>`;
    }
    function showQuestion() {
      if (!present()) return;
      phase='question';root.dataset.phase='question';
      const stage=stages[stageIndex],isAddition=stageIndex===2;
      const planks=Array.from({length:stage.total},(_,i)=>`<rect class="drawn-plank" x="${15+i*17}" y="13" width="13" height="40" rx="2"/>`).join('');
      const width=stage.total*17+27;
      const plan=`<figure class="bridge-plan"><figcaption>Plan bobra</figcaption><svg role="img" aria-label="Plan mostu, ${stage.total} desek" viewBox="0 0 ${width} 66"><path d="M5 23H${width-5} M5 44H${width-5}" stroke="#bacfc8" stroke-width="3"/>${planks}</svg></figure>`;
      const pieces=stage.sets.map(n=>buildPieces(n,stage)).join('<span class="adv-plus">+</span>');
      dock.innerHTML = `<section class="adv-card" aria-labelledby="adv-question">
        <div class="adv-card-head">
          <div><div class="adv-place">Przystanek ${stageIndex + 1}/4 <span>·</span> ${stage.place}</div>
          <h2 id="adv-question" tabindex="-1">${stage.question}</h2></div>
          <button class="adv-icon-button adv-listen" type="button" aria-label="Posłuchaj zadania" title="Posłuchaj zadania">${svg('speaker')}</button>
        </div>
        ${isAddition ? '<div class="adv-equation" aria-label="Działanie">' + stage.sets[0] + ' <span>+</span> ' + stage.sets[1] + ' <span>=</span> ?</div>' : ''}
        ${!isAddition ? plan : `<div class="adv-pieces ${isAddition ? 'adv-add' : 'adv-count'}">${pieces}</div>`}
        <div class="adv-instruction" role="status">${svg('hand')}<span>${stage.instruction}</span></div>
        ${'<div class="adv-options" role="group" aria-label="Wybierz odpowiedź">' + stage.choices.map(num => '<button type="button" data-answer="' + num + '">' + num + '</button>').join('') + '</div>'}
      </section>`;
      dock.querySelector('.adv-listen').addEventListener('click', () => {
        if (window.isAdventureSoundEnabled?.() === false) {
          showHint('Lektor jest wyłączony. Włącz dźwięk na mapie.');
          return;
        }
        readQuestion();
      });
      dock.querySelectorAll('[data-answer]').forEach(button => button.addEventListener('click', () => choose(button, stage)));
      dock.querySelector('h2').focus({ preventScroll: true });
      readQuestion();
    }
    function showHint(text) {
      const hint = dock.querySelector('.adv-instruction span');
      if (hint) hint.textContent = text;
    }
    function choose(button, stage) {
      if (paused || phase !== 'question' || dock.querySelector('.adv-options').hidden) return;
      if (Number(button.dataset.answer) !== stage.total) {
        sound('tap');
        const hint = stageIndex===0 ? 'Spójrz na plan bobra. Policz deski jeszcze raz.' : 'Policz latarenki w obu grupach i spróbuj jeszcze raz.';
        showHint(hint);
        voice(hint);
        button.classList.remove('adv-try');
        void button.offsetWidth;
        button.classList.add('adv-try');
        return;
      }
      reward(stage);
    }
    function reward(stage) {
      phase = 'success';
      collected++;
      window.adventureCheckpoint?.(0, collected);
      sound('correct');
      voice(stage.done + ' ' + stage.story);
      updateMeter();
      root.dataset.phase = 'success';
      dock.innerHTML = `<section class="adv-success" role="status"><span class="adv-earned-star">${svg('star')}</span><div><div class="adv-place">Gwiazdka ${collected} z 4</div><h2>${stage.done}</h2><p>${stage.story}</p></div></section>`;
      later(travel, 900);
    }
    function travel() {
      if (collected===2) {stageIndex=2;showQuestion();return;}
      if (collected===3) {
        walk('Przejdź przez bramę do sadu',cb=>renderer.advance(3,cb),()=>{
          walk('Zbierz trzy jabłka na placek',cb=>renderer.orchard(n=>{
            hint.textContent='Jabłka w koszyku: '+n+' z 3';
            sound('correct');
          },cb),()=>reward({done:'Koszyk pełny!',story:'Leo przyniósł do kuchni trzy jabłka.'}));
        });
        return;
      }
      if (collected===4) {finish();return;}
      walk('Przejdź przez most do gwiazdki',cb=>renderer.advance(1,cb),()=>{
        stageIndex=1;
        walk('Idź po złotej linii do gwiazdki',cb=>renderer.tracePath(cb),()=>reward(stages[1]));
      });
    }
    function finish() {
      phase = 'complete';
      root.dataset.phase = 'complete';
      renderer?.setPaused?.(true);
      window.adventureCompleted?.(0);
      sound('complete');
      voice('Brawo! W dolinie znów jasno. Hobbici zapraszają Leo na placek z jabłkami. Dziękujemy za pomoc!');
      dock.innerHTML = '';
      pauseButton.hidden = true;
      shade.hidden = false;
      shade.innerHTML = `<section class="adv-modal adv-victory" aria-labelledby="adv-won">
        <div class="adv-awards" aria-label="Cztery gwiazdki"><span>${svg('star')}</span><span>${svg('star')}</span><span>${svg('star')}</span><span>${svg('star')}</span></div>
        <div class="adv-place">${valleyName}</div><h2 id="adv-won">W dolinie znów jasno!</h2>
        <p>Hobbici zapraszają Leo do ciepłej norki na placek z jabłkami. Dziękują Ci za pomoc!</p>
        <button type="button" data-map class="adv-primary">${svg('compass')} Wróć do mapy</button>
        <button type="button" data-restart class="adv-secondary">${svg('retry')} Zagraj jeszcze raz</button></section>`;
      shade.querySelector('[data-map]').addEventListener('click', () => close());
      shade.querySelector('[data-restart]').addEventListener('click', () => {
        close(false);
        if (previouslyFocused?.isConnected) previouslyFocused.focus({ preventScroll: true });
        window.startHobbitAdventure();
      });
      shade.querySelector('[data-map]').focus({ preventScroll: true });
    }
    function pause() {
      if (paused || phase === 'complete' || !present()) return;
      paused = true;
      focusBeforePause = document.activeElement;
      quiet();
      stick.setEnabled(false);renderer?.setPaused?.(true);
      root.classList.add('adv-paused');
      shade.hidden = false;
      shade.innerHTML = `<section class="adv-modal" aria-labelledby="adv-break"><div class="adv-rest">${svg('pause')}</div><h2 id="adv-break">Przerwa w wyprawie</h2><p>Leo poczeka tutaj na Ciebie.</p>
        <button type="button" class="adv-primary" data-resume>${svg('play')} Graj dalej</button>
        <button type="button" class="adv-secondary" data-map>${svg('compass')} Wróć do mapy</button></section>`;
      shade.querySelector('[data-resume]').addEventListener('click', resume);
      shade.querySelector('[data-map]').addEventListener('click', () => close());
      dock.inert = true;
      root.querySelector('.adv-hud').inert = true;
      shade.querySelector('[data-resume]').focus({ preventScroll: true });
    }
    function resume() {
      if (!paused) return;
      paused = false;
      root.classList.remove('adv-paused');
      shade.hidden = true;
      shade.innerHTML = '';
      dock.inert = false;
      root.querySelector('.adv-hud').inert = false;
      renderer?.setPaused?.(false);stick.setEnabled(phase==='travel');
      if (focusBeforePause?.isConnected) focusBeforePause.focus({ preventScroll: true });
      if (queuedAction) {
        const action = queuedAction;
        queuedAction = null;
        action();
      } else if (phase === 'question') readQuestion(false);
    }
    function visibilityChanged() { if (document.hidden) pause(); }
    pauseButton.addEventListener('click', pause);
    root.addEventListener('cancel', event => {
      event.preventDefault();
      if (phase === 'complete') close();
      else if (paused) resume();
      else pause();
    });
    document.addEventListener('visibilitychange', visibilityChanged);
    updateMeter();
    if(renderer) walk('Podejdź do mostu',cb=>renderer.approach(cb),showQuestion);
    else {stickHost.hidden=true;hint.hidden=true;dock.innerHTML='<section class="adv-card"><h2>Nie udało się otworzyć doliny.</h2><button class="adv-primary">Wróć do mapy</button></section>';dock.querySelector('button').onclick=()=>close();}
  };
})();
