<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("teacherId") == null) {
        response.sendRedirect("teacher_login.jsp");
        return;
    }
    String selectedClass = request.getParameter("class");
    String selectedDay = request.getParameter("day");

    // Days of the week
    String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"};

    // Fetch all classes for dropdown
    List<String> classes = new ArrayList<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT DISTINCT class FROM students");
        while (rs.next()) {
            classes.add(rs.getString("class"));
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }

    // Fetch timetable for selected class and day
    List<Map<String, Object>> periods = new ArrayList<>();
    if (selectedClass != null && !selectedClass.isEmpty() && selectedDay != null && !selectedDay.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM timetable WHERE class=? AND day=? ORDER BY start_time");
            ps.setString(1, selectedClass);
            ps.setString(2, selectedDay);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> period = new HashMap<>();
                period.put("id", rs.getInt("id"));
                period.put("start_time", rs.getTime("start_time"));
                period.put("end_time", rs.getTime("end_time"));
                period.put("subject", rs.getString("subject"));
                period.put("is_break", rs.getBoolean("is_break"));
                period.put("break_type", rs.getString("break_type"));
                periods.add(period);
            }
            conn.close();
        } catch (Exception e) {
            out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Time Table</title>
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
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Time Table</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Select Class:</label>
        <select name="class" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String c : classes) { %>
                <option value="<%= c %>" <%= c.equals(selectedClass) ? "selected" : "" %>><%= c %></option>
            <% } %>
        </select>
        <% if (selectedClass != null && !selectedClass.isEmpty()) { %>
            <label>Select Day:</label>
            <select name="day" onchange="this.form.submit()">
                <option value="">--Select--</option>
                <% for (String d : days) { %>
                    <option value="<%= d %>" <%= d.equals(selectedDay) ? "selected" : "" %>><%= d %></option>
                <% } %>
            </select>
        <% } %>
    </form>
    <% if (selectedClass != null && !selectedClass.isEmpty() && selectedDay != null && !selectedDay.isEmpty()) { %>
        <h3>Add Period/Break</h3>
        <form action="AddTimetableServlet" method="post">
            <input type="hidden" name="class" value="<%= selectedClass %>">
            <input type="hidden" name="day" value="<%= selectedDay %>">
            <label>Start Time:</label>
            <input type="time" name="start_time" required>
            <label>End Time:</label>
            <input type="time" name="end_time" required>
            <label>Type:</label>
            <select name="type" onchange="document.getElementById('subjectDiv').style.display = this.value == 'period' ? 'inline' : 'none'; document.getElementById('breakDiv').style.display = this.value == 'break' ? 'inline' : 'none';">
                <option value="period">Period</option>
                <option value="break">Break</option>
            </select>
            <span id="subjectDiv" style="display:inline;">
                <label>Subject:</label>
                <input type="text" name="subject">
            </span>
            <span id="breakDiv" style="display:none;">
                <label>Break Type:</label>
                <select name="break_type">
                    <option value="Fruits">Fruits</option>
                    <option value="Lunch">Lunch</option>
                </select>
            </span>
            <button type="submit">Add</button>
        </form>
        <h3>Time Table for <%= selectedDay %></h3>
        <table class="tt-table">
            <tr>
                <th>Time</th>
                <th>Subject / Break</th>
                <th>Action</th>
            </tr>
            <% for (Map<String, Object> period : periods) { 
                String time = period.get("start_time") + " - " + period.get("end_time");
                boolean isBreak = (Boolean) period.get("is_break");
                String breakType = (String) period.get("break_type");
                String subject = (String) period.get("subject");
            %>
                <tr>
                    <td><%= time %></td>
                    <% if (isBreak) { %>
                        <td class="break <%= "Fruits".equals(breakType) ? "fruits" : "lunch" %>">
                            <%= breakType %> Break
                        </td>
                    <% } else { %>
                        <td><%= subject %></td>
                    <% } %>
                    <td>
                        <form action="DeleteTimetableServlet" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= period.get("id") %>">
                            <input type="hidden" name="class" value="<%= selectedClass %>">
                            <input type="hidden" name="day" value="<%= selectedDay %>">
                            <button type="submit" onclick="return confirm('Delete this period/break?')">Delete</button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </table>
    <% } %>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>