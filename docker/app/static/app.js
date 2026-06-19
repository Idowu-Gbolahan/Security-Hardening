/**
 * SmykkerPay — Frontend JavaScript
 * Handles API status refresh and minor UI interactions
 */

'use strict';

// ── Infrastructure status refresh ────────────────────────────────────────────
async function refreshStatus() {
    const grid = document.getElementById('infra-status');
    if (!grid) return;

    grid.classList.add('loading');

    try {
        const response = await fetch('/api/status', {
            method: 'GET',
            headers: { 'Accept': 'application/json' },
            credentials: 'same-origin'
        });

        if (!response.ok) throw new Error('API returned ' + response.status);

        const data = await response.json();

        if (data.status === 'operational') {
            const badges = grid.querySelectorAll('.badge');
            badges.forEach(badge => {
                badge.classList.remove('badge-yellow', 'badge-red');
                badge.classList.add('badge-green');
                badge.textContent = 'Healthy';
            });
        }

    } catch (err) {
        console.error('Status refresh failed:', err.message);
    } finally {
        grid.classList.remove('loading');
    }
}


// ── Form input validation feedback ──────────────────────────────────────────
function initFormValidation() {
    const inputs = document.querySelectorAll('.form-input');

    inputs.forEach(input => {
        input.addEventListener('blur', function () {
            if (this.required && !this.value.trim()) {
                this.style.borderColor = 'var(--red-500)';
            } else {
                this.style.borderColor = '';
            }
        });

        input.addEventListener('focus', function () {
            this.style.borderColor = '';
        });
    });
}


// ── Prevent form double-submit ───────────────────────────────────────────────
function initFormSubmitGuard() {
    const forms = document.querySelectorAll('form');

    forms.forEach(form => {
        form.addEventListener('submit', function () {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Signing in...';
            }
        });
    });
}


// ── Initialise on DOM ready ──────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    initFormValidation();
    initFormSubmitGuard();
});