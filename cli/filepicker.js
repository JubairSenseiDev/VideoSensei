#!/usr/bin/env node
/**
 * filepicker.js — Pure-Node terminal file picker (zero dependencies)
 *
 * Features:
 *   • Arrow keys to navigate
 *   • Enter to open directory / select file
 *   • Backspace to go up
 *   • Hidden files toggled with 'h'
 *   • Filter by extension
 *   • Auto-detects external pickers (Termux:API, zenity, kdialog, macOS, PowerShell)
 *   • Falls back to pure-Node interactive browser
 *
 * Used by VideoSensei CLI.
 *
 * License: MIT
 * Author: Jubair Sensei
 */

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawnSync } = require('child_process');

// ============================================================================
// THEME — match VideoSensei theme
// ============================================================================
const C = {
  accent: '\x1b[38;2;0;255;136m',
  ink: '\x1b[38;2;255;255;255m',
  muted: '\x1b[38;2;161;161;170m',
  secondary: '\x1b[38;2;161;161;170m',
  dim: '\x1b[38;2;82;82;91m',
  cyan: '\x1b[38;2;34;211;238m',
  blue: '\x1b[38;2;59;130;246m',
  yellow: '\x1b[38;2;250;204;21m',
  red: '\x1b[38;2;248;113;113m',
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  bg: '\x1b[48;2;10;10;11m',
  bgElevated: '\x1b[48;2;17;17;20m',
  bgHover: '\x1b[48;2;0;255;136m\x1b[38;2;10;10;11m',
};

// ============================================================================
// EXTERNAL PICKER DETECTION
// ============================================================================

/**
 * Try to use a native file picker if available.
 * Returns the selected file path, or null if user cancelled / no picker available.
 */
function tryExternalPicker(options = {}) {
  const { multiple = false, extensions = [] } = options;

  // 1. Termux:API — termux-file-picker (Android)
  if (commandExists('termux-file-picker')) {
    return runTermuxPicker(multiple);
  }

  // 2. macOS — osascript
  if (process.platform === 'darwin' && commandExists('osascript')) {
    return runOsascriptPicker(multiple, extensions);
  }

  // 3. Linux — zenity (GTK)
  if (commandExists('zenity')) {
    return runZenityPicker(multiple, extensions);
  }

  // 4. Linux — kdialog (KDE)
  if (commandExists('kdialog')) {
    return runKdialogPicker(multiple, extensions);
  }

  // 5. Windows — PowerShell
  if (process.platform === 'win32' && commandExists('powershell')) {
    return runPowerShellPicker(multiple);
  }

  // 6. fzf — terminal fuzzy finder
  if (commandExists('fzf') && process.stdin.isTTY) {
    return runFzfPicker(extensions);
  }

  // No external picker available
  return null;
}

function commandExists(cmd) {
  try {
    require('child_process').execSync(`command -v ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function runTermuxPicker(multiple) {
  try {
    const args = ['--file'];
    if (multiple) args.push('--multiple');
    const result = spawnSync('termux-file-picker', args, {
      encoding: 'utf8',
      timeout: 60000,
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    const files = result.stdout.trim().split('\n').filter(Boolean);
    return multiple ? files : (files[0] || null);
  } catch {
    return null;
  }
}

function runOsascriptPicker(multiple, extensions) {
  try {
    const extFilter = extensions.length > 0
      ? ` of type {${extensions.map((e) => `"${e.toUpperCase()}"`).join(',')}}`
      : '';
    const chooseCmd = multiple
      ? `choose file${extFilter} with multiple selections allowed`
      : `choose file${extFilter}`;
    const script = `tell application "System Events" to ${chooseCmd}`;
    const result = spawnSync('osascript', ['-e', script], {
      encoding: 'utf8',
      timeout: 60000,
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    // Parse alias "Macintosh HD:Users:foo:bar.mp4" → /Users/foo/bar.mp4
    const paths = result.stdout.trim().split(',').map((line) => {
      const m = line.match(/alias "([^"]+)"/);
      if (!m) return null;
      return '/' + m[1].replace(/^([^:]+):/, '').split(':').join('/');
    }).filter(Boolean);
    return multiple ? paths : (paths[0] || null);
  } catch {
    return null;
  }
}

function runZenityPicker(multiple, extensions) {
  try {
    const args = ['--file-selection', '--title=Pick a video'];
    if (multiple) args.push('--multiple', '--separator=\n');
    if (extensions.length > 0) {
      extensions.forEach((ext) => {
        args.push('--file-filter=Video.' + ext + ' | *.' + ext);
      });
    }
    const result = spawnSync('zenity', args, {
      encoding: 'utf8',
      timeout: 60000,
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    const files = result.stdout.trim().split('\n').filter(Boolean);
    return multiple ? files : (files[0] || null);
  } catch {
    return null;
  }
}

function runKdialogPicker(multiple, extensions) {
  try {
    const filter = extensions.length > 0
      ? extensions.map((e) => `*.${e}`).join(' ')
      : '*';
    const args = [
      '--getopenfilename',
      '.',
      filter + ' | Video files',
      'Pick a video',
    ];
    if (multiple) args.unshift('--multiple', '--separate-output');
    const result = spawnSync('kdialog', args, {
      encoding: 'utf8',
      timeout: 60000,
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    const files = result.stdout.trim().split('\n').filter(Boolean);
    return multiple ? files : (files[0] || null);
  } catch {
    return null;
  }
}

function runPowerShellPicker(multiple) {
  try {
    const ps = `[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog;
$OpenFileDialog.Title = 'Pick a video';
$OpenFileDialog.Filter = 'Video files|*.mp4;*.mkv;*.mov;*.avi;*.webm;*.flv;*.wmv;*.m4v|All files|*.*';
$OpenFileDialog.Multiselect = $${multiple};
if ($OpenFileDialog.ShowDialog() -eq 'OK') { $OpenFileDialog.FileNames }`;
    const result = spawnSync('powershell', ['-NoProfile', '-Command', ps], {
      encoding: 'utf8',
      timeout: 60000,
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    const files = result.stdout.trim().split('\n').map((s) => s.trim()).filter(Boolean);
    return multiple ? files : (files[0] || null);
  } catch {
    return null;
  }
}

function runFzfPicker(extensions) {
  try {
    const extPattern = extensions.length > 0
      ? `\\.${extensions.join('$\\|')}\\$`
      : '';
    const cmd = `find . -type f -iname '*.${extensions.length > 0 ? `{${extensions.join(',')}}` : '*'}' 2>/dev/null | head -1000 | fzf --height=40% --reverse --header='Pick a video (Ctrl-C to cancel)' --prompt='🔍 '`;
    const result = spawnSync('fzf', [], {
      encoding: 'utf8',
      timeout: 60000,
      shell: '/bin/bash',
      input: '',
      stdio: ['pipe', 'pipe', 'inherit'],
    });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    const file = result.stdout.trim();
    return path.resolve(file);
  } catch {
    return null;
  }
}

// ============================================================================
// PURE-NODE TERMINAL FILE BROWSER (fallback)
// ============================================================================
// Arrow-key navigation. No dependencies. Works everywhere with a TTY.

const VIDEO_EXTENSIONS = ['mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'wmv', 'm4v', 'mpg', 'mpeg', 'ts', '3gp'];

// Set raw mode on stdin for keystroke capture
function setRawMode(on) {
  if (process.stdin.isTTY && typeof process.stdin.setRawMode === 'function') {
    process.stdin.setRawMode(on);
  }
  process.stdin.resume();
}

function readKey() {
  return new Promise((resolve) => {
    const handler = (chunk) => {
      process.stdin.removeListener('data', handler);
      const key = chunk.toString();
      // Arrow keys come as escape sequences: \x1b[A (up), [B (down), [C (right), [D (left)
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

async function fileBrowser(options = {}) {
  const {
    startDir = null,
    extensions = VIDEO_EXTENSIONS,
    multiple = false,
  } = options;

  let currentDir = startDir || process.cwd();
  let selected = [];
  let cursor = 0;
  let scrollOffset = 0;
  let showHidden = false;
  const pageSize = 20;

  while (true) {
    // Read directory
    let entries;
    try {
      entries = fs.readdirSync(currentDir, { withFileTypes: true });
    } catch (e) {
      // Permission denied or other error — go up
      currentDir = path.dirname(currentDir);
      continue;
    }

    // Filter + sort
    entries = entries.filter((e) => {
      if (!showHidden && e.name.startsWith('.')) return false;
      return true;
    });

    // Always show ".." first, then directories, then files
    const dirs = entries.filter((e) => e.isDirectory()).sort((a, b) => a.name.localeCompare(b.name));
    const files = entries.filter((e) => {
      if (!e.isFile()) return false;
      if (extensions.length === 0) return true;
      const ext = path.extname(e.name).slice(1).toLowerCase();
      return extensions.includes(ext);
    }).sort((a, b) => a.name.localeCompare(b.name));

    const items = [{ name: '..', isDir: true, path: path.dirname(currentDir) }]
      .concat(dirs.map((d) => ({ name: d.name + '/', isDir: true, path: path.join(currentDir, d.name) })))
      .concat(files.map((f) => ({ name: f.name, isDir: false, path: path.join(currentDir, f.name) })));

    if (cursor >= items.length) cursor = items.length - 1;
    if (cursor < 0) cursor = 0;
    if (cursor < scrollOffset) scrollOffset = cursor;
    if (cursor >= scrollOffset + pageSize) scrollOffset = cursor - pageSize + 1;

    // Render
    process.stdout.write('\x1b[2J\x1b[H'); // clear screen
    renderHeader(currentDir, extensions, showHidden, multiple, selected);
    renderItems(items, cursor, scrollOffset, pageSize, selected);
    renderFooter();

    // Wait for key
    setRawMode(true);
    const key = await readKey();
    setRawMode(false);

    if (key === 'up') {
      cursor = Math.max(0, cursor - 1);
    } else if (key === 'down') {
      cursor = Math.min(items.length - 1, cursor + 1);
    } else if (key === 'enter' || key === 'right') {
      const item = items[cursor];
      if (!item) continue;
      if (item.isDir) {
        currentDir = item.path;
        cursor = 0;
        scrollOffset = 0;
      } else {
        // File selected
        if (multiple) {
          const idx = selected.indexOf(item.path);
          if (idx >= 0) {
            selected.splice(idx, 1);
          } else {
            selected.push(item.path);
          }
          // Stay in picker for more selections
        } else {
          return [item.path];
        }
      }
    } else if (key === 'backspace' || key === 'left') {
      currentDir = path.dirname(currentDir);
      cursor = 0;
      scrollOffset = 0;
    } else if (key === 'escape' || key === 'quit') {
      // Confirm exit
      if (selected.length > 0) {
        return selected;
      }
      return null;
    } else if (key === 'toggle-hidden') {
      showHidden = !showHidden;
    } else if (key === 'help') {
      showHelp();
    }
  }
}

function renderHeader(currentDir, extensions, showHidden, multiple, selected) {
  const shortDir = shortenPath(currentDir, 60);
  console.log(`${C.bg}${C.bold}  🥋 VideoSensei File Picker${C.reset}  ${C.muted}${multiple ? '(multi-select)' : ''}${C.reset}`);
  console.log('');
  console.log(`  ${C.muted}📁${C.reset} ${C.accent}${shortDir}${C.reset}`);
  console.log(`  ${C.muted}Filter: ${C.reset}${C.cyan}${extensions.length > 0 ? extensions.join(', ') : 'all files'}${C.reset}  ${C.muted}Hidden: ${C.reset}${showHidden ? C.accent + 'on' : C.dim + 'off'}${C.reset}${selected.length > 0 ? `  ${C.muted}Selected: ${C.reset}${C.accent}${selected.length}${C.reset}` : ''}`);
  console.log(`  ${C.dim}${'─'.repeat(76)}${C.reset}`);
}

function renderItems(items, cursor, scrollOffset, pageSize, selected) {
  const visible = items.slice(scrollOffset, scrollOffset + pageSize);
  visible.forEach((item, i) => {
    const idx = scrollOffset + i;
    const isSelected = idx === cursor;
    const inSelected = selected.includes(item.path);

    let icon;
    if (item.name === '..') icon = '↩';
    else if (item.isDir) icon = '📁';
    else icon = '🎬';

    let name = item.name;
    let nameColor = C.ink;
    if (item.name === '..') nameColor = C.muted;
    else if (item.isDir) nameColor = C.blue;
    else nameColor = C.ink;

    // Truncate long names
    if (name.length > 60) name = name.slice(0, 57) + '...';

    const checkmark = inSelected ? `${C.accent}✓${C.reset} ` : '  ';
    const pointer = isSelected ? `${C.accent}❯${C.reset} ` : '  ';

    if (isSelected) {
      console.log(`${pointer}${checkmark}${C.bgHover} ${icon} ${name} ${C.reset}`);
    } else {
      console.log(`${pointer}${checkmark}${nameColor} ${icon} ${name}${C.reset}`);
    }
  });

  // Pad to pageSize
  for (let i = visible.length; i < pageSize; i++) {
    console.log('');
  }
}

function renderFooter() {
  console.log(`  ${C.dim}${'─'.repeat(76)}${C.reset}`);
  console.log(`  ${C.muted}↑↓ navigate  ${C.reset}${C.muted}→/Enter open  ${C.reset}${C.muted}←/⌫ up dir  ${C.reset}${C.muted}h hidden  ${C.reset}${C.muted}q done${C.reset}`);
}

function shortenPath(p, max) {
  if (p.length <= max) return p;
  // Replace home with ~
  const home = os.homedir();
  if (p.startsWith(home)) p = '~' + p.slice(home.length);
  if (p.length <= max) return p;
  // Truncate middle
  const start = p.slice(0, Math.floor(max / 2) - 2);
  const end = p.slice(p.length - Math.floor(max / 2));
  return start + '...' + end;
}

function showHelp() {
  process.stdout.write('\x1b[2J\x1b[H');
  console.log(`${C.bg}${C.bold}  🥋 File Picker Help${C.reset}`);
  console.log('');
  console.log(`  ${C.accent}↑ ↓${C.reset}     Navigate up/down`);
  console.log(`  ${C.accent}→ / Enter${C.reset}  Open directory / select file`);
  console.log(`  ${C.accent}← / ⌫${C.reset}   Go to parent directory`);
  console.log(`  ${C.accent}h${C.reset}       Toggle hidden files`);
  console.log(`  ${C.accent}q / Esc${C.reset}  Done (return selection)`);
  console.log('');
  console.log(`  ${C.muted}In multi-select mode, Enter toggles selection.${C.reset}`);
  console.log(`  ${C.muted}Press q to finish and return all selected files.${C.reset}`);
  console.log('');
  console.log(`  ${C.muted}Press any key to continue...${C.reset}`);
  setRawMode(true);
  return readKey().then(() => {
    setRawMode(false);
  });
}

// ============================================================================
// MAIN EXPORT
// ============================================================================

/**
 * Pick a file. Tries external picker first, then falls back to Node browser.
 *
 * @param {Object} options
 * @param {string} options.startDir - Initial directory (default: cwd)
 * @param {string[]} options.extensions - File extensions to filter (default: video files)
 * @param {boolean} options.multiple - Allow multiple selection
 * @param {boolean} options.preferExternal - Try external picker first (default: true)
 * @returns {Promise<string[]|null>} Array of paths, or null if cancelled
 */
async function pickFile(options = {}) {
  const opts = {
    startDir: process.cwd(),
    extensions: VIDEO_EXTENSIONS,
    multiple: false,
    preferExternal: true,
    ...options,
  };

  // Try external picker first
  if (opts.preferExternal) {
    const result = tryExternalPicker(opts);
    if (result) {
      return Array.isArray(result) ? result : [result];
    }
  }

  // Fall back to Node browser
  if (!process.stdin.isTTY) {
    return null;
  }

  return await fileBrowser(opts);
}

/**
 * Quick check: is any file picker available?
 */
function isPickerAvailable() {
  return !!(commandExists('termux-file-picker') ||
         commandExists('zenity') ||
         commandExists('kdialog') ||
         commandExists('osascript') ||
         commandExists('fzf') ||
         (process.platform === 'win32' && commandExists('powershell')) ||
         process.stdin.isTTY);
}

module.exports = {
  pickFile,
  isPickerAvailable,
  VIDEO_EXTENSIONS,
  fileBrowser,
};
