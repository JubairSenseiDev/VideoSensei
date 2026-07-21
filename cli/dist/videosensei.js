#!/usr/bin/env node
var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/main.ts
import path5 from "node:path";
import fs4 from "node:fs";
import os3 from "node:os";
import readline from "node:readline";

// src/presets.ts
var PRESETS = {
  lite: {
    name: "Lite",
    icon: "\u{1FAB6}",
    color: "\x1B[38;2;251;146;60m",
    // orange
    codec: "libx264",
    crf: 30,
    preset: "veryfast",
    audioCodec: "aac",
    audioBitrate: "128k",
    container: "mp4",
    extraArgs: ["-pix_fmt", "yuv420p", "-movflags", "+faststart"],
    description: "Quick share, max compat (H.264, CRF 30)",
    useCase: "WhatsApp/Telegram share, email attachments"
  },
  balanced: {
    name: "Balanced",
    icon: "\u2696\uFE0F",
    color: "\x1B[38;2;34;211;238m",
    // cyan
    codec: "libx265",
    crf: 26,
    preset: "medium",
    audioCodec: "aac",
    audioBitrate: "128k",
    container: "mp4",
    extraArgs: ["-pix_fmt", "yuv420p", "-tag:v", "hvc1", "-movflags", "+faststart"],
    description: "Daily default (H.265, CRF 26) \u2014 50% smaller, sharp",
    useCase: "General use, cloud storage, archive"
  },
  crystal: {
    name: "Crystal",
    icon: "\u{1F48E}",
    color: "\x1B[38;2;59;130;246m",
    // blue
    codec: "libx265",
    crf: 22,
    preset: "slow",
    audioCodec: "aac",
    audioBitrate: "192k",
    container: "mp4",
    extraArgs: ["-pix_fmt", "yuv420p", "-tag:v", "hvc1", "-movflags", "+faststart"],
    description: "Archive quality (H.265, CRF 22) \u2014 near-lossless",
    useCase: "Archiving family videos, masters, high-value content"
  },
  sensei: {
    name: "Sensei",
    icon: "\u{1F94B}",
    color: "\x1B[38;2;0;255;136m",
    // accent green
    codec: "libsvtav1",
    crf: 32,
    preset: "6",
    audioCodec: "libopus",
    audioBitrate: "96k",
    container: "mkv",
    extraArgs: ["-pix_fmt", "yuv420p"],
    description: "Future-proof master (AV1, CRF 32) \u2014 smallest file",
    useCase: "Future-proofing, web delivery, maximum compression"
  },
  custom: {
    name: "Custom",
    icon: "\u{1F3AF}",
    color: "\x1B[38;2;199;125;255m",
    // purple
    codec: "",
    crf: 0,
    preset: "",
    audioCodec: "",
    audioBitrate: "",
    container: "mp4",
    extraArgs: [],
    description: "Full manual control",
    useCase: "Power users"
  }
};
var PRESET_KEYS = ["lite", "balanced", "crystal", "sensei", "custom"];
var CODEC_FACTORS = {
  libx264: 0.6,
  // 40% reduction
  libx265: 0.5,
  // 50% reduction
  libsvtav1: 0.35
  // 65% reduction
};

// src/theme.ts
var THEME = {
  // Backgrounds
  bg: "\x1B[48;2;10;10;11m",
  // #0A0A0B
  bgElevated: "\x1B[48;2;17;17;20m",
  // #111114
  // Foregrounds
  accent: "\x1B[38;2;0;255;136m",
  // #00FF88 neon green (signature)
  accentDim: "\x1B[38;2;0;204;106m",
  // #00CC6A
  ink: "\x1B[38;2;255;255;255m",
  // #FFFFFF
  inkSecondary: "\x1B[38;2;161;161;170m",
  // #A1A1AA
  inkMuted: "\x1B[38;2;82;82;91m",
  // #52525B
  muted: "\x1B[38;2;82;82;91m",
  // alias
  secondary: "\x1B[38;2;161;161;170m",
  // alias
  // Decorative (preset badges)
  cyan: "\x1B[38;2;34;211;238m",
  // Balanced
  blue: "\x1B[38;2;59;130;246m",
  // Crystal
  purple: "\x1B[38;2;199;125;255m",
  // Custom
  orange: "\x1B[38;2;251;146;60m",
  // Lite
  yellow: "\x1B[38;2;250;204;21m",
  // warning
  red: "\x1B[38;2;248;113;113m",
  // error
  lime: "\x1B[38;2;212;255;0m",
  // code
  // Styles
  reset: "\x1B[0m",
  bold: "\x1B[1m",
  dim: "\x1B[2m",
  italic: "\x1B[3m",
  underline: "\x1B[4m",
  bgHover: "\x1B[48;2;0;255;136m\x1B[38;2;10;10;11m"
};

// src/probe.ts
import { spawn } from "node:child_process";
import { execSync } from "node:child_process";
function checkFFmpeg() {
  try {
    execSync("ffmpeg -version", { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}
__name(checkFFmpeg, "checkFFmpeg");
function checkFFprobe() {
  try {
    execSync("ffprobe -version", { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}
__name(checkFFprobe, "checkFFprobe");
function evalFps(rateStr) {
  if (!rateStr || rateStr === "0/0") return 0;
  const [num, den] = rateStr.split("/").map(Number);
  return den ? num / den : 0;
}
__name(evalFps, "evalFps");
function probeVideo(filePath) {
  return new Promise((resolve, reject) => {
    const args = [
      "-v",
      "quiet",
      "-print_format",
      "json",
      "-show_format",
      "-show_streams",
      filePath
    ];
    const proc = spawn("ffprobe", args, { stdio: ["pipe", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    proc.stdout.on("data", (d) => {
      stdout += d;
    });
    proc.stderr.on("data", (d) => {
      stderr += d;
    });
    proc.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`ffprobe failed: ${stderr || "unknown error"}`));
        return;
      }
      try {
        const data = JSON.parse(stdout);
        const format = data.format || {};
        const videoStream = (data.streams || []).find((s) => s.codec_type === "video");
        const audioStream = (data.streams || []).find((s) => s.codec_type === "audio");
        resolve({
          path: filePath,
          duration: parseFloat(format.duration || "0"),
          size: parseInt(format.size || "0", 10),
          bitrate: parseInt(format.bit_rate || "0", 10),
          container: (format.format_name || "").split(",")[0],
          video: videoStream ? {
            codec: videoStream.codec_name || "",
            width: videoStream.width || 0,
            height: videoStream.height || 0,
            fps: evalFps(videoStream.r_frame_rate),
            bitrate: parseInt(videoStream.bit_rate || "0", 10)
          } : null,
          audio: audioStream ? {
            codec: audioStream.codec_name || "",
            channels: audioStream.channels || 0,
            sampleRate: parseInt(audioStream.sample_rate || "0", 10),
            bitrate: parseInt(audioStream.bit_rate || "0", 10)
          } : null
        });
      } catch (e) {
        reject(new Error(`Failed to parse ffprobe output: ${e.message}`));
      }
    });
    proc.on("error", (e) => reject(new Error(`Failed to spawn ffprobe: ${e.message}`)));
  });
}
__name(probeVideo, "probeVideo");

// src/ffmpeg.ts
import { spawn as spawn2 } from "node:child_process";
import path from "node:path";
import fs from "node:fs";
function getOutputPath(inputPath, presetKey, outputDir) {
  const ext = PRESETS[presetKey].container || "mp4";
  const parsed = path.parse(inputPath);
  const outName = `${parsed.name}_sensei.${ext}`;
  if (!outputDir || outputDir === "same") {
    return path.join(parsed.dir, outName);
  }
  return path.join(outputDir, outName);
}
__name(getOutputPath, "getOutputPath");
function buildFFmpegArgs(input, output, presetKey, customOpts = {}) {
  const preset = PRESETS[presetKey];
  const args = ["-i", input, "-y"];
  if (presetKey === "custom") {
    const codec = customOpts.codec || "libx265";
    const crf = customOpts.crf ?? 26;
    const encPreset = customOpts.preset || "medium";
    const audioCodec = customOpts.audioCodec || "aac";
    const audioBitrate = customOpts.audioBitrate || "128k";
    args.push(
      "-c:v",
      codec,
      "-crf",
      String(crf),
      "-preset",
      encPreset,
      "-pix_fmt",
      "yuv420p"
    );
    if (codec === "libx265") {
      args.push("-tag:v", "hvc1");
    }
    args.push(
      "-c:a",
      audioCodec,
      "-b:a",
      audioBitrate,
      "-movflags",
      "+faststart",
      output
    );
    return args;
  }
  args.push(
    "-c:v",
    preset.codec,
    "-crf",
    String(preset.crf),
    "-preset",
    String(preset.preset),
    ...preset.extraArgs,
    "-c:a",
    preset.audioCodec,
    "-b:a",
    preset.audioBitrate,
    "-metadata",
    `title=Compressed by VideoSensei (${preset.name})`,
    "-metadata",
    "comment=https://jubairsensei.com",
    output
  );
  return args;
}
__name(buildFFmpegArgs, "buildFFmpegArgs");
function parseProgress(stderrLine, totalDuration) {
  const out = {};
  const m = stderrLine.match(/frame=\s*(\d+)/);
  if (m) out.frame = parseInt(m[1], 10);
  const t = stderrLine.match(/time=\s*(\d+):(\d+):(\d+\.?\d*)/);
  if (t) {
    out.time = parseInt(t[1], 10) * 3600 + parseInt(t[2], 10) * 60 + parseFloat(t[3]);
    if (totalDuration > 0) {
      out.progress = Math.min(100, out.time / totalDuration * 100);
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
__name(parseProgress, "parseProgress");
function drawProgress(progress, elapsedSec, etaSec) {
  const width = 30;
  const filled = Math.round(progress / 100 * width);
  const empty = width - filled;
  const bar = `${THEME.accent}${"\u2501".repeat(filled)}${THEME.muted}${"\u2501".repeat(empty)}${THEME.reset}`;
  const pct = `${progress.toFixed(0).padStart(3)}%`;
  const elapsed = formatDuration(elapsedSec);
  const eta = etaSec > 0 ? formatDuration(etaSec) : "--";
  process.stdout.write(`\r  ${bar} ${THEME.accent}${THEME.bold}${pct}${THEME.reset} ${THEME.muted}elapsed:${THEME.reset} ${elapsed.padStart(7)} ${THEME.muted}eta:${THEME.reset} ${eta.padStart(7)}   `);
}
__name(drawProgress, "drawProgress");
function formatDuration(seconds) {
  if (seconds < 60) return `${seconds.toFixed(1)}s`;
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}m ${s}s`;
}
__name(formatDuration, "formatDuration");
function formatBytes(bytes) {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB", "TB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`;
}
__name(formatBytes, "formatBytes");
async function runFFmpeg(input, output, presetKey, meta, options = {}, callbacks) {
  const args = buildFFmpegArgs(input, output, presetKey, options);
  const startTime = Date.now();
  let lastProgressUpdate = 0;
  let lastError = "";
  return new Promise((resolve) => {
    const proc = spawn2("ffmpeg", args, { stdio: ["pipe", "pipe", "pipe"] });
    let stderrBuf = "";
    proc.stderr.on("data", (data) => {
      stderrBuf += data.toString();
      const lines = stderrBuf.split("\n");
      stderrBuf = lines.pop() || "";
      for (const line of lines) {
        if (line.includes("error") || line.includes("Error")) {
          lastError = line;
        }
        const p = parseProgress(line, meta.duration);
        if (p.progress !== void 0 && callbacks?.onProgress) {
          const now = Date.now();
          if (now - lastProgressUpdate > 200) {
            const elapsed = (now - startTime) / 1e3;
            const eta = p.progress > 0 ? elapsed / p.progress * (100 - p.progress) : 0;
            callbacks.onProgress(p, elapsed, eta);
            lastProgressUpdate = now;
          }
        }
      }
    });
    proc.on("close", (code) => {
      const elapsed = (Date.now() - startTime) / 1e3;
      if (code !== 0) {
        resolve({ success: false, error: `FFmpeg exited with code ${code}: ${lastError}` });
        return;
      }
      if (!fs.existsSync(output)) {
        resolve({ success: false, error: "FFmpeg exited cleanly but output file missing" });
        return;
      }
      const outStats = fs.statSync(output);
      const reduction = meta.size > 0 ? (1 - outStats.size / meta.size) * 100 : 0;
      if (meta.size > 0 && outStats.size >= meta.size) {
        fs.unlinkSync(output);
        resolve({
          success: false,
          skipped: true,
          reason: `Output (${formatBytes(outStats.size)}) was larger than source (${formatBytes(meta.size)}). Source already optimal.`,
          duration: elapsed
        });
        return;
      }
      resolve({
        success: true,
        output,
        outputSize: outStats.size,
        reduction,
        duration: elapsed
      });
    });
    proc.on("error", (e) => {
      resolve({ success: false, error: `Failed to spawn ffmpeg: ${e.message}` });
    });
    process.on("SIGINT", () => {
      proc.kill("SIGINT");
      process.exit(130);
    });
  });
}
__name(runFFmpeg, "runFFmpeg");
async function compressWithFallback(input, presetKey, meta, options = {}, callbacks) {
  const output = getOutputPath(input, presetKey, options.outputDir);
  const result = await runFFmpeg(input, output, presetKey, meta, options, callbacks);
  if (!result.success && !("skipped" in result) && presetKey !== "lite") {
    const preset = PRESETS[presetKey];
    callbacks?.onFallback?.(`${preset.name} failed, falling back to H.264 Lite`);
    const fallbackOutput = getOutputPath(input, "lite", options.outputDir);
    return runFFmpeg(input, fallbackOutput, "lite", meta, options, callbacks);
  }
  return result;
}
__name(compressWithFallback, "compressWithFallback");

// src/history.ts
import fs2 from "node:fs";
import path2 from "node:path";
import os from "node:os";
var SENSEI_DIR = path2.join(os.homedir(), ".videosensei");
var HISTORY_FILE = path2.join(SENSEI_DIR, "history.json");
var LOG_FILE = path2.join(SENSEI_DIR, "videosensi.log");
function ensureDirs() {
  if (!fs2.existsSync(SENSEI_DIR)) {
    fs2.mkdirSync(SENSEI_DIR, { recursive: true });
  }
}
__name(ensureDirs, "ensureDirs");
function log(message) {
  ensureDirs();
  const ts = (/* @__PURE__ */ new Date()).toISOString();
  try {
    fs2.appendFileSync(LOG_FILE, `[${ts}] ${message}
`);
  } catch {
  }
}
__name(log, "log");
function loadHistory() {
  ensureDirs();
  if (!fs2.existsSync(HISTORY_FILE)) return [];
  try {
    return JSON.parse(fs2.readFileSync(HISTORY_FILE, "utf8"));
  } catch {
    return [];
  }
}
__name(loadHistory, "loadHistory");
function saveHistory(history) {
  ensureDirs();
  fs2.writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2));
}
__name(saveHistory, "saveHistory");
function addToHistory(entry) {
  const history = loadHistory();
  history.unshift(entry);
  if (history.length > 100) history.length = 100;
  saveHistory(history);
}
__name(addToHistory, "addToHistory");
function clearHistory() {
  saveHistory([]);
}
__name(clearHistory, "clearHistory");
function formatTime(timestamp) {
  const d = new Date(timestamp);
  const now = Date.now();
  const diff = now - timestamp;
  if (diff < 6e4) return "just now";
  if (diff < 36e5) return `${Math.floor(diff / 6e4)}m ago`;
  if (diff < 864e5) return `${Math.floor(diff / 36e5)}h ago`;
  if (diff < 6048e5) return `${Math.floor(diff / 864e5)}d ago`;
  return d.toLocaleDateString();
}
__name(formatTime, "formatTime");
var HISTORY_PATH = HISTORY_FILE;

// src/smart.ts
function recommendPreset(meta) {
  if (!meta || !meta.video) return "balanced";
  const bitrate = meta.bitrate || 0;
  const duration = meta.duration || 0;
  const resolution = meta.video.height || 0;
  const codec = meta.video.codec || "";
  if (codec === "av1") return null;
  if (duration > 0 && duration < 30) return "lite";
  if (resolution >= 2160) return "balanced";
  if (bitrate > 5e6) return "crystal";
  if (bitrate > 0 && bitrate < 5e5) return "lite";
  return "balanced";
}
__name(recommendPreset, "recommendPreset");
function predictOutputSize(meta, presetKey) {
  if (!meta || !meta.video) return null;
  const sourceBitrate = meta.bitrate || 0;
  if (!sourceBitrate) return null;
  const codecFactor = CODEC_FACTORS[PRESET_CODEC[presetKey]] ?? 0.5;
  const crf = PRESET_CRF[presetKey];
  if (crf === void 0) return null;
  const crfFactor = (crf - 18) / 14 + 0.7;
  const targetBitrate = sourceBitrate * codecFactor * crfFactor;
  const predictedSize = targetBitrate * meta.duration / 8;
  return {
    bytes: Math.round(predictedSize),
    reduction: meta.size > 0 ? 1 - predictedSize / meta.size : 0
  };
}
__name(predictOutputSize, "predictOutputSize");
var PRESET_CODEC = {
  lite: "libx264",
  balanced: "libx265",
  crystal: "libx265",
  sensei: "libsvtav1",
  custom: ""
};
var PRESET_CRF = {
  lite: 30,
  balanced: 26,
  crystal: 22,
  sensei: 32
};

// src/ui.ts
import path3 from "node:path";
var VERSION = "1.1.0";
function clear() {
  process.stdout.write("\x1B[2J\x1B[H");
}
__name(clear, "clear");
function printLogo(small = false) {
  if (small) {
    console.log(`${THEME.accent}${THEME.bold}\u{1F94B} VideoSensei${THEME.reset} ${THEME.muted}v${VERSION}${THEME.reset}`);
    return;
  }
  const lines = [
    "",
    `${THEME.accent}    \u2571\u2501\u2501\u2501\u2501\u2501\u2501\u2501\u2572${THEME.reset}`,
    `${THEME.accent}   \u2571  \u2503\u2588\u2503  \u2572 ${THEME.reset}  ${THEME.bold}VIDEOSENSEI${THEME.reset} ${THEME.muted}v${VERSION}${THEME.reset}`,
    `${THEME.accent}  \u2571  \u2503\u2588\u2503  \u2572  ${THEME.reset}  ${THEME.muted}Master your video. Sensei-grade clarity.${THEME.reset}`,
    `${THEME.accent}  \u2572  \u2503\u2588\u2503  \u2571  ${THEME.reset}  ${THEME.muted}by Jubair Sensei${THEME.reset}`,
    `${THEME.accent}   \u2572\u2501\u2501\u2501\u2501\u2501\u2571   ${THEME.reset}  ${THEME.muted}https://jubairsensei.com${THEME.reset}`,
    ""
  ];
  lines.forEach((l) => console.log(l));
}
__name(printLogo, "printLogo");
function printHelp() {
  printLogo(true);
  console.log(`${THEME.bold}USAGE${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset}                          ${THEME.muted}# auto: pick + smart + compress${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file>                   ${THEME.muted}# auto: smart preset, no prompts${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <file> -p <preset>       ${THEME.muted}# specific preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} <f1> <f2> ... -p <p>     ${THEME.muted}# batch${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} --history                ${THEME.muted}# show past compressions${THEME.reset}`);
  console.log("");
  console.log(`${THEME.bold}PRESETS${THEME.reset}`);
  console.log(`  \u{1FAB6} Lite       H.264 CRF 30 \u2014 quick share, max compat`);
  console.log(`  \u2696\uFE0F Balanced   H.265 CRF 26 \u2014 daily default (50% smaller)`);
  console.log(`  \u{1F48E} Crystal    H.265 CRF 22 \u2014 archive, near-lossless`);
  console.log(`  \u{1F94B} Sensei     AV1   CRF 32 \u2014 future-proof, smallest`);
  console.log(`  \u{1F3AF} Custom     full manual control`);
  console.log("");
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
  console.log("");
  console.log(`${THEME.bold}FILE PICKERS${THEME.reset} (auto-detected)`);
  console.log(`  ${THEME.muted}Termux${THEME.reset}: termux-file-picker (pkg install termux-api)`);
  console.log(`  ${THEME.muted}macOS${THEME.reset}:  osascript (built-in)`);
  console.log(`  ${THEME.muted}Linux${THEME.reset}:  zenity (GTK) or kdialog (KDE)`);
  console.log(`  ${THEME.muted}Win${THEME.reset}:    PowerShell (.NET WinForms)`);
  console.log(`  ${THEME.muted}Any${THEME.reset}:    fzf (terminal fuzzy finder)`);
  console.log(`  ${THEME.muted}Fallback${THEME.reset}: built-in arrow-key browser`);
  console.log("");
  console.log(`${THEME.bold}EXAMPLES${THEME.reset}`);
  console.log(`  ${THEME.muted}# Easiest: just run it${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset}`);
  console.log("");
  console.log(`  ${THEME.muted}# Quick compress (auto-smart preset)${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4`);
  console.log("");
  console.log(`  ${THEME.muted}# Specific preset${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} video.mp4 -p sensei`);
  console.log("");
  console.log(`  ${THEME.muted}# Batch${THEME.reset}`);
  console.log(`  ${THEME.accent}videosensei${THEME.reset} *.mp4 -p balanced`);
  console.log("");
  console.log(`${THEME.bold}BRAND${THEME.reset}`);
  console.log(`  ${THEME.muted}Author:${THEME.reset}  Jubair Sensei <jubairsensei@gmail.com>`);
  console.log(`  ${THEME.muted}Site:${THEME.reset}    https://jubairsensei.com`);
  console.log(`  ${THEME.muted}Repo:${THEME.reset}    https://github.com/JubairSenseiDev/VideoSensei`);
  console.log(`  ${THEME.muted}License:${THEME.reset} MIT`);
}
__name(printHelp, "printHelp");
function printHistory(history) {
  printLogo(true);
  if (history.length === 0) {
    console.log(`  ${THEME.muted}No history yet. Your sensei will remember every video you master.${THEME.reset}`);
    console.log("");
    return;
  }
  console.log(`${THEME.bold}COMPRESSION HISTORY${THEME.reset} ${THEME.muted}(${history.length} entries)${THEME.reset}`);
  console.log("");
  history.slice(0, 20).forEach((entry, i) => {
    const idx = `${THEME.muted}${(i + 1).toString().padStart(2)}. ${THEME.reset}`;
    const name = path3.basename(entry.input);
    const time = formatTime(entry.timestamp);
    const reduction = entry.reduction ? `(${entry.reduction.toFixed(1)}% \u2193)` : "";
    const preset = entry.preset || "?";
    console.log(`${idx}\u{1F3AC} ${name}`);
    console.log(`     ${THEME.muted}${preset} \xB7 ${formatBytes(entry.inputSize)} \u2192 ${formatBytes(entry.outputSize)} ${THEME.accent}${reduction}${THEME.reset} \xB7 ${time}${THEME.reset}`);
  });
  if (history.length > 20) {
    console.log(`  ${THEME.muted}... and ${history.length - 20} more (see ${HISTORY_PATH})${THEME.reset}`);
  }
  console.log("");
}
__name(printHistory, "printHistory");

// src/filepicker.ts
import { execSync as execSync2, spawnSync } from "node:child_process";
import fs3 from "node:fs";
import path4 from "node:path";
import os2 from "node:os";
var VIDEO_EXTENSIONS = ["mp4", "mkv", "mov", "avi", "webm", "flv", "wmv", "m4v", "mpg", "mpeg", "ts", "3gp"];
function commandExists(cmd) {
  try {
    execSync2(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}
__name(commandExists, "commandExists");
function runTermuxPicker(multiple) {
  if (!commandExists("termux-file-picker")) return null;
  try {
    const args = ["--file"];
    if (multiple) args.push("--multiple");
    const result = spawnSync("termux-file-picker", args, { encoding: "utf8", timeout: 6e4 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split("\n").filter(Boolean);
  } catch {
    return null;
  }
}
__name(runTermuxPicker, "runTermuxPicker");
function runOsascriptPicker(multiple, extensions) {
  if (process.platform !== "darwin" || !commandExists("osascript")) return null;
  try {
    const extFilter = extensions.length > 0 ? ` of type {${extensions.map((e) => `"${e.toUpperCase()}"`).join(",")}}` : "";
    const chooseCmd = multiple ? `choose file${extFilter} with multiple selections allowed` : `choose file${extFilter}`;
    const result = spawnSync("osascript", ["-e", chooseCmd], { encoding: "utf8", timeout: 6e4 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split(",").map((line) => {
      const m = line.match(/alias "([^"]+)"/);
      if (!m) return null;
      return "/" + m[1].replace(/^([^:]+):/, "").split(":").join("/");
    }).filter((s) => Boolean(s));
  } catch {
    return null;
  }
}
__name(runOsascriptPicker, "runOsascriptPicker");
function runZenityPicker(multiple, extensions) {
  if (!commandExists("zenity")) return null;
  try {
    const args = ["--file-selection", "--title=Pick a video"];
    if (multiple) args.push("--multiple", "--separator=\n");
    if (extensions.length > 0) {
      extensions.forEach((ext) => args.push(`--file-filter=Video.${ext} | *.${ext}`));
    }
    const result = spawnSync("zenity", args, { encoding: "utf8", timeout: 6e4 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split("\n").filter(Boolean);
  } catch {
    return null;
  }
}
__name(runZenityPicker, "runZenityPicker");
function runKdialogPicker(multiple, extensions) {
  if (!commandExists("kdialog")) return null;
  try {
    const filter = extensions.length > 0 ? extensions.map((e) => `*.${e}`).join(" ") : "*";
    const args = ["--getopenfilename", ".", `${filter} | Video files`, "Pick a video"];
    if (multiple) args.unshift("--multiple", "--separate-output");
    const result = spawnSync("kdialog", args, { encoding: "utf8", timeout: 6e4 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split("\n").filter(Boolean);
  } catch {
    return null;
  }
}
__name(runKdialogPicker, "runKdialogPicker");
function runPowerShellPicker(multiple) {
  if (process.platform !== "win32" || !commandExists("powershell")) return null;
  try {
    const ps = `[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog;
$OpenFileDialog.Title = 'Pick a video';
$OpenFileDialog.Filter = 'Video files|*.mp4;*.mkv;*.mov;*.avi;*.webm;*.flv;*.wmv;*.m4v|All files|*.*';
$OpenFileDialog.Multiselect = $${multiple};
if ($OpenFileDialog.ShowDialog() -eq 'OK') { $OpenFileDialog.FileNames }`;
    const result = spawnSync("powershell", ["-NoProfile", "-Command", ps], { encoding: "utf8", timeout: 6e4 });
    if (result.status !== 0 || !result.stdout.trim()) return null;
    return result.stdout.trim().split("\n").map((s) => s.trim()).filter(Boolean);
  } catch {
    return null;
  }
}
__name(runPowerShellPicker, "runPowerShellPicker");
function tryExternalPicker(multiple, extensions) {
  return runTermuxPicker(multiple) || runOsascriptPicker(multiple, extensions) || runZenityPicker(multiple, extensions) || runKdialogPicker(multiple, extensions) || runPowerShellPicker(multiple);
}
__name(tryExternalPicker, "tryExternalPicker");
function setRawMode(on) {
  const stdin = process.stdin;
  if (stdin.isTTY && typeof stdin.setRawMode === "function") {
    stdin.setRawMode(on);
  }
  stdin.resume();
}
__name(setRawMode, "setRawMode");
function readKey() {
  return new Promise((resolve) => {
    const handler = /* @__PURE__ */ __name((chunk) => {
      process.stdin.removeListener("data", handler);
      const key = chunk.toString();
      if (key === "\x1B[A") return resolve("up");
      if (key === "\x1B[B") return resolve("down");
      if (key === "\x1B[C") return resolve("right");
      if (key === "\x1B[D") return resolve("left");
      if (key === "\r" || key === "\n") return resolve("enter");
      if (key === "\x1B") return resolve("escape");
      if (key === "\x7F" || key === "\b") return resolve("backspace");
      if (key === "q" || key === "Q") return resolve("quit");
      if (key === "h" || key === "H") return resolve("toggle-hidden");
      if (key === "?") return resolve("help");
      resolve(key);
    }, "handler");
    process.stdin.once("data", handler);
  });
}
__name(readKey, "readKey");
function shortenPath(p, max) {
  if (p.length <= max) return p;
  const home = os2.homedir();
  if (p.startsWith(home)) p = "~" + p.slice(home.length);
  if (p.length <= max) return p;
  const start = p.slice(0, Math.floor(max / 2) - 2);
  const end = p.slice(p.length - Math.floor(max / 2));
  return start + "..." + end;
}
__name(shortenPath, "shortenPath");
async function fileBrowser(options) {
  const extensions = options.extensions ?? VIDEO_EXTENSIONS;
  const multiple = options.multiple ?? false;
  const state = {
    currentDir: options.startDir || process.cwd(),
    cursor: 0,
    scrollOffset: 0,
    showHidden: false,
    selected: []
  };
  const pageSize = 20;
  while (true) {
    let entries;
    try {
      entries = fs3.readdirSync(state.currentDir, { withFileTypes: true });
    } catch {
      state.currentDir = path4.dirname(state.currentDir);
      continue;
    }
    entries = entries.filter((e) => state.showHidden || !e.name.startsWith("."));
    const dirs = entries.filter((e) => e.isDirectory()).sort((a, b) => a.name.localeCompare(b.name));
    const files = entries.filter((e) => {
      if (!e.isFile()) return false;
      if (extensions.length === 0) return true;
      const ext = path4.extname(e.name).slice(1).toLowerCase();
      return extensions.includes(ext);
    }).sort((a, b) => a.name.localeCompare(b.name));
    const items = [
      { name: "..", isDir: true, path: path4.dirname(state.currentDir) },
      ...dirs.map((d) => ({ name: d.name + "/", isDir: true, path: path4.join(state.currentDir, d.name) })),
      ...files.map((f) => ({ name: f.name, isDir: false, path: path4.join(state.currentDir, f.name) }))
    ];
    if (state.cursor >= items.length) state.cursor = items.length - 1;
    if (state.cursor < 0) state.cursor = 0;
    if (state.cursor < state.scrollOffset) state.scrollOffset = state.cursor;
    if (state.cursor >= state.scrollOffset + pageSize) state.scrollOffset = state.cursor - pageSize + 1;
    renderBrowser(state, items, extensions, multiple);
    setRawMode(true);
    const key = await readKey();
    setRawMode(false);
    if (key === "up") state.cursor = Math.max(0, state.cursor - 1);
    else if (key === "down") state.cursor = Math.min(items.length - 1, state.cursor + 1);
    else if (key === "enter" || key === "right") {
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
    } else if (key === "backspace" || key === "left") {
      state.currentDir = path4.dirname(state.currentDir);
      state.cursor = 0;
      state.scrollOffset = 0;
    } else if (key === "escape" || key === "quit") {
      return state.selected.length > 0 ? state.selected : null;
    } else if (key === "toggle-hidden") {
      state.showHidden = !state.showHidden;
    }
  }
}
__name(fileBrowser, "fileBrowser");
function renderBrowser(state, items, extensions, multiple) {
  const C = {
    accent: "\x1B[38;2;0;255;136m",
    ink: "\x1B[38;2;255;255;255m",
    muted: "\x1B[38;2;161;161;170m",
    dim: "\x1B[38;2;82;82;91m",
    blue: "\x1B[38;2;59;130;246m",
    cyan: "\x1B[38;2;34;211;238m",
    bgHover: "\x1B[48;2;0;255;136m\x1B[38;2;10;10;11m",
    reset: "\x1B[0m",
    bold: "\x1B[1m"
  };
  process.stdout.write("\x1B[2J\x1B[H");
  const shortDir = shortenPath(state.currentDir, 60);
  console.log(`${C.bold}  \u{1F94B} VideoSensei File Picker${C.reset}  ${C.muted}${multiple ? "(multi-select)" : ""}${C.reset}`);
  console.log("");
  console.log(`  ${C.muted}\u{1F4C1}${C.reset} ${C.accent}${shortDir}${C.reset}`);
  console.log(`  ${C.muted}Filter: ${C.reset}${C.cyan}${extensions.join(", ")}${C.reset}  ${C.muted}Hidden: ${C.reset}${state.showHidden ? C.accent + "on" : C.dim + "off"}${C.reset}${state.selected.length > 0 ? `  ${C.muted}Selected: ${C.reset}${C.accent}${state.selected.length}${C.reset}` : ""}`);
  console.log(`  ${C.dim}${"\u2500".repeat(76)}${C.reset}`);
  const pageSize = 20;
  const visible = items.slice(state.scrollOffset, state.scrollOffset + pageSize);
  visible.forEach((item, i) => {
    const idx = state.scrollOffset + i;
    const isSelected = idx === state.cursor;
    const inSelected = state.selected.includes(item.path);
    let icon;
    if (item.name === "..") icon = "\u21A9";
    else if (item.isDir) icon = "\u{1F4C1}";
    else icon = "\u{1F3AC}";
    let name = item.name;
    let nameColor = C.ink;
    if (item.name === "..") nameColor = C.muted;
    else if (item.isDir) nameColor = C.blue;
    if (name.length > 60) name = name.slice(0, 57) + "...";
    const checkmark = inSelected ? `${C.accent}\u2713${C.reset} ` : "  ";
    const pointer = isSelected ? `${C.accent}\u276F${C.reset} ` : "  ";
    if (isSelected) {
      console.log(`${pointer}${checkmark}${C.bgHover} ${icon} ${name} ${C.reset}`);
    } else {
      console.log(`${pointer}${checkmark}${nameColor} ${icon} ${name}${C.reset}`);
    }
  });
  for (let i = visible.length; i < pageSize; i++) console.log("");
  console.log(`  ${C.dim}${"\u2500".repeat(76)}${C.reset}`);
  console.log(`  ${C.muted}\u2191\u2193 navigate  ${C.reset}${C.muted}\u2192/Enter open  ${C.reset}${C.muted}\u2190/\u232B up dir  ${C.reset}${C.muted}h hidden  ${C.reset}${C.muted}q done${C.reset}`);
}
__name(renderBrowser, "renderBrowser");
async function pickFile(options = {}) {
  const opts = {
    startDir: process.cwd(),
    extensions: VIDEO_EXTENSIONS,
    multiple: false,
    preferExternal: true,
    ...options
  };
  if (opts.preferExternal) {
    const result = tryExternalPicker(opts.multiple ?? false, opts.extensions ?? VIDEO_EXTENSIONS);
    if (result && result.length > 0) return result;
  }
  const stdin = process.stdin;
  if (!stdin.isTTY) return null;
  return fileBrowser(opts);
}
__name(pickFile, "pickFile");
function isPickerAvailable() {
  const stdin = process.stdin;
  return !!(commandExists("termux-file-picker") || commandExists("zenity") || commandExists("kdialog") || commandExists("osascript") || commandExists("fzf") || process.platform === "win32" && commandExists("powershell") || stdin.isTTY);
}
__name(isPickerAvailable, "isPickerAvailable");

// src/main.ts
function prompt(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}
__name(prompt, "prompt");
function parseArgs(argv) {
  const args = {
    files: [],
    preset: null,
    outputDir: null,
    yes: true,
    // AUTO by default — no confirmation prompts
    smart: true,
    // AUTO by default — smart mode on
    pick: false,
    interactive: false,
    showHistory: false,
    clearHistory: false,
    showHelp: false,
    showVersion: false,
    custom: {}
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = argv[i + 1];
    if (arg === "-h" || arg === "--help") args.showHelp = true;
    else if (arg === "-v" || arg === "--version") args.showVersion = true;
    else if (arg === "--history") args.showHistory = true;
    else if (arg === "--clear-history") args.clearHistory = true;
    else if (arg === "-y" || arg === "--yes") args.yes = true;
    else if (arg === "--confirm") args.yes = false;
    else if (arg === "--smart") args.smart = true;
    else if (arg === "--no-smart") args.smart = false;
    else if (arg === "-i" || arg === "--interactive") args.interactive = true;
    else if (arg === "--pick" || arg === "-P") args.pick = true;
    else if (arg === "-p" || arg === "--preset") {
      args.preset = next || null;
      i++;
    } else if (arg === "-o" || arg === "--output") {
      args.outputDir = next || null;
      i++;
    } else if (arg === "--codec") {
      const c = (next || "").toLowerCase();
      args.custom.codec = c === "h264" ? "libx264" : c === "h265" ? "libx265" : c === "av1" ? "libsvtav1" : next;
      i++;
    } else if (arg === "--crf") {
      args.custom.crf = parseInt(next || "", 10);
      i++;
    } else if (arg === "--audio-bitrate") {
      args.custom.audioBitrate = next;
      i++;
    } else if (arg.startsWith("-")) {
    } else {
      args.files.push(arg);
    }
  }
  return args;
}
__name(parseArgs, "parseArgs");
async function pickFiles(multiple = false) {
  if (!isPickerAvailable()) {
    console.log(`${THEME.red}\u2717${THEME.reset}  File picker not available.`);
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
__name(pickFiles, "pickFiles");
async function compressOne(filePath, presetKey, options = {}) {
  let meta;
  try {
    meta = await probeVideo(filePath);
  } catch (e) {
    console.log(`  ${THEME.red}\u2717${THEME.reset}  ${e.message}`);
    return;
  }
  const preset = PRESETS[presetKey];
  const predictedSize = presetKey !== "custom" ? predictOutputSize(meta, presetKey) : null;
  const output = getOutputPath(filePath, presetKey, options.outputDir);
  console.log("");
  console.log(`  ${THEME.muted}Source:${THEME.reset}  ${path5.basename(filePath)}`);
  if (meta.video) {
    console.log(`           ${meta.video.width}x${meta.video.height} @ ${meta.video.fps.toFixed(1)}fps \xB7 ${meta.video.codec.toUpperCase()} \xB7 ${formatDuration(meta.duration)} \xB7 ${formatBytes(meta.size)}`);
  }
  console.log(`  ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset} ${THEME.muted}\u2014 ${preset.description}${THEME.reset}`);
  console.log(`  ${THEME.muted}Output:${THEME.reset}  ${path5.basename(output)}`);
  if (predictedSize) {
    const pct = Math.round(predictedSize.reduction * 100);
    console.log(`  ${THEME.muted}Predict:${THEME.reset} ~${formatBytes(predictedSize.bytes)} ${THEME.accent}(${pct}% smaller)${THEME.reset}`);
  }
  console.log("");
  if (options.yes === false) {
    const answer = await prompt(`  ${THEME.bold}Compress now?${THEME.reset} ${THEME.muted}[Y/n]${THEME.reset} `);
    if (answer && !answer.match(/^[Yy]/)) {
      console.log(`  ${THEME.muted}Skipped.${THEME.reset}`);
      return;
    }
    console.log("");
  }
  log(`START preset=${presetKey} input=${filePath} output=${output}`);
  const result = await compressWithFallback(
    filePath,
    presetKey,
    meta,
    {
      outputDir: options.outputDir ?? void 0,
      yes: options.yes,
      ...options.custom
    },
    {
      onProgress: /* @__PURE__ */ __name((p, elapsed, eta) => drawProgress(p.progress ?? 0, elapsed, eta), "onProgress"),
      onFallback: /* @__PURE__ */ __name((reason) => console.log(`  ${THEME.yellow}\u26A0${THEME.reset}  ${reason}${THEME.reset}`), "onFallback")
    }
  );
  process.stdout.write("\r" + " ".repeat(80) + "\r");
  if (result.success) {
    const pct = result.reduction.toFixed(1);
    console.log(`  ${THEME.accent}\u2713${THEME.reset}  ${THEME.bold}Done${THEME.reset} in ${formatDuration(result.duration)}`);
    console.log(`     ${THEME.muted}Output:${THEME.reset}  ${path5.basename(result.output)}`);
    console.log(`     ${THEME.muted}Size:${THEME.reset}    ${formatBytes(meta.size)} \u2192 ${THEME.accent}${THEME.bold}${formatBytes(result.outputSize)}${THEME.reset}  ${THEME.accent}(${pct}% \u2193)${THEME.reset}`);
    console.log(`     ${THEME.muted}Preset:${THEME.reset}  ${preset.color}${preset.icon} ${preset.name}${THEME.reset}`);
    console.log("");
    const entry = {
      timestamp: Date.now(),
      input: filePath,
      output: result.output,
      preset: preset.name,
      inputSize: meta.size,
      outputSize: result.outputSize,
      reduction: result.reduction,
      duration: result.duration,
      success: true
    };
    addToHistory(entry);
    log(`SUCCESS preset=${presetKey} input=${filePath} output=${result.output} reduction=${pct}%`);
  } else if ("skipped" in result && result.skipped) {
    console.log(`  ${THEME.yellow}\u26A0${THEME.reset}  Skipped: ${result.reason}`);
    console.log(`     ${THEME.muted}Source already optimal \u2014 no compression needed.${THEME.reset}`);
    console.log("");
    log(`SKIPPED input=${filePath} reason=${result.reason}`);
  } else {
    console.log(`  ${THEME.red}\u2717${THEME.reset}  Compression failed.`);
    if ("error" in result) {
      console.log(`     ${THEME.muted}${result.error}${THEME.reset}`);
    }
    console.log(`     ${THEME.muted}Debug log: ${HISTORY_PATH.replace("history.json", "videosensi.log")}${THEME.reset}`);
    console.log("");
    log(`FAILED input=${filePath} error=${"error" in result ? result.error : "unknown"}`);
  }
}
__name(compressOne, "compressOne");
async function autoMode(args) {
  printLogo(true);
  let files = args.files;
  if (files.length === 0) {
    const picked = await pickFiles(false);
    if (!picked || picked.length === 0) {
      console.log(`  ${THEME.muted}No file selected. Bye!${THEME.reset}`);
      return;
    }
    files = picked;
  }
  files = files.map((p) => p.replace(/^['"]|['"]$/g, "").replace(/^~(?=\/|$)/, os3.homedir()));
  for (const p of files) {
    if (!fs4.existsSync(p)) {
      console.log(`  ${THEME.red}\u2717${THEME.reset}  File not found: ${p}`);
      return;
    }
  }
  let presetKey = args.preset;
  if (!presetKey) {
    if (args.smart && files.length === 1) {
      const meta = await probeVideo(files[0]);
      const recommended = recommendPreset(meta);
      if (recommended === null) {
        console.log(`  ${THEME.yellow}\u26A0${THEME.reset}  Source is already AV1 \u2014 re-encoding won't help.`);
        console.log(`  ${THEME.muted}Force a preset with -p if you really want to re-encode.${THEME.reset}`);
        return;
      }
      presetKey = recommended;
      const p = PRESETS[presetKey];
      console.log(`  ${THEME.accent}\u{1F94B}${THEME.reset}  ${THEME.bold}Sensei auto-picked:${THEME.reset} ${p.color}${p.icon} ${p.name}${THEME.reset} ${THEME.muted}\u2014 ${p.useCase}${THEME.reset}`);
    } else {
      presetKey = "balanced";
    }
  }
  if (!PRESET_KEYS.includes(presetKey)) {
    console.log(`  ${THEME.red}\u2717${THEME.reset}  Unknown preset: ${presetKey}`);
    console.log(`   ${THEME.muted}Available:${THEME.reset} ${PRESET_KEYS.join(", ")}`);
    return;
  }
  if (args.outputDir && !fs4.existsSync(args.outputDir)) {
    fs4.mkdirSync(args.outputDir, { recursive: true });
  }
  for (let i = 0; i < files.length; i++) {
    if (files.length > 1) {
      console.log(`${THEME.bold}  [${i + 1}/${files.length}]${THEME.reset} ${path5.basename(files[i])}`);
    }
    await compressOne(files[i], presetKey, {
      outputDir: args.outputDir,
      yes: args.yes,
      custom: args.custom
    });
  }
  console.log(`  ${THEME.muted}Hack the size. Keep the clarity. \u{1F94B}${THEME.reset}`);
  console.log(`  ${THEME.muted}https://jubairsensei.com${THEME.reset}`);
}
__name(autoMode, "autoMode");
async function interactiveMode(args) {
  clear();
  printLogo();
  console.log(`  ${THEME.muted}Welcome, Sensei. \u{1F94B}${THEME.reset}`);
  console.log(`  ${THEME.muted}Master your video. Sensei-grade clarity.${THEME.reset}`);
  console.log("");
  console.log(`  ${THEME.bold}WHAT WOULD YOU LIKE TO DO?${THEME.reset}`);
  console.log("");
  console.log(`  ${THEME.accent}1.${THEME.reset} \u{1F3AC} Pick a video and compress  ${THEME.muted}(file picker)${THEME.reset}`);
  console.log(`  ${THEME.accent}2.${THEME.reset} \u{1F4C2} Type path manually         ${THEME.muted}(paste path)${THEME.reset}`);
  console.log(`  ${THEME.accent}3.${THEME.reset} \u{1F4E6} Batch compress              ${THEME.muted}(multiple files)${THEME.reset}`);
  console.log(`  ${THEME.accent}4.${THEME.reset} \u{1F4DC} View history                ${THEME.muted}(past compressions)${THEME.reset}`);
  console.log(`  ${THEME.accent}5.${THEME.reset} \u2753 Help                         ${THEME.muted}(show all options)${THEME.reset}`);
  console.log(`  ${THEME.accent}q.${THEME.reset} Quit`);
  console.log("");
  const mainChoice = await prompt(`  ${THEME.bold}Your choice${THEME.reset} ${THEME.muted}[1]${THEME.reset}: `);
  if (mainChoice === "q" || mainChoice === "Q") {
    console.log(`  ${THEME.muted}Bye! Hack the size. Keep the clarity. \u{1F94B}${THEME.reset}`);
    return;
  }
  if (mainChoice === "4") {
    printHistory(loadHistory());
    return;
  }
  if (mainChoice === "5") {
    printHelp();
    return;
  }
  let filePaths = [];
  if (mainChoice === "3") {
    const selected = await pickFiles(true);
    if (!selected || selected.length === 0) {
      console.log(`  ${THEME.yellow}No files selected. Bye!${THEME.reset}`);
      return;
    }
    filePaths = selected;
  } else if (mainChoice === "2") {
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
  filePaths = filePaths.map((p) => p.replace(/^['"]|['"]$/g, "").replace(/^~(?=\/|$)/, os3.homedir()));
  for (const p of filePaths) {
    if (!fs4.existsSync(p)) {
      console.log(`  ${THEME.red}\u2717${THEME.reset}  File not found: ${p}`);
      return;
    }
  }
  let firstMeta = null;
  if (filePaths.length === 1) {
    try {
      firstMeta = await probeVideo(filePaths[0]);
    } catch {
    }
  }
  console.log("");
  console.log(`  ${THEME.bold}CHOOSE YOUR PRESET${THEME.reset}`);
  console.log("");
  PRESET_KEYS.forEach((key, i) => {
    const p = PRESETS[key];
    const num = `${THEME.muted}${i + 1}.${THEME.reset}`;
    let line = `  ${num} ${p.color}${p.icon} ${p.name.padEnd(10)}${THEME.reset}  ${p.description}`;
    if (firstMeta && key !== "custom") {
      const prediction = predictOutputSize(firstMeta, key);
      if (prediction) {
        const pct = Math.round(prediction.reduction * 100);
        line += ` ${THEME.muted}\u2192 ~${formatBytes(prediction.bytes)} (${pct}% \u2193)${THEME.reset}`;
      }
    }
    console.log(line);
  });
  console.log("");
  const recommended = firstMeta ? recommendPreset(firstMeta) : "balanced";
  const defaultChoice = recommended === null ? 2 : PRESET_KEYS.indexOf(recommended) + 1;
  const choice = await prompt(`  ${THEME.bold}Pick preset${THEME.reset} ${THEME.muted}[1-5, default: ${defaultChoice}]${THEME.reset}: `);
  let presetIdx;
  if (!choice) presetIdx = defaultChoice - 1;
  else {
    presetIdx = parseInt(choice, 10) - 1;
    if (isNaN(presetIdx) || presetIdx < 0 || presetIdx >= PRESET_KEYS.length) {
      console.log(`  ${THEME.red}\u2717${THEME.reset}  Invalid choice`);
      return;
    }
  }
  const presetKey = PRESET_KEYS[presetIdx];
  const customOpts = {};
  if (presetKey === "custom") {
    console.log("");
    const codecChoice = await prompt(`  ${THEME.bold}Codec${THEME.reset} ${THEME.muted}[1=h264, 2=h265, 3=av1, default 2]${THEME.reset}: `);
    const codecMap = { "1": "libx264", "2": "libx265", "3": "libsvtav1" };
    customOpts.codec = codecMap[codecChoice || "2"] || "libx265";
    const crfChoice = await prompt(`  ${THEME.bold}CRF${THEME.reset} ${THEME.muted}[0-51, lower=better, default 26]${THEME.reset}: `);
    customOpts.crf = parseInt(crfChoice, 10) || 26;
    const audioChoice = await prompt(`  ${THEME.bold}Audio bitrate${THEME.reset} ${THEME.muted}[64/96/128/192/256, default 128]${THEME.reset}: `);
    customOpts.audioBitrate = `${audioChoice || "128"}k`;
  }
  console.log("");
  for (let i = 0; i < filePaths.length; i++) {
    if (filePaths.length > 1) {
      console.log(`${THEME.bold}  [${i + 1}/${filePaths.length}]${THEME.reset} ${path5.basename(filePaths[i])}`);
    }
    await compressOne(filePaths[i], presetKey, {
      outputDir: args.outputDir,
      yes: filePaths.length > 1,
      custom: customOpts
    });
  }
  console.log(`  ${THEME.muted}Hack the size. Keep the clarity. \u{1F94B}${THEME.reset}`);
  console.log(`  ${THEME.muted}https://jubairsensei.com${THEME.reset}`);
}
__name(interactiveMode, "interactiveMode");
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
    clearHistory();
    console.log(`${THEME.accent}\u2713${THEME.reset}  History cleared.`);
    return;
  }
  if (args.showHistory) {
    printHistory(loadHistory());
    return;
  }
  if (!checkFFmpeg()) {
    console.log(`${THEME.red}\u2717${THEME.reset}  FFmpeg not found. Install it first:`);
    console.log(`   ${THEME.muted}Ubuntu/Debian:${THEME.reset}  sudo apt install ffmpeg`);
    console.log(`   ${THEME.muted}macOS:${THEME.reset}         brew install ffmpeg`);
    console.log(`   ${THEME.muted}Termux:${THEME.reset}        pkg install ffmpeg`);
    console.log(`   ${THEME.muted}Windows:${THEME.reset}       choco install ffmpeg`);
    process.exit(1);
  }
  if (!checkFFprobe()) {
    console.log(`${THEME.red}\u2717${THEME.reset}  FFprobe not found (usually ships with FFmpeg).`);
    process.exit(1);
  }
  if (args.pick && args.files.length === 0) {
    const picked = await pickFiles(false);
    if (!picked || picked.length === 0) {
      console.log(`  ${THEME.muted}No file selected. Bye!${THEME.reset}`);
      return;
    }
    args.files = picked;
  }
  if (args.interactive) {
    await interactiveMode(args);
    return;
  }
  await autoMode(args);
}
__name(main, "main");
main().catch((e) => {
  console.error(`${THEME.red}\u2717${THEME.reset}  Fatal: ${e.message}`);
  process.exit(1);
});
