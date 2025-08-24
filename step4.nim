import boxy, windy

let window = newWindow("Step 4", ivec2(1280, 800))
makeContextCurrent(window)

when not defined(emscripten):
  loadExtensions()

let bxy = newBoxy()

# Load the images.
bxy.addImage("bg", readImage("data/bg.png"))
bxy.addImage("ring1", readImage("data/ring1.png"))
bxy.addImage("ring2", readImage("data/ring2.png"))
bxy.addImage("ring3", readImage("data/ring3.png"))

var frame: int

# Called when it is time to draw a new frame.
window.onFrame = proc() =
  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)

  # Draw the bg.
  bxy.drawImage("bg", rect = rect(vec2(0, 0), window.size.vec2))

  # Draw the rings.
  let center = window.size.vec2 / 2
  bxy.drawImage("ring1", center, angle = frame.float / 100)
  bxy.drawImage("ring2", center, angle = -frame.float / 190)
  bxy.drawImage("ring3", center, angle = frame.float / 170)

  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

proc mainLoop() {.cdecl.} =
  window.onFrame()

when defined(emscripten):
  # Emscripten can't block so it will call this callback instead.
  window.run(mainLoop)
else:
  while not window.closeRequested:
    pollEvents()
