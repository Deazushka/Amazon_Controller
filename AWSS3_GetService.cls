/**
 * Created by meo on 25.04.19.
 */

public with sharing class AWSS3_GetService {
    public String pic { get; set; }
    public String file { get; set; }
    public String filename { get; set; }
    public String contentType { get; set; }

    public AWSS3_GetService() {
        file = getFile();
    }

    public String getFile() {
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String key = 'xxxxxxxx';
        String secret = 'xxxxxxxxxxxxxxxxx';
        String bucketname = 'bucketname';
        String host = 's3-us-west-2.amazonaws.com';
        String method = 'GET';


        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + host + '/' + bucketname + '/build.txt');
        req.setHeader('Host', host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);


        String stringToSign = 'GET\n\n' + '\n' +
                formattedDateString + '\n' +
                '/' + bucketname + '/build.txt';

        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign), blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization', authHeader);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        contentType = res.getHeader('Content-Type');
        String result = EncodingUtil.base64Encode(res.getBodyAsBlob());
        return result;
    }

    public PageReference getUrl() {
        String filename = EncodingUtil.urlEncode(file, 'UTF-8');

        String key = 'xxxxxxxx';
        String secret = 'xxxxxxxxxxxxxxxxx';
        String bucketname = 'bucketname';

        Datetime now = DateTime.now();
        Datetime expireson = now.AddSeconds(600);
        Long Lexpires = expireson.getTime() / 1000;

        String stringToSign = 'GET\n\n\n' + Lexpires + '\n/' + bucketName + '/' + filename;

        Blob mac = Crypto.generateMac ('hmacSHA1', Blob.valueOf (stringToSign), Blob.valueOf (secret));
        stringToSign = EncodingUtil.base64Encode (mac);
        String encoded = EncodingUtil.urlEncode (stringToSign, 'UTF-8');

        String link = 'http://' + bucketName + '.s3.amazonaws.com/' + filename + '?AWSAccessKeyId=' + key + '&Signature=' + encoded +
                '&Expires=' + Lexpires;

        PageReference linkReference = new PageReference(link);
        linkReference.setRedirect(true);
        return linkReference;

    }
}