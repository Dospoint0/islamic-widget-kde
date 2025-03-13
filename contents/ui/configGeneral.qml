// ui/configGeneral.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: root
    
    //property alias cfg_city: cityField.text
    //property alias cfg_country: countryField.text
    //property alias cfg_timezone: timezoneField.text
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_showArabic: showArabicCheckbox.checked
    property alias cfg_showTranslation: showTranslationCheckbox.checked
    property alias cfg_showHadith: showHadithCheckbox.checked
    property alias cfg_showPrayerTimes: showPrayerTimesCheckbox.checked
    property alias cfg_theme: themeCombo.currentText
    property string cfg_city
    property string cfg_country
    property string cfg_timezone

    property var countries: []
    property var cities: []
    property var timezones: []
    
    //path to timezone json file
    readonly property string timezonesJsonPath: Qt.resolvedUrl("../timezones.json")
    // Location settings

    Component.onCompleted: {
        loadCountries();
        
        loadTimezones();

        //set initial values
        for(var i = 0; i<countryModel.count; i++) {
            if (countryModel.get(i).value === cfg_country) {
                countryCombo.currentIndex = i;
                break;
            }
        }

        loadCities(cfg_country);

        Qt.callLater(function() {
            for(var i = 0; i<cityModel.count; i++) {
                if (cityModel.get(i).value === cfg_city) {
                    cityCombo.currentIndex = i;
                    break;
                }
            }
        });

        setInitialTimezone();

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

    function setInitialTimezone(){
        cfg_timezone = getLocalTimezone();
        i = timezoneCombo.find(cfg_timezone);
        timezoneCombo.currentIndex = cfg_timezone;
    }

    
    // Set the default timezone if none is configured
    if (!cfg_timezone || cfg_timezone === "") {
        cfg_timezone = getLocalTimezone();
    }

    TextBox {
        id: countryText
        Kirigami.FormData.label: i18nc("@label:textbox", "Country:")
        model: countryModel
        textRole: "text"
        /*currentIndex: -1
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var selectedCountry = countryModel.get(currentIndex).value;
                cfg_country = selectedCountry;
                loadCities(selectedCountry);
                
                // Reset city selection
                cityCombo.currentIndex = 0;
            }
        }*/
    }

    ComboBox {
        id: timezoneCombo
        Kirigami.FormData.label: i18nc("@label:listbox", "Timezone:")
        model: timezoneModel
        textRole: "text"
        currentIndex: -1
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var tzItem = timezoneModel.get(currentIndex);
                
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
    // Load cities based on the selected country
    
    TextBox {
        id: cityText
        Kirigami.FormData.label: i18nc("@label:textbox", "City:")
        model: cityModel
        textRole: "text"
        /*
        currentIndex: -1
        onCurrentIndexChanged: {
            if (currentIndex >= 0 && cityModel.count > 0) {
                cfg_city = cityModel.get(currentIndex).value;
            }
        }*/
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

