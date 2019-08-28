/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
class DownloadService {

    public execute(data: DownloadData, callback: (returnCode: number, httpRequest: XMLHttpRequest) => void): void {
        let httpRequest: XMLHttpRequest = new XMLHttpRequest();

        console.log("trying to fetch data from : " + data.url);

        httpRequest.open('GET', data.url);
        if (data.contentType !== null) {
            httpRequest.setRequestHeader('Content-Type', data.contentType);
        }
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
        }
        httpRequest.timeout = data.timeout;
        console.log("timeout defined : " + httpRequest.timeout);
        httpRequest.onreadystatechange = () => {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status && httpRequest.status === 200 && httpRequest.responseText !== "undefined") {
                    console.log("return status : " + httpRequest.status);
                    console.log("Resposne Headers : " + httpRequest.getAllResponseHeaders())
                    console.log("Resposne ETag : " + httpRequest.getResponseHeader("ETag"))
                    console.log("return responseText : " + httpRequest.responseText.substring(0, 200));
                    console.log("executing success callback !");

                    callback(0, httpRequest);

                    console.log("executing success done !");
                } else if (httpRequest.status && httpRequest.status === 304) {
                    callback(1, httpRequest);
                } else {
                    console.log("executing failure callback - data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);

                    callback(2, httpRequest);
                }
            }
        };
        httpRequest.onerror = (ev: Event) => {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        }

        try {
            httpRequest.send()
        } catch (error) {
            callback(3, error);
        }

    }

    //  var url = currentPhotoId;
    //        var xhr = new XMLHttpRequest();
    //        xhr.open('GET', url, true);
    //        xhr.responseType = 'arraybuffer';
    //        xhr.onreadystatechange = function() {
    //            if (xhr.readyState === XMLHttpRequest.DONE) {
    //                if (xhr.status === 200) {
    //                    var response = new Uint8Array(xhr.response);
    //                    var raw = "";
    //                    for (var i = 0; i < response.byteLength; i++) {
    //                        raw += String.fromCharCode(response[i]);
    //                    }
    //
    //                    console.log("image fetched !");
    //
    //                    var image = 'data:image/png;base64,' +Constants.base64Encode(raw);
    //                            //
    //                    img.source = image;
    //                    fetchImages(photoIdUrls);
    //                }
    //            }
    //        }
    //        xhr.send();


    public executeBinary(data: DownloadData, callback: Function): void {
        let httpRequest: XMLHttpRequest = new XMLHttpRequest();

        console.log("trying to fetch data from : " + data.url);

        httpRequest.open('GET', data.url);
        httpRequest.responseType = 'arraybuffer';
        // httpRequest.setRequestHeader('Content-Type', data.contentType);
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
        }
        httpRequest.timeout = data.timeout;
        console.log("timeout defined : " + httpRequest.timeout);
        httpRequest.onreadystatechange = () => {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status && httpRequest.status === 200 && httpRequest.responseText !== "undefined") {
                    console.log("return status : " + httpRequest.status);
                    console.log("Resposne Headers : " + httpRequest.getAllResponseHeaders())
                    console.log("Resposne ETag : " + httpRequest.getResponseHeader("ETag"))
                    console.log("return responseText : " + httpRequest.responseText.substring(0, 200));
                    console.log("executing success callback !");

                    var response = new Uint8Array(httpRequest.response);
                    var raw = "";
                    for (var i = 0; i < response.byteLength; i++) {
                        raw += String.fromCharCode(response[i]);
                    }

                    callback(0, httpRequest, raw);

                    console.log("executing success done !");
                } else if (httpRequest.status && httpRequest.status === 304) {
                    callback(1, httpRequest);
                } else {
                    console.log("executing failure callback - data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);

                    callback(2, httpRequest);
                }
            }
        };
        httpRequest.onerror = (ev: Event) => {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        }

        try {
            httpRequest.send()
        } catch (error) {
            callback(3, error);
        }
    }

}