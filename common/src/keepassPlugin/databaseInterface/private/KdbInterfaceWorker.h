/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
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
** along with ownKeepass.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#ifndef KDBINTERFACEWORKER_H
#define KDBINTERFACEWORKER_H

#include <QObject>
#include "database/Kdb3Database.h"
#include "../KdbDatabase.h"
#include "../KdbListModel.h"

using namespace kpxPublic;

namespace kpxPrivate {

class KdbInterfaceWorker : public QObject
{
    Q_OBJECT

public:
    explicit KdbInterfaceWorker(QObject* parent = 0);
    virtual ~KdbInterfaceWorker();

signals:
    // signals to KdbDatabase object
    void databaseOpened();
    void newDatabaseCreated();
    void databaseClosed();
    void passwordChanged();
    void databaseKeyTransfRoundsChanged(int value);
    void databaseCryptAlgorithmChanged(int value);
    void errorOccured(int result, QString errorMsg);

    // signals to KdbListModel object
    void addItemToListModel(QString title, QString subtitle, int itemId, int itemType, int modelId);
    void masterGroupsLoaded(int result);
    void groupsAndEntriesLoaded(int result);
    void updateItemInListModel(QString title, QString subTitle, int itemId, int modelId);
    void deleteItemInListModel(int itemId);
    void searchEntriesCompleted(int result);

    // signal to KdbEntry object
    void entryLoaded(int entryId,
                     QString title,
                     QString url,
                     QString username,
                     QString password,
                     QString comment,
                     QString binaryDesc,
                     QString creation,
                     QString lastMod,
                     QString lastAccess,
                     QString expire,
                     quint32 binarySize,
                     QString friendlySize
                     );
    void entrySaved(int result);
    void newEntryCreated(int result, int entryId);
    void entryDeleted(int result);

    // signal to KdbGroup object
    void groupLoaded(QString title);
    void groupSaved(int result);
    void newGroupCreated(int result, int groupId);
    void groupDeleted(int result);


public slots:
    // signals from KdbDatabase object
    void slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly);
    void slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds);
    void slot_closeDatabase();
    void slot_changePassKey(QString password, QString keyFile);
    void slot_changeKeyTransfRounds(int value);
    void slot_changeCryptAlgorithm(int value);
    void slot_setting_showUserNamePasswordsInListView(bool value);

    // signal from KdbListModel object
    void slot_loadMasterGroups();
    void slot_loadGroupsAndEntries(int groupId);
    void slot_unregisterListModel(int modelId);
    void slot_searchEntries(QString searchString, int rootGroupId);

    // signal from KdbEntry object
    void slot_loadEntry(int entryId);
    void slot_saveEntry(int entryId,
                        QString title,
                        QString url,
                        QString username,
                        QString password,
                        QString comment);
    void slot_createNewEntry(QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment,
                             int parentGroupId);
    void slot_deleteEntry(int entryId);

    // signal from KdbGroup object
    void slot_loadGroup(int groupId);
    void slot_saveGroup(int groupId, QString title);
    void slot_deleteGroup(int groupId);
    void slot_createNewGroup(QString title, quint32 iconId, int parentGroupId);

private:
    void initKdbDatabase();
    void updateGrandParentGroupInListModel(IGroupHandle* parentGroup);
    inline QString getUserAndPassword(IEntryHandle* entry);

private:
    // Keepass database handler
    Kdb3Database* m_kdb3Database;

    // settings
    bool m_setting_showUserNamePasswordsInListView;

    // The following two hash tables store information about which list models are showing a dedicated entry or group in the UI
    QHash<int, int> m_entries_modelId;
    QHash<int, int> m_groups_modelId;
};

}
#endif // KDBINTERFACEWORKER_H
