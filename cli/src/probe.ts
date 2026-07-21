// VideoSensei — ffprobe wrapper
// Probes video files for metadata.

import { spawn } from 'node:child_process';
import { execSync } from 'node:child_process';
import type { VideoMetadata } from './types.js';

export function checkFFmpeg(): boolean {
  try {
    execSync('ffmpeg -version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

export function checkFFprobe(): boolean {
  try {
    execSync('ffprobe -version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function evalFps(rateStr: string | undefined): number {
  if (!rateStr || rateStr === '0/0') return 0;
  const [num, den] = rateStr.split('/').map(Number);
  return den ? num / den : 0;
}

interface FFprobeOutput {
  format?: {
    duration?: string;
    size?: string;
    bit_rate?: string;
    format_name?: string;
  };
  streams?: Array<{
    codec_type: string;
    codec_name?: string;
    width?: number;
    height?: number;
    r_frame_rate?: string;
    bit_rate?: string;
    channels?: number;
    sample_rate?: string;
  }>;
}

export function probeVideo(filePath: string): Promise<VideoMetadata> {
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
    proc.stdout.on('data', (d) => { stdout += d; });
    proc.stderr.on('data', (d) => { stderr += d; });
    proc.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`ffprobe failed: ${stderr || 'unknown error'}`));
        return;
      }
      try {
        const data: FFprobeOutput = JSON.parse(stdout);
        const format = data.format || {};
        const videoStream = (data.streams || []).find((s) => s.codec_type === 'video');
        const audioStream = (data.streams || []).find((s) => s.codec_type === 'audio');
        resolve({
          path: filePath,
          duration: parseFloat(format.duration || '0'),
          size: parseInt(format.size || '0', 10),
          bitrate: parseInt(format.bit_rate || '0', 10),
          container: (format.format_name || '').split(',')[0],
          video: videoStream ? {
            codec: videoStream.codec_name || '',
            width: videoStream.width || 0,
            height: videoStream.height || 0,
            fps: evalFps(videoStream.r_frame_rate),
            bitrate: parseInt(videoStream.bit_rate || '0', 10),
          } : null,
          audio: audioStream ? {
            codec: audioStream.codec_name || '',
            channels: audioStream.channels || 0,
            sampleRate: parseInt(audioStream.sample_rate || '0', 10),
            bitrate: parseInt(audioStream.bit_rate || '0', 10),
          } : null,
        });
      } catch (e) {
        reject(new Error(`Failed to parse ffprobe output: ${(e as Error).message}`));
      }
    });
    proc.on('error', (e) => reject(new Error(`Failed to spawn ffprobe: ${e.message}`)));
  });
}
