// ui/configGeneral.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: root
    
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
        loadCountries();
        loadTimezones();

        //set initial values
        for(var i = 0; i < countryModel.count; i++) {
            if (countryModel.get(i).value === cfg_country) {
                countryCombo.currentIndex = i;
                break;
            }
        }

        loadCities(cfg_country);

        Qt.callLater(function() {
            for(var i = 0; i < cityModel.count; i++) {
                if (cityModel.get(i).value === cfg_city) {
                    cityCombo.currentIndex = i;
                    break;
                }
            }
        });

        setInitialTimezone();
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
    
    // Function to load timezones
    function loadTimezones() {
        // Implement your timezone loading logic here
        timezoneModel.clear();
        timezoneModel.append({text: "UTC-08:00 (Pacific Time)", value: "America/Los_Angeles", identifier: "America/Los_Angeles", utcZones: ["America/Los_Angeles"]});
        timezoneModel.append({text: "UTC-05:00 (Eastern Time)", value: "America/New_York", identifier: "America/New_York", utcZones: ["America/New_York"]});
        // Add more timezones as needed
    }

    // Get the local timezone
    function getLocalTimezone() {
        // This returns the local timezone in IANA format (e.g., "America/New_York")
        var now = new Date();
        // Get timezone offset in minutes
        var timezoneOffset = -now.getTimezoneOffset();
        // Convert to hours
        var offsetHours = Math.floor(Math.abs(timezoneOffset) / 60);
        // Format offset string
        var offsetString = (timezoneOffset >= 0 ? "+" : "-") + 
                        String(offsetHours).padStart(2, "0") + ":00";
        
        // Find matching timezone in our model
        for (var i = 0; i < timezoneModel.count; i++) {
            var item = timezoneModel.get(i);
            if (item.text.indexOf(offsetString) !== -1) {
                return item.identifier;
            }
        }
        
        // Fallback to system locale information if available
        return Qt.locale().timeZoneId || "UTC";
    }

    function setInitialTimezone() {
        if (!cfg_timezone || cfg_timezone === "") {
            cfg_timezone = getLocalTimezone();
        }
        
        // Find the index of the timezone in the model
        for (var i = 0; i < timezoneModel.count; i++) {
            if (timezoneModel.get(i).identifier === cfg_timezone || 
                timezoneModel.get(i).value === cfg_timezone) {
                timezoneCombo.currentIndex = i;
                break;
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
}