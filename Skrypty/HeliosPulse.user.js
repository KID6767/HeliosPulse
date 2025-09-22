// ==UserScript==
// @name         Helios Pulse 🌀 Presence & Stats
// @namespace    https://legionisci-heliosa.local
// @version      1.0
// @description  Potwierdzanie obecności + integracja Google Sheets (HeliosPulse)
// @match        https://*.grepolis.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-end
// ==/UserScript==

(function() {
  const CONFIG = {
    "ALLIANCE": "Legioniści Heliosa",
    "WEBAPP_URL": "https://script.google.com/macros/s/AKfycby0ErMv1ffqbVOD2eHOrd_elWTbkcc71elLFthY_8PvUTGsTzitrjv8rwLOrzeDtLpmzg/exec",
    "TOKEN": "HeliosPulseToken"
  };

  function markPresence() {
    const url =
      CONFIG.WEBAPP_URL +
      "?token=" + CONFIG.TOKEN +
      "&nick=" + encodeURIComponent(window.Game?.player_name || "Unknown") +
      "&action=presence";

    GM_xmlhttpRequest({
      method: "GET",
      url: url,
      onload: r => console.log("Presence sent:", r.responseText)
    });
  }

  // Pierwsze wysłanie po 5s od załadowania strony
  window.setTimeout(markPresence, 5000);
})();
