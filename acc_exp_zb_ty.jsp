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
	int formid = Util.getIntValue(request.getParameter("formid"), 0);//��id
	int isbill = Util.getIntValue(request.getParameter("isbill"), 0);//�����ͣ�1���ݣ�0��
	int nodeid = Util.getIntValue(request.getParameter("nodeid"), 0);//�����ͣ�1���ݣ�0��
	rs.execute("select nownodeid from workflow_nownode where requestid=" + requestid);
	rs.next();
	int nownodeid = Util.getIntValue(rs.getString("nownodeid"), nodeid);
	rs.execute("select nodeid from workflow_flownode where nodetype=0 and workflowid=" + workflowid);
	rs.next();
	int onodeid = Util.getIntValue(rs.getString("nodeid"), 0);
	BillFieldUtilOfContract butil = new BillFieldUtilOfContract();
	Map mMap = butil.getFieldId(formid, "0");

	Map mMap1 = new HashMap();//��ϸ�� 1
	//mMap1 = BillFieldUtil.getFieldId(formid, "1", "uf_exp_acc_header");//��ϸ��1
	mMap1 = BillFieldUtilOfContract.getFieldId(formid, "1");//��ϸ��1

	Map mMap2 = new HashMap();//��ϸ��2
	mMap2 = BillFieldUtilOfContract.getFieldId(formid, "2");//��ϸ��2

	Map mMap3 = new HashMap();//��ϸ��3
	mMap3 = BillFieldUtilOfContract.getFieldId(formid, "3");//��ϸ��3
	
	Map mMap7 = new HashMap();//��ϸ��7
    mMap7 = BillFieldUtilOfContract.getFieldId(formid, "7");//��ϸ��7����ֵ˰רƱ��Ϣ
    
    Map mMap8 = new HashMap();//��ϸ��8
    mMap8 = BillFieldUtilOfContract.getFieldId(formid, "8");//��ϸ��8����ͨ������Ϣ
    
    Map mMap9 = new HashMap();//��ϸ��9
    mMap9 = BillFieldUtilOfContract.getFieldId(formid, "9");//��ϸ��9��ס�޷�����Ϣ
    
    Map mMap10 = new HashMap();//��ϸ��10
    mMap10 = BillFieldUtilOfContract.getFieldId(formid, "10");//��ϸ��10������������������Ϣ

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
var currentUserId = <%=user_id%>; //�û�id
var nodeid = <%=nodeid%>;
var requestid = <%=requestid%>;
var isbill = <%=isbill%>;
var currentnodetype = '<%=currentnodetype%>';
var nodeName = getNodeName(nodeid);
var data = new Array();
var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>);
var linecount = 0;
var expensetypeSelect = jQuery('#field' + <%=mMap.get("applytype")%>);
var budgetWarnFlag = 0;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
var isOpenBudgetFlag = 'Y';
setProjectContentDisplay(expensetypeSelect);//�趨��Ŀ����ʾ
//20171209 added  by ect jiajing start
var employno;  //Ա����ţ����ϵı������ֶε�value��
setProjectContentDisplay(expensetypeSelect);//�趨��Ŀ����ʾ
var expense_bill_type = jQuery('#field' + <%=mMap.get("expense_bill_type")%>);
var applysubcompany = jQuery('#field' + <%=mMap.get("applysubcompany")%>); //��ȡ�����˷ֲ�����
var budgetControlFlag = true;
//20171209 added  by ect jiajing end
//20180329 added by mengly for �������뵥���� begin
//20190218 added by sdaisino  for ���ɽ���˰��  begin
var jxsFlg = false;
//20190218 added by sdaisino for ���ɽ���˰��  end
var tripapplybillcode_c = jQuery('#field' + <%=mMap.get("tripapplybillcode_c")%>); //�������뵥code
if(tripapplybillcode_c.val() != '' && tripapplybillcode_c.val() != null){
	jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("");
	jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("<input onclick=\"openItemBill()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"����\" />");
}
//20180329 added by mengly for �������뵥���� end
window.onload = function(){
	//if(nodeName.indexOf('(N)') != -1){ //�����ڵ�
	// add by sdaisino ��������ӡҳ���Ż� start
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
	// add by sdaisino ��������ӡҳ���Ż� end
	if(currentnodetype == ''||currentnodetype == '0'){ //20181128 modified  by zuoxl for ��ڵ����˰����ʾ������(�ύ����ʾ���̾��)
		//20180601 added by lixw for ��Ʊ��Ϣ start
		//ˢ�·�Ʊ��ť 
		<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
			//20190218 added by sdaisino  for ���ɽ���˰��  begin
            jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoice()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />&nbsp;&nbsp;<input onclick=\"getTaxDetail()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"���ɽ���˰��\" />");
            //20190218 added by sdaisino for ���ɽ���˰��  end
        <%}else{ %>
            //20190218 added by sdaisino  for ���ɽ���˰��  begin
            jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />&nbsp;&nbsp;<input onclick=\"getTaxDetail()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"���ɽ���˰��\" />");
            //20190218 added by sdaisino for ���ɽ���˰��  end
        <%} %>
		jQuery("#tab_6").hide();  // ���ط�Ʊ��Ϣtabҳ
		//20180601 added by lixw for ��Ʊ��Ϣ end
        jQuery('#field' + <%=mMap.get("paytotalmoney")%> ).attr('readonly',true); //�����ܽ��
        jQuery('#field' + <%=mMap.get("reversaltotalmoney")%> ).attr('readonly',true); //�����ܽ��
        //20171209 added  by ect jiajing start
        jQuery('#field' + <%=mMap.get("applytotalmoney")%> ).attr('readonly',true); //�����ܽ��ֻ��
        //xuenhua 20190604 ����Ѻ��Ƿ񺬻����ֻ��
        jQuery('#field' + <%=mMap.get("ishuiyifee")%> ).attr('readonly',true); 
        jQuery('#field' + <%=mMap.get("huiyifei_currmony")%> ).attr('readonly',true); 
        //�󶨱���������onchange�¼�
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
		setTripApplyCode(expensebill);//20180321 added by zuoxl for �������뵥���п���
        expensebillShow(expensebill); //����ͷ��Ϣ����������������ϸ�е���������ʾ
        setcolumshow(expensebill);//�����д��������д������Ƿ���ʾ
        //20180329 added by mengly for �������뵥���� begin
		//���������뵥code��onchange�¼� 
		tripapplybillcode_c.removeAttr('onchange');      //�Ƴ�onchange�¼�
		tripapplybillcode_c.bind('change', function(){//��onchange�¼�      (+ '_browserbtn')
			if(tripapplybillcode_c.val() != '' && tripapplybillcode_c.val() != null){
				jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("");
				jQuery('#field' + <%=mMap.get("tripapplybill")%>).after("<input onclick=\"openItemBill()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"����\" />");
			}
			//window.open('/formmode/view/AddFormMode.jsp?modeId=1&formId=-6&type=1&requestid=1&orgid=81');     
		});
		//20180329 added by mengly for �������뵥���� end
        //�󶨱���������onchange�¼�
        expensebill.removeAttr('onchange');      //�Ƴ�onchange�¼�
        expensebill.bind('change', function(){//��onchange�¼�
            <%-- setCol(<%=mMap.get("paytotalmoney")%>,fmoney(0),false,fmoney(0)); //��ո����ܼ� --%>
            expensebillShow(expensebill); //����ͷ��Ϣ����������������ϸ�е���������ʾ
            setcolumshow(expensebill); //�����д��������д������Ƿ���ʾ
            jQuery("#tab_2").click();
            clearForm(0); //��ձ�����ϸ��
            clearForm(6); //��շ�Ʊ��ϸ��
            clearForm(0); //��ձ�����ϸ��
            clearForm(6); //��շ�Ʊ��ϸ��
            clearForm(7); //��ս�ͨ����ϸ
            clearForm(8); //���ס�޷���ϸ
            clearForm(9); //��ղ�����ϸ��         
            setCol(<%=mMap.get("applytotalmoney")%>, fmoney(0), false, fmoney(0)); //����ܽ��
            setCol(<%=mMap.get("paytotalmoney")%>, fmoney(0), false, fmoney(0)); //��ո����ܽ��
            setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(0), false, fmoney(0)); //��ջ����
            setTripApplyCode(expensebill);//20180321 added by zuoxl for �������뵥���п���
        }); 
        expensebillShow(expensebill); //����ͷ��Ϣ����������������ϸ�е���������ʾ
        setcolumshow(expensebill); //�����д��������д������Ƿ���ʾ
		//20180823 added by zuoxl for ��������˻صĵ��ݣ��������޸ĵ�������   begin
		var jobnumber = jQuery('#field' + <%=mMap.get("jobnumber")%>).val();//����������
		if(jobnumber!=null && jobnumber !=''){
			disabledSelect(<%=mMap.get("expense_bill_type")%>,false);//�������ͱ���
		}else{
			disabledSelect(<%=mMap.get("expense_bill_type")%>,true);//��������
		}
		//20180823 added by zuoxl for ��������˻صĵ��ݣ��������޸ĵ�������   
        jQuery("#tab_2").click();
        if(expense_bill_type.val() != '1'){     
            clearForm(7);
            clearForm(8);
            clearForm(9);
        }
        /*  bindinvoiceTable('9'); //�󶨲�����Ϣ�� */
        //��addRow�������ӿ���
        var addbutton9 = jQuery(jQuery("button[name ='addbutton9']")[0]);
        addbutton9.removeAttr('onclick');      //�Ƴ�onclick�¼�(���Ƴ��Ż�������)
        addbutton9.bind('click', function(){
            addRow9('9'); //�����е�ԭʼ����
            addRowinvoic('9','no');
            addRowControl('9','no');//20180315 added by zuoxl for ����ϸ��onchange�¼�
        });       
        // �󶨷�Ʊ����onchange�¼�
        <%-- invoicetypechagne();
       //������ֵ˰��Ʊ��
        var invoicetype = jQuery('#field' + <%=mMap.get("invoicetype")%>);  //��Ʊ����  --%>
        var addbutton6 = jQuery(jQuery("button[name ='addbutton6']")[0]);
        addbutton6.removeAttr('onclick');      //�Ƴ�onclick�¼�(���Ƴ��Ż�������)
        addbutton6.bind('click', function(){
            addRow6('6'); //�����е�ԭʼ����
            addRowinvoic('6','no');          
        });
        //20180315 added by zuoxl start
        //�󶨽�ͨ������ϸ��
        var addbutton7 = jQuery(jQuery("button[name ='addbutton7']")[0]);
        addbutton7.removeAttr('onclick');   
        addbutton7.bind('click', function(){
            addRow7('7'); //�����е�ԭʼ����
            addRowControl('7','no');//20180315 added by zuoxl for ����ϸ��onchange�¼�
        });
        //20180315 added by zuoxl end
        //20171219 added  by ect jiajing start
        //��ס�޷���Ϣ��
        var addbutton8 = jQuery(jQuery("button[name ='addbutton8']")[0]);
        addbutton8.removeAttr('onclick');      //�Ƴ�onclick�¼�(���Ƴ��Ż�������)
        addbutton8.bind('click', function(){
            addRow8('8'); //�����е�ԭʼ����
            addRowinvoic('8','no');    
            addRowControl('8','no'); //20180315 added by zuoxl for ����ϸ��onchange�¼�
        });
        //20171219 added  by ect jiajing end
        /* budgetControlFlag = true; */
        var deptNameIsNull = false;
        /* var employno;  //Ա����ţ����ϵı������ֶε�value�� */ // delete by ect jiajing
        //���requestid ��Ϊ����ֵ �����
        if(requestid != '' && requestid != '0'){
            jQuery('#field' + <%=mMap.get("requestid_c")%>).val(requestid);
        }
        var applyperson = jQuery('#field' + <%=mMap.get("applyperson")%>).val(); //������id
        var applydept = jQuery('#field' + <%=mMap.get("applydept")%>).val(); //���벿��id
        //20171209 added  by ect jiajing start
        var companycode = getapplycompany(applysubcompany.val()); //��ȡ�����˹�˾
        setCol(<%=mMap.get("applycompany")%>, companycode, true, companycode); //��ҳ���д�����˹�˾
        get_applytel(applyperson); // �������ֻ���
        var telno = jQuery('#field'+<%=mMap.get("tel")%>).val();
        if(telno == '' || telno == null){
            alert('��ά�������˵绰���ֻ���,�������');
        }
        //20171209 added  by ect jiajing end
        var count = checkInMatrix(applyperson,48,'applyperson');//�Ƿ��Ÿ�����  (�л�ϵͳ��Ҫ�ı�)
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
        employno = userInfo.map.WORKCODE;//Ա�����
        //20171209 modefied by ect jiajing start
        if(requestid==-1){         
          <%-- setCol(<%=mMap.get("applycompany")%>, userInfo.map.SUBCOMPANYCODE, true, userInfo.companyName); --%>
        //���ó�ʼֵ
          setCol(<%=mMap.get("applytotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("reversaltotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("paytotalmoney")%>,fmoney(0),false,fmoney(0));
          setCol(<%=mMap.get("huiyifei_currmony")%>,fmoney(0),false,fmoney(0));//xuenhua 20190604 �����
          var dataLoan = new Array();
          if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97'){
              dataLoan = getLoanData(employno);//�����ݿ��л�ȡ�����ʷ��ϸ
          }else{
              dataLoan = getLoanData2(employno,orgid.val());//�����ݿ��л�ȡ�����ʷ��ϸ
          }
          loadRepaymentDetailBeforeSave(dataLoan);//���ؽ����ʷ��ϸ
         
        }else{
            jQuery('#field' + <%=mMap.get("applytotalmoney")%>+ 'ncspan').hide();
            loadRepaymentDetail();
            setLineDisplay();
            setLineDisplay7(); //������ֵ˰��ϸ��
            setLineDisplay10(); //������Ϣ��ϸ�п���
            setLineDisplay8(); //ס�޷���ϸ�п���
        }
        //20171209 modefied by ect jiajing end
        //20171209 delete by ect jiajing start
        /* if(requestid == -1){  //�´���������
            var dataLoan = new Array();
            dataLoan = getLoanData(employno);//�����ݿ��л�ȡ�����ʷ��ϸ
            loadRepaymentDetailBeforeSave(dataLoan);//���ؽ����ʷ��ϸ
        }else{
            loadRepaymentDetail();
            setLineDisplay();
        } */
        //20171209 delete by ect jiajing end
      //�Ƿ���Ԥ��
        isOpenBudgetFlag = aisinoIsOpenBudget(orgid.val());
        checkCustomize = function(){//�ύǰ��֤
			//�ύǰ����ҵ���д�����ϸ�н��
			countywzdDetailMoney();
			//20180827 added by zuoxl for �ύǰУ�鷢Ʊ�Ƿ���д�������û� begin
        	if(!checkInvoiceStatus(requestid)){
        		return false;
        	}
        	//20180827 added by zuoxl for �ύǰУ�鷢Ʊ�Ƿ���д�������û�
            //20171209 added by ect jiajing start
        	//20171219 added by ect jiajing start
        	if(!expensestandardcheck()){ //У��ס�ޱ�׼�Ƿ�Ϊ����
        		return false;
        	}
        	if(!allowancecheck()){ //У�鲹����׼�Ƿ�Ϊ����
                return false;
            }
        	//20171219 added by ect jiajing end
        	if(!checkdinvoicelength()){ //��֤��Ʊ���볤��
                return false;
            }
            if(!checkdinvoicelength2()){ //��֤��Ʊ���볤��
                return false;
            }
            if(!checkInvoiceNoExist()){//��֤���ӷ�Ʊ���Ƿ��Ѿ�����
                return false;
            }
            if(!checkInvoiceNoExist2()){ //��֤��Ʊ����ͷ�Ʊ�����Ƿ���д�ظ�
                return false;
            }
			if(!checkReimbursementMoney()){ //��֤�ܽ���뱨������ϸ�ܶ��Ƿ�һ��
				alert('���鱨������ϸ��˰����д');
				return false;
			}
            if(!istelnull()){
                alert('��ά�������˵绰���ֻ���');
                return false;
            }
          //��֤���빫˾��Ϊ��
            if (!isapplycompanynull){
                alert('���빫˾����Ϊ��');
                return false;
            }
            //��Ŀ��Ϊ�� ��֤
            if(!isdeptnull()){
                alert('�����˲��Ų���Ϊ��');
                return false;
            }
            //��֤������ϸ��˰�����˰����Ƿ���ȷ
            if(!checkmoney1()){
                return false;
            }
            //��֤��Ʊϸ��˰�����˰����Ƿ���ȷ
            if(!checkmoney7()){
                return false;
            }
            if(expense_bill_type.val() == '1'){
                // У�齻ͨ����ϸ�е������ڱ�����ڿ�ʼ����
                if(!checkArrivaldate()){
                    alert('��ͨ������ϸ�У��������ڱ�����ڿ�ʼ����');
                    return false;
                }
                if(!checkOutdate()){
                    alert('ס�޷���ϸ�У���ס���ڲ��ܴ����������');
                    return false;
                }
            }           
            if(isLineDeptNull()){ //У�� ���ϵ����β����Ƿ�Ϊ�� 
                alert('��ϸ���ϵķ��óе����Ų��Ų���Ϊ�գ�����');
                return false;
            }
            if(!taxmoneyCheck()){
                alert('������ϸ��˰��ܴ��ڱ������');
                return false;
            }
            if(!taxmoneyCheck7()){
                alert('��ֵ˰��Ʊ��ϸ����ֵ˰˰���ܴ��ڱ������');
                return false;
            }
            /* if(!isNullcheck()){
                alert('���÷ѱ�������ͨ����ϸ��ס�޷���ϸ��������ϸ����Ϊ��');
                return false;
            } */
            //���У��
            if(!totalmoneyCheck()){
                alert('��ϸ�н�ͨ�ѡ�ס�޷ѡ������Ѻϼ����ܽ����');
                return false;
            }
            if(!isdutydepartmentNull()){ //������ϵķ��óе����ţ���ô�ò��ŵĲ��ű�Ŵ���
                if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97' || orgid.val() == '662'|| orgid.val() == '723'){
                    alert('�ò��ŵĲ��ű�Ŵ�������ϵ����Ա');
                }else{
                    alert('������ϸ�еķ��óе����Ų���Ϊ��');
                }
                
                return false;
            }
            if(isLineDeptNull()){ //У�� ���ϵķ��óе������Ƿ�Ϊ�� 
                alert('��ϸ���ϵķ��óе����Ų���Ϊ�գ�����');
                return false;
            }
            //��֤�տ�����ϸ�Ƿ�Ϊ��
            var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val(); //�����ܽ��
            if(getFloat(paytotalmoney) > 0){
                if(!PayeeIsinput()){
                    alert('�տ�����ϸ������Ϊ��');
                    return false;
                }
            }
			//20181015 added by zuoxl for У������֧��ͨ��λ��֧����ʽ������ֱ���� �Լ��տ�����ϸ��Ϣ begin
			if(checkQposStatus(orgid.val())){ //У���Ƿ�����֧��ͨ��������У��֧����ʽ�Լ��տ�����ϸ��Ϣ
	        	if(!checkPayway()){
	        		alert('����֧��ͨ��λ֧����ʽӦѡ������ֱ������');
					return false;
				}
				if(!checkReciptinfo()){
					return false;
				}
			}
        	//20181015 added by zuoxl for У������֧��ͨ��λ��֧����ʽֻ���ǡ�����ֱ���� �Լ��տ�����ϸ��Ϣend
          //20171209 added by ect jiajing end
          //20171209 delete by ect jiajing start
          /* //��֤�������Ƿ�������Ƿ���ͬһ������
          if(!checkemploy()){
            alert('��'+linecount+'�������˲��ڸ����β����£�������ѡ��!');
            return false;
          }
          if(deptNameIsNull){ //������ϵ����β���Ϊ�գ���ô�ò��ŵĲ��ű�Ŵ���
              alert('�ò��ŵĲ��ű�Ŵ�������ϵ����Ա');
            return false;
          }
          if(isLineDeptNull()){ //У�� ���ϵ����β����Ƿ�Ϊ�� 
            alert('��ϸ���ϵ����β��Ų���Ϊ�գ�����');
            return false;
          }
          //��֤���ӷ�Ʊ��
          if(checkElecNoOnSubmitBefore()){
            return false;
          } */
          //20171209 delete by ect jiajing end
          countPayTotalMoney();//�����ܽ��
                var applyCount = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();
          //��֤��˰�ϼ�
          if(applyCount <= 0){
            alert('��������С��0����ȷ�ϱ�����Ϣ��');
            return false;
          }
          //��֤�����ܽ��,�����ܽ��
          var reversalCount = jQuery('#field' + <%=mMap.get("reversaltotalmoney")%>).val();
          if(applyCount - fmoney(reversalCount) < 0){
            alert('�����ܽ��ܴ��ڱ����ܽ��������޸ģ�');
            return false;
          }
          var paytotalmoney1 = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
          var requestid_p = jQuery('#field' + <%=mMap.get("requestid_c")%>).val();
          if(paytotalmoney1!=0){
	          if(checkPayStatus()){
	              alert('���顰�տ�����ϸ�������Ƿ���ȷ');
	              return false;
	          }
	          if(checkTaxMoney()){
	              alert('��̯����븶���ܽ�һ�£���鿴');
	              return false;
	          }
          }
          if(paytotalmoney1==0&&requestid_p != ''){
              checkPayShareB4Submit();//�жϸ������Ƿ�Ϊ'0'����Ϊ'0'��ɾ���տ�����ϸ
          }
          //20180316 added by zuoxl for ���ñ�����֤���������Ƿ񳬱� begin =======
       	  if(check_company_sys_status(companycode) != '-1') {
	          //��֤��ͨ���߱�׼
	          if(checkAllVehicle()!='-1'){
	          	return false;
	          }
	          //��֤ס�޷��ñ�׼
	          if(checkAllExpense()!='-1'){
	          	return false;
	          }
	          //��֤�������ñ�׼
	          if(checkAllAllowance()!='-1'){
	          	return false;
	          }
	          
	          if(checkVehicleHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("��ͨ������ϸ����Ա����δά������ά��������ύ��");
	          	return false;
	          }
	          
	          if(checkExpenseHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("ס�޷�����ϸ����Ա����δά������ά��������ύ��");
	          	return false;
	          }
	          if(checkAllowanceHrlevel()!=-1){
	          	var flag = checkVehicleHrlevel();
	          	alert("����������ϸ����Ա����δά������ά��������ύ��");
	          	return false;
	          }
	          if(checkVehicleStandard()!=-1){
	          	alert("��ͨ���߱�׼Ϊ�գ���ά��������ύ��");
	          	return false;
	          }
	          if(checkExpenseStandard()!=-1){
	          	alert("ס�޷��ñ�׼Ϊ�գ���ά��������ύ��");
	          	return false;
	          }
	          if(checkAllowanceStandard()!=-1){
	          	alert("�������ñ�׼Ϊ�գ���ά��������ύ��");
	          	return false;
	          }
       	  }  
          //20180316 added by zuoxl for ���ñ�����֤���������Ƿ񳬱� end =======
          <%-- var workflowcode = jQuery('#field' + <%=mMap.get("workflowcode")%>).val(); --%>
          //��֤���̱���Ƿ��ظ�  (�ύǰ�޷����� )
          /* if(checkworkflowcode(workflowcode)){
            alert('�Բ���,���̱���ظ�����ϵ����Ա��'); 
            return false;
          } */
          //20171209 delete by ect jiajing start
          /* //����ǲ��÷ѣ��������������û�ϱ���
          if(checkIstravel()){
            if(orgid.val() == 83){//��
              alert('��ҵ���д����⣬���÷����������ò���ͬʱ������');
              return false;
            } else if(orgid.val() == 81){
              alert('���÷����������ò���ͬʱ������');
              return false;
            }    
          }
          //����ǲ��÷ѣ���������Ϊ��
          if(checktripdaycount()){
            alert('���÷ѱ���ʱ��������˰���⣬��������Ϊ�գ�');
            return false;
          } */
          //20171209 delete by ect jiajing end
          if(isOpenBudgetFlag == 'Y'){ //Ԥ����֤������Ԥ�����δ��Ԥ�㣩
              budgetWarnFlag = 0;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
            //����Ԥ��
            showBudgetOuter(); 
              
            if(!budgetControlFlag){
              alert('��Ŀ��ϲ����ڣ���������Ϣ��ά������δ��Ԥ�㣬����ϵ����ά����');
              return false;
            }
            //20170511 edited for Ԥ����� by mengly begin
            // ��֤Ԥ��
            if(budgetWarnFlag==1){
              alert('����,Ԥ�㳬�������ܱ�������鿴���������Ϣ��Ԥ����Ϣ');
              return false;
            } else if(budgetWarnFlag==3){
              if(window.confirm('����,���ڳ���Ԥ�������ı�����Ƿ�鿴Ԥ����Ϣ��\n �������ȡ�������ύ��')){
                return false; 
              }
            } else if(budgetWarnFlag==2){
              alert('����,Ԥ�㳬�������ܱ�������鿴Ԥ����Ϣ');
              return false;
            }
            //20170511 edited for Ԥ����� by mengly end
          }
          /* checkFeetype();//�Ƿ�ҵ���д����ֶ� */ //delete by ect jiajing 
          //modifer:fengjl20170630--begin
          getBusinessType();//�жϵ�ǰ����֯�����Ƿ���Ҫҵ����
          //modifer:fengjl20170630--end
          clearForm(2);//���Ԥ���
          //20170426 added for Ԥ��������ܵ��� by yandong begin
          //���ɷ������
          getApExpenseSegment();
          //20170426 added for Ԥ��������ܵ��� by yandong end
          deletePrementLine();//ɾ���������Ϊ�յĽ����ʷ��ϸ��
          var no1 = <%=mMap1.get("no")%>;
          var no2 = <%=mMap2.get("no")%>;
          checkLineNo(0,no1,no2);//������ϸ���к�
          checkLineNo(1,no1,no2);//�����ʷ��ϸ�к�
          return true;
        }
        if(isOpenBudgetFlag != 'Y'){//����Ԥ��
            jQuery("#reloadBudgetBtnTr").hide();
            jQuery("#budgetDetailTr").hide();
        }else{
            jQuery("#reloadBudgetBtn").after("&nbsp;&nbsp;<input onclick=\"showBudgetOuter()\"  title=\"��Ԥ����Ϣ\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ԥ����Ϣ\" />&nbsp;&nbsp;<input onclick=\"clearForm(2)\"  title=\"�ر�\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"�ر�\" />");
        }
        //��ȡ��Ա�Ĺ�˾��Ϣ
        var deptLongNo = getDeptNumber(jQuery('#field' + <%=mMap.get("applydept")%>).val());
        var deptSegment = splitString(deptLongNo,'-',0);
        jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(deptSegment);
        if(jQuery('#field' + <%=mMap.get("istranscompany_c")%>).val() == 1){
            var transDeptLongNo = getDeptNumber(transDeptCode);
            var transDeptSegment = splitString(transDeptLongNo,'-',0);
            jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(transDeptSegment);
        }
        //���÷���ģ��������Ϊֻ���������в����������ť������������Ϊ�˷�ֹAutoCompleteʹ��ʧȥ���ƣ�
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '__').attr('readonly',true); //����ģ��
        jQuery('#field' + <%=mMap.get("projectno")%> + '__').attr('readonly',true); //��Ŀ���
        //�������͵�onchange�¼�����շ���ģ�����Ϣ���Լ������У�
        var expensetypeSelect = jQuery('#field' + <%=mMap.get("applytype")%>);
        setProjectContentDisplay(expensetypeSelect);//�趨��Ŀ����ʾ
        expensetypeSelect.removeAttr('onchange');      //�Ƴ�onchange�¼�
        expensetypeSelect.bind('change', function(){   //��onchange�¼�
            setProjectContentDisplay(jQuery(this));//�趨��Ŀ����ʾ
            setCol(<%=mMap.get("feetemplate")%>, '', true, '');//��շ���ģ��
            setNeedCheck(<%=mMap.get("feetemplate")%>,true);//���á�����ģ�塯����
            clearForm(0);//��ձ�����Start
            //��ձ�����End
            //20171209 added by ect jiajing start
            clearForm(6); //��շ�Ʊ��ϸ��
            clearForm(7); //��ս�ͨ����ϸ
            clearForm(8); //���ס�޷���ϸ
            clearForm(9); //��ղ�����ϸ��
            setCol(<%=mMap.get("applytotalmoney")%>, fmoney(0), false, fmoney(0)); //����ܽ��
            setCol(<%=mMap.get("paytotalmoney")%>, fmoney(0), false, fmoney(0)); //��ո����ܽ��
            setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(0), false, fmoney(0)); //��ո����ܽ��
            //20171209 added by ect jiajing end
        });
        //��addRow�������ӿ���
        var addbutton0 = jQuery(jQuery("button[name ='addbutton0']")[0]);
        addbutton0.removeAttr('onclick');      //�Ƴ�onclick�¼�(���Ƴ��Ż�������)
        addbutton0.bind('click', function(){  //��onclick�¼�
          //20190218 added by sdaisino  for ���ɽ���˰��  begin
          jxsFlg = false;
          //20190218 added by sdaisino for ���ɽ���˰��  end
          var expenseType = jQuery('#field' + <%=mMap.get("applytype")%>);//��������
          var feeTemplate = jQuery('#field' + <%=mMap.get("feetemplate")%>);//����ģ��
          var projectNo = jQuery('#field' + <%=mMap.get("projectno")%>);//����ͷ��Ϣ����Ŀ���
          var deptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //���Ŷ�
          if(deptNo == null || deptNo =='')   { alert('�ò���û��ά�����ű���'); return; }
          if(expenseType.val() == null || expenseType.val() == '')      { alert('����ѡ��������'); return; }
          if(feeTemplate.val() == null || feeTemplate.val() == '')      { alert('����ѡ�����ģ��'); return; }
          //��Ŀ����ʱ����Ŀ��Ų���Ϊ��
          if(expenseType.val() == 1 && (projectNo.val() == null || projectNo.val() == ''))   { alert('��Ŀ�����౨������Ŀ��Ų���Ϊ��'); return; }
          addRow0(0); //�����е�ԭʼ����
          //20171209 modefied by ect jiaing start
          /* addRowDetail0(); */
          addRowDetail0('0','no');
        //20171209 modefied by ect jiaing end
        // add by sdaisino ��������ӡҳ���Ż� start
        var rowIndex = 1 * parseInt(document.getElementById("indexnum0").value)-1; //��ȡ��ǰ�е�����     
        jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).bind('change',function(){
            segmentTaxAdd();
        }); 
        // add by sdaisino ��������ӡҳ���Ż� end
        });
        //  ������ϸ��  (��delRow�������ӿ���)
        var delbutton0 = jQuery(jQuery("button[name ='delbutton0']")[0]);
        delbutton0.removeAttr('onclick');      
        delbutton0.bind('click', function(){
          deleteRow0(0);
          countDetailMoney(0, <%=mMap1.get("localmoney")%>, <%=mMap.get("applytotalmoney")%>);
          countPayTotalMoney();
          // add by sdaisino ��������ӡҳ���Ż� start
          var verform = document.getElementById("verform");
          if (verform) {
              var detailLine0 = document.getElementsByName('check_node_0');
	          var taxmoney = parseFloat(0);
	          for(var i = 0;i < detailLine0.length;i++){
	              var myIndex = detailLine0[i].value;
	              var taxText = jQuery('#field22369_'+ myIndex); //����˰�ı�
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
	  // add by sdaisino ��������ӡҳ���Ż� end
          return false;
        });
       //�����ʷ��ϸ  (��delRow�������ӿ���)
        var delbutton1 = jQuery(jQuery("button[name ='delbutton1']")[0]);
        delbutton1.removeAttr('onclick');      
        delbutton1.bind('click', function(){ 
          deleteRow1(1);
          countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
          countPayTotalMoney();
          return false;
        });
        //����ģ�������ť����¼�
        var feetemp = jQuery('#field' + <%=mMap.get("feetemplate")%>);
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '_browserbtn').removeAttr('onclick');
        jQuery('#field' + <%=mMap.get("feetemplate")%> + '_browserbtn').bind('click', function(){
          if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == null || jQuery('#field' + <%=mMap.get("applytype")%>).val() == ''){
            alert('����ѡ��������');
            return;
          }
          //��ձ�����
          selectAllLine(0); //ѡ�����б�����ϸ��
          delRowFun_new(0); //ɾ��ѡ����
          jQuery('#field' + <%=mMap.get("projectno")%>).val('');//��Ŀ���
          jQuery('#field' + <%=mMap.get("projectno")%> + 'span').html('');//��Ŀ���
          jQuery('#field' + <%=mMap.get("projectname")%>).val('');//��Ŀ����
          jQuery('#field' + <%=mMap.get("projectmanager")%>).val('');//��Ŀ����
          jQuery('#field' + <%=mMap.get("glprojectcode")%>).val('');//Ԥ����Ŀ����
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
        //��Ŀ��������ť����¼�
        var projno = jQuery('#field' + <%=mMap.get("projectno")%>);
        jQuery('#field' + <%=mMap.get("projectno")%> + '_browserbtn').removeAttr('onclick');
        jQuery('#field' + <%=mMap.get("projectno")%> + '_browserbtn').bind('click', function(){
          if(jQuery('#field' + <%=mMap.get("feetemplate")%>).val() == null || jQuery('#field' + <%=mMap.get("feetemplate")%>).val() == ''){
            alert('����ѡ�����ģ��');
            return;
          }
          if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //��Ŀ����
            if(jQuery('#field' + <%=mMap.get("feetemplate")%> + 'span').text().indexOf('�г�') == -1){
              jQuery('#field' + <%=mMap.get("scflag_c")%>).val('NO');//�趨���Ƿ��г����ֶ�
            } else {
              jQuery('#field' + <%=mMap.get("scflag_c")%>).val('SC');//�趨���Ƿ��г����ֶ�
            }
          }
          //��ձ�����
          selectAllLine(0); //ѡ�����б�����ϸ��
          delRowFun_new(0); //ɾ��ѡ����
          onShowBrowser2(<%=mMap.get("projectno")%>,
                  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.projectno','','161',projno.attr('viewtype'));    
        });
        // modefied by ect jiajing start        
         /*jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"payShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"�༭�տ�����ϸ\" />&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />"); */

        //�տ�����ϸ��ť  
        <% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
            jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"payShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"�༭�տ�����ϸ\" />&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />");
        <%}else{ %>
            jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />");
        <%} %>
        // modefied by ect jiajing end
    }else if(nodeName.indexOf('(I)') != -1){//����ERP�ڵ�
		//20180601 added by lixw for ��Ʊ��Ϣ start
		//ˢ�·�Ʊ��ť  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />");
		jQuery("#tab_6").show();  // ��ʾ��Ʊ��Ϣtabҳ
		//20180601 added by lixw for ��Ʊ��Ϣ end
    	//20171209 added by ect jiajing start
    	hidebutton(expense_bill_type.val());// �������ɾ����ť
        //����������Ϊ���÷ѱ�����ʱ���÷���ϸ��ʾ����������
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
        setcolumshow(expensebill); ////�����д��������д������Ƿ���ʾ
        expensebillShow(expensebill); //����ͷ��Ϣ����������������ϸ�е���������ʾ
    	//20171209 added by ect jiajing end
    	checkCustomize = function(){ //�ύǰУ��
            var invoiceNum = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();
            if(invoiceNum!=null && invoiceNum != ''){
              return true;
            }else{
              if(window.confirm('����,����δִ�е���erp������û�����ɷ�Ʊ���Ƿ�����ύ��')){
                return true;
              }else{
                return false;
              }
            }
            return true;
        }
    	jQuery("#importERP").after("&nbsp;&nbsp;<input onclick=\"importERPOuter()\"  title=\"����erp\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"����erp\" />");
        /*�տ�����ϸ��ť   author�������  begin*/
        //20171209 modefied by ect jiajing start
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />"); */
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />");
        //20171209 modefied by ect jiajing end
        /*�տ�����ϸ��ť   author�������  end*/
    }else if(nodeName.indexOf('(E)') != -1){//�����ڵ�
        //20180601 added by lixw for ��Ʊ��Ϣ start
		//ˢ�·�Ʊ��ť  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />");
		jQuery("#tab_6").show();  // ��ʾ��Ʊ��Ϣtabҳ
		//20180601 added by lixw for ��Ʊ��Ϣ end
    }else if(nodeName.indexOf('(P)') != -1){//��ӡ�ڵ�
		//20180601 added by lixw for ��Ʊ��Ϣ start
		//ˢ�·�Ʊ��ť  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />");
		jQuery("#tab_6").show();  // ��ʾ��Ʊ��Ϣtabҳ
		//20180601 added by lixw for ��Ʊ��Ϣ end
        /*�տ�����ϸ��ť   author�������  begin*/
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />"); */  //20171209 delete by ect jiajing
        /*�տ�����ϸ��ť   author�������  end*/
        //20171209 added by ect jiajing start
        hidebutton(expense_bill_type.val());// �������ɾ����ť
        //����������Ϊ���÷ѱ�����ʱ���÷���ϸ��ʾ����������
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
        expensebillShow(expensebill);
        setcolumshow(expensebill); //�����д��������д������Ƿ���ʾ
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />");
        //20171209 added by ect jiajing end
        
    }else{//�����ڵ�ͨ��
		//20180601 added by lixw for ��Ʊ��Ϣ start
		//ˢ�·�Ʊ��ť  
		jQuery('#flush_invoice').after("&nbsp;&nbsp;<input onclick=\"flushInvoices()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ʊ��ϸ\" />");
		jQuery("#tab_6").show();  // ��ʾ��Ʊ��Ϣtabҳ
		//20180601 added by lixw for ��Ʊ��Ϣ end
    	//20171209 added by ect jiajing start
    	hidebutton(expense_bill_type.val());// �������ɾ����ť
        jQuery('#field' + <%=mMap.get("applytotalmoney")%>+ 'ncspan').hide();
        //����������Ϊ���÷ѱ�����ʱ���÷���ϸ��ʾ����������
        var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
        setcolumshow(expensebill); ////�����д��������д������Ƿ���ʾ
        expensebillShow(expensebill); 
    	//20171209 added by ect jiajing end
    	budgetControlFlag = true;
        <%-- var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>); --%> //20171209 delete by ect jiajing
        //�Ƿ���Ԥ��
        isOpenBudgetFlag = aisinoIsOpenBudget(orgid.val());
        if(isOpenBudgetFlag != 'Y'){//����Ԥ��
          jQuery("#reloadBudgetBtnTr").hide();
          jQuery("#budgetDetailTr").hide();
        }else{
          jQuery("#reloadBudgetBtn").after("&nbsp;&nbsp;<input onclick=\"showBudgetOuter(true)\"  title=\"��Ԥ����Ϣ\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��Ԥ����Ϣ\" />&nbsp;&nbsp;<input onclick=\"clearForm(2)\"  title=\"�ر�\" class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"�ر�\" />");
        }
        /*�տ�����ϸ��ť   author�������  begin*/
        /* jQuery('#selectShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 100px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />"); */  // 20171209 delete by ect jiajing
        /*�տ�����ϸ��ť   author�������  end*/
        // 20171209 added by ect jiajing start
        jQuery('#payShare').after("&nbsp;&nbsp;<input onclick=\"selectShare()\"  class=\"e8_btn_top_first\" style=\"text-overflow: ellipsis; max-width: 150px; white-space: nowrap; overflow: hidden;\" type=\"button\" _disabled=\"true\" value=\"��ѯ�տ�����ϸ\" />");
        // 20171209 added by ect jiajing end
        
        checkCustomize = function(){//�ύǰ��֤
            if(isOpenBudgetFlag == 'Y'){ //Ԥ����֤������Ԥ�����δ��Ԥ�㣩
                budgetWarnFlag = 0;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
              //����Ԥ��
              showBudgetOuter(true); 
                if(!budgetControlFlag){
                alert('��Ŀ��ϲ����ڣ���������Ϣ��ά������δ��Ԥ�㣬����ϵ����ά����');
                return false;
              }
              //20170511 edited for Ԥ����� by mengly begin
            // ��֤Ԥ��
            if(budgetWarnFlag==1){
              alert('����,Ԥ�㳬�������ܱ�������鿴���������Ϣ��Ԥ����Ϣ');
              return false;
            } else if(budgetWarnFlag==3){
              if(window.confirm('����,���ڳ���Ԥ�������ı�����Ƿ�鿴Ԥ����Ϣ��\n �������ȡ�������ύ��')){
                return false; 
              }
            } else if(budgetWarnFlag==2){
              alert('����,Ԥ�㳬�������ܱ�������鿴Ԥ����Ϣ');
              return false;
            }
            //20170511 edited for Ԥ����� by mengly end
            }
            clearForm(2);//���Ԥ���
            return true;
        }
    	
    }
    //20190218 added by sdaisino  for ���ɽ���˰��  begin
    if ($("#flush_invoice")) {
    	$("#flush_invoice").parent().attr("colSpan",2)
	}
	//20190218 added by sdaisino for ���ɽ���˰��  end
}
if(isbill==0){ //��ӡ����
    window.onload=function(){
	// add by sdaisino ��������ӡҳ���Ż� start
	var verprint = document.getElementById("verprint");
	if (verprint) {
	    dealTaxMony();
	    addMoneyNoTax();
	}
	// add by sdaisino ��������ӡҳ���Ż� end
	//20171212 added by mengly for EBS��λ˰����ʾ begin
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
    	//20171212 added by mengly for EBS��λ˰����ʾ end
        var orgid = jQuery('#field' + '7918').val(); 
      var finantialProjectNo = ' ';//������Ŀ��
      for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
          var finantialProjectNoLine = jQuery('#field' + '7972_' + i).val();//���ϵĲ�����Ŀ��
          if(finantialProjectNoLine != '' && finantialProjectNoLine != null){
              finantialProjectNo = finantialProjectNoLine;
        }
    }
      //��ȡ������Ŀ����
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
        /* ���÷� Start */
        var isTravelFee = jQuery('#field' + '22205').val(); //�Ƿ���÷�
      if(isTravelFee == '1'){//���÷�
          jQuery('#titleName').text('���÷ѱ�����');
		  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
          //jQuery('#feeDate').html('<b>��ʼ����</b>');//
          jQuery('#oTable7').parent().parent().parent().parent().hide();
          jQuery('#oTable8').parent().parent().parent().parent().hide();
          jQuery('#oTable9').parent().parent().parent().parent().hide();
          for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
            <%--//��ȡÿ����ϸ������
            var ts = jQuery('#field' + '7977_' + i).val();
            //��ȡÿ����ϸ����ʼ����
            var qsrq = jQuery('#field' + '7976_' + i).val();
            if(ts==''||ts==null){
                  ts=0;
              }
            if(ts){
              //������ֹ����
              var sql = "select to_char(to_date('" + qsrq + "','yyyy-mm-dd')" + "+" + ts + ",'yyyy-mm-dd') enddate from dual";
                //��ȡ��ֹ����
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
      }else if(isTravelFee == '0'){//�ǲ��÷�
    	  jQuery('#titleName').text('ͨ�ñ�����');
    	  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
      }else if(isTravelFee == '2'){
    	  jQuery('#titleName').text('ҵ���д��ѱ�����');
    	  jQuery('.ywzd_zdrs').show();
          jQuery('.ywzd_zdjb').show();
      }else if(isTravelFee == '3'){
    	  jQuery('#titleName').text('����ѱ�����');
    	  jQuery('.ywzd_zdrs').hide();
          jQuery('.ywzd_zdjb').hide();
      }
       // add by sdaisino ��������ӡҳ���Ż� start
       if (verprint) {
           removeSibling();
       }
      // add by sdaisino ��������ӡҳ���Ż� end
      //˵�� 
      var shuoming = document.getElementById('shuoming');
      // add by sdaisino ��������ӡҳ���Ż� start
      if (verprint) {
           shuoming.style.width='10%';
       } else {
           shuoming.style.width='28%';
       }
      // add by sdaisino ��������ӡҳ���Ż� end
      //���
      var jine = document.getElementById('jine');
      // add by sdaisino ��������ӡҳ���Ż� start
      if (verprint) {
           jine.style.width='10%';
       } else {
           jine.style.width='13%';
       }
      // add by sdaisino ��������ӡҳ���Ż� end
      jQuery('#endDate').hide();//�ǲ��÷�������ֹ����
      for(var i=0;i<document.getElementById('oTable0').rows.length - 1;i++){
          jQuery('#field' + '7977_' + i).parent().hide(); //��ֹ��������
    }
      
      //20180827 modified by zuoxl for ҵ���д���ʱ��ӡ�д��������д�����  begin
      if(rowindex < 8){
		if(isTravelFee == '2'){
			for(var i = rowindex; i < 8; i++){
	           // add by sdaisino ��������ӡҳ���Ż� start
	           if (verprint) {
           	       addRowPrint1(0,11);
               } else {
           	       addRowPrint1(0,8);
               }
	        }
	        if (verprint) {
           	    resetWidth11();
            }
	        // add by sdaisino ��������ӡҳ���Ż� end
    	}else{
    		for(var i = rowindex; i < 8; i++){
  	          // add by sdaisino ��������ӡҳ���Ż� start
  	          if (verprint) {
           	       addRowPrint1(0,9);
               } else {
           	       addRowPrint1(0,6);
               }
  	        }
  	        if (verprint) {
           		resetWidth9();
            } 
  	        // add by sdaisino ��������ӡҳ���Ż� end
    	}
       // add by sdaisino ��������ӡҳ���Ż� start
      } else {
          if (verprint) {
              if(isTravelFee == '2'){
                  resetWidth11();
              }else {
                  resetWidth9();
              }
          } 
      }
      // add by sdaisino ��������ӡҳ���Ż� end
      //20180827 modified by zuoxl for ҵ���д���ʱ��ӡ�д��������д�����  end
        /* ���÷� End */
        //������Ŀ��
      var applyperson = jQuery('#field' + '7916').val();//������
      var upperMoney = getUpperMoney(getFloat(jQuery('#field' + '7937').val()).toFixed(2));
      jQuery('#capitalMoney').html(upperMoney);//��˰�ϼƴ�д
      var memo = jQuery('#field' + '7928' + 'span').html(); //7928   ��ע
      //��ȡ�绰
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
    
      var expenseNo = jQuery('#field' + '7915').val(); //��������
      var approveListStr = '';
      //getApproveList  ��ȡ��������  
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
                  approveListStr += '��';
                }
                approveListStr +=data[i].NODENAME;
                approveListStr +='��';
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
    
    //document.getElementById('memo').innerHTML = memo + '<br>'  //��'��ע'����ӳ�����Ϣ
      //��ȡ ��������б�
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
              var ci = 0;  //ci��������Ƿ����
              var bzxx = '���ţ�δ�������';  //bzxx������������ĵ��źͽ��
              for(var i=0 ;i<data.length;i++){
                  var paidmoney = data[i].PAIDMONEY.replaceAll(',','');
                if(parseFloat(data[i].PAIDMONEY) > 0){
                  ci += 1;  //���ci��Ϊ0����bzxx���';'
                  bzxx += '��' + data[i].INVOICECODE+'(' + fmoney(data[i].PAIDMONEY,2) + ')��';  //��xxxx��1111����
                }
              }
              if(ci!=0){
                document.getElementById('sfcxjk').innerHTML='��';   //����'�Ƿ�������'��ֵ
                loanstr += '<br>' + bzxx;  //��'��ע'����ӳ�����Ϣ
                //document.getElementById('memo').innerHTML = memo + '<br>' + bzxx;  //��'��ע'����ӳ�����Ϣ
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
      // �����ܲ���ӡ������������տ�����ϸ����Ӧ����Ϣ����ӡ��������㹩Ӧ�����Ƽ����
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
                        paystr += '<br>' + '�տ�����ϸ��Ӧ�̣��������';  //�տ�����ϸ��Ӧ����Ϣ
                    }
                    paystr += '��' + data[i].EMPLOYEEORSUPPLIER+'(' + fmoney(data[i].SHAREMONEY,2) + ')��';  //��xxxx��1111����
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

// add by sdaisino ��������ӡҳ���Ż� start
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
// ɾ���ֵܽڵ�
function removeSibling(){
    var colspan = 1;
    var nextAll = jQuery('#capitalMoney').nextAll();
    for (var i = 0; i < nextAll.length; i++) {
        var content = nextAll[i].innerHTML;
        if (content == " <span>�ϼƣ�</span> ") {
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
// ˰���ܼ�
function dealTaxMony() {
    var detailLine0 = document.getElementsByName('check_node_0');
    var taxmoney = parseFloat(0);
    var localmoney = parseFloat(0);
    var tax = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var rowIndex = detailLine0[i].value;
	var account_segment = jQuery('#field22369_'+ rowIndex); //����˰�ı�
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
    // ����˰���
    if (jQuery('#sum7992')) {
         jQuery('#sum7992').html((localmoney - taxmoney).toFixed(2));
         jQuery('#sumvalue7992').val((localmoney - taxmoney));
     }
    var upperMoney = getUpperMoney(getFloat(jQuery('#field' + '7937').val()).toFixed(2));
    if (jQuery('#capitalMoney')) {
         jQuery('#capitalMoney').html(upperMoney);//��˰�ϼƴ�д
     }
}
function addMoneyNoTax(){
    var detailLine0 = document.getElementsByName('check_node_0');
    var moneyNoTax = parseFloat(0);
    var totalmoney = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var myIndex = detailLine0[i].value;
	  var taxText = jQuery('#field22369_'+ myIndex); //����˰�ı�
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

// ����˰�ı�change�¼�
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

// ˰���ۼ�
function segmentTaxAdd() {
    var detailLine0 = document.getElementsByName('check_node_0');
    var taxmoney = parseFloat(0);
    for(var i = 0;i < detailLine0.length;i++){
        var myIndex = detailLine0[i].value;
        var taxText = jQuery('#field22369_'+ myIndex); //����˰�ı�
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
 // add by sdaisino ��������ӡҳ���Ż� end

function addRowPrint1(groupid,columnCount){
	  var tdstr = ' <td class="border_1">&nbsp;</td>';
	  var tdstr1 = ' <td class="border_1" colspan=2></td>';
	  //var addRowHtmlStr = "<tr height='28px'> " + tdstr1 + tdstr + tdstr + tdstr + tdstr + tdstr + tdstr + " </tr>";
	  var addRowHtmlStr = "<tr height='28px'> " + tdstr1 ;
	  for(var i=0;i<columnCount;i++){
		  addRowHtmlStr += tdstr;
	  }
	  addRowHtmlStr += " </tr>";
	  //���������JS�ļ���
	  detailOperate.addRowOperDom(groupid, addRowHtmlStr);
}

/**
 * ���ؽ����ʷ��ϸ (�´�����)
 */
function loadRepaymentDetailBeforeSave(dataLoan){
  var addbutton1 = jQuery(jQuery("button[name ='addbutton1']")[0]); //���������а�ť �������ʷ��ϸ��
    addbutton1.hide();
    jQuery(jQuery('input[name="check_all_record"]')[1]).hide();
    var no = 0;//���
    for(var i=0; i<dataLoan.length; i++){
      addRow1(1);
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').attr('readonly',true); //�趨���ڱ��κ������δѡ�в��ɱ༭
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').removeAttr('onblur');
      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').bind('blur',function(){
        changeToThousands2(jQuery(this).attr('name'),2);
        checkMoney(this);
	      countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
        countPayTotalMoney();//���㱨���ܽ��,�����ܽ��,�����ܽ��
      });
      //��checkbox��ѡ�¼�
      jQuery('input[name="check_node_1"]').each(function(){
        var checkbox = jQuery(this).val();//��ǰָ��
          if(checkbox == i){
            jQuery(this).removeAttr('onclick');
            jQuery(this).bind('click', function(){ 
              if(this.checked){//�����ѡ
                var noVerificationAmount = jQuery('#field' + <%=mMap2.get("unpaidmoney")%> + '_'+ checkbox +'').val();//δ�������
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val(noVerificationAmount);//���κ������Ĭ�ϵ���δ�������
              }else{
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').attr('readonly',true);
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val('');
              }
              countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
              countPayTotalMoney();//���㱨���ܽ��,�����ܽ��,�����ܽ��
            });
          }
      });
      var invoiceid ='';//��Ʊid
      var orderCode ='';//��Ʊ��
      var orderAmount=0;//��Ʊ���
      var verificationAmount=0;//�������
      var noVerificationAmount=0;//δ�������
      var orderAbstract ='';//��ƱժҪ
      // var projectno ='';//��Ŀ���
      var invoicedate ='';//��Ʊ����
      var endtime='';//��������
      var occupymoney = 0; //����ռ�ý��
      var affertsubtract = 0;  // �ɺ������
      orderCode = dataLoan[i].INVOICE_NUM;//��Ʊ��
      orderAmount = checkZero(dataLoan[i].AMOUNT_NUM);//��Ʊ���
      verificationAmount = checkZero(dataLoan[i].REPAY_AMOUNT_NUM);//�ѻ�����
      //20180301 modified BY mengly FOR �������������� begin
      //noVerificationAmount = parseFloat(orderAmount) - parseFloat(verificationAmount);//��Ʊ���-�Ѻ������
      noVerificationAmount = parseFloat(orderAmount) - parseFloat(verificationAmount).toFixed(2);//��Ʊ���-�Ѻ������
      //20180301 modified BY mengly FOR �������������� end
      orderAbstract = dataLoan[i].DESCRIPTION;//��ƱժҪ
      invoiceid = dataLoan[i].INVOICE_ID;//��Ʊid
      // projectno = dataLoan[i].project_number;//��Ŀ���
      invoicedate = dataLoan[i].INVOICE_DATE;//��Ʊ����
      endtime = dataLoan[i].PROMISE_REPAYMENT_DATE;//��ŵ��������
      no =i+1;//���
      //20180301 modified BY mengly FOR �������������� begin
      occupymoney = parseFloat(isunpaidmoney(invoiceid)).toFixed(2); //��ȡ����ռ�ý��
      //���¼���ɺ������
      affertsubtract = parseFloat(noVerificationAmount).toFixed(2) - parseFloat(occupymoney);
      //20180301 modified BY mengly FOR �������������� end
      //  ��ֵStart
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
 * ���ؽ����ʷ��ϸ���������˻صı���
 */
function loadRepaymentDetail(){
  var addbutton1 = jQuery(jQuery("button[name ='addbutton1']")[0]); //���������а�ť �������ʷ��ϸ��
    addbutton1.hide();
    jQuery(jQuery('input[name="check_all_record"]')[1]).hide();
    var checkboxArr = document.getElementsByName('check_node_1');//��ȡcheckbox����
    if(checkboxArr.length>0){//�����г���������ϸ
    	for(var i=0; i<checkboxArr.length; i++){
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').attr('readonly',true); //�趨���ڱ��κ������δѡ�в��ɱ༭
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').removeAttr('onblur');
 	      jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ i +'').bind('blur',function(){
 	        changeToThousands2(jQuery(this).attr('name'),2);
 	        checkMoney(this);
 		      countDetailMoney(1, <%=mMap2.get("paidmoney")%>, <%=mMap.get("reversaltotalmoney")%>);
 	        countPayTotalMoney();//���㱨���ܽ��,�����ܽ��,�����ܽ��
 	      });
 	      //��checkbox��ѡ�¼�
 	      jQuery('input[name="check_node_1"]').each(function(){
 	        var checkbox = jQuery(this).val();//��ǰָ��
 	          if(checkbox == i){
 	        	  var money = jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val();
	            if(money != null && money != ''){
	              this.checked = true;
                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
	            } 
 	            jQuery(this).removeAttr('onclick');
 	            jQuery(this).bind('click', function(){ 
 	              if(this.checked){//�����ѡ
 	                var noVerificationAmount = jQuery('#field' + <%=mMap2.get("unpaidmoney")%> + '_'+ checkbox +'').val();//δ�������
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').removeAttr('readonly');
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val(noVerificationAmount);//���κ������Ĭ�ϵ���δ�������
 	              }else{
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').attr('readonly',true); 
 	                jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'').val('');
 	              }
 	              countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
 	              countPayTotalMoney();//���㱨���ܽ��,�����ܽ��,�����ܽ��
 	            });
 	          }
 	      });
 	    }
    }else{
    	<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
      	var dataLoan = new Array();
		    dataLoan = getLoanData(employno);//�����ݿ��л�ȡ�����ʷ��ϸ
		    loadRepaymentDetailBeforeSave(dataLoan);//���ؽ����ʷ��ϸ
    	<%} %>
    }
}

//��������ܽ��
function countRepayTotalMoney(fieldname){
  jQuery(fieldname).focus();
  jQuery(fieldname).blur();
}

//�����ܽ��
function countPayTotalMoney(){
  var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%> ).val();
  var repaytotalmoney = jQuery('#field' + <%=mMap.get("reversaltotalmoney")%> ).val();
  var paytotalmoney = parseFloat(applytotalmoney) - parseFloat(repaytotalmoney);
  setCol(<%=mMap.get("paytotalmoney")%>, fmoney(paytotalmoney), true, '');

  //xuenhua �������� 20190603
	var sumhuiyifee =sumHuiYiFee();
	setCol(<%=mMap.get("huiyifei_currmony")%>, fmoney(sumhuiyifee), true, '');
}

/**
 * ����Ԥ��
 * 
 * isApproveNode   �Ƿ������ڵ�
 */
function showBudgetOuter(isApproveNode){
  budgetControlFlag = true;
	//checkWarnRateOnSubmitBefore();
  clearForm(2);
  //20170426 added for Ԥ��������ܵ��� by yandong begin
  //���ɷ������
  getApExpenseSegment();
  //20170426 added for Ԥ��������ܵ��� by yandong end
  jQuery('input[name="check_node_0"]').each(function(){
    var checkbox = jQuery(this).val();
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'span').text();
    if(feetypeName.indexOf('����˰��') != -1)  return true; //���Ե�˰��
    var depart;  //���ò���
    var employee;  //Ա��id
    var feetype;  //��������
    var orgid = jQuery('#field' + <%=mMap.get("applycompany")%>);
    feetype = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'').val();
    if(feetype==''||feetype==null)  return true;
    depart = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ checkbox +'').val();  //���β���no
    employeeNo = jQuery('#field' + <%=mMap1.get("payperson")%> + '_'+ checkbox +'').val(); //Ա�����
    var businessprojectno = jQuery('#field' + <%=mMap1.get("projectno")%> + '_'+ checkbox +'span').text().trim(); //ҵ����Ŀ��
    var finprojectno = jQuery('#field' + <%=mMap1.get("financialproject")%> + '_'+ checkbox +'span').text().trim(); //������Ŀ��
    var money = jQuery('#field' + <%=mMap1.get("money")%> + '_'+ checkbox +'').val(); //���
    var glprojectcode = jQuery('#field' + <%=mMap.get("glprojectcode")%>).val(); //Ԥ����Ŀ����
    var glCodeStr = getGlCode(employeeNo,feetype,finprojectno);
   // showBudget(orgid.val(),depart,employeeNo,feetype,finprojectno,glprojectcode,businessprojectno,thisorderemoney,isApproveNode);
    showBudget(orgid.val(),depart,employeeNo,feetype,finprojectno,glprojectcode,businessprojectno,isApproveNode,checkbox); //20170706 MODIFIED BY WANGWW checkbox���
  });
}

//����Ԥ��
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
	     thisorderemoney = getFeetypeMoney(segment4);//20171012 ADDED BY mengly FOR ����Ԥ��
  }
  //20171012 ADDED BY mengly END
  if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //��Ŀ����
    //data = reloadProjectBudget(orgid,depart,employeeNo,feetype,glprojectcode,businessprojectno);
    glCodeStr = getGlCode(employeeNo,feetype,glprojectcode);
  } else if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 0){//��������
    //data = reloadPersonalBudget(orgid,depart,employeeNo,feetype);
    glCodeStr = getGlCode(employeeNo,feetype,finprojectno);
  }
  data = reloadBudget(segment1,segment2,segment3,segment4,segment6);  //20170706 added by wangww
  var language = readCookie("languageidweaver");
  // alert(glCodeStr + '��' + SystemEnv.getHtmlNoteName(-2, language));
  if(data.length == 0){
    budgetControlFlag = false;
    alert('[' + glCodeStr + ']\n��Ŀ��ϲ����ڣ���������Ϣ��ά��');
  }
  if(data.length > 0){
    addRow2(2);
    var rowsNum = 1 * parseInt(document.getElementById("indexnum2").value)-1;//�к�
    var availableMoney=0;//��ʹ�ý��
		var warningrate = data[0].WARNING_RATE;
    // jQuery('#field6942_'+rowsNum+'span').html(rowsNum+1);//�к�

    setCol(<%=mMap3.get("budgetdept")%> + '_'+rowsNum, data[0].DEPT_DESC, true, data[0].DEPT_DESC);
    setCol(<%=mMap3.get("financialproject")%> + '_'+rowsNum, data[0].DESCFIN_PROJECT_DESC, true, data[0].DESCFIN_PROJECT_DESC);
    setCol(<%=mMap3.get("costtype")%> + '_'+rowsNum, data[0].EXPENSE_CATEGORY_DESC+'.'+data[0].EXPENSE_CLASS_DESC, true, data[0].EXPENSE_CATEGORY_DESC+'.'+data[0].EXPENSE_CLASS_DESC);
    setCol(<%=mMap3.get("budgetwholeyear")%> + '_'+rowsNum, data[0].BUDGET_SUM, true, data[0].BUDGET_SUM);
    setCol(<%=mMap3.get("addupmoney")%> + '_'+rowsNum, data[0].ERP_ACTUAL_AMOUNT, true, data[0].ERP_ACTUAL_AMOUNT);
    setCol(<%=mMap3.get("approvingmoney")%> + '_'+rowsNum, data[0].BPM_ACTUAL_AMOUNT, true, data[0].BPM_ACTUAL_AMOUNT);
    setCol(<%=mMap3.get("warningproportion")%> + '_'+rowsNum, fmoney(warningrate) , true, fmoney(warningrate));
    if(isApproveNode == true){
      availableMoney=data[0].BUDGET_SUM - data[0].ERP_ACTUAL_AMOUNT - data[0].BPM_ACTUAL_AMOUNT;//��ʹ�ý��
    } else{
      availableMoney=data[0].BUDGET_SUM - data[0].ERP_ACTUAL_AMOUNT - data[0].BPM_ACTUAL_AMOUNT - thisorderemoney;//��ʹ�ý��
      setCol(<%=mMap3.get("currentordermoney")%> + '_'+rowsNum, fmoney(thisorderemoney), true, fmoney(thisorderemoney));
    }
    var performProportion=0;//ִ�б���
    if(data[0].BUDGET_SUM>0){
      performProportion = fmoney((1-(availableMoney/data[0].BUDGET_SUM))*100,2);
    } 
    //20170511 edited for Ԥ����� by mengly begin
    if(data[0].BUDGET_SUM == 0){
      budgetWarnFlag = 1;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
    }
    //20170511 edited for Ԥ����� by mengly end
    setCol(<%=mMap3.get("canusemoney")%> + '_'+rowsNum, fmoney(availableMoney), true, fmoney(availableMoney));
    setCol(<%=mMap3.get("proportion")%> + '_'+rowsNum, performProportion, true, performProportion);
    if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){ //��Ŀ����
       setCol(<%=mMap3.get("projectname")%> + '_'+rowsNum, jQuery('#field' + <%=mMap.get("projectname")%>).val(), true, jQuery('#field' + <%=mMap.get("projectname")%>).val());
    } else if(jQuery('#field' + <%=mMap.get("applytype")%>) == 0){//��������
       setCol(<%=mMap3.get("projectname")%> + '_'+rowsNum, '��', true, '��');
    }
    var warningrateVal = document.getElementById('field' + <%=mMap3.get("warningproportion")%> + '_' + rowsNum).value;//Ԥ������
    var proportionVal = document.getElementById('field' + <%=mMap3.get("proportion")%> + '_' + rowsNum).value;//ִ�б���
    var canusemoneyVal = document.getElementById('field' + <%=mMap3.get("canusemoney")%> + '_' + rowsNum).value;//��ʹ�ý��
    //20170511 edited for Ԥ����� by mengly begin
    if(budgetWarnFlag != 1 && canusemoneyVal<0){
      budgetWarnFlag = 2;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
    }
    if(budgetWarnFlag != 1 && budgetWarnFlag != 2 && proportionVal>warningrateVal){
    	budgetWarnFlag = 3;//�Ƿ�Ԥ���ʶλ 0��������1��Ԥ��Ϊ0,2��Ԥ�㳬��Ԥ��������3����Ԥ�㵫Ԥ�㲻��
    }
    //20170511 edited for Ԥ����� by mengly end
  }
}

/**
 * �Ƿ���÷ѱ���У�飨�ܲ����÷Ѳ��ܺ��������û챨���𿨲��÷ѳ��˿��Ժ�ҵ���д��ѻ챨�����ܺ��������û챨��
 */
function checkIstravel(){
  jQuery('#field' + <%=mMap.get("istripfee_c")%>).val('0');//
  var checkNodeList = document.getElementsByName('check_node_0');//ѡ����
  for (var i = 0; i < checkNodeList.length ; i++) {
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+i+'span').html();
    if (costType.indexOf('����') != -1) {
      jQuery('#field' + <%=mMap.get("istripfee_c")%>).val('1');
      break;
    }
  }
  if(jQuery('#field' + <%=mMap.get("istripfee_c")%>).val() == 1){
	  for(var i = 0; i < checkNodeList.length ; i++) {
	    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();
	    if(orgid.val() == 83){//�𿨲��÷ѳ��˿��Ժ�ҵ���д��ѻ챨�����ܺ��������û챨
	    	if(costType.indexOf('����˰��') != -1) {
          continue;
        }
  	    if((costType.indexOf('ҵ���д���') == -1) && (costType.indexOf('����') == -1)){
          return true;
        }
	    }else if(orgid.val() == 81){//�ܲ����÷Ѳ��ܺ��������û챨
	    	if(costType.indexOf('����˰��') != -1) {
          continue;
        }
  	    if(costType.indexOf('����') == -1){
          return true;
        }
	    }
	  }
  }
}

//���÷���������Ϊ��
function checktripdaycount(){
	var checkbox = document.getElementsByName('check_node_0');
	//���÷���������Ϊ��
	if(jQuery('#field' + <%=mMap.get("istripfee_c")%>).val() == 1){//�ǲ��÷ѱ���
	  for (var i = 0; i < checkbox.length; i++) {
	    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();
	    var daycount = jQuery('#field' + <%=mMap1.get("days")%> + '_' + i).val();
	    if(costType.indexOf('����˰��') != -1){//����˰��
	      continue;
	    }else if(daycount==''||daycount==null){
	      return true;
	    }
	  }      
	}
}

// �Ƿ�ҵ���д���/�����
function checkFeetype(){
  jQuery('#field' + <%=mMap.get("isbusinessexpense_c")%>).val('0');//
  var checkNodeList = document.getElementsByName('check_node_0');//ѡ����
  for (var i = 0; i < checkNodeList.length ; i++) {
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+i+'span').html();
    if(costType.indexOf('�����') != -1 || costType.indexOf('ҵ���д���') != -1){
      jQuery('#field' + <%=mMap.get("isbusinessexpense_c")%>).val('1');//
      break;
    }
  }
}
// xuenhua 20190603 ͳ�ƻ����
function sumHuiYiFee(){
	var huiyifei = 0;
  jQuery('#field' + <%=mMap.get("ishuiyifee")%>).val('��');//
  var checkNodeList = document.getElementsByName('check_node_0');//ѡ����
  for (var i = 0; i < checkNodeList.length ; i++) {
    var rowIndex = checkNodeList[i].value;
    //jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+rowIndex).html();
    var costType = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+rowIndex+'span').text();
		var currmoeny_str = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val(); //�������(��˰)
    if(costType.indexOf('�����') != -1){
			jQuery('#field' + <%=mMap.get("ishuiyifee")%>).val('��');//
			huiyifei=huiyifei+getFloat(currmoeny_str);
    }
  }
	return huiyifei;
}

//ɾ���������Ϊ�յĽ����
function deletePrementLine(){				
	var formId = '1';
	var contractdetail = document.getElementsByName('check_node_'+formId);
    for(var i=0;i<contractdetail.length;i++){	
	    var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
	    var checkFlag = document.getElementsByName('check_node_'+formId)[i].checked;		
	    var paidmoney = jQuery('#field' + <%=mMap2.get("paidmoney")%> + '_'+ rowIndex).val();		
		//��ѡ��Ȼ��ɾ��
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
  delRowFun_new(formId); //ɾ��ѡ����				
}				


//�ύǰ��֤���ӷ�Ʊ��
function checkElecNoOnSubmitBefore(){
  var expensedetail = document.getElementsByName('check_node_0');//������ϸ��
  var elecnos = new Array();
  for(var i = 0;i<expensedetail.length;i++){
    var elecno = jQuery('#field' + <%=mMap1.get("elecerporderno")%> + '_' + i).val();//��ȡ���ӷ�Ʊ��
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + i + 'span').html();//��ȡ��������
    if(feetypeName.indexOf('����˰��') != -1||elecno==null||elecno==''){//���Ե�˰�кͿյ��ӷ�Ʊ��
    	continue;
    }else{
      if(checkInvoiceNoExist(elecno)){//�ж��Ƿ������ݿ����ظ�
        return true;
      }
      elecnos.push(elecno);
    }
  }
  var elecnosSorted = elecnos.sort();
  for(var i=0;i<elecnosSorted.length-1;i++){
    if(elecnosSorted[i]==elecnosSorted[i+1]){
      alert('���������ظ����ӷ�Ʊ�ţ��ظ���Ϊ��' + elecnosSorted[i]);
      return true;
    }
  }
}

//��֤���ӷ�Ʊ�ظ�
function checkInvoiceNoExist(invoiceNo){
  var elec_flag = false;
  var dataElecNo = null;
  dataElecNo = getElecNo(invoiceNo,requestid);
  var length = dataElecNo.length;
  if(length>0){
    alert('���ӷ�Ʊ����ʹ�ù���' + dataElecNo[0].ELECERPORDERNO);
    elec_flag = true;
  }
  return elec_flag;
}

//��֤����
function checkNum2(obj){
  var reg = new RegExp('^[0-9]+(.[0-9]{1,2})?$');
  if(!reg.test(obj.value)){
    return true;
  }
  return false;
}

//���������У�����feetypeid��ͬ�Ľ���ܺ�
function getFeetypeMoney(segment4){
var money = 0.0;
var expensedetail = document.getElementsByName('check_node_0');//������ϸ��
	for(var i=0;i<expensedetail.length;i++){
	  var rowIndex = expensedetail[i].value; //��ȡ��ǰ�е�����
	  //20171012 modified BY mengly START
	  var segment4Temp = jQuery('#field' + <%=mMap1.get("segment4")%> + '_'+ rowIndex +'').val();//��ȡsegment4
	  <%--  
	  var feetypeid1 = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex +'').val();//��ȡ��������id
	  var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex +'span').text();//��ȡ��������id
	   --%>
	  //20171012 modified BY mengly END
	  var moneytext = jQuery('#field' + <%=mMap1.get("money")%> + '_'+ rowIndex +'').val();//��ȡ���
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

//�˻ػ򱣴�󣬱����г�ʼ��
function setLineDisplay(){
  var contractdetail = document.getElementsByName('check_node_0');//������ϸ��
  for(var i=0;i<contractdetail.length;i++){
    var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
    //20171209 modefied by ect jiaing start
    /* addRowDetail0(rowIndex); */
    addRowDetail0('0',rowIndex);
    //20171209 modefied by ect jiaing end
  }
}
// 20171209 added by ect jiajing start
function setLineDisplay7(){
      var contractdetail = document.getElementsByName('check_node_6');//������ϸ��
      for(var i=0;i<contractdetail.length;i++){
        var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
        //addRowDetail0(rowIndex);
        addRowinvoic('6',rowIndex);
      }
}
function setLineDisplay10(){
    var contractdetail = document.getElementsByName('check_node_9');//������ϸ��
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
      //addRowDetail0(rowIndex);
      addRowinvoic('9',rowIndex);
      addRowControl('9',rowIndex);//added by zuoxl for ���������������ϸ�����ӿ���
    }
}
//20171209 added by ect jiajing end
//20171219 added by ect jiajing start
function setLineDisplay8(){
    var contractdetail = document.getElementsByName('check_node_8');//������ϸ��
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
      //addRowDetail0(rowIndex);
      addRowinvoic('8',rowIndex);
      addRowControl('8',rowIndex);//added by zuoxl for ���������������ϸ�����ӿ���
    }
}
//20180320 added by zuoxl for �����������ͨ��ϸ�����ӿ��� begin 
function setLineControl7(){
    var contractdetail = document.getElementsByName('check_node_7');//������ϸ��
    for(var i=0;i<contractdetail.length;i++){
      var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
      addRowControl('7',rowIndex);//added by zuoxl for ���������������ϸ�����ӿ���
    }
}
//20180320 added by zuoxl for �����������ͨ��ϸ�����ӿ��� end 
// 20171219 added by ect jiajing end
//������ϸ��  ���п���
// 20171209 modefied by ect jiajing start
<%-- function addRowDetail0(setrowindex){
	  var ind1 = 1 * parseInt(document.getElementById("indexnum0").value)-1; //��ȡ��ǰ�е�����
	  if(setrowindex != null && setrowindex != ''){ 
		  ind1 = setrowindex; 
	  }
	  if(ind1<0){
	    return ;
	  }
    if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){//�������Ŀ����
      setNeedCheck(<%=mMap1.get("taskno")%> + '_' + ind1,true); //���������Ϊ����
      var projectNo = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val();
      setCol(<%=mMap1.get("projectno")%> + '_'+ind1, projectNo, true, projectNo);//������Ŀ��
      jQuery('#field' + <%=mMap1.get("taskno")%> + '_' + ind1 + '__').attr('readonly',true);//����Ų����Զ����
    }else{//����Ǹ�������
      setNeedCheck(<%=mMap1.get("taskno")%> + '_' + ind1,false); //���������Ϊֻ��
    }
    jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + ind1 + '__').attr('readonly',true);//�������Ͳ����Զ���� 
    jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + ind1 + '__').attr('readonly',true);//�����˲����Զ����
    var elecObj = jQuery('#field' + <%=mMap1.get("elecerporderno")%> + '_'+ ind1 +'');//���ӷ�Ʊ��
    elecObj.bind('change',function(){ 
      elecerporderno = jQuery(this).val();
      var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + ind1 + 'span').html();//��ȡ��������
      if(feetypeName.indexOf('����˰��') == -1){//���Ե�˰��
        checkInvoiceNoExist(elecerporderno);
      }
    });
    jQuery('#field' + <%=mMap1.get("money")%> + '_'+ ind1 +'').removeAttr('onblur');
    jQuery('#field' + <%=mMap1.get("money")%> + '_'+ ind1 +'').bind('blur',function(){ //��� �ֶε�onblur
      changeToThousands2(jQuery(this).attr('name'),2); 
      checkMoney(this);
      countDetailMoney(0, <%=mMap1.get("money")%>, <%=mMap.get("applytotalmoney")%>);
      countPayTotalMoney();//���㱨���ܽ��,�����ܽ��,�����ܽ��
    });
    var data = new Array();
    var dutydeptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val();
    data = getDutyDept(dutydeptNo,orgid.val());//���ϵ����β���
    if(data.length>0){
      setCol(<%=mMap1.get("dutydepartment")%> + '_'+ind1, jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(), true, data[0].DESCRIPTION);
    } else {
    	deptNameIsNull = true;
    }
    if(setrowindex==null||setrowindex==''){
	    data = getEmployeeName(employno,orgid.val(),dutydeptNo);//���ϵı����˺�������
	    if(data.length > 0){
	      setCol(<%=mMap1.get("payperson")%> + '_'+ind1, employno, true, data[0].LAST_NAME);
	      setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+ind1, data[0].LAST_NAME, false, '');
	    }
   }
} --%>
function addRowDetail0(formId,rownum){
    var rowIndex = rownum; 
    if(rowIndex == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum" + formId).value)-1; //��ȡ��ǰ�е�����       
    }
    if(rowIndex<0){
      return ;
    }
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
    var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //����˰�ı�
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).attr('readonly',true);  //����˰���ɱ༭
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).attr('readonly',true); //���ñ��ҽ��ɱ༭
    if(expensebill.val() == '2'){
		//20180827 added by zuoxl for ҵ���д��ѱ���ʱ�����ر����е�˰�� ˰�� ������˰���ֶ�  begin
    	  jQuery("#zd_taxrate").hide();//˰�ʲ���ʾ����
    	  jQuery("#zd_taxrate_1").hide();//˰�ʲ���ʾ����
          jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().hide();
    	  jQuery("#zd_taxamount").hide();//˰���ʾ����
    	  jQuery("#zd_taxamount_1").hide();//˰���ʾ����
          jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().hide();
		  setCol(<%=mMap1.get("taxmoney")%> + '_' + rowIndex,0,true,0);//����˰��ֵ
          setNeedCheck_cc( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,false);
    	  jQuery("#zd_notaxamount").hide();//������˰������
    	  jQuery("#zd_notaxamount_1").hide();//������˰������
          jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().hide();
    	  //20180827 added by zuoxl for ҵ���д��ѱ���ʱ�����ر����е�˰�� ˰�� 
        jQuery("#person_num1").show();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().show();
        jQuery("#person_num2").show();
        jQuery("#server_rank1").show();
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().show();
        jQuery("#server_rank2").show();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).attr('readonly',false); //�����д������ɱ༭       
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).attr('readonly',false); //�����д�����ɱ༭      
        if(orgid.val() == '251' || orgid.val() =='252' || orgid.val()=='253'){ //�Ĵ���˾
            setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,true); //�д���������
            setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,true); //�д��������
        }else{//������˾������
            setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,false); //�д�����������
            setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,false); //�д����𲻱���
        }       
    }else{      
        setNeedCheck( <%=mMap1.get("receptionperson")%> + '_' + rowIndex,false); //�д������Ǳ���
        setNeedCheck( <%=mMap1.get("receivelevel")%> + '_' + rowIndex,false); //�д�����Ǳ���
		//20180827 added by zuoxl for ҵ���д��ѱ���ʱ����ʾ�����е�˰�� ˰�� ������˰���ֶ�  begin
          jQuery("#zd_taxrate").show();//˰�ʲ���ʾ��ʾ
          jQuery("#zd_taxrate_1").show();//˰�ʲ���ʾ��ʾ
          jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().show();
          jQuery("#zd_taxamount").show();//˰���ʾ��ʾ
          jQuery("#zd_taxamount_1").show();//˰���ʾ��ʾ
          jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().show();
          setNeedCheck_cc( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true);
          jQuery("#zd_notaxamount").show();//������˰����ʾ
          jQuery("#zd_notaxamount_1").show();//������˰����ʾ
          jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().show();
          //20180827 added by zuoxl for ҵ���д��ѱ���ʱ����ʾ�����е�˰�� ˰�� 
        jQuery("#person_num1").hide();
        jQuery('#field' + <%=mMap1.get("receptionperson")%> + '_' + rowIndex).parent().hide();
        jQuery("#person_num2").hide();
        jQuery("#server_rank1").hide();
        jQuery('#field' + <%=mMap1.get("receivelevel")%> + '_' + rowIndex).parent().hide();
        jQuery("#server_rank2").hide();
    }
    <%-- jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex + '_').attr('readonly',true); //����˰��ֻ�� --%>
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex + '_').attr('readonly',true); //���ò���˰���ֻ��
  //��Ŀ������������ű�������������������ֻ��
  if(jQuery('#field' + <%=mMap.get("applytype")%>).val() == 1){//�������Ŀ����
    setNeedCheck(<%=mMap1.get("taskno")%> + '_' + rowIndex,true); //���������Ϊ����
    var projectNo = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val();
    setCol(<%=mMap1.get("projectno")%> + '_'+rowIndex, projectNo, true, projectNo);//������Ŀ��
    jQuery('#field' + <%=mMap1.get("taskno")%> + '_' + rowIndex + '__').attr('readonly',true);//����Ų����Զ����
    if(orgid.val() == '526'){
        setNeedCheck(<%=mMap1.get("cotrial")%> + '_' + rowIndex,true);//���á����÷��࡯����
        setNeedCheck(<%=mMap1.get("businesstype")%> + '_' + rowIndex,true);//���á�ҵ�����͡�����
        jQuery('#field' + <%=mMap1.get("cotrial")%> + '_' + rowIndex + '__').attr('readonly',true);//���÷��಻���Զ����
        jQuery('#field' + <%=mMap1.get("businesstype")%> + '_' + rowIndex + '__').attr('readonly',true);//ҵ�����Ͳ����Զ����
    }
  }else{//����Ǹ�������
    setNeedCheck(<%=mMap1.get("taskno")%> + '_' + rowIndex,false); //���������Ϊֻ��
    if(orgid.val() == '526'){
        setNeedCheck(<%=mMap1.get("cotrial")%> + '_' + rowIndex,false);//���á����÷��࡯ֻ��
        setNeedCheck(<%=mMap1.get("businesstype")%> + '_' + rowIndex,false);//���á�ҵ�����͡�ֻ��
    }
  }
  jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + '__').attr('readonly',true);//�������Ͳ����ֶ���д 
  jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + rowIndex + '__').attr('readonly',true);//�����˲����ֶ���д
  jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex +'').removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex +'').bind('change',function(){ //��� �ֶε�onblur
    changeToThousands2(jQuery(this).attr('name'),2);  //ת��Ϊ���ǧ��λ
    checkMoney(this);
    /* refreshmoney(); //������ */
    //��������ܽ�Ӧ������
    var checkboxArr = document.getElementsByName('check_node_1');//��ȡcheckbox����
    if(checkboxArr.length>0){//�����г���������ϸ
        for(var i=0; i<checkboxArr.length; i++){
          //��checkbox��ѡ�¼�
            jQuery('input[name="check_node_1"]').each(function(){
                var checkbox = jQuery(this).val();//��ǰָ��
                if(checkbox == i){
                    countRepayTotalMoney('#field' + <%=mMap2.get("paidmoney")%> + '_'+ checkbox +'');
                    countPayTotalMoney();   
                }
            });
        }
    }
    setCol(<%=mMap1.get("taxmoney")%>+ '_' + rowIndex,'',false,''); //���˰��
    setCol(<%=mMap1.get("money")%>+ '_' + rowIndex,'',false,''); //��ղ���˰���
    refreshmoney(); //������
	getTaxmoney();//˰�����
   <%--  var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val(); //��ȡ������˰
    var exchangerate = jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).val(); // ��ȡ����
    var localmoney = getFloat(currmoeny) * getFloat(exchangerate);
    setCol(<%=mMap1.get("localmoney")%> + '_'+ rowIndex,fmoney(localmoney),false,fmoney(localmoney)); // ��д���ҽ�� --%>
    
  });
  //20190505 added by raoanyu for ��˰��change�¼�
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).bind('change',function(){
  	  setCol(<%=mMap1.get("taxmoney")%>+ '_' + rowIndex,'',false,''); //���˰��
      setCol(<%=mMap1.get("money")%>+ '_' + rowIndex,'',false,''); //��ղ���˰���
  	  getTaxmoney();//˰�����
  });
  //setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //˰�����
  setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,false); //����˰������
  jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex + '_').attr('readonly',true); //����˰���ֻ��
  
  //����˰�ʲ����ֶ���д
  jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex + '__').attr('readonly',true); //����˰�ʲ��ɱ༭
  jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
      jQuery(this).remove();
  });
  //��˰��onblur �¼�
  <%-- jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //˰�� �ֶε�onblur
      var taxrateval = jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex).val();
      if (taxrateval != null && taxrateval != ''){
          refreshmoney(); //������
      }   
  }); --%>
 //��˰��onblur �¼�
  jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).bind('change',function(){
      var moneyline1 = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();
      var taxmoneyline1 = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).val();  // ����˰���
      if(account_segment.val() != '21710101'){
          if (getFloat(taxmoneyline1) > getFloat(moneyline1)){
              alert('˰��ܴ��ڱ������');
              return;
          }
          var currmoenyline1 = getFloat(moneyline1) - getFloat(taxmoneyline1);
          setCol(<%=mMap1.get("money")%> + '_'+ rowIndex,fmoney(currmoenyline1),false,fmoney(currmoenyline1));
      }
      // add by sdaisino ��������ӡҳ���Ż� start
      var verform = document.getElementById("verform");
      if (verform) {
          var detailLine0 = document.getElementsByName('check_node_0');
	      var taxmoney = parseFloat(0);
	      for(var i = 0;i < detailLine0.length;i++){
	          var myIndex = detailLine0[i].value;
	          var taxText = jQuery('#field22369_'+ myIndex); //����˰�ı�
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
	  // add by sdaisino ��������ӡҳ���Ż� end
  }); 
  //�󶨻���onblur�¼�
  jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex).bind('blur',function(){
      refreshmoney(); //������
  });
  
  var currencyhead = jQuery('#field' + <%=mMap.get("currency")%>); //��ȡͷ��Ϣ����
  var currencyline = jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex); //��ȡͷ��Ϣ����
  if (currencyhead.val() == currencyline.val()){
      setCol(<%=mMap1.get("exchangerate")%> + '_' + rowIndex,1,false,1);//���û��ʳ���ֵ 
      jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',true); //���ʲ��ɱ༭
  }else{
      jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',false); //���ʲ��ɱ༭
  }
  //����onchagne�¼�
  jQuery('#field' + <%=mMap1.get("currency_text")%> + '_'+ rowIndex).removeAttr('onchange');
  jQuery('#field' + <%=mMap1.get("currency_text")%> + '_'+ rowIndex).bind('change',function(){ //˰�� �ֶε�onblur
      if (currencyhead.val() == currencyline.val()){
          setCol(<%=mMap1.get("exchangerate")%> + '_' + rowIndex,1,false,1);//���û��ʳ���ֵ 
          jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',true); //���ʲ��ɱ༭
      }else{
          jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).attr('readonly',false); //���ʲ��ɱ༭
      }
  });
  var data = new Array();
  var dutydeptNo = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val();
  if(rownum=='no'){
      data = getEmployeeName(employno,orgid.val(),dutydeptNo);//���ϵ������˺�ʹ����
      if(data.length > 0){
        setCol(<%=mMap1.get("payperson")%> + '_'+rowIndex, employno, true, data[0].LAST_NAME);
        setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+rowIndex, data[0].LAST_NAME, false, '');
      }           
  }
  
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex +'_browserbtn').hide();   //�������벿�Ų�ѯ��ť
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex +'__' ).attr('readonly',true); //���������˲���ֻ��
  jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
      jQuery(this).remove();
  });
  
  //������������
  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).removeAttr('onblur');
  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).bind('blur',function(){  //�������ı�
      var payperson_text =  jQuery('#field' + <%=mMap1.get("payperson_text")%> + '_'+ rowIndex).val();
      var applyperson = jQuery('#field' + <%=mMap1.get("payperson")%> + '_' + rowIndex).val();
      var applydepthead = jQuery('#field' + <%=mMap1.get("applydept")%> + '_' + rowIndex).val(); //�����˲���id
      var applydept; //���벿��
      var dutypersonmemo; //ʹ����
      var dutydepartment; //���óе�����
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
                    applydept = json.map.ID;            // ���벿��
                    dutypersonmemo = json.map.LASTNAME; //ʹ����
                    dutydepartment = json.map.SEGMENT2; // �����˲���
                    applydeptName = json.map.DEPARTMENTNAME; //�����˲�������
                }
              },
              error: function (){
                alert('error...');
              }
         });
         
         setCol(<%=mMap1.get("applydept")%> + '_'+rowIndex, applydept, true, applydeptName);  //�����˲���           
         setCol(<%=mMap1.get("dutypersonmemo")%> + '_'+rowIndex, dutypersonmemo, false, dutypersonmemo);  // ʹ����          
        <%--  if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97'){
             jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').hide();  //���ط��óе����Ų�ѯ��ť
             jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',true); //���÷��óе�����ֻ��
             setCol(<%=mMap1.get("dutydepartment")%> + '_'+rowIndex, erp_detpno, true, erp_deptname); //���óе�����
         }else{
             setNeedCheck( <%=mMap1.get("dutydepartment")%> + '_' + rowIndex,true); //���� �е����ű���
         } --%>           
      }
  });
  //���þ����˲�����ʾ/����
  if(orgid.val() == '81' || orgid.val() == '83' || orgid.val() == '97' || orgid.val() == '662'|| orgid.val() == '723'){
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').hide();  //���ط��óе����Ų�ѯ��ť
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',true); //���÷��óе�����ֻ��
  }else{
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'_browserbtn').show();  //��ʾ���óе����Ų�ѯ��ť
      jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_' + rowIndex +'__' ).attr('readonly',false); //���÷��óе����ŷ�ֻ��
      setNeedCheck( <%=mMap1.get("dutydepartment")%> + '_' + rowIndex,true); //���� �е����ű���
  }
  <%-- var applydeptheadId = jQuery('#field' + <%=mMap.get("applydept")%>).val(); //�����˲���id
  var deptseg_c = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //���Ŷ�
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
            departmentcode = json.map.DEPARTMENTCODE; //���óе�����code
            departmentname = json.map.DEPARTMENTNAME; //���óе���������
        }
      },
      error: function (){
        alert('error...');
      }
 }); --%>
  if(rownum == 'no'){
	  var data = new Array(); 
	  var deptseg_c = jQuery('#field' + <%=mMap.get("deptseg_c")%>).val(); //���Ŷ�
      var deptSegment = splitString(deptseg_c,'-',0);
      data = getDutyDept(deptSegment,orgid.val());//���ϵ����β���
      if(data.length>0){
    	  setCol(<%=mMap1.get("dutydepartment")%> + '_'+rowIndex, deptSegment, true, data[0].DESCRIPTION); //���óе����� 
      }      
  }
 //�󶨿�Ŀ���ı�
 jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).removeAttr('onblur');
 jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex).bind('blur',function(){
     
     if(account_segment.val() == '21710101'){ //����˰
       //��ճ�ʼ����Ŀ
          //20190218 added by sdaisino  for ���ɽ���˰��  begin
          if (!jxsFlg) {
              setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex, '', true, '');  //���˰��
          }
          //20190218 added by sdaisino for ���ɽ���˰��  end
          setCol(<%=mMap1.get("currency")%> + '_'+rowIndex, '', true, '');  //��ձ���
          setCol(<%=mMap1.get("exchangerate")%> + '_'+rowIndex, '', true, '');  //��ջ���
          setCol(<%=mMap1.get("localmoney")%> + '_'+rowIndex, '', true, '');  //��ձ��ҽ��
          //20180110 modefied by ect qiwf start
          // setCol(<%=mMap1.get("invoicecount")%> + '_'+rowIndex, '', true, '');  //��ո�������
          // setCol(<%=mMap1.get("feeinstruction")%> + '_'+rowIndex, '', true, '');  //���˵��
          jQuery('#field' + <%=mMap1.get("invoicecount")%>).val('');	//��ո�������
          jQuery('#field' + <%=mMap1.get("feeinstruction")%>).val(''); //���˵��
          //20180110 modefied by ect qiwf end
          setCol(<%=mMap1.get("money")%> + '_'+rowIndex, '', true, '');  //����˰���
          inputtaxhide(rowIndex); //���ý���˰����Ŀ����
     }else{
          //��ʼ����Ŀ
          //20190218 added by sdaisino  for ���ɽ���˰��  begin
          if (!jxsFlg) {
              setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex, '', true, '');  //���˰��
          }
          //20190218 added by sdaisino for ���ɽ���˰��  end
          setCol(<%=mMap1.get("currency")%> + '_'+rowIndex, 'CNY', true, 'CNY');  //����
          setCol(<%=mMap1.get("exchangerate")%> + '_'+rowIndex, 1, false, 1);  //����
          //20180110 modefied by ect qiwf start
          // setCol(<%=mMap1.get("invoicecount")%> + '_'+rowIndex, '', true, '');  //��ո�������
          // setCol(<%=mMap1.get("feeinstruction")%> + '_'+rowIndex, '', true, '');  //���˵��
          jQuery('#field' + <%=mMap1.get("invoicecount")%>).val('');	//��ո�������
          jQuery('#field' + <%=mMap1.get("feeinstruction")%>).val(''); //���˵��
          //20180110 modefied by ect qiwf end
          setCol(<%=mMap1.get("money")%> + '_'+rowIndex, '', true, '');  //����˰���
          inputtaxshow(rowIndex);
     }
 });
 if(account_segment.val() == '21710101'){//����˰
	 inputtaxhide(rowIndex); //���ý���˰����Ŀ����
 }
}
//20171209 modefied by ect jiajing end

//��Ŀ���,��Ŀ�������Ŀ��ر���Ŀ����ʾ����,�Լ�����Ŀ��ص�flag�ֶ�����
function setProjectContentDisplay(expensetypeSelect){
   if(expensetypeSelect.val() == 1){ //��Ŀ����
     jQuery('#field' + <%=mMap.get("isproject_c")%>).val('Y');//�趨���Ƿ���Ŀ���ֶ�
     jQuery("#projectNo").show(); //��ʾ��Ŀ��Ϣ
     jQuery("#projectManager").show();//��ʾ��Ŀ��Ϣ
     setNeedCheck(<%=mMap.get("projectno")%>,true);//���á���Ŀ��š�����
   } else if(expensetypeSelect.val() == 0){//��������
     jQuery('#field' + <%=mMap.get("isproject_c")%>).val('N');//�趨���Ƿ���Ŀ���ֶ�
     jQuery("#projectNo").hide();//������Ŀ��Ϣ
     jQuery("#projectManager").hide();//������Ŀ��Ϣ
     jQuery('#field' + <%=mMap.get("projectno")%>).val('');//��Ŀ���
     jQuery('#field' + <%=mMap.get("projectname")%>).val('');//��Ŀ����
     jQuery('#field' + <%=mMap.get("projectmanager")%>).val('');//��Ŀ����
     jQuery('#field' + <%=mMap.get("glprojectcode")%>).val('');//Ԥ����Ŀ����
     setNeedCheck(<%=mMap.get("projectno")%>,false);//���á���Ŀ��š��Ǳ���
   }
}

//У����
function checkMoney(obj){
   if(jQuery(obj).val()!='' && jQuery(obj).val()!= null){
      jQuery(obj).val(fmoney(jQuery(obj).val()));
      if(checkNum2(obj)){
   	     alert('������Ϊ���֣��Ҳ���Ϊ����');
   	     jQuery(obj).val('');
   	  }
   }
}

/**
 * ����ERP��ť�¼�
 */
function importERPOuter(){
   var invoiceNum = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();
   if(invoiceNum!=null && invoiceNum != ''){
	     alert('�Ѿ������erpϵͳ�������ظ����룡');
     return;
   }else{
     importERP();
   }
}

/**
 * ����ERP
 */
function importERP(){
	var gldate = jQuery('#field' + <%=mMap.get("billingdate")%>).val();
	var pEmployeeNo = null;
  var userInfo = getUserInfo(currentUserId);
  pEmployeeNo = userInfo.map.WORKCODE;//Ա�����
	// ����erp
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
      	alert('����ɹ�');
      	location.reload();
      }
    },
    error: function (){
      alert('����ʧ��');
    }
  }); 
}

/*�տ�����ϸ��ť��ת �߼����ύ����   author�������  begin*/
function payShare(){
	if(requestid == -1){
		alert('���ȱ�����ڽ��б༭�տ�����ϸ');
		return false;
	}
	//20180110 add by ect qiwf start
    //�ж��Ƿ���Ҫ��д�տ�����ϸ
    var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val(); //�����ܽ��
    if(getFloat(paytotalmoney) <= 0){
    	alert('�����ܽ��Ϊ"0",������д�տ�����ϸ!');
        return false;
    }   
    //20180110 add by ect qiwf end
	var orgid1 = jQuery('#field' + <%=mMap.get("applycompany")%>).val();
	var totalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	//http://10.121.1.92/formmode/view/AddFormMode.jsp?modeId=1&formId=-10&type=1
	//window.location.href = '/formmode/view/AddFormMode.jsp?modeId=1&#38;formId=-10&#38;type=1&requestid=' + requestid + '&orgid='+ orgid1 +'&totalmoney='+ totalmoney +'';
    var billid = 0;
	  // ��ѯ�Ƿ�����տ�����ϸ
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
	      alert('��ѯ�տ�����ϸid�쳣');
	      return false;
	    }
	  });
	  if(billid == 0){
		  window.open('/formmode/view/AddFormMode.jsp?modeId=1&formId=-6&type=1&requestid=' + requestid + '&orgid='+ orgid1 +'&totalmoney='+ totalmoney +'');	  
	  }else{
		  updatePayHeader(billid,totalmoney);//�޸ķ�̯ͷ���
		  window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=1&formId=-6&type=0&billid='+ billid +'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');	  
	  }
}
function selectShare(){
	var data = new Array();
	 // ��ѯ�Ƿ�༭���տ�����ϸ
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
	      alert('��ѯ�տ�����ϸid����');
	    }
	  });
	if(data.length > 0){
		onShowBrowser2('',
		  		  '/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.selectPayShare','','','');
  	}else{
  		alert('���տ�����ϸ�������Բ鿴');
  		return false;
  	}
	//window.open('/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.selectPayShare');
}

//��ȡ��̯ͷ״̬
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
	      alert('��ѯ�տ�����ϸͷ״̬����');
	    }
	  });
	if(data.length > 0){
		if(data[0].HEADERSTATUS != '�ɹ�'){
			return true;
		}
	}
}
//��֤��̯����Ƿ���ȷ
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
	      alert('��ѯ�տ�����ϸ��Ϣ����');
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
	      alert('�����տ�����ϸͷ������');
	    }
	  });
}
/*�տ�����ϸ��ť��ת �߼����ύ����   author�������  end*/


//�������Ƿ���ĳ��������
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



//�����з��������ļ�¼
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


//���β����Ƿ�Ϊ�� 
function isLineDeptNull(){
	var isLineDeptNullFlag = false;
	var expensedetail = document.getElementsByName('check_node_0');//������ϸ��
	for(var i=0;i<expensedetail.length;i++){
	  var rowIndex = expensedetail[i].value; //��ȡ��ǰ�е�����
	  var dutydept = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ rowIndex).val();//���β��� 
	  if(dutydept == '' || dutydept == null){
		  isLineDeptNullFlag = true;
	  }
	}
	return isLineDeptNullFlag;
}

//��ȡ���ñ����ķ������
function getApExpenseSegment(){
  var expenseType = jQuery('#field' + <%=mMap.get("applytype")%>);//��������
  var projectid = jQuery('#field' + <%=mMap.get("projectno")%>);//����ͷ��Ϣ����Ŀ���
  var projectno = jQuery('#field' + <%=mMap.get("projectnocode_c")%>).val(); //ҵ����Ŀ��
  var seg1 = jQuery('#field' + <%=mMap.get("compseg_c")%>).val();
  jQuery('input[name="check_node_0"]').each(function(){
    var checkbox = jQuery(this).val();
    var departmentCode = jQuery('#field' + <%=mMap1.get("dutydepartment")%> + '_'+ checkbox +'').val();
    var employeeNumber = jQuery('#field' + <%=mMap1.get("payperson")%> + '_'+ checkbox +'').val();
    var parameterId = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'').val();
    //segment1
    //��ȡ��˾��
    jQuery('#field' + <%=mMap1.get("segment1")%> + '_'+ checkbox +'').val(seg1);
    //segment2
    //��ȡ���Ŷ�
    jQuery('#field' + <%=mMap1.get("segment2")%> + '_'+ checkbox +'').val(departmentCode);
    //������Ϊ����˰��
    var feetypeName = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ checkbox +'span').text();
    if(feetypeName.indexOf('����˰��') != -1) {
      //segment3
      //��ȡ��Ŀ��
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
      //��ȡ��Ŀ��
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
    }else{//�����зǽ���˰��

      //segment3
      //��ȡ��Ŀ��
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
      //��ȡ��Ŀ��
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
      //��ȡ��Ŀ��
      //������Ŀ��Ӧ��segment6
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
        //�����������
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
//��֤�������Ƿ�������Ƿ���ͬһ������
function checkemploy(){
	var flag = true;
	//��֤���������Ƿ�������Ƿ���ͬһ������
	var contractdetail = document.getElementsByName('check_node_0');//������ϸ��
	for(var i=0;i<contractdetail.length;i++){
		var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
		var employno = jQuery('#field'+ <%=mMap1.get("payperson")%> + '_' + rowIndex).val();
		var deptno = jQuery('#field'+ <%=mMap1.get("dutydepartment")%> + '_' + rowIndex).val();
		var data = getEmployeeName(employno,orgid.val(),deptno);// ���ϵ�������
		if(data.length == 0){
			linecount = parseInt(rowIndex) + 1;
		  flag = false;
		  break;
		}
  }
	return flag;
}
//20170706 ADDED BY WANGWW STAR
//����Ԥ�����ĿԤ��
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
//�ж��Ƿ���Ҫҵ���ż��
function getBusinessType(){
	//alert(123);
	setCol(<%=mMap.get("business_type_monitor")%>,'0',false,'0');//Ϊ�Ƿ�ר����б�ʶ
	//������Ŀ��id
	var checknode0 = document.getElementsByName('check_node_0'); //��ñ��������У�����
	for(var i = 0; i < checknode0.length; i++){
		//alert(123);
		var rowindex = checknode0[i].value;
		var project_number = jQuery('#field'+ <%=mMap1.get("segment6")%> + '_' + rowindex).val();
		var name = '';//ͳ�Ƶ�ǰ���в�����Ŀ���Ƿ���� ���ⲿ�ż�ر��
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
		//���ģ�����������ƣ�����Ҫҵ�񲿼��
		if(typeof(name) != 'undefined'){//�жϲ�ѯ�����������
			if(name.indexOf('(ר��)') != -1){
				setCol(<%=mMap.get("business_type_monitor")%>,'1',false,'1');
				break;
			}
		}	
	}
}
//modifer : fengjl20170630--end
// 20171209 added by ect jiajing start
//����ͷ��Ϣ����������������ϸ�е���������ʾ
function expensebillShow(expensebill){
    if((expensebill.val() == '0') || (expensebill.val() == '2') || (expensebill.val() == '3')){   //ͨ�ñ�����
        jQuery("#tab_3").hide();  // ���ؽ�ͨ��tabҳ
        jQuery("#tab_4").hide();  // ����ס�޷�tabҳ
        jQuery("#tab_5").hide();  // ���ز�������������tabҳ
    }else if(expensebill.val() == '1'){
        jQuery("#tab_3").show();  // ���ؽ�ͨ��tabҳ
        jQuery("#tab_4").show();  // ����ס�޷�tabҳ
        jQuery("#tab_5").show();  // ���ز�������������tabҳ
    }
	//201800827 added by zuoxl for ������ϸ��˰�ʡ�˰�������˰���ֶ���ʾ������ begin
	var contractdetail = document.getElementsByName('check_node_0');//������ϸ��
	if(expensebill.val() == '2'){
		jQuery("#zd_taxrate").hide();//˰�ʲ���ʾ����
		jQuery("#zd_taxrate_1").hide();//˰�ʲ���ʾ����
		jQuery("#zd_taxamount").hide();//˰���ʾ����
		jQuery("#zd_taxamount_1").hide();//˰���ʾ����
		jQuery("#zd_notaxamount").hide();//������˰������
		jQuery("#zd_notaxamount_1").hide();//������˰������
		for(var i=0;i<contractdetail.length;i++){
			var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
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
			var rowIndex = contractdetail[i].value; //��ȡ��ǰ�е�����
			jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex).parent().show();
			jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).parent().show();
			jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).parent().show();
		}
	}
	//201800827 added by zuoxl for ������ϸ��˰�ʡ�˰�������˰���ֶ���ʾ������ end
}

//��ȡ�������ֻ���
function get_applytel(applyperson){
    var tel = '';
    var telephone = ''; //�绰��
    var mobile = '';    //�ֻ���
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
//��ϸ�н��
function refreshmoney(){
    setCol(<%=mMap.get("huiyifei_currmony")%>,0,false,0); //����ѽ��
    setCol(<%=mMap.get("applytotalmoney")%>,0,false,0); //�����ܽ��
    <%-- setCol(<%=mMap.get("reversaltotalmoney")%>,0,false,0); //�����ܽ�� --%>
    setCol(<%=mMap.get("paytotalmoney")%>,0,false,0); //�����ܽ��
    var moneyline1 = 0; //��ϸ���ܽ��
    var applytotalmoney = 0; // ͷ��Ϣ�ܽ��
    var localmoney = 0; //���ҽ��
    var arrApplyLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrApplyLine.length; k++){
        var rowIndex = arrApplyLine[k].value;
        moneyline1 = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex);      //�������(��˰)
        var exchangerate = jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_'+ rowIndex); // ��ȡ���ʶ���
        var taxrateline1 = jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex);  //˰��
        var taxrateval = getFloat(gettaxprice(taxrateline1.val())) * 0.01; //��ȡ˰��ֵ
        //������ϸ�к�˰���
        <%-- var taxmoneyval = (getFloat(moneyline1.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //���㱨����ϸ��˰��
        setCol(<%=mMap1.get("taxmoney")%> + '_'+rowIndex,fmoney(taxmoneyval),false,fmoney(taxmoneyval)); //��ҳ���д˰�� --%>
        //������ϸ�в���˰���
       <%--  var currmoenyline1 = getFloat(moneyline1.val()) - getFloat(taxmoneyline.val()); // ���㱨���в���˰���
        setCol(<%=mMap1.get("money")%> + '_'+rowIndex,fmoney(currmoenyline1),false,fmoney(currmoenyline1)); //��ҳ���д����˰���  --%>
        
        localmoney = getFloat(moneyline1.val()) * getFloat(exchangerate.val()); //���㱾�ҽ��
        setCol(<%=mMap1.get("localmoney")%> + '_'+ rowIndex,fmoney(localmoney),false,fmoney(localmoney)); // ��д���ҽ��
        
        applytotalmoney = getFloat(applytotalmoney) + getFloat(localmoney);  //����ͷ��Ϣ�ܽ��
    }
    setCol(<%=mMap.get("applytotalmoney")%>,fmoney(applytotalmoney),false,fmoney(applytotalmoney)); //��дͷ��Ϣ�ܽ��
    countPayTotalMoney();
}
//ͨ����ֵת��float��
function getFloat(val){
   if(val=='' || val == null){
       val = 0;
   }
   return parseFloat(val);
}
//��ȡ˰��ֵ
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

//���ز�����������ϸ��Ϣ
function addRowinvoic(formId,rownum){
    var rowIndex = rownum;
    if(rownum == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum"+formId).value)-1; //��ȡ��ǰ�е�����       
    }
    if(rowIndex<0){
        return ;
    }
    if (formId == '9'){
        <%-- jQuery('#field' + <%=mMap10.get("invoicemoney")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap10.get("invoicemoney")%> + '_'+ rowIndex).bind('blur',function(){
            frestaxrate('9');           
        }); --%>
        jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex + '__').attr('readonly',true); //����˰�ʲ��ɱ༭
        jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
            jQuery(this).remove();
        });
        <%-- jQuery('#field' + <%=mMap10.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap10.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //˰�� �ֶε�onblur
            var taxrateval = jQuery('#field' + <%=mMap10.get("taxrate")%> + '_'+ rowIndex).val();
            if (taxrateval != null && taxrateval != ''){
                frestaxrate('9'); //������
            }   
        }); --%>
        //20171219 added by ect jiajing start
        //�󶨲�����׼onblur�¼�
        jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).bind('change',function(){
        	var allowance = jQuery('#field' + <%=mMap10.get("allowance")%> + '_'+ rowIndex).val();
        	if(isNaN(allowance)){
        		alert('������׼����������');
        		return;
        	}
        });
        //20171219 added by ect jiajing end
    }else if(formId == '6'){//��ֵ˰רƱ��Ϣ
        jQuery('#field' + <%=mMap7.get("money")%> + '_'+ rowIndex).attr('readonly',true);// ˰����ֻ��
        
        //�󶨷�Ʊ���
        jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).bind('change',function(){
            setCol(<%=mMap7.get("taxmoney")%> + '_' +rowIndex ,'',false,''); //���˰��
            setCol(<%=mMap7.get("money")%> + '_' +rowIndex ,'',false,'');    //��ղ���˰���
            frestaxrate('6');          
        });
        //����˰�ʲ����ֶ�����
        jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex + '__').attr('readonly',true); //����˰�ʲ��ɱ༭
        jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex+'span').find("[class='e8_delClass']", "span").each(function() {
            jQuery(this).remove();
        });
        <%-- //��˰��
        jQuery('#field' + <%=mMap7.get("taxrate_text")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap7.get("taxrate_text")%> + '_'+ rowIndex).bind('blur',function(){ //˰�� �ֶε�onblur
            var taxrateval = jQuery('#field' + <%=mMap7.get("taxrate")%> + '_'+ rowIndex).val();
            if (taxrateval != null && taxrateval != ''){
                frestaxrate('6'); //������
            }   
        }); --%>
        //����ֵ˰רƱ��Ϣ
        jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).removeAttr('onblur');
        jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).bind('blur',function(){ //˰�� �ֶε�onblur
            var currmoneyval = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+ rowIndex).val(); //��Ʊ���
            var taxmoneyval = jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_'+ rowIndex).val();  //˰��
            if(getFloat(taxmoneyval) > getFloat(currmoneyval)){
                alert('��ֵ˰���ܴ��ڷ�Ʊ���');
                return;
            }
            var money = getFloat(currmoneyval) - getFloat(taxmoneyval);
            setCol(<%=mMap7.get("money")%> + '_'+ rowIndex,fmoney(money),false,fmoney(money)); //��д˰����              
        });
        
        //�󶨷�Ʊ��onchange�¼�
        jQuery('#field' + <%=mMap7.get("invoicetype")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("invoicetype")%> + '_'+ rowIndex).bind('change',function(){
            setCol(<%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex,'',false,''); //��շ�Ʊ����
            setCol(<%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex,'',false,''); //��շ�Ʊ����
        });
        //�󶨷�Ʊ����onblur�¼�
        jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).bind('change',function(){
            var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_'+ rowIndex).val();
            if(dinvoicenum.length != 8){
                alert('��Ʊ����������8λ����');
                return;
            }
        });
      //�󶨷�Ʊ����onblur�¼�
        jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_'+ rowIndex).bind('change',function(){
            var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //��Ʊ����
            if(dinvoiceno.length != 10 && dinvoiceno.length != 12){
                alert('��Ʊ����Ϊ10λ��12λ����');
                return;
            }
        });
    }
    //20171219 added by ect jiajing start
    else if(formId == '8'){ //��ס�޷���ϸ��Ϣ  	
        //�󶨲�����׼onblur�¼�
        jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).removeAttr('onchange');
        jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).bind('change',function(){
            var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_'+ rowIndex).val();
            if(isNaN(expensestandard)){
                alert('ס�ޱ�׼����������');
                return;
            }
        });
    }
    //20171219 added by ect jiajing end
}
//������������ϸ��Ϣ��ϸ�н�����
function frestaxrate(formId){
    //������������ϸ��Ϣ
    var arrDetailLine = document.getElementsByName('check_node_'+formId);
       
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        if (formId == '9') {
            <%-- var moneyline10 = jQuery('#field'+<%=mMap10.get("invoicemoney")%> +'_'+rowIndex);  //��Ʊ���obj
            var taxrateline10 = jQuery('#field' + <%=mMap10.get("taxrate")%> + '_' + rowIndex);  //˰��
            //˰��
            var taxrateval = getFloat(gettaxprice(taxrateline10.val())) * 0.01; //��ȡ˰��ֵ
           //������ϸ�к�˰���
           var taxmoneyval = (getFloat(moneyline10.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //���㱨����ϸ��˰��
            setCol(<%=mMap10.get("taxmoney")%> + '_' +rowIndex ,fmoney(taxmoneyval),false,fmoney(taxmoneyval)); --%>
        }else if(formId == '6'){
            var currmoneyline7 = jQuery('#field'+<%=mMap7.get("currmoney")%> +'_'+rowIndex); //��Ʊ���Obj
            
            <%-- var taxrateline7 = jQuery('#field' + <%=mMap7.get("taxrate")%> + '_' + rowIndex);  //˰��
                    
            //˰��
            var taxrateval = getFloat(gettaxprice(taxrateline7.val())) * 0.01; //��ȡ˰��ֵ
            //������ϸ�к�˰���
            var taxmoneyval = (getFloat(currmoneyline7.val()) /(1+ getFloat(taxrateval))) * getFloat(taxrateval); //���㱨����ϸ��˰��
            setCol(<%=mMap7.get("taxmoney")%> + '_' +rowIndex ,fmoney(taxmoneyval),false,fmoney(taxmoneyval));
            //���㲻��˰���
            var moneyval = getFloat(currmoneyline7.val()) - getFloat(taxmoneyval);
            setCol(<%=mMap7.get("money")%> + '_' +rowIndex ,fmoney(moneyval),false,fmoney(moneyval)); --%>
        
        }
        
    }
}
//�󶨷�Ʊ����onchange�¼�
<%-- function invoicetypechagne(){
    var invoicetype = jQuery('#field' + <%=mMap.get("invoicetype")%>);  //��Ʊ����
    //�󶨷�Ʊ����onchange�¼�
    invoicetype.removeAttr('onchange');      //�Ƴ�onchange�¼�
    invoicetype.bind('change', function(){ //��onchange�¼�
        if(invoicetype.val() =='0'){
            jQuery("#tab_6").show();  // ������ֵ˰רƱtabҳ
        }else{
            jQuery("#tab_6").hide();  // ��ʾ��ֵ˰רƱtabҳ
        }
        clearForm(6);
        jQuery("#tab_2").click();
    });
} --%>

//��֤�������ֻ����Ƿ�Ϊ��
function istelnull(){
    var returnflag = true;
    //�������ֻ��Ų���Ϊ��
    var telphone = jQuery('#field' + <%=mMap.get("tel")%>);
    if (telphone.val() == '' || telphone.val() == null){
        returnflag = false;
    }
    return returnflag;
}
function isapplycompanynull(){
    var returnflag = true;
    var applycompany = jQuery('#field' + <%=mMap.get("applycompany")%>);//���빫˾
    if(applycompany.val() == '' || applycompany.val() == null){
        returnflag = false;
    }
    return returnflag;
}

// ��֤���벿���Ƿ�Ϊ��
function isdeptnull(){
    var returnflag = true;
    var arrDetailLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        //��֤�����˲���
        var applydept = jQuery('#field' + <%=mMap1.get("applydept")%> + '_'+rowIndex);
        if (applydept.val() == '' || applydept == null){                
            returnflag = false;
        }
    }          
    return returnflag;
}

//���У��
function totalmoneyCheck(){
    var returnflag = true;
    var carfare = 0;     //��ͨ��
    var stayfare = 0;    //ס�޷�
    var invoicefare = 0; // ��������
    var totalmoney = 0;  //�ܽ��
    var expensebill = jQuery('#field'+<%=mMap.get("expense_bill_type")%>).val();
    if(expensebill == '1'){
        var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val(); // ͷ��Ϣ�ܼ�
        //��ȡ��ͨ��
        var arrDetailLine8 = document.getElementsByName('check_node_7');
        if (arrDetailLine8.length > 0){
            for(var k = 0; k < arrDetailLine8.length; k++){
                var rowIndex = arrDetailLine8[k].value;
                var travelexpense = jQuery('#field' + <%=mMap8.get("travelexpense")%> + '_'+rowIndex);
                carfare = getFloat(carfare) + getFloat(travelexpense.val());
            }
        }
        //��ȡס�޷�
        var arrDetailLine9 = document.getElementsByName('check_node_8');
        if (arrDetailLine9.length > 0){
            for(var k = 0; k < arrDetailLine9.length; k++){
                var rowIndex = arrDetailLine9[k].value;
                var hotelexpense = jQuery('#field' + <%=mMap9.get("hotelexpense")%> + '_'+rowIndex);
                stayfare = getFloat(stayfare) + getFloat(hotelexpense.val());
            }
        }
        //��ȡ��������
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
<%-- //����������Ϊ���÷ѱ���ʱ��������ϸֻ��ѡ������������ı���
function istravel(){
    var retrunflag = true;
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //����������
    if(expensebill == '1'){ //����������Ϊ���÷ѱ�����
        var arrDetailLine = document.getElementsByName('check_node_0');
        for(var k = 0; k < arrDetailLine.length; k++){
            var rowIndex = arrDetailLine[k].value;
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val(); // ������ϸ
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + 'span').html();
            
            if (feetypeval.indexOf('����') == -1) {
                retrunflag = false;
            }
        }

    }
    return retrunflag;
}
//��������Ϊҵ���д���ʱ��������ϸֻ��ѡ��ҵ���д��ѻ�����
function isbusiness(){
    var retrunflag = true;
    var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //����������
    if(expensebill == '2'){ //����������Ϊ���÷ѱ�����
        var arrDetailLine = document.getElementsByName('check_node_0');
        for(var k = 0; k < arrDetailLine.length; k++){
            var rowIndex = arrDetailLine[k].value;
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val(); // ������ϸ
            var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_' + rowIndex + 'span').html();
            
            if (feetypeval.indexOf('ҵ���д���') == -1 && feetypeval.indexOf('�����') == -1) {
                retrunflag = false;
            }
        }

    }
    return retrunflag;
} --%>

<%-- //��������Ϊ���÷ѱ���ʱ����ͨ������Ϣ��ס�޷�����Ϣ��������Ϣ������д
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
//������ϸ��˰��ܴ��ڱ������
function taxmoneyCheck(){
    var retrunflag = true;
    var arrDetailLine1 = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine1.length; k++){
        var rowIndex = arrDetailLine1[k].value;
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //����˰�ı�
        var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();
        var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_'+ rowIndex).val();  // ����˰���
        if(account_segment.val() != '21710101'){
            if (getFloat(taxmoney) > getFloat(currmoeny)){
                retrunflag = false;
            }
        }  
    }
    return retrunflag;
}
//��ֵ˰��Ʊ��ϸ����ֵ˰˰���ܴ��ڱ������
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
//��֤��������ϸ����뷢Ʊ����Ϣ����Ƿ����
<%-- function moneyEqualcheck(){
    var retrunflag = true;
    var currmoney = 0;//��Ʊ���
    var totalcurrmoney = 0; //��Ʊ�ܽ��
    var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();  //ͷ��Ϣ�ܽ��
    var arrDetailLine7 = document.getElementsByName('check_node_6');  //��ָ˰רƱ��Ϣ
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        currmoney = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_'+rowIndex).val();
        totalcurrmoney = getFloat(totalcurrmoney) + getFloat(currmoney); //��Ʊ���ܽ��
    }
    
    //�жϷ�Ʊ���ܽ����ͷ��Ϣ�ܽ���Ƿ����
    if (getFloat(applytotalmoney) != getFloat(totalcurrmoney)){
        retrunflag = false;
    }
    return retrunflag;
} --%>

//��ȡ����ռ�ý��
function isunpaidmoney(invoiceid){
      var invoiceno = jQuery('#field' + <%=mMap.get("invoiceno")%>).val();  //��Ʊ��
      var applyperson = jQuery('#field' + <%=mMap.get("applyperson")%>).val(); //��ȡ������id
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
//��֤�տ�����ϸ�Ƿ���д
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
          alert('��ѯ�տ�����ϸid����');
        }
    });
    if(data.length == 0){
        returnflag = false;
    }
    return returnflag;
}
//У�齻ͨ����ϸ�е������ڱ�����ڿ�ʼ����
function checkArrivaldate(){
    var returnflag = true;
     var arrDetailLine8 = document.getElementsByName('check_node_7');
     for(var k = 0; k < arrDetailLine8.length; k++){
         var rowIndex = arrDetailLine8[k].value;
         var startdate = jQuery('#field' + <%=mMap8.get("startdate")%> + '_'+rowIndex).val();     // ��ʼ����
         var arrivaldate = jQuery('#field' + <%=mMap8.get("arrivaldate")%> + '_'+rowIndex).val(); // ��������
         if(startdate > arrivaldate){
             returnflag = false;
         }
     }
     return returnflag;
}
//У��ס����Ϣ��ϸ��ס����ס���ڲ��Ŵ����������
function checkOutdate(){
    var returnflag = true;
     var arrDetailLine9 = document.getElementsByName('check_node_8');
     for(var k = 0; k < arrDetailLine9.length; k++){
         var rowIndex = arrDetailLine9[k].value;
         var indate = jQuery('#field' + <%=mMap9.get("indate")%> + '_'+rowIndex).val();     // ��ס����
         var outdate = jQuery('#field' + <%=mMap9.get("outdate")%> + '_'+rowIndex).val(); // �������      
         if(indate > outdate){
             returnflag = false;
         }
     }
     return returnflag;
}
//��֤���óе����Ų���Ϊ��
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
//�����д��������д������Ƿ���ʾ
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

function checkInvoiceNoExist(){//��֤���ӷ�Ʊ���Ƿ��Ѿ�����
    var returnflag = true;
    var data = new Array();
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value; 
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //��Ʊ����
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val(); //��Ʊ����
        var dinvoicecode = dinvoiceno + dinvoicenum; //��ȡҳ�淢Ʊ��
        data = getdinvoicenumber(dinvoiceno,dinvoicenum);
        if(data.length > 0){
            for(var i=0; i<data.length; i++){
                if(requestid != data[i].REQUESTID || requestid==-1){
                    if(dinvoicecode == data[i].DINVOICECODE){
                    	var applyPerson = getUserInfo(data[i].APPLYPERSON).map.LASTNAME;
                    	var workFlowCode = data[i].WORKFLOWCODE;
                        alert('��'+(getFloat(rowIndex)+1)+'�з�Ʊ���ѱ�ʹ�ã���Ʊ����' + dinvoicenum+';��Ʊ����'+dinvoiceno+ ';���ݱ��' + workFlowCode + ';��Ա����' + applyPerson);
                        returnflag = false;
                    }
                }
            }
        }
        
    }
    return returnflag;  
}
function checkInvoiceNoExist2(){ //��֤��Ʊ����ͷ�Ʊ�����Ƿ���д�ظ�
    var returnflag = true;
    var data = new Array();
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //��Ʊ����
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val(); //��Ʊ����
        var dinvoicecode = dinvoiceno + dinvoicenum; //��ȡҳ�淢Ʊ��
        for(var j = rowIndex;j<(arrDetailLine7.length-1);j++){
            var num = getFloat(j)+1;
            var dinvoicenoNum = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + num).val(); //��Ʊ����
            var dinvoicenumNum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + num).val(); //��Ʊ����
            var dinvoicecodeNum = dinvoicenoNum + dinvoicenumNum; //��ȡҳ�淢Ʊ��
            if(dinvoicecode == dinvoicecodeNum){
                alert('��Ʊ��ϸ�е�'+(getFloat(rowIndex)+1)+'�����'+(getFloat(num)+1)+'�з�Ʊ���ظ�');
                returnflag = false;
            }
        }
    }
    return returnflag;
}
//У�鱨��������ϸ�н��
function checkmoney1(){
    var returnflag = true;
    var arrDetailLine1 = document.getElementsByName('check_node_0');
	for(var k = 0; k < arrDetailLine1.length; k++){
		var rowIndex = arrDetailLine1[k].value;
		var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //����˰�ı�
		var currmoney = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val(); //��˰���
		var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).val(); //˰��
		var money = jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).val().replace(',',''); //����˰���
		var totalmoney = getFloat(taxmoney) + getFloat(money);
		if(account_segment.val() != '21710101'){
			if(getFloat(currmoney).toFixed(2) != getFloat(totalmoney).toFixed(2)){
				alert('������ϸ��'+(getFloat(rowIndex)+1)+'�У�˰��򲻺�˰�����㲻��ȷ');
				returnflag = false;
			}
		}
	}
    return returnflag;
}
//У�鷢Ʊ��ϸ�н��
function checkmoney7(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var currmoney = jQuery('#field' + <%=mMap7.get("currmoney")%> + '_' + rowIndex).val(); //��˰���
        var taxmoney = jQuery('#field' + <%=mMap7.get("taxmoney")%> + '_' + rowIndex).val(); //˰��
        var money = jQuery('#field' + <%=mMap7.get("money")%> + '_' + rowIndex).val(); //����˰���
        var totalmoney = getFloat(taxmoney) + getFloat(money);
        if(getFloat(currmoney).toFixed(2) != getFloat(totalmoney).toFixed(2)){
            alert('��Ʊ��Ϣ��'+(getFloat(rowIndex)+1)+'�У���ֵ˰���򲻺�˰�����㲻��ȷ');
            returnflag = false;
        }
    }
    return returnflag;
}
//��֤��Ʊ���볤��
function checkdinvoicelength(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoicenum = jQuery('#field' + <%=mMap7.get("dinvoicenum")%> + '_' + rowIndex).val();  //��Ʊ����
        if(dinvoicenum.length != 8){
            alert('��'+(getFloat(rowIndex)+1)+'�з�Ʊ��ϸ����ȷ����Ʊ����������8λ����');
            returnflag = false;
        }
    }
    return returnflag;
}
//��֤��Ʊ���볤��
function checkdinvoicelength2(){
    var returnflag = true;
    var arrDetailLine7 = document.getElementsByName('check_node_6');
    for(var k = 0; k < arrDetailLine7.length; k++){
        var rowIndex = arrDetailLine7[k].value;
        var dinvoiceno = jQuery('#field' + <%=mMap7.get("dinvoiceno")%> + '_' + rowIndex).val(); //��Ʊ����
        if(dinvoiceno.length != 10 && dinvoiceno.length != 12){
            alert('��'+(getFloat(rowIndex)+1)+'�з�Ʊ��ϸ����ȷ����Ʊ����Ϊ10λ��12λ����');
            returnflag = false;
        }
    }
    return returnflag;
}
//���ý���˰����ϸ���ɱ༭
function inputtaxhide(rowIndex){
<% if("".equals(currentnodetype) || "0".equals(currentnodetype)){ %>
    // 20190614 added by sdaisino ����˰ʱ�����ʾ������start
    // ��ձ�������˰��
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).val('');
    // 20190614 added by sdaisino ����˰ʱ�����ʾ������end
    //������Ŀ�Ǳ���
    setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //˰�����
    setNeedCheck( <%=mMap1.get("currmoeny")%> + '_' + rowIndex,false); //��˰���Ǳ���
    setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,false); //����˰���Ǳ���
    setNeedCheck_2( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //˰�ʷǱ���
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,false); //���ַǱ���
    setNeedCheck( <%=mMap1.get("exchangerate")%> + '_' + rowIndex,false); //���ʷǱ���
    setNeedCheck( <%=mMap1.get("localmoney")%> + '_' + rowIndex,false); //���ҽ��Ǳ���
    
  //20171226 added by ect mayue start
    var taxmoneyspan = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex+'span').html();
    jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex+'span').html(taxmoneyspan + '<img src="/images/BacoError_wev8.gif" align="absmiddle">'); //���ϱ����ʶ
  //20171226 added by ect mayue end
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //���� �����������ʶ
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //���ػ��ʱ��� ��ʶ
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //���ر��ҽ����� ��ʶ
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex+'span').html('<img src="/images/BacoError_wev8.gif" align="absmiddle">').hide(); //���ز���˰������ ��ʶ 

    //������Ŀ����
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).hide(); //���غ�˰��� 
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).hide(); //���ز���˰���   
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex+'span').hide(); //ȥ�������ʶ
    //20180110 update by ect qiwf start
    //jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex +'_browserbtn').hide(); //����˰��browser
    //jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex +'_browserbtn').hide(); //���ر���browser 
    setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //˰�ʲ�����
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,false); //���ֲ�����
    //20180110 update by ect qiwf end    
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).hide(); //���ػ��� 
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).hide(); //���ر��ҽ�� 
<%} %>
}
function inputtaxshow(rowIndex){
	//20171226 added by ect mayue start
	 var expensebill = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
	 if(expensebill.val() == '2'){
		 setNeedCheck_2( <%=mMap1.get("taxrate")%> + '_' + rowIndex,false); //˰�ʷǱ��� 
	 }else{
		 setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,true); //˰�ʱ���
	 }
	//20171226 added by ect mayue end
    //������Ŀ�Ǳ���
    setNeedCheck( <%=mMap1.get("taxmoney")%> + '_' + rowIndex,true); //˰�����
    setNeedCheck( <%=mMap1.get("currmoeny")%> + '_' + rowIndex,true); //��˰������
    setNeedCheck( <%=mMap1.get("money")%> + '_' + rowIndex,true); //����˰������
    <%-- setNeedCheck( <%=mMap1.get("taxrate")%> + '_' + rowIndex,true); //˰�ʷǱ��� --%>
    setNeedCheck( <%=mMap1.get("currency")%> + '_' + rowIndex,true); //���ֱ���
    setNeedCheck( <%=mMap1.get("exchangerate")%> + '_' + rowIndex,true); //���ʱ���
    setNeedCheck( <%=mMap1.get("localmoney")%> + '_' + rowIndex,true); //���ҽ�����

    //������Ŀ����
    jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_' + rowIndex).show(); //���غ�˰��� 
    jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).show(); //���ز���˰���   
    jQuery('#field' + <%=mMap1.get("taxrate")%> + '_' + rowIndex +'_browserbtn').show(); //����˰��browser    
    jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex +'_browserbtn').show(); //���ر���browser    
    jQuery('#field' + <%=mMap1.get("exchangerate")%> + '_' + rowIndex).show(); //���ػ��� 
    jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).show(); //���ر��ҽ�� 
}
// 20171209 added by ect jiajing end
//20171219 added by ect jiajing start
//ס�ޱ�׼�Ƿ�Ϊ����
function expensestandardcheck(){
    var returnflag = true;
    var arrDetailLine8 = document.getElementsByName('check_node_8');
    for(var k = 0; k < arrDetailLine8.length; k++){
        var rowIndex = arrDetailLine8[k].value;
        var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%> + '_' + rowIndex).val(); //ס�ޱ�׼
        if(isNaN(expensestandard) && (expensestandard != '' || expensestandard != null)){
            alert('ס�޷�����Ϣ����'+(getFloat(rowIndex)+1)+'��ס�ޱ�׼����������');
            returnflag = false ;
        }
    }
    return returnflag;
}
//������׼�Ƿ�Ϊ����
function allowancecheck(){
    var returnflag = true;
    var arrDetailLine9 = document.getElementsByName('check_node_9');
    for(var k = 0; k < arrDetailLine9.length; k++){
        var rowIndex = arrDetailLine9[k].value;
        var allowance = jQuery('#field' + <%=mMap10.get("allowance")%> + '_' + rowIndex).val(); //ס�ޱ�׼
        if(isNaN(allowance) && (allowance != '' || allowance != null)){
            alert('������������������Ϣ����'+(getFloat(rowIndex)+1)+'�в�����׼����������');
            returnflag = false ;
        }
    }
    return returnflag;
}
//20171226 added by ect mayue start
function checkReimbursementMoney(){ //��֤�����ܽ��ͱ�������ϸ����Ƿ�һ��
    var returnflag = true;
    var totalmoney = 0;
    var data = new Array();
    var applytotalmoney = jQuery('#field' + <%=mMap.get("applytotalmoney")%>).val();//�ܽ��
    var arrDetailLine = document.getElementsByName('check_node_0');
    for(var k = 0; k < arrDetailLine.length; k++){
        var rowIndex = arrDetailLine[k].value;
        var currency = jQuery('#field' + <%=mMap.get("currency")%>).val(); //����
        var currency1 = jQuery('#field' + <%=mMap1.get("currency")%> + '_' + rowIndex).val(); //����
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_' + rowIndex).val();//��Ŀ��
        var localmoney = jQuery('#field' + <%=mMap1.get("localmoney")%> + '_' + rowIndex).val().replace(',','');//���ҽ��
        var money = jQuery('#field' + <%=mMap1.get("money")%> + '_' + rowIndex).val().replace(',','');//����˰���
        var taxmoney = jQuery('#field' + <%=mMap1.get("taxmoney")%> + '_' + rowIndex).val();//˰��
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
//20180315 added by zuoxl for �������루���ñ�������׼���ƣ�
//��ȡ��ͨ���߱�׼
function getVehicleStandard(rowIndex){
	var hrlevel = jQuery('#field' + <%=mMap8.get("hrlevel")%> + '_'+rowIndex).val(); //��Ա����
    var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//�����˹�˾
    var expensestandard = '';
    //������Ա�����ȡ��ͨ���߱�׼
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

//��ȡס�ޱ�׼
function getExpenseStandard(rowIndex){
        var hrlevel = jQuery('#field' + <%=mMap9.get("hrlevel")%> + '_'+rowIndex).val(); //��Ա����
        var cityCategory = jQuery('#field' + <%=mMap9.get("citycategory")%> + '_'+rowIndex).val(); //�������
        var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//�����˹�˾
        var expensestandard = '';
        //������Ա�����ȡ��ͨ���߱�׼
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

//��ȡ������׼
function getAllowanceStandard(rowIndex){
        var hrlevel = jQuery('#field' + <%=mMap10.get("hrlevel")%> + '_'+rowIndex).val(); //��Ա����
        var transactiontype = jQuery('#field' + <%=mMap10.get("transactiontype")%> + '_'+rowIndex).val(); //�������
        var org_id = jQuery('#field' + <%=mMap.get("applysubcompany")%>).val();//�����˹�˾
        var allowanceStandard = '';
		var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();//���
		if(parseFloat(type) == 0){//20180919 added by ect haiyong 
        //������Ա�����ȡ��ͨ���߱�׼
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

//����ҳ�潻ͨ���������ť��ȡ��Ӧ����sortֵ
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

//��ϸ����ӿ���
function addRowControl(formId,rownum){
	
	var rowIndex = rownum;
    if(rownum == 'no'){ 
        rowIndex = 1 * parseInt(document.getElementById("indexnum"+formId).value)-1; //��ȡ��ǰ�е�����       
    }
    if(rowIndex<0){
        return ;
    }
	//��ͨ��ϸ��
	if(formId=='7'){
		//���ý�ͨ���Ƿ񳬱�Ϊֻ��
		jQuery('#field' + <%=mMap8.get("isstandard")%>+ '_'+rowIndex).attr('readOnly',true);
		//���ý�ͨ�� ��ͨ���߱�׼Ϊ���������ߡ�ʱ��עΪ����
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
	//ס����ϸ��
	if(formId=='8'){
		//����ס�ޱ�׼Ϊֻ��
		jQuery('#field' + <%=mMap9.get("expensestandard")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//����ס�ޱ�׼�ܶ�Ϊֻ��
		jQuery('#field' + <%=mMap9.get("expensetotalstandard")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//����ס�����Ƿ񳬱�Ϊֻ��
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
	//������
	if(formId=='9'){
		//���ò�����׼Ϊֻ��
		jQuery('#field' + <%=mMap10.get("allowance")%>+ '_'+rowIndex + '').attr('readOnly',true);
		//���ò�����׼�ܶ�Ϊֻ��
		jQuery('#field' + <%=mMap10.get("allowancetotal")%> + '_'+rowIndex + '').attr('readOnly',true);
		//���ò�����׼�ܶ�Ϊֻ��
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
		//20180919 added by haiyong  for �����onchange�¼� start
		var type = jQuery('#field' + <%=mMap10.get("type")%> + '_'+rowIndex);
		type.removeAttr('onchange');
		type.bind('change',function(){
			if(parseFloat(type.val())==0){
				getAllowanceStandard(rowIndex);
			}else{
				setCol(<%=mMap10.get("allowance")%> + '_'+ rowIndex, parseFloat(0), false,'');
			}
		});
		//20180919 added by haiyong  for �����onchange�¼� end
	}
}



//���������ͱ�׼��� �����ܽ���׼
function countStandardMoney(day,standard){
	var totalStandard = parseFloat(day)*parseFloat(standard);
	return totalStandard;
}
//���ݱ������������س������뵥��
function setTripApplyCode(expensebill){
	if(expensebill.val()==1||expensebill.val()==2){
    	jQuery("#tripapplycode").show();
    	
    }else{
    	jQuery("#tripapplycode").hide();
    	setCol(<%=mMap.get("tripapplycode")%>, '', true, '');
    }
}

//У����Աְ���Ƿ����
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
        		  alert("��ά����Աְ����Ϣ�������");
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

//�ύǰ��֤��ͨ��׼
function checkAllVehicle(){
	var flag = '-1';
    var detailLine8 = document.getElementsByName('check_node_7');
    for(var i = 0;i < detailLine8.length;i++){
    	var rowIndex = detailLine8[i].value; //��ȡ��ǰ�е�����
    	var vehicleStandard = jQuery('#field' + <%=mMap8.get("vehiclestandard")%>+ "_" + rowIndex).val();
    	var vehicle = jQuery('#field' + <%=mMap8.get("vehicle")%>+ "_" + rowIndex).val();
    	var vehicleStandardSort = getVehicleSort(vehicleStandard);
    	var vehicleSort = getVehicleSort(vehicle);
    	if(parseFloat(vehicleStandardSort )<parseFloat(vehicleSort)){
  	  		setCol(<%=mMap8.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
  	  		var lineno = parseFloat(i)+1;
  	  		if(!confirm("��" + lineno +"�н�ͨ���ñ�׼���꣬�Ƿ��ύ��")){
  	  			flag = i+1;
  	  			return;
  	  		}
    	}else{
    		setCol(<%=mMap8.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
    	}
    }
    return flag;
}
//�ύǰ��֤ס�ޱ�׼
function checkAllExpense(){
	var flag = '-1';
    var detailLine9 = document.getElementsByName('check_node_8');
    for(var i = 0;i < detailLine9.length;i++){
    	var rowIndex = detailLine9[i].value; //��ȡ��ǰ�е�����    	
    	var accomdateStandard = jQuery('#field' + <%=mMap9.get("expensetotalstandard")%>+ "_" + rowIndex).val();
    	var accomdate = jQuery('#field' + <%=mMap9.get("hotelexpense")%>+ "_" + rowIndex).val();
    	if(parseFloat(accomdateStandard)<parseFloat(accomdate)){
  	  		setCol(<%=mMap9.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
  	  		var lineno = parseFloat(i)+1;
  	  		if(!confirm("��" + lineno +"��ס�޷��ñ�׼���꣬�Ƿ��ύ��")){
  	  			flag = i+1;
  	  			return;
  	  		}
    	}else{
    		setCol(<%=mMap9.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
    	}
    }
    return flag;
}

//�ύǰ��֤������׼
function checkAllAllowance(){
	var flag = '-1';
    var detailLine10 = document.getElementsByName('check_node_9');
    for(var i = 0;i < detailLine10.length;i++){
    	var rowIndex = detailLine10[i].value; //��ȡ��ǰ�е�����
		var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();
		if(parseFloat(type) == 0){//20180919 added by ect haiyong ѡ������������ʾΪ����
			var allowanceStandard = jQuery('#field' + <%=mMap10.get("allowancetotal")%>+ "_" + rowIndex).val();
			var allowance = jQuery('#field' + <%=mMap10.get("invoicemoney")%>+ "_" + rowIndex).val();
			if(parseFloat(allowanceStandard)<parseFloat(allowance)){
				setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
				var lineno = parseFloat(i)+1;
				if(!confirm("��" + lineno +"�в������ñ�׼���꣬�Ƿ��ύ��")){
					flag = i+1;
					return;
				}
			}else{
				setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
			}
		}else{
			setCol(<%=mMap10.get("isstandard")%> + "_" + rowIndex, "����", false, "����");
		}
	}
		return flag;
}
//�ύǰ��֤��ͨ����Ա����
function checkVehicleHrlevel(){
	var flag = -1;
	var detailLine8 = document.getElementsByName('check_node_7');
    for(var i = 0;i < detailLine8.length;i++){
    	var rowIndex = detailLine8[i].value; //��ȡ��ǰ�е�����
    	var hrlevel = jQuery('#field' + <%=mMap8.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//�ύǰ��֤ס������Ա����
function checkExpenseHrlevel(){
	var flag = -1;
	var detailLine9 = document.getElementsByName('check_node_8');
    for(var i = 0;i < detailLine9.length;i++){
    	var rowIndex = detailLine9[i].value; //��ȡ��ǰ�е�����
    	var hrlevel = jQuery('#field' + <%=mMap9.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//�ύǰ��֤��������Ա����
function checkAllowanceHrlevel(){
	var flag = -1;
	var detailLine10 = document.getElementsByName('check_node_9');
    for(var i = 0;i < detailLine10.length;i++){
    	var rowIndex = detailLine10[i].value; //��ȡ��ǰ�е�����
    	var hrlevel = jQuery('#field' + <%=mMap10.get("hrlevel")%>+ "_" + rowIndex).val();
    	if(hrlevel ==''){
    		flag = i+1;
    		return;
    	}
    }
    return flag;
}

//�ύǰУ�齻ͨ���߱�׼�Ƿ�Ϊ��
function checkVehicleStandard(){
		var flag = -1;
		var detailLine8 = document.getElementsByName('check_node_7');
	    for(var i = 0;i < detailLine8.length;i++){
	    	var rowIndex = detailLine8[i].value; //��ȡ��ǰ�е�����
	    	var vehiclestandard = jQuery('#field' + <%=mMap8.get("vehiclestandard")%>+ "_" + rowIndex).val();
	    	if(vehiclestandard == 0){
	    		flag = i+1;
	    		return;
	    	}
	    }
	    return flag;
}
//�ύǰУ��ס�޷��ñ�׼�Ƿ�Ϊ��
function checkExpenseStandard(){
		var flag = -1;
		var detailLine9 = document.getElementsByName('check_node_8');
	    for(var i = 0;i < detailLine9.length;i++){
	    	var rowIndex = detailLine9[i].value; //��ȡ��ǰ�е�����
	    	var expensestandard = jQuery('#field' + <%=mMap9.get("expensestandard")%>+ "_" + rowIndex).val();
	    	if(expensestandard == 0){
	    		flag = i+1;
	    		return;
	    	}
	    }
	    return flag;
}
//�ύǰУ�鲹�����ñ�׼�Ƿ�Ϊ��
function checkAllowanceStandard(){
		var flag = -1;
		var detailLine10 = document.getElementsByName('check_node_9');
	    for(var i = 0;i < detailLine10.length;i++){
	    	var rowIndex = detailLine10[i].value; //��ȡ��ǰ�е�����
	    	var allowance = jQuery('#field' + <%=mMap10.get("allowance")%>+ "_" + rowIndex).val();
			var type = jQuery('#field' + <%=mMap10.get("type")%>+ "_" + rowIndex).val();
			if(parseFloat(type) == 0){//20180919 added by ect haiyong ѡ���������ò�����׼Ϊ0
				if(allowance == 0){
					flag = i+1;
					return;
				}
			}
	    }
	    return flag;
}
//20180315 added by zuoxl for �������루���ñ�������׼���ƣ�  end
//20180329 added by mengly for �������뵥���� begin
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
//20180329 added by mengly for �������뵥���� end

//20180404 added by zuoxl �����ı�������Ǳ���   booleΪtrue����Ϊ���booleΪfalse����Ϊ�Ǳ�������ֵ��
function setNeedCheck_cc(fieldid_no,boole){
  var field_c = 'field' + fieldid_no;
  var textValue = "<IMG align=absMiddle src='/images/BacoError_wev8.gif' />" ;
  btzd = jQuery("input[name='needcheck']").val();
  var fieldIds = "" ;
  if(boole == true){
    //��ӱ���
    jQuery("#"+field_c+ "span").html(textValue);
    jQuery("#"+field_c).attr('viewtype','1');
    //�����ֶ�id
    fieldIds = btzd + "," + field_c ;
    jQuery( "input[name='needcheck']").val(fieldIds);
  }else{
    //ȡ������
    jQuery("#"+field_c+"span" ).html('');
    //�����ֶ�id
    fieldIds = btzd.replace(new RegExp(("," + field_c),"gm"), "") ;
    jQuery( "input[name='needcheck']").val(fieldIds);
  }
}
//20180514 added by zuoxl for �ύǰУ�鸶���ܽ�� ��Ϊ�գ���ɾ���տ�����ϸ  begin
function checkPayShareB4Submit(){
	var org_id = jQuery('#field' + <%=mMap.get("applycompany")%>).val();
	var requestid_c = jQuery('#field' + <%=mMap.get("requestid_c")%>).val();
	var paytotalmoney = jQuery('#field' + <%=mMap.get("paytotalmoney")%>).val();
	if(paytotalmoney==0){
		delete_p_header_dt1(requestid_c,org_id);//ɾ���տ�����ϸ��
		delete_p_header(requestid_c,org_id);//ɾ���տ�����ϸͷ��
		update_requestid_c(requestid_c);//ɾ���������տ�����ϸ��ʶ
	}
	
}
//ɾ���տ�����ϸͷ��
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
	        alert('ɾ���տ�����ϸͷ�����');
	      }
	    });
}
//ɾ���տ�����ϸ��ϸ�б�
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
	        alert('ɾ���տ�����ϸ��ϸ�б����');
	      }
	    });
}
//ɾ�������й����տ�����ϸ��ʶ
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
	        alert('ɾ�������й����տ�����ϸ��ʶ����');
	      }
	    });
}
//20180514 added by zuoxl for �ύǰУ�鸶���ܽ�� ��Ϊ�գ���ɾ���տ�����ϸ  end
//20180601 added by lixw for ˢ�·�Ʊ��ť start
/**
 * ˢ�·�Ʊ��Ϣ
 */
function flushInvoice() {
	if(requestid == -1){
        alert('���ȱ�����ڽ���ˢ�·�Ʊ��ϸ');
        return false;
    }
	var data = "";
	// ��ѯ�Ƿ�༭����Ʊ��ϸ
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
	        alert('ˢ�·�Ʊ����');
	      }
	    });
	  if(data.length > 0){
		  var billid = data[0].ID;
		// �༭
	     window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=0&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  // ���
	   // window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=3&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  }else{
		// ����
		 window.open('/formmode/view/AddFormMode.jsp?modeId=2061&formId=-68&type=1&layoutid=2564&requestid=' + requestid + '&source=2');
	  }
	
}

/**
 * ˢ�·�Ʊ��Ϣ
 */
function flushInvoices() {
	if(requestid == -1){
        alert('���ȱ�����ڽ���ˢ�·�Ʊ��ϸ');
        return false;
    }
	var data = "";
	// ��ѯ�Ƿ�༭����Ʊ��ϸ
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
	        alert('ˢ�·�Ʊ����');
	      }
	    });
	  if(data.length > 0){
		  var billid = data[0].ID;
	  // ���
	   window.open('/formmode/view/AddFormMode.jsp?isfromTab=0&modeId=2061&formId=-68&type=3&billid='+billid+'&iscreate=1&messageid=&viewfrom=&opentype=0&customid=0&isopenbyself=&isdialog=&isclose=1&templateid=0&mainid=0&istabinline=0&tabcount=0');
	  }else{
		//�޷�Ʊ
	   alert('�޷�Ʊ��Ϣ');
	  }
	
}
//20180601 added by lixw for ˢ�·�Ʊ��ť end
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
	        alert('��ȡ�������뵥mainid����');
	      }
	    });
	return applybill_mainid;
}
//20180530 added by ect lijian for ��ѯ��֯��λ������� start
//��ѯ��֯��λ�����������
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
      alert('��ѯ��֯��λ���������������');
    }
  });
	return status;
}
//20180530 added by ect lijian for ��ѯ��֯��λ������� end
//20180827 added by zuoxl for ��鷢Ʊ��ϸ���Ƿ���д   begin
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
		  alert('��ȡ��Ʊ��Ϣ����');
		}
	});
	if(data.length < 1){
		//20181105 modifie by zuoxl for �ύǰУ�����˰ʱ�Ƿ���д��Ʊ��ϸ  -------begin
		/*
		20190411 deleted by ect-zuoxl for ɾ������˰����Ʊ����У��
		if(!checkInputtaxExsit()&&orgid.val()=='81'){
			alert('������ϸ�д��ڽ���˰���Ʊ��ϸ����Ϊ�գ����飡');
			return false;
		}else{ */
		        //20190218 added by sdaisino  for ���ɽ���˰��  begin
		        if(!checkInputtaxExsit() && orgid.val()=='81'){
		            alert('�н���˰�У�û�н���˰��Ʊ!');
		            return false;
	                }
			//20190218 added by sdaisino for ���ɽ���˰��  end
			if(confirm('��Ʊ��Ϣδ��д���Ƿ��ύ���ݣ�')){
				return true;
			}else{
				return false;
			}
		//}
		//20181105 modified by zuoxl for �ύǰУ�����˰ʱ�Ƿ���д��Ʊ��ϸ  -------begin
		//20190218 added by sdaisino  for ���ɽ���˰��  begin
        } else {
            if(checkInputtaxExsit() && orgid.val()=='81'){
		        alert('�н���˰��Ʊ��û�н���˰��!');
		        return false;
	        }
        }
        //20190218 added by sdaisino for ���ɽ���˰��  end
	return true;
}
//20180827 added by zuoxl for ��鷢Ʊ��ϸ���Ƿ���д   end
function countywzdDetailMoney(){
	var expensebill2 = jQuery('#field' + <%=mMap.get("expense_bill_type")%>); //����������
	if(expensebill2.val() == 2){
		var detailLine0 = document.getElementsByName('check_node_0');
		for(var i = 0;i < detailLine0.length;i++){
			var rowIndex = detailLine0[i].value; //��ȡ��ǰ�е�����
			var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%>+ "_" + rowIndex).val();
			setCol(<%=mMap1.get("taxmoney")%>+ "_" + rowIndex, 0, true , 0);
			setCol(<%=mMap1.get("money")%> + "_" + rowIndex, parseFloat(currmoeny), true, parseFloat(currmoeny));
		}
	}
	return true;
}
//20181015 added by zuoxl for ����֧��ͨ��λ�ύǰУ��֧����ʽ/�տ�����ϸ
//��ȡ��λ֧��ͨ����״��
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
	        alert('��ȡ֧��ͨ����״̬����');
	      }
	});
	if("1"==status){
		return true;
	}else{
		return false;
	}
}
//У��֧����ʽ�Ƿ�Ϊ����ֱ��
function checkPayway(){
	var payway = jQuery('#field' + <%=mMap.get("payway")%>).val();
	if('HEB_PAYMENT'==payway){
		return true;
	}else{
		return false;
	}
}
//У���տ���ϸ��Ϣ�Ƿ���ȫ
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
			  alert('��ȡ�տ�����ϸ��Ϣ����');
			}
		});
	}
	for(var i =0;i<data.length;i++){
		if(data[i].BANK==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"���д���"Ϊ��,��ϵ��ά��Աά����');
		}
		if(data[i].RCVACCNO==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"�տ����˺�"Ϊ�գ���ϵ��ά��Աά����');
		}
		if(data[i].RCVBANKFULLNAME==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"�տ�����ȫ��"Ϊ�գ���ϵ��ά��Աά����');
		}
		if(data[i].RCVACCNAME==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"�տ��"Ϊ�գ���ϵ��ά��Աά����');
		}
		if(data[i].UNIONBANKNUMBER==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"���к�"Ϊ�գ���ϵ��ά��Աά����');
		}
		if(data[i].PAYCITY==''){
			rtnFlag =false;
			alert(data[i].EMPLOYEEORSUPPLIER+'-�տ���Ϣ"�տ����"Ϊ�գ���ϵ��ά��Աά����');
		}
	}
	return rtnFlag;
}	
//20181105 added by zuoxl for ��鱨����ϸ���Ƿ���д����˰��  -------begin
function checkInputtaxExsit(){
	var flag = true;
	//20190218 added by sdaisino  for ���ɽ���˰��  begin
	var detailLine0 = document.getElementsByName('check_node_0');
	for(var i = 0;i < detailLine0.length;i++){
		var rowIndex = detailLine0[i].value;
		var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> + '_'+ rowIndex); //����˰�ı�
		if(account_segment.val() == '21710101'){
			flag = false;
		}
	}
	//20190218 added by sdaisino for ���ɽ���˰��  end
	return flag;
}
//20181105 added by zuoxl for ��鱨����ϸ���Ƿ���д����˰��  -------begin
//20190507 add by raoanyu for ˰�ļ���˰��
function getTaxmoney(){
	var expensebilltype = jQuery('#field' + <%=mMap.get("expense_bill_type")%>).val(); //����������
	if(expensebilltype=='1'){ 
	var arrDetailLine1 = document.getElementsByName('check_node_0');
		for(var k = 0; k < arrDetailLine1.length; k++){
			var rowIndex = arrDetailLine1[k].value;		
			var currmoeny = jQuery('#field' + <%=mMap1.get("currmoeny")%> + '_'+ rowIndex).val();//�������
			var taxmoney = '';//˰��
			var taxrateid= jQuery('#field' + <%=mMap1.get("taxrate")%> + '_'+ rowIndex).val();;//˰��
			var taxratename=getAisinoBrowserRef(<%=mMap1.get("taxrate")%>,taxrateid);
			var feetypeval = jQuery('#field' + <%=mMap1.get("feetype")%> + '_'+ rowIndex).val();//������ϸ
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
//20190218 added by sdaisino  for ���ɽ���˰��  begin
function getTaxDetail() {
	var detailLine0 = document.getElementsByName('check_node_0');
    for(var i = 0;i < detailLine0.length;i++){
        var rowIndex = detailLine0[i].value;
        // ����˰�ı�
        var account_segment = jQuery('#field' + <%=mMap1.get("account_segment")%> +'_'+ rowIndex); 
        if(account_segment.val() == '21710101'){
            alert("��ɾ������˰�к�,�ٴ��Զ�����˰��!");
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
			    		    // ����˰
			    		    setCol(<%=mMap1.get("feetype")%> + '_' + index,json.map.REQUESTID,true,json.map.EXPENSE_ITEM);
			    		    // ˰��
				    		setCol(<%=mMap1.get("taxmoney")%> + '_' + index,list[i].TAXMONEY,false,'');
				    		// ˵��
				    		//setCol(<%=mMap1.get("feeinstruction")%> + '_' + index,list[i].TAXPAYER_NUMBER,true,'');
				    		// ����
				    		setCol(<%=mMap1.get("exchangerate")%> + '_' + index,'', true,'');
				    		// ��������
				    		setCol(<%=mMap1.get("invoicecount")%> + '_' + index, 0, true,'');
			    		} //else {
			    		//	setCol(<%=mMap1.get("feetype")%> + '_' + index,'34569',true,'����˰��');
			    		//}
			    		
			    	}
			    } else {
			    	alert("�޽���˰�У�");
			    }
			},
			error: function (){
			  alert('���ɽ���˰�д���');
			}
		});
		segmentTaxAdd();
}
//20190218 added by sdaisino for ���ɽ���˰��  end
</SCRIPT>

