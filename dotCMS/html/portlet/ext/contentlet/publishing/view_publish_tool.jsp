<%@page import="com.liferay.portal.util.WebKeys"%>
<%@page import="com.dotmarketing.business.Layout"%>
<%@page import="com.dotmarketing.util.UtilMethods"%>
<%@page import="com.liferay.portal.model.User"%>
<%@page import="com.dotmarketing.business.web.WebAPILocator"%>
<%@page import="com.dotmarketing.util.URLEncoder"%>
<%@ page import="com.liferay.portal.language.LanguageUtil"%>
<html xmlns="http://www.w3.org/1999/xhtml">

<%
User user = WebAPILocator.getUserWebAPI().getLoggedInUser(request);
if(user == null){
	response.setStatus(403);
	return;
}

Layout layoutOb = (Layout) request.getAttribute(WebKeys.LAYOUT);
String layout = null;
if (layoutOb != null) {
	layout = layoutOb.getId();
}

%>
<script type="text/javascript">
	dojo.require("dijit.form.NumberTextBox");
    dojo.require("dojox.layout.ContentPane");
	
	function doQueueFilter () {
	
		var url="";
		url="layout=<%=layout%>";
		refreshQueueList(url);
	}
	
	function doAuditFilter() {
		var url="";
		url="layout=<%=layout%>";
		refreshAuditList(url);
	}
	
	
	var lastUrlParams ;
	
	function refreshQueueList(urlParams){
		lastUrlParams = urlParams;
		var url = "/html/portlet/ext/contentlet/publishing/view_publish_queue_list.jsp?"+ urlParams;		
		
		var myCp = dijit.byId("queueContent");	
		
		if (myCp) {
			myCp.destroyRecursive(false);
		}
		myCp = new dojox.layout.ContentPane({
			id : "queueContent"
		}).placeAt("queue_results");

		myCp.attr("href", url);
		
		myCp.refresh();

	}
	
	function refreshAuditList(urlParams){
		lastUrlParams = urlParams;
		var url = "/html/portlet/ext/contentlet/publishing/view_publish_audit_list.jsp?"+ urlParams;		
		
		var myCp = dijit.byId("auditContent");	
		
		if (myCp) {
			myCp.destroyRecursive(false);
		}
		myCp = new dojox.layout.ContentPane({
			id : "auditContent"
		}).placeAt("audit_results");

		myCp.attr("href", url);
		
		myCp.refresh();

	}
	
	function doLuceneFilter () {
		
		var url="";
		url="&query="+encodeURIComponent(dijit.byId("query").value);
		url+="&sort="+dijit.byId("sort").value;
		url="layout=<%=layout%>"+url;
		refreshLuceneList(url);

	}
	
	var lastLuceneUrlParams ;
	
	function refreshLuceneList(urlParams){
		lastLuceneUrlParams = urlParams;
		var url = "/html/portlet/ext/contentlet/publishing/view_publish_content_list.jsp?"+ urlParams;		
		
		var myCp = dijit.byId("searchLuceneContent");
		
		
		if (myCp) {
			myCp.destroyRecursive(false);
		}
		myCp = new dojox.layout.ContentPane({
			id : "searchLuceneContent"
		}).placeAt("lucene_results");

		myCp.attr("href", url);
		
		myCp.refresh();

	}
	function loadPublishQueueServers(){
		var url = "/html/portlet/ext/contentlet/publishing/view_publish_servers.jsp";		
		
		var myCp = dijit.byId("instances");	
		
		if (myCp) {
			myCp.destroyRecursive(true);
		}
		myCp = new dojox.layout.ContentPane({
			id : "instances"
		}).placeAt("solr_servers");

		myCp.attr("href", url);
	}
</script>
<div class="portlet-wrapper">
	<div>
		<img src="/html/portlet/ext/contentlet/publishing/images/solr.gif"> <%= LanguageUtil.get(pageContext, "publisher_Manager") %>
		<hr/>
	</div>
	<div id="mainTabContainer" dojoType="dijit.layout.TabContainer" dolayout="false">
  		<div id="searchLucene" dojoType="dijit.layout.ContentPane" title="<%= LanguageUtil.get(pageContext, "publisher_Search") %>" >
  			<div>
				<dl>	
					<dt><strong><%= LanguageUtil.get(pageContext, "publisher_Lucene_Query") %> </strong></dt>
					<dd>
						<textarea dojoType="dijit.form.Textarea" name="query" style="width:500px;min-height: 150px;" id="query" type="text"></textarea>
					</dd>
					<dt><strong><%= LanguageUtil.get(pageContext, "publisher_Sort") %> </strong></dt><dd><input name="sort" id="sort" dojoType="dijit.form.TextBox" type="text" value="modDate" size="10" /></dd>
					<dt><strong><%= LanguageUtil.get(pageContext, "Publish") %> </strong></dt>
					<dd>
						<input 
						type="text" 
						dojoType="dijit.form.DateTextBox" 
						validate="return false;" 
						invalidMessage=""  
						id="publishDate"
						name="publishDate" value="">
						
						
						<input type="text" name="publishDate" id="publishTime" value="T15:00:00"
						  data-dojo-type="dijit.form.TimeTextBox"
						  onChange="dojo.byId('val').value=arguments[0].toString().replace(/.*1970\s(\S+).*/,'T$1')"
						  required="true" />
					</dd>
					
					<dt><strong><%= LanguageUtil.get(pageContext, "publisher_Expire") %> </strong></dt>
					<dd>
						<input 
						type="text" 
						dojoType="dijit.form.DateTextBox" 
						validate="return false;" 
						invalidMessage=""  
						id="expireDate" name="expireDate" value="">
						
						
						<input type="text" name="expireDate" id="expireTime" value="T15:00:00"
						  data-dojo-type="dijit.form.TimeTextBox"
						  onChange="dojo.byId('val').value=arguments[0].toString().replace(/.*1970\s(\S+).*/,'T$1')"
						  required="true" />
					</dd>
						
					
					<dt></dt><dd><button dojoType="dijit.form.Button" onclick="doLuceneFilter();" iconClass="searchIcon"><%= LanguageUtil.get(pageContext, "publisher_Search_Content") %></button></dd>
				</dl>
			</div>
			<hr>
			<div>&nbsp;</div>
			<div id="lucene_results">
			</div>
		</div>	
  		<div id="queue" dojoType="dijit.layout.ContentPane" title="<%= LanguageUtil.get(pageContext, "publisher_Queue") %>" >
  		    <div>
				<button dojoType="dijit.form.Button" onClick="deleteQueue();" iconClass="deleteIcon">
					<%= LanguageUtil.get(pageContext, "publisher_Delete_from_queue") %> 
				</button>
				<%-- &nbsp;&nbsp;<%= LanguageUtil.get(pageContext, "publisher_Show") %> 
				<input dojoType="dijit.form.CheckBox" checked="checked" type="checkbox" name="showPendings" value="true" id="showPendings" onclick="doQueueFilter()" /> <label for="showPendings"><%=LanguageUtil.get(pageContext, "publisher_Queue_Pending")%></label> 
				<input dojoType="dijit.form.CheckBox" checked="checked" type="checkbox" name="showErrors" value="true" id="showErrors"  onclick="doQueueFilter()"  /> <label for="showErrors"><%=LanguageUtil.get(pageContext, "publisher_Queue_Error")%></label> --%>
				<button class="solr_right" dojoType="dijit.form.Button" onClick="doQueueFilter();" iconClass="resetIcon">
					<%= LanguageUtil.get(pageContext, "publisher_Refresh") %> 
				</button> 
			</div>			
			<hr>
			<div>&nbsp;</div>
  			<div id="queue_results">
			</div>
			<script type="text/javascript">
			dojo.ready(function(){
				doQueueFilter();
			});
			</script>
  		</div>
  		
  		<div id="audit" dojoType="dijit.layout.ContentPane" title="<%= LanguageUtil.get(pageContext, "publisher_Audit") %>" >
			<div>
				<button class="solr_right" dojoType="dijit.form.Button" onClick="doAuditFilter();" iconClass="resetIcon">
					<%= LanguageUtil.get(pageContext, "publisher_Refresh") %> 
				</button> 
			</div>			
			<hr>
			<div>&nbsp;</div>
  			<div id="audit_results">
			</div>
			<script type="text/javascript">
			dojo.ready(function(){
				doAuditFilter();
			});
			</script>
  		</div>
  		
  		<div id="instances" dojoType="dijit.layout.ContentPane" title="<%= LanguageUtil.get(pageContext, "publisher_Servers") %>" >
  			<div>
				<%= LanguageUtil.get(pageContext, "publisher_Servers_Intro") %> 
			</div>			
			<hr>
			<div>&nbsp;</div>
  			<div id="solr_servers">
			</div>
			<script type="text/javascript">
			dojo.ready(function(){
				loadPublishQueueServers();
			});
			</script>
  		</div>
	</div>
</div>


