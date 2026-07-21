// VideoSensei — Console UI helpers

import { THEME } from './theme.js';

export const VERSION = '1.1.0';

export function clear(): void {
  process.stdout.write('\x1b[2J\x1b[H');
}

export function printLogo(small = false): void {
  if (small) {
    console.log(`${THEME.accent}${THEME.bold}🥋 VideoSensei${THEME.reset} ${THEME.muted}v${VERSION}${THEME.reset}`);
    return;
  }
  const lines = [
    '',
    `${THEME.accent}    ╱━━━━━━━╲${THEME.reset}`,
    `${THEME.accent}   ╱  ┃█┃  ╲ ${THEME.reset}  ${THEME.bold}VIDEOSENSEI${THEME.reset} ${THEME.muted}v${VERSION}${THEME.reset}`,
    `${THEME.accent}  ╱  ┃█┃  ╲  ${THEME.reset}  ${THEME.muted}Master your video. Sensei-grade clarity.${THEME.reset}`,
    `${THEME.accent}  ╲  ┃█┃  ╱  ${THEME.reset}  ${THEME.muted}by Jubair Sensei${THEME.reset}`,
    `${THEME.accent}   ╲━━━━━╱   ${THEME.reset}  ${THEME.muted}https://jubairsensei.com${THEME.reset}`,
    '',
  ];
  lines.forEach((l) => console.log(l));
}

export function printHelp(): void {
  printLogo(true);
  console.log(`${THEME.bold}USAGE${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset}                          ${THEME.muted}# auto: pick + smart + compress${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file>                   ${THEME.muted}# auto: smart preset, no prompts${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file> -p <preset>       ${THEME.muted}# specific preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <f1> <f2> ... -p <p>     ${THEME.muted}# batch${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} --history                ${THEME.muted}# show past compressions${THEME.reset}`);
  console.log('');
  console.log(`${THEME.bold}PRESETS${THEME.reset}`);
  console.log(`  🪶 Lite       H.264 CRF 30 — quick share, max compat`);
  console.log(`  ⚖️ Balanced   H.265 CRF 26 — daily default (50% smaller)`);
  console.log(`  💎 Crystal    H.265 CRF 22 — archive, near-lossless`);
  console.log(`  🥋 Sensei     AV1   CRF 32 — future-proof, smallest`);
  console.log(`  🎯 Custom     full manual control`);
  console.log('');
  console.log(`${THEME.bold}OPTIONS${THEME.reset}`);
  console.log(`  ${THEME.accent}-p, --preset${THEME.reset} <name>     Preset: lite|balanced|crystal|sensei|custom`);
  console.log(`  ${THEME.accent}-P, --pick${THEME.reset}                 Open file picker`);
  console.log(`  ${THEME.accent}-o, --output${THEME.reset} <dir>       Output directory`);
  console.log(`  ${THEME.accent}-i, --interactive${THEME.reset}        Show menu (old behavior)`);
  console.log(`  ${THEME.accent}--confirm${THEME.reset}                 Ask before compressing`);
  console.log(`  ${THEME.accent}--smart${THEME.reset}                  Use smart mode (default)`);
  console.log(`  ${THEME.accent}--no-smart${THEME.reset}               Disable smart mode`);
  console.log(`  ${THEME.accent}--codec${THEME.reset} <name>            Custom: h264|h265|av1`);
  console.log(`  ${THEME.accent}--crf${THEME.reset} <0-51>              Custom: CRF value`);
  console.log(`  ${THEME.accent}--audio-bitrate${THEME.reset} <k>       Custom: audio bitrate`);
  console.log(`  ${THEME.accent}--history${THEME.reset}                Show history`);
  console.log(`  ${THEME.accent}--clear-history${THEME.reset}          Clear history`);
  console.log(`  ${THEME.accent}-h, --help${THEME.reset}               Show this help`);
  console.log(`  ${THEME.accent}-v, --version${THEME.reset}            Show version`);
  console.log('');
  console.log(`${THEME.bold}FILE PICKERS${THEME.reset} (auto-detected)`);
  console.log(`  ${THEME.muted}Termux${THEME.reset}: termux-file-picker (pkg install termux-api)`);
  console.log(`  ${THEME.muted}macOS${THEME.reset}:  osascript (built-in)`);
  console.log(`  ${THEME.muted}Linux${THEME.reset}:  zenity (GTK) or kdialog (KDE)`);
  console.log(`  ${THEME.muted}Win${THEME.reset}:    PowerShell (.NET WinForms)`);
  console.log(`  ${THEME.muted}Any${THEME.reset}:    fzf (terminal fuzzy finder)`);
  console.log(`  ${THEME.muted}Fallback${THEME.reset}: built-in arrow-key browser`);
  console.log('');
  console.log(`${THEME.bold}EXAMPLES${THEME.reset}`);
  console.log(`  ${THEME.muted}# Easiest: just run it${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset}`);
  console.log('');
  console.log(`  ${THEME.muted}# Quick compress (auto-smart preset)${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4`);
  console.log('');
  console.log(`  ${THEME.muted}# Specific preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4 -p sensei`);
  console.log('');
  console.log(`  ${THEME.muted}# Batch${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} *.mp4 -p balanced`);
  console.log('');
  console.log(`${THEME.bold}BRAND${THEME.reset}`);
  console.log(`  ${THEME.muted}Author:${THEME.reset}  Jubair Sensei <jubairsensei@gmail.com>`);
  console.log(`  ${THEME.muted}Site:${THEME.reset}    https://jubairsensei.com`);
  console.log(`  ${THEME.muted}Repo:${THEME.reset}    https://github.com/JubairSenseiDev/VideoSensei`);
  console.log(`  ${THEME.muted}License:${THEME.reset} MIT`);
}

import type { CompressionResult } from './types.js';
import { formatTime, HISTORY_PATH } from './history.js';
import path from 'node:path';
import { formatBytes, formatDuration } from './ffmpeg.js';

export function printHistory(history: CompressionResult[]): void {
  printLogo(true);
  if (history.length === 0) {
    console.log(`  ${THEME.muted}No history yet. Your sensei will remember every video you master.${THEME.reset}`);
    console.log('');
    return;
  }
  console.log(`${THEME.bold}COMPRESSION HISTORY${THEME.reset} ${THEME.muted}(${history.length} entries)${THEME.reset}`);
  console.log('');
  history.slice(0, 20).forEach((entry, i) => {
    const idx = `${THEME.muted}${(i + 1).toString().padStart(2)}. ${THEME.reset}`;
    const name = path.basename(entry.input);
    const time = formatTime(entry.timestamp);
    const reduction = entry.reduction ? `(${entry.reduction.toFixed(1)}% ↓)` : '';
    const preset = entry.preset || '?';
    console.log(`${idx}🎬 ${name}`);
    console.log(`     ${THEME.muted}${preset} · ${formatBytes(entry.inputSize)} → ${formatBytes(entry.outputSize)} ${THEME.accent}${reduction}${THEME.reset} · ${time}${THEME.reset}`);
  });
  if (history.length > 20) {
    console.log(`  ${THEME.muted}... and ${history.length - 20} more (see ${HISTORY_PATH})${THEME.reset}`);
  }
  console.log('');
}
