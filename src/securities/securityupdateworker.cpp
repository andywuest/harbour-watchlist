#include "securityupdateworker.h"

SecurityUpdateWorker::~SecurityUpdateWorker() {
    qDebug() << "SecurityUpdateWorker::destroy";
    connect(this, SIGNAL(updateSecurityTokenSuccessful()), this, SLOT(handleUpdateSecurityTokenSuccessful()));
}

SecurityUpdateWorker::SecurityUpdateWorker(QObject *parent) : QThread(parent) {
    qDebug() << "Initializing SecurityUpdateWorker";
}

void SecurityUpdateWorker::setParameters(const QString &queryString) {
    this->queryString = queryString;
    this->securityTokens = queryString.split(QLatin1Char(',')); // TODO skip empty parts
    this->finished = false;
}

void SecurityUpdateWorker::updateNextSecurity() {
     qDebug() << "SecurityUpdateWorker::updateNextSecurity";

    if (this->securityTokens.size() > 0) {
        const QString token = this->securityTokens.first();
        this->securityTokens.removeFirst();
        qDebug() << "SecurityUpdateWorker::updateNextSecurity::firstToken : " << token;
        qDebug() << "SecurityUpdateWorker::updateNextSecurity::length (remaining) : " << this->securityTokens.size();
        msleep(2 * 1000);
        qDebug() << "SecurityUpdateWorker::updateNextSecurity::done : " << this->securityTokens.size();
        // emit updateSecurityTokenSuccessful();
        updateNextSecurity();
    } else {
        this->finished = true;
        // emit updateSecurityTokenFinished();
    }
}

void SecurityUpdateWorker::handleUpdateSecurityTokenSuccessful() {
    qDebug() << "SecurityUpdateWorker::handleUpdateSecurityTokenSuccessful";
    updateNextSecurity();
}

//void SecurityUpdateWorker::handleUpdateSecurityTokenFinished() {
//    qDebug() << "SecurityUpdateWorker::handleUpdateSecurityTokenFinished";
//    updateNextSecurity();
//}

void SecurityUpdateWorker::performUpdate() {
    qDebug() << "SecurityUpdateWorker::performUpdate" << this->queryString;
    QVariantList resultList;

    updateNextSecurity();

    // wait until the flag tells its finished
    while (this->finished == false) {
        msleep(100);
    }


//    if (database.open()) {
//        QSqlQuery query(database);
//        query.prepare("select * from emojis where description match (:queryString) limit 25");
//        query.bindValue(":queryString", queryString + "*");
//        query.exec();
//        while (query.next()) {
//            if (isInterruptionRequested()) {
//                break;
//            }
//            QVariantMap foundEmoji;
//            foundEmoji.insert("file_name", query.value(0).toString());
//            foundEmoji.insert("emoji", query.value(1).toString());
//            foundEmoji.insert("emoji_version", query.value(2).toString());
//            foundEmoji.insert("description", query.value(3).toString());
//            resultList.append(foundEmoji);
//        }
//        database.close();
//    } else {
//        qDebug() << "Unable to perform a query on database" << database.lastError().databaseText();
//    }

    emit securityUpdateCompleted(queryString, resultList);
}
