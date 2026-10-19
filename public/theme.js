try {
  if (localStorage.getItem("den-theme") === "light") {
    document.documentElement.dataset.theme = "light";
  }
} catch (e) {
  console.error("Couldn't load theme from localStorage" ,e)
}
