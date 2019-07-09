<%@ page import="weaver.file.Prop"%>
<%@ page import="weaver.general.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="aisino.com.cn.util.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="weaver.general.Util,java.util.*,java.math.*" %>
<%@ page language="java" contentType="text/html; charset=GBK"%>
<jsp:useBean id="SubCompanyComInfo" class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	//ExecUtil ex = new ExecUtil();
	//ex.oaToErpSp("1234567");
	String workflowid = Util.null2String(request.getParameter("workflowid"));
	String requestid = Util.null2String(request.getParameter("requestid"));
	int formid = Util.getIntValue(request.getParameter("formid"), 0);//表单id
	int isbill = Util.getIntValue(request.getParameter("isbill"), 0);//表单类型，1单据，0表单
	int nodeid = Util.getIntValue(request.getParameter("nodeid"), 0);//表单类型，1单据，0表单
	rs.execute("select nownodeid from workflow_nownode where requestid=" + requestid);
	rs.next();
	int nownodeid = Util.getIntValue(rs.getString("nownodeid"), nodeid);
	rs.execute("select nodeid from workflow_flownode where nodetype=0 and workflowid=" + workflowid);
	rs.next();
	int onodeid = Util.getIntValue(rs.getString("nodeid"), 0);
	BillFieldUtilOfContract butil = new BillFieldUtilOfContract();
	Map mMap = butil.getFieldId(formid, "0");

	Map mMap1 = new HashMap();//明细表 1
	//mMap1 = BillFieldUtil.getFieldId(formid, "1", "uf_exp_acc_header");//明细表1
	mMap1 = BillFieldUtilOfContract.getFieldId(formid, "1");//明细表1

	Map mMap2 = new HashMap();//明细表2
	mMap2 = BillFieldUtilOfContract.getFieldId(formid, "2");//明细表2

	Map mMap3 = new HashMap();//明细表3
	mMap3 = BillFieldUtilOfContract.getFieldId(formid, "3");//明细表3
	
	Map mMap7 = new HashMap();//明细表7
    mMap7 = BillFieldUtilOfContract.getFieldId(formid, "7");//明细表7：增值税专票信息
    
    Map mMap8 = new HashMap();//明细表8
    mMap8 = BillFieldUtilOfContract.getFieldId(formid, "8");//明细表8：交通费用信息
    
    Map mMap9 = new HashMap();//明细表9
    mMap9 = BillFieldUtilOfContract.getFieldId(formid, "9");//明细表9：住宿费用信息
    
    Map mMap10 = new HashMap();//明细表10
    mMap10 = BillFieldUtilOfContract.getFieldId(formid, "10");//明细表10：补助、其他费用信息

	rs.execute("select b.tablename from workflow_base a ,workflow_bill b where a.formid=b.id and a.id=" + workflowid);
	rs.next();
	String tablename = Util.null2String(rs.getString("tablename"));

	rs.execute("select id from " + tablename + " where requestid=" + requestid);
	rs.next();
	String mainid = Util.null2String(rs.getString("id"));
	if ("".equals(mainid)) {
		mainid = "0";
	} 
	User user = HrmUserVarify.getUser(request, response) ;
	int user_id = user.getUID();
	String currentnodetype = Util.null2String((String)session.getAttribute(user_id + "_" + requestid + "currentnodetype"));
%>
<style type="text/css">
.border_1 {border: 1px solid #000}
</style>
 
<SCRIPT src="/interface/aisino/com/cn/js/AisinoPublicUtil.js" type="text/javascript"></SCRIPT>
<SCRIPT src="/interface/aisino/com/cn/js/contractutil_ecology.js" type="text/javascript"></SCRIPT>
<SCRIPT src="/interface/aisino/com/cn/js/AisinoUtil.js" type="text/javascript"></SCRIPT>
<script type="text/javascript">
var currentUserId = <%=user_id%>; //用户id
var nodeid = <%=nodeid%>;
var requestid = <%=requestid%>;
var isbill = <%=isbill%>;
var currentnodetype = '<%=currentnodetype%>';
var nodeName = getNodeName(nodeid);
var data = new Array();
var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>);
var linecount = 0;
var expensetypeSelect = jQuery('#field' + <%=mMap.get("applytype")%>);
var budgetWarnFlag = 0;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
var isOpenBudgetFlag = 'Y';
setProjectContentDisplay(expensetypeSelect);//设定项目的显示
//20171209 added  by ect jiajing start
var employno;  //员工编号（行上的报销人字段的value）
setProjectContentDisplay(expensetypeSelect);//设定项目的显示
var expense_bill_type = jQuery('#field' + <%=mMap.get("expense_bill_type")%>);
var applysubcompany = jQuery('#field' + <%=mMap.get("applysubcompany")%>); //获取经办人分部对象
var budgetControlFlag = true;
//20171209 added  by ect jiajing end
//20180329 added by mengly for 事项申请单链接 begin
//20190218 added by sdaisino  for 生成进项税行  begin
var jxsFlg = false;
//20190218 added by sdaisino for 生成进项税行  end
var tripapplybillcode_c = jQuery('#field' + <%=mMap.get("tripapplybillcode_c")%>); //事项申请单code
if(tripapplybillcode_c.val() != '' && tripapplybillcode_c.val() != null){
	jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("");
	jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("<input onclick=\"openItemBill()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"详情\" />");
}
//20180329 added by mengly for 事项申请单链接 end
window.onload = function(){
	//if(nodeName.indexOf('(N)') != -1){ //创建节点
	// add by sdaisino 报销单打印页面优化 start
	var verform = document.getElementById("verform");
	if (verform) {
	    if(currentnodetype == ''|| currentnodetype == '0'){ 
		dealTaxMony();
		segmentChange();
        } else {
               var detailLine0 = document.getElementsByName('check_node_0');
               if (detailLine0.length > 0) {
               	   dealTaxMony();
               }
        }
	}
	// add by sdaisino 报销单打印页面优化 end
	if(currentnodetype == ''||currentnodetype == '0'){ //20181128 modified  by zuoxl for 填单节点进项税额显示不正常(提交后显示红感叹号)
		//20180601 added by lixw for 发票信息 start
		//刷新发票按钮 
		<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
			//20190218 added by sdaisino  for 生成进项税行  begin
            jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoice()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />&nbsp;&nbsp;<input onclick=\"getTaxDetail()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"生成进项税行\" />");
            //20190218 added by sdaisino for 生成进项税行  end
        <%}else{ %>
            //20190218 added by sdaisino  for 生成进项税行  begin
            jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />&nbsp;&nbsp;<input onclick=\"getTaxDetail()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"生成进项税行\" />");
            //20190218 added by sdaisino for 生成进项税行  end
        <%} %>
		jQuery("#tab_6").hide();  // 隐藏发票信息tab页
		//20180601 added by lixw for 发票信息 end
        jQuery('#field' + <%=mMap.get("paytotalmoney")%> ).attr('readonly',true); //付款总金额
        jQuery('#field' + <%=mMap.get("reversaltotalmoney")%> ).attr('readonly',true); //冲销总金额
        //20171209 added  by ect jiajing start
        jQuery('#field' + <%=mMap.get("applytotalmoney")%> ).attr('readonly',true); //报销总金额只读
        //xuenhua 20190604 会议费和是否含会议费只读
        jQuery('#field' + <%=mMap.get("ishuiyifee")%> ).attr('readonly',true); 
        jQuery('#field' + <%=mMap.get("huiyifei_currmony")%> ).attr('readonly',true); 
        //绑定报销单类型onchange事件
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
		setTripApplyCode(expensebill);//20180321 added by zuoxl for 出差申请单号行控制
        expensebillShow(expensebill); //根据头信息报销单类型设置明细行的隐藏与显示
        setcolumshow(expensebill);//控制招待人数、招待级别是否显示
        //20180329 added by mengly for 事项申请单链接 begin
		//绑定事项申请单code的onchange事件 
		tripapplybillcode_c.removeAttr('onchange');      //移除onchange事件
		tripapplybillcode_c.bind('change', function(){//绑定onchange事件      (+ '_browserbtn')
			if(tripapplybillcode_c.val() != '' && tripapplybillcode_c.val() != null){
				jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("");
				jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("<input onclick=\"openItemBill()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"详情\" />");
			}
			//window.open('/formmode/view/AddFormMode.jsp?modeId=1&formId=-6&type=1&requestid=1&orgid=81');     
		});
		//20180329 added by mengly for 事项申请单链接 end
        //绑定报销单类型onchange事件
        expensebill.removeAttr('onchange');      //移除onchange事件
        expensebill.bind('change', function(){//绑定onchange事件
            <%-- setCol(<%=mMap.get("paytotalmoney")%>,fmoney(0),false,fmoney(0)); //清空付款总计 --%>
            expensebillShow(expensebill); //根据头信息报销单类型设置明细行的隐藏与显示
            setcolumshow(expensebill); //控制招待人数、招待级别是否显示
            jQuery("#tab_2").click();
            clearForm(0); //清空报销明细行
            clearForm(6); //清空发票明细行
            clearForm(0); //清空报销明细行
            clearForm(6); //清空发票明细行
            clearForm(7); //清空交通费明细
            clearForm(8); //清空住宿费明细
            clearForm(9); //清空补助明细行         
            setCol(<%=mMap.get("applytotalmoney")%>, fmoney(0), false, fmoney(0)); //清空总金额
            setCol(<%=mMap.get("paytotalmoney")%>, fmoney(0), false, fmoney(0)); //清空付款总金额
            setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(0), false, fmoney(0)); //清空会议费
            setTripApplyCode(expensebill);//20180321 added by zuoxl for 出差申请单号行控制
        }); 
        expensebillShow(expensebill); //根据头信息报销单类型设置明细行的隐藏与显示
        setcolumshow(expensebill); //控制招待人数、招待级别是否显示
		//20180823 added by zuoxl for 共享初审退回的单据，不可以修改单据类型   begin
		var jobnumber = jQuery('#field' + <%=mMap.get("jobnumber")%>).val();//财务共享工单号
		if(jobnumber!=null && jobnumber !=''){
			disabledSelect(<%=mMap.get("expense_bill_type")%>,false);//单据类型必填
		}else{
			disabledSelect(<%=mMap.get("expense_bill_type")%>,true);//单据类型
		}
		//20180823 added by zuoxl for 共享初审退回的单据，不可以修改单据类型   
        jQuery("#tab_2").click();
        if(expense_bill_type.val() != '1'){     
            clearForm(7);
            clearForm(8);
            clearForm(9);
        }
        /*  bindinvoiceTable('9'); //绑定补助信息表 */
        //给addRow方法增加控制
        var addbutton9 = jQuery(jQuery("button[name ='addbutton9']")[0]);
        addbutton9.removeAttr('onclick');      //移除onclick事件(先移除才会起作用)
        addbutton9.bind('click', function(){
            addRow9('9'); //增加行的原始方法
            addRowinvoic('9','no');
            addRowControl('9','no');//20180315 added by zuoxl for 绑定明细行onchange事件
        });       
        // 绑定发票类型onchange事件
        <%-- invoicetypechagne();
       //增加增值税发票行
        var invoicetype = jQuery('#field' + <%=mMap.get("invoicetype")%>);  //发票类型  --%>
        var addbutton6 = jQuery(jQuery("button[name ='addbutton6']")[0]);
        addbutton6.removeAttr('onclick');      //移除onclick事件(先移除才会起作用)
        addbutton6.bind('click', function(){
            addRow6('6'); //增加行的原始方法
            addRowinvoic('6','no');          
        });
        //20180315 added by zuoxl start
        //绑定交通费用明细行
        var addbutton7 = jQuery(jQuery("button[name ='addbutton7']")[0]);
        addbutton7.removeAttr('onclick');   
        addbutton7.bind('click', function(){
            addRow7('7'); //增加行的原始方法
            addRowControl('7','no');//20180315 added by zuoxl for 绑定明细行onchange事件
        });
        //20180315 added by zuoxl end
        //20171219 added  by ect jiajing start
        //绑定住宿费信息行
        var addbutton8 = jQuery(jQuery("button[name ='addbutton8']")[0]);
        addbutton8.removeAttr('onclick');      //移除onclick事件(先移除才会起作用)
        addbutton8.bind('click', function(){
            addRow8('8'); //增加行的原始方法
            addRowinvoic('8','no');    
            addRowControl('8','no'); //20180315 added by zuoxl for 绑定明细行onchange事件
        });
        //20171219 added  by ect jiajing end
        /* budgetControlFlag = true; */
        var deptNameIsNull = false;
        /* var employno;  //员工编号（行上的报销人字段的value） */ // delete by ect jiajing
        //如果requestid 不为空则赋值 冯金龙
        if(requestid != '' && requestid != '0'){
            jQuery('#field' + <%=mMap.get("requestid_c")%>).val(requestid);
        }
        var applyperson = jQuery('#field' + <%=mMap.get("applyperson")%>).val(); //申请人id
        var applydept = jQuery('#field' + <%=mMap.get("applydept")%>).val(); //申请部门id
        //20171209 added  by ect jiajing start
        var companycode = getapplycompany(applysubcompany.val()); //获取经办人公司
        setCol(<%=mMap.get("applycompany")%>, companycode, true, companycode); //向页面会写经办人公司
        get_applytel(applyperson); // 经办人手机号
        var telno = jQuery('#field'+<%=mMap.get("tel")%>).val();
        if(telno == '' || telno == null){
            alert('请维护经办人电话或手机号,再重新填单');
        }
        //20171209 added  by ect jiajing end
        var count = checkInMatrix(applyperson,48,'applyperson');//是否部门负责人  (切换系统需要改变)
        var transDeptCode = '';
        if(count>0){
          setCol(<%=mMap.get("istranscompany_c")%>, 1, true, 1);
          transDeptCode = checkValueInMatrix(applyperson,48,'applyperson');
          setCol(<%=mMap.get("dutydept")%>, transDeptCode, true, transDeptCode); //20170524 
        }else{
          setCol(<%=mMap.get("istranscompany_c")%>, 0, true, 0);
          setCol(<%=mMap.get("dutydept")%>, applydept, true, applydept); //20170524 
        }
        var userInfo = getUserInfo(applyperson);
        employno = userInfo.map.WORKCODE;//员工编号
        //20171209 modefied by ect jiajing start
        if(requestid==-1){         
          <%-- setCol(<%=mMap.get("applycompany")%>, userInfo.map.SUBCOMPANYCODE, true, userInfo.companyName); --%>
        //设置初始值
          setCol(<%=mMap.get("applytotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("reversaltotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("paytotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("huiyifei_currmony")%>,fmoney(0),false,fmoney(0));//xuenhua 20190604 会议费
          var dataLoan = new Array();
          if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97'){
              dataLoan = getLoanData(employno);//从数据库中获取借款历史明细
          }else{
              dataLoan = getLoanData2(employno,orgid.val());//从数据库中获取借款历史明细
          }
          loadRepaymentDetailBeforeSave(dataLoan);//加载借款历史明细
         
        }else{
            jQuery('#field' + <%=mMap.get("applytotalmoney")%>+ 'ncspan').hide();
            loadRepaymentDetail();
            setLineDisplay();
            setLineDisplay7(); //控制增值税明细行
            setLineDisplay10(); //补助信息明细行控制
            setLineDisplay8(); //住宿费明细行控制
        }
        //20171209 modefied by ect jiajing end
        //20171209 delete by ect jiajing start
        /* if(requestid == -1){  //新创建表单数据
            var dataLoan = new Array();
            dataLoan = getLoanData(employno);//从数据库中获取借款历史明细
            loadRepaymentDetailBeforeSave(dataLoan);//加载借款历史明细
        }else{
            loadRepaymentDetail();
            setLineDisplay();
        } */
        //20171209 delete by ect jiajing end
      //是否开启预算
        isOpenBudgetFlag = aisinoIsOpenBudget(orgid.val());
        checkCustomize = function(){//提交前验证
			//提交前计算业务招待费明细行金额
			countywzdDetailMoney();
			//20180827 added by zuoxl for 提交前校验发票是否填写，提醒用户 begin
        	if(!checkInvoiceStatus(requestid)){
        		return false;
        	}
        	//20180827 added by zuoxl for 提交前校验发票是否填写，提醒用户
            //20171209 added by ect jiajing start
        	//20171219 added by ect jiajing start
        	if(!expensestandardcheck()){ //校验住宿标准是否为数字
        		return false;
        	}
        	if(!allowancecheck()){ //校验补助标准是否为数字
                return false;
            }
        	//20171219 added by ect jiajing end
        	if(!checkdinvoicelength()){ //验证发票号码长度
                return false;
            }
            if(!checkdinvoicelength2()){ //验证发票代码长度
                return false;
            }
            if(!checkInvoiceNoExist()){//验证电子发票号是否已经存在
                return false;
            }
            if(!checkInvoiceNoExist2()){ //验证发票号码和发票代码是否填写重复
                return false;
            }
			if(!checkReimbursementMoney()){ //验证总金额与报销行明细总额是否一致
				alert('请检查报销行明细的税行填写');
				return false;
			}
            if(!istelnull()){
                alert('请维护经办人电话或手机号');
                return false;
            }
          //验证申请公司不为空
            if (!isapplycompanynull){
                alert('申请公司不能为空');
                return false;
            }
            //项目不为空 验证
            if(!isdeptnull()){
                alert('申请人部门不能为空');
                return false;
            }
            //验证报销明细行税额、不含税金额是否正确
            if(!checkmoney1()){
                return false;
            }
            //验证发票细行税额、不含税金额是否正确
            if(!checkmoney7()){
                return false;
            }
            if(expense_bill_type.val() == '1'){
                // 校验交通费明细行到达日期必须大于开始日期
                if(!checkArrivaldate()){
                    alert('交通费用明细行，到达日期必须大于开始日期');
                    return false;
                }
                if(!checkOutdate()){
                    alert('住宿费明细行，入住日期不能大于离店日期');
                    return false;
                }
            }           
            if(isLineDeptNull()){ //校验 行上的责任部门是否为空 
                alert('明细行上的费用承担部门部门不能为空，请检查');
                return false;
            }
            if(!taxmoneyCheck()){
                alert('报销明细行税额不能大于报销金额');
                return false;
            }
            if(!taxmoneyCheck7()){
                alert('增值税发票明细行增值税税额能大于报销金额');
                return false;
            }
            /* if(!isNullcheck()){
                alert('差旅费报销单交通费明细、住宿费明细、补助明细不能为空');
                return false;
            } */
            //金额校验
            if(!totalmoneyCheck()){
                alert('明细行交通费、住宿费、补助费合计与总金额不相等');
                return false;
            }
            if(!isdutydepartmentNull()){ //如果行上的费用承担部门，那么该部门的部门编号错误
                if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97' || orgid.val() == '662'|| orgid.val() == '723'){
                    alert('该部门的部门编号错误，请联系管理员');
                }else{
                    alert('报销明细行的费用承担部门不能为空');
                }
                
                return false;
            }
            if(isLineDeptNull()){ //校验 行上的费用承担部门是否为空 
                alert('明细行上的费用承担部门不能为空，请检查');
                return false;
            }
            //验证收款人明细是否为空
            var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val(); //付款总金额
            if(getFloat(paytotalmoney) > 0){
                if(!PayeeIsinput()){
                    alert('收款人明细部不能为空');
                    return false;
                }
            }
			//20181015 added by zuoxl for 校验已上支付通单位的支付方式（银企直连） 以及收款人明细信息 begin
			if(checkQposStatus(orgid.val())){ //校验是否上线支付通，已上则校验支付方式以及收款人明细信息
	        	if(!checkPayway()){
	        		alert('已上支付通单位支付方式应选择【银企直联】！');
					return false;
				}
				if(!checkReciptinfo()){
					return false;
				}
			}
        	//20181015 added by zuoxl for 校验已上支付通单位的支付方式只能是“银企直连” 以及收款人明细信息end
          //20171209 added by ect jiajing end
          //20171209 delete by ect jiajing start
          /* //验证申请人是否与填单人是否在同一部门下
          if(!checkemploy()){
            alert('第'+linecount+'行申请人不在该责任部门下，请重新选择!');
            return false;
          }
          if(deptNameIsNull){ //如果行上的责任部门为空，那么该部门的部门编号错误
              alert('该部门的部门编号错误，请联系管理员');
            return false;
          }
          if(isLineDeptNull()){ //校验 行上的责任部门是否为空 
            alert('明细行上的责任部门不能为空，请检查');
            return false;
          }
          //验证电子发票号
          if(checkElecNoOnSubmitBefore()){
            return false;
          } */
          //20171209 delete by ect jiajing end
          countPayTotalMoney();//计算总金额
                var applyCount = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();
          //验证价税合计
          if(applyCount <= 0){
            alert('报销金额不能小于0，请确认报销信息！');
            return false;
          }
          //验证冲销总金额,付款总金额
          var reversalCount = jQuery('#field' + <%=mMap.get("reversaltotalmoney")%>).val();
          if(applyCount - fmoney(reversalCount) < 0){
            alert('冲销总金额不能大于报销总金额，请重新修改！');
            return false;
          }
          var paytotalmoney1 = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
          var requestid_p = jQuery('#field' + <%=mMap.get("requestid_c")%>).val();
          if(paytotalmoney1!=0){
	          if(checkPayStatus()){
	              alert('请检查“收款人明细”数据是否正确');
	              return false;
	          }
	          if(checkTaxMoney()){
	              alert('分摊金额与付款总金额不一致，请查看');
	              return false;
	          }
          }
          if(paytotalmoney1==0&&requestid_p != ''){
              checkPayShareB4Submit();//判断付款金额是否为'0'，若为'0'则删除收款人明细
          }
          //20180316 added by zuoxl for 差旅报销验证报销明行是否超标 begin =======
       	  if(check_company_sys_status(companycode) != '-1') {
	          //验证交通工具标准
	          if(checkAllVehicle()!='-1'){
	          	return false;
	          }
	          //验证住宿费用标准
	          if(checkAllExpense()!='-1'){
	          	return false;
	          }
	          //验证补助费用标准
	          if(checkAllAllowance()!='-1'){
	          	return false;
	          }
	          
	          if(checkVehicleHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("交通工具明细行人员级别未维护，请维护后再填单提交！");
	          	return false;
	          }
	          
	          if(checkExpenseHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("住宿费用明细行人员级别未维护，请维护后再填单提交！");
	          	return false;
	          }
	          if(checkAllowanceHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("补助费用明细行人员级别未维护，请维护后再填单提交！");
	          	return false;
	          }
	          if(checkVehicleStandard()!=-1){
	          	alert("交通工具标准为空，请维护后再填单提交！");
	          	return false;
	          }
	          if(checkExpenseStandard()!=-1){
	          	alert("住宿费用标准为空，请维护后再填单提交！");
	          	return false;
	          }
	          if(checkAllowanceStandard()!=-1){
	          	alert("补助费用标准为空，请维护后再填单提交！");
	          	return false;
	          }
       	  }  
          //20180316 added by zuoxl for 差旅报销验证报销明行是否超标 end =======
          <%-- var workflowcode = jQuery('#field' + <%=mMap.get("workflowcode")%>).val(); --%>
          //验证流程编号是否重复  (提交前无法生成 )
          /* if(checkworkflowcode(workflowcode)){
            alert('对不起,流程编号重复请联系管理员！'); 
            return false;
          } */
          //20171209 delete by ect jiajing start
          /* //如果是差旅费，不能与其他费用混合报销
          if(checkIstravel()){
            if(orgid.val() == 83){//金卡
              alert('除业务招待费外，差旅费与其他费用不能同时报销！');
              return false;
            } else if(orgid.val() == 81){
              alert('差旅费与其他费用不能同时报销！');
              return false;
            }    
          }
          //如果是差旅费，天数不能为空
          if(checktripdaycount()){
            alert('差旅费报销时，除进项税额外，天数不能为空！');
            return false;
          } */
          //20171209 delete by ect jiajing end
          if(isOpenBudgetFlag == 'Y'){ //预算验证（超过预算或者未做预算）
              budgetWarnFlag = 0;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
            //加载预算
            showBudgetOuter(); 
              
            if(!budgetControlFlag){
              alert('科目组合不存在，请申请信息部维护；或未做预算，请联系财务部维护。');
              return false;
            }
            //20170511 edited for 预算控制 by mengly begin
            // 验证预算
            if(budgetWarnFlag==1){
              alert('警告,预算超出，不能报销！请查看费用组合信息和预算信息');
              return false;
            } else if(budgetWarnFlag==3){
              if(window.confirm('警告,存在超出预警比例的报销项，是否查看预算信息？\n （点击“取消”则提交）')){
                return false; 
              }
            } else if(budgetWarnFlag==2){
              alert('警告,预算超出，不能报销！请查看预算信息');
              return false;
            }
            //20170511 edited for 预算控制 by mengly end
          }
          /* checkFeetype();//是否业务招待费字段 */ //delete by ect jiajing 
          //modifer:fengjl20170630--begin
          getBusinessType();//判断当前跨组织报销是否需要业务监控
          //modifer:fengjl20170630--end
          clearForm(2);//清空预算表单
          //20170426 added for 预算控制性能调优 by yandong begin
          //生成费用组合
          getApExpenseSegment();
          //20170426 added for 预算控制性能调优 by yandong end
          deletePrementLine();//删除核销金额为空的借款历史明细行
          var no1 = <%=mMap1.get("no")%>;
          var no2 = <%=mMap2.get("no")%>;
          checkLineNo(0,no1,no2);//报销明细行行号
          checkLineNo(1,no1,no2);//借款历史明细行号
          return true;
        }
        if(isOpenBudgetFlag != 'Y'){//隐藏预算
            jQuery("#reloadBudgetBtnTr").hide();
            jQuery("#budgetDetailTr").hide();
        }else{
            jQuery("#reloadBudgetBtn").after("&nbsp;&nbsp;<input onclick=\"showBudgetOuter()\"  title=\"打开预算信息\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"打开预算信息\" />&nbsp;&nbsp;<input onclick=\"clearForm(2)\"  title=\"关闭\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"关闭\" />");
        }
        //获取人员的公司信息
        var deptLongNo = getDeptNumber(jQuery('#field' + <%=mMap.get("applydept")%>).val());
        var deptSegment = splitString(deptLongNo,'-',0);
        jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(deptSegment);
        if(jQuery('#field' + <%=mMap.get("istranscompany_c")%>).val() == 1){
            var transDeptLongNo = getDeptNumber(transDeptCode);
            var transDeptSegment = splitString(transDeptLongNo,'-',0);
            jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(transDeptSegment);
        }
        //设置费用模板的输入框为只读（对于有参数的浏览按钮，这样设置是为了防止AutoComplete使其失去控制）
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '__').attr('readonly',true); //费用模板
        jQuery('#field' + <%=mMap.get("projectno")%> + '__').attr('readonly',true); //项目编号
        //报销类型的onchange事件（清空费用模板等信息，以及报销行）
        var expensetypeSelect = jQuery('#field' + <%=mMap.get("applytype")%>);
        setProjectContentDisplay(expensetypeSelect);//设定项目的显示
        expensetypeSelect.removeAttr('onchange');      //移除onchange事件
        expensetypeSelect.bind('change', function(){   //绑定onchange事件
            setProjectContentDisplay(jQuery(this));//设定项目的显示
            setCol(<%=mMap.get("feetemplate")%>, '', true, '');//清空费用模板
            setNeedCheck(<%=mMap.get("feetemplate")%>,true);//设置‘费用模板’必填
            clearForm(0);//清空报销行Start
            //清空报销行End
            //20171209 added by ect jiajing start
            clearForm(6); //清空发票明细行
            clearForm(7); //清空交通费明细
            clearForm(8); //清空住宿费明细
            clearForm(9); //清空补助明细行
            setCol(<%=mMap.get("applytotalmoney")%>, fmoney(0), false, fmoney(0)); //清空总金额
            setCol(<%=mMap.get("paytotalmoney")%>, fmoney(0), false, fmoney(0)); //清空付款总金额
            setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(0), false, fmoney(0)); //清空付款总金额
            //20171209 added by ect jiajing end
        });
        //给addRow方法增加控制
        var addbutton0 = jQuery(jQuery("button[name ='addbutton0']")[0]);
        addbutton0.removeAttr('onclick');      //移除onclick事件(先移除才会起作用)
        addbutton0.bind('click', function(){  //绑定onclick事件
          //20190218 added by sdaisino  for 生成进项税行  begin
          jxsFlg = false;
          //20190218 added by sdaisino for 生成进项税行  end
          var expenseType = jQuery('#field' + <%=mMap.get("applytype")%>);//报销类型
          var feeTemplate = jQuery('#field' + <%=mMap.get("feetemplate")%>);//费用模板
          var projectNo = jQuery('#field' + <%=mMap.get("projectno")%>);//报销头信息的项目编号
          var deptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //部门段
          if(deptNo == null || deptNo =='')   { alert('该部门没有维护部门编码'); return; }
          if(expenseType.val() == null || expenseType.val() == '')      { alert('请先选择报销类型'); return; }
          if(feeTemplate.val() == null || feeTemplate.val() == '')      { alert('请先选择费用模板'); return; }
          //项目事务时，项目编号不能为空
          if(expenseType.val() == 1 && (projectNo.val() == null || projectNo.val() == ''))   { alert('项目事务类报销，项目编号不能为空'); return; }
          addRow0(0); //增加行的原始方法
          //20171209 modefied by ect jiaing start
          /* addRowDetail0(); */
          addRowDetail0('0','no');
        //20171209 modefied by ect jiaing end
        // add by sdaisino 报销单打印页面优化 start
        var rowIndex = 1 * parseInt(document.getElementById("indexnum0").value)-1; //获取当前行的索引     
        jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).bind('change',function(){
            segmentTaxAdd();
        }); 
        // add by sdaisino 报销单打印页面优化 end
        });
        //  报销明细行  (给delRow方法增加控制)
        var delbutton0 = jQuery(jQuery("button[name ='delbutton0']")[0]);
        delbutton0.removeAttr('onclick');      
        delbutton0.bind('click', function(){
          deleteRow0(0);
          countDetailMoney(0, <%=mMap1.get("localmoney")%>, <%=mMap.get("applytotalmoney")%>);
          countPayTotalMoney();
          // add by sdaisino 报销单打印页面优化 start
          var verform = document.getElementById("verform");
          if (verform) {
              var detailLine0 = document.getElementsByName('check_node_0');
	          var taxmoney = parseFloat(0);
	          for(var i = 0;i < detailLine0.length;i++){
	              var myIndex = detailLine0[i].value;
	              var taxText = jQuery('#field22369_'+ myIndex); //进项税文本
	              if(taxText.val() != '21710101'){
	                  if (jQuery('#field22364_'+ myIndex).val() != '') {
	                      taxmoney = parseFloat(taxmoney)+ parseFloat(jQuery('#field22364_'+ myIndex).val());
	                  }
	              } 
	          }
	    	  var myTax = document.getElementById('zd_taxamount_1');
	    	  myTax.innerHTML = '';
	    	  if (!isNaN(taxmoney)) {
	              myTax.innerHTML = "<span >" + taxmoney.toFixed(2)+ "</span>";
	            } 
          }
	  // add by sdaisino 报销单打印页面优化 end
          return false;
        });
       //借款历史明细  (给delRow方法增加控制)
        var delbutton1 = jQuery(jQuery("button[name ='delbutton1']")[0]);
        delbutton1.removeAttr('onclick');      
        delbutton1.bind('click', function(){ 
          deleteRow1(1);
          countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
          countPayTotalMoney();
          return false;
        });
        //费用模板浏览按钮点击事件
        var feetemp = jQuery('#field' + <%=mMap.get("feetemplate")%>);
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '_browserbtn').removeAttr('onclick');
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '_browserbtn').bind('click', function(){
          if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == null || jQuery('#field' + <%=mMap.get("applytype")%>).val() == ''){
            alert('请先选择报销类型');
            return;
          }
          //清空报销行
          selectAllLine(0); //选中所有报销明细行
          delRowFun_new(0); //删除选中行
          jQuery('#field' + <%=mMap.get("projectno")%>).val('');//项目编号
          jQuery('#field' + <%=mMap.get("projectno")%> + 'span').html('');//项目编号
          jQuery('#field' + <%=mMap.get("projectname")%>).val('');//项目名称
          jQuery('#field' + <%=mMap.get("projectmanager")%>).val('');//项目经理
          jQuery('#field' + <%=mMap.get("glprojectcode")%>).val('');//预算项目代码
          <%-- onShowBrowser2(<%=mMap.get("feetemplate")%>,
                  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.deptfeetemplate','','161',feetemp.attr('viewtype')); --%>
          if(orgid.val() == '81' || orgid.val() == '97' || orgid.val() == '83'){
              onShowBrowser2(<%=mMap.get("feetemplate")%>,
                  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.deptfeetemplate','','161',feetemp.attr('viewtype'));
          }else{
              onShowBrowser2(<%=mMap.get("feetemplate")%>,
                  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.feetemplate','','161',feetemp.attr('viewtype'));
          }
        });
        //项目编号浏览按钮点击事件
        var projno = jQuery('#field' + <%=mMap.get("projectno")%>);
        jQuery('#field' + <%=mMap.get("projectno")%> + '_browserbtn').removeAttr('onclick');
        jQuery('#field' + <%=mMap.get("projectno")%> + '_browserbtn').bind('click', function(){
          if(jQuery('#field' + <%=mMap.get("feetemplate")%>).val() == null || jQuery('#field' + <%=mMap.get("feetemplate")%>).val() == ''){
            alert('请先选择费用模板');
            return;
          }
          if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //项目事务
            if(jQuery('#field' + <%=mMap.get("feetemplate")%> + 'span').text().indexOf('市场') == -1){
              jQuery('#field' + <%=mMap.get("scflag_c")%>).val('NO');//设定‘是否市场’字段
            } else {
              jQuery('#field' + <%=mMap.get("scflag_c")%>).val('SC');//设定‘是否市场’字段
            }
          }
          //清空报销行
          selectAllLine(0); //选中所有报销明细行
          delRowFun_new(0); //删除选中行
          onShowBrowser2(<%=mMap.get("projectno")%>,
                  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.projectno','','161',projno.attr('viewtype'));    
        });
        // modefied by ect jiajing start        
         /*jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"payShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"编辑收款人明细\" />&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />"); */

        //收款人明细按钮  
        <% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
            jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"payShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"编辑收款人明细\" />&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />");
        <%}else{ %>
            jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />");
        <%} %>
        // modefied by ect jiajing end
    }else if(nodeName.indexOf('(I)') != -1){//导入ERP节点
		//20180601 added by lixw for 发票信息 start
		//刷新发票按钮  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />");
		jQuery("#tab_6").show();  // 显示发票信息tab页
		//20180601 added by lixw for 发票信息 end
    	//20171209 added by ect jiajing start
    	hidebutton(expense_bill_type.val());// 隐藏添加删除按钮
        //报销单类型为差旅费报销单时差旅费明细显示，否则隐藏
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
        setcolumshow(expensebill); ////控制招待人数、招待级别是否显示
        expensebillShow(expensebill); //根据头信息报销单类型设置明细行的隐藏与显示
    	//20171209 added by ect jiajing end
    	checkCustomize = function(){ //提交前校验
            var invoiceNum = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();
            if(invoiceNum!=null && invoiceNum != ''){
              return true;
            }else{
              if(window.confirm('警告,本次未执行导入erp操作，没有生成发票，是否继续提交？')){
                return true;
              }else{
                return false;
              }
            }
            return true;
        }
    	jQuery("#importERP").after("&nbsp;&nbsp;<input onclick=\"importERPOuter()\"  title=\"导入erp\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"导入erp\" />");
        /*收款人明细按钮   author：冯金龙  begin*/
        //20171209 modefied by ect jiajing start
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />"); */
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />");
        //20171209 modefied by ect jiajing end
        /*收款人明细按钮   author：冯金龙  end*/
    }else if(nodeName.indexOf('(E)') != -1){//结束节点
        //20180601 added by lixw for 发票信息 start
		//刷新发票按钮  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />");
		jQuery("#tab_6").show();  // 显示发票信息tab页
		//20180601 added by lixw for 发票信息 end
    }else if(nodeName.indexOf('(P)') != -1){//打印节点
		//20180601 added by lixw for 发票信息 start
		//刷新发票按钮  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />");
		jQuery("#tab_6").show();  // 显示发票信息tab页
		//20180601 added by lixw for 发票信息 end
        /*收款人明细按钮   author：冯金龙  begin*/
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />"); */  //20171209 delete by ect jiajing
        /*收款人明细按钮   author：冯金龙  end*/
        //20171209 added by ect jiajing start
        hidebutton(expense_bill_type.val());// 隐藏添加删除按钮
        //报销单类型为差旅费报销单时差旅费明细显示，否则隐藏
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
        expensebillShow(expensebill);
        setcolumshow(expensebill); //控制招待人数、招待级别是否显示
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />");
        //20171209 added by ect jiajing end
        
    }else{//审批节点通用
		//20180601 added by lixw for 发票信息 start
		//刷新发票按钮  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"发票明细\" />");
		jQuery("#tab_6").show();  // 显示发票信息tab页
		//20180601 added by lixw for 发票信息 end
    	//20171209 added by ect jiajing start
    	hidebutton(expense_bill_type.val());// 隐藏添加删除按钮
        jQuery('#field' + <%=mMap.get("applytotalmoney")%>+ 'ncspan').hide();
        //报销单类型为差旅费报销单时差旅费明细显示，否则隐藏
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
        setcolumshow(expensebill); ////控制招待人数、招待级别是否显示
        expensebillShow(expensebill); 
    	//20171209 added by ect jiajing end
    	budgetControlFlag = true;
        <%-- var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>); --%> //20171209 delete by ect jiajing
        //是否开启预算
        isOpenBudgetFlag = aisinoIsOpenBudget(orgid.val());
        if(isOpenBudgetFlag != 'Y'){//隐藏预算
          jQuery("#reloadBudgetBtnTr").hide();
          jQuery("#budgetDetailTr").hide();
        }else{
          jQuery("#reloadBudgetBtn").after("&nbsp;&nbsp;<input onclick=\"showBudgetOuter(true)\"  title=\"打开预算信息\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"打开预算信息\" />&nbsp;&nbsp;<input onclick=\"clearForm(2)\"  title=\"关闭\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"关闭\" />");
        }
        /*收款人明细按钮   author：冯金龙  begin*/
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />"); */  // 20171209 delete by ect jiajing
        /*收款人明细按钮   author：冯金龙  end*/
        // 20171209 added by ect jiajing start
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"查询收款人明细\" />");
        // 20171209 added by ect jiajing end
        
        checkCustomize = function(){//提交前验证
            if(isOpenBudgetFlag == 'Y'){ //预算验证（超过预算或者未做预算）
                budgetWarnFlag = 0;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
              //加载预算
              showBudgetOuter(true); 
                if(!budgetControlFlag){
                alert('科目组合不存在，请申请信息部维护；或未做预算，请联系财务部维护。');
                return false;
              }
              //20170511 edited for 预算控制 by mengly begin
            // 验证预算
            if(budgetWarnFlag==1){
              alert('警告,预算超出，不能报销！请查看费用组合信息和预算信息');
              return false;
            } else if(budgetWarnFlag==3){
              if(window.confirm('警告,存在超出预警比例的报销项，是否查看预算信息？\n （点击“取消”则提交）')){
                return false; 
              }
            } else if(budgetWarnFlag==2){
              alert('警告,预算超出，不能报销！请查看预算信息');
              return false;
            }
            //20170511 edited for 预算控制 by mengly end
            }
            clearForm(2);//清空预算表单
            return true;
        }
    	
    }
    //20190218 added by sdaisino  for 生成进项税行  begin
    if ($("#flush_invoice")) {
    	$("#flush_invoice").parent().attr("colSpan",2)
	}
	//20190218 added by sdaisino for 生成进项税行  end
}
if(isbill==0){ //打印布局
    window.onload=function(){
	// add by sdaisino 报销单打印页面优化 start
	var verprint = document.getElementById("verprint");
	if (verprint) {
	    dealTaxMony();
	    addMoneyNoTax();
	}
	// add by sdaisino 报销单打印页面优化 end
	//20171212 added by mengly for EBS单位税行显示 begin
    	var headCurrency = jQuery('#field' + '7924').val(); 
    	var taxmoney;
    	var notaxmoney;
    	var account_segment;
    	var localmoney;
    	var lineCurrency; 
    	for(var i=0;i<document.getElementById('oTable0').rows.length - 2;i++){
    	  taxmoney = jQuery('#field' + '22364_' + i).val();
    	  notaxmoney = jQuery('#field' + '7975_' + i).val();
    	  account_segment = jQuery('#field' + '22369_' + i).val();
    	  localmoneySpan = jQuery('#field' + '7992_' + i + 'span');
    	  lineCurrency = jQuery('#field' + '7990_' + i).val(); 
    	  if(headCurrency==lineCurrency){
   		    if('21710101' == account_segment){
 		        localmoneySpan.html(''+ taxmoney);
 		      }else{
 		        localmoneySpan.html(''+ notaxmoney);
 		      }
    	  }else if(lineCurrency == ''&&'21710101' == account_segment){
 		        localmoneySpan.html(''+ taxmoney);
    	  }
    	}
    	//20171212 added by mengly for EBS单位税行显示 end
        var orgid = jQuery('#field' + '7918').val(); 
      var finantialProjectNo = ' ';//财务项目号
      for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
          var finantialProjectNoLine = jQuery('#field' + '7972_' + i).val();//行上的财务项目号
          if(finantialProjectNoLine != '' && finantialProjectNoLine != null){
              finantialProjectNo = finantialProjectNoLine;
        }
    }
      //获取财务项目名称
      jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        //processData : false,
        data :   {"action":"getFinancialProjectName","cwxmh":finantialProjectNo,"orgid":orgid},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
            jQuery('#financialProjectName').text(json.list[0].PROJECTNAME);
          }
        },
        error: function (){
          alert('error...');
        }
      }); 
      
        var rowindex = parseInt($G("indexnum0").value);
        /* 差旅费 Start */
        var isTravelFee = jQuery('#field' + '22205').val(); //是否差旅费
      if(isTravelFee == '1'){//差旅费
          jQuery('#titleName').text('差旅费报销单');
		  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
          //jQuery('#feeDate').html('<b>起始日期</b>');//
          jQuery('#oTable7').parent().parent().parent().parent().hide();
          jQuery('#oTable8').parent().parent().parent().parent().hide();
          jQuery('#oTable9').parent().parent().parent().parent().hide();
          for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
            <%--//获取每条明细的天数
            var ts = jQuery('#field' + '7977_' + i).val();
            //获取每条明细的起始日期
            var qsrq = jQuery('#field' + '7976_' + i).val();
            if(ts==''||ts==null){
                  ts=0;
              }
            if(ts){
              //计算终止日期
              var sql = "select to_char(to_date('" + qsrq + "','yyyy-mm-dd')" + "+" + ts + ",'yyyy-mm-dd') enddate from dual";
                //获取终止日期
                  jQuery.ajax({
                    url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
                    type : "post",
                    async : false,
                    //processData : false,
                    data :   {"action":"getEndDate","qsrq":qsrq,"ts":ts},  
                    dataType : 'json',
                    success: function (json){
                      if(json.flag=='s'){
                          jQuery('#field' + '7977_' + i +'span').html(json.list[0].ENDDATE);
                      }
                    },
                    error: function (){
                      alert('error...');
                    }
                  }); 
            }     --%>        
        }
      }else if(isTravelFee == '0'){//非差旅费
    	  jQuery('#titleName').text('通用报销单');
    	  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
      }else if(isTravelFee == '2'){
    	  jQuery('#titleName').text('业务招待费报销单');
    	  jQuery('.ywzd_zdrs').show();
          jQuery('.ywzd_zdjb').show();
      }else if(isTravelFee == '3'){
    	  jQuery('#titleName').text('劳务费报销单');
    	  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
      }
       // add by sdaisino 报销单打印页面优化 start
       if (verprint) {
           removeSibling();
       }
      // add by sdaisino 报销单打印页面优化 end
      //说明 
      var shuoming = document.getElementById('shuoming');
      // add by sdaisino 报销单打印页面优化 start
      if (verprint) {
           shuoming.style.width='10%';
       } else {
           shuoming.style.width='28%';
       }
      // add by sdaisino 报销单打印页面优化 end
      //金额
      var jine = document.getElementById('jine');
      // add by sdaisino 报销单打印页面优化 start
      if (verprint) {
           jine.style.width='10%';
       } else {
           jine.style.width='13%';
       }
      // add by sdaisino 报销单打印页面优化 end
      jQuery('#endDate').hide();//非差旅费隐藏终止日期
      for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
          jQuery('#field' + '7977_' + i).parent().hide(); //终止日期隐藏
    }
      
      //20180827 modified by zuoxl for 业务招待费时打印招待人数和招待级别  begin
      if(rowindex < 8){
		if(isTravelFee == '2'){
			for(var i = rowindex; i < 8; i++){
	           // add by sdaisino 报销单打印页面优化 start
	           if (verprint) {
           	       addRowPrint1(0,11);
               } else {
           	       addRowPrint1(0,8);
               }
	        }
	        if (verprint) {
           	    resetWidth11();
            }
	        // add by sdaisino 报销单打印页面优化 end
    	}else{
    		for(var i = rowindex; i < 8; i++){
  	          // add by sdaisino 报销单打印页面优化 start
  	          if (verprint) {
           	       addRowPrint1(0,9);
               } else {
           	       addRowPrint1(0,6);
               }
  	        }
  	        if (verprint) {
           		resetWidth9();
            } 
  	        // add by sdaisino 报销单打印页面优化 end
    	}
       // add by sdaisino 报销单打印页面优化 start
      } else {
          if (verprint) {
              if(isTravelFee == '2'){
                  resetWidth11();
              }else {
                  resetWidth9();
              }
          } 
      }
      // add by sdaisino 报销单打印页面优化 end
      //20180827 modified by zuoxl for 业务招待费时打印招待人数和招待级别  end
        /* 差旅费 End */
        //财务项目号
      var applyperson = jQuery('#field' + '7916').val();//申请人
      var upperMoney = getUpperMoney(getFloat(jQuery('#field' + '7937').val()).toFixed(2));
      jQuery('#capitalMoney').html(upperMoney);//价税合计大写
      var memo = jQuery('#field' + '7928' + 'span').html(); //7928   备注
      //获取电话
      jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        //processData : false,
        data : "action=getTelephone&applyperson=" + applyperson ,  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
            jQuery('#phone').html(json.map.PHONE);
          }
        },
        error: function (){
          alert('error...');
        }
      }); 
    
      var expenseNo = jQuery('#field' + '7915').val(); //报销单号
      var approveListStr = '';
      //getApproveList  获取审批流程  
        jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data :   {"action":"getApproveList","expenseNo":expenseNo},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
            data = json.list;
            if(data.length>0){
              var length1 = data.length;
              for(var i=0; i<length1; i++){
                if(i!=0){
                  approveListStr += '，';
                }
                approveListStr +=data[i].NODENAME;
                approveListStr +='：';
                approveListStr +=data[i].USERNAME;
              }
              jQuery('#approveList').html(approveListStr);
            }
          }
        },
        error: function (){
          alert('error...');
        }
      }); 
    
    //document.getElementById('memo').innerHTML = memo + '<br>'  //在'备注'中添加冲销信息
      //获取 冲销借款列表
      var loanstr='';
      jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"getInvoiceno","expenseno":expenseNo} ,  
        dataType : 'json',
         success: function (json){
          if(json.flag=='s'){
            data = json.list;
            if(data.length>0){
              var ci = 0;  //ci用来标记是否冲销
              var bzxx = '借款单号（未还款金额）：';  //bzxx用来保存冲销的单号和金额
              for(var i=0 ;i<data.length;i++){
                  var paidmoney = data[i].PAIDMONEY.replaceAll(',','');
                if(parseFloat(data[i].PAIDMONEY) > 0){
                  ci += 1;  //如果ci不为0，在bzxx后加';'
                  bzxx += '【' + data[i].INVOICECODE+'(' + fmoney(data[i].PAIDMONEY,2) + ')】';  //【xxxx（1111）】
                }
              }
              if(ci!=0){
                document.getElementById('sfcxjk').innerHTML='是';   //更改'是否冲销借款'的值
                loanstr += '<br>' + bzxx;  //在'备注'中添加冲销信息
                //document.getElementById('memo').innerHTML = memo + '<br>' + bzxx;  //在'备注'中添加冲销信息
              }
            }
          }else if(json.flag=='e'){
            alert(json.error_msg);
          }
        },
        error: function (){
          alert('error...');
        }
      });
      // 航信总部打印单据中如果有收款人明细给供应商信息，打印出付款非陪供应商名称及金额
        var paystr = '';
        if(orgid == '81'){
         jQuery.ajax({
            url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
            type : "post",
            async : false,
            data :   {"action":"getSupplierPayment","requestid":requestid},  
            dataType : 'json',
            success: function (json){
              if(json.flag=='s'){
                data = json.list;
                if(data.length>0){
                  var length1 = data.length;
                  for(var i=0; i<length1; i++){
                    if(i==0){
                        paystr += '<br>' + '收款人明细供应商（分配金额）：';  //收款人明细供应商信息
                    }
                    paystr += '【' + data[i].EMPLOYEEORSUPPLIER+'(' + fmoney(data[i].SHAREMONEY,2) + ')】';  //【xxxx（1111）】
                  }
                }
              }
            },
            error: function (){
              alert('getSupplierPayment error...');
            }
          });
        }
        document.getElementById('memo').innerHTML = memo + loanstr + paystr;
    };
}

// add by sdaisino 报销单打印页面优化 start
function resetWidth11() {
    var reset = document.getElementById('resetWidth');
    var widthChild = reset.previousSibling.previousSibling.children;
    if (widthChild[0]) {
    	widthChild[0].style.width='4%';
    }
    if (widthChild[1]) {
    	widthChild[1].style.width='1%';
    }
     if (widthChild[2]) {
    	widthChild[2].style.width='10%';
    }
    if (widthChild[3]) {
    	widthChild[3].style.width='10%';
    }
    if (widthChild[4]) {
    	widthChild[4].style.width='10%';
    }
    if (widthChild[5]) {
    	widthChild[5].style.width='5%';
    }
    if (widthChild[6]) {
    	widthChild[6].style.width='5%';
    }
    if (widthChild[7]) {
    	widthChild[7].style.width='8%';
    }
    if (widthChild[8]) {
    	widthChild[8].style.width='15%';
    }
    if (widthChild[9]) {
    	widthChild[9].style.width='8%';
    }
    if (widthChild[10]) {
    	widthChild[10].style.width='5%';
    }
    if (widthChild[11]) {
    	widthChild[11].style.width='10%';
    }
    if (widthChild[12]) {
    	widthChild[12].style.width='10%';
    }
    if (widthChild[13]) {
    	widthChild[13].style.width='15%';
    }
}
function resetWidth9() {
    var reset = document.getElementById('resetWidth');
    var widthChild = reset.previousSibling.previousSibling.children;
    if (widthChild[0]) {
    	widthChild[0].style.width='4%';
    }
    if (widthChild[1]) {
    	widthChild[1].style.width='1%';
    }
     if (widthChild[2]) {
    	widthChild[2].style.width='10%';
    }
    if (widthChild[3]) {
    	widthChild[3].style.width='10%';
    }
    if (widthChild[4]) {
    	widthChild[4].style.width='10%';
    }
    if (widthChild[5]) {
    	widthChild[5].style.width='20%';
    }
    if (widthChild[6]) {
    	widthChild[6].style.width='8%';
    }
    if (widthChild[7]) {
    	widthChild[7].style.width='10%';
    }
    if (widthChild[8]) {
    	widthChild[8].style.width='10%';
    }
    if (widthChild[9]) {
    	widthChild[9].style.width='10%';
    }
    if (widthChild[10]) {
    	widthChild[10].style.width='5%';
    }
    if (widthChild[11]) {
    	widthChild[11].style.width='10%';
    }
    if (widthChild[12]) {
    	widthChild[12].style.width='10%';
    }
    if (widthChild[13]) {
    	widthChild[13].style.width='15%';
    }
}
// 删除兄弟节点
function removeSibling(){
    var colspan = 1;
    var nextAll = jQuery('#capitalMoney').nextAll();
    for (var i = 0; i < nextAll.length; i++) {
        var content = nextAll[i].innerHTML;
        if (content == " <span>合计：</span> ") {
            break;
        } else {
            if(nextAll[i].style.display == "none"){
            	var $obj = $(nextAll[i]);
            	$obj.remove();
            } else {
            	colspan++;
            	var $obj = $(nextAll[i]);
		$obj.remove();
            }
        }
    }
    
    jQuery('#capitalMoney').attr("colSpan", colspan);
}
// 税额总计
function dealTaxMony() {
    var detailLine0 = document.getElementsByName('check_node_0');
    var taxmoney = parseFloat(0);
    var localmoney = parseFloat(0);
    var tax = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var rowIndex = detailLine0[i].value;
	var account_segment = jQuery('#field22369_'+ rowIndex); //进项税文本
	if(account_segment.val() != '21710101'){
	    if (jQuery('#field22364_'+ rowIndex).val() != '') {
	        taxmoney = parseFloat(taxmoney)+ parseFloat(jQuery('#field22364_'+ rowIndex).val());
	     }
	     if (jQuery('#field7992_'+ rowIndex).val() != '') {
	        localmoney = parseFloat(localmoney)+ parseFloat(jQuery('#field7992_'+ rowIndex).val().replace(',',''));
	     }
        } else {
        	if (jQuery('#field22364_'+ rowIndex).val() !='') {
	        tax = parseFloat(tax) + parseFloat(jQuery('#field22364_'+ rowIndex).val());
	      }
        }
    }
    jQuery('#sum22364').html(taxmoney.toFixed(2));
    jQuery('#sumvalue22364').val(taxmoney);
    // 不含税金额
    if (jQuery('#sum7992')) {
         jQuery('#sum7992').html((localmoney - taxmoney).toFixed(2));
         jQuery('#sumvalue7992').val((localmoney - taxmoney));
     }
    var upperMoney = getUpperMoney(getFloat(jQuery('#field' + '7937').val()).toFixed(2));
    if (jQuery('#capitalMoney')) {
         jQuery('#capitalMoney').html(upperMoney);//价税合计大写
     }
}
function addMoneyNoTax(){
    var detailLine0 = document.getElementsByName('check_node_0');
    var moneyNoTax = parseFloat(0);
    var totalmoney = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var myIndex = detailLine0[i].value;
	  var taxText = jQuery('#field22369_'+ myIndex); //进项税文本
	   if(taxText.val() != '21710101'){
	        if (jQuery('#field22362_'+ myIndex).val() != '') {
	            moneyNoTax = parseFloat(jQuery('#field22362_'+ myIndex).val()) - parseFloat(jQuery('#field22364_'+ myIndex).val());
	            totalmoney =totalmoney + parseFloat(jQuery('#field22362_'+ myIndex).val());
	            if (!isNaN(moneyNoTax)) {
	                setCol('7992' + '_'+ myIndex, moneyNoTax, true, moneyNoTax.toFixed(2));
	            }
	         }
	   } else if(taxText.val() == '21710101'){
	   	   jQuery('#field7992_'+ myIndex + 'span').parent().html('');
	   	   jQuery('#field22362_'+ myIndex + 'span').parent().html('');
	   }
    }
    jQuery('#sum22362').html(totalmoney.toFixed(2));
    jQuery('#sumvalue22362').val(totalmoney);
}

// 进项税文本change事件
function segmentChange() {
    var detailLine0 = document.getElementsByName('check_node_0');
    for(var i = 0;i < detailLine0.length;i++){
    	var rowIndex = detailLine0[i].value;
    	jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).bind('change',function(){
            segmentTaxAdd();
        }); 
    }
}

// 税行累计
function segmentTaxAdd() {
    var detailLine0 = document.getElementsByName('check_node_0');
    var taxmoney = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var myIndex = detailLine0[i].value;
        var taxText = jQuery('#field22369_'+ myIndex); //进项税文本
        if(taxText.val() != '21710101'){
            if (jQuery('#field22364_'+ myIndex).val() != '') {
                taxmoney = parseFloat(taxmoney)+ parseFloat(jQuery('#field22364_'+ myIndex).val());
            }
        } 
    }
    var myTax = document.getElementById('zd_taxamount_1');
    myTax.innerHTML = '';
    if (!isNaN(taxmoney)) {
        myTax.innerHTML = "<span >" + taxmoney.toFixed(2)+ "</span>";
    } 
}
 // add by sdaisino 报销单打印页面优化 end

function addRowPrint1(groupid,columnCount){
	  var tdstr = ' <td class="border_1">&nbsp;</td>';
	  var tdstr1 = ' <td class="border_1" colspan=2></td>';
	  //var addRowHtmlStr = "<tr height='28px'> " + tdstr1 + tdstr + tdstr + tdstr + tdstr + tdstr + tdstr + " </tr>";
	  var addRowHtmlStr = "<tr height='28px'> " + tdstr1 ;
	  for(var i=0;i<columnCount;i++){
		  addRowHtmlStr += tdstr;
	  }
	  addRowHtmlStr += " </tr>";
	  //操作主体放JS文件中
	  detailOperate.addRowOperDom(groupid, addRowHtmlStr);
}

/**
 * 加载借款历史明细 (新创建表单)
 */
function loadRepaymentDetailBeforeSave(dataLoan){
  var addbutton1 = jQuery(jQuery("button[name ='addbutton1']")[0]); //隐藏增加行按钮 （借款历史明细）
    addbutton1.hide();
    jQuery(jQuery('input[name="check_all_record"]')[1]).hide();
    var no = 0;//序号
    for(var i=0; i<dataLoan.length; i++){
      addRow1(1);
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').attr('readonly',true); //设定初期本次核销金额未选中不可编辑
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').removeAttr('onblur');
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').bind('blur',function(){
        changeToThousands2(jQuery(this).attr('name'),2);
        checkMoney(this);
	      countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
        countPayTotalMoney();//计算报销总金额,冲销总金额,付款总金额
      });
      //绑定checkbox勾选事件
      jQuery('input[name="check_node_1"]').each(function(){
        var checkbox = jQuery(this).val();//当前指向
          if(checkbox == i){
            jQuery(this).removeAttr('onclick');
            jQuery(this).bind('click', function(){ 
              if(this.checked){//如果勾选
                var noVerificationAmount = jQuery('#field' + <%=mMap2.get("unpaidmoney")%> + '_'+ checkbox +'').val();//未核销金额
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val(noVerificationAmount);//本次核销金额默认等于未核销金额
              }else{
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').attr('readonly',true);
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val('');
              }
              countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
              countPayTotalMoney();//计算报销总金额,冲销总金额,付款总金额
            });
          }
      });
      var invoiceid ='';//借款发票id
      var orderCode ='';//借款发票号
      var orderAmount=0;//借款发票金额
      var verificationAmount=0;//核销金额
      var noVerificationAmount=0;//未核销金额
      var orderAbstract ='';//借款发票摘要
      // var projectno ='';//项目编号
      var invoicedate ='';//发票日期
      var endtime='';//逾期日期
      var occupymoney = 0; //核销占用金额
      var affertsubtract = 0;  // 可核销金额
      orderCode = dataLoan[i].INVOICE_NUM;//借款发票号
      orderAmount = checkZero(dataLoan[i].AMOUNT_NUM);//借款发票金额
      verificationAmount = checkZero(dataLoan[i].REPAY_AMOUNT_NUM);//已还款金额
      //20180301 modified BY mengly FOR 浮点数精度问题 begin
      //noVerificationAmount = parseFloat(orderAmount) - parseFloat(verificationAmount);//发票金额-已核销金额
      noVerificationAmount = parseFloat(orderAmount) - parseFloat(verificationAmount).toFixed(2);//发票金额-已核销金额
      //20180301 modified BY mengly FOR 浮点数精度问题 end
      orderAbstract = dataLoan[i].DESCRIPTION;//借款发票摘要
      invoiceid = dataLoan[i].INVOICE_ID;//借款发票id
      // projectno = dataLoan[i].project_number;//项目编号
      invoicedate = dataLoan[i].INVOICE_DATE;//发票日期
      endtime = dataLoan[i].PROMISE_REPAYMENT_DATE;//承诺还款日期
      no =i+1;//序号
      //20180301 modified BY mengly FOR 浮点数精度问题 begin
      occupymoney = parseFloat(isunpaidmoney(invoiceid)).toFixed(2); //获取核销占用金额
      //重新计算可核销金额
      affertsubtract = parseFloat(noVerificationAmount).toFixed(2) - parseFloat(occupymoney);
      //20180301 modified BY mengly FOR 浮点数精度问题 end
      //  赋值Start
      setCol(<%=mMap2.get("invoicecode")%> + '_'+ i, orderCode, true, orderCode);
      setCol(<%=mMap2.get("invoicedate")%> + '_'+ i, invoicedate, true, invoicedate);
      setCol(<%=mMap2.get("invoicemoney")%> + '_'+ i, orderAmount, true, orderAmount);
      setCol(<%=mMap2.get("promiserepaydate")%> + '_'+ i, endtime, true, endtime);
      <%-- setCol(<%=mMap2.get("unpaidmoney")%> + '_'+ i, fmoney(noVerificationAmount), true, fmoney(noVerificationAmount)); --%>
      setCol(<%=mMap2.get("unpaidmoney")%> + '_'+ i, fmoney(affertsubtract), true, fmoney(affertsubtract));
      setCol(<%=mMap2.get("abstract")%> + '_'+ i, orderAbstract, true, orderAbstract);
      setCol(<%=mMap2.get("invoiceid")%> + '_'+ i, invoiceid, true, invoiceid);
    }
}
/**
 * 加载借款历史明细（保存后或被退回的表单）
 */
function loadRepaymentDetail(){
  var addbutton1 = jQuery(jQuery("button[name ='addbutton1']")[0]); //隐藏增加行按钮 （借款历史明细）
    addbutton1.hide();
    jQuery(jQuery('input[name="check_all_record"]')[1]).hide();
    var checkboxArr = document.getElementsByName('check_node_1');//获取checkbox数组
    if(checkboxArr.length>0){//本单有冲销借款的明细
    	for(var i=0; i<checkboxArr.length; i++){
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').attr('readonly',true); //设定初期本次核销金额未选中不可编辑
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').removeAttr('onblur');
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').bind('blur',function(){
 	        changeToThousands2(jQuery(this).attr('name'),2);
 	        checkMoney(this);
 		      countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
 	        countPayTotalMoney();//计算报销总金额,冲销总金额,付款总金额
 	      });
 	      //绑定checkbox勾选事件
 	      jQuery('input[name="check_node_1"]').each(function(){
 	        var checkbox = jQuery(this).val();//当前指向
 	          if(checkbox == i){
 	        	  var money = jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val();
	            if(money != null && money != ''){
	              this.checked = true;
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
	            } 
 	            jQuery(this).removeAttr('onclick');
 	            jQuery(this).bind('click', function(){ 
 	              if(this.checked){//如果勾选
 	                var noVerificationAmount = jQuery('#field' + <%=mMap2.get("unpaidmoney")%> + '_'+ checkbox +'').val();//未核销金额
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val(noVerificationAmount);//本次核销金额默认等于未核销金额
 	              }else{
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').attr('readonly',true); 
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val('');
 	              }
 	              countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
 	              countPayTotalMoney();//计算报销总金额,冲销总金额,付款总金额
 	            });
 	          }
 	      });
 	    }
    }else{
    	<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
      	var dataLoan = new Array();
		    dataLoan = getLoanData(employno);//从数据库中获取借款历史明细
		    loadRepaymentDetailBeforeSave(dataLoan);//加载借款历史明细
    	<%} %>
    }
}

//计算冲销总金额
function countRepayTotalMoney(fieldname){
  jQuery(fieldname).focus();
  jQuery(fieldname).blur();
}

//计算总金额
function countPayTotalMoney(){
  var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%> ).val();
  var repaytotalmoney = jQuery('#field' + <%=mMap.get("reversaltotalmoney")%> ).val();
  var paytotalmoney = parseFloat(applytotalmoney) - parseFloat(repaytotalmoney);
  setCol(<%=mMap.get("paytotalmoney")%>, fmoney(paytotalmoney), true, '');

  //xuenhua 计算会议费 20190603
	var sumhuiyifee =sumHuiYiFee();
	setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(sumhuiyifee), true, '');
}

/**
 * 加载预算
 * 
 * isApproveNode   是否审批节点
 */
function showBudgetOuter(isApproveNode){
  budgetControlFlag = true;
	//checkWarnRateOnSubmitBefore();
  clearForm(2);
  //20170426 added for 预算控制性能调优 by yandong begin
  //生成费用组合
  getApExpenseSegment();
  //20170426 added for 预算控制性能调优 by yandong end
  jQuery('input[name="check_node_0"]').each(function(){
    var checkbox = jQuery(this).val();
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'span').text();
    if(feetypeName.indexOf('进项税额') != -1)  return true; //忽略掉税行
    var depart;  //费用部门
    var employee;  //员工id
    var feetype;  //费用类型
    var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>);
    feetype = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'').val();
    if(feetype==''||feetype==null)  return true;
    depart = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ checkbox +'').val();  //责任部门no
    employeeNo = jQuery('#field' + <%=mMap1.get("payperson")%> + '_'+ checkbox +'').val(); //员工编号
    var businessprojectno = jQuery('#field' + <%=mMap1.get("projectno")%> + '_'+ checkbox +'span').text().trim(); //业务项目号
    var finprojectno = jQuery('#field' + <%=mMap1.get("financialproject")%> + '_'+ checkbox +'span').text().trim(); //财务项目号
    var money = jQuery('#field' + <%=mMap1.get("money")%> + '_'+ checkbox +'').val(); //金额
    var glprojectcode = jQuery('#field' + <%=mMap.get("glprojectcode")%>).val(); //预算项目代码
    var glCodeStr = getGlCode(employeeNo,feetype,finprojectno);
   // showBudget(orgid.val(),depart,employeeNo,feetype,finprojectno,glprojectcode,businessprojectno,thisorderemoney,isApproveNode);
    showBudget(orgid.val(),depart,employeeNo,feetype,finprojectno,glprojectcode,businessprojectno,isApproveNode,checkbox); //20170706 MODIFIED BY WANGWW checkbox添加
  });
}

//加载预算
function showBudget(orgid,depart,employeeNo,feetype,finprojectno,glprojectcode,businessprojectno,isApproveNode,checkbox){
  var data;
  var glCodeStr = '';
  //20170706 ADDED BY WANGWW START
  var segment1 = jQuery('#field' + <%=mMap1.get("segment1")%> + '_'+ checkbox +'').val();
  var segment2 = jQuery('#field' + <%=mMap1.get("segment2")%> + '_'+ checkbox +'').val();
  var segment3 = jQuery('#field' + <%=mMap1.get("segment3")%> + '_'+ checkbox +'').val();
  var segment4 = jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ checkbox +'').val();
  var segment6 = jQuery('#field' + <%=mMap1.get("segment6")%> + '_'+ checkbox +'').val();
  //20170706 ADDED BY WANGWW END
  //20171012 ADDED BY mengly START
  var thisorderemoney;
  if(isApproveNode == true){
  	 thisorderemoney = 0;
  }else{
	     //thisorderemoney = getFeetypeMoney(feetype);
	     thisorderemoney = getFeetypeMoney(segment4);//20171012 ADDED BY mengly FOR 汇总预算
  }
  //20171012 ADDED BY mengly END
  if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //项目事务
    //data = reloadProjectBudget(orgid,depart,employeeNo,feetype,glprojectcode,businessprojectno);
    glCodeStr = getGlCode(employeeNo,feetype,glprojectcode);
  } else if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 0){//个人事务
    //data = reloadPersonalBudget(orgid,depart,employeeNo,feetype);
    glCodeStr = getGlCode(employeeNo,feetype,finprojectno);
  }
  data = reloadBudget(segment1,segment2,segment3,segment4,segment6);  //20170706 added by wangww
  var language = readCookie("languageidweaver");
  // alert(glCodeStr + '：' + SystemEnv.getHtmlNoteName(-2, language));
  if(data.length == 0){
    budgetControlFlag = false;
    alert('[' + glCodeStr + ']\n科目组合不存在，请申请信息部维护');
  }
  if(data.length > 0){
    addRow2(2);
    var rowsNum = 1 * parseInt(document.getElementById("indexnum2").value)-1;//行号
    var availableMoney=0;//可使用金额
		var warningrate = data[0].WARNING_RATE;
    // jQuery('#field6942_'+rowsNum+'span').html(rowsNum+1);//行号

    setCol(<%=mMap3.get("budgetdept")%> + '_'+rowsNum, data[0].DEPT_DESC, true, data[0].DEPT_DESC);
    setCol(<%=mMap3.get("financialproject")%> + '_'+rowsNum, data[0].DESCFIN_PROJECT_DESC, true, data[0].DESCFIN_PROJECT_DESC);
    setCol(<%=mMap3.get("costtype")%> + '_'+rowsNum, data[0].EXPENSE_CATEGORY_DESC+'.'+data[0].EXPENSE_CLASS_DESC, true, data[0].EXPENSE_CATEGORY_DESC+'.'+data[0].EXPENSE_CLASS_DESC);
    setCol(<%=mMap3.get("budgetwholeyear")%> + '_'+rowsNum, data[0].BUDGET_SUM, true, data[0].BUDGET_SUM);
    setCol(<%=mMap3.get("addupmoney")%> + '_'+rowsNum, data[0].ERP_ACTUAL_AMOUNT, true, data[0].ERP_ACTUAL_AMOUNT);
    setCol(<%=mMap3.get("approvingmoney")%> + '_'+rowsNum, data[0].BPM_ACTUAL_AMOUNT, true, data[0].BPM_ACTUAL_AMOUNT);
    setCol(<%=mMap3.get("warningproportion")%> + '_'+rowsNum, fmoney(warningrate) , true, fmoney(warningrate));
    if(isApproveNode == true){
      availableMoney=data[0].BUDGET_SUM - data[0].ERP_ACTUAL_AMOUNT - data[0].BPM_ACTUAL_AMOUNT;//可使用金额
    } else{
      availableMoney=data[0].BUDGET_SUM - data[0].ERP_ACTUAL_AMOUNT - data[0].BPM_ACTUAL_AMOUNT - thisorderemoney;//可使用金额
      setCol(<%=mMap3.get("currentordermoney")%> + '_'+rowsNum, fmoney(thisorderemoney), true, fmoney(thisorderemoney));
    }
    var performProportion=0;//执行比例
    if(data[0].BUDGET_SUM>0){
      performProportion = fmoney((1-(availableMoney/data[0].BUDGET_SUM))*100,2);
    } 
    //20170511 edited for 预算控制 by mengly begin
    if(data[0].BUDGET_SUM == 0){
      budgetWarnFlag = 1;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
    }
    //20170511 edited for 预算控制 by mengly end
    setCol(<%=mMap3.get("canusemoney")%> + '_'+rowsNum, fmoney(availableMoney), true, fmoney(availableMoney));
    setCol(<%=mMap3.get("proportion")%> + '_'+rowsNum, performProportion, true, performProportion);
    if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //项目事务
       setCol(<%=mMap3.get("projectname")%> + '_'+rowsNum, jQuery('#field' + <%=mMap.get("projectname")%>).val(), true, jQuery('#field' + <%=mMap.get("projectname")%>).val());
    } else if(jQuery('#field' + <%=mMap.get("applytype")%>) == 0){//个人事务
       setCol(<%=mMap3.get("projectname")%> + '_'+rowsNum, '无', true, '无');
    }
    var warningrateVal = document.getElementById('field' + <%=mMap3.get("warningproportion")%> + '_' + rowsNum).value;//预警比例
    var proportionVal = document.getElementById('field' + <%=mMap3.get("proportion")%> + '_' + rowsNum).value;//执行比例
    var canusemoneyVal = document.getElementById('field' + <%=mMap3.get("canusemoney")%> + '_' + rowsNum).value;//可使用金额
    //20170511 edited for 预算控制 by mengly begin
    if(budgetWarnFlag != 1 && canusemoneyVal<0){
      budgetWarnFlag = 2;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
    }
    if(budgetWarnFlag != 1 && budgetWarnFlag != 2 && proportionVal>warningrateVal){
    	budgetWarnFlag = 3;//是否超预算标识位 0是正常，1是预算为0,2是预算超出预警比例，3是有预算但预算不足
    }
    //20170511 edited for 预算控制 by mengly end
  }
}

/**
 * 是否差旅费报销校验（总部差旅费不能和其他费用混报，金卡差旅费除了可以和业务招待费混报，不能和其他费用混报）
 */
function checkIstravel(){
  jQuery('#field' + <%=mMap.get("istripfee_c")%>).val('0');//
  var checkNodeList = document.getElementsByName('check_node_0');//选择行
  for (var i = 0; i < checkNodeList.length ; i++) {
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+i+'span').html();
    if (costType.indexOf('差旅') != -1) {
      jQuery('#field' + <%=mMap.get("istripfee_c")%>).val('1');
      break;
    }
  }
  if(jQuery('#field' + <%=mMap.get("istripfee_c")%>).val() == 1){
	  for(var i = 0; i < checkNodeList.length ; i++) {
	    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();
	    if(orgid.val() == 83){//金卡差旅费除了可以和业务招待费混报，不能和其他费用混报
	    	if(costType.indexOf('进项税额') != -1) {
          continue;
        }
  	    if((costType.indexOf('业务招待费') == -1) && (costType.indexOf('差旅') == -1)){
          return true;
        }
	    }else if(orgid.val() == 81){//总部差旅费不能和其他费用混报
	    	if(costType.indexOf('进项税额') != -1) {
          continue;
        }
  	    if(costType.indexOf('差旅') == -1){
          return true;
        }
	    }
	  }
  }
}

//差旅费天数不能为空
function checktripdaycount(){
	var checkbox = document.getElementsByName('check_node_0');
	//差旅费天数不能为空
	if(jQuery('#field' + <%=mMap.get("istripfee_c")%>).val() == 1){//是差旅费报销
	  for (var i = 0; i < checkbox.length; i++) {
	    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();
	    var daycount = jQuery('#field' + <%=mMap1.get("days")%> + '_' + i).val();
	    if(costType.indexOf('进项税额') != -1){//忽略税行
	      continue;
	    }else if(daycount==''||daycount==null){
	      return true;
	    }
	  }      
	}
}

// 是否业务招待费/会议费
function checkFeetype(){
  jQuery('#field' + <%=mMap.get("isbusinessexpense_c")%>).val('0');//
  var checkNodeList = document.getElementsByName('check_node_0');//选择行
  for (var i = 0; i < checkNodeList.length ; i++) {
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+i+'span').html();
    if(costType.indexOf('会议费') != -1 || costType.indexOf('业务招待费') != -1){
      jQuery('#field' + <%=mMap.get("isbusinessexpense_c")%>).val('1');//
      break;
    }
  }
}
// xuenhua 20190603 统计会议费
function sumHuiYiFee(){
	var huiyifei = 0;
  jQuery('#field' + <%=mMap.get("ishuiyifee")%>).val('否');//
  var checkNodeList = document.getElementsByName('check_node_0');//选择行
  for (var i = 0; i < checkNodeList.length ; i++) {
    var rowIndex = checkNodeList[i].value;
    //jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+rowIndex).html();
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+rowIndex+'span').text();
		var currmoeny_str = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val(); //报销金额(含税)
    if(costType.indexOf('会议费') != -1){
			jQuery('#field' + <%=mMap.get("ishuiyifee")%>).val('是');//
			huiyifei=huiyifei+getFloat(currmoeny_str);
    }
  }
	return huiyifei;
}

//删除核销金额为空的借款行
function deletePrementLine(){				
	var formId = '1';
	var contractdetail = document.getElementsByName('check_node_'+formId);
    for(var i=0;i<contractdetail.length;i++){	
	    var rowIndex = contractdetail[i].value; //获取当前行的索引
	    var checkFlag = document.getElementsByName('check_node_'+formId)[i].checked;		
	    var paidmoney = jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ rowIndex).val();		
		//反选，然后删除
		if(paidmoney == '' || paidmoney == 0){  
            document.getElementsByName('check_node_'+formId)[i].checked=true;
        }else{
            document.getElementsByName('check_node_'+formId)[i].checked=false;
        }
		/* if(!checkFlag){		
		  document.getElementsByName('check_node_'+formId)[i].checked=true;		
		}else{		
			if(paidmoney == '' || paidmoney == 0){	
				document.getElementsByName('check_node_'+formId)[i].checked=true;
			}else{	
				document.getElementsByName('check_node_'+formId)[i].checked=false;
			}	
		} */		
  }				
  delRowFun_new(formId); //删除选中行				
}				


//提交前验证电子发票号
function checkElecNoOnSubmitBefore(){
  var expensedetail = document.getElementsByName('check_node_0');//报销明细行
  var elecnos = new Array();
  for(var i = 0;i<expensedetail.length;i++){
    var elecno = jQuery('#field' + <%=mMap1.get("elecerporderno")%> + '_' + i).val();//获取电子发票号
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();//获取费用类型
    if(feetypeName.indexOf('进项税额') != -1||elecno==null||elecno==''){//忽略掉税行和空电子发票号
    	continue;
    }else{
      if(checkInvoiceNoExist(elecno)){//判断是否与数据库中重复
        return true;
      }
      elecnos.push(elecno);
    }
  }
  var elecnosSorted = elecnos.sort();
  for(var i=0;i<elecnosSorted.length-1;i++){
    if(elecnosSorted[i]==elecnosSorted[i+1]){
      alert('本单内有重复电子发票号，重复号为：' + elecnosSorted[i]);
      return true;
    }
  }
}

//验证电子发票重复
function checkInvoiceNoExist(invoiceNo){
  var elec_flag = false;
  var dataElecNo = null;
  dataElecNo = getElecNo(invoiceNo,requestid);
  var length = dataElecNo.length;
  if(length>0){
    alert('电子发票号已使用过：' + dataElecNo[0].ELECERPORDERNO);
    elec_flag = true;
  }
  return elec_flag;
}

//验证数额
function checkNum2(obj){
  var reg = new RegExp('^[0-9]+(.[0-9]{1,2})?$');
  if(!reg.test(obj.value)){
    return true;
  }
  return false;
}

//遍历报销行，返回feetypeid相同的金额总和
function getFeetypeMoney(segment4){
var money = 0.0;
var expensedetail = document.getElementsByName('check_node_0');//报销明细行
	for(var i=0;i<expensedetail.length;i++){
	  var rowIndex = expensedetail[i].value; //获取当前行的索引
	  //20171012 modified BY mengly START
	  var segment4Temp = jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ rowIndex +'').val();//获取segment4
	  <%--  
	  var feetypeid1 = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex +'').val();//获取费用类型id
	  var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex +'span').text();//获取费用类型id
	   --%>
	  //20171012 modified BY mengly END
	  var moneytext = jQuery('#field' + <%=mMap1.get("money")%> + '_'+ rowIndex +'').val();//获取金额
	  var moneytext1 = moneytext.replaceAll(',','');
	  if(moneytext1==''||moneytext1==null){
	    moneytext1=0;
	  }
	  if(segment4Temp == segment4){
	    money += parseFloat(moneytext1);
	  }
	}
	return money;
}

//退回或保存后，报销行初始化
function setLineDisplay(){
  var contractdetail = document.getElementsByName('check_node_0');//报销明细行
  for(var i=0;i<contractdetail.length;i++){
    var rowIndex = contractdetail[i].value; //获取当前行的索引
    //20171209 modefied by ect jiaing start
    /* addRowDetail0(rowIndex); */
    addRowDetail0('0',rowIndex);
    //20171209 modefied by ect jiaing end
  }
}
// 20171209 added by ect jiajing start
function setLineDisplay7(){
      var contractdetail = document.getElementsByName('check_node_6');//报销明细行
      for(var i=0;i<contractdetail.length;i++){
        var rowIndex = contractdetail[i].value; //获取当前行的索引
        //addRowDetail0(rowIndex);
        addRowinvoic('6',rowIndex);
      }
}
function setLineDisplay10(){
    var contractdetail = document.getElementsByName('check_node_9');//报销明细行
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //获取当前行的索引
      //addRowDetail0(rowIndex);
      addRowinvoic('9',rowIndex);
      addRowControl('9',rowIndex);//added by zuoxl for 事项申请给报销明细行增加控制
    }
}
//20171209 added by ect jiajing end
//20171219 added by ect jiajing start
function setLineDisplay8(){
    var contractdetail = document.getElementsByName('check_node_8');//报销明细行
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //获取当前行的索引
      //addRowDetail0(rowIndex);
      addRowinvoic('8',rowIndex);
      addRowControl('8',rowIndex);//added by zuoxl for 事项申请给报销明细行增加控制
    }
}
//20180320 added by zuoxl for 事项申请给交通明细行增加控制 begin 
function setLineControl7(){
    var contractdetail = document.getElementsByName('check_node_7');//报销明细行
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //获取当前行的索引
      addRowControl('7',rowIndex);//added by zuoxl for 事项申请给报销明细行增加控制
    }
}
//20180320 added by zuoxl for 事项申请给交通明细行增加控制 end 
// 20171219 added by ect jiajing end
//报销明细行  加行控制
// 20171209 modefied by ect jiajing start
<%-- function addRowDetail0(setrowindex){
	  var ind1 = 1 * parseInt(document.getElementById("indexnum0").value)-1; //获取当前行的索引
	  if(setrowindex != null && setrowindex != ''){ 
		  ind1 = setrowindex; 
	  }
	  if(ind1<0){
	    return ;
	  }
    if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){//如果是项目事务
      setNeedCheck(<%=mMap1.get("taskno")%> + '_' + ind1,true); //任务号设置为必填
      var projectNo = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val();
      setCol(<%=mMap1.get("projectno")%> + '_'+ind1, projectNo, true, projectNo);//设置项目号
      jQuery('#field' + <%=mMap1.get("taskno")%> + '_' + ind1 + '__').attr('readonly',true);//任务号不可自动完成
    }else{//如果是个人事务
      setNeedCheck(<%=mMap1.get("taskno")%> + '_' + ind1,false); //任务号设置为只读
    }
    jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + ind1 + '__').attr('readonly',true);//费用类型不可自动完成 
    jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + ind1 + '__').attr('readonly',true);//报销人不可自动完成
    var elecObj = jQuery('#field' + <%=mMap1.get("elecerporderno")%> + '_'+ ind1 +'');//电子发票号
    elecObj.bind('change',function(){ 
      elecerporderno = jQuery(this).val();
      var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + ind1 + 'span').html();//获取费用类型
      if(feetypeName.indexOf('进项税额') == -1){//忽略掉税行
        checkInvoiceNoExist(elecerporderno);
      }
    });
    jQuery('#field' + <%=mMap1.get("money")%> + '_'+ ind1 +'').removeAttr('onblur');
    jQuery('#field' + <%=mMap1.get("money")%> + '_'+ ind1 +'').bind('blur',function(){ //金额 字段的onblur
      changeToThousands2(jQuery(this).attr('name'),2); 
      checkMoney(this);
      countDetailMoney(0, <%=mMap1.get("money")%>, <%=mMap.get("applytotalmoney")%>);
      countPayTotalMoney();//计算报销总金额,冲销总金额,付款总金额
    });
    var data = new Array();
    var dutydeptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val();
    data = getDutyDept(dutydeptNo,orgid.val());//行上的责任部门
    if(data.length>0){
      setCol(<%=mMap1.get("dutydepartment")%> + '_'+ind1, jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(), true, data[0].DESCRIPTION);
    } else {
    	deptNameIsNull = true;
    }
    if(setrowindex==null||setrowindex==''){
	    data = getEmployeeName(employno,orgid.val(),dutydeptNo);//行上的报销人和责任人
	    if(data.length > 0){
	      setCol(<%=mMap1.get("payperson")%> + '_'+ind1, employno, true, data[0].LAST_NAME);
	      setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+ind1, data[0].LAST_NAME, false, '');
	    }
   }
} --%>
function addRowDetail0(formId,rownum){
    var rowIndex = rownum; 
    if(rowIndex == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum" + formId).value)-1; //获取当前行的索引       
    }
    if(rowIndex<0){
      return ;
    }
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
    var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //进项税文本
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).attr('readonly',true);  //不含税金额不可编辑
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).attr('readonly',true); //设置本币金额不可编辑
    if(expensebill.val() == '2'){
		//20180827 added by zuoxl for 业务招待费报销时，隐藏报销行的税率 税额 金额（不含税）字段  begin
    	  jQuery("#zd_taxrate").hide();//税率不显示隐藏
    	  jQuery("#zd_taxrate_1").hide();//税率不显示隐藏
          jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().hide();
    	  jQuery("#zd_taxamount").hide();//税额不显示隐藏
    	  jQuery("#zd_taxamount_1").hide();//税额不显示隐藏
          jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().hide();
		  setCol(<%=mMap1.get("taxmoney")%> + '_' + rowIndex,0,true,0);//设置税额值
          setNeedCheck_cc( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,false);
    	  jQuery("#zd_notaxamount").hide();//金额（不含税）隐藏
    	  jQuery("#zd_notaxamount_1").hide();//金额（不含税）隐藏
          jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().hide();
    	  //20180827 added by zuoxl for 业务招待费报销时，隐藏报销行的税率 税额 
        jQuery("#person_num1").show();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().show();
        jQuery("#person_num2").show();
        jQuery("#server_rank1").show();
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().show();
        jQuery("#server_rank2").show();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).attr('readonly',false); //设置招待人数可编辑       
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).attr('readonly',false); //设置招待级别可编辑      
        if(orgid.val() == '251' || orgid.val() =='252' || orgid.val()=='253'){ //四川公司
            setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,true); //招待人数必填
            setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,true); //招待级别必填
        }else{//其他公司不必填
            setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,false); //招待人数不必填
            setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,false); //招待级别不必填
        }       
    }else{      
        setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,false); //招待人数非必填
        setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,false); //招待级别非必填
		//20180827 added by zuoxl for 业务招待费报销时，显示报销行的税率 税额 金额（不含税）字段  begin
          jQuery("#zd_taxrate").show();//税率不显示显示
          jQuery("#zd_taxrate_1").show();//税率不显示显示
          jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().show();
          jQuery("#zd_taxamount").show();//税额不显示显示
          jQuery("#zd_taxamount_1").show();//税额不显示显示
          jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().show();
          setNeedCheck_cc( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true);
          jQuery("#zd_notaxamount").show();//金额（不含税）显示
          jQuery("#zd_notaxamount_1").show();//金额（不含税）显示
          jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().show();
          //20180827 added by zuoxl for 业务招待费报销时，显示报销行的税率 税额 
        jQuery("#person_num1").hide();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().hide();
        jQuery("#person_num2").hide();
        jQuery("#server_rank1").hide();
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().hide();
        jQuery("#server_rank2").hide();
    }
    <%-- jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex + '_').attr('readonly',true); //设置税额只读 --%>
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex + '_').attr('readonly',true); //设置不含税金额只读
  //项目事物设置任务号必填，个人事物设置任务号只读
  if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){//如果是项目事务
    setNeedCheck(<%=mMap1.get("taskno")%> + '_' + rowIndex,true); //任务号设置为必填
    var projectNo = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val();
    setCol(<%=mMap1.get("projectno")%> + '_'+rowIndex, projectNo, true, projectNo);//设置项目号
    jQuery('#field' + <%=mMap1.get("taskno")%> + '_' + rowIndex + '__').attr('readonly',true);//任务号不可自动完成
    if(orgid.val() == '526'){
        setNeedCheck(<%=mMap1.get("cotrial")%> + '_' + rowIndex,true);//设置‘费用分类’必填
        setNeedCheck(<%=mMap1.get("businesstype")%> + '_' + rowIndex,true);//设置‘业务类型’必填
        jQuery('#field' + <%=mMap1.get("cotrial")%> + '_' + rowIndex + '__').attr('readonly',true);//费用分类不可自动完成
        jQuery('#field' + <%=mMap1.get("businesstype")%> + '_' + rowIndex + '__').attr('readonly',true);//业务类型不可自动完成
    }
  }else{//如果是个人事务
    setNeedCheck(<%=mMap1.get("taskno")%> + '_' + rowIndex,false); //任务号设置为只读
    if(orgid.val() == '526'){
        setNeedCheck(<%=mMap1.get("cotrial")%> + '_' + rowIndex,false);//设置‘费用分类’只读
        setNeedCheck(<%=mMap1.get("businesstype")%> + '_' + rowIndex,false);//设置‘业务类型’只读
    }
  }
  jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + '__').attr('readonly',true);//费用类型不可手动填写 
  jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + rowIndex + '__').attr('readonly',true);//报销人不可手动填写
  jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex +'').removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex +'').bind('change',function(){ //金额 字段的onblur
    changeToThousands2(jQuery(this).attr('name'),2);  //转换为金额千分位
    checkMoney(this);
    /* refreshmoney(); //金额计算 */
    //计算冲销总金额、应付款金额
    var checkboxArr = document.getElementsByName('check_node_1');//获取checkbox数组
    if(checkboxArr.length>0){//本单有冲销借款的明细
        for(var i=0; i<checkboxArr.length; i++){
          //绑定checkbox勾选事件
            jQuery('input[name="check_node_1"]').each(function(){
                var checkbox = jQuery(this).val();//当前指向
                if(checkbox == i){
                    countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
                    countPayTotalMoney();   
                }
            });
        }
    }
    setCol(<%=mMap1.get("taxmoney")%>+ '_' + rowIndex,'',false,''); //清空税额
    setCol(<%=mMap1.get("money")%>+ '_' + rowIndex,'',false,''); //清空不含税金额
    refreshmoney(); //金额计算
	getTaxmoney();//税额计算
   <%--  var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val(); //获取报销金额含税
    var exchangerate = jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).val(); // 获取汇率
    var localmoney = getFloat(currmoeny) * getFloat(exchangerate);
    setCol(<%=mMap1.get("localmoney")%> + '_'+ rowIndex,fmoney(localmoney),false,fmoney(localmoney)); // 回写本币金额 --%>
    
  });
  //20190505 added by raoanyu for 绑定税率change事件
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).bind('change',function(){
  	  setCol(<%=mMap1.get("taxmoney")%>+ '_' + rowIndex,'',false,''); //清空税额
      setCol(<%=mMap1.get("money")%>+ '_' + rowIndex,'',false,''); //清空不含税金额
  	  getTaxmoney();//税额计算
  });
  //setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //税额必填
  setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,false); //不含税金额不必填
  jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex + '_').attr('readonly',true); //不含税金额只读
  
  //设置税率不可手动填写
  jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex + '__').attr('readonly',true); //设置税率不可编辑
  jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
      jQuery(this).remove();
  });
  //绑定税率onblur 事件
  <%-- jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //税率 字段的onblur
      var taxrateval = jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex).val();
      if (taxrateval != null && taxrateval != ''){
          refreshmoney(); //金额计算
      }   
  }); --%>
 //绑定税额onblur 事件
  jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).bind('change',function(){
      var moneyline1 = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();
      var taxmoneyline1 = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).val();  // 不含税金额
      if(account_segment.val() != '21710101'){
          if (getFloat(taxmoneyline1) > getFloat(moneyline1)){
              alert('税额不能大于报销金额');
              return;
          }
          var currmoenyline1 = getFloat(moneyline1) - getFloat(taxmoneyline1);
          setCol(<%=mMap1.get("money")%> + '_'+ rowIndex,fmoney(currmoenyline1),false,fmoney(currmoenyline1));
      }
      // add by sdaisino 报销单打印页面优化 start
      var verform = document.getElementById("verform");
      if (verform) {
          var detailLine0 = document.getElementsByName('check_node_0');
	      var taxmoney = parseFloat(0);
	      for(var i = 0;i < detailLine0.length;i++){
	          var myIndex = detailLine0[i].value;
	          var taxText = jQuery('#field22369_'+ myIndex); //进项税文本
	          if(taxText.val() != '21710101'){
	              if (jQuery('#field22364_'+ myIndex).val() != '') {
	                  taxmoney = parseFloat(taxmoney)+ parseFloat(jQuery('#field22364_'+ myIndex).val());
	              }
	          } 
	      }
		  var myTax = document.getElementById('zd_taxamount_1');
		  myTax.innerHTML = '';
		  if (!isNaN(taxmoney)) {
	          myTax.innerHTML = "<span >" + taxmoney.toFixed(2)+ "</span>";
	        } 
      }
	  // add by sdaisino 报销单打印页面优化 end
  }); 
  //绑定汇率onblur事件
  jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).bind('blur',function(){
      refreshmoney(); //计算金额
  });
  
  var currencyhead = jQuery('#field' + <%=mMap.get("currency")%>); //获取头信息币种
  var currencyline = jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex); //获取头信息币种
  if (currencyhead.val() == currencyline.val()){
      setCol(<%=mMap1.get("exchangerate")%> + '_' + rowIndex,1,false,1);//设置汇率初期值 
      jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',true); //汇率不可编辑
  }else{
      jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',false); //汇率不可编辑
  }
  //币种onchagne事件
  jQuery('#field' + <%=mMap1.get("currency_text")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("currency_text")%> + '_'+ rowIndex).bind('change',function(){ //税率 字段的onblur
      if (currencyhead.val() == currencyline.val()){
          setCol(<%=mMap1.get("exchangerate")%> + '_' + rowIndex,1,false,1);//设置汇率初期值 
          jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',true); //汇率不可编辑
      }else{
          jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',false); //汇率不可编辑
      }
  });
  var data = new Array();
  var dutydeptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val();
  if(rownum=='no'){
      data = getEmployeeName(employno,orgid.val(),dutydeptNo);//行上的申请人和使用人
      if(data.length > 0){
        setCol(<%=mMap1.get("payperson")%> + '_'+rowIndex, employno, true, data[0].LAST_NAME);
        setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+rowIndex, data[0].LAST_NAME, false, '');
      }           
  }
  
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex +'_browserbtn').hide();   //隐藏申请部门查询按钮
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex +'__' ).attr('readonly',true); //设置申请人部门只读
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
      jQuery(this).remove();
  });
  
  //绑定行上申请人
  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).bind('blur',function(){  //申请人文本
      var payperson_text =  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).val();
      var applyperson = jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + rowIndex).val();
      var applydepthead = jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex).val(); //经办人部门id
      var applydept; //申请部门
      var dutypersonmemo; //使用人
      var dutydepartment; //费用承担部门
      var applydeptName;
      if (payperson_text != '' && payperson_text != null){
          jQuery.ajax({
              url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
              type : "post",
              async : false,
              data : {"action":"get_bpm_applydept","applyperson":applyperson} ,  
              dataType : 'json',
              success: function (json){
                if(json.flag=='s'){
                    applydept = json.map.ID;            // 申请部门
                    dutypersonmemo = json.map.LASTNAME; //使用人
                    dutydepartment = json.map.SEGMENT2; // 申请人部门
                    applydeptName = json.map.DEPARTMENTNAME; //申请人部门名称
                }
              },
              error: function (){
                alert('error...');
              }
         });
         
         setCol(<%=mMap1.get("applydept")%> + '_'+rowIndex, applydept, true, applydeptName);  //申请人部门           
         setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+rowIndex, dutypersonmemo, false, dutypersonmemo);  // 使用人          
        <%--  if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97'){
             jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').hide();  //隐藏费用承担部门查询按钮
             jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',true); //设置费用承担部门只读
             setCol(<%=mMap1.get("dutydepartment")%> + '_'+rowIndex, erp_detpno, true, erp_deptname); //费用承担部门
         }else{
             setNeedCheck( <%=mMap1.get("dutydepartment")%> + '_' + rowIndex,true); //费用 承担部门必填
         } --%>           
      }
  });
  //设置经办人部门显示/隐藏
  if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97' || orgid.val() == '662'|| orgid.val() == '723'){
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').hide();  //隐藏费用承担部门查询按钮
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',true); //设置费用承担部门只读
  }else{
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').show();  //显示费用承担部门查询按钮
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',false); //设置费用承担部门非只读
      setNeedCheck( <%=mMap1.get("dutydepartment")%> + '_' + rowIndex,true); //费用 承担部门必填
  }
  <%-- var applydeptheadId = jQuery('#field' + <%=mMap.get("applydept")%>).val(); //经办人部门id
  var deptseg_c = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //部门段
  var departmentcode = '';
  var departmentname = '';
  jQuery.ajax({
      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
      type : "post",
      async : false,
      data : {"action":"get_applydept","applydeptid":deptseg_c} ,  
      dataType : 'json',
      success: function (json){
        if(json.flag=='s'){
            departmentcode = json.map.DEPARTMENTCODE; //费用承担部门code
            departmentname = json.map.DEPARTMENTNAME; //费用承担部门名称
        }
      },
      error: function (){
        alert('error...');
      }
 }); --%>
  if(rownum == 'no'){
	  var data = new Array(); 
	  var deptseg_c = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //部门段
      var deptSegment = splitString(deptseg_c,'-',0);
      data = getDutyDept(deptSegment,orgid.val());//行上的责任部门
      if(data.length>0){
    	  setCol(<%=mMap1.get("dutydepartment")%> + '_'+rowIndex, deptSegment, true, data[0].DESCRIPTION); //费用承担部门 
      }      
  }
 //绑定科目段文本
 jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).removeAttr('onblur');
 jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).bind('blur',function(){
     
     if(account_segment.val() == '21710101'){ //进项税
       //清空初始化项目
          //20190218 added by sdaisino  for 生成进项税行  begin
          if (!jxsFlg) {
              setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex, '', true, '');  //清空税额
          }
          //20190218 added by sdaisino for 生成进项税行  end
          setCol(<%=mMap1.get("currency")%> + '_'+rowIndex, '', true, '');  //清空币种
          setCol(<%=mMap1.get("exchangerate")%> + '_'+rowIndex, '', true, '');  //清空汇率
          setCol(<%=mMap1.get("localmoney")%> + '_'+rowIndex, '', true, '');  //清空本币金额
          //20180110 modefied by ect qiwf start
          // setCol(<%=mMap1.get("invoicecount")%> + '_'+rowIndex, '', true, '');  //清空附件张数
          // setCol(<%=mMap1.get("feeinstruction")%> + '_'+rowIndex, '', true, '');  //清空说明
          jQuery('#field' + <%=mMap1.get("invoicecount")%>).val('');	//清空附件张数
          jQuery('#field' + <%=mMap1.get("feeinstruction")%>).val(''); //清空说明
          //20180110 modefied by ect qiwf end
          setCol(<%=mMap1.get("money")%> + '_'+rowIndex, '', true, '');  //不含税金额
          inputtaxhide(rowIndex); //设置进项税行项目隐藏
     }else{
          //初始化项目
          //20190218 added by sdaisino  for 生成进项税行  begin
          if (!jxsFlg) {
              setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex, '', true, '');  //清空税额
          }
          //20190218 added by sdaisino for 生成进项税行  end
          setCol(<%=mMap1.get("currency")%> + '_'+rowIndex, 'CNY', true, 'CNY');  //币种
          setCol(<%=mMap1.get("exchangerate")%> + '_'+rowIndex, 1, false, 1);  //汇率
          //20180110 modefied by ect qiwf start
          // setCol(<%=mMap1.get("invoicecount")%> + '_'+rowIndex, '', true, '');  //清空附件张数
          // setCol(<%=mMap1.get("feeinstruction")%> + '_'+rowIndex, '', true, '');  //清空说明
          jQuery('#field' + <%=mMap1.get("invoicecount")%>).val('');	//清空附件张数
          jQuery('#field' + <%=mMap1.get("feeinstruction")%>).val(''); //清空说明
          //20180110 modefied by ect qiwf end
          setCol(<%=mMap1.get("money")%> + '_'+rowIndex, '', true, '');  //不含税金额
          inputtaxshow(rowIndex);
     }
 });
 if(account_segment.val() == '21710101'){//进项税
	 inputtaxhide(rowIndex); //设置进项税行项目隐藏
 }
}
//20171209 modefied by ect jiajing end

//项目编号,项目经理等项目相关表单项目的显示控制,以及与项目相关的flag字段设置
function setProjectContentDisplay(expensetypeSelect){
   if(expensetypeSelect.val() == 1){ //项目事务
     jQuery('#field' + <%=mMap.get("isproject_c")%>).val('Y');//设定‘是否项目’字段
     jQuery("#projectNo").show(); //显示项目信息
     jQuery("#projectManager").show();//显示项目信息
     setNeedCheck(<%=mMap.get("projectno")%>,true);//设置‘项目编号’必填
   } else if(expensetypeSelect.val() == 0){//个人事务
     jQuery('#field' + <%=mMap.get("isproject_c")%>).val('N');//设定‘是否项目’字段
     jQuery("#projectNo").hide();//隐藏项目信息
     jQuery("#projectManager").hide();//隐藏项目信息
     jQuery('#field' + <%=mMap.get("projectno")%>).val('');//项目编号
     jQuery('#field' + <%=mMap.get("projectname")%>).val('');//项目名称
     jQuery('#field' + <%=mMap.get("projectmanager")%>).val('');//项目经理
     jQuery('#field' + <%=mMap.get("glprojectcode")%>).val('');//预算项目代码
     setNeedCheck(<%=mMap.get("projectno")%>,false);//设置‘项目编号’非必填
   }
}

//校验金额
function checkMoney(obj){
   if(jQuery(obj).val()!='' && jQuery(obj).val()!= null){
      jQuery(obj).val(fmoney(jQuery(obj).val()));
      if(checkNum2(obj)){
   	     alert('金额必须为数字，且不能为负数');
   	     jQuery(obj).val('');
   	  }
   }
}

/**
 * 导入ERP按钮事件
 */
function importERPOuter(){
   var invoiceNum = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();
   if(invoiceNum!=null && invoiceNum != ''){
	     alert('已经导入过erp系统，不能重复导入！');
     return;
   }else{
     importERP();
   }
}

/**
 * 导入ERP
 */
function importERP(){
	var gldate = jQuery('#field' + <%=mMap.get("billingdate")%>).val();
	var pEmployeeNo = null;
  var userInfo = getUserInfo(currentUserId);
  pEmployeeNo = userInfo.map.WORKCODE;//员工编号
	// 导入erp
  jQuery.ajax({
    url : "/interface/aisino/com/cn/jsp/personal_expense.jsp",
    type : "post",
    async : false,
    data : {"action":"importERP2","requestid":requestid,"gldate":gldate,"pEmployeeNo":pEmployeeNo} ,  
    dataType : 'json',
    success: function (json){
  	 /*  alert(json.map.p_return_message);
  	   alert(json.map.p_return_status); */
      if(json.map.p_return_status != 'S'){
        	alert(json.map.p_return_message);
      }else{
      	alert('导入成功');
      	location.reload();
      }
    },
    error: function (){
      alert('导入失败');
    }
  }); 
}

/*收款人明细按钮跳转 逻辑，提交控制   author：冯金龙  begin*/
function payShare(){
	if(requestid == -1){
		alert('请先保存后，在进行编辑收款人明细');
		return false;
	}
	//20180110 add by ect qiwf start
    //判断是否需要填写收款人明细
    var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val(); //付款总金额
    if(getFloat(paytotalmoney) <= 0){
    	alert('付款总金额为"0",无需填写收款人明细!');
        return false;
    }   
    //20180110 add by ect qiwf end
	var orgid1 = jQuery('#field' + <%=mMap.get("applycompany")%>).val();
	var totalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	//http://10.121.1.92/formmode/view/AddFormMode.jsp?modeId=1&formId=-10&type=1
	//window.location.href = '/formmode/view/AddFormMode.jsp?modeId=1&#38;formId=-10&#38;type=1&requestid=' + requestid + '&orgid='+ orgid1 +'&totalmoney='+ totalmoney +'';
    var billid = 0;
	  // 查询是否存在收款人明细
	  jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"getPaymentShare","requestid":requestid} ,  
	    dataType : 'json',
	    success: function (json){
	    	data = json.list;
	    	if(data.length > 0){
	    		billid = data[0].ID;
	    	}
	    },
	    error: function (){
	      alert('查询收款人明细id异常');
	      return false;
	    }
	  });
	  if(billid == 0){
		  window.open('/formmode/view/AddFormMode.jsp?modeId=1&formId=-6&type=1&requestid=' + requestid + '&orgid='+ orgid1 +'&totalmoney='+ totalmoney +'');	  
	  }else{
		  updatePayHeader(billid,totalmoney);//修改分摊头金额
		  window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=1&formId=-6&type=0&billid='+ billid +'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');	  
	  }
}
function selectShare(){
	var data = new Array();
	 // 查询是否编辑过收款人明细
	  jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"checkPayShareYN","requestid":requestid} ,  
	    dataType : 'json',
	    success: function (json){
	    	data = json.list;
	    },
	    error: function (){
	      alert('查询收款人明细id错误');
	    }
	  });
	if(data.length > 0){
		onShowBrowser2('',
		  		  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.selectPayShare','','','');
  	}else{
  		alert('无收款人明细，不可以查看');
  		return false;
  	}
	//window.open('/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.selectPayShare');
}

//获取分摊头状态
function checkPayStatus(){
	var data = new Array();
	jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"checkPayShareYN","requestid":requestid} ,  
	    dataType : 'json',
	    success: function (json){
	    	if(json.flag == 's'){
	    		data = json.list;
	    	}
	    },
	    error: function (){
	      alert('查询收款人明细头状态错误');
	    }
	  });
	if(data.length > 0){
		if(data[0].HEADERSTATUS != '成功'){
			return true;
		}
	}
}
//验证分摊金额是否正确
function checkTaxMoney(){
	var taxTotalMoney = 0;
	var payTotalMoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	var data = new Array();
	jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"checkTaxMoney","requestid":requestid} ,  
	    dataType : 'json',
	    success: function (json){
	    	if(json.flag == 's'){
	    		data = json.list;
	    	}
	    },
	    error: function (){
	      alert('查询收款人明细信息错误');
	    }
	  });
	for(var i = 0; i < data.length; i++){
		taxTotalMoney = parseFloat(data[i].SHAREMONEY) + parseFloat(taxTotalMoney);
	}
	if(parseFloat(payTotalMoney).toFixed(2) != parseFloat(taxTotalMoney).toFixed(2) && parseFloat(taxTotalMoney).toFixed(2) != 0){
		return true;
	}
}

function updatePayHeader(id,money){
	jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"updatePayHeader","id":id,"money":money} ,  
	    dataType : 'json',
	    success: function (json){
	    },
	    error: function (){
	      alert('更改收款人明细头金额错误');
	    }
	  });
}
/*收款人明细按钮跳转 逻辑，提交控制   author：冯金龙  end*/


//申请人是否在某个矩阵中
function checkInMatrix(applyPerson,matrixId,columnName){
		var count = 0;
	  jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"checkInMatrix","applyPersonId":applyPerson,"matrixId":matrixId,"columnName":columnName} ,  
	    dataType : 'json',
	    success: function (json){
	      if(json.flag == 's'){
	        	count = json.map.COUNT1;
	      }
	    },
	    error: function (){
	      alert('error...');
	    }
	  }); 
	  return count;
}



//矩阵中符合条件的记录
function checkValueInMatrix(applyPerson,matrixId,columnName){
		var deptcode = '';
	  jQuery.ajax({
	    url : "/interface/aisino/com/cn/jsp/personal_expense.jsp",
	    type : "post",
	    async : false,
	    data : {"action":"checkValueInMatrix","applyPersonId":applyPerson,"matrixId":matrixId,"columnName":columnName} ,  
	    dataType : 'json',
	    success: function (json){
	      if(json.flag == 's'){
	    	  deptcode = json.map.DUTYDEPT;
	      }
	    },
	    error: function (){
	      alert('error...');
	    }
	  }); 
	  return deptcode;
}


//责任部门是否为空 
function isLineDeptNull(){
	var isLineDeptNullFlag = false;
	var expensedetail = document.getElementsByName('check_node_0');//报销明细行
	for(var i=0;i<expensedetail.length;i++){
	  var rowIndex = expensedetail[i].value; //获取当前行的索引
	  var dutydept = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ rowIndex).val();//责任部门 
	  if(dutydept == '' || dutydept == null){
		  isLineDeptNullFlag = true;
	  }
	}
	return isLineDeptNullFlag;
}

//获取费用报销的费用组合
function getApExpenseSegment(){
  var expenseType = jQuery('#field' + <%=mMap.get("applytype")%>);//报销类型
  var projectid = jQuery('#field' + <%=mMap.get("projectno")%>);//报销头信息的项目编号
  var projectno = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val(); //业务项目号
  var seg1 = jQuery('#field' + <%=mMap.get("compseg_c")%>).val();
  jQuery('input[name="check_node_0"]').each(function(){
    var checkbox = jQuery(this).val();
    var departmentCode = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ checkbox +'').val();
    var employeeNumber = jQuery('#field' + <%=mMap1.get("payperson")%> + '_'+ checkbox +'').val();
    var parameterId = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'').val();
    //segment1
    //获取公司段
    jQuery('#field' + <%=mMap1.get("segment1")%> + '_'+ checkbox +'').val(seg1);
    //segment2
    //获取部门段
    jQuery('#field' + <%=mMap1.get("segment2")%> + '_'+ checkbox +'').val(departmentCode);
    //报销行为进项税额
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'span').text();
    if(feetypeName.indexOf('进项税额') != -1) {
      //segment3
      //获取科目段
      jQuery.ajax({
      url : "/interface/aisino/com/cn/jsp/ExpenseSegmentDao.jsp",
        type : "post",
        async : false,
        data :   {"action":"getExpParamSegment3","parameterId":parameterId},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
                jQuery('#field' + <%=mMap1.get("segment3")%> + '_'+ checkbox +'').val(json.map.SEGMENT3);
          }
        },
        error: function (){
          alert('error3...');
        }
      });
      //segment4
      //获取子目段
      jQuery.ajax({
      url : "/interface/aisino/com/cn/jsp/ExpenseSegmentDao.jsp",
        type : "post",
        async : false,
        data :   {"action":"getSegment4","parameterId":parameterId},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
                jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ checkbox +'').val(json.map.SEGMENT4);
          }
        },
        error: function (){
          alert('error4...');
        }
      });
      jQuery('#field' + <%=mMap1.get("segment6")%> + '_'+ checkbox +'').val('0');
    }else{//报销行非进项税额

      //segment3
      //获取科目段
      jQuery.ajax({
      url : "/interface/aisino/com/cn/jsp/ExpenseSegmentDao.jsp",
        type : "post",
        async : false,
        data :   {"action":"getSegment3","employeeNumber":employeeNumber},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
                jQuery('#field' + <%=mMap1.get("segment3")%> + '_'+ checkbox +'').val(json.map.SEGMENT3);
          }
        },
        error: function (){
          alert('error3...');
        }
      });
      //segment4
      //获取子目段
      jQuery.ajax({
      url : "/interface/aisino/com/cn/jsp/ExpenseSegmentDao.jsp",
        type : "post",
        async : false,
        data :   {"action":"getSegment4","parameterId":parameterId},  
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
                jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ checkbox +'').val(json.map.SEGMENT4);
          }
        },
        error: function (){
          alert('error4...');
        }
      });
      
      //segment6
      //获取项目段
      //财务项目对应的segment6
      if(expenseType.val() == 0 && (projectid.val() == null || projectid.val() == '')) {
        var seg6 = jQuery('#field' + <%=mMap1.get("financialproject")%> + '_'+ checkbox +'').val();
        jQuery('#field' + <%=mMap1.get("segment6")%> + '_'+ checkbox +'').val(seg6);
      }else{
        jQuery.ajax({
          url : "/interface/aisino/com/cn/jsp/ExpenseSegmentDao.jsp",
            type : "post",
            async : false,
            //data :   {"action":"getProjSegment6","projectno":projectno},  
            data :   {"action":"getProjSegment6","projectNumber":projectno},  //20170706 modified by wangww
            dataType : 'json',
            success: function (json){
              if(json.flag=='s'){
                    jQuery('#field' + <%=mMap1.get("segment6")%> + '_'+ checkbox +'').val(json.map.SEGMENT6);
              }
            },
            error: function (){
              alert('errorproj6...');
            }
          });
      }
    }

    jQuery('#field' + <%=mMap1.get("segment5")%> + '_'+ checkbox +'').val('0');
    jQuery('#field' + <%=mMap1.get("segment7")%> + '_'+ checkbox +'').val('0');
    jQuery('#field' + <%=mMap1.get("segment8")%> + '_'+ checkbox +'').val('0');
        //费用组合设置
    var segment1 = jQuery('#field' + <%=mMap1.get("segment1")%> + '_'+ checkbox +'').val();
      var segment2 = jQuery('#field' + <%=mMap1.get("segment2")%> + '_'+ checkbox +'').val();
      var segment3 = jQuery('#field' + <%=mMap1.get("segment3")%> + '_'+ checkbox +'').val();
      var segment4 = jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ checkbox +'').val();
      var segment5 = jQuery('#field' + <%=mMap1.get("segment5")%> + '_'+ checkbox +'').val();
      var segment6 = jQuery('#field' + <%=mMap1.get("segment6")%> + '_'+ checkbox +'').val();
      var segment7 = jQuery('#field' + <%=mMap1.get("segment7")%> + '_'+ checkbox +'').val();
      var segment8 = jQuery('#field' + <%=mMap1.get("segment8")%> + '_'+ checkbox +'').val();
      var gl_combination = segment1 + '.' + segment2 + '.' + segment3 + '.' + segment4 + '.' + segment5 + '.' + segment6 + '.' + segment7 + '.' + segment8;
      jQuery('#field' + <%=mMap1.get("gl_combination")%> + '_'+ checkbox +'').val(gl_combination);
  });
}
//验证申请人是否与填单人是否在同一部门下
function checkemploy(){
	var flag = true;
	//验证报申请人是否与填单人是否在同一部门下
	var contractdetail = document.getElementsByName('check_node_0');//报销明细行
	for(var i=0;i<contractdetail.length;i++){
		var rowIndex = contractdetail[i].value; //获取当前行的索引
		var employno = jQuery('#field'+ <%=mMap1.get("payperson")%> + '_' + rowIndex).val();
		var deptno = jQuery('#field'+ <%=mMap1.get("dutydepartment")%> + '_' + rowIndex).val();
		var data = getEmployeeName(employno,orgid.val(),deptno);// 行上的申请人
		if(data.length == 0){
			linecount = parseInt(rowIndex) + 1;
		  flag = false;
		  break;
		}
  }
	return flag;
}
//20170706 ADDED BY WANGWW STAR
//个人预算和项目预算
function reloadBudget(segment1,segment2,segment3,segment4,segment6){
  var data = new Array();
  jQuery.ajax({
    url : "/interface/aisino/com/cn/jsp/personal_expense.jsp",
    type : "post",
    async : false,
    //processData : false,
    data : {"action":"reloadBudget",
            "segment1":segment1,
            "segment2":segment2,
            "segment3":segment3,
            "segment4":segment4,
            "segment6":segment6
           } ,
    dataType : 'json',
    success: function (json){
      if(json.flag=='s'){
        data = json.list;
      }else if(json.flag=='e'){
        alert(json.error_msg);
        return;
      }
    },
    error: function (){
      alert('error...');
    }
  }); 
  return data;
}
//20170706 ADDED BY WANGWW END
//modifer : fengjl20170630--begin
//判断是否需要业务部门监控
function getBusinessType(){
	//alert(123);
	setCol(<%=mMap.get("business_type_monitor")%>,'0',false,'0');//为是否专项进行标识
	//财务项目号id
	var checknode0 = document.getElementsByName('check_node_0'); //获得报销名称行，行数
	for(var i = 0; i < checknode0.length; i++){
		//alert(123);
		var rowindex = checknode0[i].value;
		var project_number = jQuery('#field'+ <%=mMap1.get("segment6")%> + '_' + rowindex).val();
		var name = '';//统计当前多有财务项目号是否带有 特殊部门监控标记
		jQuery.ajax({
		    url : "/interface/aisino/com/cn/jsp/personal_expense.jsp",
		    type : "post",
		    async : false,
		    data : {"action":"getFeeTemplateName","project_number":project_number},  
		    dataType : 'json',
		    success: function (json){
		      if(json.flag == 's'){
		    	  //alert(json.sql);
		    	  name = json.map.NAME;
		    	  //alert(json.map.NAME);
		      }
		    },
		    error: function (){
		      alert('getFeeTemplateName_error...');
		    }
		  });
		//如果模板存在这个名称，则需要业务部监控
		if(typeof(name) != 'undefined'){//判断查询不到的清空下
			if(name.indexOf('(专项)') != -1){
				setCol(<%=mMap.get("business_type_monitor")%>,'1',false,'1');
				break;
			}
		}	
	}
}
//modifer : fengjl20170630--end
// 20171209 added by ect jiajing start
//根据头信息报销单类型设置明细行的隐藏与显示
function expensebillShow(expensebill){
    if((expensebill.val() == '0') || (expensebill.val() == '2') || (expensebill.val() == '3')){   //通用报销单
        jQuery("#tab_3").hide();  // 隐藏交通费tab页
        jQuery("#tab_4").hide();  // 隐藏住宿费tab页
        jQuery("#tab_5").hide();  // 隐藏补助及其他费用tab页
    }else if(expensebill.val() == '1'){
        jQuery("#tab_3").show();  // 隐藏交通费tab页
        jQuery("#tab_4").show();  // 隐藏住宿费tab页
        jQuery("#tab_5").show();  // 隐藏补助及其他费用tab页
    }
	//201800827 added by zuoxl for 控制明细行税率、税额、金额（不含税）字段显示与隐藏 begin
	var contractdetail = document.getElementsByName('check_node_0');//报销明细行
	if(expensebill.val() == '2'){
		jQuery("#zd_taxrate").hide();//税率不显示隐藏
		jQuery("#zd_taxrate_1").hide();//税率不显示隐藏
		jQuery("#zd_taxamount").hide();//税额不显示隐藏
		jQuery("#zd_taxamount_1").hide();//税额不显示隐藏
		jQuery("#zd_notaxamount").hide();//金额（不含税）隐藏
		jQuery("#zd_notaxamount_1").hide();//金额（不含税）隐藏
		for(var i=0;i<contractdetail.length;i++){
			var rowIndex = contractdetail[i].value; //获取当前行的索引
	        jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().hide();
	        jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().hide();
			jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().hide();
		}
	}else{
		jQuery("#zd_taxrate").show();
		jQuery("#zd_taxrate_1").show();
		jQuery("#zd_taxamount").show();
		jQuery("#zd_taxamount_1").show();
		jQuery("#zd_notaxamount").show();
		jQuery("#zd_notaxamount_1").show();
		for(var i=0;i<contractdetail.length;i++){
			var rowIndex = contractdetail[i].value; //获取当前行的索引
			jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().show();
			jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().show();
			jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().show();
		}
	}
	//201800827 added by zuoxl for 控制明细行税率、税额、金额（不含税）字段显示与隐藏 end
}

//获取经办人手机号
function get_applytel(applyperson){
    var tel = '';
    var telephone = ''; //电话号
    var mobile = '';    //手机号
    jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"get_apply_tel","applyperson":applyperson} ,
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
              mobile = json.map.MOBILE;
              telephone = json.map.TELEPHONE;
          }else if(json.flag=='e'){
            alert(json.error_msg);
            return;
          }
        },
        error: function (){
          alert('error...');
        }
      });
    if( (telephone != null && telephone != '') && (mobile != null && mobile != '')){
        tel = telephone + '/' + mobile;
    }else if((telephone != null && telephone != '') && (mobile == null || mobile == '')){
        tel = telephone;
    }else if((telephone == null || telephone == '') && (mobile != null && mobile != '')){
        tel = mobile;
    }
    setCol(<%=mMap.get("tel")%>, tel, true, tel);
}
//明细行金额
function refreshmoney(){
    setCol(<%=mMap.get("huiyifei_currmony")%>,0,false,0); //会议费金额
    setCol(<%=mMap.get("applytotalmoney")%>,0,false,0); //报销总金额
    <%-- setCol(<%=mMap.get("reversaltotalmoney")%>,0,false,0); //冲销总金额 --%>
    setCol(<%=mMap.get("paytotalmoney")%>,0,false,0); //付款总金额
    var moneyline1 = 0; //明细行总金额
    var applytotalmoney = 0; // 头信息总金额
    var localmoney = 0; //本币金额
    var arrApplyLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrApplyLine.length; k++){
        var rowIndex = arrApplyLine[k].value;
        moneyline1 = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex);      //报销金额(含税)
        var exchangerate = jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex); // 获取汇率对象
        var taxrateline1 = jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex);  //税率
        var taxrateval = getFloat(gettaxprice(taxrateline1.val())) * 0.01; //获取税率值
        //报销明细行含税金额
        <%-- var taxmoneyval = (getFloat(moneyline1.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //计算报销明细行税额
        setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex,fmoney(taxmoneyval),false,fmoney(taxmoneyval)); //向页面回写税额 --%>
        //报销明细行不含税金额
       <%--  var currmoenyline1 = getFloat(moneyline1.val()) - getFloat(taxmoneyline.val()); // 计算报销行不含税金额
        setCol(<%=mMap1.get("money")%> + '_'+rowIndex,fmoney(currmoenyline1),false,fmoney(currmoenyline1)); //向页面回写不含税金额  --%>
        
        localmoney = getFloat(moneyline1.val()) * getFloat(exchangerate.val()); //计算本币金额
        setCol(<%=mMap1.get("localmoney")%> + '_'+ rowIndex,fmoney(localmoney),false,fmoney(localmoney)); // 回写本币金额
        
        applytotalmoney = getFloat(applytotalmoney) + getFloat(localmoney);  //计算头信息总金额
    }
    setCol(<%=mMap.get("applytotalmoney")%>,fmoney(applytotalmoney),false,fmoney(applytotalmoney)); //回写头信息总金额
    countPayTotalMoney();
}
//通用数值转换float型
function getFloat(val){
   if(val=='' || val == null){
       val = 0;
   }
   return parseFloat(val);
}
//获取税率值
function gettaxprice(taxratval){
    var data;
    jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"Get_taxrat","requestid":taxratval} ,  
        dataType : 'json',
        success: function (json){
             if(json.flag=='s'){
                 data = json.map.PERCENTAGE_RATE;
             }
        },
        error: function (){
           alert('Get_taxrat_error...');
        }
    });
    return data;
}

//加载补助及其他明细信息
function addRowinvoic(formId,rownum){
    var rowIndex = rownum;
    if(rownum == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum"+formId).value)-1; //获取当前行的索引       
    }
    if(rowIndex<0){
        return ;
    }
    if (formId == '9'){
        <%-- jQuery('#field' + <%=mMap10.get("invoicemoney")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap10.get("invoicemoney")%> + '_'+ rowIndex).bind('blur',function(){
            frestaxrate('9');           
        }); --%>
        jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex + '__').attr('readonly',true); //设置税率不可编辑
        jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
            jQuery(this).remove();
        });
        <%-- jQuery('#field' + <%=mMap10.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap10.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //税率 字段的onblur
            var taxrateval = jQuery('#field' + <%=mMap10.get("taxrate")%> + '_'+ rowIndex).val();
            if (taxrateval != null && taxrateval != ''){
                frestaxrate('9'); //金额计算
            }   
        }); --%>
        //20171219 added by ect jiajing start
        //绑定补助标准onblur事件
        jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).bind('change',function(){
        	var allowance = jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).val();
        	if(isNaN(allowance)){
        		alert('补助标准请输入数字');
        		return;
        	}
        });
        //20171219 added by ect jiajing end
    }else if(formId == '6'){//增值税专票信息
        jQuery('#field' + <%=mMap7.get("money")%> + '_'+ rowIndex).attr('readonly',true);// 税后金额只读
        
        //绑定发票金额
        jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).bind('change',function(){
            setCol(<%=mMap7.get("taxmoney")%> + '_' +rowIndex ,'',false,''); //清空税额
            setCol(<%=mMap7.get("money")%> + '_' +rowIndex ,'',false,'');    //清空不含税金额
            frestaxrate('6');          
        });
        //设置税率不可手动输入
        jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex + '__').attr('readonly',true); //设置税率不可编辑
        jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
            jQuery(this).remove();
        });
        <%-- //绑定税率
        jQuery('#field' + <%=mMap7.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap7.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //税率 字段的onblur
            var taxrateval = jQuery('#field' + <%=mMap7.get("taxrate")%> + '_'+ rowIndex).val();
            if (taxrateval != null && taxrateval != ''){
                frestaxrate('6'); //金额计算
            }   
        }); --%>
        //绑定增值税专票信息
        jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).bind('blur',function(){ //税率 字段的onblur
            var currmoneyval = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).val(); //发票金额
            var taxmoneyval = jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).val();  //税额
            if(getFloat(taxmoneyval) > getFloat(currmoneyval)){
                alert('增值税金额不能大于发票金额');
                return;
            }
            var money = getFloat(currmoneyval) - getFloat(taxmoneyval);
            setCol(<%=mMap7.get("money")%> + '_'+ rowIndex,fmoney(money),false,fmoney(money)); //重写税后金额              
        });
        
        //绑定发票类onchange事件
        jQuery('#field' + <%=mMap7.get("invoicetype")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("invoicetype")%> + '_'+ rowIndex).bind('change',function(){
            setCol(<%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex,'',false,''); //清空发票代码
            setCol(<%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex,'',false,''); //清空发票号码
        });
        //绑定发票号码onblur事件
        jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).bind('change',function(){
            var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).val();
            if(dinvoicenum.length != 8){
                alert('发票号码请输入8位数字');
                return;
            }
        });
      //绑定发票号码onblur事件
        jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex).bind('change',function(){
            var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //发票代码
            if(dinvoiceno.length != 10 && dinvoiceno.length != 12){
                alert('发票代码为10位或12位数字');
                return;
            }
        });
    }
    //20171219 added by ect jiajing start
    else if(formId == '8'){ //绑定住宿费明细信息  	
        //绑定补助标准onblur事件
        jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).bind('change',function(){
            var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).val();
            if(isNaN(expensestandard)){
                alert('住宿标准请输入数字');
                return;
            }
        });
    }
    //20171219 added by ect jiajing end
}
//补助及其他明细信息明细行金额计算
function frestaxrate(formId){
    //补助及其他明细信息
    var arrDetailLine = document.getElementsByName('check_node_'+formId);
       
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        if (formId == '9') {
            <%-- var moneyline10 = jQuery('#field'+<%=mMap10.get("invoicemoney")%> +'_'+rowIndex);  //发票金额obj
            var taxrateline10 = jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex);  //税率
            //税率
            var taxrateval = getFloat(gettaxprice(taxrateline10.val())) * 0.01; //获取税率值
           //报销明细行含税金额
           var taxmoneyval = (getFloat(moneyline10.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //计算报销明细行税额
            setCol(<%=mMap10.get("taxmoney")%> + '_' +rowIndex ,fmoney(taxmoneyval),false,fmoney(taxmoneyval)); --%>
        }else if(formId == '6'){
            var currmoneyline7 = jQuery('#field'+<%=mMap7.get("currmoney")%> +'_'+rowIndex); //发票金额Obj
            
            <%-- var taxrateline7 = jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex);  //税率
                    
            //税率
            var taxrateval = getFloat(gettaxprice(taxrateline7.val())) * 0.01; //获取税率值
            //报销明细行含税金额
            var taxmoneyval = (getFloat(currmoneyline7.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //计算报销明细行税额
            setCol(<%=mMap7.get("taxmoney")%> + '_' +rowIndex ,fmoney(taxmoneyval),false,fmoney(taxmoneyval));
            //计算不含税金额
            var moneyval = getFloat(currmoneyline7.val()) - getFloat(taxmoneyval);
            setCol(<%=mMap7.get("money")%> + '_' +rowIndex ,fmoney(moneyval),false,fmoney(moneyval)); --%>
        
        }
        
    }
}
//绑定发票类型onchange事件
<%-- function invoicetypechagne(){
    var invoicetype = jQuery('#field' + <%=mMap.get("invoicetype")%>);  //发票类型
    //绑定发票类型onchange事件
    invoicetype.removeAttr('onchange');      //移除onchange事件
    invoicetype.bind('change', function(){ //绑定onchange事件
        if(invoicetype.val() =='0'){
            jQuery("#tab_6").show();  // 隐藏增值税专票tab页
        }else{
            jQuery("#tab_6").hide();  // 显示增值税专票tab页
        }
        clearForm(6);
        jQuery("#tab_2").click();
    });
} --%>

//验证经办人手机号是否为空
function istelnull(){
    var returnflag = true;
    //经办人手机号部门为空
    var telphone = jQuery('#field' + <%=mMap.get("tel")%>);
    if (telphone.val() == '' || telphone.val() == null){
        returnflag = false;
    }
    return returnflag;
}
function isapplycompanynull(){
    var returnflag = true;
    var applycompany = jQuery('#field' + <%=mMap.get("applycompany")%>);//申请公司
    if(applycompany.val() == '' || applycompany.val() == null){
        returnflag = false;
    }
    return returnflag;
}

// 验证申请部门是否为空
function isdeptnull(){
    var returnflag = true;
    var arrDetailLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        //验证申请人部门
        var applydept = jQuery('#field' + <%=mMap1.get("applydept")%> + '_'+rowIndex);
        if (applydept.val() == '' || applydept == null){                
            returnflag = false;
        }
    }          
    return returnflag;
}

//金额校验
function totalmoneyCheck(){
    var returnflag = true;
    var carfare = 0;     //交通费
    var stayfare = 0;    //住宿费
    var invoicefare = 0; // 补助费用
    var totalmoney = 0;  //总金额
    var expensebill = jQuery('#field'+<%=mMap.get("expense_bill_type")%>).val();
    if(expensebill == '1'){
        var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val(); // 头信息总计
        //获取交通费
        var arrDetailLine8 = document.getElementsByName('check_node_7');
        if (arrDetailLine8.length > 0){
            for(var k = 0; k < arrDetailLine8.length; k++){
                var rowIndex = arrDetailLine8[k].value;
                var travelexpense = jQuery('#field' + <%=mMap8.get("travelexpense")%> + '_'+rowIndex);
                carfare = getFloat(carfare) + getFloat(travelexpense.val());
            }
        }
        //获取住宿费
        var arrDetailLine9 = document.getElementsByName('check_node_8');
        if (arrDetailLine9.length > 0){
            for(var k = 0; k < arrDetailLine9.length; k++){
                var rowIndex = arrDetailLine9[k].value;
                var hotelexpense = jQuery('#field' + <%=mMap9.get("hotelexpense")%> + '_'+rowIndex);
                stayfare = getFloat(stayfare) + getFloat(hotelexpense.val());
            }
        }
        //获取补助费用
        var arrDetailLine10 = document.getElementsByName('check_node_9');
        if (arrDetailLine10.length > 0){
            for(var k = 0; k < arrDetailLine10.length; k++){
                var rowIndex = arrDetailLine10[k].value;
                var invoicemoney = jQuery('#field' + <%=mMap10.get("invoicemoney")%> + '_'+rowIndex);
                invoicefare = getFloat(invoicefare) + getFloat(invoicemoney.val());
            }
        }
        totalmoney = getFloat(carfare) + getFloat(stayfare) + getFloat(invoicefare);
        if (getFloat(totalmoney).toFixed(2) != getFloat(applytotalmoney).toFixed(2)){
            returnflag = false;
        }
    }   
    return returnflag;
}
<%-- //报销单类型为差旅费报销时，费用明细只能选择带差旅字样的报销
function istravel(){
    var retrunflag = true;
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //报销单类型
    if(expensebill == '1'){ //报销单类型为差旅费报销单
        var arrDetailLine = document.getElementsByName('check_node_0');
        for(var k = 0; k < arrDetailLine.length; k++){
            var rowIndex = arrDetailLine[k].value;
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val(); // 费用明细
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + 'span').html();
            
            if (feetypeval.indexOf('差旅') == -1) {
                retrunflag = false;
            }
        }

    }
    return retrunflag;
}
//报销类型为业务招待费时，费用明细只能选择业务招待费或会议费
function isbusiness(){
    var retrunflag = true;
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //报销单类型
    if(expensebill == '2'){ //报销单类型为差旅费报销单
        var arrDetailLine = document.getElementsByName('check_node_0');
        for(var k = 0; k < arrDetailLine.length; k++){
            var rowIndex = arrDetailLine[k].value;
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val(); // 费用明细
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + 'span').html();
            
            if (feetypeval.indexOf('业务招待费') == -1 && feetypeval.indexOf('会议费') == -1) {
                retrunflag = false;
            }
        }

    }
    return retrunflag;
} --%>

<%-- //报销类型为差旅费报销时，交通费用信息，住宿费用信息，补助信息必须填写
function isNullcheck(){
    var retrunflag = true;
    var expensebill = jQuery('#field'+<%=mMap.get("expense_bill_type")%>).val();
    if(expensebill == '1'){
        var arrDetailLine8 = document.getElementsByName('check_node_7');
        if(!(arrDetailLine8.length > 0)){
             retrunflag = false;
        }
        var arrDetailLine9 = document.getElementsByName('check_node_8');
        if(!(arrDetailLine9.length > 0)){
            retrunflag = false;
        }
        var arrDetailLine10 = document.getElementsByName('check_node_9');
        if(!(arrDetailLine10.length > 0)){
            retrunflag = false;
        }
    }
    return retrunflag;
} --%>
//报销明细行税额不能大于报销金额
function taxmoneyCheck(){
    var retrunflag = true;
    var arrDetailLine1 = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine1.length; k++){
        var rowIndex = arrDetailLine1[k].value;
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //进项税文本
        var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();
        var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).val();  // 不含税金额
        if(account_segment.val() != '21710101'){
            if (getFloat(taxmoney) > getFloat(currmoeny)){
                retrunflag = false;
            }
        }  
    }
    return retrunflag;
}
//增值税发票明细行增值税税额能大于报销金额
function taxmoneyCheck7(){
    var retrunflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var currmoney = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+rowIndex).val();
        var taxmoney =  jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+rowIndex).val();
        if(getFloat(taxmoney) > getFloat(currmoney)){
            retrunflag = false;
        }
    }
    return retrunflag;
}
//验证报销行明细金额与发票行信息金额是否相等
<%-- function moneyEqualcheck(){
    var retrunflag = true;
    var currmoney = 0;//发票金额
    var totalcurrmoney = 0; //发票总金额
    var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();  //头信息总金额
    var arrDetailLine7 = document.getElementsByName('check_node_6');  //增指税专票信息
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        currmoney = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+rowIndex).val();
        totalcurrmoney = getFloat(totalcurrmoney) + getFloat(currmoney); //发票行总金额
    }
    
    //判断发票行总金额与头信息总金额是否相等
    if (getFloat(applytotalmoney) != getFloat(totalcurrmoney)){
        retrunflag = false;
    }
    return retrunflag;
} --%>

//获取核销占用金额
function isunpaidmoney(invoiceid){
      var invoiceno = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();  //发票号
      var applyperson = jQuery('#field' + <%=mMap.get("applyperson")%>).val(); //获取经办人id
      var occupymoney = 0;
      if(invoiceno == '' || invoiceno == nul){
            jQuery.ajax({
              url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
              type : "post",
              async : false,
              data :   {"action":"get_occupymoney","applyperson":applyperson,"invoiceid":invoiceid},  
              dataType : 'json',
              success: function (json){
                if(json.flag=='s'){
                    occupymoney = json.map.OCCUPYMONEY;
                }
              },
              error: function (){
                alert('error...');
              }
          }); 
      }else{
          occupymoney = 0;
      }
      return occupymoney;
}
//验证收款人明细是否填写
function PayeeIsinput(){
    var data = new Array();
    var returnflag = true;
    jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"checkpayeeIsNull","requestid":requestid} ,  
        dataType : 'json',
        success: function (json){
            if(json.flag=='s'){
                data = json.list;
            }
        },
        error: function (){
          alert('查询收款人明细id错误');
        }
    });
    if(data.length == 0){
        returnflag = false;
    }
    return returnflag;
}
//校验交通费明细行到达日期必须大于开始日期
function checkArrivaldate(){
    var returnflag = true;
     var arrDetailLine8 = document.getElementsByName('check_node_7');
     for(var k = 0; k < arrDetailLine8.length; k++){
         var rowIndex = arrDetailLine8[k].value;
         var startdate = jQuery('#field' + <%=mMap8.get("startdate")%> + '_'+rowIndex).val();     // 开始日期
         var arrivaldate = jQuery('#field' + <%=mMap8.get("arrivaldate")%> + '_'+rowIndex).val(); // 到达日期
         if(startdate > arrivaldate){
             returnflag = false;
         }
     }
     return returnflag;
}
//校验住宿信息明细行住宿入住日期部门大于离店日期
function checkOutdate(){
    var returnflag = true;
     var arrDetailLine9 = document.getElementsByName('check_node_8');
     for(var k = 0; k < arrDetailLine9.length; k++){
         var rowIndex = arrDetailLine9[k].value;
         var indate = jQuery('#field' + <%=mMap9.get("indate")%> + '_'+rowIndex).val();     // 入住日期
         var outdate = jQuery('#field' + <%=mMap9.get("outdate")%> + '_'+rowIndex).val(); // 离店日期      
         if(indate > outdate){
             returnflag = false;
         }
     }
     return returnflag;
}
//验证费用承担部门不能为空
function isdutydepartmentNull(){
    var returnflag = true;
    var arrDetailLine1 = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine1.length; k++){
        var rowIndex = arrDetailLine1[k].value;
        var dutydepartment = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+rowIndex).val();
        if(dutydepartment=='' || dutydepartment==null){
            returnflag = false;
        }
    }
    return returnflag;
}
//控制招待人数、招待级别是否显示
function setcolumshow(expensebill){
    var arrDetailLine1 = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine1.length; k++){
        var rowIndex = arrDetailLine1[k].value;
        if(expensebill.val() == '2'){
              jQuery("#person_num1").show();
              jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().show();
              jQuery("#person_num2").show();
              jQuery("#server_rank1").show();
              jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().show();
              jQuery("#server_rank2").show();           
          }else{      
              jQuery("#person_num1").hide();
              jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().hide();
              jQuery("#person_num2").hide();
              jQuery("#server_rank1").hide();
              jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().hide();
              jQuery("#server_rank2").hide();
          }
    }
}

function checkInvoiceNoExist(){//验证电子发票号是否已经存在
    var returnflag = true;
    var data = new Array();
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value; 
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //发票代码
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val(); //发票号码
        var dinvoicecode = dinvoiceno + dinvoicenum; //获取页面发票号
        data = getdinvoicenumber(dinvoiceno,dinvoicenum);
        if(data.length > 0){
            for(var i=0; i<data.length; i++){
                if(requestid != data[i].REQUESTID || requestid==-1){
                    if(dinvoicecode == data[i].DINVOICECODE){
                    	var applyPerson = getUserInfo(data[i].APPLYPERSON).map.LASTNAME;
                    	var workFlowCode = data[i].WORKFLOWCODE;
                        alert('第'+(getFloat(rowIndex)+1)+'行发票号已被使用：发票号码' + dinvoicenum+';发票代码'+dinvoiceno+ ';单据编号' + workFlowCode + ';人员姓名' + applyPerson);
                        returnflag = false;
                    }
                }
            }
        }
        
    }
    return returnflag;  
}
function checkInvoiceNoExist2(){ //验证发票号码和发票代码是否填写重复
    var returnflag = true;
    var data = new Array();
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //发票代码
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val(); //发票号码
        var dinvoicecode = dinvoiceno + dinvoicenum; //获取页面发票号
        for(var j = rowIndex;j<(arrDetailLine7.length-1);j++){
            var num = getFloat(j)+1;
            var dinvoicenoNum = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + num).val(); //发票代码
            var dinvoicenumNum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + num).val(); //发票号码
            var dinvoicecodeNum = dinvoicenoNum + dinvoicenumNum; //获取页面发票号
            if(dinvoicecode == dinvoicecodeNum){
                alert('发票明细行第'+(getFloat(rowIndex)+1)+'行与第'+(getFloat(num)+1)+'行发票号重复');
                returnflag = false;
            }
        }
    }
    return returnflag;
}
//校验报销报销明细行金额
function checkmoney1(){
    var returnflag = true;
    var arrDetailLine1 = document.getElementsByName('check_node_0');
	for(var k = 0; k < arrDetailLine1.length; k++){
		var rowIndex = arrDetailLine1[k].value;
		var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //进项税文本
		var currmoney = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val(); //含税金额
		var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).val(); //税额
		var money = jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).val().replace(',',''); //不含税金额
		var totalmoney = getFloat(taxmoney) + getFloat(money);
		if(account_segment.val() != '21710101'){
			if(getFloat(currmoney).toFixed(2) != getFloat(totalmoney).toFixed(2)){
				alert('报销明细第'+(getFloat(rowIndex)+1)+'行，税额或不含税金额计算不正确');
				returnflag = false;
			}
		}
	}
    return returnflag;
}
//校验发票明细行金额
function checkmoney7(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var currmoney = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_' + rowIndex).val(); //含税金额
        var taxmoney = jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_' + rowIndex).val(); //税额
        var money = jQuery('#field' + <%=mMap7.get("money")%> + '_' + rowIndex).val(); //不含税金额
        var totalmoney = getFloat(taxmoney) + getFloat(money);
        if(getFloat(currmoney).toFixed(2) != getFloat(totalmoney).toFixed(2)){
            alert('发票信息第'+(getFloat(rowIndex)+1)+'行，增值税金额或不含税金额计算不正确');
            returnflag = false;
        }
    }
    return returnflag;
}
//验证发票号码长度
function checkdinvoicelength(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val();  //发票号码
        if(dinvoicenum.length != 8){
            alert('第'+(getFloat(rowIndex)+1)+'行发票明细不正确，发票号码请输入8位数字');
            returnflag = false;
        }
    }
    return returnflag;
}
//验证发票代码长度
function checkdinvoicelength2(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //发票代码
        if(dinvoiceno.length != 10 && dinvoiceno.length != 12){
            alert('第'+(getFloat(rowIndex)+1)+'行发票明细不正确，发票代码为10位或12位数字');
            returnflag = false;
        }
    }
    return returnflag;
}
//设置进项税行明细不可编辑
function inputtaxhide(rowIndex){
<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
    // 20190614 added by sdaisino 进项税时金额显示问题解决start
    // 清空报销金额（含税）
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val('');
    // 20190614 added by sdaisino 进项税时金额显示问题解决end
    //设置项目非必填
    setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //税额必填
    setNeedCheck( <%=mMap1.get("currmoeny")%> + '_' + rowIndex,false); //含税金额非必填
    setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,false); //不含税金额非必填
    setNeedCheck_2( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //税率非必填
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,false); //币种非必填
    setNeedCheck( <%=mMap1.get("exchangerate")%> + '_' + rowIndex,false); //汇率非必填
    setNeedCheck( <%=mMap1.get("localmoney")%> + '_' + rowIndex,false); //本币金额非必填
    
  //20171226 added by ect mayue start
    var taxmoneyspan = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex+'span').html();
    jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex+'span').html(taxmoneyspan + '<img src="/images/BacoError_wev8.gif" align="absmiddle">'); //加上必填标识
  //20171226 added by ect mayue end
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //隐藏 报销金额必填标识
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //隐藏汇率必填 标识
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //隐藏本币金额必填 标识
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //隐藏不含税金额必填 标识 

    //设置项目隐藏
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).hide(); //隐藏含税金额 
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).hide(); //隐藏不含税金额   
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex+'span').hide(); //去掉必填标识
    //20180110 update by ect qiwf start
    //jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex +'_browserbtn').hide(); //隐藏税率browser
    //jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex +'_browserbtn').hide(); //隐藏币种browser 
    setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //税率不必填
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,false); //币种不必填
    //20180110 update by ect qiwf end    
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).hide(); //隐藏汇率 
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).hide(); //隐藏本币金额 
<%} %>
}
function inputtaxshow(rowIndex){
	//20171226 added by ect mayue start
	 var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
	 if(expensebill.val() == '2'){
		 setNeedCheck_2( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //税率非必填 
	 }else{
		 setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,true); //税率必填
	 }
	//20171226 added by ect mayue end
    //设置项目非必填
    setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //税额必填
    setNeedCheck( <%=mMap1.get("currmoeny")%> + '_' + rowIndex,true); //含税金额必填
    setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,true); //不含税金额必填
    <%-- setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,true); //税率非必填 --%>
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,true); //币种必填
    setNeedCheck( <%=mMap1.get("exchangerate")%> + '_' + rowIndex,true); //汇率必填
    setNeedCheck( <%=mMap1.get("localmoney")%> + '_' + rowIndex,true); //本币金额必填

    //设置项目隐藏
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).show(); //隐藏含税金额 
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).show(); //隐藏不含税金额   
    jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex +'_browserbtn').show(); //隐藏税率browser    
    jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex +'_browserbtn').show(); //隐藏币种browser    
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).show(); //隐藏汇率 
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).show(); //隐藏本币金额 
}
// 20171209 added by ect jiajing end
//20171219 added by ect jiajing start
//住宿标准是否为数字
function expensestandardcheck(){
    var returnflag = true;
    var arrDetailLine8 = document.getElementsByName('check_node_8');
    for(var k = 0; k < arrDetailLine8.length; k++){
        var rowIndex = arrDetailLine8[k].value;
        var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_' + rowIndex).val(); //住宿标准
        if(isNaN(expensestandard) && (expensestandard != '' || expensestandard != null)){
            alert('住宿费用信息，第'+(getFloat(rowIndex)+1)+'行住宿标准请输入数字');
            returnflag = false ;
        }
    }
    return returnflag;
}
//补助标准是否为数字
function allowancecheck(){
    var returnflag = true;
    var arrDetailLine9 = document.getElementsByName('check_node_9');
    for(var k = 0; k < arrDetailLine9.length; k++){
        var rowIndex = arrDetailLine9[k].value;
        var allowance = jQuery('#field' + <%=mMap10.get("allowance")%> + '_' + rowIndex).val(); //住宿标准
        if(isNaN(allowance) && (allowance != '' || allowance != null)){
            alert('补助、及其他费用信息，第'+(getFloat(rowIndex)+1)+'行补助标准请输入数字');
            returnflag = false ;
        }
    }
    return returnflag;
}
//20171226 added by ect mayue start
function checkReimbursementMoney(){ //验证报销总金额和报销行明细金额是否一致
    var returnflag = true;
    var totalmoney = 0;
    var data = new Array();
    var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();//总金额
    var arrDetailLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        var currency = jQuery('#field' + <%=mMap.get("currency")%>).val(); //币种
        var currency1 = jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex).val(); //币种
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_' + rowIndex).val();//科目段
        var localmoney = jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).val().replace(',','');//本币金额
        var money = jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).val().replace(',','');//不含税金额
        var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).val();//税额
        if(currency != currency1 && account_segment != '21710101'){
    	   totalmoney = getFloat(totalmoney) + getFloat(localmoney);
       }else if(account_segment == '21710101'){
    	   totalmoney = getFloat(totalmoney) + getFloat(taxmoney);
       }else{
		   totalmoney = getFloat(totalmoney) + getFloat(money);  
	   }
      /*  if(account_segment == '21710101'){
		   totalmoney = getFloat(totalmoney) + getFloat(taxmoney); 
	   }else{
		   totalmoney = getFloat(totalmoney) + getFloat(money);  
	   } */
    }
    
    if(applytotalmoney != getFloat(totalmoney).toFixed(2)){
    	returnflag = false;
    }
    return returnflag;
}
//20171226 added by ect mayue end
//20171219 added by ect jiajing end
//20180315 added by zuoxl for 事项申请（差旅报销单标准控制）
//获取交通工具标准
function getVehicleStandard(rowIndex){
	var hrlevel = jQuery('#field' + <%=mMap8.get("hrlevel")%> + '_'+rowIndex).val(); //人员级别
    var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//经办人公司
    var expensestandard = '';
    //根据人员级别获取交通工具标准
    jQuery.ajax({
	        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	        type : "post",
	        async : false,
	        data : {"action":"getVehicleStandard","hrlevel":hrlevel,"org_id":org_id} ,
	        dataType : 'json',
	        success: function (json){
	          if(json.flag=='s'){
	        	  vehiclestandard = json.map.VEHICLE;
				  if(vehiclestandard!=null&&vehiclestandard!=''){
		        	  setCol(<%=mMap8.get("vehiclestandard")%> + '_'+ rowIndex, vehiclestandard, true, getAisinoBrowserRef(<%=mMap8.get("vehiclestandard")%>,vehiclestandard));
				  }else{
					  setCol(<%=mMap8.get("vehiclestandard")%> + '_'+ rowIndex, '', true, '');
				  }       	  
	        	  
	          }else if(json.flag=='e'){
	            alert(json.error_msg);
	          }
	        },
	        error: function (){
	          alert('error...');
	        }
	        
	    });
}

//获取住宿标准
function getExpenseStandard(rowIndex){
        var hrlevel = jQuery('#field' + <%=mMap9.get("hrlevel")%> + '_'+rowIndex).val(); //人员级别
        var cityCategory = jQuery('#field' + <%=mMap9.get("citycategory")%> + '_'+rowIndex).val(); //城市类别
        var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//经办人公司
        var expensestandard = '';
        //根据人员级别获取交通工具标准
        jQuery.ajax({
	        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	        type : "post",
	        async : false,
	        data : {"action":"getExpenseStandard","hrlevel":hrlevel,"cityCategory":cityCategory,"org_id":org_id} ,
	        dataType : 'json',
	        success: function (json){
	          if(json.flag=='s'){
				  expensestandard = json.map.ACCOMDATE_LEVEL;
				  if(expensestandard!=null&&expensestandard!=''){
		        	  setCol(<%=mMap9.get("expensestandard")%> + '_'+ rowIndex, parseFloat(expensestandard), true, '');
				  }else{
					  setCol(<%=mMap9.get("expensestandard")%> + '_'+ rowIndex, parseFloat(0), true, '');
				  }
	        	  
	          }else if(json.flag=='e'){
	            alert(json.error_msg);
	          }
	        },
	        error: function (){
	          alert('error...');
	        }
	        
	    });
    
}

//获取补助标准
function getAllowanceStandard(rowIndex){
        var hrlevel = jQuery('#field' + <%=mMap10.get("hrlevel")%> + '_'+rowIndex).val(); //人员级别
        var transactiontype = jQuery('#field' + <%=mMap10.get("transactiontype")%> + '_'+rowIndex).val(); //城市类别
        var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//经办人公司
        var allowanceStandard = '';
		var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();//类别
		if(parseFloat(type) == 0){//20180919 added by ect haiyong 
        //根据人员级别获取交通工具标准
        jQuery.ajax({
	        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	        type : "post",
	        async : false,
	        data : {"action":"getAllowanceStandard","hrlevel":hrlevel,"transactiontype":transactiontype,"org_id":org_id} ,
	        dataType : 'json',
	        success: function (json){
	          if(json.flag=='s'){
		      	allowanceStandard = json.map.SUBSUDY_LEVEL;
		      	if(allowanceStandard!=null&&allowanceStandard!=''){
			      	setCol(<%=mMap10.get("allowance")%> + '_'+ rowIndex, parseFloat(allowanceStandard), true, '');
		      	}else{
		      		setCol(<%=mMap10.get("allowance")%> + '_'+ rowIndex, parseFloat(0), true, '');
		      	}
	          }else if(json.flag=='e'){
	            alert(json.error_msg);
	          }
	        },
	        error: function (){
	          alert('error...');
	        }
	        
	    });
		}else{
			setCol(<%=mMap10.get("allowance")%> + '_'+ rowIndex, parseFloat(0), true, '');//20180919 added by ect haiyong 
		}
    
}

//根据页面交通工具浏览按钮获取对应工具sort值
function getVehicleSort(vehicle){
	var sort = '0';
    jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"getVehicleSort","vehicle":vehicle} ,
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
        	  sort = json.map.SORT;
        	  return sort;
          }else if(json.flag=='e'){
            alert(json.error_msg);
          }
        },
        error: function (){
          alert('error...');
        }
    });
    return sort;
}

//明细行添加控制
function addRowControl(formId,rownum){
	
	var rowIndex = rownum;
    if(rownum == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum"+formId).value)-1; //获取当前行的索引       
    }
    if(rowIndex<0){
        return ;
    }
	//交通明细行
	if(formId=='7'){
		//设置交通行是否超标为只读
		jQuery('#field' + <%=mMap8.get("isstandard")%>+ '_'+rowIndex).attr('readOnly',true);
		//设置交通行 交通工具标准为“其他工具”时备注为必填
		var vehiclevalue = jQuery('#field' + <%=mMap8.get("vehiclevalue")%> + '_' + rowIndex);
		vehiclevalue.removeAttr('onchange');
		vehiclevalue.bind('change',function(){
			var vehicle = jQuery('#field' + <%=mMap8.get("vehicle")%> + '_' + rowIndex);
			if('othervehicles' == vehicle.val()){
				setNeedCheck_cc(<%=mMap8.get("memo")%> + '_'+rowIndex,true);
			}else{
				setNeedCheck_cc(<%=mMap8.get("memo")%> + '_'+rowIndex,false);
			}
		});
		var staff = jQuery('#field' + <%=mMap8.get("staffvalue")%> + '_' + rowIndex);
		staff.removeAttr('onchange');
		staff.bind('change',function(){
			checkHrlevel('7',rowIndex);
		});
		var hrlevel = jQuery('#field' + <%=mMap8.get("hrlevelvalue")%> + '_' + rowIndex);
		hrlevel.removeAttr('onchange');
		hrlevel.bind('change',function(){
			getVehicleStandard(rowIndex);
		});
	}
	//住宿明细行
	if(formId=='8'){
		//设置住宿标准为只读
		jQuery('#field' + <%=mMap9.get("expensestandard")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//设置住宿标准总额为只读
		jQuery('#field' + <%=mMap9.get("expensetotalstandard")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//设置住宿行是否超标为只读
		jQuery('#field' + <%=mMap9.get("isstandard")%>+ '_'+rowIndex + '').attr('readOnly',true);
		var staff = jQuery('#field' + <%=mMap9.get("staffvalue")%> + '_' + rowIndex);
		staff.removeAttr('onchange');
		staff.bind('change',function(){
			getExpenseStandard(rowIndex);
			checkHrlevel('8',rowIndex);
		});
		
		var cityCategory = jQuery('#field' + <%=mMap9.get("citycategory_val")%> + '_'+rowIndex);
		cityCategory.removeAttr('onchange');
		cityCategory.bind('change',function(){
			getExpenseStandard(rowIndex);
		});
		var time = jQuery('#field' + <%=mMap9.get("days")%> + '_'+rowIndex);
		time.removeAttr('onchange');
		time.bind('change',function(){
			var day = jQuery('#field' + <%=mMap9.get("days")%> + '_'+rowIndex).val();
			var standard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+rowIndex).val();
			var totalStandard = countStandardMoney(day,standard);
			setCol(<%=mMap9.get("expensetotalstandard")%> + '_'+ rowIndex, parseFloat(totalStandard), true, '');
		});
		var expense = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+rowIndex);
		expense.removeAttr('onchange');
		expense.bind('change',function(){
			var day = jQuery('#field' + <%=mMap9.get("days")%> + '_'+rowIndex).val();
			var standard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+rowIndex).val();
			var totalStandard = countStandardMoney(day,standard);
			setCol(<%=mMap9.get("expensetotalstandard")%> + '_'+ rowIndex, parseFloat(totalStandard), true, '');
		});
	}
	//补助行
	if(formId=='9'){
		//设置补助标准为只读
		jQuery('#field' + <%=mMap10.get("allowance")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//设置补助标准总额为只读
		jQuery('#field' + <%=mMap10.get("allowancetotal")%> + '_'+rowIndex + '').attr('readOnly',true);
		//设置补助标准总额为只读
		jQuery('#field' + <%=mMap10.get("isstandard")%> + '_'+rowIndex + '').attr('readOnly',true);
		var staff = jQuery('#field' + <%=mMap10.get("staffvalue")%> + '_' + rowIndex);
		staff.removeAttr('onchange');
		staff.bind('change',function(){
			getAllowanceStandard(rowIndex);
			checkHrlevel('9',rowIndex);
		});
		
		var transactiontype = jQuery('#field' + <%=mMap10.get("transactiontype_val")%> + '_'+rowIndex);
		transactiontype.removeAttr('onchange');
		transactiontype.bind('change',function(){
			getAllowanceStandard(rowIndex);
		});
		var time = jQuery('#field' + <%=mMap10.get("tripdays")%> + '_'+rowIndex);
		time.removeAttr('onchange');
		time.bind('change',function(){
			var day = jQuery('#field' + <%=mMap10.get("tripdays")%> + '_'+rowIndex).val();
			var standard = jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+rowIndex).val();
			var totalStandard = countStandardMoney(day,standard);
			setCol(<%=mMap10.get("allowancetotal")%> + '_'+ rowIndex, parseFloat(totalStandard), true, '');
		});
		var allowance = jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+rowIndex);
		allowance.removeAttr('onchange');
		allowance.bind('change',function(){
			var day = jQuery('#field' + <%=mMap10.get("tripdays")%> + '_'+rowIndex).val();
			var standard = jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+rowIndex).val();
			var totalStandard = countStandardMoney(day,standard);
			setCol(<%=mMap10.get("allowancetotal")%> + '_'+ rowIndex, parseFloat(totalStandard), true, '');
		});
		//20180919 added by haiyong  for 绑定类别onchange事件 start
		var type = jQuery('#field' + <%=mMap10.get("type")%> + '_'+rowIndex);
		type.removeAttr('onchange');
		type.bind('change',function(){
			if(parseFloat(type.val())==0){
				getAllowanceStandard(rowIndex);
			}else{
				setCol(<%=mMap10.get("allowance")%> + '_'+ rowIndex, parseFloat(0), false,'');
			}
		});
		//20180919 added by haiyong  for 绑定类别onchange事件 end
	}
}



//根据天数和标准金额 计算总金额标准
function countStandardMoney(day,standard){
	var totalStandard = parseFloat(day)*parseFloat(standard);
	return totalStandard;
}
//根据报销单类型隐藏出差申请单号
function setTripApplyCode(expensebill){
	if(expensebill.val()==1||expensebill.val()==2){
    	jQuery("#tripapplycode").show();
    	
    }else{
    	jQuery("#tripapplycode").hide();
    	setCol(<%=mMap.get("tripapplycode")%>, '', true, '');
    }
}

//校验人员职级是否存在
function checkHrlevel(formId,rowIndex){
	var staff ='';
	if(formId=='7'){
		staff = jQuery('#field' + <%=mMap8.get("staffvalue")%> + '_' + rowIndex).val();
	}
	if(formId=='8'){
		staff = jQuery('#field' + <%=mMap9.get("staffvalue")%> + '_' + rowIndex).val();
	}
	if(formId=='9'){
		staff = jQuery('#field' + <%=mMap10.get("staffvalue")%> + '_' + rowIndex).val();
	}
	var hrlevel ='';
	jQuery.ajax({
        url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
        type : "post",
        async : false,
        data : {"action":"checkHrlevel","staff":staff},
        dataType : 'json',
        success: function (json){
          if(json.flag=='s'){
        	  hrlevel = json.map.HRLEVEL;
        	  if(hrlevel==''){
        		  alert("请维护人员职级信息后再填单！");
        	  }
          }else if(json.flag=='e'){
            alert(json.error_msg);
          }
        },
        error: function (){
          alert('error...');
        }
    });
}

//提交前验证交通标准
function checkAllVehicle(){
	var flag = '-1';
    var detailLine8 = document.getElementsByName('check_node_7');
    for(var i = 0;i < detailLine8.length;i++){
    	var rowIndex = detailLine8[i].value; //获取当前行的索引
    	var vehicleStandard = jQuery('#field' + <%=mMap8.get("vehiclestandard")%>+ "_" + rowIndex).val();
    	var vehicle = jQuery('#field' + <%=mMap8.get("vehicle")%>+ "_" + rowIndex).val();
    	var vehicleStandardSort = getVehicleSort(vehicleStandard);
    	var vehicleSort = getVehicleSort(vehicle);
    	if(parseFloat(vehicleStandardSort )<parseFloat(vehicleSort)){
  	  		setCol(<%=mMap8.get("isstandard")%> + "_" + rowIndex, "超标", false, "超标");
  	  		var lineno = parseFloat(i)+1;
  	  		if(!confirm("第" + lineno +"行交通费用标准超标，是否提交？")){
  	  			flag = i+1;
  	  			return;
  	  		}
    	}else{
    		setCol(<%=mMap8.get("isstandard")%> + "_" + rowIndex, "正常", false, "正常");
    	}
    }
    return flag;
}
//提交前验证住宿标准
function checkAllExpense(){
	var flag = '-1';
    var detailLine9 = document.getElementsByName('check_node_8');
    for(var i = 0;i < detailLine9.length;i++){
    	var rowIndex = detailLine9[i].value; //获取当前行的索引    	
    	var accomdateStandard = jQuery('#field' + <%=mMap9.get("expensetotalstandard")%>+ "_" + rowIndex).val();
    	var accomdate = jQuery('#field' + <%=mMap9.get("hotelexpense")%>+ "_" + rowIndex).val();
    	if(parseFloat(accomdateStandard)<parseFloat(accomdate)){
  	  		setCol(<%=mMap9.get("isstandard")%> + "_" + rowIndex, "超标", false, "超标");
  	  		var lineno = parseFloat(i)+1;
  	  		if(!confirm("第" + lineno +"行住宿费用标准超标，是否提交？")){
  	  			flag = i+1;
  	  			return;
  	  		}
    	}else{
    		setCol(<%=mMap9.get("isstandard")%> + "_" + rowIndex, "正常", false, "正常");
    	}
    }
    return flag;
}

//提交前验证补助标准
function checkAllAllowance(){
	var flag = '-1';
    var detailLine10 = document.getElementsByName('check_node_9');
    for(var i = 0;i < detailLine10.length;i++){
    	var rowIndex = detailLine10[i].value; //获取当前行的索引
		var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();
		if(parseFloat(type) == 0){//20180919 added by ect haiyong 选择其他费用显示为超标
			var allowanceStandard = jQuery('#field' + <%=mMap10.get("allowancetotal")%>+ "_" + rowIndex).val();
			var allowance = jQuery('#field' + <%=mMap10.get("invoicemoney")%>+ "_" + rowIndex).val();
			if(parseFloat(allowanceStandard)<parseFloat(allowance)){
				setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "超标", false, "超标");
				var lineno = parseFloat(i)+1;
				if(!confirm("第" + lineno +"行补助费用标准超标，是否提交？")){
					flag = i+1;
					return;
				}
			}else{
				setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "正常", false, "正常");
			}
		}else{
			setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "正常", false, "正常");
		}
	}
		return flag;
}
//提交前验证交通行人员级别
function checkVehicleHrlevel(){
	var flag = -1;
	var detailLine8 = document.getElementsByName('check_node_7');
    for(var i = 0;i < detailLine8.length;i++){
    	var rowIndex = detailLine8[i].value; //获取当前行的索引
    	var hrlevel = jQuery('#field' + <%=mMap8.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//提交前验证住宿行人员级别
function checkExpenseHrlevel(){
	var flag = -1;
	var detailLine9 = document.getElementsByName('check_node_8');
    for(var i = 0;i < detailLine9.length;i++){
    	var rowIndex = detailLine9[i].value; //获取当前行的索引
    	var hrlevel = jQuery('#field' + <%=mMap9.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//提交前验证补助行人员级别
function checkAllowanceHrlevel(){
	var flag = -1;
	var detailLine10 = document.getElementsByName('check_node_9');
    for(var i = 0;i < detailLine10.length;i++){
    	var rowIndex = detailLine10[i].value; //获取当前行的索引
    	var hrlevel = jQuery('#field' + <%=mMap10.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//提交前校验交通工具标准是否为空
function checkVehicleStandard(){
		var flag = -1;
		var detailLine8 = document.getElementsByName('check_node_7');
	    for(var i = 0;i < detailLine8.length;i++){
	    	var rowIndex = detailLine8[i].value; //获取当前行的索引
	    	var vehiclestandard = jQuery('#field' + <%=mMap8.get("vehiclestandard")%>+ "_" + rowIndex).val();
	    	if(vehiclestandard == 0){
	    		flag = i+1;
	    		return;
	    	}
	    }
	    return flag;
}
//提交前校验住宿费用标准是否为空
function checkExpenseStandard(){
		var flag = -1;
		var detailLine9 = document.getElementsByName('check_node_8');
	    for(var i = 0;i < detailLine9.length;i++){
	    	var rowIndex = detailLine9[i].value; //获取当前行的索引
	    	var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%>+ "_" + rowIndex).val();
	    	if(expensestandard == 0){
	    		flag = i+1;
	    		return;
	    	}
	    }
	    return flag;
}
//提交前校验补助费用标准是否为空
function checkAllowanceStandard(){
		var flag = -1;
		var detailLine10 = document.getElementsByName('check_node_9');
	    for(var i = 0;i < detailLine10.length;i++){
	    	var rowIndex = detailLine10[i].value; //获取当前行的索引
	    	var allowance = jQuery('#field' + <%=mMap10.get("allowance")%>+ "_" + rowIndex).val();
			var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();
			if(parseFloat(type) == 0){//20180919 added by ect haiyong 选择其他费用补助标准为0
				if(allowance == 0){
					flag = i+1;
					return;
				}
			}
	    }
	    return flag;
}
//20180315 added by zuoxl for 事项申请（差旅报销单标准控制）  end
//20180329 added by mengly for 事项申请单链接 begin
function openItemBill(){
	item_bill_requestid = jQuery('#field' + <%=mMap.get("tripapplybill")%>).val();
	var bill_mainid = get_applybill_mainid(item_bill_requestid);
	var expense_bill_type = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val();
	if(expense_bill_type==1){
		window.open('/interface/aisino/com/cn/jsp/acc_exp_ccsq_show.jsp?requestid=' + item_bill_requestid +'&mainid='+bill_mainid);
	}else if(expense_bill_type==2){
		window.open('/interface/aisino/com/cn/jsp/acc_exp_ywzd_show.jsp?requestid=' + item_bill_requestid +'&mainid='+bill_mainid);
	}
}
//20180329 added by mengly for 事项申请单链接 end

//20180404 added by zuoxl 设置文本框必填或非必填   boole为true，设为必填；boole为false，设为非必填，不清空值；
function setNeedCheck_cc(fieldid_no,boole){
  var field_c = 'field' + fieldid_no;
  var textValue = "<IMG align=absMiddle src='/images/BacoError_wev8.gif' />" ;
  btzd = jQuery("input[name='needcheck']").val();
  var fieldIds = "" ;
  if(boole == true){
    //添加必填
    jQuery("#"+field_c+ "span").html(textValue);
    jQuery("#"+field_c).attr('viewtype','1');
    //必填字段id
    fieldIds = btzd + "," + field_c ;
    jQuery( "input[name='needcheck']").val(fieldIds);
  }else{
    //取消必填
    jQuery("#"+field_c+"span" ).html('');
    //必填字段id
    fieldIds = btzd.replace(new RegExp(("," + field_c),"gm"), "") ;
    jQuery( "input[name='needcheck']").val(fieldIds);
  }
}
//20180514 added by zuoxl for 提交前校验付款总金额 若为空，则删除收款人明细  begin
function checkPayShareB4Submit(){
	var org_id = jQuery('#field' + <%=mMap.get("applycompany")%>).val();
	var requestid_c = jQuery('#field' + <%=mMap.get("requestid_c")%>).val();
	var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	if(paytotalmoney==0){
		delete_p_header_dt1(requestid_c,org_id);//删除收款人明细表
		delete_p_header(requestid_c,org_id);//删除收款人明细头表
		update_requestid_c(requestid_c);//删除主表中收款人明细标识
	}
	
}
//删除收款人明细头表
function delete_p_header(requestid_c,org_id){
	jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"delete_p_header","requestid_c":requestid_c,"org_id":org_id} ,  
	      dataType : 'json',
	      success: function (json){
	          data = json.list;
	      },
	      error: function (){
	        alert('删除收款人明细头表错误');
	      }
	    });
}
//删除收款人明细明细行表
function delete_p_header_dt1(requestid_c,org_id){
	jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"delete_p_header_dt1","requestid_c":requestid_c,"org_id":org_id} ,  
	      dataType : 'json',
	      success: function (json){
	          data = json.list;
	      },
	      error: function (){
	        alert('删除收款人明细明细行表错误');
	      }
	    });
}
//删除主表中关于收款人明细标识
function update_requestid_c(requestid_c){
	jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"update_requestid_c","requestid_c":requestid_c} ,  
	      dataType : 'json',
	      success: function (json){
	          data = json.list;
	      },
	      error: function (){
	        alert('删除主表中关于收款人明细标识错误');
	      }
	    });
}
//20180514 added by zuoxl for 提交前校验付款总金额 若为空，则删除收款人明细  end
//20180601 added by lixw for 刷新发票按钮 start
/**
 * 刷新发票信息
 */
function flushInvoice() {
	if(requestid == -1){
        alert('请先保存后，在进行刷新发票明细');
        return false;
    }
	var data = "";
	// 查询是否编辑过发票明细
     jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"checkInvoice","requestid":requestid} ,  
	      dataType : 'json',
	      success: function (json){
	          data = json.list;
	      },
	      error: function (){
	        alert('刷新发票错误');
	      }
	    });
	  if(data.length > 0){
		  var billid = data[0].ID;
		// 编辑
	     window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=0&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  // 监控
	   // window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=3&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  }else{
		// 新增
		 window.open('/formmode/view/AddFormMode.jsp?modeId=2061&formId=-68&type=1&layoutid=2564&requestid=' + requestid + '&source=2');
	  }
	
}

/**
 * 刷新发票信息
 */
function flushInvoices() {
	if(requestid == -1){
        alert('请先保存后，在进行刷新发票明细');
        return false;
    }
	var data = "";
	// 查询是否编辑过发票明细
     jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_f.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"checkInvoice","requestid":requestid} ,  
	      dataType : 'json',
	      success: function (json){
	          data = json.list;
	      },
	      error: function (){
	        alert('刷新发票错误');
	      }
	    });
	  if(data.length > 0){
		  var billid = data[0].ID;
	  // 监控
	   window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=3&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  }else{
		//无发票
	   alert('无发票信息');
	  }
	
}
//20180601 added by lixw for 刷新发票按钮 end
function get_applybill_mainid(item_bill_requestid){
	var applybill_mainid = '';	
	jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"get_applybill_mainid","requestid":item_bill_requestid} ,  
	      dataType : 'json',
	      success: function (json){
	    	  applybill_mainid = json.map.APPLYBILL_MAINID;
	      },
	      error: function (){
	        alert('获取事项申请单mainid错误');
	      }
	    });
	return applybill_mainid;
}
//20180530 added by ect lijian for 查询组织单位上线情况 start
//查询组织单位事项上线情况
function check_company_sys_status(org_id){
	var status = '-1';
	jQuery.ajax({
    url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
    type : "post",
    async : false,
    data : {"action":"getapplicationF","orgid":org_id} ,  
    dataType : 'json',
    success: function (json){
    	if(json.flag=='s'){
            data = json.list;
            if(data.length>0){
            	status = data[0].APPLICATION_MATTERS;
            }
        }
    },
    error: function (){
      alert('查询组织单位事项上线情况错误');
    }
  });
	return status;
}
//20180530 added by ect lijian for 查询组织单位上线情况 end
//20180827 added by zuoxl for 检查发票明细行是否填写   begin
function checkInvoiceStatus(requestid){
	var data = '';
	jQuery.ajax({
		url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
		type : "post",
		async : false,
		data : {"action":"checkinvoicestatus","requestid":requestid} ,  
		dataType : 'json',
		success: function (json){
			data = json.list;
		},
		error: function (){
		  alert('获取发票信息错误');
		}
	});
	if(data.length < 1){
		//20181105 modifie by zuoxl for 提交前校验进项税时是否填写发票明细  -------begin
		/*
		20190411 deleted by ect-zuoxl for 删除进项税，发票必填校验
		if(!checkInputtaxExsit()&&orgid.val()=='81'){
			alert('报销明细行存在进项税额，发票明细不能为空，请检查！');
			return false;
		}else{ */
		        //20190218 added by sdaisino  for 生成进项税行  begin
		        if(!checkInputtaxExsit() && orgid.val()=='81'){
		            alert('有进项税行，没有进项税发票!');
		            return false;
	                }
			//20190218 added by sdaisino for 生成进项税行  end
			if(confirm('发票信息未填写，是否提交单据？')){
				return true;
			}else{
				return false;
			}
		//}
		//20181105 modified by zuoxl for 提交前校验进项税时是否填写发票明细  -------begin
		//20190218 added by sdaisino  for 生成进项税行  begin
        } else {
            if(checkInputtaxExsit() && orgid.val()=='81'){
		        alert('有进项税发票，没有进项税行!');
		        return false;
	        }
        }
        //20190218 added by sdaisino for 生成进项税行  end
	return true;
}
//20180827 added by zuoxl for 检查发票明细行是否填写   end
function countywzdDetailMoney(){
	var expensebill2 = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //报销单类型
	if(expensebill2.val() == 2){
		var detailLine0 = document.getElementsByName('check_node_0');
		for(var i = 0;i < detailLine0.length;i++){
			var rowIndex = detailLine0[i].value; //获取当前行的索引
			var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%>+ "_" + rowIndex).val();
			setCol(<%=mMap1.get("taxmoney")%>+ "_" + rowIndex, 0, true , 0);
			setCol(<%=mMap1.get("money")%> + "_" + rowIndex, parseFloat(currmoeny), true, parseFloat(currmoeny));
		}
	}
	return true;
}
//20181015 added by zuoxl for 上线支付通单位提交前校验支付方式/收款人明细
//获取单位支付通上线状况
function checkQposStatus(org_id){
	var status = '';
	jQuery.ajax({
	      url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
	      type : "post",
	      async : false,
	      data : {"action":"checkQposStatus","org_id":org_id},  
	      dataType : 'json',
	      success: function (json){
	    	  status = json.map.IS_QPOSSTATUS;
	      },
	      error: function (){
	        alert('获取支付通上线状态错误');
	      }
	});
	if("1"==status){
		return true;
	}else{
		return false;
	}
}
//校验支付方式是否为银企直连
function checkPayway(){
	var payway = jQuery('#field' + <%=mMap.get("payway")%>).val();
	if('HEB_PAYMENT'==payway){
		return true;
	}else{
		return false;
	}
}
//校验收款明细信息是否齐全
function checkReciptinfo(){
	var rtnFlag = true;
	var requestid_c = jQuery('#field' + <%=mMap.get("requestid_c")%>).val();
	var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	if(paytotalmoney>0){
		jQuery.ajax({
			url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
			type : "post",
			async : false,
			data : {"action":"get_reciptinfo","requestid_c":requestid_c} ,  
			dataType : 'json',
			success: function (json){
			    data = json.list;
			},
			error: function (){
			  alert('获取收款人明细信息错误');
			}
		});
	}
	for(var i =0;i<data.length;i++){
		if(data[i].BANK==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"银行大类"为空,联系运维人员维护！');
		}
		if(data[i].RCVACCNO==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"收款人账号"为空！联系运维人员维护！');
		}
		if(data[i].RCVBANKFULLNAME==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"收款银行全称"为空！联系运维人员维护！');
		}
		if(data[i].RCVACCNAME==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"收款户名"为空！联系运维人员维护！');
		}
		if(data[i].UNIONBANKNUMBER==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"联行号"为空！联系运维人员维护！');
		}
		if(data[i].PAYCITY==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-收款信息"收款城市"为空！联系运维人员维护！');
		}
	}
	return rtnFlag;
}	
//20181105 added by zuoxl for 检查报销明细行是否填写进项税额  -------begin
function checkInputtaxExsit(){
	var flag = true;
	//20190218 added by sdaisino  for 生成进项税行  begin
	var detailLine0 = document.getElementsByName('check_node_0');
	for(var i = 0;i < detailLine0.length;i++){
		var rowIndex = detailLine0[i].value;
		var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //进项税文本
		if(account_segment.val() == '21710101'){
			flag = false;
		}
	}
	//20190218 added by sdaisino for 生成进项税行  end
	return flag;
}
//20181105 added by zuoxl for 检查报销明细行是否填写进项税额  -------begin
//20190507 add by raoanyu for 税改计算税额
function getTaxmoney(){
	var expensebilltype = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //报销单类型
	if(expensebilltype=='1'){ 
	var arrDetailLine1 = document.getElementsByName('check_node_0');
		for(var k = 0; k < arrDetailLine1.length; k++){
			var rowIndex = arrDetailLine1[k].value;		
			var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();//报销金额
			var taxmoney = '';//税额
			var taxrateid= jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex).val();;//税率
			var taxratename=getAisinoBrowserRef(<%=mMap1.get("taxrate")%>,taxrateid);
			var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val();//费用明细
			var feetypename = getAisinoBrowserRef(<%=mMap1.get("feetype")%>,feetypeval);
				 jQuery.ajax({
					    url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
					    type : "post",
					    async : false,
					    data : {"action":"get_taxrate_ebs","feetypeval":feetypeval} ,
					    dataType : 'json',
					    success: function (json){
					      if(json.flag=='s'){
					    	 var taxrate=json.map.PERCENTAGE_RATE;
					    	 var taxratecode=json.map.TAX_RATE_CODE;
					    	  if(taxrate!='-1'&&taxratecode==taxratename){
					    		 var taxrate1 = taxrate * 0.01;
					 			 taxmoney=getFloat(currmoeny/(1+taxrate1)*taxrate1).toFixed(2);
					 			 setCol(<%=mMap1.get("taxmoney")%> + '_' + rowIndex, taxmoney, false, taxmoney);
					 			 var currmoenyline2 = getFloat(currmoeny) - getFloat(taxmoney);
					 		     setCol(<%=mMap1.get("money")%> + '_'+ rowIndex,fmoney(currmoenyline2),false,fmoney(currmoenyline2)); 
					 	        }
					      }else if(json.flag=='e'){
					        alert(json.error_msg);
					        return;
					      }
					    },
					    error: function (){
					      alert('error...');
					    }
					  }); 			 		 
		}
	}
}	
//20190218 added by sdaisino  for 生成进项税行  begin
function getTaxDetail() {
	var detailLine0 = document.getElementsByName('check_node_0');
    for(var i = 0;i < detailLine0.length;i++){
        var rowIndex = detailLine0[i].value;
        // 进项税文本
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> +'_'+ rowIndex); 
        if(account_segment.val() == '21710101'){
            alert("请删除已有税行后,再次自动生成税行!");
            return;
        }
    }
	var feetemplate = jQuery('#field' + <%=mMap.get("feetemplate")%>).val();
	jQuery.ajax({
			url : "/interface/aisino/com/cn/jsp/personal_expense_ty.jsp",
			type : "post",
			async : false,
			data : {"action":"getTaxDetail","requestid":requestid,"orgid":orgid.val(),"feetemplate":feetemplate} ,  
			dataType : 'json',
			success: function (json){
			    var list = json.list;
			    if (list.length > 0) {
			        jxsFlg = true;
			    	for (var i=0; i < list.length; i++) {
			    	    addRow0(0);
			    	    addRowDetail0('0','no');
			    		var index = 1 * parseInt(document.getElementById("indexnum" + '0').value)-1;
			    		if (JSON.stringify(json.map)!='{}') {
			    		    // 进项税
			    		    setCol(<%=mMap1.get("feetype")%> + '_' + index,json.map.REQUESTID,true,json.map.EXPENSE_ITEM);
			    		    // 税额
				    		setCol(<%=mMap1.get("taxmoney")%> + '_' + index,list[i].TAXMONEY,false,'');
				    		// 说明
				    		//setCol(<%=mMap1.get("feeinstruction")%> + '_' + index,list[i].TAXPAYER_NUMBER,true,'');
				    		// 汇率
				    		setCol(<%=mMap1.get("exchangerate")%> + '_' + index,'', true,'');
				    		// 附件张数
				    		setCol(<%=mMap1.get("invoicecount")%> + '_' + index, 0, true,'');
			    		} //else {
			    		//	setCol(<%=mMap1.get("feetype")%> + '_' + index,'34569',true,'进项税额');
			    		//}
			    		
			    	}
			    } else {
			    	alert("无进项税行！");
			    }
			},
			error: function (){
			  alert('生成进项税行错误');
			}
		});
		segmentTaxAdd();
}
//20190218 added by sdaisino for 生成进项税行  end
</SCRIPT>

