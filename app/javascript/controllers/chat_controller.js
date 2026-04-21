import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    chatId: String,
    messagesPath: String,
    nextPage: Number
  }

  initialize() {
    this.hasMoreMessages = true
    this.isLoading = false
  }

  connect() {
    this.messagesElement = this.element.querySelector("#messages")
    this.boundHandleScroll = this.handleScroll.bind(this)

    if (this.messagesElement) {
      this.messagesElement.addEventListener("scroll", this.boundHandleScroll)
      this.scheduleInitialLoad()
    }
  }

  disconnect() {
    if (this.messagesElement) {
      this.messagesElement.removeEventListener("scroll", this.boundHandleScroll)
    }
  }

  handleScroll() {
    if (!this.messagesElement || this.messagesElement.scrollTop > 0) return

    this.loadMessages()
  }

  async scheduleInitialLoad() {
    await this.nextFrame()
    await this.nextFrame()

    this.loadMessages()
  }

  async loadMessages() {
    if (!this.hasMoreMessages || this.isLoading) return

    this.isLoading = true

    const previousScrollHeight = this.messagesElement.scrollHeight
    const previousScrollTop = this.messagesElement.scrollTop

    this.messagesElement.dataset.preserveScroll = "true"

    try {
      const response = await fetch(
        `${this.messagesPathValue}?chat_id=${encodeURIComponent(this.chatIdValue)}&page=${this.nextPageValue}`,
        {
          headers: {
            Accept: "text/vnd.turbo-stream.html"
          }
        }
      )

      if (response.status === 204) {
        this.hasMoreMessages = false
        return
      }

      if (!response.ok) {
        throw new Error(`Failed to load messages: ${response.status}`)
      }

      const html = await response.text()

      if (html.length === 0) {
        this.hasMoreMessages = false
        return
      }

      Turbo.renderStreamMessage(html)

      await this.restoreScrollPosition(previousScrollHeight, previousScrollTop)
      this.nextPageValue += 1
    } finally {
      delete this.messagesElement.dataset.preserveScroll
      this.isLoading = false
    }
  }

  async restoreScrollPosition(previousScrollHeight, previousScrollTop) {
    await this.nextFrame()
    await this.nextFrame()

    this.messagesElement.scrollTop =
      this.messagesElement.scrollHeight - previousScrollHeight + previousScrollTop
  }

  nextFrame() {
    return new Promise((resolve) => requestAnimationFrame(resolve))
  }
}
