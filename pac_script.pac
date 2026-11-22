//
var directDomains = [
    "google.com", "youtube.com", "twitter.com", "facebook.com",
    "instagram.com", "wikipedia.org", "github.com", "archive.org",
    "googleapis.com", "gstatic.com", "blogspot.com"
];

function FindProxyForURL(url, host) {
    // 
    if (isPlainHostName(host)) {
        return "DIRECT";
    }

    // 
    for (var i = 0; i < directDomains.length; i++) {
        var domain = directDomains[i];
        if (host === domain || host.endsWith('.' + domain)) {
            // 
            return "PROXY 127.0.0.1:7891";
        }
    }

    // 
    if (isInNet(host, "10.0.0.0", "255.0.0.0") ||
        isInNet(host, "172.16.0.0", "255.240.0.0") ||
        isInNet(host, "192.168.0.0", "255.255.0.0") ||
        isInNet(host, "127.0.0.0", "255.255.255.0")) {
        return "DIRECT";
    }

    //
    return "DIRECT";
}


