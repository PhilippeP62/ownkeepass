/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.ownkeepass.KeepassX1 1.0
import "../scripts/Global.js" as Global
import "../common"

Dialog {
    id: editSettingsDialog

    // save cover state because database settings page can be opened from various
    // pages like list view or edit dialogs, which have different cover states
    property string saveCoverState: ""
    property string saveCoverTitle: ""
    property bool defaultCryptAlgorithmChanged: false
    property bool defaultKeyTransfRoundsChanged: false
    property bool inactivityLockTimeChanged: false
    property bool fastUnlockChanged: false
    property bool fastUnlockRetryCountChanged: false
    property bool showUserNamePasswordInListViewChanged: false
    property bool focusSearchBarOnStartupChanged: false
    property bool showUserNamePasswordOnCoverChanged: false
    property bool lockDatabaseFromCoverChanged: false
    property bool copyNpasteFromCoverChanged: false
    property bool clearClipboardChanged: false
    property bool expertModeChanged: false
    property bool languageChanged: false

    function updateCoverState() {
        if (saveCoverState === "") // save initial state
            saveCoverState = applicationWindow.cover.state
        if (saveCoverTitle === "") // save initial state
            saveCoverTitle = applicationWindow.cover.title
        if (expertModeChanged || defaultCryptAlgorithmChanged || defaultKeyTransfRoundsChanged ||
                inactivityLockTimeChanged || fastUnlockChanged || fastUnlockRetryCountChanged ||
                showUserNamePasswordInListViewChanged || focusSearchBarOnStartupChanged ||
                showUserNamePasswordOnCoverChanged || lockDatabaseFromCoverChanged ||
                copyNpasteFromCoverChanged || clearClipboardChanged || languageChanged) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
            applicationWindow.cover.title = "Settings"
        } else {
            applicationWindow.cover.state = saveCoverState
            applicationWindow.cover.title = saveCoverTitle
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        ApplicationMenu {
            helpContent: "Settings"
            disableSettingsItem: true
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
                title: qsTr("ownKeepass Settings")
            }

            SilicaLabel {
                text: qsTr("Change default settings of your ownKeepass application here")
            }

            SectionHeader {
                text: qsTr("Database")
            }

            Column {
                width: parent.width
                spacing: 0

                SilicaLabel {
                    text: qsTr("This is the encryption which will be used as default when creating a new Keepass database:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                ComboBox {
                    id: defaultCryptAlgorithm
                    width: editSettingsDialog.width
                    label: qsTr("Default encryption:")
                    currentIndex: ownKeepassSettings.defaultCryptAlgorithm
                    menu: ContextMenu {
                        MenuItem { text: "AES/Rijndael" }
                        MenuItem { text: "Twofish" }
                    }
                    onCurrentIndexChanged: {
                        editSettingsDialog.defaultCryptAlgorithmChanged =
                                defaultCryptAlgorithm.currentIndex !== ownKeepassSettings.defaultCryptAlgorithm
                        editSettingsDialog.updateCoverState()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 0

                TextField {
                    id: defaultKeyTransfRounds
                    width: parent.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: RegExpValidator { regExp: /^[0-9]*$/ }
                    errorHighlight: Number(text) === 0
                    label: qsTr("Default key transformation rounds")
                    placeholderText: label
                    text: String(ownKeepassSettings.defaultKeyTransfRounds)
                    EnterKey.enabled: !errorHighlight
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editSettingsDialog.defaultKeyTransfRoundsChanged =
                                Number(defaultKeyTransfRounds.text) !== ownKeepassSettings.defaultKeyTransfRounds
                        editSettingsDialog.updateCoverState()
                    }
                }

                SilicaLabel {
                    text: qsTr("Setting this value higher increases opening time of the Keepass database but makes it more robust against brute force attacks")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: qsTr("Security")
            }

            Slider {
                id: inactivityLockTime
                value: ownKeepassSettings.locktime
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                valueText: calculateInactivityTime(value)
                label: qsTr("Inactivity lock time")
                /*
                  0 = immediately
                  1 = 5 seconds
                  2 = 10 seconds
                  3 = 30 seconds
                  4 = 1 minute
                  5 = 2 minutes
                  6 = 5 minutes
                  7 = 10 minutes
                  8 = 30 minutes
                  9 = 60 minutes
                  10 = unlimited
                  */
                function calculateInactivityTime(value) {
                    switch (value) {
                    case 0:
                        return qsTr("Immediately")
                    case 1:
                        return "5 " + qsTr("seconds")
                    case 2:
                        return "10 " + qsTr("seconds")
                    case 3:
                        return "30 " + qsTr("seconds")
                    case 4:
                        return "1 " + qsTr("minute")
                    case 5:
                        return "2 " + qsTr("minutes")
                    case 6:
                        return "5 " + qsTr("minutes")
                    case 7:
                        return "10 " + qsTr("minutes")
                    case 8:
                        return "30 " + qsTr("minutes")
                    case 9:
                        return "60 " + qsTr("minutes")
                    case 10:
                        return qsTr("Unlimited")
                    }
                }
                onValueChanged: {
                    editSettingsDialog.inactivityLockTimeChanged = inactivityLockTime.value !== ownKeepassSettings.locktime
                    editSettingsDialog.updateCoverState()
                }
            }

            Column {
                width: parent.width
                height: fastUnlockRetryCount.enabled ? fastUnlock.height + fastUnlockRetryCount.height : fastUnlock.height
                spacing: 0

                Behavior on height { NumberAnimation { duration: 500 } }

                TextSwitch {
                    id: fastUnlock
                    checked: ownKeepassSettings.fastUnlock
                    text: qsTr("Fast unlock")
                    description: qsTr("Enable this to unlock your database quickly with just the first 3 characters of your master password.")
                    onCheckedChanged: {
                        editSettingsDialog.fastUnlockChanged = fastUnlock.checked !== ownKeepassSettings.fastUnlock
                        editSettingsDialog.updateCoverState()
                    }
                }

                Slider {
                    id: fastUnlockRetryCount
                    enabled: fastUnlock.checked
                    opacity: enabled ? 1.0 : 0.0
                    value: ownKeepassSettings.fastUnlockRetryCount
                    minimumValue: 0
                    maximumValue: 5
                    stepSize: 1
                    width: parent.width - Theme.paddingLarge * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    valueText: value
                    label: qsTr("Number of fast unlock retries")
                    onValueChanged: {
                        editSettingsDialog.fastUnlockRetryCountChanged = fastUnlockRetryCount.value !== ownKeepassSettings.fastUnlockRetryCount
                        editSettingsDialog.updateCoverState()
                    }

                    Behavior on opacity { FadeAnimation { duration: 500 } }
                }
            }

            TextSwitch {
                id: clearClipboard
                checked: ownKeepassSettings.clearClipboard !== 0
                text: qsTr("Clear clipboard")
                description: qsTr("If enabled the clipboard will be cleared after 10 seconds when username or password is copied")
                onCheckedChanged: {
                    // This workaround makes it possible to replace this simple switch later with a slider setting which will control timer value
                    var clearClipboardTimer = clearClipboard.checked ? 10 : 0
                    editSettingsDialog.clearClipboardChanged = clearClipboardTimer !== ownKeepassSettings.clearClipboard
                    editSettingsDialog.updateCoverState()
                }
            }

            SectionHeader {
                text: qsTr("UI settings")
            }

            TextSwitch {
                id: showUserNamePasswordInListView
                checked: ownKeepassSettings.showUserNamePasswordInListView
                text: qsTr("Extended list liew")
                description: qsTr("If you switch this on username and password are shown below entry title in list views")
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordInListViewChanged =
                            showUserNamePasswordInListView.checked !== ownKeepassSettings.showUserNamePasswordInListView
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: focusSearchBarOnStartup
                checked: ownKeepassSettings.focusSearchBarOnStartup
                text: qsTr("Focus search bar")
                description: qsTr("If enabled the search bar will be focused on application startup")
                onCheckedChanged: {
                    editSettingsDialog.focusSearchBarOnStartupChanged =
                            focusSearchBarOnStartup.checked !== ownKeepassSettings.focusSearchBarOnStartup
                    editSettingsDialog.updateCoverState()
                }
            }

            Column {
                width: parent.width
                spacing: 0

                ComboBox {
                    id: language
                    width: editSettingsDialog.width
                    label: qsTr("Language:")
                    currentIndex: toCurrentIndex(ownKeepassSettings.language)
                    menu: ContextMenu {
                        MenuItem { text: "System default" } // 0
                        MenuItem { text: "Catalan" } // 1
                        MenuItem { text: "Chinese" } // 2
                        MenuItem { text: "Czech" } // 3
                        MenuItem { text: "Danish (partly)" } // 4
                        MenuItem { text: "Dutch" } // 5
                        MenuItem { text: "English" } // 6
                        MenuItem { text: "Finnish" } // 7
                        MenuItem { text: "French " } // 8
                        MenuItem { text: "German" } // 9
                        MenuItem { text: "Italian" } // 10
                        MenuItem { text: "Norwegian Bokmål (partly)" } // 11
//                        MenuItem { text: "Polish" } // -1 -- not yet started
                        MenuItem { text: "Russian" } // 12
                        MenuItem { text: "Spanish" }  // 13
                        MenuItem { text: "Swedish" } // 14
//                        MenuItem { text: "Ukrainian" } // -1 -- not yet started
                    }

                    // The next two converter functions decouple the alphabetic language list
                    // index from the internal settings index, which cannot be changed for legacy reasons
                    function toCurrentIndex(value) {
                        console.log("Lang de: " + Languages.DE_DE)
                        switch (value) {
                        case Languages.SYSTEM_DEFAULT:
                            return Global.system_default
                        case Languages.EN_GB: // English
                            return Global.english
                        case Languages.SV_SE: // Swedish
                            return Global.swedish
                        case Languages.FI_FI: // Finnish
                            return Global.finnish
                        case Languages.DE_DE: // German
                            return Global.german
                        case Languages.CS_CZ: // Czech
                            return Global.czech
                        case Languages.CA: // Catalan
                            return Global.catalan
                        case Languages.NL_NL: // Dutch
                            return Global.dutch
                        case Languages.ES: // Spanish
                            return Global.spanish
                        case Languages.FR_FR: // French
                            return Global.french
                        case Languages.IT: // Itanian
                            return Global.italian
                        case Languages.RU: // Russian
                            return Global.russian
                        case Languages.DA: // Danish
                            return Global.danish
                        case Languages.PL_PL: // Polish
                            return Global.polish
                        case Languages.ZH_CN: // Chinese
                            return Global.chinese
                        case Languages.UK_UA: // Ukrainian
                            return Global.ukrainian
                        case Languages.NB_NO: // Norwegian Bokmål
                            return Global.norwegian_bokmal
                        default:
                            return Global.english
                        }
                    }

                    function toSettingsIndex(value) {
                        switch (value) {
                        case Global.system_default:
                            return Languages.SYSTEM_DEFAULT
                        case Global.english:
                            return Languages.EN_GB // English
                        case Global.swedish:
                            return Languages.SV_SE // Swedish
                        case Global.finnish:
                            return Languages.FI_FI // Finnish
                        case Global.german:
                            return Languages.DE_DE // German
                        case Global.czech:
                            return Languages.CS_CZ // Czech
                        case Global.catalan:
                            return Languages.CA // Catalan
                        case Global.dutch:
                            return Languages.NL_NL // Dutch
                        case Global.spanish:
                            return Languages.ES // Spanish
                        case Global.french:
                            return Languages.FR_FR // French
                        case Global.italian:
                            return Languages.IT // Itanian
                        case Global.russian:
                            return Languages.RU // Russian
                        case Global.danish:
                            return Languages.DA // Danish
                        case Global.polish:
                            return Languages.PL_PL // Polish
                        case Global.chinese:
                            return Languages.ZH_CN // Chinese
                        case Global.ukrainian:
                            return Languages.UK_UA // Ukrainian
                        case Global.norwegian_bokmal:
                            return Languages.NB_NO // Norwegian Bokmål
                        default:
                            return Languages.EN_GB // English
                        }
                    }

                    onCurrentIndexChanged: {
                        editSettingsDialog.languageChanged =
                                toSettingsIndex(language.currentIndex) !== ownKeepassSettings.language
                        editSettingsDialog.updateCoverState()
                    }
                }

                SilicaLabel {
                    text: qsTr("Change of language will be active in ownKeepass after restarting the application")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: qsTr("Cover settings")
            }

            TextSwitch {
                id: showUserNamePasswordOnCover
                checked: ownKeepassSettings.showUserNamePasswordOnCover
                text: qsTr("Show username and password")
                description: qsTr("Switching this on will show username and password of the currently opened Keepass entry on the cover")
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordOnCoverChanged =
                            showUserNamePasswordOnCover.checked !== ownKeepassSettings.showUserNamePasswordOnCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: lockDatabaseFromCover
                checked: ownKeepassSettings.lockDatabaseFromCover
                text: qsTr("Lock database from cover")
                description: qsTr("This lets you lock the database with the left cover action")
                onCheckedChanged: {
                    editSettingsDialog.lockDatabaseFromCoverChanged =
                            lockDatabaseFromCover.checked !== ownKeepassSettings.lockDatabaseFromCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: copyNpasteFromCover
                checked: ownKeepassSettings.copyNpasteFromCover
                text: qsTr("Copy'n'paste from cover")
                description: qsTr("Enable this to copy username and password into clipboard from cover")
                onCheckedChanged: {
                    editSettingsDialog.copyNpasteFromCoverChanged =
                            copyNpasteFromCover.checked !== ownKeepassSettings.copyNpasteFromCover
                    editSettingsDialog.updateCoverState()
                }
            }
/*
            SectionHeader {
                text: qsTr("Advanced settings")
            }

            TextSwitch {
                id: expertMode
                checked: !ownKeepassSettings.simpleMode
                text: qsTr("Expert user mode")
                description: qsTr("This enables advanced functionality like handling multiple databases on main page")
                onCheckedChanged: {
                    expertModeChanged = checked === ownKeepassSettings.simpleMode
                    updateCoverState()
                }
            }
*/
        }
    }

    onAccepted: {
        // First save locally ownKeepass settings then trigger saving
        kdbListItemInternal.setKeepassSettings(
                    defaultCryptAlgorithm.currentIndex,
                    Number(defaultKeyTransfRounds.text),
                    inactivityLockTime.value,
                    showUserNamePasswordInListView.checked,
                    focusSearchBarOnStartup.checked,
                    showUserNamePasswordOnCover.checked,
                    lockDatabaseFromCover.checked,
                    copyNpasteFromCover.checked,
                    clearClipboard.checked ? 10 : 0,
                    language.toSettingsIndex(language.currentIndex),
                    fastUnlock.checked,
                    fastUnlockRetryCount.value)
        kdbListItemInternal.saveKeepassSettings()
    }

    onRejected: {
        // Save ownKeepass settings to check for unsaved changes
        kdbListItemInternal.setKeepassSettings(
                    defaultCryptAlgorithm.currentIndex,
                    Number(defaultKeyTransfRounds.text),
                    inactivityLockTime.value,
                    showUserNamePasswordInListView.checked,
                    focusSearchBarOnStartup.checked,
                    showUserNamePasswordOnCover.checked,
                    lockDatabaseFromCover.checked,
                    copyNpasteFromCover.checked,
                    clearClipboard.checked ? 10 : 0,
                    language.toSettingsIndex(language.currentIndex),
                    fastUnlock.checked,
                    fastUnlockRetryCount.value)
        kdbListItemInternal.checkForUnsavedKeepassSettingsChanges()
    }
}
