function newStep(cStep) {
   
   
   var para = document.createElement("div");
    para.innerHTML = '<div class="row form-group"><label class="col-sm-1 control-label" for="step">Step</label><div class="col-sm-5 form-horizontal"><input id="step" name="step" type="text" placeholder="placeholder" class="form-control input-md step"></input></div><div class="col-md-4"><button id="singlebutton" name="singlebutton" class="btn" onclick="newStep(this)">+</button></div></div>';
    
    
    var element = document.getElementById("set");
    
    var parent = cStep.parentNode.parentNode;
    var grandpa = parent.parentNode;
    console.log('xxx');
    
    if (parent.nextSibling) {
        grandpa.insertBefore( para,  parent.nextSibling);
    } else {
        grandpa.appendChild(para);
    }
    
   
}


function generate() {
    var pre = document.getElementById("dita");
    
    var title = document.getElementsByClassName("title")[0];
    var shortdesc = document.getElementsByClassName("shortdesc")[0];
    var steps = document.getElementsByClassName("step");
    
    
    var ditaContent = '<task id="create_google_account">\n';
    ditaContent += '<title>' + title.value + '</title>\n';
    ditaContent += '<shortdesc>' + shortdesc.value + '</shortdesc>\n';
    
    ditaContent += '<taskbody>\n';
    
    ditaContent += '<steps>\n';
    
    for (var i=0;i < steps.length;i++) {
       ditaContent += '  <step>\n';
       
       ditaContent += '    <cmd>';
       
       ditaContent += steps[i].value;
       
       ditaContent += '</cmd>\n';
       
       ditaContent += '  </step>\n';
    }
    
    ditaContent += '</steps>\n';
    ditaContent += '</taskbody>\n';
    ditaContent += '</task>\n';
    
    
    pre.innerHTML = "<pre>" + safe_tags_replace(ditaContent) + "</pre>"
}

var tagsToReplace = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;'
};

function replaceTag(tag) {
    return tagsToReplace[tag] || tag;
}

function safe_tags_replace(str) {
    return str.replace(/[&<>]/g, replaceTag);
}