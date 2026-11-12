const { chromium } = require('playwright-core');
const { execSync } = require('child_process');
const fs = require('fs');
const S = process.argv[2];
// Records deploy.webm: both servers start on build 1, get build 2, the page reloads.
// Usage: node deploy.js <work dir>   (expects <work dir>/dep/{plain_v1,plain_v2,hash_v1,hash_v2,naive,hashed}
// and the two serve.py processes logging to <work dir>/dep/naive.log and hashed.log)
const exe = process.env.CHROME_PATH; // optional, defaults to Playwright's Chromium
const swap = (v) => { execSync(`ln -sfn ${S}/dep/plain_v${v} ${S}/dep/naive/live && ln -sfn ${S}/dep/hash_v${v} ${S}/dep/hashed/live`); };
(async () => {
  swap(1);
  const b = await chromium.launch(exe ? { executablePath: exe } : {});
  const ctx = await b.newContext({ viewport: { width: 1000, height: 560 }, deviceScaleFactor: 2, recordVideo: { dir: 'vid/deploy', size: { width: 1000, height: 560 } } });
  const p = await ctx.newPage();
  let log;
  await p.goto('file://' + __dirname + '/stage.html');
  await p.waitForTimeout(5000);
  const t0 = Date.now();
  await p.waitForTimeout(1800);
  await p.evaluate(() => { document.getElementById('cap').innerHTML = 'Deploy build 2 to both servers'; });
  swap(2);
  await p.waitForTimeout(2000);
  await p.evaluate(() => { document.getElementById('cap').textContent = 'User hits reload…'; });
  await p.waitForTimeout(800);
  fs.writeFileSync(S + '/dep/naive.log', ''); fs.writeFileSync(S + '/dep/hashed.log', '');
  for (const fr of p.frames()) { if (/:808[12]/.test(fr.url())) fr.evaluate(() => location.reload()).catch(() => {}); }
  await p.waitForTimeout(3500);
  const rd = (f) => fs.readFileSync(S + '/dep/' + f, 'utf8').replace(/\0/g, '').split('\n').map(l => l.trim().split(' ')[1]).filter(Boolean);
  log = { '8081': rd('naive.log'), '8082': rd('hashed.log') };
  const fmt = (arr) => 'fetched from server:<br><b>' + (arr.filter(x => !/favicon|icons|manifest/.test(x)).join('  ') || '/') + '</b>';
  await p.evaluate(([a, c]) => { document.getElementById('na').innerHTML = a; document.getElementById('nb').innerHTML = c; document.getElementById('cap').textContent = 'Same deploy. Only one user sees it.'; }, [fmt(log['8081']), fmt(log['8082'])]);
  await p.waitForTimeout(3500);
  fs.writeFileSync('deploy.start', String((Date.now() - t0) / 1000));
  console.log(JSON.stringify(log));
  await ctx.close(); await b.close();
  const f = fs.readdirSync('vid/deploy').sort().pop(); fs.renameSync('vid/deploy/' + f, 'deploy.webm');
})();
