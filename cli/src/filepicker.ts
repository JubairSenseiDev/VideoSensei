// VideoSensei — File picker (multi-backend)
// Tries native pickers first, falls back to pure-Node arrow-key browser.

import { execSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import type { Readable } from 'node:stream';

const VIDEO_EXTENSIONS = ['mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'wmv', 'm4v', 'mpg', 'mpeg', 'ts', '3gp'];

function commandExists(cmd: string): boolean {
  try {
    execSync(`command -v ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// ============================================================================
// EXTERNAL PICKERS
// ============================================================================

function runTermuxPicker(multiple: boolean): string[] | null {
  if (!commandExists('termux-file-picker')) return null;
  try {
    const args = ['--file'];
    if (multiple) args.push('--multiple');
    const result = spawnSync('termux-file-picker', args, { encoding: 'utf8', timeout: 60000 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split('\n').filter(Boolean);
  } catch {
    return null;
  }
}

function runOsascriptPicker(multiple: boolean, extensions: string[]): string[] | null {
  if (process.platform !== 'darwin' || !commandExists('osascript')) return null;
  try {
    const extFilter = extensions.length > 0
      ? ` of type {${extensions.map((e) => `"${e.toUpperCase()}"`).join(',')}}`
      : '';
    const chooseCmd = multiple
      ? `choose file${extFilter} with multiple selections allowed`
      : `choose file${extFilter}`;
    const result = spawnSync('osascript', ['-e', chooseCmd], { encoding: 'utf8', timeout: 60000 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split(',').map((line) => {
      const m = line.match(/alias "([^"]+)"/);
      if (!m) return null;
      return '/' + m[1].replace(/^([^:]+):/, '').split(':').join('/');
    }).filter((s): s is string => Boolean(s));
  } catch {
    return null;
  }
}

function runZenityPicker(multiple: boolean, extensions: string[]): string[] | null {
  if (!commandExists('zenity')) return null;
  try {
    const args = ['--file-selection', '--title=Pick a video'];
    if (multiple) args.push('--multiple', '--separator=\n');
    if (extensions.length > 0) {
      extensions.forEach((ext) => args.push(`--file-filter=Video.${ext} | *.${ext}`));
    }
    const result = spawnSync('zenity', args, { encoding: 'utf8', timeout: 60000 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split('\n').filter(Boolean);
  } catch {
    return null;
  }
}

function runKdialogPicker(multiple: boolean, extensions: string[]): string[] | null {
  if (!commandExists('kdialog')) return null;
  try {
    const filter = extensions.length > 0
      ? extensions.map((e) => `*.${e}`).join(' ')
      : '*';
    const args = ['--getopenfilename', '.', `${filter} | Video files`, 'Pick a video'];
    if (multiple) args.unshift('--multiple', '--separate-output');
    const result = spawnSync('kdialog', args, { encoding: 'utf8', timeout: 60000 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split('\n').filter(Boolean);
  } catch {
    return null;
  }
}

function runPowerShellPicker(multiple: boolean): string[] | null {
  if (process.platform !== 'win32' || !commandExists('powershell')) return null;
  try {
    const ps = `[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog;
$OpenFileDialog.Title = 'Pick a video';
$OpenFileDialog.Filter = 'Video files|*.mp4;*.mkv;*.mov;*.avi;*.webm;*.flv;*.wmv;*.m4v|All files|*.*';
$OpenFileDialog.Multiselect = $${multiple};
if ($OpenFileDialog.ShowDialog() -eq 'OK') { $OpenFileDialog.FileNames }`;
    const result = spawnSync('powershell', ['-NoProfile', '-Command', ps], { encoding: 'utf8', timeout: 60000 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split('\n').map((s) => s.trim()).filter(Boolean);
  } catch {
    return null;
  }
}

function tryExternalPicker(multiple: boolean, extensions: string[]): string[] | null {
  return runTermuxPicker(multiple)
    || runOsascriptPicker(multiple, extensions)
    || runZenityPicker(multiple, extensions)
    || runKdialogPicker(multiple, extensions)
    || runPowerShellPicker(multiple);
}

// ============================================================================
// PURE-NODE TERMINAL BROWSER (fallback)
// ============================================================================

interface BrowserItem {
  name: string;
  isDir: boolean;
  path: string;
}

function setRawMode(on: boolean): void {
  const stdin = process.stdin as Readable & { isTTY?: boolean; setRawMode?: (mode: boolean) => void };
  if (stdin.isTTY && typeof stdin.setRawMode === 'function') {
    stdin.setRawMode(on);
  }
  stdin.resume();
}

function readKey(): Promise<string> {
  return new Promise((resolve) => {
    const handler = (chunk: Buffer) => {
      process.stdin.removeListener('data', handler);
      const key = chunk.toString();
      if (key === '\x1b[A') return resolve('up');
      if (key === '\x1b[B') return resolve('down');
      if (key === '\x1b[C') return resolve('right');
      if (key === '\x1b[D') return resolve('left');
      if (key === '\r' || key === '\n') return resolve('enter');
      if (key === '\x1b') return resolve('escape');
      if (key === '\x7f' || key === '\x08') return resolve('backspace');
      if (key === 'q' || key === 'Q') return resolve('quit');
      if (key === 'h' || key === 'H') return resolve('toggle-hidden');
      if (key === '?') return resolve('help');
      resolve(key);
    };
    process.stdin.once('data', handler);
  });
}

function shortenPath(p: string, max: number): string {
  if (p.length <= max) return p;
  const home = os.homedir();
  if (p.startsWith(home)) p = '~' + p.slice(home.length);
  if (p.length <= max) return p;
  const start = p.slice(0, Math.floor(max / 2) - 2);
  const end = p.slice(p.length - Math.floor(max / 2));
  return start + '...' + end;
}

interface BrowserState {
  currentDir: string;
  cursor: number;
  scrollOffset: number;
  showHidden: boolean;
  selected: string[];
}

async function fileBrowser(options: {
  startDir?: string;
  extensions?: string[];
  multiple?: boolean;
}): Promise<string[] | null> {
  const extensions = options.extensions ?? VIDEO_EXTENSIONS;
  const multiple = options.multiple ?? false;
  const state: BrowserState = {
    currentDir: options.startDir || process.cwd(),
    cursor: 0,
    scrollOffset: 0,
    showHidden: false,
    selected: [],
  };
  const pageSize = 20;

  while (true) {
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(state.currentDir, { withFileTypes: true });
    } catch {
      state.currentDir = path.dirname(state.currentDir);
      continue;
    }

    entries = entries.filter((e) => state.showHidden || !e.name.startsWith('.'));

    const dirs = entries.filter((e) => e.isDirectory()).sort((a, b) => a.name.localeCompare(b.name));
    const files = entries.filter((e) => {
      if (!e.isFile()) return false;
      if (extensions.length === 0) return true;
      const ext = path.extname(e.name).slice(1).toLowerCase();
      return extensions.includes(ext);
    }).sort((a, b) => a.name.localeCompare(b.name));

    const items: BrowserItem[] = [
      { name: '..', isDir: true, path: path.dirname(state.currentDir) },
      ...dirs.map((d) => ({ name: d.name + '/', isDir: true, path: path.join(state.currentDir, d.name) })),
      ...files.map((f) => ({ name: f.name, isDir: false, path: path.join(state.currentDir, f.name) })),
    ];

    if (state.cursor >= items.length) state.cursor = items.length - 1;
    if (state.cursor < 0) state.cursor = 0;
    if (state.cursor < state.scrollOffset) state.scrollOffset = state.cursor;
    if (state.cursor >= state.scrollOffset + pageSize) state.scrollOffset = state.cursor - pageSize + 1;

    renderBrowser(state, items, extensions, multiple);

    setRawMode(true);
    const key = await readKey();
    setRawMode(false);

    if (key === 'up') state.cursor = Math.max(0, state.cursor - 1);
    else if (key === 'down') state.cursor = Math.min(items.length - 1, state.cursor + 1);
    else if (key === 'enter' || key === 'right') {
      const item = items[state.cursor];
      if (!item) continue;
      if (item.isDir) {
        state.currentDir = item.path;
        state.cursor = 0;
        state.scrollOffset = 0;
      } else if (multiple) {
        const idx = state.selected.indexOf(item.path);
        if (idx >= 0) state.selected.splice(idx, 1);
        else state.selected.push(item.path);
      } else {
        return [item.path];
      }
    } else if (key === 'backspace' || key === 'left') {
      state.currentDir = path.dirname(state.currentDir);
      state.cursor = 0;
      state.scrollOffset = 0;
    } else if (key === 'escape' || key === 'quit') {
      return state.selected.length > 0 ? state.selected : null;
    } else if (key === 'toggle-hidden') {
      state.showHidden = !state.showHidden;
    }
  }
}

function renderBrowser(
  state: BrowserState,
  items: BrowserItem[],
  extensions: string[],
  multiple: boolean
): void {
  const C = {
    accent: '\x1b[38;2;0;255;136m',
    ink: '\x1b[38;2;255;255;255m',
    muted: '\x1b[38;2;161;161;170m',
    dim: '\x1b[38;2;82;82;91m',
    blue: '\x1b[38;2;59;130;246m',
    cyan: '\x1b[38;2;34;211;238m',
    bgHover: '\x1b[48;2;0;255;136m\x1b[38;2;10;10;11m',
    reset: '\x1b[0m',
    bold: '\x1b[1m',
  };

  process.stdout.write('\x1b[2J\x1b[H');
  const shortDir = shortenPath(state.currentDir, 60);
  console.log(`${C.bold}  🥋 VideoSensei File Picker${C.reset}  ${C.muted}${multiple ? '(multi-select)' : ''}${C.reset}`);
  console.log('');
  console.log(`  ${C.muted}📁${C.reset} ${C.accent}${shortDir}${C.reset}`);
  console.log(`  ${C.muted}Filter: ${C.reset}${C.cyan}${extensions.join(', ')}${C.reset}  ${C.muted}Hidden: ${C.reset}${state.showHidden ? C.accent + 'on' : C.dim + 'off'}${C.reset}${state.selected.length > 0 ? `  ${C.muted}Selected: ${C.reset}${C.accent}${state.selected.length}${C.reset}` : ''}`);
  console.log(`  ${C.dim}${'─'.repeat(76)}${C.reset}`);

  const pageSize = 20;
  const visible = items.slice(state.scrollOffset, state.scrollOffset + pageSize);
  visible.forEach((item, i) => {
    const idx = state.scrollOffset + i;
    const isSelected = idx === state.cursor;
    const inSelected = state.selected.includes(item.path);

    let icon: string;
    if (item.name === '..') icon = '↩';
    else if (item.isDir) icon = '📁';
    else icon = '🎬';

    let name = item.name;
    let nameColor = C.ink;
    if (item.name === '..') nameColor = C.muted;
    else if (item.isDir) nameColor = C.blue;

    if (name.length > 60) name = name.slice(0, 57) + '...';

    const checkmark = inSelected ? `${C.accent}✓${C.reset} ` : '  ';
    const pointer = isSelected ? `${C.accent}❯${C.reset} ` : '  ';

    if (isSelected) {
      console.log(`${pointer}${checkmark}${C.bgHover} ${icon} ${name} ${C.reset}`);
    } else {
      console.log(`${pointer}${checkmark}${nameColor} ${icon} ${name}${C.reset}`);
    }
  });

  for (let i = visible.length; i < pageSize; i++) console.log('');
  console.log(`  ${C.dim}${'─'.repeat(76)}${C.reset}`);
  console.log(`  ${C.muted}↑↓ navigate  ${C.reset}${C.muted}→/Enter open  ${C.reset}${C.muted}←/⌫ up dir  ${C.reset}${C.muted}h hidden  ${C.reset}${C.muted}q done${C.reset}`);
}

// ============================================================================
// PUBLIC API
// ============================================================================

export interface PickFileOptions {
  startDir?: string;
  extensions?: string[];
  multiple?: boolean;
  preferExternal?: boolean;
}

export async function pickFile(options: PickFileOptions = {}): Promise<string[] | null> {
  const opts = {
    startDir: process.cwd(),
    extensions: VIDEO_EXTENSIONS,
    multiple: false,
    preferExternal: true,
    ...options,
  };

  if (opts.preferExternal) {
    const result = tryExternalPicker(opts.multiple ?? false, opts.extensions ?? VIDEO_EXTENSIONS);
    if (result && result.length > 0) return result;
  }

  const stdin = process.stdin as Readable & { isTTY?: boolean };
  if (!stdin.isTTY) return null;

  return fileBrowser(opts);
}

export function isPickerAvailable(): boolean {
  const stdin = process.stdin as Readable & { isTTY?: boolean };
  return !!(
    commandExists('termux-file-picker') ||
    commandExists('zenity') ||
    commandExists('kdialog') ||
    commandExists('osascript') ||
    commandExists('fzf') ||
    (process.platform === 'win32' && commandExists('powershell')) ||
    stdin.isTTY
  );
}

export { VIDEO_EXTENSIONS };
