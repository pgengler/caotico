// Search popup and mobile menu interactions.
// Vanilla JS rewrite of the original jQuery-based script.js.

function toggleSearch() {
  const popup = document.querySelector(".search_popup");
  const searchIcon = document.querySelector(".search > .icon-search");
  const removeIcon = document.querySelector(".search > .icon-remove");
  if (!popup) return;

  const isOpen = popup.classList.contains("open");
  if (isOpen) {
    popup.classList.remove("open");
    popup.style.display = "none";
    const input = popup.querySelector('input[type=text]');
    if (input) input.blur();
  } else {
    popup.classList.add("open");
    popup.style.display = "block";
    const input = popup.querySelector('input[type=text]');
    if (input) input.focus();
  }

  if (searchIcon) searchIcon.classList.toggle("active");
  if (removeIcon) removeIcon.classList.toggle("active");
}

function toggleMobileMenu() {
  const nav = document.querySelector("header nav");
  if (!nav) return;

  const isVisible = window.getComputedStyle(nav).display !== "none";
  nav.style.display = isVisible ? "none" : "block";
}

function setupScript() {
  const searchIcon = document.querySelector(".search > .icon-search");
  const removeIcon = document.querySelector(".search > .icon-remove");
  const menuButton = document.querySelector(".menubutton");

  if (searchIcon) searchIcon.addEventListener("click", toggleSearch);
  if (removeIcon) removeIcon.addEventListener("click", toggleSearch);
  if (menuButton) menuButton.addEventListener("click", toggleMobileMenu);
}

document.addEventListener("DOMContentLoaded", setupScript);
document.addEventListener("turbo:load", setupScript);
