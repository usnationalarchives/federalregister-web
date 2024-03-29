OFR.ContentNotifications = class ContentNotifications {
  constructor(userPreferenceStore) {
    this.userPreferenceStore = userPreferenceStore
  }

  addEvents() {
    this.addDismiss()
  }

  addDismiss() {
    document.querySelectorAll('.content-notification .dismiss-link')
      .forEach(dismissLink => {
        dismissLink.addEventListener('click', (event) => {
          const notification = event.target.closest('.content-notification')
          notification.style.display = 'none'
          this.ignoreForSession(notification.id)
        })
      }
    )
  }

  hideIgnored(body) {
    // body is optional and we fall back to the rendered document body
    // but turbo allows us to operate on the new body before rendering
    body = body || document.body

    const settings = this.userPreferenceStore.getContentNotificationsSettings()

    settings.ignoredNotifications.forEach(id => {
      const notification = body.querySelector(`#${id}`)

      if (notification !== null) {
        notification.style.display = 'none'
      }
    })
  }

  ignoreForSession(id) {
    const settings = this.userPreferenceStore.getContentNotificationsSettings()

    settings.ignoredNotifications.push(id)

    this.userPreferenceStore.saveContentNotificationsSetting(
      {ignoredNotifications: settings.ignoredNotifications}
    )
  }

}
