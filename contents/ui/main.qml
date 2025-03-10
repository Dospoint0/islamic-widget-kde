// ui/main.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root
    
    // Config properties from plasmoid configuration
    property string cityName: plasmoid.configuration.city || "New York"
    property string countryName: plasmoid.configuration.country || "United States"
    property string timezone: plasmoid.configuration.timezone || getLocalTimezone()
    property int fontSize: plasmoid.configuration.fontSize || 12
    property bool showArabic: plasmoid.configuration.showArabic === undefined ? true : plasmoid.configuration.showArabic
    property bool showTranslation: plasmoid.configuration.showTranslation === undefined ? true : plasmoid.configuration.showTranslation
    property bool showHadith: plasmoid.configuration.showHadith === undefined ? true : plasmoid.configuration.showHadith
    property string theme: plasmoid.configuration.theme || "light"
    
    // API URLs
    property string prayerApiUrl: "https://api.aladhan.com/v1/timingsByCity"
    property string quranApiUrl: "https://api.alquran.cloud/v1/ayah/random"
    property string hadithApiUrl: "https://random-hadith-generator.vercel.app/bukhari"
    
    // Prayer times data
    property var prayerTimes: ({})
    property string nextPrayer: ""
    property date nextPrayerTime: new Date()
    property int countdownSeconds: 0
    
    // Quran verse data
    property string arabicText: i18nc("@info", "Loading verse...")
    property string translationText: i18nc("@info", "Loading translation...")
    property string verseReference: i18nc("@info", "Surah --:--")
    
    // Hadith data
    property string hadithText: i18nc("@info", "Loading hadith...")
    property string hadithSource: i18nc("@info", "Source: --")
    
    // Helper function to get local timezone
    function getLocalTimezone() {
        // Default timezone as fallback
        return "America/New_York";
    }
    
    // Timer for countdown updates
    Timer {
        id: countdownTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateCountdown()
    }
    
    // Timer for daily updates at midnight
    Timer {
        id: dailyUpdateTimer
        interval: calculateMidnightInterval()
        repeat: true
        running: true
        onTriggered: {
            updateAllData();
            interval = 24 * 60 * 60 * 1000; // Set for next day
        }
        
        // Calculate milliseconds until midnight
        function calculateMidnightInterval() {
            var now = new Date();
            var midnight = new Date();
            midnight.setHours(24, 0, 0, 0);
            return midnight - now;
        }
    }
    
    // Update all data
    function updateAllData() {
        updatePrayerTimes();
        updateQuranVerse();
        if (showHadith) {
            updateHadith();
        }
    }
    
    // Convert time string to Date object
    function timeStringToDate(timeStr) {
        var today = new Date();
        var parts = timeStr.split(':');
        var hours = parseInt(parts[0]);
        var minutes = parseInt(parts[1]);
        
        today.setHours(hours, minutes, 0, 0);
        return today;
    }
    
    // Update prayer times from API
    function updatePrayerTimes() {
        var xhr = new XMLHttpRequest();
        var today = new Date();
        var dateStr = today.getDate() + "-" + (today.getMonth() + 1) + "-" + today.getFullYear();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.code === 200) {
                        var timings = response.data.timings;
                        
                        // Store prayer times
                        prayerTimes = {
                            'Fajr': timeStringToDate(timings.Fajr),
                            'Sunrise': timeStringToDate(timings.Sunrise),
                            'Dhuhr': timeStringToDate(timings.Dhuhr),
                            'Asr': timeStringToDate(timings.Asr),
                            'Maghrib': timeStringToDate(timings.Maghrib),
                            'Isha': timeStringToDate(timings.Isha),
                            'Midnight': timeStringToDate(timings.Midnight)
                        };
                        
                        // Get tomorrow's Fajr for midnight calculation
                        fetchTomorrowFajr();
                        
                        // Determine next prayer
                        updateNextPrayer();
                    } else {
                        nextPrayer = i18nc("@info", "API Error");
                        countdownSeconds = 0;
                    }
                } else {
                    nextPrayer = i18nc("@info", "Connection Error");
                    countdownSeconds = 0;
                }
            }
        };
        
        xhr.open("GET", prayerApiUrl + "?city=" + encodeURIComponent(cityName) + 
                "&country=" + encodeURIComponent(countryName) + 
                "&method=2&date=" + dateStr + "&timezone=" + encodeURIComponent(timezone));
        xhr.send();
    }
    
    // Fetch tomorrow's Fajr time for accurate midnight calculation
    function fetchTomorrowFajr() {
        var xhr = new XMLHttpRequest();
        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        var dateStr = tomorrow.getDate() + "-" + (tomorrow.getMonth() + 1) + "-" + tomorrow.getFullYear();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.code === 200) {
                    var tomorrowFajr = timeStringToDate(response.data.timings.Fajr);
                    tomorrowFajr.setDate(tomorrowFajr.getDate() + 1);
                    
                    // Calculate midnight as midpoint between Isha and tomorrow's Fajr
                    var ishaTime = prayerTimes['Isha'];
                    var secondsBetween = (tomorrowFajr - ishaTime) / 1000;
                    var midnightDate = new Date(ishaTime.getTime() + (secondsBetween / 2) * 1000);
                    prayerTimes['Midnight'] = midnightDate;
                    
                    // Update next prayer again with correct midnight
                    updateNextPrayer();
                }
            }
        };
        
        xhr.open("GET", prayerApiUrl + "?city=" + encodeURIComponent(cityName) + 
                "&country=" + encodeURIComponent(countryName) + 
                "&method=2&date=" + dateStr);
        xhr.send();
    }
    
    // Determine next prayer time
    function updateNextPrayer() {
        var now = new Date();
        var next = null;
        var nextTime = null;
        
        // Find the next prayer
        for (var prayer in prayerTimes) {
            var time = prayerTimes[prayer];
            if (time > now) {
                if (nextTime === null || time < nextTime) {
                    next = prayer;
                    nextTime = time;
                }
            }
        }
        
        // If no next prayer found, use tomorrow's Fajr
        if (next === null) {
            fetchTomorrowPrayer();
        } else {
            nextPrayer = next;
            nextPrayerTime = nextTime;
            updateCountdown();
        }
    }
    
    // Fetch tomorrow's first prayer
    function fetchTomorrowPrayer() {
        var xhr = new XMLHttpRequest();
        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        var dateStr = tomorrow.getDate() + "-" + (tomorrow.getMonth() + 1) + "-" + tomorrow.getFullYear();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.code === 200) {
                    var fajrTime = timeStringToDate(response.data.timings.Fajr);
                    fajrTime.setDate(fajrTime.getDate() + 1);
                    
                    nextPrayer = i18nc("@info", "Fajr (Tomorrow)");
                    nextPrayerTime = fajrTime;
                    updateCountdown();
                }
            }
        };
        
        xhr.open("GET", prayerApiUrl + "?city=" + encodeURIComponent(cityName) + 
                "&country=" + encodeURIComponent(countryName) + 
                "&method=2&date=" + dateStr);
        xhr.send();
    }
    
    // Update countdown to next prayer
    function updateCountdown() {
        var now = new Date();
        countdownSeconds = Math.floor((nextPrayerTime - now) / 1000);
        
        if (countdownSeconds <= 0) {
            // Time has passed, update prayer times
            updatePrayerTimes();
        }
    }
    
    // Format seconds to HH:MM:SS
    function formatCountdown(seconds) {
        if (seconds <= 0) return "--:--:--";
        
        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var secs = seconds % 60;
        
        return String(hours).padStart(2, '0') + ":" + 
               String(minutes).padStart(2, '0') + ":" + 
               String(secs).padStart(2, '0');
    }
    
    // Update Quran verse
    function updateQuranVerse() {
        var xhr = new XMLHttpRequest();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.code === 200) {
                    var verse = response.data;
                    arabicText = verse.text;
                    verseReference = i18nc("@info", "Surah %1 (%2)", verse.surah.englishName, verse.numberInSurah);
                    
                    // Get translation
                    fetchTranslation(verse.number);
                }
            }
        };
        
        xhr.open("GET", quranApiUrl);
        xhr.send();
    }
    
    // Fetch translation for verse
    function fetchTranslation(verseNumber) {
        var xhr = new XMLHttpRequest();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.code === 200) {
                    translationText = response.data.text;
                }
            }
        };
        
        xhr.open("GET", "https://api.alquran.cloud/v1/ayah/" + verseNumber + "/en.sahih");
        xhr.send();
    }
    
    // Update hadith
    function updateHadith() {
        var xhr = new XMLHttpRequest();
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.data) {
                    var hadith = response.data;
                    hadithText = hadith.hadith_english || "";
                    hadithSource = i18nc("@info", "Source: Sahih al-Bukhari %1", hadith.hadith_number || "");
                }
            }
        };
        
        xhr.open("GET", hadithApiUrl);
        xhr.send();
    }
    
    // Initialize on component completion
    Component.onCompleted: {
        updateAllData();
    }
    
    preferredRepresentation: fullRepresentation
    
    // Full representation
    fullRepresentation: ColumnLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 24
        Layout.preferredHeight: Kirigami.Units.gridUnit * 36
        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        Layout.minimumHeight: Kirigami.Units.gridUnit * 15
        
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.largeSpacing
        
        // Header
        Label {
            text: i18nc("@title", "Islamic Widget")
            font.pixelSize: Kirigami.Units.gridUnit * 1.2
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Prayer times section
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: prayerColumn.height
            
            ColumnLayout {
                id: prayerColumn
                width: parent.width
                spacing: Kirigami.Units.smallSpacing
                
                Label {
                    text: i18nc("@title", "Prayer Times")
                    font.pixelSize: Kirigami.Units.gridUnit
                    font.bold: true
                }
                
                // Prayer times grid
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Kirigami.Units.largeSpacing
                    
                    // Fajr
                    Label {
                        text: i18nc("@label:prayer", "Fajr:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Fajr'] ? Qt.formatTime(prayerTimes['Fajr'], "hh:mm") : "--:--"
                        color: nextPrayer === "Fajr" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Fajr"
                    }
                    
                    // Sunrise
                    Label {
                        text: i18nc("@label:prayer", "Sunrise:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Sunrise'] ? Qt.formatTime(prayerTimes['Sunrise'], "hh:mm") : "--:--"
                        color: nextPrayer === "Sunrise" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Sunrise"
                    }
                    
                    // Dhuhr
                    Label {
                        text: i18nc("@label:prayer", "Dhuhr:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Dhuhr'] ? Qt.formatTime(prayerTimes['Dhuhr'], "hh:mm") : "--:--"
                        color: nextPrayer === "Dhuhr" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Dhuhr"
                    }
                    
                    // Asr
                    Label {
                        text: i18nc("@label:prayer", "Asr:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Asr'] ? Qt.formatTime(prayerTimes['Asr'], "hh:mm") : "--:--"
                        color: nextPrayer === "Asr" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Asr"
                    }
                    
                    // Maghrib
                    Label {
                        text: i18nc("@label:prayer", "Maghrib:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Maghrib'] ? Qt.formatTime(prayerTimes['Maghrib'], "hh:mm") : "--:--"
                        color: nextPrayer === "Maghrib" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Maghrib"
                    }
                    
                    // Isha
                    Label {
                        text: i18nc("@label:prayer", "Isha:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Isha'] ? Qt.formatTime(prayerTimes['Isha'], "hh:mm") : "--:--"
                        color: nextPrayer === "Isha" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Isha"
                    }
                    
                    // Midnight
                    Label {
                        text: i18nc("@label:prayer", "Midnight:")
                        font.bold: true
                    }
                    Label {
                        text: prayerTimes['Midnight'] ? Qt.formatTime(prayerTimes['Midnight'], "hh:mm") : "--:--"
                        color: nextPrayer === "Midnight" ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        font.bold: nextPrayer === "Midnight"
                    }
                }
                
                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Kirigami.Theme.disabledTextColor
                    opacity: 0.3
                }
                
                // Next prayer and countdown
                Label {
                    text: i18nc("@info", "Next: %1", nextPrayer)
                    font.bold: true
                    color: Kirigami.Theme.highlightColor
                }
                
                Label {
                    text: i18nc("@info", "Time Remaining: %1", formatCountdown(countdownSeconds))
                    font.bold: true
                }
            }
        }
        
        // Quran verse section
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: quranColumn.height
            visible: showArabic || showTranslation
            
            ColumnLayout {
                id: quranColumn
                width: parent.width
                spacing: Kirigami.Units.smallSpacing
                
                Label {
                    text: i18nc("@title", "Daily Verse")
                    font.pixelSize: Kirigami.Units.gridUnit
                    font.bold: true
                }
                
                // Arabic text
                Label {
                    visible: showArabic
                    text: arabicText
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: fontSize + 4
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                
                // Translation
                Label {
                    visible: showTranslation
                    text: translationText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                
                // Reference
                Label {
                    text: verseReference
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                    font.italic: true
                }
            }
        }
        
        // Hadith section
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: hadithColumn.height
            visible: showHadith
            
            ColumnLayout {
                id: hadithColumn
                width: parent.width
                spacing: Kirigami.Units.smallSpacing
                
                Label {
                    text: i18nc("@title", "Daily Hadith")
                    font.pixelSize: Kirigami.Units.gridUnit
                    font.bold: true
                }
                
                // Hadith text
                Label {
                    text: hadithText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                
                // Source
                Label {
                    text: hadithSource
                    font.italic: true
                }
            }
        }
        
        // Refresh button
        Button {
            text: i18nc("@action:button", "Refresh")
            icon.name: "view-refresh"
            Layout.alignment: Qt.AlignHCenter
            onClicked: updateAllData()
        }
    }
}