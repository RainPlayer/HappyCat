<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ include file="/commons/global.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>用户管理</title>
<%@ include file="/commons/superuiBase.jsp"%>
<script type="text/javascript">
	var userid=<shiro:principal property="id"/>;
	var cuarrentPageNumber = 1;
	var totalPage;
	var eachPageSize = 3;
	var managed_userid=0;
	
	$(document).ready(function() {
				var page1 = $($($("#splitPage").children()[0]).children()[1])
						.children();
				getPageInfo(page1);
	});

	function getPageInfo(obj) {
		//alert($(obj).html());
		size = eachPageSize;
		var page = $(obj).html().trim();

		if (page > totalPage) {
			return;
		}

		$("#splitPage ul").children().removeClass("active");
		$(obj).parent().addClass("active");

		var url = "${base}/user/getPageUser";
		$.ajax({
			url : url,
			data : {
				page : page,
				size : size
			},
			type : 'post',
			cache : false,
			dataType : 'json',
			success : function(data) {
				//data={"success":true,"msg":"","obj":{"pageNum":1,"pageSize":6,"size":2,"orderBy":null,"startRow":1,"endRow":2,"total":2,"pages":1,"list":[{"id":1,"loginname":"hendy","name":"hendy","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"15851732142","email":"87026928@qq.com"},{"id":2,"loginname":"tom","name":"sacukra","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"123456","email":"8888@qq.com"}],"firstPage":1,"prePage":0,"nextPage":0,"lastPage":1,"isFirstPage":true,"isLastPage":true,"hasPreviousPage":false,"hasNextPage":false,"navigatePages":8,"navigatepageNums":[1]}}
				if (data.success == true) {

					//设置全局变量
					cuarrentPageNumber = data.obj.pageNum;
					totalPage = data.obj.pages;

					//alert(data.obj.list.length);
					showTable(data.obj.list);

					splitPage();

				} else {
					//alert(data.msg);
					//showMsg('warning',data.msg);
				}
			},
			error : function() {
				// view("异常！");  
				showMsg('error', '未知错误请联系管理员');
			}
		});
	}
	//控制分页前一页、后一页禁用等
	function splitPage() {
		var ul = $("#splitPage").children()[0];
		var lis = $(ul).children();
		if (cuarrentPageNumber <= lis.length - 2) {

			$("#prePage").addClass("disabled");
		} else {
			$("#prePage").removeClass("disabled");
		}

		//alert(lis.length);
		for (var i = 1; i < lis.length - 1; i++) {
			//alert($(lis[i]).html().trim());
			if ($(lis[i]).children().html().trim() > totalPage) {
				$(lis[i]).addClass("disabled");
			} else {
				$(lis[i]).removeClass("disabled");
			}
		}
		//alert($(lis[lis.length-2]).children().html().trim());
		if ($(lis[lis.length - 2]).children().html().trim() >= totalPage) {
			$(lis[lis.length - 1]).addClass("disabled");
		} else {
			$(lis[lis.length - 1]).removeClass("disabled");
		}
	}
	
	function nextPages() {
		var ul = $("#splitPage").children()[0];
		var lis = $(ul).children();
		var size = lis.length - 2;
		if ($(lis[lis.length - 2]).children().html().trim() >= totalPage) {
			return;
		}
		for (var i = 1; i < lis.length - 1; i++) {
			var oldValue = $(lis[i]).children().html().trim();
			$(lis[i]).children().html(parseInt(oldValue) + size);
		}
		var page1 = $($($("#splitPage").children()[0]).children()[1])
				.children();
		getPageInfo(page1);
	}
	
	function prePage() {
		var ul = $("#splitPage").children()[0];
		var lis = $(ul).children();
		var size = lis.length - 2;

		var page1 = $($($("#splitPage").children()[0]).children()[1])
				.children();
		//alert(page1.html().trim());
		if (page1.html().trim() > size) {
			for (var i = 1; i < lis.length - 1; i++) {
				var oldValue = $(lis[i]).children().html().trim();
				$(lis[i]).children().html(parseInt(oldValue) - size);
			}
			getPageInfo(page1);
		}
	}
	
	function showTable(lst){
		//增加table头内容
		$("#userInfoTb thead").empty();
		var thead=$("#userInfoTb thead");
		if(lst.length>0){
			var tr=$("<tr></tr>");
			for(var key in lst[0] ){
				if(key=='password' ||key=='icon'){
					continue;
				}
				$(tr).append("<th>"+key+"</th>");
			}
		}
		$(thead).append(tr);
		//增加table体内容
		$("#userInfoTb tbody").empty();
		for(var i=0;i<lst.length;i++){
			var tr=$("<tr></tr>");
			for(var key in lst[i] ){
				if(key=='password' ||key=='icon'){
					continue;
				}
				$(tr).append("<td>"+lst[i][key]+"</td>");
				//alert(lst[i][key]);
			}
			$(tr).append("<td><a data-toggle='modal' onclick='edit(this)' href='#edit'>编辑</a></td>");
			$(tr).append("<td><a data-toggle='modal' onclick='openManage(this)' href='javascript:void(0)'>管理</a></td>");
			$("#userInfoTb tbody").append(tr);
		}
	}
	
	function showMsg(type,msg){
		//var arry=new Array('success','success','info','warning','error');
		toastr.options = {
				  "closeButton": true,
				  "debug": false,
				  "positionClass": "toast-top-right",
				  "onclick": null,
				  "showDuration": "1000",
				  "hideDuration": "6000",
				  "timeOut": "5000",
				  "extendedTimeOut": "1000",
				  "showEasing": "swing",
				  "hideEasing": "linear",
				  "showMethod": "fadeIn",
				  "hideMethod": "fadeOut"
				}
		toastr[type](msg, "提示");
	}
	
	function edit(obj){
		var srcTable=$("#userInfoTb");
		var ul=$("#modal-table");
		var srcThead=$("#userInfoTb thead");
		
		var tr=$(obj).parent().parent();
		var tds=$(tr).children();
		
		var head_tr=$(srcThead).children()[0];
		//alert(head_tr.innerHtml);
		var ths=$(head_tr).children();
		//for(var i=0;i<ths.length-1;i++){
			//var value=$(ths[i]).html();
		//}
		$(ul).empty();
		for(var i=0;i<tds.length-1;i++){
			var key=$(ths[i]).html();
			//alert(key.length);
			
			//alert(key+';')
			var value=$(tds[i]).html();
			var li=$('<li class="list-group-item"><span>'+key+'</span>:<input type="text" class="form-control" '+key+' value="'+value+'"></li>');
			$(ul).append(li);
		}
	}
	
	function save(){
		var ul=$("#modal-table");
		var map={};
		for(var i=0;i<$(ul).children().length;i++){
			var item=$(ul).children()[i];
			var key=$(item).children('span').html();
			var value=$(item).children('input').val();
			if(value=='null'){
				continue;
			}
			map[key]=value;
		}
		var url="${base}/user/updateUser";
		$.ajax({
			url : url, 
			data :JSON.stringify(map),
			type : 'post',
			headers: { 
		        'Accept': 'application/json',
		        'Content-Type': 'application/json' 
		    },
			cache : false,
			dataType : 'json',
			success : function(data) {
				//data={"success":true,"msg":"","obj":{"pageNum":1,"pageSize":6,"size":2,"orderBy":null,"startRow":1,"endRow":2,"total":2,"pages":1,"list":[{"id":1,"loginname":"hendy","name":"hendy","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"15851732142","email":"87026928@qq.com"},{"id":2,"loginname":"tom","name":"sacukra","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"123456","email":"8888@qq.com"}],"firstPage":1,"prePage":0,"nextPage":0,"lastPage":1,"isFirstPage":true,"isLastPage":true,"hasPreviousPage":false,"hasNextPage":false,"navigatePages":8,"navigatepageNums":[1]}}
				if (data.success == true) { 
					showMsg('success',data.msg);
				} else {
					showMsg('warning',data.msg);
				}
				$('#edit').modal('hide');
				$("#close").click();
			},
			error : function() {
				showMsg('error','未知错误请联系管理员');
			}
		});
		
	}
	function openManage(obj){
		var tr=$(obj).parent().parent();
		managed_userid=$($(tr).children()[0]).html();
		//alert(managed_userid);
		loadAllRole();
		$("#manage").modal('show');
	}
	function ajaxCommon(url,data,callBack){
		var result='null';
		if(data==null){
			data={};
		}
		//data=JSON.stringify(data);
		$.ajax({
			url : url,
			data:data,
			type : 'post',
			cache : true,
			async: false, 
			dataType : 'json',
			success : function(data) {
				//data={"success":true,"msg":"","obj":{"pageNum":1,"pageSize":6,"size":2,"orderBy":null,"startRow":1,"endRow":2,"total":2,"pages":1,"list":[{"id":1,"loginname":"hendy","name":"hendy","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"15851732142","email":"87026928@qq.com"},{"id":2,"loginname":"tom","name":"sacukra","password":null,"sex":1,"age":18,"usertype":1,"status":1,"createdate":"2016-05-27 00:00:00","phone":"123456","email":"8888@qq.com"}],"firstPage":1,"prePage":0,"nextPage":0,"lastPage":1,"isFirstPage":true,"isLastPage":true,"hasPreviousPage":false,"hasNextPage":false,"navigatePages":8,"navigatepageNums":[1]}}
				if (data.success == true) {
					result=data.obj;
					if(callBack!=null){
						callBack(data);
					}
				} else {
					showMsg('warning',data.msg);
				}
			},
			error : function() {
				showMsg('error','未知错误请联系管理员');
			}
		});
		return result;
	}
	
	
	
	
	function loadAllRole(){
		sdata={};
		sdata['id']=managed_userid;
		//alert(JSON.stringify(sdata));
		//return;
		var resList=
			ajaxCommon('${base}/user/findUserRoleByUserId',sdata,null);
		//alert(resList.length);
		var url="${base}/role/getAllRole";
		ajaxCommon(url,null,function(data){
			var list=data.obj;
			$("#roleCheck").empty();
			for(var i=0;i<list.length;i++){
				$("#roleCheck").append(list[i].name+':<input name="role" data-id="'+list[i].id+'" onclick="check(this)" type="checkbox" value="'+list[i].id+'" />&nbsp;&nbsp;&nbsp;');
			}
			
			var nlist=$("#roleCheck").children("input");
			for(var i=0;i<nlist.length;i++){
				for(var j=0;j<resList.length;j++){
					console.log($(nlist[i]).attr("data-id")+"    "+resList[j].id);
					if($(nlist[i]).attr("data-id")== resList[j].id){
						$(nlist[i]).attr("checked","checked");
					}		
					
				}
			}
			
			
			//123
			//12
			
		});
	}
	function check(obj){
		//$(obj).prop("checked",true);
		if($(obj).attr("checked")=="checked"){
			$(obj).removeAttr("checked");
		}else{
			$(obj).attr("checked","checked");
		}
	}
	function saveUserRole(){
		user_id=managed_userid;
		var list=$("#roleCheck").children("input[checked=checked]");
		//alert(list.length);
		var value="";
		for (var i=0;i<list.length;i++){
			value+=$(list[i]).val();
			value+="-";
		}
		var url="${base}/user/saveUserRole";
		data={userid:user_id,value:value}
		ajaxCommon(url, data, function(data){
			alert(data.msg);
			showMsg(data.msg);
			$('#manage').modal('hide');
		});
	}
	
</script>
</head>
<body>
	<div class="col-md-12">

		<!-- BEGIN SAMPLE TABLE PORTLET-->
		<div class="portlet box green">
			<div class="portlet-title">
				<div class="caption">
					<i class="fa fa-cogs"></i>响应式表格
				</div>
				<div class="tools">
					<a href="javascript:;" class="collapse" data-original-title=""
						title=""> </a> <a href="#portlet-config" data-toggle="modal"
						class="config" data-original-title="" title=""> </a> <a
						href="javascript:;" class="reload" data-original-title="" title="">
					</a> <a href="javascript:;" class="remove" data-original-title=""
						title=""> </a>
				</div>
			</div>
			<div class="portlet-body flip-scroll" style="display: block;">
				<table id="userInfoTb"
					class="table table-bordered table-striped table-condensed flip-content">
					<thead class="flip-content">

					</thead>
					<tbody>
					</tbody>
				</table>
				<!-- split page -->
				<div id="splitPage">
					<ul class="pagination">
						<li id="prePage" onclick="prePage()"><a href="javascript:;">
								<i class="fa fa-angle-left"></i>
						</a></li>
						<li><a href="javascript:;" onclick="getPageInfo(this)"> 1
						</a></li>
						 <li>
	                                            <a href="javascript:;" onclick="getPageInfo(this)"> 2 </a>
	                                        </li>
	                                        <li >
	                                            <a href="javascript:;" onclick="getPageInfo(this)"> 3 </a>
	                                        </li>
	                                        <li>
	                                            <a href="javascript:;" onclick="getPageInfo(this)"> 4 </a>
	                                        </li>
	                                        <li>
	                                            <a href="javascript:;" onclick="getPageInfo(this)"> 5 </a>
	                                        </li>
	                                        <li>
	                                            <a href="javascript:;" onclick="getPageInfo(this)"> 6 </a>
						</li>
						<li id="nextPage" onclick="nextPages()"><a
							href="javascript:;"> <i class="fa fa-angle-right"></i>
						</a></li>
					</ul>
				</div>
				<!-- split page end -->
			</div>
		</div>
		<!-- END SAMPLE TABLE PORTLET-->
	</div>
	<!--support  -->
	<!-- /.modal -->
	<div class="modal fade" id="edit" tabindex="-1" role="basic"
		aria-hidden="true">
		<div class="modal-dialog ">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true"></button>
					<h4 class="modal-title">编辑修改</h4>
				</div>
				<div class="modal-body">
					<ul id="modal-table" class="list-group">

					</ul>
				</div>
				<div class="modal-footer">
					<button id="close" type="button" class="btn dark btn-outline"
						data-dismiss="modal">关闭</button>
					<button type="button" onclick="save()" class="btn green">保存</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!--end /.modal -->
	<!-- start modal -->
	<div id="manage" class="modal fade bs-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel">
	  <div class="modal-dialog modal-lg">
	    <div class="modal-content">
	      		<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true"></button>
					<h4 class="modal-title">编辑修改</h4>
				</div>
				<div class="modal-body">
					<div id="roleCheck">
					</div>
				</div>
				<div class="modal-footer">
					<button id="" type="button" class="btn dark btn-outline"
						data-dismiss="modal">关闭</button>
					<button type="button" onclick="saveUserRole()" class="btn green">保存</button>
				</div>
	    </div>
	  </div>
	 <!--end /.modal -->
</div>
</body>
</html>