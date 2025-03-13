import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ColumnLayout {
    id: rootLayout
    
    // Debug section (only visible when debugMode is true)
    property bool debugMode: true
    
    Rectangle {
        Layout.fillWidth: true
        height: debugText.contentHeight + 20
        color: "#f0f0f0"
        border.color: "#cccccc"
        visible: debugMode
        
        TextArea {
            id: debugText
            anchors.fill: parent
            anchors.margins: 10
            readOnly: true
            wrapMode: TextEdit.WordWrap
            text: "Debug Log:"
            
            function log(message) {
                text = text + "\n" + message;
                console.log(message);
            }
        }
    }
    
    // The original form layout
    Kirigami.FormLayout {
        id: root
        Layout.fillWidth: true
    
    property alias cfg_city: cityCombo.currentValue
    property alias cfg_country: countryCombo.currentValue
    property alias cfg_timezone: timezoneCombo.currentValue
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_showArabic: showArabicCheckbox.checked
    property alias cfg_showTranslation: showTranslationCheckbox.checked
    property alias cfg_showHadith: showHadithCheckbox.checked
    property alias cfg_showPrayerTimes: showPrayerTimesCheckbox.checked
    property alias cfg_theme: themeCombo.currentText
    
    property var countries: []
    property var cities: []
    property var timezones: []
    
    //path to timezone json file
    readonly property string timezonesJsonPath: Qt.resolvedUrl("../timezones.json")
    
    ListModel {
        id: countryModel
    }
    
    ListModel {
        id: cityModel
    }
    
    ListModel {
        id: timezoneModel
    }

    Component.onCompleted: {
        debugText.log("Component.onCompleted called");
        debugText.log("timezonesJsonPath: " + timezonesJsonPath);
        
        // Log initial configuration values
        debugText.log("Initial cfg_country: " + cfg_country);
        debugText.log("Initial cfg_city: " + cfg_city);
        debugText.log("Initial cfg_timezone: " + cfg_timezone);
        
        loadCountries();
        debugText.log("Countries loaded, count: " + countryModel.count);
        
        loadTimezones();
        debugText.log("Started timezone loading (async)");

        //set initial values for country
        if (cfg_country && cfg_country !== "") {
            debugText.log("Setting initial country: " + cfg_country);
            for(var i = 0; i < countryModel.count; i++) {
                if (countryModel.get(i).value === cfg_country) {
                    debugText.log("Found matching country at index " + i);
                    countryCombo.currentIndex = i;
                    break;
                }
            }
        } else {
            debugText.log("No country set, using first available");
            if (countryModel.count > 0) {
                countryCombo.currentIndex = 0;
            }
        }

        loadCities(cfg_country);
        debugText.log("Cities loaded for " + cfg_country + " count: " + cityModel.count);

        Qt.callLater(function() {
            debugText.log("Setting initial city: " + cfg_city);
            if (cfg_city && cfg_city !== "") {
                for(var i = 0; i < cityModel.count; i++) {
                    if (cityModel.get(i).value === cfg_city) {
                        debugText.log("Found matching city at index " + i);
                        cityCombo.currentIndex = i;
                        break;
                    }
                }
            } else {
                debugText.log("No city set, using first available");
                if (cityModel.count > 0) {
                    cityCombo.currentIndex = 0;
                }
            }
        });
    }

    // Function to load countries
    function loadCountries() {
        // Implement your country loading logic here
        // For example:
        countryModel.clear();
        countryModel.append({text: "United States", value: "US"});
        countryModel.append({text: "Canada", value: "CA"});
        // Add more countries as needed
    }
    
    // Function to load cities based on country
    function loadCities(country) {
        // Implement your city loading logic here
        cityModel.clear();
        if (country === "US") {
            cityModel.append({text: "New York", value: "New York"});
            cityModel.append({text: "Los Angeles", value: "Los Angeles"});
            // Add more US cities
        } else if (country === "CA") {
            cityModel.append({text: "Toronto", value: "Toronto"});
            cityModel.append({text: "Vancouver", value: "Vancouver"});
            // Add more Canadian cities
        }
        // Add more country conditions as needed
    }
    
    // Function to load timezones from JSON file
    function loadTimezones() {
        console.log("Starting loadTimezones function");
        console.log("Attempting to load timezones from:", timezonesJsonPath);
        
        var xhr = new XMLHttpRequest();
        xhr.open("GET", timezonesJsonPath, true);
        
        xhr.onreadystatechange = function() {
            console.log("XHR state changed:", xhr.readyState);
            
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("XHR request complete with status:", xhr.status);
                
                if (xhr.status === 200) {
                    try {
                        console.log("Response received, first 100 chars:", xhr.responseText.substring(0, 100));
                        var data = JSON.parse(xhr.responseText);
                        console.log("JSON parsed successfully, found", data.length, "timezones");
                        
                        timezoneModel.clear();
                        console.log("Timezone model cleared");
                        
                        for (var i = 0; i < data.length; i++) {
                            var timezone = data[i];
                            timezoneModel.append({
                                text: timezone.text,
                                value: timezone.value,
                                identifier: timezone.utc && timezone.utc.length > 0 ? timezone.utc[0] : timezone.value,
                                utcZones: timezone.utc || []
                            });
                            
                            // Log every 10th timezone to avoid flooding console
                            if (i % 10 === 0 || i < 5) {
                                console.log("Added timezone:", timezone.text, "with identifier:", timezone.utc && timezone.utc.length > 0 ? timezone.utc[0] : timezone.value);
                            }
                        }
                        
                        console.log("Total timezones loaded into model:", timezoneModel.count);
                        
                        // After loading timezones, set the initial timezone
                        console.log("Calling setInitialTimezone");
                        Qt.callLater(setInitialTimezone);
                    } catch (e) {
                        console.error("Error parsing timezone JSON:", e);
                        console.log("First 100 chars of response that failed to parse:", xhr.responseText.substring(0, 100));
                    }
                } else {
                    console.error("Failed to load timezones.json. Status:", xhr.status, "Status text:", xhr.statusText);
                }
            }
        };
        
        xhr.onerror = function() {
            console.error("Network error occurred when trying to fetch timezones.json");
        };
        
        console.log("Sending XHR request");
        xhr.send();
    }

    // Get the local timezone
    function getLocalTimezone() {
        debugText.log("getLocalTimezone called");
        // This returns the local timezone in IANA format (e.g., "America/New_York")
        var now = new Date();
        // Get timezone offset in minutes
        var timezoneOffset = -now.getTimezoneOffset();
        // Convert to hours
        var offsetHours = Math.floor(Math.abs(timezoneOffset) / 60);
        // Format offset string
        var offsetString = (timezoneOffset >= 0 ? "+" : "-") + 
                        String(offsetHours).padStart(2, "0") + ":00";
        
        debugText.log("Local timezone offset: " + offsetString);
        
        // Find matching timezone in our model
        for (var i = 0; i < timezoneModel.count; i++) {
            var item = timezoneModel.get(i);
            if (item.text.indexOf(offsetString) !== -1) {
                debugText.log("Found matching timezone by offset: " + item.identifier);
                return item.identifier;
            }
        }
        
        // Fallback to system locale information if available
        var localeTimeZone = Qt.locale().timeZoneId || "UTC";
        debugText.log("Falling back to locale timezone: " + localeTimeZone);
        return localeTimeZone;
    }

    function setInitialTimezone() {
        debugText.log("setInitialTimezone called, current cfg_timezone: " + cfg_timezone);
        debugText.log("Current timezoneModel count: " + timezoneModel.count);
        
        if (!cfg_timezone || cfg_timezone === "") {
            cfg_timezone = getLocalTimezone();
            debugText.log("No timezone set, using local timezone: " + cfg_timezone);
        }
        
        // Find the index of the timezone in the model
        var found = false;
        for (var i = 0; i < timezoneModel.count; i++) {
            var item = timezoneModel.get(i);
            debugText.log("Checking timezone at index " + i + ": " + item.identifier + " vs " + cfg_timezone);
            
            if (item.identifier === cfg_timezone || 
                item.value === cfg_timezone || 
                (item.utcZones && item.utcZones.indexOf(cfg_timezone) !== -1)) {
                debugText.log("Found matching timezone at index " + i);
                timezoneCombo.currentIndex = i;
                found = true;
                break;
            }
        }
        
        if (!found) {
            debugText.log("Could not find matching timezone for: " + cfg_timezone);
            if (timezoneModel.count > 0) {
                debugText.log("Setting to first available timezone");
                timezoneCombo.currentIndex = 0;
            }
        }
    }

    ComboBox {
        id: countryCombo
        Kirigami.FormData.label: i18nc("@label:listbox", "Country:")
        model: countryModel
        textRole: "text"
        valueRole: "value"
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var selectedCountry = model.get(currentIndex).value;
                loadCities(selectedCountry);
                
                // Reset city selection
                cityCombo.currentIndex = 0;
            }
        }
    }

    ComboBox {
        id: cityCombo
        Kirigami.FormData.label: i18nc("@label:listbox", "City:")
        model: cityModel
        textRole: "text"
        valueRole: "value"
    }

    ComboBox {
        id: timezoneCombo
        Kirigami.FormData.label: i18nc("@label:listbox", "Timezone:")
        model: timezoneModel
        textRole: "text"
        valueRole: "value"
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var tzItem = model.get(currentIndex);
                
                // Use the first UTC timezone as the value to save if available
                if (tzItem.utcZones && tzItem.utcZones.length > 0) {
                    cfg_timezone = tzItem.utcZones[0];
                } else if (tzItem.identifier) {
                    cfg_timezone = tzItem.identifier;
                } else {
                    cfg_timezone = tzItem.value;
                }
            }
        }
    }

    // Appearance settings
    SpinBox {
        id: fontSizeSpinBox
        Kirigami.FormData.label: i18nc("@label:spinbox", "Font Size:")
        from: 8
        to: 24
        value: 12
    }
    
    ComboBox {
        id: themeCombo
        Kirigami.FormData.label: i18nc("@label:combobox", "Theme:")
        model: [i18nc("@item:inlistbox", "light"), i18nc("@item:inlistbox", "dark")]
        currentIndex: 0
    }
    
    CheckBox {
        id: showArabicCheckbox
        Kirigami.FormData.label: i18nc("@option:check", "Show Arabic Text:")
        checked: true
    }
    
    CheckBox {
        id: showTranslationCheckbox
        Kirigami.FormData.label: i18nc("@option:check", "Show Translation:")
        checked: true
    }
    
    CheckBox {
        id: showHadithCheckbox
        Kirigami.FormData.label: i18nc("@option:check", "Show Hadith:")
        checked: true
    }

    CheckBox {
        id: showPrayerTimesCheckbox
        Kirigami.FormData.label: i18nc("@option:check", "Show Prayer Times:")
        checked: true
    }
    
    RowLayout {
        Layout.fillWidth: true
        visible: debugMode
        
        Button {
            text: "Refresh Timezones"
            onClicked: {
                debugText.log("Manual refresh of timezones requested");
                loadTimezones();
            }
        }
        
        Button {
            text: "Clear Debug Log"
            onClicked: {
                debugText.text = "Debug Log:";
            }
        }
        }
    }
}