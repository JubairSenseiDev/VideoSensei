// VideoSensei — Main entry point
//
// v1.1.0 — Auto-everything:
//   • videosensei           → picker → smart preset → compress (zero prompts)
//   • videosensei file.mp4  → smart preset → compress (zero prompts)
//   • videosensei -p sensei → smart preset override → compress
//   • videosensei -i        → interactive menu (old behavior, power users)
//
// Author: Jubair Sensei <jubairsensei@gmail.com>
// Site:   https://jubairsensei.com
// License: MIT

import path from 'node:path';
import fs from 'node:fs';
import os from 'node:os';
import readline from 'node:readline';
import type { ParsedArgs, PresetKey, VideoMetadata, CompressionResult } from './types.js';
import { PRESETS, PRESET_KEYS } from './presets.js';
import { THEME } from './theme.js';
import { probeVideo, checkFFmpeg, checkFFprobe } from './probe.js';
import {
  compressWithFallback,
  drawProgress,
  formatBytes,
  formatDuration,
  getOutputPath,
} from './ffmpeg.js';
import {
  ensureDirs,
  loadHistory,
  addToHistory,
  clearHistory,
  log,
  HISTORY_PATH,
} from './history.js';
import { recommendPreset, predictOutputSize } from './smart.js';
import { printLogo, printHelp, printHistory, clear, VERSION } from './ui.js';
import { pickFile, isPickerAvailable } from './filepicker.js';

// ============================================================================
// PROMPT HELPER
// ============================================================================

function prompt(question: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

// ============================================================================
// ARGUMENT PARSING
// ============================================================================

function parseArgs(argv: string[]): ParsedArgs {
  const args: ParsedArgs = {
    files: [],
    preset: null,
    outputDir: null,
    yes: true,           // AUTO by default — no confirmation prompts
    smart: true,         // AUTO by default — smart mode on
    pick: false,
    interactive: false,
    showHistory: false,
    clearHistory: false,
    showHelp: false,
    showVersion: false,
    custom: {},
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = argv[i + 1];

    if (arg === '-h' || arg === '--help') args.showHelp = true;
    else if (arg === '-v' || arg === '--version') args.showVersion = true;
    else if (arg === '--history') args.showHistory = true;
    else if (arg === '--clear-history') args.clearHistory = true;
    else if (arg === '-y' || arg === '--yes') args.yes = true;
    else if (arg === '--confirm') args.yes = false;
    else if (arg === '--smart') args.smart = true;
    else if (arg === '--no-smart') args.smart = false;
    else if (arg === '-i' || arg === '--interactive') args.interactive = true;
    else if (arg === '--pick' || arg === '-P') args.pick = true;
    else if (arg === '-p' || arg === '--preset') {
      args.preset = (next as PresetKey) || null;
      i++;
    } else if (arg === '-o' || arg === '--output') {
      args.outputDir = next || null;
      i++;
    } else if (arg === '--codec') {
      const c = (next || '').toLowerCase();
      args.custom.codec = c === 'h264' ? 'libx264' : c === 'h265' ? 'libx265' : c === 'av1' ? 'libsvtav1' : next;
      i++;
    } else if (arg === '--crf') {
      args.custom.crf = parseInt(next || '', 10);
      i++;
    } else if (arg === '--audio-bitrate') {
      args.custom.audioBitrate = next;
      i++;
    } else if (arg.startsWith('-')) {
      // unknown flag, ignore
    } else {
      args.files.push(arg);
    }
  }

  return args;
}

// ============================================================================
// FILE PICKER INTEGRATION
// ============================================================================

async function pickFiles(multiple = false): Promise<string[] | null> {
  if (!isPickerAvailable()) {
    console.log(`${THEME.red}✗${THEME.reset}  File picker not available.`);
    console.log(`   ${THEME.muted}Install one of:${THEME.reset}`);
    console.log(`     ${THEME.accent}Termux${THEME.reset}: pkg install termux-api  ${THEME.muted}(then install Termux:API app)${THEME.reset}`);
    console.log(`     ${THEME.accent}Linux${THEME.reset}: sudo apt install zenity  ${THEME.muted}(or: fzf)${THEME.reset}`);
    console.log(`     ${THEME.accent}macOS${THEME.reset}: built-in (osascript)`);
    console.log(`   ${THEME.muted}Or type the file path: videosensei /path/to/video.mp4${THEME.reset}`);
    return null;
  }
  console.log(`  ${THEME.muted}Opening file picker...${THEME.reset}`);
  return pickFile({ multiple });
}

// ============================================================================
// COMPRESS — the heart, now auto-everything
// ============================================================================

async function compressOne(
  filePath: string,
  presetKey: PresetKey,
  options: { outputDir?: string | null; yes?: boolean; custom?: typeof PRESETS.custom } = {}
): Promise<void> {
  // Probe
  let meta: VideoMetadata;
  try {
    meta = await probeVideo(filePath);
  } catch (e) {
    console.log(`  ${THEME.red}✗${THEME.reset}  ${(e as Error).message}`);
    return;
  }

  const preset = PRESETS[presetKey];
  const predictedSize = presetKey !== 'custom' ? predictOutputSize(meta, presetKey) : null;
  const output = getOutputPath(filePath, presetKey, options.outputDir);

  // Show summary
  console.log('');
  console.log(`  ${THEME.muted}Source:${THEME.reset}  ${path.basename(filePath)}`);
  if (meta.video) {
    console.log(`           ${meta.video.width}x${meta.video.height} @ ${meta.video.fps.toFixed(1)}fps · ${meta.video.codec.toUpperCase()} · ${formatDuration(meta.duration)} · ${formatBytes(meta.size)}`);
  }
  console.log(`  ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset} ${THEME.muted}— ${preset.description}${THEME.reset}`);
  console.log(`  ${THEME.muted}Output:${THEME.reset}  ${path.basename(output)}`);
  if (predictedSize) {
    const pct = Math.round(predictedSize.reduction * 100);
    console.log(`  ${THEME.muted}Predict:${THEME.reset} ~${formatBytes(predictedSize.bytes)} ${THEME.accent}(${pct}% smaller)${THEME.reset}`);
  }
  console.log('');

  // Confirm (only if user opted in)
  if (options.yes === false) {
    const answer = await prompt(`  ${THEME.bold}Compress now?${THEME.reset} ${THEME.muted}[Y/n]${THEME.reset} `);
    if (answer && !answer.match(/^[Yy]/)) {
      console.log(`  ${THEME.muted}Skipped.${THEME.reset}`);
      return;
    }
    console.log('');
  }

  log(`START preset=${presetKey} input=${filePath} output=${output}`);

  const result = await compressWithFallback(
    filePath,
    presetKey,
    meta,
    {
      outputDir: options.outputDir ?? undefined,
      yes: options.yes,
      ...options.custom,
    },
    {
      onProgress: (p, elapsed, eta) => drawProgress(p.progress ?? 0, elapsed, eta),
      onFallback: (reason) => console.log(`  ${THEME.yellow}⚠${THEME.reset}  ${reason}${THEME.reset}`),
    }
  );

  // Clear progress line
  process.stdout.write('\r' + ' '.repeat(80) + '\r');

  if (result.success) {
    const pct = result.reduction.toFixed(1);
    console.log(`  ${THEME.accent}✓${THEME.reset}  ${THEME.bold}Done${THEME.reset} in ${formatDuration(result.duration)}`);
    console.log(`     ${THEME.muted}Output:${THEME.reset}  ${path.basename(result.output)}`);
    console.log(`     ${THEME.muted}Size:${THEME.reset}    ${formatBytes(meta.size)} → ${THEME.accent}${THEME.bold}${formatBytes(result.outputSize)}${THEME.reset}  ${THEME.accent}(${pct}% ↓)${THEME.reset}`);
    console.log(`     ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset}`);
    console.log('');

    const entry: CompressionResult = {
      timestamp: Date.now(),
      input: filePath,
      output: result.output,
      preset: preset.name,
      inputSize: meta.size,
      outputSize: result.outputSize,
      reduction: result.reduction,
      duration: result.duration,
      success: true,
    };
    addToHistory(entry);
    log(`SUCCESS preset=${presetKey} input=${filePath} output=${result.output} reduction=${pct}%`);
  } else if ('skipped' in result && result.skipped) {
    console.log(`  ${THEME.yellow}⚠${THEME.reset}  Skipped: ${result.reason}`);
    console.log(`     ${THEME.muted}Source already optimal — no compression needed.${THEME.reset}`);
    console.log('');
    log(`SKIPPED input=${filePath} reason=${result.reason}`);
  } else {
    console.log(`  ${THEME.red}✗${THEME.reset}  Compression failed.`);
    if ('error' in result) {
      console.log(`     ${THEME.muted}${result.error}${THEME.reset}`);
    }
    console.log(`     ${THEME.muted}Debug log: ${HISTORY_PATH.replace('history.json', 'videosensi.log')}${THEME.reset}`);
    console.log('');
    log(`FAILED input=${filePath} error=${'error' in result ? result.error : 'unknown'}`);
  }
}

// ============================================================================
// AUTO MODE — the new default
// ============================================================================

async function autoMode(args: ParsedArgs): Promise<void> {
  printLogo(true);

  // Step 1: Get files (via picker if no args, else use args)
  let files = args.files;
  if (files.length === 0) {
    const picked = await pickFiles(false);
    if (!picked || picked.length === 0) {
      console.log(`  ${THEME.muted}No file selected. Bye!${THEME.reset}`);
      return;
    }
    files = picked;
  }

  // Normalize paths
  files = files.map((p) => p.replace(/^['"]|['"]$/g, '').replace(/^~(?=\/|$)/, os.homedir()));

  // Validate
  for (const p of files) {
    if (!fs.existsSync(p)) {
      console.log(`  ${THEME.red}✗${THEME.reset}  File not found: ${p}`);
      return;
    }
  }

  // Step 2: Determine preset
  let presetKey = args.preset;
  if (!presetKey) {
    if (args.smart && files.length === 1) {
      const meta = await probeVideo(files[0]);
      const recommended = recommendPreset(meta);
      if (recommended === null) {
        console.log(`  ${THEME.yellow}⚠${THEME.reset}  Source is already AV1 — re-encoding won't help.`);
        console.log(`  ${THEME.muted}Force a preset with -p if you really want to re-encode.${THEME.reset}`);
        return;
      }
      presetKey = recommended;
      const p = PRESETS[presetKey];
      console.log(`  ${THEME.accent}🥋${THEME.reset}  ${THEME.bold}Sensei auto-picked:${THEME.reset} ${p.color}${p.icon} ${p.name}${THEME.reset} ${THEME.muted}— ${p.useCase}${THEME.reset}`);
    } else {
      presetKey = 'balanced';
    }
  }

  if (!PRESET_KEYS.includes(presetKey)) {
    console.log(`  ${THEME.red}✗${THEME.reset}  Unknown preset: ${presetKey}`);
    console.log(`   ${THEME.muted}Available:${THEME.reset} ${PRESET_KEYS.join(', ')}`);
    return;
  }

  // Step 3: Output dir
  if (args.outputDir && !fs.existsSync(args.outputDir)) {
    fs.mkdirSync(args.outputDir, { recursive: true });
  }

  // Step 4: Compress all files (zero prompts by default)
  for (let i = 0; i < files.length; i++) {
    if (files.length > 1) {
      console.log(`${THEME.bold}  [${i + 1}/${files.length}]${THEME.reset} ${path.basename(files[i])}`);
    }
    await compressOne(files[i], presetKey, {
      outputDir: args.outputDir,
      yes: args.yes,
      custom: args.custom as any,
    });
  }

  console.log(`  ${THEME.muted}Hack the size. Keep the clarity. 🥋${THEME.reset}`);
  console.log(`  ${THEME.muted}https://jubairsensei.com${THEME.reset}`);
}

// ============================================================================
// INTERACTIVE MODE (old behavior, opt-in with -i)
// ============================================================================

async function interactiveMode(args: ParsedArgs): Promise<void> {
  clear();
  printLogo();

  console.log(`  ${THEME.muted}Welcome, Sensei. 🥋${THEME.reset}`);
  console.log(`  ${THEME.muted}Master your video. Sensei-grade clarity.${THEME.reset}`);
  console.log('');

  console.log(`  ${THEME.bold}WHAT WOULD YOU LIKE TO DO?${THEME.reset}`);
  console.log('');
  console.log(`  ${THEME.accent}1.${THEME.reset} 🎬 Pick a video and compress  ${THEME.muted}(file picker)${THEME.reset}`);
  console.log(`  ${THEME.accent}2.${THEME.reset} 📂 Type path manually         ${THEME.muted}(paste path)${THEME.reset}`);
  console.log(`  ${THEME.accent}3.${THEME.reset} 📦 Batch compress              ${THEME.muted}(multiple files)${THEME.reset}`);
  console.log(`  ${THEME.accent}4.${THEME.reset} 📜 View history                ${THEME.muted}(past compressions)${THEME.reset}`);
  console.log(`  ${THEME.accent}5.${THEME.reset} ❓ Help                         ${THEME.muted}(show all options)${THEME.reset}`);
  console.log(`  ${THEME.accent}q.${THEME.reset} Quit`);
  console.log('');

  const mainChoice = await prompt(`  ${THEME.bold}Your choice${THEME.reset} ${THEME.muted}[1]${THEME.reset}: `);

  if (mainChoice === 'q' || mainChoice === 'Q') {
    console.log(`  ${THEME.muted}Bye! Hack the size. Keep the clarity. 🥋${THEME.reset}`);
    return;
  }
  if (mainChoice === '4') {
    printHistory(loadHistory());
    return;
  }
  if (mainChoice === '5') {
    printHelp();
    return;
  }

  let filePaths: string[] = [];

  if (mainChoice === '3') {
    const selected = await pickFiles(true);
    if (!selected || selected.length === 0) {
      console.log(`  ${THEME.yellow}No files selected. Bye!${THEME.reset}`);
      return;
    }
    filePaths = selected;
  } else if (mainChoice === '2') {
    const input = await prompt(`  ${THEME.bold}Video path:${THEME.reset} `);
    if (!input) return;
    filePaths = [input];
  } else {
    const selected = await pickFiles(false);
    if (!selected || selected.length === 0) {
      console.log(`  ${THEME.yellow}No file selected. Bye!${THEME.reset}`);
      return;
    }
    filePaths = selected;
  }

  filePaths = filePaths.map((p) => p.replace(/^['"]|['"]$/g, '').replace(/^~(?=\/|$)/, os.homedir()));

  for (const p of filePaths) {
    if (!fs.existsSync(p)) {
      console.log(`  ${THEME.red}✗${THEME.reset}  File not found: ${p}`);
      return;
    }
  }

  // Probe first file for smart recommendation
  let firstMeta: VideoMetadata | null = null;
  if (filePaths.length === 1) {
    try {
      firstMeta = await probeVideo(filePaths[0]);
    } catch {}
  }

  // Show presets
  console.log('');
  console.log(`  ${THEME.bold}CHOOSE YOUR PRESET${THEME.reset}`);
  console.log('');
  PRESET_KEYS.forEach((key, i) => {
    const p = PRESETS[key];
    const num = `${THEME.muted}${i + 1}.${THEME.reset}`;
    let line = `  ${num} ${p.color}${p.icon} ${p.name.padEnd(10)}${THEME.reset}  ${p.description}`;
    if (firstMeta && key !== 'custom') {
      const prediction = predictOutputSize(firstMeta, key);
      if (prediction) {
        const pct = Math.round(prediction.reduction * 100);
        line += ` ${THEME.muted}→ ~${formatBytes(prediction.bytes)} (${pct}% ↓)${THEME.reset}`;
      }
    }
    console.log(line);
  });
  console.log('');

  const recommended = firstMeta ? recommendPreset(firstMeta) : 'balanced';
  const defaultChoice = recommended === null ? 2 : (PRESET_KEYS.indexOf(recommended as PresetKey) + 1);

  const choice = await prompt(`  ${THEME.bold}Pick preset${THEME.reset} ${THEME.muted}[1-5, default: ${defaultChoice}]${THEME.reset}: `);
  let presetIdx: number;
  if (!choice) presetIdx = defaultChoice - 1;
  else {
    presetIdx = parseInt(choice, 10) - 1;
    if (isNaN(presetIdx) || presetIdx < 0 || presetIdx >= PRESET_KEYS.length) {
      console.log(`  ${THEME.red}✗${THEME.reset}  Invalid choice`);
      return;
    }
  }
  const presetKey = PRESET_KEYS[presetIdx];

  const customOpts: any = {};
  if (presetKey === 'custom') {
    console.log('');
    const codecChoice = await prompt(`  ${THEME.bold}Codec${THEME.reset} ${THEME.muted}[1=h264, 2=h265, 3=av1, default 2]${THEME.reset}: `);
    const codecMap: Record<string, string> = { '1': 'libx264', '2': 'libx265', '3': 'libsvtav1' };
    customOpts.codec = codecMap[codecChoice || '2'] || 'libx265';

    const crfChoice = await prompt(`  ${THEME.bold}CRF${THEME.reset} ${THEME.muted}[0-51, lower=better, default 26]${THEME.reset}: `);
    customOpts.crf = parseInt(crfChoice, 10) || 26;

    const audioChoice = await prompt(`  ${THEME.bold}Audio bitrate${THEME.reset} ${THEME.muted}[64/96/128/192/256, default 128]${THEME.reset}: `);
    customOpts.audioBitrate = `${audioChoice || '128'}k`;
  }

  console.log('');
  for (let i = 0; i < filePaths.length; i++) {
    if (filePaths.length > 1) {
      console.log(`${THEME.bold}  [${i + 1}/${filePaths.length}]${THEME.reset} ${path.basename(filePaths[i])}`);
    }
    await compressOne(filePaths[i], presetKey, {
      outputDir: args.outputDir,
      yes: filePaths.length > 1,
      custom: customOpts,
    });
  }

  console.log(`  ${THEME.muted}Hack the size. Keep the clarity. 🥋${THEME.reset}`);
  console.log(`  ${THEME.muted}https://jubairsensei.com${THEME.reset}`);
}

// ============================================================================
// MAIN
// ============================================================================

async function main(): Promise<void> {
  ensureDirs();
  const args = parseArgs(process.argv.slice(2));

  if (args.showHelp) {
    printHelp();
    return;
  }
  if (args.showVersion) {
    console.log(`VideoSensei v${VERSION}`);
    console.log(`https://jubairsensei.com`);
    return;
  }
  if (args.clearHistory) {
    clearHistory();
    console.log(`${THEME.accent}✓${THEME.reset}  History cleared.`);
    return;
  }
  if (args.showHistory) {
    printHistory(loadHistory());
    return;
  }

  // Check dependencies
  if (!checkFFmpeg()) {
    console.log(`${THEME.red}✗${THEME.reset}  FFmpeg not found. Install it first:`);
    console.log(`   ${THEME.muted}Ubuntu/Debian:${THEME.reset}  sudo apt install ffmpeg`);
    console.log(`   ${THEME.muted}macOS:${THEME.reset}         brew install ffmpeg`);
    console.log(`   ${THEME.muted}Termux:${THEME.reset}        pkg install ffmpeg`);
    console.log(`   ${THEME.muted}Windows:${THEME.reset}       choco install ffmpeg`);
    process.exit(1);
  }
  if (!checkFFprobe()) {
    console.log(`${THEME.red}✗${THEME.reset}  FFprobe not found (usually ships with FFmpeg).`);
    process.exit(1);
  }

  // --pick flag: open picker then auto-compress
  if (args.pick && args.files.length === 0) {
    const picked = await pickFiles(false);
    if (!picked || picked.length === 0) {
      console.log(`  ${THEME.muted}No file selected. Bye!${THEME.reset}`);
      return;
    }
    args.files = picked;
  }

  // Interactive mode (opt-in)
  if (args.interactive) {
    await interactiveMode(args);
    return;
  }

  // AUTO MODE (default) — zero prompts unless --confirm
  await autoMode(args);
}

main().catch((e) => {
  console.error(`${THEME.red}✗${THEME.reset}  Fatal: ${(e as Error).message}`);
  process.exit(1);
});
