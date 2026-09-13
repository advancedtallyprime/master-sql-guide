<template>
  <footer class="gtec-doc-footer">
    <div class="footer-inner">
      <div class="footer-brand">
        <span class="footer-name">G-TEC Jain Keerti Education</span>
        <span class="footer-divider">·</span>
        <span class="footer-tagline">Global Leader in IT Education</span>
      </div>
      <p class="footer-copyright">© 2026 G-TEC Jain Keerti Education. All Rights Reserved.</p>
    </div>
  </footer>
</template>

<script setup>
</script>

<style scoped>
.gtec-doc-footer {
  margin-top: 3.5rem;
  padding: 1.5rem 1.25rem;
  border-radius: var(--radius-sm, 8px);
  text-align: center;
  background: var(--bg-card, #FFFFFF);
  border: 1px solid var(--border, #DCE7EE);
  border-top: 2px solid var(--brand-blue, #0878B8);
  box-shadow: var(--shadow-card, 0 2px 8px rgba(8, 120, 184, 0.05));
  transition: border-color 0.2s, background 0.2s;
}

.footer-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.footer-brand {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 14px;
}

.footer-name {
  font-weight: 700;
  color: var(--brand-blue, #0878B8);
  letter-spacing: -0.01em;
}

.footer-divider {
  color: var(--text-muted, #80868B);
  font-weight: 700;
}

.footer-tagline {
  font-weight: 500;
  color: var(--text-secondary, #5F6368);
}

.footer-copyright {
  margin: 4px 0 0 0 !important;
  font-size: 12px !important;
  color: var(--text-muted, #80868B) !important;
}

.dark .gtec-doc-footer {
  background: var(--bg-card, #202127);
  border: 1px solid var(--border, #2E303A);
  border-top: 2px solid var(--brand-blue, #4DA8E0);
  box-shadow: var(--shadow-card, 0 2px 8px rgba(0, 0, 0, 0.25));
}

.dark .footer-name {
  color: var(--brand-blue, #4DA8E0);
}

.dark .footer-tagline {
  color: var(--text-secondary, #9CA3AF);
}

.dark .footer-copyright {
  color: var(--text-muted, #6B7280) !important;
}
</style>
