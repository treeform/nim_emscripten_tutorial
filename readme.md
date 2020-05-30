## Nim Emscripten Tutorial for Windows.

### Step 0: Making sure Emscripten can compile C:

Assumes windows 10 64bit.

First clone the `emsdk` - is kind of like `choosenim` which will install the actual `emcc` compiler.

```sh
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
```

Lets install `emcc` - the actual compiler we will be using.

```sh
emsdk install latest
emsdk activate latest
emsdk_env.bat
```

Ok lets compile the basic C program to make sure it works:

```sh
emcc step0.c -o step0.html
```

To view the files because of CORS we need to run a webserver. The easiest one to run is python (version 3):

```sh
python -m http.server
```

Ok open a browser to that page:

```sh
start http://localhost:8000/step0.html
```

You should see the Emscripten default chrome:

![step0.c with emscripten](docs\step0a.png)

Make sure you got the `Hello, world!` in the console.

To remove the ugly Emscripten default chrome, you need to use your own minimal html. I provided one in this repo, just call:

```sh
emcc step0.c -o step0.html --shell-file shell_minimal.html
```

![step0.c with emscripten](docs\step0b.png)

Now the `Hello, world!` in the JS console.

### Step 1: Using Nim with Emscripten.

Next lets try nim, lets look at the very simple [step1.nim](step1.nim):
```nim
echo "Hello World, from Nim."
```

Most of the work will be done but the [step1.nims](step1.nims) file:
```nim
if defined(emscripten):
  # This path will only run if -d:emscripten is passed to nim.

  --nimcache:tmp # Store intermediate files close by in ./tmp dir.

  --os:linux # Emscripten pretends to be linux.
  --cpu:i386 # Emscripten is 32bits.
  --cc:clang # Emscripten is very close to clang, so we ill replace it.
  --clang.exe:emcc.bat  # Replace C
  --clang.linkerexe:emcc.bat # Replace C linker
  --clang.cpp.exe:emcc.bat # Replace C++
  --clang.cpp.linkerexe:emcc.bat # Replace C++ linker.
  --listCmd # List what commands we are running so that we can debug them.

  --gc:arc # GC:arc is friendlier with crazy platforms.
  --exceptions:goto # Goto exceptions are friendlier with crazy platforms.

  # Pass this to Emscripten linker to generate html file scaffold for us.
  switch("passL", "-o basic.html --shell-file shell_minimal.html")
```

Lets compiler it!

```sh
nim c -d:emscripten .\basic.nim
```

Lets go to step1.html, this is how it should look:

```sh
start http://localhost:8000/step0.html
```

![step1](docs\step1.png)

Take note of the console output with `Hello World, from Nim.`.

### Nim with openGL.

We can do a ton of stuff with just "console" programs, but what Emscripten is all bout is doing graphics. We can use normal openGL, and emscripten will convert it to webGL. We can also use normal SDL or GLFW windowing and input library and emscripten will convert it to HTML events for us. Emscripten also gives us a "fake" file system to load files from. Many things that would be missing from just having WASM running in the browser we get from free with Emscripten.

I will be using GLFW for my examples, GLFW is lighter weight then SDL with less bloated API. I will be using https://github.com/treeform/staticglfw because it has been made to work with emscripten.

See: [step2.nim](step2.nim)

First lets make sure it runs in normal native mode:

```sh
nim c -r step2.nim
```

![step2](docs\step2a.png)

You should just see a window with changing background color.

Now lets try it with `-d:emscripten`:

```sh
nim c -d:emscripten step2.nim
```

Again a ton of work is happening in the settings file [step2.nims](step2.nims).

Lets go take a look at step2.html

```sh
start http://localhost:8000/step2.html
```

![step2](docs\step2b.png)


Again you should see red window with pulsating color.

### Step3: Nim with OpenGL Triangle.

The [step3.nim](step3.nim) is more complex as it requires loading shaders and setting up a triangle to draw.

Again see it work natively:
```sh
nim c -r step3.nim
```

Then compile it for the browser:
```sh
nim c -d:emscripten step3.nim
```

And see it run:

It also handles resizing of window as well.
