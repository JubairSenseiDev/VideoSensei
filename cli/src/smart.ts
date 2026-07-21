// VideoSensei — Smart mode + size prediction

import type { PresetKey, SizePrediction, VideoMetadata } from './types.js';
import { CODEC_FACTORS } from './presets.js';

/**
 * Smart mode: recommend a preset based on source video properties.
 * Only returns null if source is AV1 (already optimal codec).
 * For small/low-bitrate files we still recommend a preset — user
 * explicitly invoked videosensei, so they want compression.
 */
export function recommendPreset(meta: VideoMetadata | null): PresetKey | null {
  if (!meta || !meta.video) return 'balanced';

  const bitrate = meta.bitrate || 0;
  const duration = meta.duration || 0;
  const resolution = meta.video.height || 0;
  const codec = meta.video.codec || '';

  // Already AV1 → don't re-encode (truly optimal codec)
  if (codec === 'av1') return null;

  // Short clip → Lite (quick share)
  if (duration > 0 && duration < 30) return 'lite';

  // 4K → Balanced (downscale optional)
  if (resolution >= 2160) return 'balanced';

  // Very high bitrate, likely high motion → Crystal (preserve detail)
  if (bitrate > 5_000_000) return 'crystal';

  // Very low bitrate → Lite (don't waste time on heavy encode)
  if (bitrate > 0 && bitrate < 500_000) return 'lite';

  // Default → Balanced
  return 'balanced';
}

/**
 * Predict output size (rough estimate).
 * Returns null if prediction isn't possible.
 */
export function predictOutputSize(
  meta: VideoMetadata | null,
  presetKey: PresetKey
): SizePrediction | null {
  if (!meta || !meta.video) return null;

  const sourceBitrate = meta.bitrate || 0;
  if (!sourceBitrate) return null;

  // Codec factors map (imported from presets)
  const codecFactor = CODEC_FACTORS[PRESET_CODEC[presetKey]] ?? 0.5;

  // CRF factor — lower CRF = higher bitrate (rough heuristic)
  const crf = PRESET_CRF[presetKey];
  if (crf === undefined) return null;
  const crfFactor = (crf - 18) / 14 + 0.7; // CRF 18 → 0.7, CRF 32 → 1.4

  const targetBitrate = sourceBitrate * codecFactor * crfFactor;
  const predictedSize = (targetBitrate * meta.duration) / 8;

  return {
    bytes: Math.round(predictedSize),
    reduction: meta.size > 0 ? (1 - predictedSize / meta.size) : 0,
  };
}

// Local lookup maps to avoid importing PRESETS (would cause circular dep)
const PRESET_CODEC: Record<PresetKey, string> = {
  lite: 'libx264',
  balanced: 'libx265',
  crystal: 'libx265',
  sensei: 'libsvtav1',
  custom: '',
};

const PRESET_CRF: Partial<Record<PresetKey, number>> = {
  lite: 30,
  balanced: 26,
  crystal: 22,
  sensei: 32,
};
