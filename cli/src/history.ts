// VideoSensei — History management

import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import type { CompressionResult } from './types.js';

const SENSEI_DIR = path.join(os.homedir(), '.videosensei');
const HISTORY_FILE = path.join(SENSEI_DIR, 'history.json');
const LOG_FILE = path.join(SENSEI_DIR, 'videosensi.log');

export function ensureDirs(): void {
  if (!fs.existsSync(SENSEI_DIR)) {
    fs.mkdirSync(SENSEI_DIR, { recursive: true });
  }
}

export function log(message: string): void {
  ensureDirs();
  const ts = new Date().toISOString();
  try {
    fs.appendFileSync(LOG_FILE, `[${ts}] ${message}\n`);
  } catch {
    // ignore log failures
  }
}

export function loadHistory(): CompressionResult[] {
  ensureDirs();
  if (!fs.existsSync(HISTORY_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(HISTORY_FILE, 'utf8'));
  } catch {
    return [];
  }
}

export function saveHistory(history: CompressionResult[]): void {
  ensureDirs();
  fs.writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2));
}

export function addToHistory(entry: CompressionResult): void {
  const history = loadHistory();
  history.unshift(entry);
  if (history.length > 100) history.length = 100;
  saveHistory(history);
}

export function clearHistory(): void {
  saveHistory([]);
}

export function formatTime(timestamp: number): string {
  const d = new Date(timestamp);
  const now = Date.now();
  const diff = now - timestamp;
  if (diff < 60000) return 'just now';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}d ago`;
  return d.toLocaleDateString();
}

export const HISTORY_PATH = HISTORY_FILE;
export const LOG_PATH = LOG_FILE;
export const SENSEI_DIR_PATH = SENSEI_DIR;
