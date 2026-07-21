// VideoSensei — Shared types
// All TypeScript interfaces live here for single-source-of-truth.

export type PresetKey = 'lite' | 'balanced' | 'crystal' | 'sensei' | 'custom';

export interface VideoStream {
  codec: string;
  width: number;
  height: number;
  fps: number;
  bitrate: number;
}

export interface AudioStream {
  codec: string;
  channels: number;
  sampleRate: number;
  bitrate: number;
}

export interface VideoMetadata {
  path: string;
  duration: number;
  size: number;
  bitrate: number;
  container: string;
  video: VideoStream | null;
  audio: AudioStream | null;
}

export interface CompressionPreset {
  readonly name: string;
  readonly icon: string;
  readonly color: string;
  readonly codec: string;
  readonly crf: number;
  readonly preset: string;
  readonly audioCodec: string;
  readonly audioBitrate: string;
  readonly container: string;
  readonly extraArgs: readonly string[];
  readonly description: string;
  readonly useCase: string;
}

export interface CompressionProgress {
  frame?: number;
  time?: number;
  progress?: number;
  speed?: number;
  bitrate?: number;
  size?: number;
}

export interface CompressionResult {
  timestamp: number;
  input: string;
  output: string | null;
  preset: string;
  inputSize: number;
  outputSize: number;
  reduction: number;
  duration: number;
  success: boolean;
  skipped?: boolean;
}

export interface CustomOptions {
  codec?: string;
  crf?: number;
  audioBitrate?: string;
  audioCodec?: string;
  preset?: string; // encoder preset (e.g. 'medium', 'slow')
}

export interface CompressOptions extends CustomOptions {
  outputDir?: string;
  yes?: boolean;
  interactive?: boolean;
}

export interface SizePrediction {
  bytes: number;
  reduction: number;
}

export interface ParsedArgs {
  files: string[];
  preset: PresetKey | null;
  outputDir: string | null;
  yes: boolean;
  smart: boolean;
  pick: boolean;
  interactive: boolean;
  showHistory: boolean;
  clearHistory: boolean;
  showHelp: boolean;
  showVersion: boolean;
  custom: CustomOptions;
}
