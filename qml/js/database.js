// .pragma library

Qt.include("constants.js")

var SORT_BY_NAME = " name ASC ";
var SORT_BY_CHANGE_ASC = " changeRelative ASC ";
var SORT_BY_CHANGE_DESC = " changeRelative DESC ";

function getOpenDatabase() {
    var db = LocalStorage.openDatabaseSync(
                "WatchlistApp", "1.0",
                "Database for the WatchlistApp!", 10000000)
    return db
}

// drops all application tables
function resetApplication() {
    try {
        var db = getOpenDatabase()
        console.log("Dropping all tables of the application!")
        db.transaction(function (tx) {
            tx.executeSql('DROP TABLE IF EXISTS stockdata');
            tx.executeSql('DROP TABLE IF EXISTS watchlist');
            tx.executeSql('DROP TABLE IF EXISTS backend');
            tx.executeSql('DROP TABLE IF EXISTS alarm');
        })
    } catch (err) {
        console.log("Error deleting tables for application in database : " + err)
    }
}

// initializes all application tables
function initApplicationTables() {
    try {
        var db = getOpenDatabase()
        console.log("Creating all tables of the application if they do not yet exist!")
        db.transaction(function (tx) {
            // backend
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS backend'
                        + ' (id INTEGER, name text NOT NULL, PRIMARY KEY (id))');
            tx.executeSql('INSERT INTO backend (name) VALUES ("Euroinvestor")');
            // watchlist
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS watchlist'
                        + ' (id INTEGER, backendId INTEGER NOT NULL, name text NOT NULL, PRIMARY KEY (id), '
                        +' FOREIGN KEY(backendId) REFERENCES backend(id))');
            tx.executeSql('INSERT INTO watchlist (name, backendId) VALUES ("DEFAULT", (SELECT id FROM backend WHERE name = "Euroinvestor"))');
            // stockdata
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS stockdata'
                        + ' (id INTEGER, name text, currency text, stockMarketSymbol text, stockMarketName text, isin text, symbol1 text, symbol2 text, '
                        + ' price real DEFAULT 0.0, changeAbsolute real DEFAULT 0.0, changeRelative real DEFAULT 0.0, '
                        + ' quoteTimestamp text, lastChangeTimestamp text, watchlistId INTEGER NOT NULL, '
                        +' PRIMARY KEY(id), FOREIGN KEY(watchlistId) REFERENCES watchlist(id))');
            // alarm
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS alarm'
                        + ' (id INTEGER, minimumPrice real DEFAULT null, maximumPrice real DEFAULT null, triggered INTEGER NOT NULL, '
                        +' PRIMARY KEY(id))');
        })
    } catch (err) {
        console.log("Error creating tables for application in database : " + err)
    }
}

function loadTriggeredAlarms(watchlistId, lower) {
    var result = null;
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT s.id AS id, s.name AS name, s.currency as currency, a.minimumPrice as minimumPrice, a.maximumPrice as maximumPrice '
                        + ' FROM alarm a INNER JOIN stockdata s ON a.id = s.id'
                        + ' WHERE s.watchlistId = ? AND s.price > 0.0 AND a.triggered = ? '
                        + ' AND ' + (lower ? ' a.minimumPrice < s.price ' : ' a.maximumPrice > s.price'),
                        [watchlistId, SQL_FALSE]);
            if (dbResult.rows.length > 0) {
                result = [];
                console.log("triggers alarm row count : " + dbResult.rows.length);
                for (var i = 0; i < dbResult.rows.length; i++) {
                    var triggeredAlarm = {};
                    triggeredAlarm.id = dbResult.rows.item(i).id;
                    triggeredAlarm.name = dbResult.rows.item(i).name;
                    triggeredAlarm.currency = dbResult.rows.item(i).currency;
                    triggeredAlarm.maximumPrice = dbResult.rows.item(i).maximumPrice;
                    triggeredAlarm.minimumPrice = dbResult.rows.item(i).minimumPrice;
                    console.log("triggered alarm is " + JSON.stringify(triggeredAlarm));
                    result.push(triggeredAlarm);
                }
            } else {
                console.log("alarms  not triggered !");
            }
        })
    } catch (err) {
        console.log("Error selecting triggred alarms id from database: " + err)
    }
    return result;
}

function loadAlarm(id) {
    var result = null;
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT minimumPrice, maximumPrice FROM alarm WHERE id = ?',
                        [id]);
            if (dbResult.rows.length > 0) {
                console.log("alarm row count : " + dbResult.rows.length);
                var alarm = {};
                alarm.id = id;
                alarm.minimumPrice = dbResult.rows.item(0).minimumPrice;
                alarm.maximumPrice = dbResult.rows.item(0).maximumPrice;
                alarm.triggered = dbResult.rows.item(0).triggered;
                console.log("alarm is " + JSON.stringify(alarm));
                result = alarm;
            } else {
                console.log("alarm not found !");
            }
        })
    } catch (err) {
        console.log("Error selecting alarm id from database: " + err)
    }
    return result;
}

function saveAlarm(alarm) {
    var result = ""
    try {
        var db = getOpenDatabase()
        console.log("trying to insert row for alarm  " + alarm.id + ", " + alarm.minimumPrice + ", and maxprice : " + alarm.minimumPrice);
        console.log("final alarm id " + alarm.id);

        var numberOfPersistedAlarms = 0;

        db.transaction(function (tx) {
            var results = tx.executeSql('SELECT COUNT(*) as count FROM alarm');
            numberOfPersistedAlarms = results.rows.item(0).count;
        })

        console.log("number of persisted alarms : " + numberOfPersistedAlarms)

        db.transaction(function (tx) {
            tx.executeSql(
                        'INSERT OR REPLACE INTO alarm(id, minimumPrice, maximumPrice, triggered) '
                        + 'VALUES (?, ?, ?, ?)',
                        [alarm.id, alarm.minimumPrice, alarm.maximumPrice, SQL_FALSE])
        })
        result = qsTr("Alarm added")
    } catch (err) {
        result = qsTr("Error adding alarm")
        console.log(result + err)
    }
    return result
}

function removeAlarm(alarm) {
    var result = ""
    try {
        var db = getOpenDatabase()

        db.transaction(function (tx) {
            tx.executeSql(
                        'DELETE FROM alarm WHERE id = ?',
                        [alarm.id])
        })
        result = qsTr("Alarm deleted")
    } catch (err) {
        result = qsTr("Error deleting alarm")
        console.log(result + err)
    }
    return result
}

function getCurrentWatchlistId() {
    var result = null;
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT id FROM watchlist WHERE name = ?',
                        ['DEFAULT']);
            if (dbResult.rows.length > 0) {
                console.log("watchlist row count : " + dbResult.rows.length);
                var watchlistId = dbResult.rows.item(0).id;
                console.log("watchlistId is " + watchlistId);
                result = watchlistId;
            } else {
                console.log("watchlistId not found !");
            }
        })
    } catch (err) {
        console.log("Error selecting watchlistId from database: " + err)
    }
    return result;
}

// persists the stock data - either insert or update
function persistStockData(data, watchlistId) {
    var result = ""
    try {
        var db = getOpenDatabase()
        var finalWatchlistId = (watchlistId === null || watchlistId === undefined) ? data.watchlistId : watchlistId;
        console.log("trying to insert row for " + data.symbol + ", " + data.name + ", and watchlist : " + watchlistId + ", " + data.watchlistId);
        console.log("final watchlist id " + finalWatchlistId);

        var numberOfPersistedStockData = 0;

        db.transaction(function (tx) {
            var results = tx.executeSql('SELECT COUNT(*) as count FROM stockdata');
            numberOfPersistedStockData = results.rows.item(0).count;
        })

        console.log("number of persisted stockdata : " + numberOfPersistedStockData)

        db.transaction(function (tx) {
            tx.executeSql(
                        'INSERT OR REPLACE INTO stockdata(id, name, currency, stockMarketSymbol, stockMarketName, isin, symbol1, symbol2, '
                        + 'price, changeAbsolute, changeRelative, quoteTimestamp, lastChangeTimestamp, watchlistId) '
                        + 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [data.id, data.name, data.currency, data.stockMarketSymbol, data.stockMarketName, data.isin, data.symbol1, data.symbol2,
                         data.price, data.changeAbsolute, data.changeRelative, data.quoteTimestamp, data.lastChangeTimestamp, finalWatchlistId])
        })
        result = qsTr("Stock added")
    } catch (err) {
        result = qsTr("Error adding stock")
        console.log(result + err)
    }
    return result
}

function deleteStockData(stockDataId) {
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var result = tx.executeSql(
                        'DELETE FROM stockdata WHERE id = ?',
                        [stockDataId])
            console.log("deleted stockdata with id : " + stockDataId)
        })
    } catch (err) {
        console.log("Error deleting stockdata in database: " + err)
    }
}

function loadAllStockData(watchListId, sortString) { // TODO implement watchlistid
    var result = [];
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var query = 'SELECT id, name, currency, stockMarketSymbol, stockMarketName, isin, symbol1, symbol2, price, changeAbsolute, changeRelative, quoteTimestamp, lastChangeTimestamp, watchlistId '
                    +' FROM stockdata ORDER BY ' + sortString;
            console.log("query : " + query);
            var dbResult = tx.executeSql(query, [])
            // create same object as from json response
            if (dbResult.rows.length > 0) {
                console.log("stockdata row count : " + dbResult.rows.length);
                for (var i = 0; i < dbResult.rows.length; i++) {
                    var row = dbResult.rows.item(i);
                    var entry = {};
                    console.log("row : " + row.name + ", change rel : " + row.changeRelative);
                    entry.id = row.id;
                    entry.name = row.name;
                    entry.currency = row.currency;
                    entry.stockMarketSymbol = row.stockMarketSymbol;
                    entry.stockMarketName = row.stockMarketName;
                    entry.isin = row.isin;
                    entry.symbol1 = row.symbol1;
                    entry.symbol2 = row.symbol2;
                    // nicht gesetzt attribute koennen speater nicht mehr gesetzt werden (wenn mal als model verwendet)
                    entry.price = (row.price === null ? 0.0 : row.price);
                    entry.changeAbsolute = (row.changeAbsolute === null ? 0.0 : row.changeAbsolute);
                    entry.changeRelative = (row.changeRelative === null ? 0.0 : row.changeRelative);
                    entry.quoteTimestamp = (row.quoteTimestamp === null ? "" : row.quoteTimestamp);
                    entry.lastChangeTimestamp = (row.lastChangeTimestamp === null ? "" : row.lastChangeTimestamp);
                    entry.watchlistId = row.watchlistId;
                    result.push(entry);
                }
                console.log("loading stockdata data from database done");
            } else {
                console.log("no stockdata found");
            }
        })
    } catch (err) {
        console.log("Error loading stockdata from database: " + err)
    }
    return result;
}
