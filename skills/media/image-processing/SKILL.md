---
name: image-processing
title: Image Processing
description: Process and manipulate images when PIL/Pillow is unavailable — using Node.js sharp for pixel-level transformations, color shifting, and image generation.
---

## When to Use

- The user asks you to edit/modify/generate an image
- You need to apply pixel-level transformations (color shift, filter, blend)
- You cannot install PIL/Pillow due to venv restrictions or pip timeout
- The system has Node.js available (check with `node --version`)

## Setup

```bash
cd /tmp && npm install sharp
```

sharp is fast, does not require system dependencies, and handles RGBA correctly.

## Approach

### 1. Read the source image with sharp

```javascript
const sharp = require('sharp');
const img = sharp('/path/to/image.jpg');
const meta = await img.metadata();
const { data, info } = await img.ensureAlpha().raw().toBuffer({ resolveWithObject: true });
```

Always call `.ensureAlpha()` before `.raw()` to get consistent 4-channel RGBA output.

### 2. Manipulate pixels

```javascript
const pixels = new Uint8Array(data);
for (let y = 0; y < info.height; y++) {
  for (let x = 0; x < info.width; x++) {
    const i = (y * info.width + x) * 4;
    const r = pixels[i], g = pixels[i+1], b = pixels[i+2], a = pixels[i+3];
    // ... your pixel logic here ...
    pixels[i] = newR; pixels[i+1] = newG; pixels[i+2] = newB;
  }
}
```

### 3. Save output

```javascript
const out = sharp(pixels, { raw: { width: info.width, height: info.height, channels: 4 } });
await out.png().toFile('/path/to/output.png');
```

PNG is preferred for transparency support.

## Common Recipes

### Color shifting (e.g., make a piggy green)

```javascript
if (pa > 200) {  // non-transparent pixels
  const avg = (r + g + b) / 3.0;
  pixels[i]   = Math.min(255, Math.round(avg * 0.4 + 20));   // R
  pixels[i+1] = Math.min(255, Math.round(avg * 0.8 + 40));   // G
  pixels[i+2] = Math.min(255, Math.round(avg * 0.2 + 10));   // B
}
```

### Background removal

Detect background by color range, then set alpha to 0:
```javascript
const isBg = (r > thresholdR && g > thresholdG && b < thresholdB);
if (isBg) { pixels[i+3] = 0; }
```

## Pitfalls

- **Raw buffer size**: `width * height * 4` bytes. sharp's `.raw()` without `.ensureAlpha()` on JPEG (3 channels) gives `width * height * 3` bytes. Always use `.ensureAlpha()` for consistent 4-channel output.
- **pip install Pillow may hang** if the system has virtualenv restrictions (`--break-system-packages` needed) or network issues. Use sharp instead.
- **Output to `~/.hermes/image_cache/`** for gateway access, or share via `send_message` with `MEDIA:path` in the message.
- **WeCom cannot send proactive images** without WECOM_HOME_CHANNEL configured. Save to image_cache and inform user, or fall back to describing the result.
