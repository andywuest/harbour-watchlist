> ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost
> cd /home/src1/projects/sailfishos/github/harbour-watchlist
> mb2 -t SailfishOS-2.2.0.29-armv7hl build
> cd RPMS
> scp harbour-watchlist-0.0.1-1.armv7hl.rpm wuesand@192.168.123.128:

NOTE:
 * Timeouts for xmlhttprequests are not yet supported: https://bugreports.qt.io/browse/QTBUG-50275

TODO  watchlist


after release
+ properly handle timeouts -> show error if not network is available
+ Stock suche -> keine Ergebnis anzeigen -> loading indicator bei suche.
+ für aktien ohne erstmalige kursabfrage auch keine preis Euro/ Änderung in Prozent angeben.
+ Refresh on cover (enable)
+ i18n
+ icons
+ multiple backends
+ multiple watchlists
+ standardsortierung in watchlist konfigurierbar
+ github move
+ cleanup
+ lokalen dummy server für quotes um timeouts zu testen.
+ backend.sortByChangeDesc -pruefen, ob noch benoetig
+ todo doppelte urls im backend fixen
+ konfigurierbare notifications lower / upper limit


# generate or remove license header -via maven plugin
mvn license:format
mvn license:remove



