import Player from "./player"
import socket from "./user_socket.js"

let Video = {
  init(element) {
    if (!element) {
      return
    }

    let playerId = element.getAttribute("data-player-id")
    let videoId = element.getAttribute("data-id")
    socket.connect()
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let videoChannel = socket.channel("videos:" + videoId)

    videoChannel.join()
      .receive("ok", resp => console.log("Joined the video channel", resp))
      .receive("error", reason => console.log("join failed", reason))


    videoChannel.on("ping", ({ count }) => console.log("PING", count))
    videoChannel.on("msg-receive", ({ message }) => console.log(`Sender: ${message.sender} - ${message.msg}`))

    window.videoChannel = videoChannel
    postButton.addEventListener('click', _evt => {
      const payload = {body: msgInput.value, at: Player.getCurrentTime()}
        videoChannel.push("new_annotation", payload)
          .receive("error", e => console.log(e))

    msgInput.value = ""


    })

    videoChannel.on('new_annotation', (resp) => {
      this.renderAnnotation(msgContainer, resp) 
    })

      },

  renderAnnotation(msgContainer, {user, body, at}) {
    const template = document.createElement("div")
    template.innerHTML = `
 <a href="#" data-seek="${this.esc(at)}"><b>${this.esc(body)} </a>
`
      msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight

  },

  esc(str) {
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },
}

export default Video
