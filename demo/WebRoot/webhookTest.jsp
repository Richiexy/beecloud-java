<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="cn.beecloud.*"%>
<%@ page import="java.util.Date"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; UTF-8">
<link href="demo.css" rel="stylesheet" type="text/css"/>
<title>Webhook Test Page</title>
<script type="text/javascript">
</script>
</head>
<body>
<%
	String transactionId = request.getParameter("transactionId");

	System.out.println("transactionId " + transactionId);
	
	String channel = request.getParameter("channel");
	
	if(channel.contains("_")){
		channel = channel.split("_")[0];
	}
	
	System.out.println("channel " + channel);
	
	String type = request.getParameter("type");
	
	System.out.println("type " + type);
	
	BCQueryResult result = BCPay.startQueryCountByConditon(channel, "webhook_result__", type, transactionId);
	if (result.getType().ordinal() == 0) {
		System.out.println(result.getTotalCount());
		if (result.getTotalCount() >0) {
			out.println("SUCCESS");	
		} else {
			out.println("FAIL");	
		}
	}else {
		out.println(result.getErrMsg());
		out.println(result.getErrDetail());
	}
%>
</body>
</html>