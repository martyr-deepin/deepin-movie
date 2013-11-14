#! /usr/bin/env python
# -*- coding: utf-8 -*-


import execjs
import utils
from netlib import Curl

class Poster(object):
    
    def __init__(self, username, password):
        
        self.username = username
        self.password = password
        self.__cookie_file = utils.get_cookie_file(username)
        self.curl = Curl(self.__cookie_file)
        
    def parse_password(self):
        data = dict(t=utils.get_random_t())
        ret = self.curl.request("http://passport.kuaibo.com/user/dynamic_encrypt", data)
        if ret is None:
            return None
        try:
            ctx = execjs.compile(ret)
            return ctx.call("dynamic_encrypt", self.password)
        except:
            return None

                
    def login(self):    
        
        if self.check_login():
            return True
        
        password = self.parse_password()
        if password is None:
            return False
                
        data = dict(user_name=self.username, user_pwd=password, captcha="验证码",
                    referrer="http://vod.kuaibo.com/?t=home", remember_me=1, from_id=2, ext_from_id=2,
                    t=utils.get_random_t())
        ret = self.curl.request("http://passport.kuaibo.com/login/", data=data, method="POST", raw=False)
        json = utils.parser_json(ret)
        return json.get("ok", False)

        
    def check_login(self):    
        url = "http://account.kuaibo.com/check/login/"
        data = {"_" : utils.timestamp()}
        ret = self.curl.request(url, data)
        ret = ret.replace("(", "").replace(")", "")
        json = utils.parser_json(ret)
        return json.get("ok", False)
    
    def get_list(self):
        '''
        {"ok": true, "reason": "", "data": {"max_limit_num": 1000, "used_num": 1, "vod_data": [{"res_type": "", "vod_id": 85641680, "res_info": {}, "play_time_span": "--", "vod_name": "\u661f\u9645\u4f20\u59473.TC1280\u6e05\u6670\u82f1\u8bed\u4e2d\u5b57", "file_info": {"videos": [], "file_name": "\u661f\u9645\u4f20\u59473.TC1280\u6e05\u6670\u82f1\u8bed\u4e2d\u5b57.mkv", "file_hash": "0D5E15FD62178E0ACFDDD3239A20E6B9", "ref_file_id": null, "create_time": 1383203680, "file_id": 2351789, "file_size": 2539634623, "progress": 0}, "video_type": "mkv", "vod_id_encrypt": "b6e207713a82447ca81be4b1d3e9c11f", "create_time": 1383575444, "file_id": 2351789, "play_time": 0, "res_id": 8669739, "res_status": "\u5904\u7406\u4e2d"}], "page_size": 20, "total_page": 1, "used_rate": "0.1%"}}
        '''
        url = "http://vod.kuaibo.com/vod/all/list/"
        data = {"page" : 1, "page_size": 20, "_" : utils.timestamp()}
        ret = self.curl.request(url, data)
    
        return ret
    
    def get_history(self):
        url = "http://vod.kuaibo.com/vod/history/?page=1&page_size=20&_=1384401545301"
        
    def get_playargs(self):    
        url = "http://vod.kuaibo.com/play/get/play/args/?t=0.09687586802507453&vod_id=e9df6061a61a4e57a81be4b1d3e9c11f&s=E3A09C3136B21917440924119539E5A4A6F00A87"
        
        
        

