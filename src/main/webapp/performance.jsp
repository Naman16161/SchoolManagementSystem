<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Integer studentId = (Integer) session.getAttribute("studentId");

    // Fetch test results
    List<Map<String, Object>> results = new ArrayList<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT p.test_name, p.subject, p.marks_obtained, p.total_marks, " +
            "(SELECT remark FROM teacher_remarks tr WHERE tr.student_id=p.student_id AND tr.test_name=p.test_name LIMIT 1) AS remark " +
            "FROM performance p WHERE p.student_id=? ORDER BY p.test_name, p.subject");
        ps.setInt(1, studentId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("test_name", rs.getString("test_name"));
            row.put("subject", rs.getString("subject"));
            row.put("marks_obtained", rs.getDouble("marks_obtained"));
            row.put("total_marks", rs.getDouble("total_marks"));
            row.put("remark", rs.getString("remark"));
            results.add(row);
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Performance</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .perf-table { margin: 0 auto; border-collapse: collapse; }
        .perf-table th, .perf-table td { border: 1px solid #ccc; padding: 8px 12px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>
    <h2>Performance</h2>
    <table class="perf-table">
        <tr>
            <th>Test Name</th>
            <th>Subject</th>
            <th>Marks Obtained</th>
            <th>Total Marks</th>
            <th>Percentage</th>
            <th>Teacher's Remark</th>
        </tr>
        <% for (Map<String, Object> row : results) { 
            double marks = (Double)row.get("marks_obtained");
            double total = (Double)row.get("total_marks");
            double percent = total > 0 ? (marks * 100.0 / total) : 0;
        %>
            <tr>
                <td><%= row.get("test_name") %></td>
                <td><%= row.get("subject") %></td>
                <td><%= marks %></td>
                <td><%= total %></td>
                <td><%= String.format("%.2f", percent) %>%</td>
                <td><%= row.get("remark") != null ? row.get("remark") : "" %></td>
            </tr>
        <% } %>
    </table>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>