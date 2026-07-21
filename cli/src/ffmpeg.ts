// VideoSensei — FFmpeg execution + progress parsing

import { spawn } from 'node:child_process';
import path from 'node:path';
import fs from 'node:fs';
import type {
  CompressionPreset,
  CompressionProgress,
  CompressOptions,
  CustomOptions,
  PresetKey,
  VideoMetadata,
} from './types.js';
import { PRESETS } from './presets.js';
import { THEME } from './theme.js';

export function getOutputPath(
  inputPath: string,
  presetKey: PresetKey,
  outputDir?: string | null
): string {
  const ext = PRESETS[presetKey].container || 'mp4';
  const parsed = path.parse(inputPath);
  const outName = `${parsed.name}_sensei.${ext}`;
  if (!outputDir || outputDir === 'same') {
    return path.join(parsed.dir, outName);
  }
  return path.join(outputDir, outName);
}

export function buildFFmpegArgs(
  input: string,
  output: string,
  presetKey: PresetKey,
  customOpts: CustomOptions = {}
): string[] {
  const preset = PRESETS[presetKey];
  const args = ['-i', input, '-y'];

  if (presetKey === 'custom') {
    const codec = customOpts.codec || 'libx265';
    const crf = customOpts.crf ?? 26;
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
    '-metadata', 'comment=https://jubairsensei.com',
    output
  );
  return args;
}

export function parseProgress(stderrLine: string, totalDuration: number): CompressionProgress {
  const out: CompressionProgress = {};
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

export function drawProgress(progress: number, elapsedSec: number, etaSec: number): void {
  const width = 30;
  const filled = Math.round((progress / 100) * width);
  const empty = width - filled;
  const bar = `${THEME.accent}${'━'.repeat(filled)}${THEME.muted}${'━'.repeat(empty)}${THEME.reset}`;
  const pct = `${progress.toFixed(0).padStart(3)}%`;
  const elapsed = formatDuration(elapsedSec);
  const eta = etaSec > 0 ? formatDuration(etaSec) : '--';
  process.stdout.write(`\r  ${bar} ${THEME.accent}${THEME.bold}${pct}${THEME.reset} ${THEME.muted}elapsed:${THEME.reset} ${elapsed.padStart(7)} ${THEME.muted}eta:${THEME.reset} ${eta.padStart(7)}   `);
}

export function formatDuration(seconds: number): string {
  if (seconds < 60) return `${seconds.toFixed(1)}s`;
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}m ${s}s`;
}

export function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`;
}

export interface CompressCallbacks {
  onProgress?: (progress: CompressionProgress, elapsed: number, eta: number) => void;
  onFallback?: (reason: string) => void;
}

export interface CompressSuccess {
  success: true;
  output: string;
  outputSize: number;
  reduction: number;
  duration: number;
}

export interface CompressSkipped {
  success: false;
  skipped: true;
  reason: string;
  duration: number;
}

export interface CompressFailed {
  success: false;
  error: string;
}

export type CompressOutcome = CompressSuccess | CompressSkipped | CompressFailed;

export async function runFFmpeg(
  input: string,
  output: string,
  presetKey: PresetKey,
  meta: VideoMetadata,
  options: CompressOptions = {},
  callbacks?: CompressCallbacks
): Promise<CompressOutcome> {
  const args = buildFFmpegArgs(input, output, presetKey, options);
  const startTime = Date.now();
  let lastProgressUpdate = 0;
  let lastError = '';

  return new Promise((resolve) => {
    const proc = spawn('ffmpeg', args, { stdio: ['pipe', 'pipe', 'pipe'] });
    let stderrBuf = '';

    proc.stderr.on('data', (data) => {
      stderrBuf += data.toString();
      const lines = stderrBuf.split('\n');
      stderrBuf = lines.pop() || '';

      for (const line of lines) {
        if (line.includes('error') || line.includes('Error')) {
          lastError = line;
        }
        const p = parseProgress(line, meta.duration);
        if (p.progress !== undefined && callbacks?.onProgress) {
          const now = Date.now();
          if (now - lastProgressUpdate > 200) {
            const elapsed = (now - startTime) / 1000;
            const eta = p.progress > 0 ? (elapsed / p.progress) * (100 - p.progress) : 0;
            callbacks.onProgress(p, elapsed, eta);
            lastProgressUpdate = now;
          }
        }
      }
    });

    proc.on('close', (code) => {
      const elapsed = (Date.now() - startTime) / 1000;

      if (code !== 0) {
        resolve({ success: false, error: `FFmpeg exited with code ${code}: ${lastError}` });
        return;
      }

      // Success — check output
      if (!fs.existsSync(output)) {
        resolve({ success: false, error: 'FFmpeg exited cleanly but output file missing' });
        return;
      }

      const outStats = fs.statSync(output);
      const reduction = meta.size > 0 ? (1 - outStats.size / meta.size) * 100 : 0;

      // If output is larger than source, mark as skipped (auto-delete)
      if (meta.size > 0 && outStats.size >= meta.size) {
        fs.unlinkSync(output);
        resolve({
          success: false,
          skipped: true,
          reason: `Output (${formatBytes(outStats.size)}) was larger than source (${formatBytes(meta.size)}). Source already optimal.`,
          duration: elapsed,
        });
        return;
      }

      resolve({
        success: true,
        output,
        outputSize: outStats.size,
        reduction,
        duration: elapsed,
      });
    });

    proc.on('error', (e) => {
      resolve({ success: false, error: `Failed to spawn ffmpeg: ${e.message}` });
    });

    process.on('SIGINT', () => {
      proc.kill('SIGINT');
      process.exit(130);
    });
  });
}

export async function compressWithFallback(
  input: string,
  presetKey: PresetKey,
  meta: VideoMetadata,
  options: CompressOptions = {},
  callbacks?: CompressCallbacks
): Promise<CompressOutcome> {
  const output = getOutputPath(input, presetKey, options.outputDir);
  const result = await runFFmpeg(input, output, presetKey, meta, options, callbacks);

  // If failed and preset was not H.264, try Lite as fallback
  if (!result.success && !('skipped' in result) && presetKey !== 'lite') {
    const preset = PRESETS[presetKey];
    callbacks?.onFallback?.(`${preset.name} failed, falling back to H.264 Lite`);
    const fallbackOutput = getOutputPath(input, 'lite', options.outputDir);
    return runFFmpeg(input, fallbackOutput, 'lite', meta, options, callbacks);
  }

  return result;
}
