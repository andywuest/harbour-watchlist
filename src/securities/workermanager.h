#ifndef WORKERMANAGER_H
#define WORKERMANAGER_H

#include <QObject>
#include "securityupdateworker.h"

class WorkerManager : public QObject
{
    Q_OBJECT
public:
    explicit WorkerManager(QObject *parent = nullptr);

    Q_INVOKABLE void updateSecurity(const QString &queryString);

signals:
    void securityUpdateSuccessful(const QVariantList &result);

public slots:
    void handleSecurityUpdateCompleted(const QString &queryString, const QVariantList &resultList);

private:
    SecurityUpdateWorker securityUpdateWorker;

};

#endif // WORKERMANAGER_H
