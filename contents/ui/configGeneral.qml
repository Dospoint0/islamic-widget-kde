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
    property alias cfg_theme: themeCombo.currentText
    
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
}