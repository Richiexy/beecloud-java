<%@page import="cn.beecloud.BCEumeration.CARD_TYPE"%>
<%@ page import="cn.beecloud.bean.CreditCardInfo"%>
<%@ page import="cn.beecloud.BCEumeration.PAYPAL_CURRENCY"%>
<%@ page import="cn.beecloud.bean.BCInternationlOrder"%>
<%@ page import="cn.beecloud.BCEumeration.PAY_CHANNEL" %>
<%@ page import="cn.beecloud.BCEumeration.QR_PAY_MODE" %>
<%@ page import="cn.beecloud.BCPay" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="cn.beecloud.BCUtil" %>
<%@ page import="cn.beecloud.BeeCloud" %>
<%@ page import="cn.beecloud.bean.BCException" %>
<%@ page import="cn.beecloud.bean.BCOrder" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Properties" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="cn.beecloud.BCEumeration" %>
<%@ page import="java.util.concurrent.Exchanger" %>
<%@ include file="loadProperty.jsp" %>
<%
    /**
     功能：商户结算跳转至指定支付方式页面
     版本：3.3
     日期：2015-03-20
     说明：
     以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
     该代码仅供学习和研究使用，只是提供一个参考。

     //***********页面功能说明***********
     该页面可以在本机电脑测试。
     //********************************
     */
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; UTF-8">
    <title>pay</title>
</head>
<body>

<%

    Logger log = Logger.getLogger("pay.jsp");

    //模拟商户的交易编号、标题、金额、附加数据
    String billNo = BCUtil.generateRandomUUIDPure();
    String title = "demo测试";
    Map<String, Object> optional = new HashMap<String, Object>();
    optional.put("rui", "睿");

    String type = request.getParameter("paytype");
    PAY_CHANNEL channel;
    try {
        channel = PAY_CHANNEL.valueOf(type);
    } catch (Exception e) {
        channel = null;
        log.error(e.getMessage(), e);
    }
    boolean success = false;

    //BCPayResult的type字段有OK和非OK两种，当type字段是OK时（对应值为0），bcPayResult包含支付所需的内容如html或者code_url或者支付成功信息,
    //当type的字段为非OK的时候，，bcPayResult包含通用错误和具体的错误信息。商户系统可以任意显示，打印或者记录日志。
    BCOrder bcOrder = new BCOrder(channel, 1, billNo, title);
    BCInternationlOrder internationalOrder = new BCInternationlOrder();
    bcOrder.setBillTimeout(300);
    bcOrder.setOptional(optional);

    //以下是WX_JSAPI（公众号内支付）用到的返回参数，需要在页面的js用到
    String jsapiString = "";
    String jsapiAppid = "";
    String timeStamp = "";
    String nonceStr = "";
    String jsapipackage = "";
    String signType = "";
    String paySign = "";
    
    //以下是每个渠道的return url
    String aliReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/aliReturnUrl.jsp";
    String unReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/unReturnUrl.jsp";
    String yeeWapReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/yeeWapReturnUrl.jsp";
    String yeeWebReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/yeeWebReturnUrl.jsp";
    String jdWapReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/jdWapReturnUrl.jsp";
    String jdWebReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/jdWebReturnUrl.jsp";
    String kqReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/kqReturnUrl.jsp";
    String bdReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/bdReturnUrl.jsp";
	String paypalReturnUrl = "http://localhost:8080/PC-Web-Pay-Demo/return_url_example/paypalReturnUrl.jsp";
    	
    switch (channel) {

        case ALI_WEB:
        case ALI_WAP:
            bcOrder.setReturnUrl(aliReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getObjectId());
                Thread.sleep(3000);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case ALI_QRCODE:
            bcOrder.setQrPayMode(QR_PAY_MODE.MODE_FRONT);
            bcOrder.setReturnUrl(aliReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getObjectId());
                Thread.sleep(3000);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;

        case WX_NATIVE:
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getObjectId());
                success = true;
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;

        case WX_JSAPI:
            //微信 公众号id（读取配置文件conf.properties）及微信 redirec_uri
            Properties prop = loadProperty();
            String wxJSAPIAppId = prop.get("wxJSAPIAppId").toString();
            String wxJSAPISecret = prop.get("wxJSAPISecret").toString();
            String wxJSAPIRedirectUrl = "http://javademo.beecloud.cn/demo/pay.jsp?type=WX_NATIVE";
            String encodedWSJSAPIRedirectUrl = URLEncoder.encode(wxJSAPIRedirectUrl);
            if (request.getParameter("code") == null || request.getParameter("code") == "") {
                String redirectUrl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + wxJSAPIAppId + "&redirect_uri=" + encodedWSJSAPIRedirectUrl + "&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect";
                log.info("wx jsapi redirct url:" + redirectUrl);
                response.sendRedirect(redirectUrl);
            } else {
                String code = request.getParameter("code");
                String result = sendGet("https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + wxJSAPIAppId + "&secret=" + wxJSAPISecret + "&code=" + code + "&grant_type=authorization_code");
                log.info("result:" + result);
                JSONObject resultObject = JSONObject.fromObject(result);
                if (resultObject.containsKey("errcode")) {
                    out.println("获取access_token出错！错误信息为：" + resultObject.get("errmsg").toString());
                } else {
                    String openId = resultObject.get("openid").toString();
                    bcOrder.setOpenId(openId);
                    bcOrder = BCPay.startBCPay(bcOrder);
                    try {
                        bcOrder = BCPay.startBCPay(bcOrder);
                        out.println(bcOrder.getObjectId());
                        Map<String, String> map = bcOrder.getWxJSAPIMap();
                        jsapiAppid = map.get("appId").toString();
                        timeStamp = map.get("timeStamp").toString();
                        nonceStr = map.get("nonceStr").toString();
                        jsapipackage = map.get("package").toString();
                        signType = map.get("signType").toString();
                        paySign = map.get("paySign").toString();
                    } catch (BCException e) {
                        log.error(e.getMessage(), e);
                        out.println(e.getMessage());
                    }
                }
            }

            break;

        case UN_WEB:
            bcOrder.setReturnUrl(unReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;

        case YEE_WAP:
            //真实环境可以不需要这句话
            BeeCloud.registerApp("230b89e6-d7ff-46bb-b0b6-032f8de7c5d0", "191418f6-c0f5-4943-8171-d07bfeff46b0");
            //真实环境可以不需要这句话end
            bcOrder.setReturnUrl(yeeWapReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                response.sendRedirect(bcOrder.getUrl());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case YEE_WEB:
            bcOrder.setReturnUrl(yeeWebReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                response.sendRedirect(bcOrder.getUrl());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case YEE_NOBANKCARD:
            //易宝点卡支付参数样例
            String cardNo = "15078120125091678";
            String cardPwd = "121684730734269992";
            String frqid = "SZX";
            bcOrder.setCardNo(cardNo);
            bcOrder.setCardPwd(cardPwd);
            bcOrder.setFrqid(frqid);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getObjectId());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case JD_WAP:
            bcOrder.setReturnUrl(jdWapReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case JD_WEB:
            bcOrder.setReturnUrl(jdWebReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case KUAIQIAN_WEB:
        	bcOrder.setReturnUrl(kqReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;

        case KUAIQIAN_WAP:
            bcOrder.setReturnUrl(kqReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
        case BD_WEB:
            bcOrder.setReturnUrl(bdReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                response.sendRedirect(bcOrder.getUrl());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;

        case BD_WAP:
            bcOrder.setReturnUrl(bdReturnUrl);
            try {
                bcOrder = BCPay.startBCPay(bcOrder);
                out.println(bcOrder.getHtml());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
		
        case PAYPAL_PAYPAL:
        	internationalOrder.setChannel(PAY_CHANNEL.PAYPAL_PAYPAL);
        	internationalOrder.setBillNo(billNo);
        	internationalOrder.setCurrency(PAYPAL_CURRENCY.USD);
        	internationalOrder.setTitle("paypal test");
        	internationalOrder.setTotalFee(1);
        	internationalOrder.setReturnUrl(paypalReturnUrl);
        	 try {
        		 internationalOrder = BCPay.startBCInternatioalPay(internationalOrder);
                 response.sendRedirect(internationalOrder.getUrl());
             } catch (BCException e) {
                 log.error(e.getMessage(), e);
                 out.println(e.getMessage());
             }
             break;
        
        case PAYPAL_CREDITCARD:
        	CreditCardInfo creditCardInfo = new CreditCardInfo();
        	creditCardInfo.setCardNo("5187187005718530");
        	creditCardInfo.setExpireMonth(11);
        	creditCardInfo.setExpireYear(19);
        	creditCardInfo.setCvv(350);
        	creditCardInfo.setFirstName("RUI");
        	creditCardInfo.setLastName("FENG");
        	creditCardInfo.setCardType(CARD_TYPE.mastercard);
        	internationalOrder.setBillNo(billNo);
        	internationalOrder.setChannel(PAY_CHANNEL.PAYPAL_CREDITCARD);
        	internationalOrder.setCreditCardInfo(creditCardInfo);
        	internationalOrder.setCurrency(PAYPAL_CURRENCY.USD);
        	internationalOrder.setTitle("paypal credit card test");
        	internationalOrder.setTotalFee(1);
        	try {
       			internationalOrder = BCPay.startBCInternatioalPay(internationalOrder);
       			out.println("PAYPAL_CREDITCARD 支付成功！");
       			out.println(internationalOrder.getCreditCardId());
       			request.getSession().setAttribute("creditCardId", internationalOrder.getCreditCardId());
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
            
        case PAYPAL_SAVED_CREDITCARD:
        	internationalOrder.setBillNo(billNo);
        	internationalOrder.setChannel(PAY_CHANNEL.PAYPAL_SAVED_CREDITCARD);
        	internationalOrder.setCurrency(PAYPAL_CURRENCY.USD);
        	internationalOrder.setTitle("PAYPAL_SAVED_CREDITCARD test");
        	internationalOrder.setTotalFee(1);
        	internationalOrder.setBillNo(request.getSession().getAttribute("creditCardId").toString());
        	try {
       			internationalOrder = BCPay.startBCInternatioalPay(internationalOrder);
       			out.println("PAYPAL_SAVED_CREDITCARD 支付成功！");
            } catch (BCException e) {
                log.error(e.getMessage(), e);
                out.println(e.getMessage());
            }
            break;
            
        default:
            break;
    }
%>
<%!
    String sendGet(String url) throws Exception {
        String result = "";
        BufferedReader in = null;
        URL realUrl = new URL(url);
        // 打开和URL之间的连接
        HttpURLConnection conn = (HttpURLConnection) realUrl.openConnection();
        // 设置通用的请求属性
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setReadTimeout(5000);
        conn.setConnectTimeout(5000);
        conn.setRequestMethod("GET");
        in = new BufferedReader(
                new InputStreamReader(conn.getInputStream()));
        String line;
        while ((line = in.readLine()) != null) {
            result += line;
        }
        return result;
    }
%>
<div align="center" id="qrcode">
</div>
</body>
<script src="../js/qrcode.js"></script>
<script type="text/javascript">
    function makeqrcode() {
        var qr = qrcode(10, 'M');
        qr.addData(codeUrl);
        qr.make();
        var wording = document.createElement('p');
        wording.innerHTML = "扫我，扫我";
        var code = document.createElement('DIV');
        code.innerHTML = qr.createImgTag();
        var element = document.getElementById("qrcode");
        element.appendChild(wording);
        element.appendChild(code);
    }
    var type = '<%=type%>';
    var codeUrl;
    var success = '<%=success%>'
    if (type == 'WX_NATIVE') {
        codeUrl = '<%=bcOrder.getCodeUrl()%>';
    }

    if (type == 'WX_NATIVE' || 'true' == success) {
        makeqrcode();
    }

</script>

<script type="text/javascript">
    callpay();
    function jsApiCall() {
        var data = {
            //以下参数的值由BCPayByChannel方法返回来的数据填入即可
            "appId": "<%=jsapiAppid%>",
            "timeStamp": "<%=timeStamp%>",
            "nonceStr": "<%=nonceStr%>",
            "package": "<%=jsapipackage%>",
            "signType": "<%=signType%>",
            "paySign": "<%=paySign%>"
        };
        alert(JSON.stringify(data));
        WeixinJSBridge.invoke(
                'getBrandWCPayRequest',
                data,
                function (res) {
                    alert(res.err_msg);
                    alert(JSON.stringify(res));
                    WeixinJSBridge.log(res.err_msg);
                }
        );
    }

    function callpay() {
        if (typeof WeixinJSBridge == "undefined") {
            if (document.addEventListener) {
                document.addEventListener('WeixinJSBridgeReady', jsApiCall, false);
            } else if (document.attachEvent) {
                document.attachEvent('WeixinJSBridgeReady', jsApiCall);
                document.attachEvent('onWeixinJSBridgeReady', jsApiCall);
            }
        } else {
            jsApiCall();
        }
    }

</script>
</html>