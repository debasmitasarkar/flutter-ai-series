// usage: node r08_run.js <url> <screenshot.png> [locale]
const { chromium } = require('playwright-core');
(async () => {
  const [url, shot, locale = 'de-DE'] = process.argv.slice(2);
  const browser = await chromium.launch({ executablePath: process.env.PW_CHROME });
  const page = await browser.newPage({ locale, viewport: { width: 480, height: 560 }, deviceScaleFactor: 2 });
  const lines = [];
  page.on('console', m => { const t = m.text(); if (/AUDIT|Error|error/.test(t)) lines.push(t); });
  page.on('pageerror', e => lines.push('PAGEERROR ' + e.message));
  await page.goto(url);
  await page.waitForFunction(() => window.__done === true || false, null, { timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(6000);
  await page.screenshot({ path: shot });
  console.log(lines.join('\n'));
  await browser.close();
})();
