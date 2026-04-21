import { Controller } from "@hotwired/stimulus"

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

    this.messagesElement.dataset.preserveScroll = "true"
    const anchorData = this.captureAnchor()
    const pendingUpdate = this.waitForMessagesUpdate(anchorData)

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
        pendingUpdate.cancel()
        this.hasMoreMessages = false
        return
      }

      if (!response.ok) {
        pendingUpdate.cancel()
        throw new Error(`Failed to load messages: ${response.status}`)
      }

      await pendingUpdate.promise
      this.nextPageValue += 1
    } finally {
      delete this.messagesElement.dataset.preserveScroll
      this.isLoading = false
    }
  }

  captureAnchor() {
    const containerTop = this.messagesElement.getBoundingClientRect().top
    const children = Array.from(this.messagesElement.children)

    const element = children.find((child) => {
      return child.getBoundingClientRect().bottom > containerTop
    })

    if (!element) return null

    return {
      element,
      topOffset: element.getBoundingClientRect().top - containerTop
    }
  }

  waitForMessagesUpdate(anchorData) {
    let resolved = false
    let observer = null
    let timeoutId = null
    let resolvePromise = null

    const promise = new Promise((resolve) => {
      resolvePromise = resolve

      const finish = () => {
        if (resolved) return

        resolved = true
        observer?.disconnect()
        if (timeoutId) clearTimeout(timeoutId)
        resolve()
      }

      observer = new MutationObserver(() => {
        if (anchorData?.element?.isConnected) {
          const containerTop = this.messagesElement.getBoundingClientRect().top
          const newTopOffset = anchorData.element.getBoundingClientRect().top - containerTop

          this.messagesElement.scrollTop += newTopOffset - anchorData.topOffset
        }

        finish()
      })
      observer.observe(this.messagesElement, { childList: true })

      timeoutId = setTimeout(finish, 1500)
    })

    return {
      promise,
      cancel() {
        if (resolved) return
        resolved = true
        observer?.disconnect()
        if (timeoutId) clearTimeout(timeoutId)
        resolvePromise?.()
      }
    }
  }

  nextFrame() {
    return new Promise((resolve) => requestAnimationFrame(resolve))
  }
}
