function doGet(e) {
  var token = e.parameter.token;
  if(token !== "HeliosPulseToken") return ContentService.createTextOutput("Invalid token");
  var action = e.parameter.action;
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  if(action == "presence") {
    var nick = e.parameter.nick || "Unknown";
    var sh = sheet.getSheetByName("presence") || sheet.insertSheet("presence");
    sh.appendRow([new Date(), nick]);
    return ContentService.createTextOutput("Presence logged for " + nick);
  }
  return ContentService.createTextOutput("No action");
}