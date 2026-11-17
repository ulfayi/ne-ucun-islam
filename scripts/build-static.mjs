import { cpSync, existsSync, mkdirSync, rmSync } from 'node:fs';

if (!existsSync('public/content.json')) {
  throw new Error('public/content.json tapılmadı. Lokal olaraq npm run extract işlədin.');
}

rmSync('dist', { recursive: true, force: true });
mkdirSync('dist', { recursive: true });
for (const file of ['index.html', 'app.js', 'styles.css']) {
  cpSync(file, `dist/${file}`);
}
cpSync('public', 'dist/public', { recursive: true });
console.log('Statik deploy paketi dist/ qovluğunda hazırdır.');
