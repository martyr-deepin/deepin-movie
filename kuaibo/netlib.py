#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import pycurl
import StringIO
from  urllib import urlencode


try:
    unicode
except NameError:
    def _is_unicode(x):
        return 0
else:
    def _is_unicode(x):
        return isinstance(x, unicode)


def raw_urlencode(query, doseq=0):
    """Encode a sequence of two-element tuples or dictionary into a URL query string.

    If any values in the query arg are sequences and doseq is true, each
    sequence element is converted to a separate parameter.

    If the query arg is a sequence of two-element tuples, the order of the
    parameters in the output will match the order of parameters in the
    input.
    """

    if hasattr(query,"items"):
        # mapping objects
        query = query.items()
    else:
        # it's a bother at times that strings and string-like objects are
        # sequences...
        try:
            # non-sequence items should not work with len()
            # non-empty strings will fail this
            if len(query) and not isinstance(query[0], tuple):
                raise TypeError
            # zero-length sequences of all types will get here and succeed,
            # but that's a minor nit - since the original implementation
            # allowed empty dicts that type of behavior probably should be
            # preserved for consistency
        except TypeError:
            ty,va,tb = sys.exc_info()
            raise TypeError, "not a valid non-string sequence or mapping object", tb

    l = []
    if not doseq:
        # preserve old behavior
        for k, v in query:
            k = str(k)
            v = str(v)
            l.append(k + '=' + v)
    else:
        for k, v in query:
            k = str(k)
            if isinstance(v, str):
                l.append(k + '=' + v)
            elif _is_unicode(v):
                # is there a reasonable way to convert to ASCII?
                # encode generates a string, but "replace" or "ignore"
                # lose information and "strict" can raise UnicodeError
                v = v.encode("ASCII","replace")
                l.append(k + '=' + v)
            else:
                try:
                    # is this a sufficient test for sequence-ness?
                    len(v)
                except TypeError:
                    # not a sequence
                    v = str(v)
                    l.append(k + '=' + v)
                else:
                    # loop over the sequence
                    for elt in v:
                        l.append(k + '=' + str(elt))
    return '&'.join(l)


class Curl(object):
    '''
    methods:
    
    GET
    POST
    UPLOAD
    '''
    HEADERS = ['User-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 ' \
                   '(KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4',]

    
    def __init__(self, cookie_file=None, headers=HEADERS):
        self.cookie_file = cookie_file
        self.headers = headers
        self.url = ""
    
    def request(self, url, data=None, method="GET", header=None, proxy_host=None, proxy_port=None, raw=False):
        '''
        open url width get method
        @param url: the url to visit
        @param data: the data to post
        @param header: the http header
        @param proxy_host: the proxy host name
        @param proxy_port: the proxy port
        '''
        
        if raw:
            url_encode = raw_urlencode
        else:    
            url_encode = urlencode
        
        if isinstance(url, unicode):
            self.url = str(url)
        else:    
            self.url = url
        
        crl = pycurl.Curl()
        #crl.setopt(pycurl.VERBOSE,1)
        crl.setopt(pycurl.NOSIGNAL, 1)

        # set proxy
        if proxy_host:
            crl.setopt(pycurl.PROXY, proxy_host)
        if proxy_port:
            crl.setopt(pycurl.PROXYPORT, proxy_port)
            
        if self.cookie_file:    
            crl.setopt(pycurl.COOKIEJAR, self.cookie_file)            
            crl.setopt(pycurl.COOKIEFILE, self.cookie_file)            
            
        # set ssl
        crl.setopt(pycurl.SSL_VERIFYPEER, 0)
        crl.setopt(pycurl.SSL_VERIFYHOST, 0)
        crl.setopt(pycurl.SSLVERSION, 3)
         
        crl.setopt(pycurl.CONNECTTIMEOUT, 10)
        crl.setopt(pycurl.TIMEOUT, 300)
        crl.setopt(pycurl.HTTPPROXYTUNNEL, 1)

        headers = self.headers or header
        if headers:
            crl.setopt(pycurl.HTTPHEADER, headers)

        crl.fp = StringIO.StringIO()
            
        if method == "GET" and data:    
            self.url = "%s?%s" % (self.url, url_encode(data))
            
        elif method == "POST" and data:
            print url_encode(data)
            crl.setopt(pycurl.POSTFIELDS, url_encode(data))  # post data
            
        elif method == "UPLOAD" and data:
            if isinstance(data, dict):
                upload_data = data.items()
            else:
                upload_data = data
            crl.setopt(pycurl.HTTPPOST, upload_data)   # upload file
            
        crl.setopt(pycurl.URL, self.url)
        crl.setopt(crl.WRITEFUNCTION, crl.fp.write)
        try:
            crl.perform()
        except Exception:
            return None
        
        crl.close()
        back = crl.fp.getvalue()
        crl.fp.close()
        return back
    
public_curl = Curl()    
