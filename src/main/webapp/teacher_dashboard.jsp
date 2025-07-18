<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Teacher Dashboard</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="header">
        <img src="images/${sessionScope.teacherPhoto}" alt="Teacher Photo" height="80">
        <span>Name: ${sessionScope.teacherName}</span>
        <span>Email: ${sessionScope.teacherEmail}</span>
    </div>
    <h2>Welcome, ${sessionScope.teacherName}</h2>
    <div class="dashboard">
        <a href="manage_homework.jsp">Manage Homework</a>
        <a href="manage_fee.jsp">Manage Fee</a>
        <a href="manage_attendance.jsp">Manage Attendance</a>
        <a href="manage_performance.jsp">Manage Performance</a>
        <a href="manage_syllabus.jsp">Manage Syllabus</a>
        <a href="manage_timetable.jsp">Manage Time Table</a>
    </div>
    <a href="index.jsp">Logout</a>
</body>
</html>