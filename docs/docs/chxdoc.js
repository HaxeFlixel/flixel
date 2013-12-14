
function showInherited(name, visibile) {
	//if IE
	// document.styleSheets[0].rules
	var r = document.styleSheets[0].cssRules;
	if(r == undefined) {
		document.styleSheets[0].addRule(".hideInherited" + name, visibile ? "display:inline" : "display:none");
		document.styleSheets[0].addRule(".showInherited" + name, visibile ? "display:none" : "display:inline");
	}
	else {
		for (var i = 0; i < r.length; i++) {
			if (r[i].selectorText == ".hideInherited" + name)
				r[i].style.display = visibile ? "inline" : "none";
			if (r[i].selectorText == ".showInherited" + name)
				r[i].style.display = visibile ? "none" : "inline";
		}
	}

	setCookie(
		"showInherited" + name,
		visibile ? "true" : "false",
		10000,
		"/",
		document.location.domain);
}

function initShowInherited() {
    showInherited("Var", getCookie("showInheritedVar") == "true");
    showInherited("Method", getCookie("showInheritedMethod") == "true");
}

function setCookie(name, value, days, path, domain, secure) {
	var endDate=new Date();
	endDate.setDate(endDate.getDate() + days);

	document.cookie =
		name + "=" + escape(value) +
		((days==null) ? "" : ";expires=" + endDate.toGMTString()) +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

function getCookie(name) {
	if (document.cookie.length>0) {
		begin=document.cookie.indexOf(name + "=");
		if (begin != -1) {
			begin = begin + name.length + 1;
			end = document.cookie.indexOf(";",begin);
			if(end==-1)
				end=document.cookie.length;
			return unescape(document.cookie.substring(begin,end));
		}
	}
	return "";
}

function isIE() {
	if(navigator.appName.indexOf("Microsoft") != -1)
		return true;
	return false;
}

initShowInherited();