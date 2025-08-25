import boxy, windy

let window = newWindow("Step 4", ivec2(1280, 800))
makeContextCurrent(window)

when not defined(emscripten):
  import opengl
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
  # Test if OpenGL is working - set a red clear color

  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)

  # Draw the bg.
  bxy.drawImage("bg", rect = rect(vec2(0, 0), window.size.vec2))

  # # Draw the rings.
  let center = window.size.vec2 / 2
  bxy.drawImage("ring1", center, angle = frame.float / 100)
  bxy.drawImage("ring2", center, angle = -frame.float / 190)
  bxy.drawImage("ring3", center, angle = frame.float / 170)

  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()

  inc frame

window.onCloseRequest = proc() =
  echo "Emscripten: window's can't be closed"

window.onMove = proc() =
  echo "Emscripten: window's can't be moved"

window.onResize = proc() =
  echo "onResize ", window.size, " content scale = ", window.contentScale
  if window.minimized:
    echo "Emscripten: window's can't be minimized"
  if window.maximized:
    echo "Emscripten: window's can't be maximized"

window.onFocusChange = proc() =
  echo "onFocusChange ", window.focused

window.onMouseMove = proc() =
  echo "onMouseMove from ",
    window.mousePrevPos, " to ", window.mousePos, " delta = ", window.mouseDelta

window.onScroll = proc() =
  echo "onScroll ", window.scrollDelta

window.onButtonPress = proc(button: Button) =
  echo "onButtonPress ", button
  echo "down: ", window.buttonDown[button]
  echo "pressed: ", window.buttonPressed[button]
  echo "released: ", window.buttonReleased[button]
  echo "toggle: ", window.buttonToggle[button]

window.onButtonRelease = proc(button: Button) =
  echo "onButtonRelease ", button
  echo "down: ", window.buttonDown[button]
  echo "pressed: ", window.buttonPressed[button]
  echo "released: ", window.buttonReleased[button]
  echo "toggle: ", window.buttonToggle[button]

window.onRune = proc(rune: Rune) =
  echo "onRune ", rune

proc mainLoop() {.cdecl.} =
  pollEvents()
  if window.onFrame != nil:
    window.onFrame()

when defined(emscripten):
  # Emscripten can't block so it will call this callback instead.
  window.run(mainLoop)
else:
  while not window.closeRequested:
    mainLoop()
