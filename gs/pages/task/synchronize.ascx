﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="synchronize.ascx.cs" Inherits="GalleryServerPro.Web.Pages.Task.synchronize" %>
<%@ Import Namespace="GalleryServerPro.Web" %>
<div class="gsp_content">
  <asp:PlaceHolder ID="phTaskHeader" runat="server" />
  <div class="gsp_addleftpadding1" runat="server">
    <p class="gsp_h3">
      <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Album_Title_Prefix_Text %>" />&nbsp;<asp:Label
        ID="lblAlbumTitle" runat="server" />
    </p>
    <hr />
    <p class="gsp_textcol">
      <asp:Label ID="lblInstructions" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Body_Text %>" />
    </p>
    <div class="gsp_addleftpadding6">
      <p>
        <input id="chkIncludeChildAlbums" type="checkbox" /><label for="chkIncludeChildAlbums"><asp:Literal
          ID="lit1" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_IncludeChildAlbums_Text %>" />
        </label>
        <asp:Label ID="lblIncludeChildAlbums" runat="server" />
      </p>
      <p>
        <input id="chkOverwriteThumbnails" type="checkbox" /><label for="chkOverwriteThumbnails"><asp:Literal
          ID="lit2" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_OverwriteThumbnails_Text %>" />
        </label>
        <asp:Label ID="lblOverwriteThumbnails" runat="server" />
      </p>
      <p>
        <input id="chkOverwriteCompressed" type="checkbox" /><label for="chkOverwriteCompressed"><asp:Literal
          ID="lit3" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_OverwriteCompressed_Text %>" />
        </label>
        <asp:Label ID="lblOverwriteCompressed" runat="server" />
      </p>
    </div>
    <div id="<%= cid %>_gsp_sync_sts" class="gsp_sync_sts gsp_single_tab">
      <div class="gsp_single_tab_hdr">
        <span class="gsp_single_tab_hdr_txt"><asp:Literal ID="l4b" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Status_Text %>" /></span>
      </div>
      <div class="gsp_single_tab_bdy gsp_dropshadow3">
        <div class="gsp_sync_pb_ctr">
          <div class="gsp_sync_pb">
          </div>
        </div>
        <p class="gsp_sync_sts_cursts">
          <span class="gsp_sync_sts_cursts_hdr">
            <asp:Literal ID="l5" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Progress_Status_Text %>" />
          </span><span class="gsp_sync_sts_cursts_msg"></span>&nbsp;<a href="#" class="gsp_sync_sts_cursts_abort_ctr" title='<asp:Literal ID="l8" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Close_Button_Tooltip %>" />'><asp:Literal ID="l7" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Cancel_Button_Text %>" /></a><img src="<%=Utils.GetSkinnedUrl("/images/wait-squares.gif")%>" class="gsp_invisible gsp_sync_sts_spinner" alt="" />
        </p>
        <p class="gsp_sync_sts_rate">
          <span class="gsp_sync_sts_rate_hdr">
            <asp:Literal ID="l4" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Progress_SynchRate_Text %>" />
          </span><span class="gsp_sync_sts_rate_msg"></span>
        </p>
        <p class="gsp_sync_sts_curfile">
          <span class="gsp_sync_sts_curfile_hdr">
            <asp:Literal ID="l6" runat="server" Text="<%$ Resources:GalleryServerPro, Task_Synch_Progress_Processing_Text %>" />
          </span><span class="gsp_sync_sts_curfile_msg"></span>
        </p>
      </div>
    </div>
  </div>
  <asp:PlaceHolder ID="phTaskFooter" runat="server" />
</div>
<asp:PlaceHolder runat="server">
  <script id='tmplSyncSkippedFiles' type='text/x-jsrender'>
    <%= SyncCompleteJsRenderTemplate %>
  </script>
  <script>
	(function ($) {
	  var serverTask;

	  $(document).ready(function () {
	    bindEventHandlers();
	    configTooltips();
	  });

	  var bindEventHandlers = function() {
	    $("#<%= OkButtonTop.ClientID %>,#<%= OkButtonBottom.ClientID %>").click(function() {
		    beginSync();
		    return false;
		  });
		};

    var beginSync = function() {
      var updateUi = function(status) {
        var ctr = $("#<%= cid %>_gsp_sync_sts");

			  ctr.show();
			  $(".gsp_sync_sts_cursts_msg", ctr).text(status.StatusForUI);
			  $(".gsp_sync_sts_rate_msg", ctr).text(status.SyncRate);
			  $(".gsp_sync_sts_curfile_msg", ctr).text(status.CurrentFile);
			  $(".gsp_sync_sts_spinner", ctr).show();
			  $(".gsp_sync_pb", ctr).width(status.PercentComplete + '%');

			  var showFinalMsg = function() {
			    if (status.Status == "Complete") {
			      var tmplData = $("#tmplSyncSkippedFiles").render(status);
			      if (status.SkippedFiles.length == 0) {
			        $.gspShowMsg('Synchronization Complete', tmplData, { autoCloseDelay: 0 });
			      } else { // Some files were skipped, so make the dialog a bit wider.
			        $.gspShowMsg('Synchronization Complete', tmplData, { autoCloseDelay: 0, width: 700 });
			      }
			    } else if (status.Status == "Error") {
			      $.gspShowMsg('Synchronization error', 'An error occurred while synchronizing the gallery. Additional details may be found in the gallery\'s event log.', { msgType: 'error', autoCloseDelay: 0 });
			    } else if (status.Status == "AnotherSynchronizationInProgress") {
			      $.gspShowMsg('Cannot start synchronization', 'Another synchronization is in progress. To forcefully cancel it, restart the application pool.', { msgType: 'info', autoCloseDelay: 0 });
			    }
			  };

			  showFinalMsg();
			};

			var userDefinedProgressCallback = function(status, serverTaskInstance) {
			  // We've received a status report from the server. Update the screen. If the status indicates the action is complete,
			  // cancel the server polling.
			  updateUi(status);

			  if (status.Status == "Complete" || status.Status == "Error" || status.Status == "AnotherSynchronizationInProgress" || status.Status == "Aborted") {
			    serverTaskInstance.resetTask();

			    $(".gsp_sync_sts_cursts_abort_ctr, .gsp_sync_sts_spinner", $("#<%= cid %>_gsp_sync_sts")).hide();
        }
			};

		  var configAbortFunctionality = function() {
		    $(".gsp_sync_sts_cursts_abort_ctr", $("#<%= cid %>_gsp_sync_sts")).one("click", function(e) {
			    // Send signal to server to cancel when user clicks cancel button.
			    if (serverTask != null)
			      serverTask.abortTask();

			    $(this)
						.text(window.<%= cid %>.gspData.Resource.SyncAborting)
						.prop('disabled', true);

				}).text(window.<%= cid %>.gspData.Resource.SyncAbort)
					.prop('disabled', false).show();
			  
					$("#<%= CancelButtonTop.ClientID %>,#<%= CancelButtonBottom.ClientID %>").click(function() {
						if (serverTask != null)
							serverTask.abortTask();
					});
			};

		  var albumId = window.<%= cid %>.gspData.Album.Id;
		  var galleryId = window.<%= cid %>.gspData.Album.GalleryId;

		  var serverTaskOptions = {
		    userDefinedProgressCallback: userDefinedProgressCallback,
		    taskAbortedCallback: null,
		    taskBeginData: {
		      AlbumIdToSynchronize: albumId,
		      IsRecursive: $('#chkIncludeChildAlbums').prop('checked'),
		      RebuildThumbnails: $('#chkOverwriteThumbnails').prop('checked'),
		      RebuildOptimized: $('#chkOverwriteCompressed').prop('checked'),
		      SyncInitiator: 1 // SyncInitiator.LoggedOnGalleryUser
		    },
		    taskBeginUrl: window.Gsp.AppRoot + '/api/task/startsync',
		    taskProgressUrl: window.Gsp.AppRoot + '/api/task/' + galleryId + '/statussync',
		    taskAbortUrl: window.Gsp.AppRoot + '/api/task/' + galleryId + '/abortsync',
		  };

		  serverTask = new window.Gsp.ServerTask(serverTaskOptions);
		  serverTask.startTask();

		  updateUi({ Status: 'Starting', StatusForUI: window.<%= cid %>.gspData.Resource.SyncStarting, SyncRate: '', CurrentFile: '', PercentComplete: 0 });
    configAbortFunctionality();
  };

  var configTooltips = function() {
    $('#<%= lblIncludeChildAlbums.ClientID %>').gspTooltip({
	      title: '<%= Resources.GalleryServerPro.Task_Synch_IncludeChildAlbums_Hlp_Hdr.JsEncode() %>',
	      content: '<%= Resources.GalleryServerPro.Task_Synch_IncludeChildAlbums_Hlp_Bdy.JsEncode() %>'
	    });

	    $('#<%= lblOverwriteThumbnails.ClientID %>').gspTooltip({
	      title: '<%= Resources.GalleryServerPro.Task_Synch_OverwriteThumbnails_Hlp_Hdr.JsEncode() %>',
	      content: '<%= Resources.GalleryServerPro.Task_Synch_OverwriteThumbnails_Hlp_Bdy.JsEncode() %>'
	    });

	    $('#<%= lblOverwriteCompressed.ClientID %>').gspTooltip({
	      title: '<%= Resources.GalleryServerPro.Task_Synch_OverwriteCompressed_Hlp_Hdr.JsEncode() %>',
	      content: '<%= Resources.GalleryServerPro.Task_Synch_OverwriteCompressed_Hlp_Bdy.JsEncode() %>'
	    });

	    $('#<%= lblInstructions.ClientID %>').gspTooltip({
	      title: '<%= Resources.GalleryServerPro.Task_Synch_Options_Hlp_Hdr.JsEncode() %>',
	      content: '<%= Resources.GalleryServerPro.Task_Synch_Options_Hlp_Bdy.JsEncode() %>'
	    });
	  };
    })(jQuery);
  </script>
</asp:PlaceHolder>
