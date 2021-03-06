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

#include "KdbInterface.h"

using namespace kpxPrivate;

// Global static pointer used to ensure a single instance of the class
// It is used by KdbDatabase, KdbListModel, KdbGroup and KdbEntry classes to access data of the Keepass database
KdbInterface* KdbInterface::m_Instance = new KdbInterface;

KdbInterface::KdbInterface(QObject *parent)
    : QObject(parent),
      m_workerThread(),
      m_worker() // worker has got no parent because it must be moved to another thread.
{
    m_worker.moveToThread(&m_workerThread);
    m_workerThread.start();
}

KdbInterface::~KdbInterface()
{
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }
}

KdbInterface* KdbInterface::getInstance()
{
//    if (NULL == m_Instance) new KdbInterface;
    Q_ASSERT(m_Instance);
    return m_Instance;
}
