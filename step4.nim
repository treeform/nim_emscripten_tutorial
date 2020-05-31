import fidget

loadFont("IBM Plex Sans Regular", "data/IBMPlexSans-Regular.ttf")

proc drawMain() =
  frame "main":
    box 0, 0, 620, 140
    for i in 0 .. 4:
      group "block":
        box 20+i*120, 20, 100, 100
        fill "#2B9FEA"

  text "text stuff":
    box 30, 30, 10000, 100
    fontFamily "IBM Plex Sans Regular"
    fontSize 60
    lineHeight 60
    fill "#000000"
    textAlign hLeft, vBottom
    characters "Text test / Текстовый тест"

when defined(js):
  startFidget(drawMain)
else:
  startFidget(drawMain, w = 620, h = 140)
