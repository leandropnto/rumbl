import Player from "./player";
import socket from "./user_socket.js";
import { Presence } from "phoenix";

let Video = {
  init(element) {
    if (!element) {
      return;
    }

    let playerId = element.getAttribute("data-player-id");
    let videoId = element.getAttribute("data-id");
    socket.connect();
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket);
    });
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container");
    let msgInput = document.getElementById("msg-input");
    let postButton = document.getElementById("msg-submit");
    let userList = document.getElementById("user-list");
    let lastSeenId = 0;
    let videoChannel = socket.channel("videos:" + videoId, () => {
      return { last_seen_id: lastSeenId };
    });

    let presence = new Presence(videoChannel);

    presence.onSync(
      () =>
        (userList.innerHTML = presence
          .list((id, { user: user, metas: [first, ...rest] }) => {
            const count = rest.length + 1;
            return `<li>${user.username}: (${count})</li>`;
          })
          .join(""))
    );
    window.videoChannel = videoChannel;

    postButton.addEventListener("click", (_evt) => {
      const payload = { body: msgInput.value, at: Player.getCurrentTime() };
      videoChannel
        .push("new_annotation", payload)
        .receive("error", (e) => console.log(e));

      msgInput.value = "";
    });

    videoChannel.on("new_annotation", (resp) => {
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    videoChannel
      .join()
      .receive("ok", (resp) => {
        let ids = resp.annotations.map((ann) => ann.id);
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        }
        this.scheduleMessages(msgContainer, resp.annotations);
      })
      .receive("error", (reason) => console.log("join failed", reason));

    msgContainer.addEventListener("click", (e) => {
      e.preventDefault();
      const seconds =
        e.target.getAttribute("data-seek") ||
        e.target.parentNode.getAttribute("data-seek");
      if (!seconds) {
        return;
      }

      Player.seekTo(seconds);
    });
  },

  renderAnnotation(msgContainer, { user, body, at }) {
    const template = document.createElement("div");
    template.innerHTML = `
 <a href="#" data-seek="${this.esc(at)}">[${this.formatTime(at)}] - <b>${
      user.username
    }: </b> ${this.esc(body)} </a>
`;
    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },

  esc(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.schedulerTimer);
    this.schedulerTimer = setTimeout(() => {
      const ctime = Player.getCurrentTime();
      const remaining = this.renderAtTime(annotations, ctime, msgContainer);
      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter((ann) => {
      if (ann.at > seconds) {
        return true;
      } else {
        this.renderAnnotation(msgContainer, ann);
      }
    });
  },

  formatTime(at) {
    let date = new Date(null);
    date.setSeconds(at / 1000);
    console.log(date.toISOString());
    console.log(date.toISOString().substring(14, 5));
    return date.toISOString().substring(11, 19);
  },
};

export default Video;
