#! /usr/bin/env python
# -*- coding: utf-8 -*-

from PyQt5 import QtQuick, QtCore, QtNetwork

class _ExtendedNetworkCookieJar(QtNetwork.QNetworkCookieJar):
    
    def mozillaCookies(self):
        """
        Return all cookies in Mozilla text format:
        
        # domain domain_flag path secure_connection expiration name value
        
        .firefox.com     TRUE   /  FALSE  946684799   MOZILLA_ID  100103        
        """
        header = ["# Netscape HTTP Cookie File", ""]        
        def bool2str(value):
            return {True: "TRUE", False: "FALSE"}[value]
        def byte2str(value):            
            return str(value)        
        def get_line(cookie):
            domain_flag = str(cookie.domain()).startswith(".")
            return "\t".join([
                byte2str(cookie.domain()),
                bool2str(domain_flag),
                byte2str(cookie.path()),
                bool2str(cookie.isSecure()),
                byte2str(cookie.expirationDate().toTime_t()),
                byte2str(cookie.name()),
                byte2str(cookie.value()),
            ])
        lines = [get_line(cookie) for cookie in self.allCookies()] 
        return "\n".join(header + lines)

    def setMozillaCookies(self, string_cookies):
        """Set all cookies from Mozilla test format string.
        .firefox.com     TRUE   /  FALSE  946684799   MOZILLA_ID  100103        
        """
        def str2bool(value):
            return {"TRUE": True, "FALSE": False}[value]
        def get_cookie(line):
            fields = map(str.strip, line.split("\t"))
            if len(fields) != 7:
                return
            domain, domain_flag, path, is_secure, expiration, name, value = fields
            cookie = QtNetwork.QNetworkCookie(name, value)
            cookie.setDomain(domain)
            cookie.setPath(path)
            cookie.setSecure(str2bool(is_secure))
            cookie.setExpirationDate(QtCore.QDateTime.fromTime_t(int(expiration)))
            return cookie
        cookies = [get_cookie(line) for line in string_cookies.splitlines() 
          if line.strip() and not line.strip().startswith("#")]
        self.setAllCookies(filter(bool, cookies))

class CookieManager(QtCore.QObject):
    
    def __init__(self, view):
        super(CookieManager, self).__init__()
        self.network_manager = view.engine().networkAccessManager()
        self.cookie_jar = _ExtendedNetworkCookieJar()
        self.network_manager.setCookieJar(self.cookie_jar)
        
    @QtCore.pyqtSlot(str)    
    def setCookie(self, f):
        with open(f) as fp:
            self.cookie_jar.setMozillaCookies(fp.read())
        
        reply = self.network_manager.get(QtNetwork.QNetworkRequest(QtCore.QUrl("http://account.kuaibo.com/check/login/")))    
        def on_reply_finised(*args):
            print str(reply.readAll())
        reply.finished.connect(on_reply_finised)
        
    def clearCookie(self):    
        self.network_manager.setCookieJar(QtNetwork.QNetworkCookieJar())
        
        
        
