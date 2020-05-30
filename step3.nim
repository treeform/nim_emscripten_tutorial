import vmath, opengl, staticglfw

proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}

var
  vertices: seq[float32] = @[
    -0.6f, -0.4f, 1.0f, 0.0f, 0.0f,
    +0.6f, -0.4f, 0.0f, 1.0f, 0.0f,
    +0.0f, +0.6f, 0.0f, 0.0f, 1.0f
  ]

  vertexShaderText = """
uniform mat4 MVP;
attribute vec3 vCol;
attribute vec2 vPos;
varying vec3 color;
void main()
{
    gl_Position = MVP * vec4(vPos, 0.0, 1.0);
    color = vCol;
}
"""

  fragmentShaderText = """
precision mediump float;
varying vec3 color;
void main()
{
    gl_FragColor = vec4(color, 1.0);
}
"""

proc checkError*(shader: GLuint) =
  var code: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr code)
  if code.GLboolean == GL_FALSE:
    var length: GLint = 0
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr length)
    var log = newString(length.int)
    glGetShaderInfoLog(shader, length, nil, log);
    echo log
  else:
    echo "pass"

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

var vertexBuffer: GLuint
glGenBuffers(1, addr vertexBuffer)
glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer)
glBufferData(GL_ARRAY_BUFFER, vertices.len * 5 * 4, addr vertices[0], GL_STATIC_DRAW)

var vertexShader = glCreateShader(GL_VERTEX_SHADER)
var vertexShaderTextArr = allocCStringArray([vertexShaderText])
glShaderSource(vertexShader, 1.GLsizei, vertexShaderTextArr, nil)
glCompileShader(vertex_shader)
checkError(vertexShader)

var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
var fragmentShaderTextArr = allocCStringArray([fragmentShaderText])
glShaderSource(fragmentShader, 1.GLsizei, fragmentShaderTextArr, nil);
glCompileShader(fragmentShader)
checkError(fragment_shader)

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

proc onResize(handle: staticglfw.Window, w, h: int32) {.cdecl.} =
  echo "resize: ", w, "x", h
discard window.setFramebufferSizeCallback(onResize)

proc mainLoop() {.cdecl.} =
  var ratio: float32
  var width, height: cint
  var m, p, mvp: Mat4
  getFramebufferSize(window, addr width, addr height)
  ratio = width.float32 / height.float32
  glViewport(0, 0, width, height)
  var a = sin(colorFade)*0.2 + 0.20
  glClearColor(a, a, a, 1)
  colorFade += 0.01
  glClear(GL_COLOR_BUFFER_BIT)

  m = rotateZ(getTime().float32)
  p = ortho(-1, 1, 1, -1, -1000, 1000)
  mvp = m * p;

  glUseProgram(program)
  glUniformMatrix4fv(mvpLocation.GLint, 1, GL_FALSE, addr mvp[0]);
  glDrawArrays(GL_TRIANGLES, 0, 3);

  # Swap buffers (this will display the red color)
  window.swapBuffers()

  # Check for events.
  pollEvents()

when defined(emscripten):
  # Emscripten can't block so it will call this callback instead.
  emscripten_set_main_loop(main_loop, 0, true);
else:
  # When running native code we can block in an infinite loop.
  while windowShouldClose(window) == 0:
    mainLoop()
    # If you get ESC key quit.
    if window.getKey(KEY_ESCAPE) == 1:
      window.setWindowShouldClose(1)
