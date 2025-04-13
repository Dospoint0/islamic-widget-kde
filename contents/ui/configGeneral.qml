// ui/configGeneral.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: root
    
    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property alias cfg_timezone: timezoneField.text
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_showArabic: showArabicCheckbox.checked
    property alias cfg_showTranslation: showTranslationCheckbox.checked
    property alias cfg_showHadith: showHadithCheckbox.checked
    property alias cfg_showPrayerTimes: showPrayerTimesCheckbox.checked
    property alias cfg_theme: themeCombo.currentText
    property alias cfg_calculationMethod: calculationMethodCombo.currentIndex
    property alias cfg_fajrAngle: fajrAngleField.text
    property alias cfg_ishaAngle: ishaAngleField.text
    
    // Location settings
    TextField {
        id: cityField
        Kirigami.FormData.label: i18nc("@label:textbox", "City:")
        placeholderText: i18nc("@info:placeholder", "Enter city name")
    }
    
    TextField {
        id: countryField
        Kirigami.FormData.label: i18nc("@label:textbox", "Country:")
        placeholderText: i18nc("@info:placeholder", "Enter country name")
    }
    
    TextField {
        id: timezoneField
        Kirigami.FormData.label: i18nc("@label:textbox", "Timezone:")
        placeholderText: i18nc("@info:placeholder", "e.g. America/New_York")
    }
    
    // Prayer Times Calculation Method
    ComboBox {
        id: calculationMethodCombo
        Kirigami.FormData.label: i18nc("@label:combobox", "Calculation Method:")
        model: [
            i18nc("@item:inlistbox", "Jafari / Shia Ithna-Ashari"),
            i18nc("@item:inlistbox", "University of Islamic Sciences, Karachi"),
            i18nc("@item:inlistbox", "Islamic Society of North America"),
            i18nc("@item:inlistbox", "Muslim World League"),
            i18nc("@item:inlistbox", "Umm Al-Qura University, Makkah"),
            i18nc("@item:inlistbox", "Egyptian General Authority of Survey"),
            i18nc("@item:inlistbox", "Institute of Geophysics, University of Tehran"),
            i18nc("@item:inlistbox", "Gulf Region"),
            i18nc("@item:inlistbox", "Kuwait"),
            i18nc("@item:inlistbox", "Qatar"),
            i18nc("@item:inlistbox", "Majlis Ugama Islam Singapura, Singapore"),
            i18nc("@item:inlistbox", "Union Organization islamic de France"),
            i18nc("@item:inlistbox", "Diyanet İşleri Başkanlığı, Turkey"),
            i18nc("@item:inlistbox", "Spiritual Administration of Muslims of Russia"),
            i18nc("@item:inlistbox", "Moonsighting Committee Worldwide"),
            i18nc("@item:inlistbox", "Dubai (experimental)"),
            i18nc("@item:inlistbox", "Jabatan Kemajuan Islam Malaysia (JAKIM)"),
            i18nc("@item:inlistbox", "Tunisia"),
            i18nc("@item:inlistbox", "Algeria"),
            i18nc("@item:inlistbox", "KEMENAG - Kementerian Agama Republik Indonesia"),
            i18nc("@item:inlistbox", "Morocco"),
            i18nc("@item:inlistbox", "Comunidade Islamica de Lisboa"),
            i18nc("@item:inlistbox", "Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan"),
            i18nc("@item:inlistbox", "Custom")
        ]
        currentIndex: 2  // Default to ISNA
    }
    
    // Custom Angle Fields (only visible when "Custom" method is selected)
    TextField {
        id: fajrAngleField
        Kirigami.FormData.label: i18nc("@label:textbox", "Fajr Angle:")
        placeholderText: i18nc("@info:placeholder", "Enter angle (e.g. 15)")
        visible: calculationMethodCombo.currentIndex === 23  // Only visible when Custom is selected
        validator: DoubleValidator {
            bottom: 0
            top: 30
            decimals: 2
            notation: DoubleValidator.StandardNotation
        }
        text: "15"  // Default value
        
        // Visual feedback for validation
        Rectangle {
            anchors.fill: parent
            border.color: {
                if (fajrAngleField.text === "") return Kirigami.Theme.neutralTextColor
                return Number(fajrAngleField.text) >= 0 && Number(fajrAngleField.text) <= 30 ? 
                       Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
            }
            border.width: 1
            color: "transparent"
            radius: 2
            visible: fajrAngleField.activeFocus
        }
    }
    
    TextField {
        id: ishaAngleField
        Kirigami.FormData.label: i18nc("@label:textbox", "Isha Angle:")
        placeholderText: i18nc("@info:placeholder", "Enter angle (e.g. 15)")
        visible: calculationMethodCombo.currentIndex === 23  // Only visible when Custom is selected
        validator: DoubleValidator {
            bottom: 0
            top: 30
            decimals: 2
            notation: DoubleValidator.StandardNotation
        }
        text: "15"  // Default value
        
        // Visual feedback for validation
        Rectangle {
            anchors.fill: parent
            border.color: {
                if (ishaAngleField.text === "") return Kirigami.Theme.neutralTextColor
                return Number(ishaAngleField.text) >= 0 && Number(ishaAngleField.text) <= 30 ? 
                       Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
            }
            border.width: 1
            color: "transparent"
            radius: 2
            visible: ishaAngleField.activeFocus
        }
    }
    
    Label {
        text: i18nc("@info", "Valid angle values are between 0° and 30°")
        font.italic: true
        visible: calculationMethodCombo.currentIndex === 23  // Only visible when Custom is selected
        opacity: 0.7
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