import vmath, opengl, windy

var
  vertices: seq[float32] = @[
    -0.6f, -0.4f, 1.0f, 0.0f, 0.0f,
    +0.6f, -0.4f, 0.0f, 1.0f, 0.0f,
    +0.0f, +0.6f, 0.0f, 0.0f, 1.0f
  ]

when defined(emscripten):
  var
    vertexShaderText = readFile("data/vert.emscripten.sh")
    fragmentShaderText = readFile("data/frag.emscripten.sh")
else:
  var
    vertexShaderText = readFile("data/vert.sh")
    fragmentShaderText = readFile("data/frag.sh")

proc checkError*(shader: GLuint) =
  var code: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr code)
  if code.GLboolean == GL_FALSE:
    var length: GLint = 0
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr length)
    var log = newString(length.int)
    glGetShaderInfoLog(shader, length, nil, log.cstring);
    echo log
  else:
    echo "pass"

# Open window.
var window = newWindow("GLFW3 WINDOW", ivec2(800, 600))
# Connect the GL context.
window.makeContextCurrent()

when not defined(emscripten):
  # This must be called to make any GL function work
  loadExtensions()

# Create and bind VAO for macOS/desktop OpenGL Core Profile
var vao: GLuint
when not defined(emscripten):
  glGenVertexArrays(1, addr vao)
  glBindVertexArray(vao)

var vertexBuffer: GLuint
glGenBuffers(1, addr vertexBuffer)
glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
glBufferData(GL_ARRAY_BUFFER, vertices.len * 5 * 4, addr vertices[0], GL_STATIC_DRAW)

var vertexShader = glCreateShader(GL_VERTEX_SHADER)
var vertexShaderTextArr = allocCStringArray([vertexShaderText])
glShaderSource(vertexShader, 1.GLsizei, vertexShaderTextArr, nil)
glCompileShader(vertexShader)
checkError(vertexShader)

var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
var fragmentShaderTextArr = allocCStringArray([fragmentShaderText])
glShaderSource(fragmentShader, 1.GLsizei, fragmentShaderTextArr, nil);
glCompileShader(fragmentShader)
checkError(fragmentShader)

var program = glCreateProgram()
glAttachShader(program, vertexShader)
glAttachShader(program, fragmentShader)
glLinkProgram(program)
var
  mvpLocation = glGetUniformLocation(program, "MVP").GLuint
  vposLocation = glGetAttribLocation(program, "vPos").GLuint
  vcolLocation = glGetAttribLocation(program, "vCol").GLuint
echo mvpLocation
echo vposLocation
#echo vcolLocation
glEnableVertexAttribArray(vposLocation);
glVertexAttribPointer(vposLocation, 2.GLint, cGL_FLOAT, GL_FALSE, (5 * 4).GLsizei, nil)
glEnableVertexAttribArray(vcolLocation.GLuint);
glVertexAttribPointer(vcolLocation, 3.GLint, cGL_FLOAT, GL_FALSE, (5 * 4).GLsizei, cast[pointer](4*2))

var colorFade = 1.0
var rotationAngle = 0.0f

window.onResize = proc() =
  let size = window.size
  echo "resize: ", size.x, "x", size.y

proc mainLoop() {.cdecl.} =
  var ratio: float32
  var m, p, mvp: Mat4
  let fbSize = window.size
  let width = fbSize.x.cint
  let height = fbSize.y.cint
  ratio = width.float32 / height.float32
  glViewport(0, 0, width, height)
  var a = sin(colorFade)*0.2 + 0.20
  glClearColor(a, a, a, 1)
  colorFade += 0.01
  glClear(GL_COLOR_BUFFER_BIT)

  rotationAngle += 0.02f
  m = rotateZ(rotationAngle)
  p = ortho[float32](-1, 1, 1, -1, -1000, 1000)
  mvp = m * p;

  glUseProgram(program)
  var mvp_addr = cast[ptr GLFloat](mvp.unsafeAddr)
  glUniformMatrix4fv(mvpLocation.GLint, 1, GL_FALSE, mvp_addr);
  glDrawArrays(GL_TRIANGLES, 0, 3);

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
