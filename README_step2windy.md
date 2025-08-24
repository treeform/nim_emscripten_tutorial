# Step2Windy - Windy Library with Emscripten

This demonstrates using the Windy windowing library with Emscripten to create web-based OpenGL applications.

## What was done

1. **Fixed the typo in step2windy.nim**: Changed `main_loop` to `mainLoop` for consistency
2. **Implemented Emscripten platform support in Windy**: Created a working implementation in `windy/src/windy/platforms/emscripten/platform.nim`
3. **Created build configuration**: Added `step2windy.nims` with proper Emscripten settings
4. **Successfully compiled**: The project now compiles to WebAssembly

## Building

To build the project:

```bash
nim c -d:emscripten step2windy.nim
```

This generates:
- `step2windy.html` - The HTML page
- `step2windy.js` - JavaScript glue code
- `step2windy.wasm` - WebAssembly module

## Running

To run the application, you need a web server:

```bash
# Install nimhttpd if not already installed
nimble install nimhttpd

# Start the web server
nimhttpd -p:8000
```

Then open http://localhost:8000/step2windy.html in your browser.

## Features

The application:
- Creates a window using Windy
- Sets up an OpenGL/WebGL context
- Displays a red screen with animated color fading
- Uses Emscripten's main loop for browser compatibility

## Key Changes Made

### Windy Platform Implementation
- Added WebGL context creation using Emscripten's HTML5 API
- Implemented all required Window procedures for API compatibility
- Used proper Emscripten headers to avoid conflicts

### Build Configuration
- Configured for WebGL 2.0 with fallback to 1.0
- Enabled full ES3 support
- Allowed memory growth for flexibility
