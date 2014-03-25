// JavaScript Document 
var $=function(id){ return document.getElementById(id);}

var sys = {};
var ua = navigator.userAgent.toLowerCase();
var s;
(s = ua.match(/msie ([\d.]+)/)) ? sys.ie = s[1] :
(s = ua.match(/firefox\/([\d.]+)/)) ? sys.firefox = s[1] :
(s = ua.match(/chrome\/([\d.]+)/)) ? sys.chrome = s[1] :
(s = ua.match(/opera.([\d.]+)/)) ? sys.opera = s[1] :
(s = ua.match(/version\/([\d.]+).*safari/)) ? sys.safari = s[1] : 0;

//以下进行测试
/*
if (sys.ie) document.write('IE: ' + sys.ie);
if (sys.firefox) document.write('Firefox: ' + sys.firefox);
if (sys.chrome) document.write('Chrome: ' + sys.chrome);
if (sys.opera) document.write('Opera: ' + sys.opera);
if (sys.safari) document.write('Safari: ' + sys.safari);
*/

/*过渡加载*/
function loading(id,big)
{
	if(big=='big')
	{
		var loa='<table class="loading" width="100%" height="100%" border="0" cellpadding="0" cellspacing="0"><tr><td align="center" valign="middle"><img  style="top:45%" src="/images/loading_b.gif" /></td></tr></table>';
	}else{
		var loa='<table class="loading" width="100%" height="100%" border="0" cellpadding="0" cellspacing="0"><tr><td align="center" valign="middle"><img  style="top:45%" src="/images/loading.gif" /></td></tr></table>';
	}

	if(typeof(id) == 'object')
	{
		id.innerHTML=loa;
	}else{
		document.getElementById(id).innerHTML=loa;
	}
}

/*用法
loadContent('http://127.0.0.1/tmp/v.php?','sendData_callback');
function sendData_callback(data,parameter)
{
	alert(data);
}*/
/*
跨域调用
定义了回调函数，会有2个参数输出，第一个是返回的数据，第二个是这个函数传递给回调函数的参数
*/
function loadContent(url,callback,parameter,flag)
{
	var f=url.split("?").length>=2?"&":"?";
	var timestamp = Date.parse(new Date());	
	flag=flag?flag:0;
	var obj=document.body.getElementsByTagName('SCRIPT');
	if(obj && obj.length && obj[0].id=="sys_tmp_script_"+flag)
	{
		obj[0].parentNode.removeChild(obj[0]);
		var s=document.createElement('SCRIPT');
		s.id="sys_tmp_script_"+flag;
		s.src=url+f+"callback="+callback+"&parameter="+parameter+"&t="+timestamp;
		document.body.insertBefore(s,document.body.childNodes[0]);
	}else{
		var s=document.createElement('SCRIPT');
		s.id="sys_tmp_script_"+flag;
		s.src=url+f+"callback="+callback+"&parameter="+parameter+"&t="+timestamp;
		document.body.insertBefore(s,document.body.childNodes[0]);
	}
}


/* //////////////////////////////////////////////////////////////////////////////////////////////////
  *   AJAX主函数
  *   参数说明：
  *   url 提交页面  可选参数 geturl(id) 自定义 为空 ，3中状态 必选 其它不为必选
  *   fun 调用函数 默认调用client  可选参数 不调用 自定义
  *   method提交方式 get post 默认 GET 
  *   fromid 提交表单的ID或名称
  *   id     可以带一个返回参数
  *   vars 将数据返回给外部变量（注意：在使用它之间必须先定义外部变量比如：var gamehtml='';ajax_ultimate('index_.php','','','','','gamehtml');）这样才是正却的，否则报错 他的等级最高，其次外调函数，再次是ID返回值
  
  *   当method为GET时 只需调用 url 和fum两个即可
  *   当method为POST时 如果URL启用的是 geturl()函数时只需调用 url,fun,method即可 
  *   如果URL为用户定义路径时 需要把url,fun,method,id这4个参数掉齐全
  *   如果URL为空时则属要调用 url,fun,method,id 4个参数
  *   geturl(id)；AJAX附加调用函数
  *   作用：为AJAX取得FORM表单的路径 参数ID为 FORM表单ID或名称
  *   POST用法有3种 
  *   1、URL 用户自定义地址 Fun 可为空 ,method 为POST 输入FORM表单ID  ajax_ultimate(url,fun,method,id)
  *   2、URL 为空 Fun 可为空 ,method 为POST  ,id 提交表单的ID或名称 ajax_ultimate('',fun,method,id)
  *   3、URL 调入url() 函数  Fun 可为空 ,method 为POST ajax_ultimate(geturl(ID),fun,method,id)
*/////////////////////////////////////////////////////////////////////////////////////////////////

function ajax_ultimate(url,fun,method,fromid,id,vars)
{
	new ajaxsends(url,fun,method,fromid,id,vars);
	return ;
}

function ajaxsends(url,fun,method,fromid,id,vars)
{
	var this_=this;
	this_.url=url;
	this_.fun=fun;
	this_.method=method;
	this_.fromid=fromid;
	this_.id=id;
	this_.vars=vars;
	this_.cleaeTO=null;
	
	/*AJAX执行状态*/
	ajaxsends.prototype.ajax_yun=function()
	{
		//获取执行状态
		this_.ajax.onreadystatechange = function() 
		{
			//如果执行是状态正常，那么就把返回的内容赋值给上面指定的层
			if (this_.ajax.readyState == 4 && this_.ajax.status == 200)
			{
				var	strdiv = this_.ajax.responseText;  //读取PHP页面打印出来的文字
				clearTimeout(this_.cleaeTO);
				var jsstr=strdiv;
				
				strdiv=strdiv.replace(/<script[\s\S]+?<\/script>/igm,"");
				if(vars)
				{
					eval(this_.vars +"=strdiv");
				}else{
					if(this_.fun)
					{
						eval(this_.fun + "(strdiv,id)");
					}else if(this_.id){
						 document.getElementById(this_.id).innerHTML=strdiv;
					}
				}
				this_.ajaxjs(jsstr);
				
				/*释放变量及缓存*/
				this_.url=this_.fun=this_.method=this_.fromid=this_.id=strdiv=jsstr=this_.ajax=this_.vars=null;
				delete this_.ajax ; 
				this_=null;
				if(sys.ie){CollectGarbage;}
				
		//////////////////////////////////上面是处理//////////////////////////////////////////////////
			}
		}
	}
	
	
	/* 实例化AJAX*/
	ajaxsends.prototype.user_InitAjaxw=function()
	{
		 if (window.ActiveXObject)
		 {
			//IE
			try {
				//IE6.0以上
				return new ActiveXObject("Microsoft.XMLHTTP");
			}catch (e1) {
					//IE5.5以下
					return new ActiveXObject("Msxml2.XMLHTTP");
			}
		} else if (window.XMLHttpRequest) {
			//FireFox
			return new XMLHttpRequest();
		}

	}
	
	/*获取表单URL*/
	ajaxsends.prototype.geturl=function()
	{	
		var u=new Array();
		
		try{
			var url=document.getElementById(this_.fromid).action; 
		}catch(err){
			var  url=document.getElementsByName(this_.fromid)[0].action; 
		}
		
		if(!url)
		{
			alert('表单action属性为空（要提交的地址）！');
			return false;
		}
		
		u[0]=url;
		u[1]=fromid;
		
		return u;
	}
	
	/*执行JS */
	ajaxsends.prototype.ajaxjs=function(msg)
	{
		var str2=msg.split("\r\n").join('');
		str2=str2.split("\n").join('');
		str2=str2.split("\r").join('');
		
		var reg=/<script[^>]*?>(.*?)<\/script>/ig;
		var str=str2.match(reg);
		
		if(!str)
		{
			return false;
		}
		
		for(var i=0;i<str.length;i++)
		{
			str[i]=str[i].replace(reg,"$1");
			try {
				eval(str[i]);
			}catch(e){}

		}
	}
	
	
	/*POST提交*/
	ajaxsends.prototype.post=function()
    {
		if(!this_.url)
		{
			this_.url=this_.geturl();
		}else{
			if ( this_.url.constructor != window.Array)
			{
				var url_=this_.url;
				this_.url = new Array () ; 
				this_.url[0]=url_;
				this_.url[1]=this_.fromid;
			}
		}
		
		
		if (!typeof(this_.url[0])){return;}

		if(!this_.url[0]){return;}
       
		this_.ajax_yun();
		
        this_.ajax.open("POST", this_.url[0], true);
		
        this_.ajax.setRequestHeader("If-Modified-Since","0");
        this_.ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		//发送空
		
		try
		{
			var oForm=document.getElementById(this_.url[1]);

		}catch(err){
		
		   var oForm=document.getElementsByName(this_.url[1])[0];
		}
		
		var sBody=""
		if(oForm)
		{
			sBody=getRequestBody(oForm);
		}else{
			sBody=this_.url[1]
		}
		
		this_.ajax.send(sBody);
	}

	/*GET提交*/
	ajaxsends.prototype.get=function()
	{
		if (!typeof(this_.url)){return;}
		
		if(!this_.url){return;}
		
		this_.ajax.open("GET",this_.url,true);
		this_.ajax_yun();
		this_.ajax.setRequestHeader("Content-Type","text/html; charset=UTF-8");
		this_.ajax.setRequestHeader("If-Modified-Since","0");
		this_.ajax.send(null);
	}
	//////////////////////////////////////////
	this_.ajax = this_.user_InitAjaxw();
	
	this_.cleaeTO = setTimeout(function(){this_.ajax.abort();},20000);
        
	if(!this_.method || this_.method=='get'  || this_.method=='GET')
	{
		this_.get();//GET方式
	}else{
		this_.post();//POST方式	
	}
	
	if(sys.ie){CollectGarbage();}//释放缓存
}

function getRequestBody(oForm)
{
	var aParams=new Array();
	for(var i=0;i<oForm.elements.length;i++)
	{
		if(oForm.elements[i].type=="radio" || oForm.elements[i].type=="checkbox")
		{
			if(oForm.elements[i].checked==true)
			{
				var sParam=encodeURIComponent(oForm.elements[i].name);
				sParam+="=";
				sParam+=encodeURIComponent(oForm.elements[i].value);
				aParams.push(sParam);
			}
		}else{
			var sParam=encodeURIComponent(oForm.elements[i].name);
			sParam+="=";
			sParam+=encodeURIComponent(oForm.elements[i].value);
			aParams.push(sParam);
		}
	}
	return aParams.join("&");
}


function setCookie(name,value,timet) //Cookie名  Cookie内容  Cookie存储时间
{ //设置Cookie
    	var exp  = new Date();    //new Date("December 31, 9998");
        exp.setTime(exp.getTime()+Number(timet));
        document.cookie = name + "="+ escape (value) + ";expires=" + exp.toGMTString();
}
function getCookie(name)
{//读取Cookie
    var arr,reg=new RegExp("(^| )"+name+"=([^;]*)(;|$)");
        if(arr=document.cookie.match(reg)) return unescape(arr[2]);
        else return null;
}
function delCookie(name)
{//删除Cookie
    var exp = new Date();
        exp.setTime(exp.getTime() - 1);
    var cval=getCookie(name);
        if(cval!=null) document.cookie= name + "="+cval+";expires="+exp.toGMTString();
}

/*判断表单是否存在*/
function detection_thing(labelID)
{
	try
		{
			var oForm=document.getElementById(labelID);
			
			return true;	
			
		}catch(err){return false; }
}

/*随屏幕滚动层*/
function scrolldiv(id,h)
{
	var MyMar='';
	
	var obj=document.getElementById(id);
	
	if(h==null)
	{
		h='50px';
	}
	
	if(obj.style.display!='none')
	{
		MyMar=setInterval('scrolldiv_("'+id+'",'+h+')',100);   ///控制层的移动
	}else{
		clearInterval(MyMar);
	}
}

function  scrolldiv_(id,h)
{  //定位层
   obj=document.getElementById(id);

   obj.style.top =  ((document.documentElement) ? document.documentElement : document.body).scrollTop+h;
} 


function base64_encode(str)
{
	var base64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	var base64DecodeChars = new Array(
　　-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
　　-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
　　-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
　　52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
　　-1,　0,　1,　2,　3,  4,　5,　6,　7,　8,　9, 10, 11, 12, 13, 14,
　　15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
　　-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
　　41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1);

　　var out, i, len;
　　var c1, c2, c3;
　　len = str.length;
　　i = 0;
　　out = "";
　　while(i < len) {
 c1 = str.charCodeAt(i++) & 0xff;
 if(i == len)
 {
　　 out += base64EncodeChars.charAt(c1 >> 2);
　　 out += base64EncodeChars.charAt((c1 & 0x3) << 4);
　　 out += "==";
　　 break;
 }
 c2 = str.charCodeAt(i++);
 if(i == len)
 {
　　 out += base64EncodeChars.charAt(c1 >> 2);
　　 out += base64EncodeChars.charAt(((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4));
　　 out += base64EncodeChars.charAt((c2 & 0xF) << 2);
　　 out += "=";
　　 break;
 }
 c3 = str.charCodeAt(i++);
 out += base64EncodeChars.charAt(c1 >> 2);
 out += base64EncodeChars.charAt(((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4));
 out += base64EncodeChars.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >>6));
 out += base64EncodeChars.charAt(c3 & 0x3F);
　　}
　　return out;
}

function on_off(value,e)
{
     var obj=document.getElementById(value);
	 if(e)
	 {
		obj.style.display=e;
	}else{
		obj.style.display=(obj.style.display=='none')?'':'none';
	}
	
}

/**************************BEGIN图层渐变显示*************************************/
/*
参数说明
div_id要控制渐变的ID
*/
function shade_show(div_id)
{
	var this_=this;
	this_.fade_opacity = 0;
	this_.ele_div = null;
	this_.fade_times= null;
	
	shade_show.prototype.change_show=function()
	{
	   var obj =this_.ele_div;
	   this_.fade_opacity = this_.fade_opacity + 5; //逐渐显示速度
	   obj.style.filter = "Alpha(Opacity=" + this_.fade_opacity + ")"; //透明度逐渐变小
	   obj.style.opacity = this_.fade_opacity/100; //兼容FireFox
	   if(this_.fade_opacity>=100){
		clearInterval(this_.fade_times);
		this_.fade_opacity=0;
	   }
	}
	
	
	shade_show.prototype.show_fade=function()
	{
	   var obj = document.getElementById(div_id);
	   if (!obj)
	   {
		   return ;
	   }
	   this_.ele_div = obj;
	   if(this_.fade_times){clearInterval(this_.fade_times);}
	   obj.style.filter = "Alpha(Opacity=0)"; //透明度逐渐变小
	   obj.style.opacity = this_.fade_opacity/100; //兼容FireFox
	   obj.style.display="block";
	   this_.fade_times = setInterval(this_.change_show,1);
	}
}
/**************************END图层渐变显示**************************************/	

/*
函数说明：
url   移动层内的内容地址
title  标题
css   移动层的样式（不用包含TOP和LEFT）
cajax  是采用AJAX还是iframe方式调用内容 1为不采用AJAX 0为采用AJAX
scrolling 如果采用iframe 是否启用滚动条，默认为自动 有三个值 no yes auto
top 顶坐标 默认居中
left 顶坐标 默认居中
cssid	容器，通常可以为空因为在也没中加入了入 <div id='movediv' style="display:none;"></div>，而这个有事程序里默认的
callback  毁掉函数可以为空的
parameter	可以想回调函数中传入一个参数
注意 使用前应引入/imgedit/manipulate.js
请在页面中加入 <div id='movediv' style="display:none;"></div>这个 一般加在最底部
*/
function movediv(url,title,css,cajax,scrolling,top,left,cssid,callback,parameter)
{
	if(!callback){callback="";}
	var imgp="/template/default/aa_images/frame/min/";
	if(!cssid)
	{
		cssid="movediv";
	}
	document.getElementById(cssid).style.display='';

	if(!scrolling){scrolling='auto';}
	
	var infos='<div id=move_div_info style="text-align:center;"><\/div>';
	
	if(!title)
	{
		title='';
	}
	
	document.getElementById(cssid).innerHTML = '<div id=movediv_ class="frame">'+
	'<div class="frame-a">'+
    	'<div class="w24"><img src="'+imgp+'top-1.gif" /><\/div>'+
        '<div class="f-am1"><div style="position:absolute;top:13px;right:25px;"><img style="cursor:pointer;" onclick="logoutdiv(\''+cssid+'\')" src="'+imgp+'close.gif" /></div><\/div>'+
        '<div class="w24"><img src="'+imgp+'top-3.gif" /><\/div>'+
    '<\/div>'+
	'<div class="frame-b">'+
    	'<div class="f-bl"><\/div>'+
		'<div class="f-bm">'+infos+
		'<\/div>'+
        '<div class="f-br"><\/div>'+
	'<\/div>'+
	'<div class="frame-a">'+
    	'<div class="w24"><img src="'+imgp+'bot-1.gif" /><\/div>'+
        '<div class="f-am2" style="height:4px; line-height:4px;"></div>'+
        '<div class="w24"><img src="'+imgp+'bot-3.gif" /><\/div>'+
    '<\/div>'
'<\/div>';
	
	loading('move_div_info','big');//载入

	//var ss=new shade_show("movediv_");
	//ss.show_fade();//渐变显示调用 
	
	var mobj=document.getElementById("movediv_");
	
	mobj.className=css;
	
	document.documentElement.scrollTop = 0; 

	var yw = document.documentElement.clientWidth; 
	
	var yh = document.documentElement.clientHeight; 
	
	var w = mobj.clientWidth||mobj.offsetWidth;
	
	var h = mobj.clientHeight||mobj.offsetHeight;
		
	if(!top && !left)
	{
		mobj.style.top=((yh/2)-(h/2))+"px";
			
		mobj.style.left=((yw/2)-(w/2))+"px";
	}else{
		if(!top)
		{
			mobj.style.top=((yh/2)-(h/2))+"px";
				
			mobj.style.left=left+"px";
		}else if(!left)
		{
			mobj.style.top=top+"px";
				
			mobj.style.left=((yw/2)-(w/2))+"px";
		}else{
			mobj.style.top=top+"px";
				
			mobj.style.left=left+"px";
		}

	}
	
	if(!Number(cajax))
	{
		ajax_ultimate(url,"__movediv",'','',{"callback":callback,"parameter":parameter});
	}else{
		document.getElementById("move_div_info").innerHTML='<iframe src="'+url+'" hspace="0" vspace="0" frameborder="0" scrolling="'+scrolling+'" height="100%" width="100%"><\/iframe>';
	}
}

function __movediv(data,parameter)
{
	document.getElementById("move_div_info").innerHTML=data;
	if(parameter.callback)
	{
		eval(parameter.callback + "(parameter.parameter,data)");
	}
}

/*小的*/
function small_movediv(url,css,top,left,cssid)
{
	if(!cssid)
	{
		cssid="movediv";
	}
	document.getElementById(cssid).style.display='';
	
	var infos='<div id=move_div_info_sm style="text-align:center;width:100%;height:100%;"><\/div>';
	
	document.getElementById(cssid).innerHTML = '<div id=movediv_sm class="min-wod">'+
		'<div class="min-wod-a" style="position:relative;Z-INDEX: 998;"><img src="/template/default/f/image/open/bg-min-top.gif" /><div style="position:absolute;Z-INDEX: 999; top:3px;right:5px;"><img style="cursor:pointer;" onclick="logoutdiv(\''+cssid+'\')" src="/template/default/f/image/open/frame/close.gif" /></div></div>'+
			'<div class="min-wod-b">'+infos+'</div>'+
		'<div class="min-wod-a"><img src="/template/default/f/image/open/bg-min-bot.gif" /></div>'+
	'</div>';
	
	loading('move_div_info_sm','big');//载入

	var ss=new shade_show("movediv_sm");
	ss.show_fade();//渐变显示调用 
	
	var mobj=document.getElementById("movediv_sm");
	mobj.className=css;
	document.documentElement.scrollTop = 0; 

	var yw = document.documentElement.clientWidth; 
	
	var yh = document.documentElement.clientHeight; 
	
	var w = mobj.clientWidth||mobj.offsetWidth;
	
	var h = mobj.clientHeight||mobj.offsetHeight;
		
	if(!top && !left)
	{
		mobj.style.top=((yh/2)-(h/2))+"px";
			
		mobj.style.left=((yw/2)-(w/2))+"px";
	}else{
		if(!top)
		{
			mobj.style.top=((yh/2)-(h/2))+"px";
				
			mobj.style.left=left+"px";
		}else if(!left)
		{
			mobj.style.top=top+"px";
				
			mobj.style.left=((yw/2)-(w/2))+"px";
		}else{
			mobj.style.top=top+"px";
				
			mobj.style.left=left+"px";
		}

	}
	
	ajax_ultimate(url,'','','','move_div_info_sm');
}

function logoutdiv(cssid)
{
	if(!cssid)
	{
		cssid="movediv";
	}
	document.getElementById(cssid).style.display='none';
}


function canmove(elementToDrag, event)
{
	if(document.getElementById('yesmove')!=null)
	{
		if(document.getElementById('yesmove').checked!=true){return false;}
	}
	var deltaX = event.clientX - parseInt(elementToDrag.style.left);
	var deltaY = event.clientY - parseInt(elementToDrag.style.top);
	
	elementToDrag.style.cursor = "move";
	
	if (document.addEventListener)
	{//2 级 DOM事件模型
		document.addEventListener("mousemove", moveHandler, true);
		document.addEventListener("mouseup", upHandler, true);
	}else if (document.attachEvent){//IE5+事件模型
	
		document.attachEvent("onmousemove", moveHandler);
		document.attachEvent("onmouseup", upHandler);
	}else {//IE4事件模型
		document.onmousemove = moveHandler;
		document.onmouseup = upHandler;
	}
	
	//禁止起泡
	if (event.stopPropagation)//DOM2
	event.stopPropagation();
	else event.cancelBubble = true;//IE
	
	if (event.preventDefault)
	event.preventDefault();
	else event.cancelBubble = true;
	
	function moveHandler(e)
	{
		if (!e)
		e = window.event;
		
		elementToDrag.style.left = (e.clientX - deltaX) + "px";
		elementToDrag.style.top = (e.clientY - deltaY) + "px";
		
		if (e.stopPropagation)
		e.stopPropagation();
		else e.cancelBubble = true;
	}
	
	function upHandler(e)
	{
		if (!e)
		e = window.event;
		
		elementToDrag.style.cursor = "default";
		
		if (document.removeEventListener)
		{ //DOM2
			document.removeEventListener('mousemove', moveHandler, true);
			document.removeEventListener('mouseup', upHandler, true);
			
		}else if (document.detachEvent) 
		{ //IE5+
			document.detachEvent("onmousemove", moveHandler);
			document.detachEvent("onmouseup", upHandler);
			
			
		}else {//IE4
			document.onmousemove = moveHandler;
			document.onmouseup = upHandler;
		}
		
		if (e.stopPropagation)
		e.stopPropagation();
		else e.cancelBubble = true;
	}
}

/*取得DIV的背景图*/

function divbackimg(id)
{

	return document.getElementById(id).style.backgroundImage.replace("url(","").replace(")","");
}


/*清理多余HTML代码 content要处理的字符串*/
function DelHtml(content)
{
		a = content.indexOf("<");
		b = content.indexOf(">");
		len = content.length;
		c = content.substring(0, a);
		if(b == -1)
		b = a;
		d = content.substring((b + 1), len);
		content = c + d;
		tagCheck = content.indexOf("<");
		if(tagCheck != -1)
		content = DelHtml(content);
		return content;
} 


/*删除HTML元素比如层 表格等 obj可以似乎ID也可以是对象*/
function Delhtml(obj)
{
	if(typeof(obj)!="object")
	{
		obj = document.getElementById(obj);
	}
	
	obj.parentNode.removeChild(obj);
}

function getIE(e)
{  
	var coordinate=Array;
	var   t=e.offsetTop;
	var   l=e.offsetLeft;
 	while(e=e.offsetParent)
	{  
	  t+=e.offsetTop;  
	  l+=e.offsetLeft;  
	}
	coordinate['top']=t;
	coordinate['left']=l;
	return coordinate;
}


function getEvent() //同时兼容ie和ff的写法
{ 
	if(document.all)  return window.event;   
	func=getEvent.caller;       
	while(func!=null){ 
		var arg0=func.arguments[0];
		if(arg0)
		{
		  if((arg0.constructor==Event || arg0.constructor ==MouseEvent) || (typeof(arg0)=="object" && arg0.preventDefault && arg0.stopPropagation))
		  { 
		  return arg0;
		  }
		}
		func=func.caller;
	}
	return null;
}
	
function goto(url)
{
	window.location.href=url;
}


// 1.判断select选项中 是否存在Value="paraValue"的Item        
function is_select_item_value(objSelect, objItemValue)
{        
    var isExit = false;        
    for (var i = 0; i < objSelect.options.length; i++) {        
        if (objSelect.options[i].value == objItemValue) {        
            isExit = true;        
            break;        
        }        
    }        
    return isExit;        
}         
   
// 2.向select选项中 加入一个Item        
function add_select_item(objSelect, objItemText, objItemValue)
{        
    //判断是否存在        
    if (is_select_item_value(objSelect, objItemValue)) {        
       // alert("该Item的Value值已经存在");
	   return false;      
    } else {
        var varItem = new Option(objItemText, objItemValue);      
        objSelect.options.add(varItem);    
		return true;         
    }        
}        
   
// 3.从select选项中 删除一个Item        
function del_select_item(objSelect, objItemValue)
{        
    //判断是否存在        
    if (is_select_item_value(objSelect, objItemValue)) {        
        for (var i = 0; i < objSelect.options.length; i++) {        
            if (objSelect.options[i].value == objItemValue) {        
                objSelect.options.remove(i);        
                break;        
            }        
        }        
       // alert("成功删除");     
	   return true;         
    } else {        
        //alert("该select中 不存在该项"); 
		return false;             
    }        
}    
   
   
// 4.删除select中选中的项    
function del_select_item_selected(objSelect)
{        
    var length = objSelect.options.length - 1;    
    for(var i = length; i >= 0; i--){    
        if(objSelect[i].selected == true){    
            objSelect.options[i] = null;    
        }    
    }    
}      
   
// 5.修改select选项中 value="paraValue"的text为"paraText"        
function update_select_item(objSelect, objItemText, objItemValue)
{        
    //判断是否存在        
    if (is_select_item_value(objSelect, objItemValue)) {        
        for (var i = 0; i < objSelect.options.length; i++) {        
            if (objSelect.options[i].value == objItemValue) {        
                objSelect.options[i].text = objItemText;        
                break;        
            }        
        }        
        //alert("成功修改");  
		return true;       
    } else {        
       // alert("该select中 不存在该项");   
		return false;           
    }        
}        
   
// 6.设置select中text="paraText"的第一个Item为选中        
function set_select_item_selected(objSelect, objItemText)
{            
    //判断是否存在        
    var isExit = false;        
    for (var i = 0; i < objSelect.options.length; i++) {        
        if (objSelect.options[i].text == objItemText) {        
            objSelect.options[i].selected = true;        
            isExit = true;        
            break;        
        }        
    }              
    //Show出结果        
    if (isExit) {        
       // alert("成功选中");       
	   return true; 
    } else {        
       // alert("该select中 不存在该项");  
	   return false;      
    }        
}   

// 6.设置select中value="paraText"的第一个Item为选中        
function set_select_item(objSelect, objItemvalue)
{            
    //判断是否存在        
    var isExit = false;        
    for (var i = 0; i < objSelect.options.length; i++) {        
        if (objSelect.options[i].value == objItemvalue) {        
            objSelect.options[i].selected = true;        
            isExit = true;        
            break;        
        }        
    }              
    //Show出结果        
    if (isExit) {        
       // alert("成功选中");       
	   return true; 
    } else {        
       // alert("该select中 不存在该项");  
	   return false;      
    }        
}      


//将json字符串转车对象
function json_x(str)
{

	str=ctrim(str,0);
	
	var maxs=str.length-1;
	
	if((str.substr(0,1)=="{"||str.substr(0,1)=="[")&& (str.substr(maxs,1)=="}" ||str.substr(maxs,1)=="]"))
	{
		
		return eval('('+str+')');
	}else{
		return false;
	}
}

function ctrim(sInputString,iType)
{
	var sTmpStr = ' '
	var i = -1
	if(iType == 0 || iType == 1)
	{
		while(sTmpStr == ' ')
		{
			++i
			sTmpStr = sInputString.substr(i,1)
		}
		sInputString = sInputString.substring(i)
	}
	
	if(iType == 0 || iType == 2)
	{
		sTmpStr = ' '
		i = sInputString.length
		while(sTmpStr == ' ')
		{
			--i
			sTmpStr = sInputString.substr(i,1)
		}
		sInputString = sInputString.substring(0,i+1)
	}
	return sInputString
}

function isobj(str)
{
	if(typeof(str)=='object')
	{
		return true;
	}
	return false;
}

//汉字截取
function mSubstr(str,slen)
{ 
	var tmp = 0;
	var len = 0;
	var okLen = 0;
	for(var i=0;i<slen;i++)
	{
		if(str.charCodeAt(i)>255)
		{
			tmp += 2;
		}else{
			len += 1;
		}
		okLen += 1;
		if(tmp + len == slen) 
		{
			return (str.substring(0,okLen));
			break;
		}
		
		if(tmp + len > slen)
		{
			return (str.substring(0,okLen - 1)); 
			break;
		}
	}
}

//取得时间戳
function timestamp()
{
	return  (new Date()).valueOf();
}

//取得url参数
function getargs()
{ 
    var args = {};
    var query = location.search.substring(1);
    // Get query string
    var pairs = query.split("&"); 
    // Break at ampersand
     for(var i = 0; i < pairs.length; i++)
	 {
		var pos = pairs[i].indexOf('=');
		// Look for "name=value"
		if (pos == -1) continue;
		// If not found, skip
		var argname = pairs[i].substring(0,pos);// Extract the name
		var value = pairs[i].substring(pos+1);// Extract the value
		value = decodeURIComponent(value);// Decode it, if needed
		args[argname] = value;
		// Store as a property
    }
    return args;// Return the object 
 }
