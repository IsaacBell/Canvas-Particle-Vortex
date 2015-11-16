# Small color particles
# Rotate around the mouse position
# On mousedown, scales out to circle the entire screen

fps = 30 # Low fps to give a slow-motion effect with little effort, also save on cpu
width = window.innerWidth
height = window.innerHeight
r = 70 # radius
scale = 1 # Cloud size
scaleMin = 12.5
scaleMax = 100 # Scale when holding the mouse down
particleCount = 250
canvas = undefined
context = undefined
particles = undefined
mouseX = width * 0.5
mouseY = height * 0.5
isMouseDown = false

init = ->
  # Create canvas element
  canvas = document.createElement('canvas')
  canvas.id  = 'myCanvas'
  document.body.appendChild(canvas)
  if canvas and canvas.getContext
    context = canvas.getContext('2d')
    # Event handlers
    window.addEventListener 'mousemove', onMouseMove, false
    window.addEventListener 'mousedown', onMouseDown, false
    window.addEventListener 'mouseup', onMouseUp, false
    window.addEventListener 'onResize', onResize, false
    createParticles()
    onResize()
    setInterval animLoop, 1000 / fps
  return

colorLuminance = (hex, lum) ->
  # validate hex string
  hex = String(hex).replace(/[^0-9a-f]/gi, '') 
  if hex.length < 6
    hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2]
  lum = lum or 0

  # convert to decimal and change luminosity
  rgb = '#'
  c = undefined
  i = undefined
  i = 0
  while i < 3
    c = parseInt(hex.substr(i * 2, 2), 16)
    c = Math.round(Math.min(Math.max(0, c + c * lum), 255)).toString(16)
    rgb += ('00' + c).substr(c.length)
    i++
  return rgb

createParticles = ->
  particles = []
  i = 0
  while i < particleCount
    particle = 
      size: 5
      position:
        x: mouseX
        y: mouseY
      offset:
        x: 0
        y: 0
      shift:
        x: mouseX
        y: mouseY
      speed: 0.02 + Math.random() * 0.02
      targetSize: 1
      fillColor: colorLuminance('#' + Math.random().toString(16), -0.23)
      orbit: r / 3 * Math.random()
    particles.push particle
    i++
  return

onMouseMove = (e) ->
  mouseX = e.clientX - ((window.innerWidth - width) * .5)
  mouseY = e.clientY - ((window.innerHeight - height) * .5)
  return

onMouseDown = ->
  isMouseDown = true

onMouseUp = ->
  isMouseDown = false

onResize = ->
  width = window.innerWidth
  height = window.innerHeight
  canvas.width = width
  canvas.height = height
  return

animLoop = ->
  if isMouseDown
    scale += (scaleMax - scale) * 0.2
  else
    scale -= (scale - scaleMin) * 0.2
  scale = Math.min(scale, scaleMax)
  context.fillStyle = 'rgba(0,0,0,0.55)'
  context.fillRect 0, 0, context.canvas.width, context.canvas.height
  i = 0
  len = particles.length
  while i < len
    particle = particles[i]
    lp = 
      x: particle.position.x
      y: particle.position.y
    # Rotation
    particle.offset.x += particle.speed * 0.7
    particle.offset.y += particle.speed * 0.7
    # Follow mouse with some lag
    particle.shift.x += (mouseX - (particle.shift.x)) * particle.speed * 0.6
    particle.shift.y += (mouseY - (particle.shift.y)) * particle.speed * 0.6
    # Apply position
    particle.position.x = particle.shift.x + Math.cos(i + particle.offset.x) * particle.orbit * scale
    particle.position.y = particle.shift.y + Math.sin(i + particle.offset.y) * particle.orbit * scale
    # Limit to screen bounds
    particle.position.x = Math.max(Math.min(particle.position.x, width), 0)
    particle.position.y = Math.max(Math.min(particle.position.y, height), 0)
    particle.size += (particle.targetSize - (particle.size)) * 0.05
    if Math.round(particle.size) == Math.round(particle.targetSize)
      particle.targetSize = 1 + Math.random() * 10
    context.beginPath()
    context.fillStyle = particle.fillColor
    context.strokeStyle = particle.fillColor
    context.lineWidth = particle.size
    context.moveTo lp.x, lp.y
    context.lineTo particle.position.x, particle.position.y
    context.stroke()
    context.arc particle.position.x, particle.position.y, particle.size / 2, 0, Math.PI * 2, true
    context.fill()
    i++
  return

window.onload = init

