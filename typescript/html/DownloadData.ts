class DownloadData {
    contentType: string = "application/json;charset=utf-8"; // by default json
    url: string;
    eTag : string; // the optional etag
    timeout: number = 5000; // 5 seconds timeout
}
