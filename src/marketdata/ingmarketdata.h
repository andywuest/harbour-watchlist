#ifndef INGMARKETDATA_H
#define INGMARKETDATA_H

#include <QObject>

class IngMarketData {
public:
    IngMarketData(const QString extRefId, const QString internalId, const QString indexName);

    QString getExtRefId() const;
    QString getInternalId() const;
    QString getIndexName() const;

private:
    QString extRefId;
    QString internalId;
    QString indexName;
};

#endif // INGMARKETDATA_H
