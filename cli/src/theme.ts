// VideoSensei — Theme tokens
// Extracted from jubairsensei.com (see THEME.md)

export const THEME = {
  // Backgrounds
  bg: '\x1b[48;2;10;10;11m',          // #0A0A0B
  bgElevated: '\x1b[48;2;17;17;20m',  // #111114
  // Foregrounds
  accent: '\x1b[38;2;0;255;136m',     // #00FF88 neon green (signature)
  accentDim: '\x1b[38;2;0;204;106m',  // #00CC6A
  ink: '\x1b[38;2;255;255;255m',      // #FFFFFF
  inkSecondary: '\x1b[38;2;161;161;170m', // #A1A1AA
  inkMuted: '\x1b[38;2;82;82;91m',    // #52525B
  muted: '\x1b[38;2;82;82;91m',       // alias
  secondary: '\x1b[38;2;161;161;170m',// alias
  // Decorative (preset badges)
  cyan: '\x1b[38;2;34;211;238m',      // Balanced
  blue: '\x1b[38;2;59;130;246m',      // Crystal
  purple: '\x1b[38;2;199;125;255m',   // Custom
  orange: '\x1b[38;2;251;146;60m',    // Lite
  yellow: '\x1b[38;2;250;204;21m',    // warning
  red: '\x1b[38;2;248;113;113m',      // error
  lime: '\x1b[38;2;212;255;0m',       // code
  // Styles
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  italic: '\x1b[3m',
  underline: '\x1b[4m',
  bgHover: '\x1b[48;2;0;255;136m\x1b[38;2;10;10;11m',
} as const;

// Style helper functions
export const glow = (text: string): string =>
  `\x1b[38;2;0;255;136m\x1b[1m${text}\x1b[0m`;

export const success = (text: string): string =>
  `\x1b[38;2;0;255;136m${text}\x1b[0m`;

export const warn = (text: string): string =>
  `\x1b[38;2;250;204;21m${text}\x1b[0m`;

export const err = (text: string): string =>
  `\x1b[38;2;248;113;113m${text}\x1b[0m`;
