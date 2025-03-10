import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    
    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property alias cfg_timezone: timezoneField.text
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_showArabic: showArabicCheckbox.checked
    property alias cfg_showTranslation: showTranslationCheckbox.checked
    property alias cfg_showHadith: showHadithCheckbox.checked
    property alias cfg_theme: themeCombo.currentText
    
    // Location settings
    TextField {
        id: cityField
        Kirigami.FormData.label: i18n("City:")
        placeholderText: i18n("Enter city name")
    }
    
    TextField {
        id: countryField
        Kirigami.FormData.label: i18n("Country:")
        placeholderText: i18n("Enter country name")
    }
    
    TextField {
        id: timezoneField
        Kirigami.FormData.label: i18n("Timezone:")
        placeholderText: i18n("e.g. America/New_York")
    }
    
    // Appearance settings
    SpinBox {
        id: fontSizeSpinBox
        Kirigami.FormData.label: i18n("Font Size:")
        from: 8
        to: 24
        value: 12
    }
    
    ComboBox {
        id: themeCombo
        Kirigami.FormData.label: i18n("Theme:")
        model: [i18n("light"), i18n("dark")]
        currentIndex: 0
    }
    
    CheckBox {
        id: showArabicCheckbox
        Kirigami.FormData.label: i18n("Show Arabic Text:")
        checked: true
    }
    
    CheckBox {
        id: showTranslationCheckbox
        Kirigami.FormData.label: i18n("Show Translation:")
        checked: true
    }
    
    CheckBox {
        id: showHadithCheckbox
        Kirigami.FormData.label: i18n("Show Hadith:")
        checked: true
    }
}