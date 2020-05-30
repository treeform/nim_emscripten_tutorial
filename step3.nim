import math, opengl, staticglfw

proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}

# Init GLFW
if init() == 0:
  raise newException(Exception, "Failed to Initialize GLFW")

# Open window.
var window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
# Connect the GL context.
window.makeContextCurrent()

when not defined(emscripten):
  # This must be called to make any GL function work
  loadExtensions()

var colorFade = 1.0

proc onResize(handle: staticglfw.Window, w, h: int32) {.cdecl.} =
  echo "resize: ", w, "x", h
discard window.setFramebufferSizeCallback(onResize)

proc mainLoop() {.cdecl.} =

  # Draw red color screen.
  glClearColor(sin(colorFade)/2 + 0.5, 0, 0, 1)
  colorFade += 0.01
  glClear(GL_COLOR_BUFFER_BIT)

  # Swap buffers (this will display the red color)
  window.swapBuffers()

  # Check for events.
  pollEvents()
  # If you get ESC key quit.
  if window.getKey(KEY_ESCAPE) == 1:
    window.setWindowShouldClose(1)

when defined(emscripten):
  # Emscripten can't block so it will call this callback instead.
  emscripten_set_main_loop(main_loop, 0, true);
else:
  # When running native code we can block in an infinite loop.
  while windowShouldClose(window) == 0:
    mainLoop()
