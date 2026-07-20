#!/usr/bin/env node
/**
 * VideoSensei — Master your video. Sensei-grade clarity.
 *
 * Modern, branded CLI for video compression.
 *   • 5 quality presets: Lite / Balanced / Crystal / Sensei / Custom
 *   • H.264 / H.265 / AV1 codec support
 *   • Smart mode with auto-recommendation
 *   • Batch processing
 *   • History log
 *   • Theme: neon green on near-black (inherited from jubairsensei.com)
 *
 * Author: Jubair Sensei <jubairsensei@gmail.com>
 * Site:   https://jubairsensei.com
 * Repo:   https://github.com/JubairSenseiDev/VideoSensei
 * License: MIT
 *
 * Usage:
 *   videosensei                          # interactive mode
 *   videosensei <file>                   # quick compress (Balanced)
 *   videosensei <file> -p lite           # Lite preset
 *   videosensei <file> -p sensei         # AV1 master
 *   videosensei <file> -p custom --crf 22 --codec h265
 *   videosensei <file1> <file2> -p lite  # batch
 *   videosensei --history                # show past compressions
 *   videosensei --help
 *   videosensei --version
 */

'use strict';

const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');

// ============================================================================
// THEME — extracted from jubairsensei.com (see THEME.md)
// ============================================================================
const THEME = {
  // Dark mode (terminal default)
  bg: '\x1b[48;2;10;10;11m',     // #0A0A0B
  bgElevated: '\x1b[48;2;17;17;20m', // #111114
  accent: '\x1b[38;2;0;255;136m',   // #00FF88 neon green
  accentDim: '\x1b[38;2;0;204;106m', // #00CC6A
  ink: '\x1b[38;2;255;255;255m',     // #FFFFFF
  inkSecondary: '\x1b[38;2;161;161;170m', // #A1A1AA
  inkMuted: '\x1b[38;2;82;82;91m',   // #52525B
  muted: '\x1b[38;2;82;82;91m',      // #52525B (alias for inkMuted, used as prefix)
  secondary: '\x1b[38;2;161;161;170m', // #A1A1AA (alias, used as prefix)
  cyan: '\x1b[38;2;34;211;238m',     // #22D3EE (Balanced)
  blue: '\x1b[38;2;59;130;246m',     // #3B82F6 (Crystal)
  purple: '\x1b[38;2;199;125;255m',  // #C77DFF (Custom)
  orange: '\x1b[38;2;251;146;60m',   // #FB923C (Lite)
  yellow: '\x1b[38;2;250;204;21m',   // #FACC15 (warning)
  red: '\x1b[38;2;248;113;113m',     // #F87171 (error)
  lime: '\x1b[38;2;212;255;0m',      // #D4FF00 (code)
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  italic: '\x1b[3m',
  underline: '\x1b[4m',
  // Styles (functions — wrap text in start/end codes)
  glow: (text) => `\x1b[38;2;0;255;136m\x1b[1m${text}\x1b[0m`,
  success: (text) => `\x1b[38;2;0;255;136m${text}\x1b[0m`,
  warn: (text) => `\x1b[38;2;250;204;21m${text}\x1b[0m`,
  err: (text) => `\x1b[38;2;248;113;113m${text}\x1b[0m`,
  secondaryWrap: (text) => `\x1b[38;2;161;161;170m${text}\x1b[0m`,
};

// ============================================================================
// PRESETS — see COMPRESSION.md for the strategy
// ============================================================================
const PRESETS = {
  lite: {
    name: 'Lite',
    icon: '🪶',
    color: THEME.orange,
    codec: 'libx264',
    crf: 30,
    preset: 'veryfast',
    audioCodec: 'aac',
    audioBitrate: '128k',
    container: 'mp4',
    extraArgs: ['-pix_fmt', 'yuv420p', '-movflags', '+faststart'],
    tag: undefined,
    description: 'Quick share, max compat (H.264, CRF 30)',
    useCase: 'WhatsApp/Telegram share, email attachments',
  },
  balanced: {
    name: 'Balanced',
    icon: '⚖️',
    color: THEME.cyan,
    codec: 'libx265',
    crf: 26,
    preset: 'medium',
    audioCodec: 'aac',
    audioBitrate: '128k',
    container: 'mp4',
    extraArgs: ['-pix_fmt', 'yuv420p', '-tag:v', 'hvc1', '-movflags', '+faststart'],
    description: 'Daily default (H.265, CRF 26) — 50% smaller, sharp',
    useCase: 'General use, cloud storage, archive',
  },
  crystal: {
    name: 'Crystal',
    icon: '💎',
    color: THEME.blue,
    codec: 'libx265',
    crf: 22,
    preset: 'slow',
    audioCodec: 'aac',
    audioBitrate: '192k',
    container: 'mp4',
    extraArgs: ['-pix_fmt', 'yuv420p', '-tag:v', 'hvc1', '-movflags', '+faststart'],
    description: 'Archive quality (H.265, CRF 22) — near-lossless',
    useCase: 'Archiving family videos, masters, high-value content',
  },
  sensei: {
    name: 'Sensei',
    icon: '🥋',
    color: THEME.accent,
    codec: 'libsvtav1',
    crf: 32,
    preset: '6',
    audioCodec: 'libopus',
    audioBitrate: '96k',
    container: 'mkv',
    extraArgs: ['-pix_fmt', 'yuv420p'],
    description: 'Future-proof master (AV1, CRF 32) — smallest file',
    useCase: 'Future-proofing, web delivery, maximum compression',
  },
  custom: {
    name: 'Custom',
    icon: '🎯',
    color: THEME.purple,
    description: 'Full manual control',
    useCase: 'Power users',
  },
};

const PRESET_KEYS = ['lite', 'balanced', 'crystal', 'sensei', 'custom'];

// ============================================================================
// PATHS
// ============================================================================
const HOME = os.homedir();
const SENSEI_DIR = path.join(HOME, '.videosensei');
const HISTORY_FILE = path.join(SENSEI_DIR, 'history.json');
const LOG_FILE = path.join(SENSEI_DIR, 'videosensi.log');
const VERSION = '1.0.0';

// ============================================================================
// UTILITIES
// ============================================================================

function ensureDirs() {
  if (!fs.existsSync(SENSEI_DIR)) {
    fs.mkdirSync(SENSEI_DIR, { recursive: true });
  }
}

function log(msg) {
  ensureDirs();
  const ts = new Date().toISOString();
  fs.appendFileSync(LOG_FILE, `[${ts}] ${msg}\n`);
}

function loadHistory() {
  ensureDirs();
  if (!fs.existsSync(HISTORY_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(HISTORY_FILE, 'utf8'));
  } catch {
    return [];
  }
}

function saveHistory(history) {
  ensureDirs();
  fs.writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2));
}

function addToHistory(entry) {
  const history = loadHistory();
  history.unshift(entry);
  // Keep last 100 entries
  if (history.length > 100) history.length = 100;
  saveHistory(history);
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`;
}

function formatDuration(seconds) {
  if (seconds < 60) return `${seconds.toFixed(1)}s`;
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}m ${s}s`;
}

function formatTime(timestamp) {
  const d = new Date(timestamp);
  const now = Date.now();
  const diff = now - timestamp;
  if (diff < 60000) return 'just now';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}d ago`;
  return d.toLocaleDateString();
}

function checkFFmpeg() {
  try {
    execSync('ffmpeg -version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function checkFFprobe() {
  try {
    execSync('ffprobe -version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

async function probeVideo(filePath) {
  return new Promise((resolve, reject) => {
    const args = [
      '-v', 'quiet',
      '-print_format', 'json',
      '-show_format',
      '-show_streams',
      filePath,
    ];
    const proc = spawn('ffprobe', args, { stdio: ['pipe', 'pipe', 'pipe'] });
    let stdout = '';
    let stderr = '';
    proc.stdout.on('data', (d) => stdout += d);
    proc.stderr.on('data', (d) => stderr += d);
    proc.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`ffprobe failed: ${stderr || 'unknown error'}`));
        return;
      }
      try {
        const data = JSON.parse(stdout);
        const format = data.format || {};
        const videoStream = (data.streams || []).find((s) => s.codec_type === 'video');
        const audioStream = (data.streams || []).find((s) => s.codec_type === 'audio');
        resolve({
          path: filePath,
          duration: parseFloat(format.duration || 0),
          size: parseInt(format.size || 0, 10),
          bitrate: parseInt(format.bit_rate || 0, 10),
          container: (format.format_name || '').split(',')[0],
          video: videoStream ? {
            codec: videoStream.codec_name,
            width: videoStream.width,
            height: videoStream.height,
            fps: evalFps(videoStream.r_frame_rate),
            bitrate: parseInt(videoStream.bit_rate || 0, 10),
          } : null,
          audio: audioStream ? {
            codec: audioStream.codec_name,
            channels: audioStream.channels,
            sampleRate: parseInt(audioStream.sample_rate || 0, 10),
            bitrate: parseInt(audioStream.bit_rate || 0, 10),
          } : null,
        });
      } catch (e) {
        reject(new Error(`Failed to parse ffprobe output: ${e.message}`));
      }
    });
  });
}

function evalFps(rateStr) {
  if (!rateStr || rateStr === '0/0') return 0;
  const [num, den] = rateStr.split('/').map(Number);
  return den ? num / den : 0;
}

function getOutputPath(inputPath, presetKey, outputDir) {
  const ext = PRESETS[presetKey].container || 'mp4';
  const parsed = path.parse(inputPath);
  const outName = `${parsed.name}_sensei.${ext}`;
  if (!outputDir || outputDir === 'same') {
    return path.join(parsed.dir, outName);
  }
  return path.join(outputDir, outName);
}

function buildFFmpegArgs(input, output, presetKey, customOpts = {}) {
  const preset = PRESETS[presetKey];
  const args = ['-i', input, '-y'];

  if (presetKey === 'custom') {
    const codec = customOpts.codec || 'libx265';
    const crf = customOpts.crf || 26;
    const encPreset = customOpts.preset || 'medium';
    const audioCodec = customOpts.audioCodec || 'aac';
    const audioBitrate = customOpts.audioBitrate || '128k';

    args.push(
      '-c:v', codec,
      '-crf', String(crf),
      '-preset', encPreset,
      '-pix_fmt', 'yuv420p'
    );
    if (codec === 'libx265') {
      args.push('-tag:v', 'hvc1');
    }
    args.push(
      '-c:a', audioCodec,
      '-b:a', audioBitrate,
      '-movflags', '+faststart',
      output
    );
    return args;
  }

  args.push(
    '-c:v', preset.codec,
    '-crf', String(preset.crf),
    '-preset', String(preset.preset),
    ...preset.extraArgs,
    '-c:a', preset.audioCodec,
    '-b:a', preset.audioBitrate,
    '-metadata', `title=Compressed by VideoSensei (${preset.name})`,
    '-metadata', `comment=https://jubairsensei.com`,
    output
  );
  return args;
}

// Smart mode: recommend a preset based on source video
function recommendPreset(meta) {
  if (!meta || !meta.video) return 'balanced';

  const bitrate = meta.bitrate || 0;
  const duration = meta.duration || 0;
  const resolution = meta.video.height || 0;
  const codec = meta.video.codec || '';

  // Already AV1 → don't re-encode
  if (codec === 'av1') return null;

  // Very low bitrate already → skip
  if (bitrate > 0 && bitrate < 500000) return null;

  // Short clip → Lite
  if (duration > 0 && duration < 30) return 'lite';

  // 4K → Balanced (will downscale optional)
  if (resolution >= 2160) return 'balanced';

  // Very high bitrate, likely high motion → Crystal
  if (bitrate > 5000000) return 'crystal';

  // Default → Balanced
  return 'balanced';
}

// Predict output size (rough estimate)
function predictOutputSize(meta, presetKey) {
  if (!meta || !meta.video) return null;

  const sourceBitrate = meta.bitrate || 0;
  if (!sourceBitrate) return null;

  const codecFactors = {
    libx264: 0.6,   // 40% reduction
    libx265: 0.5,   // 50% reduction
    libsvtav1: 0.35, // 65% reduction
  };
  const preset = PRESETS[presetKey];
  if (!preset || presetKey === 'custom') return null;

  const codec = preset.codec;
  const codecFactor = codecFactors[codec] || 0.5;

  // CRF factor — lower CRF = higher bitrate (rough heuristic)
  const crfFactor = (preset.crf - 18) / 14 + 0.7; // CRF 18 → 0.7, CRF 32 → 1.4

  const targetBitrate = sourceBitrate * codecFactor * crfFactor;
  const predictedSize = (targetBitrate * meta.duration) / 8;

  return {
    bytes: Math.round(predictedSize),
    reduction: meta.size > 0 ? (1 - predictedSize / meta.size) : 0,
  };
}

// ============================================================================
// UI — Display functions
// ============================================================================

function clear() {
  process.stdout.write('\x1b[2J\x1b[H');
}

function printLogo(small = false) {
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

function printHelp() {
  printLogo(true);
  console.log(`${THEME.bold}USAGE${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset}                          ${THEME.muted}# interactive mode${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file>                   ${THEME.muted}# quick compress (Balanced)${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file> -p <preset>       ${THEME.muted}# specific preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file1> <file2> ... -p <preset>  ${THEME.muted}# batch${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} --history               ${THEME.muted}# show past compressions${THEME.reset}`);
  console.log('');
  console.log(`${THEME.bold}PRESETS${THEME.reset}`);
  PRESET_KEYS.forEach((key) => {
    const p = PRESETS[key];
    console.log(`  ${p.color}${p.icon} ${p.name.padEnd(10)}${THEME.reset}  ${THEME.muted}-p ${key.padEnd(9)}${THEME.reset}  ${p.description}`);
  });
  console.log('');
  console.log(`${THEME.bold}OPTIONS${THEME.reset}`);
  console.log(`  ${THEME.accent}-p, --preset${THEME.reset} <name>     Preset: lite|balanced|crystal|sensei|custom`);
  console.log(`  ${THEME.accent}-o, --output${THEME.reset} <dir>       Output directory (default: same as input)`);
  console.log(`  ${THEME.accent}-y, --yes${THEME.reset}                Skip confirmation prompts`);
  console.log(`  ${THEME.accent}--codec${THEME.reset} <name>            Custom: h264|h265|av1 (with -p custom)`);
  console.log(`  ${THEME.accent}--crf${THEME.reset} <0-51>              Custom: CRF value (with -p custom)`);
  console.log(`  ${THEME.accent}--audio-bitrate${THEME.reset} <k>       Custom: audio bitrate, e.g. 128k`);
  console.log(`  ${THEME.accent}--smart${THEME.reset}                  Use smart mode (auto-recommend preset)`);
  console.log(`  ${THEME.accent}--history${THEME.reset}                Show compression history`);
  console.log(`  ${THEME.accent}--clear-history${THEME.reset}          Clear all history`);
  console.log(`  ${THEME.accent}-h, --help${THEME.reset}               Show this help`);
  console.log(`  ${THEME.accent}-v, --version${THEME.reset}            Show version`);
  console.log('');
  console.log(`${THEME.bold}EXAMPLES${THEME.reset}`);
  console.log(`  ${THEME.muted}# Quick compress a video with Balanced preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} vacation.mp4`);
  console.log('');
  console.log(`  ${THEME.muted}# Compress for WhatsApp (smallest H.264)${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4 -p lite`);
  console.log('');
  console.log(`  ${THEME.muted}# Future-proof AV1 master${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4 -p sensei`);
  console.log('');
  console.log(`  ${THEME.muted}# Custom: H.265 CRF 22${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4 -p custom --codec h265 --crf 22`);
  console.log('');
  console.log(`  ${THEME.muted}# Batch compress${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} *.mp4 -p balanced`);
  console.log('');
  console.log(`${THEME.bold}BRAND${THEME.reset}`);
  console.log(`  ${THEME.muted}Author:${THEME.reset}  Jubair Sensei <jubairsensei@gmail.com>`);
  console.log(`  ${THEME.muted}Site:${THEME.reset}    https://jubairsensei.com`);
  console.log(`  ${THEME.muted}Repo:${THEME.reset}    https://github.com/JubairSenseiDev/VideoSensei`);
  console.log(`  ${THEME.muted}License:${THEME.reset} MIT`);
}

function printPresets(meta) {
  console.log(`${THEME.bold}CHOOSE YOUR PRESET${THEME.reset}`);
  console.log('');
  PRESET_KEYS.forEach((key, i) => {
    const p = PRESETS[key];
    const num = `${THEME.muted}${i + 1}.${THEME.reset}`;
    let line = `  ${num} ${p.color}${p.icon} ${p.name.padEnd(10)}${THEME.reset}  ${p.description}`;

    if (meta && key !== 'custom') {
      const prediction = predictOutputSize(meta, key);
      if (prediction) {
        const pct = Math.round(prediction.reduction * 100);
        line += ` ${THEME.muted}→ ~${formatBytes(prediction.bytes)} (${pct}% ↓)${THEME.reset}`;
      }
    }
    console.log(line);
  });
  console.log('');
}

async function prompt(question) {
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
// COMPRESSION — the heart of the tool
// ============================================================================

function parseProgress(stderrLine, totalDuration) {
  // Parse ffmpeg stderr lines like:
  // frame=  123 fps= 45 q=28.0 size=    1024kB time=00:00:05.12 bitrate= 1640.6kbits/s speed=2.5x
  const out = {};
  const m = stderrLine.match(/frame=\s*(\d+)/);
  if (m) out.frame = parseInt(m[1], 10);
  const t = stderrLine.match(/time=\s*(\d+):(\d+):(\d+\.?\d*)/);
  if (t) {
    out.time = parseInt(t[1], 10) * 3600 + parseInt(t[2], 10) * 60 + parseFloat(t[3]);
    if (totalDuration > 0) {
      out.progress = Math.min(100, (out.time / totalDuration) * 100);
    }
  }
  const s = stderrLine.match(/speed=\s*([\d.]+)x/);
  if (s) out.speed = parseFloat(s[1]);
  const b = stderrLine.match(/bitrate=\s*([\d.]+)kbits\/s/);
  if (b) out.bitrate = parseFloat(b[1]);
  const sz = stderrLine.match(/size=\s*(\d+)kB/);
  if (sz) out.size = parseInt(sz[1], 10) * 1024;
  return out;
}

function drawProgress(progress, elapsedSec, etaSec) {
  const width = 30;
  const filled = Math.round((progress / 100) * width);
  const empty = width - filled;
  const bar = `${THEME.accent}${'━'.repeat(filled)}${THEME.muted}${'━'.repeat(empty)}${THEME.reset}`;
  const pct = `${progress.toFixed(0).padStart(3)}%`;
  const elapsed = formatDuration(elapsedSec);
  const eta = etaSec > 0 ? formatDuration(etaSec) : '--';
  process.stdout.write(`\r  ${bar} ${THEME.accent}${THEME.bold}${pct}${THEME.reset} ${THEME.muted}elapsed:${THEME.reset} ${elapsed.padStart(7)} ${THEME.muted}eta:${THEME.reset} ${eta.padStart(7)}   `);
}

async function compressVideo(inputPath, presetKey, options = {}) {
  const preset = PRESETS[presetKey];
  if (!preset) {
    throw new Error(`Unknown preset: ${presetKey}`);
  }

  // Validate input
  if (!fs.existsSync(inputPath)) {
    throw new Error(`File not found: ${inputPath}`);
  }

  // Probe source
  let meta;
  try {
    meta = await probeVideo(inputPath);
  } catch (e) {
    throw new Error(`Failed to probe video: ${e.message}`);
  }

  const outputPath = getOutputPath(inputPath, presetKey, options.outputDir);
  const predictedSize = predictOutputSize(meta, presetKey);

  // Show summary
  console.log('');
  console.log(`  ${THEME.muted}Source:${THEME.reset}  ${path.basename(inputPath)}`);
  if (meta.video) {
    console.log(`           ${meta.video.width}x${meta.video.height} @ ${meta.video.fps.toFixed(1)}fps · ${meta.video.codec.toUpperCase()} · ${formatDuration(meta.duration)} · ${formatBytes(meta.size)}`);
  }
  console.log(`  ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset} ${THEME.muted}— ${preset.description}${THEME.reset}`);
  console.log(`  ${THEME.muted}Output:${THEME.reset}  ${path.basename(outputPath)}`);
  if (predictedSize) {
    const pct = Math.round(predictedSize.reduction * 100);
    console.log(`  ${THEME.muted}Predict:${THEME.reset} ~${formatBytes(predictedSize.bytes)} ${THEME.accent}(${pct}% smaller)${THEME.reset}`);
  }
  console.log('');

  // Confirmation
  if (!options.yes) {
    const answer = await prompt(`  ${THEME.bold}Compress now?${THEME.reset} ${THEME.muted}[Y/n]${THEME.reset} `);
    if (answer && !answer.match(/^[Yy]/)) {
      console.log(`  ${THEME.muted}Cancelled.${THEME.reset}`);
      return null;
    }
    console.log('');
  }

  // Build args
  const args = buildFFmpegArgs(inputPath, outputPath, presetKey, options);
  log(`START preset=${presetKey} input=${inputPath} output=${outputPath} args=${JSON.stringify(args)}`);

  // Run ffmpeg
  const startTime = Date.now();
  let lastProgressUpdate = 0;
  let lastFrame = 0;
  let lastTime = 0;

  return new Promise((resolve, reject) => {
    const proc = spawn('ffmpeg', args, { stdio: ['pipe', 'pipe', 'pipe'] });
    let stderrBuf = '';
    let lastError = '';

    proc.stderr.on('data', (data) => {
      stderrBuf += data.toString();
      const lines = stderrBuf.split('\n');
      stderrBuf = lines.pop() || '';

      for (const line of lines) {
        if (line.includes('error') || line.includes('Error')) {
          lastError = line;
        }
        const p = parseProgress(line, meta.duration);
        if (p.progress !== undefined) {
          const now = Date.now();
          if (now - lastProgressUpdate > 200) {
            const elapsed = (now - startTime) / 1000;
            const eta = p.progress > 0 ? (elapsed / p.progress) * (100 - p.progress) : 0;
            drawProgress(p.progress, elapsed, eta);
            lastProgressUpdate = now;
            lastFrame = p.frame || lastFrame;
            lastTime = p.time || lastTime;
          }
        }
      }
    });

    proc.on('close', async (code) => {
      process.stdout.write('\r' + ' '.repeat(80) + '\r');
      const elapsed = (Date.now() - startTime) / 1000;

      if (code !== 0) {
        log(`FAILED preset=${presetKey} input=${inputPath} code=${code} error=${lastError}`);
        // Fallback to H.264 if not already H.264
        if (preset.codec !== 'libx264') {
          console.log(`  ${THEME.warn('⚠')}  ${preset.name} failed. Falling back to H.264 (Lite)...${THEME.reset}`);
          const fallbackOutput = getOutputPath(inputPath, 'lite', options.outputDir);
          const fallbackArgs = buildFFmpegArgs(inputPath, fallbackOutput, 'lite', {});
          try {
            execSync(`ffmpeg ${fallbackArgs.map((a) => `'${a.replace(/'/g, "'\\''")}'`).join(' ')}`, { stdio: 'inherit' });
            const stats = fs.statSync(fallbackOutput);
            console.log(`  ${THEME.success('✓')}  Fallback succeeded: ${path.basename(fallbackOutput)} (${formatBytes(stats.size)})${THEME.reset}`);
            const result = {
              timestamp: Date.now(),
              input: inputPath,
              output: fallbackOutput,
              preset: 'lite (fallback)',
              inputSize: meta.size,
              outputSize: stats.size,
              duration: elapsed,
              success: true,
            };
            addToHistory(result);
            log(`FALLBACK_SUCCESS input=${inputPath} output=${fallbackOutput}`);
            resolve(result);
            return;
          } catch (e) {
            // continue to error below
          }
        }
        console.log(`  ${THEME.err('✗')}  Compression failed.${THEME.reset}`);
        if (lastError) console.log(`     ${THEME.muted(lastError.trim())}${THEME.reset}`);
        console.log(`     ${THEME.muted('Check log:')} ${LOG_FILE}${THEME.reset}`);
        reject(new Error(`FFmpeg exited with code ${code}: ${lastError}`));
        return;
      }

      // Success
      const outStats = fs.statSync(outputPath);
      let reduction = meta.size > 0 ? (1 - outStats.size / meta.size) * 100 : 0;
      let actuallySaved = reduction > 0;

      // If output is larger than source, warn and offer to delete
      if (!actuallySaved && meta.size > 0) {
        console.log(`  ${THEME.warn('⚠')}  Output is larger than source (${formatBytes(outStats.size)} vs ${formatBytes(meta.size)}).${THEME.reset}`);
        console.log(`     ${THEME.muted}Source was already well-compressed.${THEME.reset}`);

        // Auto-delete the larger output (in -y mode) or ask
        let shouldDelete = true;
        if (!options.yes) {
          const answer = await prompt(`  ${THEME.bold}Delete the larger output?${THEME.reset} ${THEME.muted}[Y/n]${THEME.reset} `);
          shouldDelete = !answer || answer.match(/^[Yy]/);
        }
        if (shouldDelete) {
          fs.unlinkSync(outputPath);
          console.log(`  ${THEME.muted}Deleted output. Source is already optimal — no compression needed.${THEME.reset}`);
          log(`SKIPPED preset=${presetKey} input=${inputPath} reason=output_larger_than_source (${reduction.toFixed(1)}%)`);
          resolve({
            timestamp: Date.now(),
            input: inputPath,
            output: null,
            preset: preset.name,
            inputSize: meta.size,
            outputSize: meta.size,
            reduction: 0,
            duration: elapsed,
            success: false,
            skipped: true,
          });
          return;
        }
        reduction = 0;
      }

      const reductionPct = reduction.toFixed(1);

      if (actuallySaved) {
        console.log(`  ${THEME.success('✓')}  Done in ${formatDuration(elapsed)}${THEME.reset}`);
        console.log(`     ${THEME.muted}Output:${THEME.reset}  ${path.basename(outputPath)}`);
        console.log(`     ${THEME.muted}Size:${THEME.reset}    ${formatBytes(meta.size)} → ${THEME.accent}${THEME.bold}${formatBytes(outStats.size)}${THEME.reset}  ${THEME.success(`(${reductionPct}% ↓`)}`);
        console.log(`     ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset}`);
      } else {
        console.log(`  ${THEME.success('✓')}  Done in ${formatDuration(elapsed)} (kept output)${THEME.reset}`);
      }
      console.log('');

      const result = {
        timestamp: Date.now(),
        input: inputPath,
        output: outputPath,
        preset: preset.name,
        inputSize: meta.size,
        outputSize: outStats.size,
        reduction: reduction,
        duration: elapsed,
        success: actuallySaved,
      };
      addToHistory(result);
      log(`SUCCESS preset=${presetKey} input=${inputPath} output=${outputPath} reduction=${reductionPct}%`);
      resolve(result);
    });

    proc.on('error', (e) => {
      reject(new Error(`Failed to spawn ffmpeg: ${e.message}`));
    });

    // Handle Ctrl-C
    process.on('SIGINT', () => {
      proc.kill('SIGINT');
      console.log(`\n  ${THEME.warn('⚠')}  Cancelled by user.${THEME.reset}`);
      process.exit(130);
    });
  });
}

// ============================================================================
// HISTORY VIEW
// ============================================================================

function printHistory() {
  printLogo(true);
  const history = loadHistory();
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
    const icon = '🎬';
    console.log(`${idx}${icon} ${name}`);
    console.log(`     ${THEME.muted}${preset} · ${formatBytes(entry.inputSize)} → ${formatBytes(entry.outputSize)} ${THEME.accent}${reduction}${THEME.reset} · ${time}${THEME.reset}`);
  });
  if (history.length > 20) {
    console.log(`  ${THEME.muted}... and ${history.length - 20} more (see ${HISTORY_FILE})${THEME.reset}`);
  }
  console.log('');
}

// ============================================================================
// INTERACTIVE MODE
// ============================================================================

async function interactiveMode() {
  clear();
  printLogo();

  // Welcome
  console.log(`  ${THEME.muted}Welcome, Sensei. 🥋${THEME.reset}`);
  console.log(`  ${THEME.muted}Pick a video to begin.${THEME.reset}`);
  console.log('');

  // Get file path
  let filePath = process.argv[2];
  if (!filePath) {
    filePath = await prompt(`  ${THEME.bold}Video path:${THEME.reset} `);
  }
  if (!filePath) {
    console.log(`  ${THEME.warn('No file selected. Bye!')}${THEME.reset}`);
    process.exit(0);
  }
  filePath = filePath.replace(/^['"]|['"]$/g, '').replace(/^~(?=\/|$)/, HOME);
  if (!fs.existsSync(filePath)) {
    console.log(`  ${THEME.err('✗')}  File not found: ${filePath}${THEME.reset}`);
    process.exit(1);
  }

  // Probe
  let meta;
  try {
    console.log(`  ${THEME.muted}Probing video...${THEME.reset}`);
    meta = await probeVideo(filePath);
  } catch (e) {
    console.log(`  ${THEME.err('✗')}  ${e.message}${THEME.reset}`);
    process.exit(1);
  }

  console.log('');
  console.log(`  ${THEME.bold}Source:${THEME.reset} ${path.basename(filePath)}`);
  if (meta.video) {
    console.log(`  ${THEME.muted}         ${meta.video.width}x${meta.video.height} @ ${meta.video.fps.toFixed(1)}fps · ${meta.video.codec.toUpperCase()} · ${formatDuration(meta.duration)} · ${formatBytes(meta.size)}${THEME.reset}`);
  }
  console.log('');

  // Smart recommendation
  const recommended = recommendPreset(meta);
  if (recommended === null) {
    console.log(`  ${THEME.warn('⚠')}  Sensei says: source is already small or in AV1. Re-compression not recommended.${THEME.reset}`);
    console.log(`     ${THEME.muted}Proceed anyway?${THEME.reset}`);
  } else if (recommended) {
    const p = PRESETS[recommended];
    console.log(`  ${THEME.success('🥋')}  ${THEME.bold}Sensei recommends:${THEME.reset} ${p.color}${p.icon} ${p.name}${THEME.reset} ${THEME.muted}— ${p.useCase}${THEME.reset}`);
  }
  console.log('');

  // Show presets
  printPresets(meta);

  // Get preset choice
  const choice = await prompt(`  ${THEME.bold}Pick preset${THEME.reset} ${THEME.muted}[1-5, default: ${recommended === null ? 2 : (PRESET_KEYS.indexOf(recommended) + 1)}]${THEME.reset}: `);
  let presetIdx;
  if (!choice) {
    presetIdx = recommended === null ? 1 : PRESET_KEYS.indexOf(recommended);
  } else {
    presetIdx = parseInt(choice, 10) - 1;
    if (isNaN(presetIdx) || presetIdx < 0 || presetIdx >= PRESET_KEYS.length) {
      console.log(`  ${THEME.err('✗')}  Invalid choice${THEME.reset}`);
      process.exit(1);
    }
  }
  const presetKey = PRESET_KEYS[presetIdx];

  // Custom options
  const customOpts = {};
  if (presetKey === 'custom') {
    console.log('');
    const codecChoice = await prompt(`  ${THEME.bold}Codec${THEME.reset} ${THEME.muted}[1=h264, 2=h265, 3=av1, default 2]${THEME.reset}: `);
    const codecMap = { '1': 'libx264', '2': 'libx265', '3': 'libsvtav1' };
    customOpts.codec = codecMap[codecChoice || '2'] || 'libx265';

    const crfChoice = await prompt(`  ${THEME.bold}CRF${THEME.reset} ${THEME.muted}[0-51, lower=better, default 26]${THEME.reset}: `);
    customOpts.crf = parseInt(crfChoice, 10) || 26;

    const audioChoice = await prompt(`  ${THEME.bold}Audio bitrate${THEME.reset} ${THEME.muted}[64/96/128/192/256, default 128]${THEME.reset}: `);
    customOpts.audioBitrate = `${audioChoice || '128'}k`;
  }

  // Compress
  try {
    await compressVideo(filePath, presetKey, { ...customOpts, yes: false });
  } catch (e) {
    console.log(`  ${THEME.err('✗')}  ${e.message}${THEME.reset}`);
    process.exit(1);
  }

  // What's next
  console.log(`  ${THEME.muted}Hack the size. Keep the clarity.${THEME.reset}`);
  console.log(`  ${THEME.muted}https://jubairsensei.com${THEME.reset}`);
  console.log('');
}

// ============================================================================
// ARGUMENT PARSING
// ============================================================================

function parseArgs(argv) {
  const args = {
    files: [],
    preset: null,
    outputDir: null,
    yes: false,
    smart: false,
    showHistory: false,
    clearHistory: false,
    showHelp: false,
    showVersion: false,
    custom: {
      codec: null,
      crf: null,
      audioBitrate: null,
    },
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = argv[i + 1];

    if (arg === '-h' || arg === '--help') {
      args.showHelp = true;
    } else if (arg === '-v' || arg === '--version') {
      args.showVersion = true;
    } else if (arg === '--history') {
      args.showHistory = true;
    } else if (arg === '--clear-history') {
      args.clearHistory = true;
    } else if (arg === '-y' || arg === '--yes') {
      args.yes = true;
    } else if (arg === '--smart') {
      args.smart = true;
    } else if (arg === '-p' || arg === '--preset') {
      args.preset = next;
      i++;
    } else if (arg === '-o' || arg === '--output') {
      args.outputDir = next;
      i++;
    } else if (arg === '--codec') {
      const c = next.toLowerCase();
      args.custom.codec = c === 'h264' ? 'libx264' : c === 'h265' ? 'libx265' : c === 'av1' ? 'libsvtav1' : next;
      i++;
    } else if (arg === '--crf') {
      args.custom.crf = parseInt(next, 10);
      i++;
    } else if (arg === '--audio-bitrate') {
      args.custom.audioBitrate = next;
      i++;
    } else if (arg.startsWith('-')) {
      // unknown flag, ignore
    } else {
      // file argument
      args.files.push(arg);
    }
  }

  return args;
}

// ============================================================================
// MAIN
// ============================================================================

async function main() {
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
    saveHistory([]);
    console.log(`${THEME.success('✓')}  History cleared.`);
    return;
  }

  if (args.showHistory) {
    printHistory();
    return;
  }

  // Check dependencies
  if (!checkFFmpeg()) {
    console.log(`${THEME.err('✗')}  FFmpeg not found. Install it first:${THEME.reset}`);
    console.log(`     ${THEME.muted}Ubuntu/Debian:${THEME.reset}  sudo apt install ffmpeg`);
    console.log(`     ${THEME.muted}macOS:${THEME.reset}         brew install ffmpeg`);
    console.log(`     ${THEME.muted}Termux:${THEME.reset}        pkg install ffmpeg`);
    console.log(`     ${THEME.muted}Windows:${THEME.reset}       choco install ffmpeg`);
    process.exit(1);
  }
  if (!checkFFprobe()) {
    console.log(`${THEME.err('✗')}  FFprobe not found (usually ships with FFmpeg).${THEME.reset}`);
    process.exit(1);
  }

  // No files = interactive mode
  if (args.files.length === 0) {
    await interactiveMode();
    return;
  }

  // Validate preset
  let presetKey = args.preset;
  if (!presetKey) {
    presetKey = 'balanced';
  }
  if (!PRESET_KEYS.includes(presetKey)) {
    console.log(`${THEME.err('✗')}  Unknown preset: ${presetKey}${THEME.reset}`);
    console.log(`   ${THEME.muted}Available:${THEME.reset} ${PRESET_KEYS.join(', ')}`);
    process.exit(1);
  }

  // Smart mode override
  if (args.smart && args.files.length === 1) {
    const meta = await probeVideo(args.files[0]);
    const rec = recommendPreset(meta);
    if (rec) {
      presetKey = rec;
      const p = PRESETS[rec];
      console.log(`${THEME.success('🥋')}  Sensei recommends: ${p.color}${p.icon} ${p.name}${THEME.reset}`);
    }
  }

  // Output directory
  if (args.outputDir && !fs.existsSync(args.outputDir)) {
    fs.mkdirSync(args.outputDir, { recursive: true });
  }

  // Batch or single
  printLogo(true);
  console.log('');

  for (let i = 0; i < args.files.length; i++) {
    const file = args.files[i].replace(/^['"]|['"]$/g, '').replace(/^~(?=\/|$)/, HOME);
    if (args.files.length > 1) {
      console.log(`${THEME.bold}[${i + 1}/${args.files.length}]${THEME.reset} ${path.basename(file)}`);
    }
    try {
      await compressVideo(file, presetKey, {
        outputDir: args.outputDir,
        yes: args.yes,
        ...args.custom,
      });
    } catch (e) {
      console.log(`${THEME.err('✗')}  ${e.message}${THEME.reset}`);
      log(`ERROR file=${file} error=${e.message}`);
    }
  }

  console.log(`${THEME.muted}Hack the size. Keep the clarity.${THEME.reset}`);
  console.log(`${THEME.muted}https://jubairsensei.com${THEME.reset}`);
}

main().catch((e) => {
  console.error(`${THEME.err('✗')}  Fatal: ${e.message}${THEME.reset}`);
  process.exit(1);
});
