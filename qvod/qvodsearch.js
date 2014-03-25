var dochistory = [];
var qvodurl_arr=[];

function inTeam(team,value){
    var result = false;
    for(var _findex in team){
		if (team[_findex] == value){
            result = true;}}
    return result;
}

function pobject(doc){
    var b=false;
    var tmpembedobj=doc.getElementsByTagName("object")    
    if(tmpembedobj && tmpembedobj.length){
		for(var i=0;i<tmpembedobj.length;i++){
			var tmpe=tmpembedobj[i].getElementsByTagName("embed")	    
			if(tmpe && tmpe.length>0){
				for (var j=0;j<tmpe.length;j++){
					b=true
					if(tmpe[j].getAttribute("url")){
						qvodurl_arr[qvodurl_arr.length]=tmpe[j].getAttribute("url")}}}}}
    return b;
}

function startsearch(docums)
{
    var qvodurl=[];
    var tmpembedobj=docums.getElementsByTagName("object")
	
    if(tmpembedobj && tmpembedobj.length){
    	pobject(docums)
    	if(qvodurl_arr.length==0){
    	    var tmpembedobj=docums.getElementsByTagName("iframe")            
            if(tmpembedobj){
    	    	for(var i=0;i<tmpembedobj.length;i++){
    	    	    var h=get_b_obj(tmpembedobj[i])
					if(h){
		    			pobject(h)}}}}
    }
    else{
    	var tmpembedobj=docums.getElementsByTagName("iframe")	
    	if(tmpembedobj){
			for(var i=0;i<tmpembedobj.length;i++){
	    		var h=get_b_obj(tmpembedobj[i])
	    		if(h){
	    			pobject(h)}}}}
    
    if(qvodurl_arr.length==false){
		alert("No Qvod URL found on this page!")
		return
    }
    
    qvodurl=qvodurl_arr
    
    for(var _index in qvodurl){
    	if (inTeam(dochistory,qvodurl[_index])){
    	}
		else{
    	    if(qvodurl[_index].substr(0,4)=="http"){
    			var mypostdata="url="+encodeURI(qvodurl[_index])
				ajax_ultimate("http://www.qvodsou.com/http2qvod/http2qvod.do?url="
							  +mypostdata,"httpis_oks","post",mypostdata,qvodurl[_index])
			}
			else{
				var mypostdata=qvodurl[_index]
				ajax_ultimate("http://localhost:62351","is_oks",
							  "post",mypostdata,qvodurl[_index])}}}}

function get_b_obj(objs){
    if(objs){
		if(objs.contentWindow){
			return objs.contentWindow.document;
		}
		else if(objs.contentDocument){
			return objs.contentDocument.body;}}
    return false;
}

function is_oks(e,addurl){
    if(e.trim()=="ok"){
		dochistory.push(addurl);
		alert("Qvod URL sent successfully!")
    }else{
		alert("Qvod URL sent failed!")
    }
}

function httpis_oks(e,addurl){
    var res_=e.match('转换:<\/td><td>(.*?)<\/td>');
    if(res_.length==2 && res_[1].substr(0,4)=="qvod"){
		var mypostdata=res_[1]
		ajax_ultimate("http://localhost:62351","is_oks","post",mypostdata,res_[1])
    }else{
		alert("Convertion from http address to Qvod address failed!")
    }
}


function keyDown(e){
    var keycode = e.which;
    var realkey = String.fromCharCode(e.which);
    if (e.ctrlKey && keycode == 81){
		startsearch(document);
    }
}

document.onkeydown = keyDown;
