// VideoSensei — Compression presets
// See COMPRESSION.md for the strategy

import type { CompressionPreset, PresetKey } from './types.js';

export const PRESETS: Record<PresetKey, CompressionPreset> = {
  lite: {
    name: 'Lite',
    icon: '🪶',
    color: '\x1b[38;2;251;146;60m', // orange
    codec: 'libx264',
    crf: 30,
    preset: 'veryfast',
    audioCodec: 'aac',
    audioBitrate: '128k',
    container: 'mp4',
    extraArgs: ['-pix_fmt', 'yuv420p', '-movflags', '+faststart'],
    description: 'Quick share, max compat (H.264, CRF 30)',
    useCase: 'WhatsApp/Telegram share, email attachments',
  },
  balanced: {
    name: 'Balanced',
    icon: '⚖️',
    color: '\x1b[38;2;34;211;238m', // cyan
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
    color: '\x1b[38;2;59;130;246m', // blue
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
    color: '\x1b[38;2;0;255;136m', // accent green
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
    color: '\x1b[38;2;199;125;255m', // purple
    codec: '',
    crf: 0,
    preset: '',
    audioCodec: '',
    audioBitrate: '',
    container: 'mp4',
    extraArgs: [],
    description: 'Full manual control',
    useCase: 'Power users',
  },
};

export const PRESET_KEYS: PresetKey[] = ['lite', 'balanced', 'crystal', 'sensei', 'custom'];

// Codec efficiency factors for size prediction
export const CODEC_FACTORS: Record<string, number> = {
  libx264: 0.6,    // 40% reduction
  libx265: 0.5,    // 50% reduction
  libsvtav1: 0.35, // 65% reduction
};
