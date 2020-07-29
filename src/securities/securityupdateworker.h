#ifndef SECURITYUPDATEWORKER_H
#define SECURITYUPDATEWORKER_H

#include <QObject>
#include <QThread>
#include <QDebug>

class SecurityUpdateWorker : public QThread
{
    Q_OBJECT
     void run() Q_DECL_OVERRIDE {
         performUpdate();
     }

public:
    //SecurityUpdateWorker();
    ~SecurityUpdateWorker();
    explicit SecurityUpdateWorker(QObject *parent = 0);
    void setParameters(const QString &queryString);

signals:
    void securityUpdateCompleted(const QString &queryString, const QVariantList &resultList);
    void updateSecurityTokenSuccessful();
//    void updateSecurityTokenFinished();

public slots:
    void handleUpdateSecurityTokenSuccessful();
  //  void handleUpdateSecurityTokenFinished();

private:
    QString queryString;
    QStringList securityTokens;
    bool finished = false;

    void performUpdate();

    void updateNextSecurity();
};

#endif // SECURITYUPDATEWORKER_H
