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
    Calendar cal = Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH) + 1; // 1-based for SQL
    String monthStr = request.getParameter("month");
    String yearStr = request.getParameter("year");
    if (monthStr != null) month = Integer.parseInt(monthStr);
    if (yearStr != null) year = Integer.parseInt(yearStr);

    // Get number of days in month
    cal.set(year, month - 1, 1);
    int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

    // Fetch attendance
    Map<Integer, String> attendanceMap = new HashMap<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT DAY(date) as day, status FROM attendance WHERE student_id=? AND MONTH(date)=? AND YEAR(date)=?");
        ps.setInt(1, studentId);
        ps.setInt(2, month);
        ps.setInt(3, year);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            attendanceMap.put(rs.getInt("day"), rs.getString("status"));
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Attendance</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .attendance-table { margin: 0 auto; border-collapse: collapse; }
        .attendance-table th, .attendance-table td { border: 1px solid #ccc; padding: 8px 12px; }
        .present { background: #b6fcb6; }
        .absent { background: #ffb3b3; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>
    <h2>Attendance - <%= new java.text.DateFormatSymbols().getMonths()[month-1] %> <%= year %></h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Month:</label>
        <select name="month">
            <% for (int m = 1; m <= 12; m++) { %>
                <option value="<%= m %>" <%= m == month ? "selected" : "" %>><%= new java.text.DateFormatSymbols().getMonths()[m-1] %></option>
            <% } %>
        </select>
        <label>Year:</label>
        <select name="year">
            <% for (int y = year-2; y <= year+1; y++) { %>
                <option value="<%= y %>" <%= y == year ? "selected" : "" %>><%= y %></option>
            <% } %>
        </select>
        <button type="submit">Go</button>
    </form>
    <table class="attendance-table">
        <tr>
            <th>Date</th>
            <th>Status</th>
        </tr>
        <% for (int d = 1; d <= daysInMonth; d++) { 
            String status = attendanceMap.getOrDefault(d, "Absent");
            String css = "Present".equals(status) ? "present" : "absent";
        %>
            <tr>
                <td><%= d %> <%= new java.text.DateFormatSymbols().getMonths()[month-1].substring(0,3) %></td>
                <td class="<%= css %>"><%= status %></td>
            </tr>
        <% } %>
    </table>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>