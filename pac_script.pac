// 白名单列表：这些域名及其所有子域名将使用代理
var directDomains = [
    "google.com", "youtube.com", "twitter.com", "facebook.com",
    "instagram.com", "wikipedia.org", "github.com", "archive.org",
    "googleapis.com", "gstatic.com", "blogspot.com"
];

function FindProxyForURL(url, host) {
    // 1. 如果主机名没有点（如 http://localhost/），直接连接
    if (isPlainHostName(host)) {
        return "DIRECT";
    }

    // 2. 检查是否在白名单中（及其所有子域名）
    for (var i = 0; i < directDomains.length; i++) {
        var domain = directDomains[i];
        if (host === domain || host.endsWith('.' + domain)) {
            // 使用你的代理地址 127.0.0.1:7891
            return "PROXY 127.0.0.1:7891";
        }
    }

    // 3. 国内局域网/内网地址，直接连接
    if (isInNet(host, "10.0.0.0", "255.0.0.0") ||
        isInNet(host, "172.16.0.0", "255.240.0.0") ||
        isInNet(host, "192.168.0.0", "255.255.0.0") ||
        isInNet(host, "127.0.0.0", "255.255.255.0")) {
        return "DIRECT";
    }

    // 4. 默认：所有其他网站直接连接
    return "DIRECT";
}


