/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


class DownloadData {
    contentType: string = "application/json;charset=utf-8"; // by default json
    url: string;
    eTag : string; // the optional etag
    timeout: number = 5000; // 5 seconds timeout
}
