<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String className = (String) session.getAttribute("className");

    // Days of the week
    String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"};

    // Fetch timetable for this class
    Map<String, List<Map<String, Object>>> timetable = new LinkedHashMap<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        for (String day : days) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM timetable WHERE class=? AND day=? ORDER BY start_time");
            ps.setString(1, className);
            ps.setString(2, day);
            ResultSet rs = ps.executeQuery();
            List<Map<String, Object>> periods = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> period = new HashMap<>();
                period.put("start_time", rs.getTime("start_time"));
                period.put("end_time", rs.getTime("end_time"));
                period.put("subject", rs.getString("subject"));
                period.put("is_break", rs.getBoolean("is_break"));
                period.put("break_type", rs.getString("break_type"));
                periods.add(period);
            }
            timetable.put(day, periods);
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Time Table</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .tt-table { margin: 0 auto; border-collapse: collapse; }
        .tt-table th, .tt-table td { border: 1px solid #ccc; padding: 8px 12px; }
        .break { background: #ffe599; font-weight: bold; }
        .fruits { background: #b6fcb6; }
        .lunch { background: #ffd6a5; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>
    <h2>Time Table</h2>
    <table class="tt-table">
        <tr>
            <th>Day</th>
            <th>Time</th>
            <th>Subject / Break</th>
        </tr>
        <% for (String day : days) { 
            List<Map<String, Object>> periods = timetable.get(day);
            if (periods == null) continue;
            boolean firstRow = true;
            for (Map<String, Object> period : periods) {
                String time = period.get("start_time") + " - " + period.get("end_time");
                boolean isBreak = (Boolean) period.get("is_break");
                String breakType = (String) period.get("break_type");
                String subject = (String) period.get("subject");
        %>
            <tr>
                <% if (firstRow) { %>
                    <td rowspan="<%= periods.size() %>"><%= day %></td>
                <% } %>
                <td><%= time %></td>
                <% if (isBreak) { %>
                    <td class="break <%= "Fruits".equals(breakType) ? "fruits" : "lunch" %>">
                        <%= breakType %> Break
                    </td>
                <% } else { %>
                    <td><%= subject %></td>
                <% } %>
            </tr>
        <%
                firstRow = false;
            }
        } %>
    </table>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>