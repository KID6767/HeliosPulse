// ==UserScript==
// @name         Helios Pulse — Presence & Stats
// @namespace    https://legionisci-heliosa.local
// @version      1.0
// @description  Potwierdzanie obecności + integracja Google Sheets (HeliosPulse)
// @match        https://*.grepolis.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-end
// ==/UserScript==

(function() {
  const CONFIG = {"ALLIANCE": "Legioni\u015bci Heliosa", "WEBAPP_URL": "https://script.google.com/macros/s/AKfycbyUNnWniaGRrJgc69xQPb9VQZqeSUd8NzAbwQPWqJely7weWlr5jNQLNWpYtfXUH6RCYQ/exec", "TOKEN": "HeliosPulseToken"};
  function markPresence() {
    const url = CONFIG.WEBAPP_URL + "?token=" + CONFIG.TOKEN + "&nick=" + encodeURIComponent(window.Game?.player_name||"Unknown") + "&action=presence";
    GM_xmlhttpRequest({
      method: "GET", url: url,
      onload: r => console.log("Presence sent:", r.responseText)
    });
  }
  window.setTimeout(markPresence, 5000);
})();
