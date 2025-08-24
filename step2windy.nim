import math, opengl, windy

# Open window.
var window = newWindow("Windy Window", ivec2(800, 600))
# Connect the GL context.
window.makeContextCurrent()

when not defined(emscripten):
  # This must be called to make any GL function work
  loadExtensions()

var colorFade = 1.0

proc mainLoop() {.cdecl.} =

  # Draw red color screen.
  glClearColor(sin(colorFade)/2 + 0.5, 0, 0, 1)
  colorFade += 0.01
  glClear(GL_COLOR_BUFFER_BIT)

  # Swap buffers (this will display the red color)
  window.swapBuffers()

  # Check for events.
  pollEvents()

when defined(emscripten):
  # Emscripten can't block so it will call this callback instead.
  window.run(mainLoop)
else:
  # When running native code we can block in an infinite loop.
  while not window.closeRequested:
    mainLoop()
