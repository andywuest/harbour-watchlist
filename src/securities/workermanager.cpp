#include "workermanager.h"

WorkerManager::WorkerManager(QObject *parent) : QObject(parent) {
  connect(&securityUpdateWorker, SIGNAL(securityUpdateCompleted(QString, QVariantList)), this, SLOT(handleSecurityUpdateCompleted(QString, QVariantList)));
}

void WorkerManager::handleSecurityUpdateCompleted(const QString &queryString, const QVariantList &resultList) {
  qDebug() << "WorkerManager::handleSecurityUpdateCompleted" << queryString;
  emit securityUpdateSuccessful(resultList);
}

void WorkerManager::updateSecurity(const QString &queryString)
{
    qDebug() << "WorkerManager::updateSecurity" << queryString;
    while (this->securityUpdateWorker.isRunning()) {
        this->securityUpdateWorker.requestInterruption();
    }
    qDebug() << "WorkerManager::startingWorker" << queryString;
    this->securityUpdateWorker.setParameters(queryString);
    this->securityUpdateWorker.start();
}
