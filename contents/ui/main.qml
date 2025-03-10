import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    
    // Plasmoid configuration
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    // Config properties from plasmoid configuration
    property string cityName: Plasmoid.configuration.city || "New York"
    property string countryName: Plasmoid.configuration.country || "United States"
    property string timezone: Plasmoid.configuration.timezone || getLocalTimezone()
    property int fontSize: Plasmoid.configuration.fontSize || 12
    property bool showArabic: Plasmoid.configuration.showArabic === undefined ? true : Plasmoid.configuration.showArabic
    property bool showTranslation: Plasmoid.configuration.showTranslation === undefined ? true : Plasmoid.configuration.showTranslation
    property bool showHadith: Plasmoid.configuration.showHadith === undefined ? true : Plasmoid.configuration.showHadith
    property string theme: Plasmoid.configuration.theme || "light"
    
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
    property string arabicText: i18n("Loading verse...")
    property string translationText: i18n("Loading translation...")
    property string verseReference: i18n("Surah --:--")
    
    // Hadith data
    property string hadithText: i18n("Loading hadith...")
    property string hadithSource: i18n("Source: --")
    
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
                        nextPrayer = i18n("API Error");
                        countdownSeconds = 0;
                    }
                } else {
                    nextPrayer = i18n("Connection Error");
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
                    
                    nextPrayer = "Fajr (Tomorrow)";
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
                    verseReference = i18n("Surah %1 (%2)", verse.surah.englishName, verse.numberInSurah);
                    
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
                    hadithSource = i18n("Source: Sahih al-Bukhari %1", hadith.hadith_number || "");
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
    
    // Full representation (expanded widget)
    Plasmoid.fullRepresentation: Item {
        Layout.preferredWidth: units.gridUnit * 24
        Layout.preferredHeight: units.gridUnit * 36
        
        // Apply theme
        PlasmaCore.ColorScope {
            id: colorScope
            colorGroup: theme === "dark" ? PlasmaCore.Theme.ComplementaryColorGroup : PlasmaCore.Theme.NormalColorGroup
            
            anchors.fill: parent
            
            // Main layout
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.smallSpacing
                spacing: units.largeSpacing
                
                // Header
                PlasmaComponents.Label {
                    text: i18n("Islamic Widget")
                    font.pixelSize: units.gridUnit * 1.2
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
                        spacing: units.smallSpacing
                        
                        PlasmaComponents.Label {
                            text: i18n("Prayer Times")
                            font.pixelSize: units.gridUnit
                            font.bold: true
                        }
                        
                        // Prayer times grid
                        GridLayout {
                            columns: 2
                            Layout.fillWidth: true
                            columnSpacing: units.largeSpacing
                            
                            // Fajr
                            PlasmaComponents.Label {
                                text: i18n("Fajr:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Fajr'] ? Qt.formatTime(prayerTimes['Fajr'], "hh:mm") : "--:--"
                                color: nextPrayer === "Fajr" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Fajr"
                            }
                            
                            // Sunrise
                            PlasmaComponents.Label {
                                text: i18n("Sunrise:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Sunrise'] ? Qt.formatTime(prayerTimes['Sunrise'], "hh:mm") : "--:--"
                                color: nextPrayer === "Sunrise" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Sunrise"
                            }
                            
                            // Dhuhr
                            PlasmaComponents.Label {
                                text: i18n("Dhuhr:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Dhuhr'] ? Qt.formatTime(prayerTimes['Dhuhr'], "hh:mm") : "--:--"
                                color: nextPrayer === "Dhuhr" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Dhuhr"
                            }
                            
                            // Asr
                            PlasmaComponents.Label {
                                text: i18n("Asr:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Asr'] ? Qt.formatTime(prayerTimes['Asr'], "hh:mm") : "--:--"
                                color: nextPrayer === "Asr" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Asr"
                            }
                            
                            // Maghrib
                            PlasmaComponents.Label {
                                text: i18n("Maghrib:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Maghrib'] ? Qt.formatTime(prayerTimes['Maghrib'], "hh:mm") : "--:--"
                                color: nextPrayer === "Maghrib" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Maghrib"
                            }
                            
                            // Isha
                            PlasmaComponents.Label {
                                text: i18n("Isha:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Isha'] ? Qt.formatTime(prayerTimes['Isha'], "hh:mm") : "--:--"
                                color: nextPrayer === "Isha" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Isha"
                            }
                            
                            // Midnight
                            PlasmaComponents.Label {
                                text: i18n("Midnight:")
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: prayerTimes['Midnight'] ? Qt.formatTime(prayerTimes['Midnight'], "hh:mm") : "--:--"
                                color: nextPrayer === "Midnight" ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
                                font.bold: nextPrayer === "Midnight"
                            }
                        }
                        
                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: PlasmaCore.Theme.disabledTextColor
                            opacity: 0.3
                        }
                        
                        // Next prayer and countdown
                        PlasmaComponents.Label {
                            text: i18n("Next: %1", nextPrayer)
                            font.bold: true
                            color: PlasmaCore.Theme.highlightColor
                        }
                        
                        PlasmaComponents.Label {
                            text: i18n("Time Remaining: %1", formatCountdown(countdownSeconds))
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
                        spacing: units.smallSpacing
                        
                        PlasmaComponents.Label {
                            text: i18n("Daily Verse")
                            font.pixelSize: units.gridUnit
                            font.bold: true
                        }
                        
                        // Arabic text
                        PlasmaComponents.Label {
                            visible: showArabic
                            text: arabicText
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: fontSize + 4
                            font.bold: true
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        
                        // Translation
                        PlasmaComponents.Label {
                            visible: showTranslation
                            text: translationText
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        
                        // Reference
                        PlasmaComponents.Label {
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
                        spacing: units.smallSpacing
                        
                        PlasmaComponents.Label {
                            text: i18n("Daily Hadith")
                            font.pixelSize: units.gridUnit
                            font.bold: true
                        }
                        
                        // Hadith text
                        PlasmaComponents.Label {
                            text: hadithText
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        
                        // Source
                        PlasmaComponents.Label {
                            text: hadithSource
                            font.italic: true
                        }
                    }
                }
                
                // Refresh button
                PlasmaComponents.Button {
                    text: i18n("Refresh")
                    icon.name: "view-refresh"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: updateAllData()
                }
            }
        }
    }
}