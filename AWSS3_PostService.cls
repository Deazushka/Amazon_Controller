/**
 * Created by meo on 30.04.19.
 */

public with sharing class AWSS3_PostService {

    public static void uploadToAmazonS3(String sBlob, String blobName, String xFolder, String contentType) {

        //xFolder this is random folder

        sBlob = EncodingUtil.urlDecode(sBlob, 'UTF-8');

        Blob attachmentBody = EncodingUtil.base64Decode(sBlob);
        String formattedDateString = Datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss z');
        String key = 'xxxxxxxx';
        String secret = 'xxxxxxxxxxxxxxxxxxx';
        String bucketName = 'bucketname';
        String host = 'host';
        String method = 'PUT';
        String filename = blobName;

        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + bucketName + '.' + host + '/' + xFolder + '/' + filename);
        req.setHeader('Host', bucketName + '.' + host);
        req.setHeader('Content-Length', String.valueOf(sBlob.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', contentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read');
        req.setBodyAsBlob(attachmentBody);

        String stringToSign = 'PUT\n\n' +
                contentType + '\n' +
                formattedDateString + '\n' +
                '/' + bucketName + '/' + xFolder + '/' + filename;

        Blob mac = Crypto.generateMac('HMACSHA1', Blob.valueOf(stringToSign), Blob.valueOf(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization', authHeader);

        Http http = new Http();
        HttpResponse res = http.send(req);

    }
}