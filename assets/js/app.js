// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/espaco_neuro"
import topbar from "../vendor/topbar"

let Uploaders = {}

Uploaders.S3 = function(entries, onViewError) {
  entries.forEach(entry => {
    let {url} = entry.meta
    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 200 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable){
        let percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100){ entry.progress(percent) }
      }
    })
    xhr.open("PUT", url, true)
    xhr.setRequestHeader("Content-Type", entry.file.type)
    xhr.send(entry.file)
  })
}

const ProfessionalCardTextFit = {
  mounted() {
    this.fitFrame = null
    this.measureFrame = null
    this.scheduleFit = () => {
      if (this.fitFrame) cancelAnimationFrame(this.fitFrame)
      if (this.measureFrame) cancelAnimationFrame(this.measureFrame)

      this.fitFrame = requestAnimationFrame(() => this.resetAndFitCards())
    }

    this.resizeObserver = new ResizeObserver(this.scheduleFit)
    this.resizeObserver.observe(this.el)
    document.fonts?.ready.then(this.scheduleFit)
    this.scheduleFit()
  },

  updated() {
    this.scheduleFit()
  },

  destroyed() {
    this.resizeObserver.disconnect()
    if (this.fitFrame) cancelAnimationFrame(this.fitFrame)
    if (this.measureFrame) cancelAnimationFrame(this.measureFrame)
  },

  resetAndFitCards() {
    const cards = [...this.el.querySelectorAll(".pro-card")]

    cards.forEach(card => {
      const title = card.querySelector(".pro-title")
      const description = card.querySelector(".pro-desc")

      if (title) {
        const baseLines = Number(title.dataset.baseLines) || 1
        title.style.setProperty("--card-title-lines", baseLines)
        delete title.dataset.visibleCharacters
        delete title.dataset.visibleLines
      }

      if (!description) return

      const baseLines = Number(description.dataset.baseLines) || 4
      description.style.setProperty("--card-description-lines", baseLines)
      delete description.dataset.visibleLines
    })

    this.measureFrame = requestAnimationFrame(() => {
      cards.forEach(card => this.fitCard(card))
    })
  },

  fitCard(card) {
    const title = card.querySelector(".pro-title")
    const description = card.querySelector(".pro-desc")
    const modalities = card.querySelector(".pro-foot")

    if (!title || !description || !modalities) return

    const titleLineHeight = Number.parseFloat(getComputedStyle(title).lineHeight)
    const descriptionLineHeight = Number.parseFloat(getComputedStyle(description).lineHeight)

    if (
      !Number.isFinite(titleLineHeight) ||
      titleLineHeight <= 0 ||
      !Number.isFinite(descriptionLineHeight) ||
      descriptionLineHeight <= 0
    ) return

    const titleBaseLines = Number(title.dataset.baseLines) || 1
    const fullTitleLines = this.measureFullLineCount(title, titleLineHeight)
    const hiddenTitleLines = Math.max(0, fullTitleLines - titleBaseLines)
    const titleExtraLines = Math.min(
      hiddenTitleLines,
      Math.floor(Math.max(0, this.availableTextHeight(card, description) - 2) / titleLineHeight)
    )
    const visibleTitleLines = Math.min(fullTitleLines, titleBaseLines + titleExtraLines)

    title.style.setProperty("--card-title-lines", visibleTitleLines)
    title.dataset.visibleLines = visibleTitleLines

    const totalCharacters = Array.from(title.textContent.trim()).length
    const visibleCharacters = this.measureVisibleCharacterCount(
      title,
      visibleTitleLines,
      titleLineHeight,
      fullTitleLines
    )

    title.dataset.visibleCharacters = visibleCharacters
    this.updateFitStatus(title, visibleCharacters, totalCharacters)

    const baseLines = Number(description.dataset.baseLines) || 4
    const fullLines = this.measureFullLineCount(description, descriptionLineHeight)
    const hiddenLines = Math.max(0, fullLines - baseLines)
    const extraLines = Math.min(
      hiddenLines,
      Math.floor(
        Math.max(0, this.availableTextHeight(card, description) - 2) / descriptionLineHeight
      )
    )
    const visibleLines = baseLines + extraLines

    description.style.setProperty("--card-description-lines", visibleLines)
    description.dataset.visibleLines = visibleLines
  },

  availableTextHeight(card, description) {
    const modalities = card.querySelector(".pro-foot")
    const specialties = card.querySelector(".pro-specialties")
    const contentBeforeModalities = specialties || description

    return (
      modalities.getBoundingClientRect().top -
      contentBeforeModalities.getBoundingClientRect().bottom
    )
  },

  measureFullLineCount(element, lineHeight) {
    const measurement = this.createMeasurement(element)

    if (!measurement) return 1

    const fullHeight = measurement.getBoundingClientRect().height
    measurement.remove()

    return Math.max(1, Math.ceil((fullHeight - 0.5) / lineHeight))
  },

  measureVisibleCharacterCount(element, visibleLines, lineHeight, fullLines) {
    const characters = Array.from(element.textContent.trim())

    if (fullLines <= visibleLines) return characters.length

    const measurement = this.createMeasurement(element)

    if (!measurement) return characters.length

    const maximumHeight = visibleLines * lineHeight + 0.5
    let lowerBound = 0
    let upperBound = characters.length

    while (lowerBound < upperBound) {
      const middle = Math.ceil((lowerBound + upperBound) / 2)
      const candidate = characters.slice(0, middle).join("").trimEnd()
      measurement.textContent = `${candidate}…`

      if (measurement.getBoundingClientRect().height <= maximumHeight) {
        lowerBound = middle
      } else {
        upperBound = middle - 1
      }
    }

    measurement.remove()
    return lowerBound
  },

  createMeasurement(element) {
    const width = element.getBoundingClientRect().width

    if (width <= 0) return null

    const measurement = element.cloneNode(true)

    measurement.removeAttribute("id")
    measurement.removeAttribute("data-visible-lines")
    measurement.removeAttribute("data-visible-characters")
    Object.assign(measurement.style, {
      position: "fixed",
      inset: "0 auto auto -10000px",
      width: `${width}px`,
      height: "auto",
      maxHeight: "none",
      margin: "0",
      display: "block",
      overflow: "visible",
      visibility: "hidden",
      pointerEvents: "none",
      webkitLineClamp: "unset",
      lineClamp: "unset",
      webkitBoxOrient: "unset",
    })

    document.body.appendChild(measurement)
    return measurement
  },

  updateFitStatus(title, visibleCharacters, totalCharacters) {
    const targetId = title.dataset.fitStatusTarget

    if (!targetId) return

    const status = document.getElementById(targetId)

    if (!status) return

    status.textContent = visibleCharacters >= totalCharacters
      ? "Todo o texto está visível na prévia."
      : `Na prévia, ${visibleCharacters} de ${totalCharacters} caracteres estão visíveis.`
  },
}

const LiveCharacterCounter = {
  mounted() {
    this.updateCharacterCount = () => {
      const counter = document.getElementById(this.el.dataset.counterTarget)
      const characterCount = Array.from(this.el.value).length

      if (counter) {
        counter.textContent = characterCount
      }
    }

    this.el.addEventListener("input", this.updateCharacterCount)
    this.updateCharacterCount()
  },

  updated() {
    this.updateCharacterCount()
  },

  destroyed() {
    this.el.removeEventListener("input", this.updateCharacterCount)
  },
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ProfessionalCardTextFit, LiveCharacterCounter},
  uploaders: Uploaders,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
