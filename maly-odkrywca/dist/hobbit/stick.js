/* One movement vector for the touch stick, a controller's left stick, or arrow keys. */
(() => {
  'use strict';

  const keys = {
    ArrowLeft: [-1, 0], KeyA: [-1, 0], ArrowRight: [1, 0], KeyD: [1, 0],
    ArrowUp: [0, -1], KeyW: [0, -1], ArrowDown: [0, 1], KeyS: [0, 1]
  };

  function normalize(x, y, deadZone) {
    const length = Math.hypot(x, y);
    if (!Number.isFinite(length) || length <= deadZone) return [0, 0];
    const strength = (Math.min(length, 1) - deadZone) / (1 - deadZone);
    return [x / length * strength, y / length * strength];
  }

  class AdventureStick {
    constructor(container, callback) {
      this.callback = callback;
      this.enabled = true;
      this.destroyed = false;
      this.windowActive = true;
      this.pointerId = null;
      this.touchVector = [0, 0];
      this.heldKeys = new Set();
      this.releasePad = true;
      this.listeners = [];
      this.frameId = 0;
      this.lastX = 0;
      this.lastY = 0;

      this.base = document.createElement('div');
      this.base.className = 'leo-stick';
      this.base.tabIndex = 0;
      this.base.setAttribute('role', 'group');
      this.base.setAttribute('aria-label', 'Gałka sterowania');
      this.base.setAttribute('aria-keyshortcuts', 'ArrowUp ArrowDown ArrowLeft ArrowRight');
      this.base.innerHTML = '<span class="leo-stick-ring" aria-hidden="true">' +
        '<i class="leo-stick-tick leo-stick-up"></i><i class="leo-stick-tick leo-stick-right"></i>' +
        '<i class="leo-stick-tick leo-stick-down"></i><i class="leo-stick-tick leo-stick-left"></i>' +
        '<span class="leo-stick-thumb"><span class="leo-stick-grip"></span></span></span>';
      container.appendChild(this.base);
      this.thumb = this.base.querySelector('.leo-stick-thumb');

      this.run = this.run.bind(this);
      this.measure = this.measure.bind(this);
      this.installInput();
      this.measure();
      if ('ResizeObserver' in window) {
        this.resizeObserver = new ResizeObserver(this.measure);
        this.resizeObserver.observe(this.base);
      }
      this.requestFrame();
    }

    listen(target, type, handler, options) {
      target.addEventListener(type, handler, options);
      this.listeners.push(() => target.removeEventListener(type, handler, options));
    }

    measure() {
      const box = this.base.getBoundingClientRect();
      this.radius = Math.max(1, Math.min(box.width, box.height) * .28);
    }

    isActive() {
      return this.enabled && !this.destroyed && !document.hidden && this.windowActive;
    }

    installInput() {
      const prevent = event => {
        if (event.cancelable) event.preventDefault();
        event.stopPropagation();
      };
      const capture = { capture: true, passive: false };
      if ('PointerEvent' in window) {
        this.listen(this.base, 'pointerdown', event => {
          if (!this.isActive() || this.pointerId !== null || event.button !== 0) return;
          prevent(event);
          this.startPointer(event.pointerId, event.clientX, event.clientY);
          try { this.base.setPointerCapture(event.pointerId); } catch { /* Window listeners still receive the drag. */ }
        }, { passive: false });
        this.listen(window, 'pointermove', event => {
          if (event.pointerId !== this.pointerId) return;
          prevent(event);
          if (event.pointerType === 'mouse' && !event.buttons) this.stopPointer();
          else this.movePointer(event.clientX, event.clientY);
        }, capture);
        const release = event => {
          if (event.pointerId !== this.pointerId) return;
          prevent(event);
          this.stopPointer();
        };
        this.listen(window, 'pointerup', release, capture);
        this.listen(window, 'pointercancel', release, capture);
        this.listen(this.base, 'lostpointercapture', release);
        this.listen(window, 'pointerout', event => {
          if (event.pointerId === this.pointerId && event.relatedTarget === null &&
              !this.base.hasPointerCapture?.(event.pointerId)) this.stopPointer();
        });
      } else {
        this.listen(this.base, 'touchstart', event => {
          if (!this.isActive() || this.pointerId !== null) return;
          const touch = event.changedTouches[0];
          if (!touch) return;
          prevent(event);
          this.startPointer(touch.identifier, touch.clientX, touch.clientY);
        }, { passive: false });
        const tracked = event => Array.from(event.changedTouches).find(t => t.identifier === this.pointerId);
        this.listen(window, 'touchmove', event => {
          const touch = tracked(event);
          if (!touch) return;
          prevent(event);
          this.movePointer(touch.clientX, touch.clientY);
        }, capture);
        const release = event => {
          if (!tracked(event)) return;
          prevent(event);
          this.stopPointer();
        };
        this.listen(window, 'touchend', release, capture);
        this.listen(window, 'touchcancel', release, capture);
      }

      this.listen(this.base, 'contextmenu', prevent);
      this.listen(window, 'keydown', event => {
        if (!this.isActive() || !Object.hasOwn(keys, event.code) ||
            event.altKey || event.metaKey || event.ctrlKey || event.target?.isContentEditable) return;
        prevent(event);
        this.heldKeys.add(event.code);
      }, capture);
      this.listen(window, 'keyup', event => {
        if (!this.heldKeys.delete(event.code)) return;
        prevent(event);
        if (!this.heldKeys.size && this.pointerId === null) this.emit(0, 0);
      }, capture);
      this.listen(window, 'blur', () => {
        this.windowActive = false;
        this.reset();
      });
      this.listen(window, 'focus', () => {
        this.windowActive = true;
        this.requestFrame();
      });
      this.listen(document, 'visibilitychange', () => {
        if (document.hidden) this.reset();
        else this.requestFrame();
      });
      this.listen(window, 'orientationchange', () => {
        this.reset();
        this.measure();
        this.requestFrame();
      });
      this.listen(window, 'resize', this.measure);
    }

    startPointer(id, x, y) {
      this.measure();
      const box = this.base.getBoundingClientRect();
      this.centerX = box.left + box.width / 2;
      this.centerY = box.top + box.height / 2;
      this.pointerId = id;
      this.base.classList.add('leo-stick-held');
      this.movePointer(x, y);
    }

    movePointer(x, y) {
      this.touchVector = normalize((x - this.centerX) / this.radius, (y - this.centerY) / this.radius, .10);
      this.emit(...this.touchVector);
    }

    stopPointer() {
      const id = this.pointerId;
      this.pointerId = null;
      if (id !== null && this.base.hasPointerCapture?.(id)) this.base.releasePointerCapture(id);
      this.touchVector = [0, 0];
      this.base.classList.remove('leo-stick-held');
      this.emit(0, 0);
    }

    readPad() {
      let pads;
      try { pads = navigator.getGamepads?.(); } catch { return [0, 0]; }
      if (!pads) return [0, 0];
      for (const pad of pads) {
        if (!pad || !pad.connected || pad.axes.length < 2) continue;
        const vector = normalize(pad.axes[0], pad.axes[1], .18);
        if (vector[0] || vector[1]) return this.releasePad ? [0, 0] : vector;
      }
      this.releasePad = false;
      return [0, 0];
    }

    emit(x, y) {
      if (x !== this.lastX || y !== this.lastY) {
        this.thumb.style.transform = 'translate(' + (x * this.radius).toFixed(2) + 'px,' +
          (y * this.radius).toFixed(2) + 'px)';
        this.lastX = x;
        this.lastY = y;
      }
      this.callback(x, y);
    }

    requestFrame() {
      if (this.isActive() && !this.frameId) this.frameId = requestAnimationFrame(this.run);
    }

    run() {
      this.frameId = 0;
      if (!this.isActive()) return;
      const pad = this.readPad();
      if (this.pointerId !== null) this.emit(...this.touchVector);
      else if (this.heldKeys.size) {
        let x = 0, y = 0;
        for (const key of this.heldKeys) { x += keys[key][0]; y += keys[key][1]; }
        this.emit(...normalize(x, y, 0));
      } else this.emit(...pad);
      this.requestFrame();
    }

    reset() {
      cancelAnimationFrame(this.frameId);
      this.frameId = 0;
      this.heldKeys.clear();
      this.releasePad = true;
      this.stopPointer();
    }

    setEnabled(enabled) {
      if (this.destroyed || this.enabled === Boolean(enabled)) return;
      this.enabled = Boolean(enabled);
      this.base.classList.toggle('leo-stick-disabled', !this.enabled);
      this.base.setAttribute('aria-disabled', String(!this.enabled));
      this.base.tabIndex = this.enabled ? 0 : -1;
      if (this.enabled) this.requestFrame();
      else this.reset();
    }

    destroy() {
      if (this.destroyed) return;
      this.destroyed = true;
      this.reset();
      for (const remove of this.listeners) remove();
      this.listeners.length = 0;
      this.resizeObserver?.disconnect();
      this.base.remove();
    }
  }
  window.AdventureStick = AdventureStick;
})();
