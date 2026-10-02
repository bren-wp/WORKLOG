(() => {
  const form = document.querySelector('#auth-form');
  const nameRow = document.querySelector('#name-row');
  const nameInput = document.querySelector('#name');
  const email = document.querySelector('#email');
  const password = document.querySelector('#password');
  const message = document.querySelector('#message');
  const submit = form.querySelector('button[type="submit"]');
  const tabs = [...document.querySelectorAll('.tab')];
  const session = document.querySelector('#session');
  const sessionName = document.querySelector('#session-name');
  const sessionEmail = document.querySelector('#session-email');
  const logout = document.querySelector('#logout');

  let mode = 'login';
  let accessToken = sessionStorage.getItem('worklog_access') || '';
  let refreshToken = sessionStorage.getItem('worklog_refresh') || '';

  const api = (path) => new URL(path.replace(/^\//, ''), document.baseURI).toString();

  function setMessage(text, ok = false) {
    message.textContent = text;
    message.classList.toggle('ok', ok);
  }

  function setMode(next) {
    mode = next;
    tabs.forEach((tab) => tab.classList.toggle('active', tab.dataset.mode === mode));
    nameRow.classList.toggle('hidden', mode !== 'register');
    nameInput.required = mode === 'register';
    password.autocomplete = mode === 'register' ? 'new-password' : 'current-password';
    submit.textContent = mode === 'register' ? 'Izradi račun' : 'Prijavi se';
    setMessage('');
  }

  function showSession(user) {
    form.classList.add('hidden');
    document.querySelector('.tabs').classList.add('hidden');
    session.classList.remove('hidden');
    sessionName.textContent = user.name;
    sessionEmail.textContent = user.email;
  }

  async function request(path, options = {}) {
    const response = await fetch(api(path), {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.error || 'Zahtjev nije uspio.');
    return data;
  }

  tabs.forEach((tab) => tab.addEventListener('click', () => setMode(tab.dataset.mode)));

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    submit.disabled = true;
    setMessage('');
    try {
      const payload = {
        email: email.value.trim(),
        password: password.value,
      };
      if (mode === 'register') payload.name = nameInput.value.trim();
      const data = await request('api/v1/auth/' + mode, {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      accessToken = data.access_token;
      refreshToken = data.refresh_token;
      sessionStorage.setItem('worklog_access', accessToken);
      sessionStorage.setItem('worklog_refresh', refreshToken);
      setMessage('Uspješno.', true);
      showSession(data.user);
    } catch (error) {
      setMessage(error.message);
    } finally {
      submit.disabled = false;
    }
  });

  logout.addEventListener('click', async () => {
    try {
      if (accessToken) {
        await request('api/v1/auth/logout', {
          method: 'POST',
          headers: { Authorization: 'Bearer ' + accessToken },
          body: JSON.stringify({ refresh_token: refreshToken }),
        });
      }
    } catch (_) {
      // Lokalna odjava se mora izvršiti i ako je sesija već istekla.
    }
    sessionStorage.removeItem('worklog_access');
    sessionStorage.removeItem('worklog_refresh');
    location.reload();
  });

  async function restore() {
    if (!accessToken) return;
    try {
      const data = await request('api/v1/auth/me', {
        headers: { Authorization: 'Bearer ' + accessToken },
      });
      showSession(data.user);
      return;
    } catch (_) {
      if (!refreshToken) {
        sessionStorage.removeItem('worklog_access');
        sessionStorage.removeItem('worklog_refresh');
        return;
      }
    }

    try {
      const data = await request('api/v1/auth/refresh', {
        method: 'POST',
        body: JSON.stringify({ refresh_token: refreshToken }),
      });
      accessToken = data.access_token;
      refreshToken = data.refresh_token;
      sessionStorage.setItem('worklog_access', accessToken);
      sessionStorage.setItem('worklog_refresh', refreshToken);
      showSession(data.user);
    } catch (_) {
      sessionStorage.removeItem('worklog_access');
      sessionStorage.removeItem('worklog_refresh');
    }
  }

  restore();
})();
