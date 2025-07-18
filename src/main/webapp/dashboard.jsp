<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="header">
        <img src="images/${sessionScope.photo}" alt="Student Photo" height="80">
        <span>Name: ${sessionScope.name}</span>
        <span>Class: ${sessionScope.className}</span>
        <span>Roll No: ${sessionScope.roll_no}</span>
    </div>
    <h2>Welcome, ${sessionScope.name}</h2>
    <div class="dashboard">
        <a href="homework.jsp">Homework</a>
        <a href="fee.jsp">Fee</a>
        <a href="attendence.jsp">Attendance</a>
        <a href="performance.jsp">Performance</a>
        <a href="syllabus.jsp">Syllabus</a>
        <a href="timetable.jsp">Time Table</a>
    </div>
    <a href="index.jsp">Logout</a>
</body>
</html>