export default {
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
}
